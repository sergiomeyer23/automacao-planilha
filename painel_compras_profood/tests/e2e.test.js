/* Testes de ponta a ponta no Chromium (Playwright) com o ARTEFATO FINAL (entrega/bi_oc_sankhya.jsp):
 * o servidor de teste remove as diretivas JSP, resolve as 3 expressões EL e injeta um executeQuery
 * falso que roda o SQL gerado no DuckDB. Isso testa a integração da página com o contrato
 * executeQuery(sql, params, ok, erro); NÃO é o Construtor de BI nem o Oracle. */
"use strict";
const test = require("node:test");
const assert = require("node:assert/strict");
const path = require("path");
const fs = require("fs");
const { spawn, execSync } = require("child_process");
const S = require("./lib/sql_runner.js");
const A = require("./lib/apoio.js");
const Motor = require("../src/motor.js");
const build = require("../scripts/build.js");

function carregarPlaywright() {
  try { return require("playwright"); } catch (e) { /* tenta a instalação global */ }
  try { return require(path.join(execSync("npm root -g", { encoding: "utf8" }).trim(), "playwright")); } catch (e) { return null; }
}
const pw = carregarPlaywright();
const py = S.python();
const motivoPulo = !pw ? "Playwright indisponível" : !py ? "Python com DuckDB indisponível" : false;
const FIXTURE = path.join(__dirname, "fixtures", "e2e_banco.json");

function subirServidor(porta, env) {
  const proc = spawn(py, [path.join(__dirname, "e2e", "servidor.py"), String(porta), FIXTURE], { env: Object.assign({}, process.env, env || {}), stdio: "ignore" });
  return new Promise((ok, falha) => {
    const t0 = Date.now();
    (function tentar() {
      require("http").get("http://127.0.0.1:" + porta + "/painel.html", (r) => { r.resume(); ok(proc); })
        .on("error", () => (Date.now() - t0 > 20000 ? falha(new Error("servidor não subiu")) : setTimeout(tentar, 200)));
    })();
  });
}
async function abrir(browser, url) {
  const pg = await browser.newPage({ viewport: { width: 1440, height: 1000 }, acceptDownloads: true });
  pg.erros = [];
  pg.on("pageerror", (e) => pg.erros.push(e.message));
  await pg.goto(url);
  return pg;
}
const esperarKpis = (pg) => pg.waitForFunction(() => document.querySelectorAll("#exec-kpis .kpi").length >= 8 && !document.querySelector("#exec-top .carregando"), null, { timeout: 240000 });

test("e2e", { skip: motivoPulo, timeout: 900000 }, async (t) => {
  if (!fs.existsSync(FIXTURE)) execSync("node " + path.join(__dirname, "e2e", "gerar_fixture_e2e.js"));
  build.principal();
  const fx = JSON.parse(fs.readFileSync(FIXTURE, "utf8"));
  const srv = await subirServidor(8791);
  const browser = await pw.chromium.launch();
  try {
    await t.test("sem executeQuery a página bloqueia (não vira mockup)", async () => {
      const pg = await abrir(browser, "http://127.0.0.1:8791/painel.html");
      await pg.waitForSelector("#bloqueio:not([hidden])");
      assert.match(await pg.textContent("#bloqueio"), /executeQuery/);
      assert.deepEqual(pg.erros, []);
      await pg.close();
    });

    await t.test("modo real: carrega, totais iguais ao cálculo de referência, sem XSS", async () => {
      const pg = await abrir(browser, "http://127.0.0.1:8791/painel_real.html");
      await esperarKpis(pg);
      const Q = S.consultas();
      const res = Motor.executar("Q_RESUMO", A.porNome(Q.Q_RESUMO, A.binds(Q.Q_RESUMO, A.valoresPadrao({}))), fx.tabelas, { config: A.CONFIG, sysdate: fx.sysdate });
      const n = (p) => { const r = res.find((x) => x.PRIORIDADE === p); return r ? r.N_SKUS : 0; };
      const kpi = await pg.textContent("#exec-kpis .kpi:first-child .kpi-v");
      assert.equal(kpi.trim(), String(n("P1_CRITICO") + n("P2_RUPTURA_IMINENTE")));
      assert.match(await pg.textContent("#contexto"), /Data-base do cálculo: 17\/11\/2026/);
      assert.match(await pg.textContent("#exec-kpis"), /OTIF\s*Indisponível/);
      assert.match(await pg.textContent("#exec-kpis"), /Aderência.*Indisponível/s);
      await pg.click("button[data-pg=fila]");
      await pg.waitForSelector("#fila-tab tr.lin", { timeout: 240000 });
      await pg.fill("#ff-busca", "9001");
      await pg.waitForFunction(() => document.querySelectorAll("#fila-tab tr.lin").length >= 1);
      assert.match(await pg.textContent("#fila-tab"), /<img src=x onerror=/, "texto malicioso aparece como texto");
      assert.equal(await pg.evaluate(() => document.querySelectorAll("#fila-tab img, #fila-tab script").length), 0);
      await pg.click("button[data-pg=carteira]");
      await pg.waitForFunction(() => document.querySelectorAll("#oc-tab tr.lin").length > 0, null, { timeout: 240000 });
      assert.equal(await pg.evaluate(() => window.__xss), undefined, "nenhum script injetado executou");
      assert.deepEqual(pg.erros, []);
      await pg.close();
    });

    await t.test("respostas fora de ordem: só o último filtro é renderizado", async () => {
      const pg = await abrir(browser, "http://127.0.0.1:8791/painel_real.html");
      await esperarKpis(pg);
      await pg.click("button[data-pg=fila]");
      await pg.waitForSelector("#fila-tab tr.lin", { timeout: 240000 });
      for (const u of ["REVISAR", "EXCESSO", "TODOS", "REVISAR", "ATENCAO"]) await pg.selectOption("#ff-universo", u);
      await pg.waitForFunction(() => /universo “Precisa de atenção/.test(document.querySelector("#fila-resumo").textContent) && !document.querySelector("#fila-tab .carregando"), null, { timeout: 240000 });
      await pg.waitForTimeout(4000);
      const Q = S.consultas();
      const esperado = Motor.executar("Q_PLANO", A.porNome(Q.Q_PLANO, A.binds(Q.Q_PLANO, A.valoresPadrao({ FILTRO_FILA: "ATENCAO" }))), fx.tabelas, { config: A.CONFIG, sysdate: fx.sysdate }).length;
      assert.equal(await pg.evaluate(() => document.querySelectorAll("#fila-tab tr.lin").length), esperado);
      assert.match(await pg.textContent("#fila-resumo"), /Precisa de atenção/);
      await pg.close();
    });

    await t.test("detalhe por produto e drill-down de OC/consumo", async () => {
      const pg = await abrir(browser, "http://127.0.0.1:8791/painel_real.html");
      await esperarKpis(pg);
      await pg.click("button[data-pg=fila]");
      await pg.waitForSelector("#fila-tab tr.lin", { timeout: 240000 });
      await pg.click("#fila-tab tr.lin");
      await pg.waitForSelector("#fila-tab tr.det");
      const det = await pg.textContent("#fila-tab tr.det");
      ["Estoque e compromissos", "Demanda", "Política de cobertura", "Necessidade", "Preço de referência", "não validada"].forEach((s) => assert.ok(det.indexOf(s) >= 0, s));
      await pg.click("#fila-tab tr.det button[data-acao=cons-prod]");
      await pg.waitForFunction(() => /Consumo mensal/.test(document.querySelector("#fila-tab tr.det").textContent), null, { timeout: 120000 });
      await pg.click("#fila-tab tr.det button[data-acao=ocs-prod]");
      await pg.waitForFunction(() => /OCs abertas do produto|Nenhum item de OC aberto/.test(document.querySelector("#fila-tab tr.det").textContent), null, { timeout: 120000 });
      await pg.close();
    });

    await t.test("exportação CSV: mesmos filtros, pt-BR e protegida contra fórmula", async () => {
      const pg = await abrir(browser, "http://127.0.0.1:8791/painel_real.html");
      await esperarKpis(pg);
      await pg.click("button[data-pg=carteira]");
      await pg.selectOption("#fo-filtro", "TODAS");
      await pg.waitForFunction(() => /no recorte/.test(document.querySelector("#oc-resumo").textContent) && document.querySelectorAll("#oc-tab tr.lin").length > 0, null, { timeout: 240000 });
      await pg.fill("#fo-busca", "HYPERLINK");
      const nTela = await pg.evaluate(() => document.querySelectorAll("#oc-tab tr.lin").length);
      const [dl] = await Promise.all([pg.waitForEvent("download"), pg.click("#fo-csv")]);
      const csv = fs.readFileSync(await dl.path(), "utf8");
      assert.ok(csv.charCodeAt(0) === 0xfeff, "BOM para o Excel");
      const linhas = csv.replace(/^﻿/, "").split("\r\n").filter(Boolean);
      assert.equal(linhas.length - 1, nTela, "exporta exatamente as linhas filtradas na tela");
      assert.ok(linhas[0].split(";").length > 20);
      assert.ok(linhas.slice(1).every((l) => l.indexOf("\"'=HYPERLINK(") >= 0), "fórmula neutralizada");
      assert.match(dl.suggestedFilename(), /^ocs_abertas_TODAS_/);
      await pg.close();
    });

    await t.test("parâmetros e qualidade: tabela opcional ausente é informada, não vira erro genérico", async () => {
      const pg = await abrir(browser, "http://127.0.0.1:8791/painel_real.html");
      await esperarKpis(pg);
      assert.match(await pg.textContent("#avisos"), /BI_PARAM_COMPRA não encontrada/);
      await pg.click("button[data-pg=param]");
      await pg.waitForSelector("#par-qual table");
      assert.match(await pg.textContent("#par-tab"), /não existe \(opcional\)/);
      assert.match(await pg.textContent("#par-map"), /PERDA\s*nenhuma/);
      assert.match(await pg.textContent("#par-log"), /Q_PARAMS\s*erro/);
      await pg.click("#b-snap");
      await pg.waitForFunction(() => /tabela opcional não existe/.test(document.querySelector("#par-diag").textContent), null, { timeout: 60000 });
      await pg.close();
    });

    await t.test("modo demonstração é identificado e não usa executeQuery", async () => {
      const pg = await abrir(browser, "http://127.0.0.1:8791/painel.html?modo=demo&opcionais=1");
      await esperarKpis(pg);
      assert.equal(await pg.isVisible("#selo-demo"), true);
      assert.match(await pg.title(), /DEMONSTRAÇÃO/);
      assert.match(await pg.textContent("#contexto"), /DEMONSTRAÇÃO/);
      const av = await pg.textContent("#avisos");
      assert.match(av, /DIVISOR_MEDIA: Removido/, "chave legada avisada");
      assert.match(av, /SEGURANCA_PCT_LT fora da faixa/, "valor inválido recusado");
      assert.deepEqual(pg.erros, []);
      await pg.close();
    });
  } finally {
    await browser.close();
    srv.kill();
  }

  const srv2 = await subirServidor(8792, { ERRO_SE_CONTEM: "res AS (|ORA-00904: \"X\".\"Y\": invalid identifier" });
  const b2 = await pw.chromium.launch();
  try {
    await t.test("erro de coluna não é mascarado como tabela ausente", async () => {
      const pg = await abrir(b2, "http://127.0.0.1:8792/painel_real.html");
      await pg.waitForSelector("#exec-kpis .erro", { timeout: 240000 });
      const txt = await pg.textContent("#exec-kpis");
      assert.match(txt, /Coluna inexistente/);
      assert.match(txt, /ORA-00904/);
      assert.doesNotMatch(txt, /tabela opcional/i);
      await pg.close();
    });
  } finally {
    await b2.close();
    srv2.kill();
  }
});
