/* Testes unitários das funções puras (src/calc.js). Não dependem de banco. */
"use strict";
const test = require("node:test");
const assert = require("node:assert/strict");
const Calc = require("../src/calc.js");
const parametros = require("../config/parametros.json");

test("13. conversão: multiplica, divide, unidade padrão", () => {
  const g = Calc.agruparVoa([{ CODPROD: 1, CODVOL: "CX", DIVIDEMULTIPLICA: "M", QUANTIDADE: 12 }, { CODPROD: 1, CODVOL: "FD", DIVIDEMULTIPLICA: "D", QUANTIDADE: 4 }]);
  assert.deepEqual(Calc.conversao("CX", "UN", g["1|CX"]), { fator: 12, status: "MULTIPLICA" });
  assert.deepEqual(Calc.conversao("FD", "UN", g["1|FD"]), { fator: 0.25, status: "DIVIDE" });
  assert.deepEqual(Calc.conversao("UN", "UN", undefined), { fator: 1, status: "PADRAO" });
});

test("14. conversão ambígua, inexistente, inválida ou inativa não converte", () => {
  const g = Calc.agruparVoa([
    { CODPROD: 1, CODVOL: "PC", DIVIDEMULTIPLICA: "M", QUANTIDADE: 10 }, { CODPROD: 1, CODVOL: "PC", DIVIDEMULTIPLICA: "M", QUANTIDADE: 12 },
    { CODPROD: 1, CODVOL: "RL", DIVIDEMULTIPLICA: "X", QUANTIDADE: 5 }, { CODPROD: 1, CODVOL: "SC", DIVIDEMULTIPLICA: "M", QUANTIDADE: 5, ATIVO: "N" },
    { CODPROD: 1, CODVOL: "KG", DIVIDEMULTIPLICA: "M", QUANTIDADE: 0 },
    { CODPROD: 1, CODVOL: "DZ", DIVIDEMULTIPLICA: "M", QUANTIDADE: 12 }, { CODPROD: 1, CODVOL: "DZ", DIVIDEMULTIPLICA: "M", QUANTIDADE: 12 }]);
  assert.equal(Calc.conversao("PC", "UN", g["1|PC"]).status, "AMBIGUA");
  assert.equal(Calc.conversao("RL", "UN", g["1|RL"]).status, "REGRA_INVALIDA");
  assert.equal(Calc.conversao("SC", "UN", g["1|SC"]).status, "SEM_REGRA");
  assert.equal(Calc.conversao("KG", "UN", g["1|KG"]).status, "REGRA_INVALIDA");
  assert.equal(Calc.conversao(null, "UN", undefined).status, "SEM_UNIDADE");
  assert.equal(Calc.conversao("DZ", "UN", g["1|DZ"]).fator, 12, "regras repetidas idênticas não são ambíguas");
  ["PC", "RL", "SC", "KG"].forEach((u) => assert.equal(Calc.conversao(u, "UN", g["1|" + u]).fator, null));
});

test("6.5 pesos da média ponderada somam 1 e são renormalizados no histórico curto", () => {
  let s = 0;
  for (let a = 1; a <= 12; a++) s += Calc.pesoMes(a, 12);
  assert.ok(Math.abs(s - 1) < 1e-12);
  assert.ok(Math.abs(Calc.somaPesos(12, 12) - 1) < 1e-12);
  assert.ok(Math.abs(Calc.somaPesos(2, 12) - 2 * Calc.pesoMes(1, 12)) < 1e-12);
});

test("5. demanda zero: sem divisão por zero; falta só quando a oferta não cobre o compromisso", () => {
  assert.equal(Calc.tFalta(100, 0, 0, 1), null);
  assert.equal(Calc.tFalta(10, 20, 0, 1), 0);
  assert.equal(Calc.tFalta(-5, 0, 0, 2), 0);
  assert.equal(Calc.tFalta(50, 0, 10, 1), 5);
  assert.equal(Calc.tFalta(50, 20, 10, 2), 3, "SOMA desconta o compromisso antes");
  assert.equal(Calc.tFalta(50, 20, 10, 1), 5, "MAIOR: compromisso contido na previsão");
  assert.equal(Calc.dDemanda(200, 10, 51, 1), 510);
  assert.equal(Calc.dDemanda(200, 10, 51, 2), 710);
});

test("15. lote e múltiplo: atende os dois, nunca negativo, desligado não arredonda", () => {
  assert.deepEqual(Calc.arredondarLote(130, 200, 75, true), { qtd: 225, excesso: 95, invalido: false });
  assert.equal(Calc.arredondarLote(300, null, 100, true).qtd, 300, "300/100 sem erro de ponto flutuante");
  assert.equal(Calc.arredondarLote(0.7 * 3, null, 0.7, true).qtd.toFixed(6), "2.100000");
  assert.equal(Calc.arredondarLote(130, -5, null, true).invalido, true);
  assert.equal(Calc.arredondarLote(130, -5, null, true).qtd, 130);
  assert.equal(Calc.arredondarLote(0, 200, 75, true).qtd, null, "sem necessidade não compra lote");
  assert.equal(Calc.arredondarLote(-10, 200, 75, true).qtd, null);
  assert.equal(Calc.arredondarLote(130, 200, 75, false).qtd, null);
});

test("18. política PRG/JIT: sem classificador validado, nada é classificado; pedido misto por item", () => {
  const itemA = { NUNOTA: 1, SEQUENCIA: 1, SOLCOMPRA: "S", AD_ABASTECIMENTO: "JIT" }, itemB = { NUNOTA: 1, SEQUENCIA: 2, SOLCOMPRA: "N" };
  assert.equal(Calc.classificarPolitica(itemA, null), "NAO_VALIDADA");
  assert.equal(Calc.classificarPolitica(itemA, { validado: false, porItem: () => "PRG" }), "NAO_VALIDADA");
  const porItem = (i) => (i.SEQUENCIA === 1 ? "PRG" : i.SEQUENCIA === 2 ? "JIT" : null);
  assert.equal(Calc.classificarPolitica(itemA, { validado: true, porItem }), "PRG");
  assert.equal(Calc.classificarPolitica(itemB, { validado: true, porItem }), "JIT");
  assert.equal(Calc.classificarPolitica({ SEQUENCIA: 3 }, { validado: true, porItem }), "NAO_VALIDADA", "valor vazio não vira política");
});

test("19. classificação de erro: só ORA-00942 é objeto ausente; o resto não é mascarado", () => {
  assert.equal(Calc.classificarErro("ORA-00942: table or view does not exist").tipo, "OBJETO_AUSENTE");
  assert.equal(Calc.classificarErro("ORA-00904: \"X\": invalid identifier").tipo, "COLUNA_AUSENTE");
  assert.equal(Calc.classificarErro("ORA-01031: insufficient privileges").tipo, "PERMISSAO");
  assert.equal(Calc.classificarErro("Sem resposta em 180 s").tipo, "TEMPO");
  assert.equal(Calc.classificarErro("ORA-00600: internal error").tipo, "OUTRO");
});

test("20. respostas fora de ordem: só a geração mais recente de cada área renderiza", () => {
  const s = Calc.criarSequenciador();
  const t1 = s.novo("fila"), t2 = s.novo("fila"), c1 = s.novo("carteira");
  assert.equal(s.valido("fila", t1), false);
  assert.equal(s.valido("fila", t2), true);
  assert.equal(s.valido("carteira", c1), true);
  s.invalidarTudo();
  assert.equal(s.valido("fila", t2), false);
  assert.equal(s.valido("carteira", c1), false);
});

test("20b. fila de execução limita consultas simultâneas", () => {
  const f = Calc.criarFila(2), liberadores = [];
  let maxAtivos = 0;
  for (let i = 0; i < 5; i++) f.executar((fim) => { liberadores.push(fim); maxAtivos = Math.max(maxAtivos, f.ativos()); });
  assert.equal(f.ativos(), 2); assert.equal(f.pendentes(), 3);
  while (liberadores.length) liberadores.shift()();
  assert.equal(maxAtivos, 2); assert.equal(f.ativos(), 0); assert.equal(f.pendentes(), 0);
});

test("22. HTML: texto do banco é sempre escapado", () => {
  const mal = "<img src=x onerror=\"alert(1)\">'`&";
  assert.equal(Calc.esc(mal), "&lt;img src=x onerror=&quot;alert(1)&quot;&gt;&#39;&#96;&amp;");
  assert.equal(Calc.esc(null), "");
});

test("22b. CSV pt-BR: ';', vírgula decimal, BOM, aspas e proteção contra fórmula", () => {
  const csv = Calc.montarCSV([
    { A: "=HYPERLINK(\"http://x\")", B: 1234.5, C: "texto; com \"aspas\"\nquebra", D: "-10", E: -10, F: "+1", G: "@SOMA(A1)", H: null }
  ], [["A", "a"], ["B", "b", 2], ["C", "c"], ["D", "d"], ["E", "e", "auto"], ["F", "f"], ["G", "g"], ["H", "h", 2]]);
  assert.ok(csv.startsWith("﻿"));
  const linha = csv.split("\r\n")[1];
  assert.ok(linha.startsWith("\"'=HYPERLINK(\"\"http://x\"\")\";"), linha);
  assert.ok(linha.indexOf(";1234,50;") > 0);
  assert.ok(linha.indexOf("\"texto; com \"\"aspas\"\"\nquebra\"") > 0);
  assert.ok(linha.indexOf(";'-10;-10;'+1;'@SOMA(A1);") > 0, "texto com sinal é protegido, número negativo não: " + linha);
  assert.ok(linha.endsWith(";"), "nulo vira vazio");
});

test("23. parâmetros: contrato de binds, lista fechada e faixas", () => {
  const q = { params: ["CODEMP", "DT_INI", "FILTRO_FILA", "DIAS_MES"], tipos: ["I", "S", "S", "I"] };
  const esp = parametros.especiais;
  const ok = Calc.montarParams(q, { CODEMP: 1, DT_INI: "2026-01-31", FILTRO_FILA: "ATENCAO", DIAS_MES: 300000 }, esp);
  assert.deepEqual(ok.map((p) => p.type), ["I", "S", "S", "I"]);
  assert.throws(() => Calc.montarParams(q, { CODEMP: "1 OR 1=1", DT_INI: "2026-01-31", FILTRO_FILA: "ATENCAO", DIAS_MES: 1 }, esp), /inválido/);
  assert.throws(() => Calc.montarParams(q, { CODEMP: 1, DT_INI: "2026-02-31", FILTRO_FILA: "ATENCAO", DIAS_MES: 1 }, esp), /Data inválida/);
  assert.throws(() => Calc.montarParams(q, { CODEMP: 1, DT_INI: "2026-01-31", FILTRO_FILA: "ATENCAO' OR '1'='1", DIAS_MES: 1 }, esp), /lista permitida/);
  assert.throws(() => Calc.montarParams(q, { CODEMP: 1, DT_INI: "2026-01-31", FILTRO_FILA: "ATENCAO" }, esp), /sem valor/);
  const def = parametros.parametros.find((p) => p.chave === "SEGURANCA_PCT_LT");
  assert.equal(Calc.validarParametro(def, 0.2), true);
  assert.equal(Calc.validarParametro(def, 1.5), false);
  assert.equal(Calc.validarParametro(def, NaN), false);
  const mm = parametros.parametros.find((p) => p.chave === "MESES_MEDIA");
  assert.equal(Calc.validarParametro(mm, 6.5), false, "inteiro exigido");
  assert.deepEqual(Calc.validarCruzado({ MIN_MESES_HIST: 13, MESES_MEDIA: 12, ABC_LIMITE_A: 0.9, ABC_LIMITE_B: 0.8 }), ["MIN_MESES_HIST", "ABC_LIMITE_B"]);
  assert.equal(Calc.normData("31/02/2026"), null);
  assert.equal(Calc.normData("29/02/2028"), "2028-02-29");
});

test("contrato do retorno do executeQuery: formatos aceitos e recusados", () => {
  const json = "[{\"codprod\":1,\"QTD\":2}]";
  assert.deepEqual(Calc.lerRetorno(json), [{ CODPROD: 1, QTD: 2 }]);
  assert.deepEqual(Calc.lerRetorno(JSON.stringify(json)), [{ CODPROD: 1, QTD: 2 }], "JSON duplo");
  assert.deepEqual(Calc.lerRetorno({ c: { b: json }, b: null, toString: () => json }), [{ CODPROD: 1, QTD: 2 }], "envelope do Construtor");
  assert.deepEqual(Calc.lerRetorno({ rows: [[1, 2]], fields: [{ name: "A" }, "B"] }), [{ A: 1, B: 2 }]);
  assert.deepEqual(Calc.lerRetorno(""), []);
  assert.throws(() => Calc.lerRetorno("não é json"), /não reconhecido/);
  assert.throws(() => Calc.lerRetorno("[[1,2]]"), /sem nome de coluna/);
});

test("datas: ADD_MONTHS com a regra de último dia do Oracle", () => {
  const d = (s) => Calc.dia(s), i = (n) => Calc.diaISO(n);
  assert.equal(i(Calc.addMonths(d("2026-01-31"), 1)), "2026-02-28");
  assert.equal(i(Calc.addMonths(d("2026-02-28"), 1)), "2026-03-31");
  assert.equal(i(Calc.addMonths(d("2026-11-17"), -12)), "2025-11-17");
  assert.equal(i(Calc.addMonths(d("2026-11-01"), -24)), "2024-11-01");
  assert.equal(Calc.dia("2026-10-31 23:59:59"), Calc.dia("2026-10-31"));
});

test("formatação pt-BR", () => {
  assert.equal(Calc.fN(1234567.891, 2), "1.234.567,89");
  assert.equal(Calc.fN(-0.001, 2), "0,00");
  assert.equal(Calc.fQ(10), "10");
  assert.equal(Calc.fQ(10.5), "10,50");
  assert.equal(Calc.fR(null), "—");
  assert.equal(Calc.fData("2026-11-17"), "17/11/2026");
  assert.equal(Calc.arred(2.5, 0), 3);
  assert.equal(Calc.arred(-2.5, 0), -3);
});
