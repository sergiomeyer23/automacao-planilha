/* Build e validação estática: somente leitura, binds, portabilidade, JSP, determinismo e contrato UI × consultas. */
"use strict";
const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
const { spawnSync } = require("child_process");
const build = require("../scripts/build.js");
const Motor = require("../src/motor.js");
const Demo = require("../src/demo.js");
const A = require("./lib/apoio.js");
const S = require("./lib/sql_runner.js");

const RAIZ = path.resolve(__dirname, "..");
const conf = build.carregarConfig();
const consultas = build.montarConsultas(conf, build.carregarMacros());

test("build é determinístico e produz o JSP sem edição manual", () => {
  build.principal();
  const a = crypto.createHash("sha256").update(fs.readFileSync(path.join(RAIZ, "entrega", "bi_oc_sankhya.jsp"))).digest("hex");
  build.principal();
  const b = crypto.createHash("sha256").update(fs.readFileSync(path.join(RAIZ, "entrega", "bi_oc_sankhya.jsp"))).digest("hex");
  assert.equal(a, b);
  const man = JSON.parse(fs.readFileSync(path.join(RAIZ, "entrega", "MANIFESTO.json"), "utf8"));
  assert.equal(man.sha256, a);
});

test("JSP preserva diretivas, taglibs, snk:load e só as 3 expressões EL do Construtor", () => {
  const jsp = fs.readFileSync(path.join(RAIZ, "entrega", "bi_oc_sankhya.jsp"), "utf8");
  assert.ok(jsp.startsWith("<%@ page language=\"java\""));
  assert.ok(jsp.indexOf("isELIgnored=\"false\"") > 0);
  assert.ok(jsp.indexOf("<%@ taglib prefix=\"snk\" uri=\"/WEB-INF/tld/sankhyaUtil.tld\" %>") > 0);
  assert.ok(jsp.indexOf("<snk:load/>") > 0);
  assert.deepEqual((jsp.match(/\$\{[^}]*\}/g) || []).sort(), ["${CODEMP}", "${PERIODO.FIN}", "${PERIODO.INI}"]);
  assert.equal((jsp.match(/#\{/g) || []).length, 0);
  assert.equal((jsp.match(/<%/g) || []).length, 3, "só as 3 diretivas");
});

test("sem dependência externa: nenhum script/link/URL de rede no artefato", () => {
  const jsp = fs.readFileSync(path.join(RAIZ, "entrega", "bi_oc_sankhya.jsp"), "utf8");
  assert.equal(/<script[^>]+src=/i.test(jsp), false);
  assert.equal(/<link[^>]+href=/i.test(jsp), false);
  const urls = (jsp.match(/https?:\/\/[^\s"')]+/g) || []).filter((u) => u !== "http://java.sun.com/jstl/core_rt");
  assert.deepEqual(urls, [], "só a URI identificadora da taglib JSTL é permitida");
});

test("todas as consultas: somente SELECT, binds conferidos, portáveis (Oracle 11g+)", () => {
  for (const id of Object.keys(consultas)) {
    const q = consultas[id];
    assert.match(q.sql, /^(WITH|SELECT)\b/, id);
    assert.equal(q.params.length, q.tipos.length, id);
    assert.equal((q.sql.replace(/'[^']*'/g, "").match(/\?/g) || []).length, q.params.length, id);
    assert.equal(/\b(INSERT|UPDATE|DELETE|MERGE|CREATE|ALTER|DROP|TRUNCATE|GRANT|EXECUTE|BEGIN|COMMIT)\b/i.test(q.sql.replace(/'[^']*'/g, "")), false, id);
  }
});

test("validador do build recusa escrita, ';', FETCH FIRST, bind sem parâmetro, alias de tabela com AS e '?' em literal", () => {
  const casos = [
    ["SELECT 1 FROM DUAL; DELETE FROM TGFCAB", 0], ["UPDATE TGFPRO SET ATIVO = 'N'", 0], ["SELECT * FROM TGFPRO FETCH FIRST 10 ROWS ONLY", 0],
    ["SELECT ? AS A FROM DUAL", 0], ["SELECT P.CODPROD FROM TGFPRO AS P", 0], ["SELECT '?' AS X FROM DUAL", 0],
    ["SELECT 1 AS IDENTIFICADOR_COM_MAIS_DE_TRINTA_CARACTERES FROM DUAL", 0], ["SELECT (1 AS X FROM DUAL", 0],
    ["SELECT 1 FROM DUAL WHERE ROWNUM <= 1", 0], ["SELECT 1 FROM TGFPRO@LINK", 0]
  ];
  for (const c of casos) assert.throws(() => build.validarSql("t", c[0], c[1]), /reprovada/, c[0]);
  assert.doesNotThrow(() => build.validarSql("t", "WITH x AS (SELECT ? AS A FROM DUAL) SELECT X.A FROM x X", 1));
});

test("uma única fonte por regra: fragmentos e macros compartilhados, sem bloco de 166 KB", () => {
  const plano = consultas.Q_PLANO.formatada, resumo = consultas.Q_RESUMO.formatada;
  const nucleo = fs.readFileSync(path.join(RAIZ, "sql", "fragmentos", "plano.sql"), "utf8").replace(/\{\{[^}]+\}\}/g, "").slice(0, 400);
  assert.ok(plano.indexOf("chaves AS (") > 0 && resumo.indexOf("chaves AS (") > 0);
  assert.ok(nucleo.length > 100);
  const total = Object.keys(consultas).reduce((s, id) => s + consultas[id].sql.length, 0);
  assert.ok(total < 166000, "SQL total " + total + " caracteres");
});

test("contrato interface × consultas: todo campo lido na tela existe na saída do cálculo", () => {
  const app = fs.readFileSync(path.join(RAIZ, "src", "app.js"), "utf8");
  const usados = new Set();
  app.replace(/\b(?:r|r0|x|xp|p\.r)\.([A-Z][A-Z0-9_]+)\b/g, (t, c) => { usados.add(c); return t; });
  (app.match(/var COLS_[A-Z_]+ = \[[\s\S]*?\];/g) || []).forEach((bloco) => {
    bloco.replace(/\["([A-Z][A-Z0-9_]+)", "/g, (t, c) => { usados.add(c); return t; });
  });
  assert.ok(usados.size > 60, "extração dos campos usados pela tela: " + usados.size);
  const banco = Demo.gerar(A.SYSDATE, true);
  const Q = S.consultas();
  const saida = new Set();
  ["Q_PLANO", "Q_RESUMO", "Q_CONSUMO", "Q_CARTEIRA", "Q_OC_LISTA", "Q_DIAG", "Q_SNAP_PROBE", "Q_PARAMS"].forEach((id) => {
    const b = A.binds(Q[id], A.valoresPadrao({ FILTRO_FILA: "TODOS", FILTRO_OC: "TODAS" }));
    Motor.executar(id, A.porNome(Q[id], b), banco, { config: A.CONFIG, sysdate: A.SYSDATE }).forEach((l) => Object.keys(l).forEach((k) => saida.add(k)));
  });
  const internos = new Set(["MOTIVO", "QUAL"]);
  const faltando = [...usados].filter((c) => !saida.has(c) && !internos.has(c));
  assert.deepEqual(faltando, []);
});

test("validação estática sqlglot (dialeto Oracle): sintaxe e colunas contra o esquema demonstrado", { skip: (() => {
  const py = S.python();
  if (!py) return "Python com DuckDB indisponível";
  return spawnSync(py, ["-c", "import sqlglot"]).status === 0 ? false : "sqlglot indisponível";
})() }, () => {
  build.principal();
  const r = spawnSync(S.python(), [path.join(RAIZ, "tests", "sql", "validar_sqlglot.py"), path.join(RAIZ, "sql", "gerado", "consultas.json")], { encoding: "utf8" });
  assert.equal(r.status, 0, r.stderr);
  const res = JSON.parse(r.stdout);
  for (const id of Object.keys(res)) {
    assert.equal(res[id].parse, "ok", id + " parse: " + res[id].parse);
    assert.equal(res[id].colunas, "ok", id + " colunas: " + res[id].colunas);
  }
});
