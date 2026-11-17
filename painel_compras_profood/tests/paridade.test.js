/* 24. Paridade: o MESMO banco (sintético, ~2.200 notas) passa pelo SQL gerado (DuckDB) e pelo motor JS,
 * em várias combinações de parâmetros e filtros. Qualquer diferença de coluna, linha ou valor reprova.
 * Prova coerência entre SQL, motor e interface; NÃO prova execução no Oracle. */
"use strict";
const test = require("node:test");
const assert = require("node:assert/strict");
const A = require("./lib/apoio.js");
const S = require("./lib/sql_runner.js");
const Motor = require("../src/motor.js");
const Demo = require("../src/demo.js");

const CHAVES = {
  Q_PLANO: (l) => l.CODEMP + "/" + l.CODPROD, Q_RESUMO: (l) => l.PRIORIDADE, Q_CONSUMO: (l) => l.CODEMP + "/" + l.CODPROD + "/" + l.IDX_MES,
  Q_CARTEIRA: (l) => l.BLOCO + "/" + l.CHAVE + "/" + l.CHAVE2, Q_OC_LISTA: (l) => l.NUNOTA + "/" + l.SEQUENCIA,
  Q_PARAMS: (l) => l.CHAVE, Q_SNAP_PROBE: () => "1", Q_DIAG: () => "1"
};
const CENARIOS = [
  { nome: "padrões", v: {} },
  { nome: "ponderada + mês parcial + histórico mínimo 6", v: { MEDIA_MODO: 1, MES_PARCIAL: 1, MIN_MESES_HIST: 6 } },
  { nome: "SOMA + RESERVADO + desconta bloqueado", v: { REGRA_PREVISAO_FIRME: 2, FONTE_COMPROMISSO: 2, DESCONTA_BLOQUEADO: 1 } },
  { nome: "ABC + lote/múltiplo + segurança por ESTMIN", v: { ABC_CALCULADA: 1, LOTE_MULTIPLO: 1, POLITICA_SEGURANCA: 2 } },
  { nome: "sem segurança, janela 6 meses, empresa 1", v: { POLITICA_SEGURANCA: 0, MESES_MEDIA: 6, CODEMP: 1 } },
  { nome: "empresa inexistente (vazio)", v: { CODEMP: 77 } },
  { nome: "dias úteis e margens diferentes", v: { DIAS_MES: 21.75, MARGEM_ATENCAO_DIAS: 0, COBERTURA_MAX_DIAS: 45, LEADTIME_DEFAULT: 60, SEGURANCA_PCT_LT: 0.35 } }
];
const FILTROS = [{ FILTRO_FILA: "ATENCAO" }, { FILTRO_FILA: "EXCESSO" }, { FILTRO_FILA: "REVISAR" }, { FILTRO_FILA: "TODOS", LIMITE_FILA: 7 },
  { FILTRO_OC: "ATRASADAS" }, { FILTRO_OC: "SEM_PREVISAO" }, { FILTRO_OC: "NAO_CONFIRMADAS" }, { FILTRO_OC: "ANTIGAS" }, { FILTRO_OC: "TODAS", LIMITE_OC: 5 },
  { CODPROD_FILTRO: 9007, FILTRO_OC: "TODAS", TOPN_CONSUMO: 50 }, { TOPN_CONSUMO: 3 }];

test("24. paridade SQL gerado × motor JS em todas as consultas", { skip: S.python() ? false : "DuckDB indisponível" }, () => {
  const banco = Demo.gerar(A.SYSDATE, true);
  const Q = S.consultas();
  const casos = [];
  CENARIOS.forEach((c) => {
    Object.keys(CHAVES).forEach((id) => casos.push({ cen: c.nome, id, v: Object.assign({}, c.v) }));
    FILTROS.forEach((f) => ["Q_PLANO", "Q_OC_LISTA", "Q_CONSUMO"].forEach((id) => casos.push({ cen: c.nome + " " + JSON.stringify(f), id, v: Object.assign({}, c.v, f) })));
  });
  const entradas = casos.map((c) => ({ id: c.id, params: A.binds(Q[c.id], A.valoresPadrao(c.v)), sysdate: A.SYSDATE }));
  const res = S.rodar(banco, entradas, Q);
  let comparados = 0, linhas = 0;
  casos.forEach((c, i) => {
    const r = res[i];
    let js = null, erroJs = null;
    try { js = Motor.executar(c.id, A.porNome(Q[c.id], entradas[i].params), banco, { config: A.CONFIG, sysdate: A.SYSDATE }); } catch (e) { erroJs = e.message; }
    if (!r.ok) { assert.ok(erroJs && /ORA-\d{5}/.test(erroJs) && erroJs.slice(0, 9) === r.erro.slice(0, 9), c.id + " [" + c.cen + "]: SQL " + r.erro + " | JS " + erroJs); return; }
    assert.equal(erroJs, null, c.id + " [" + c.cen + "] motor falhou: " + erroJs);
    const dif = A.comparar(r.linhas, js, CHAVES[c.id], 1e-6);
    assert.deepEqual(dif.slice(0, 10), [], c.id + " [" + c.cen + "]");
    comparados++; linhas += r.linhas.length;
  });
  assert.ok(comparados > 150 && linhas > 5000, "cobertura mínima de comparação: " + comparados + " consultas, " + linhas + " linhas");
  console.log("# paridade: " + comparados + " execuções comparadas, " + linhas + " linhas, 0 divergências; " + A.fronteiras.length +
    " diferença(s) de 1 unidade na última casa (fronteira DOUBLE x NUMBER): " + A.fronteiras.slice(0, 5).join(" | "));
});
