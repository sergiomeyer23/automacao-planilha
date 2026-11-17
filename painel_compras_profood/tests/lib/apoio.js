/* Utilidades de teste: parâmetros padrão, binds e comparação tolerante de linhas. */
"use strict";
const path = require("path");
const Calc = require("../../src/calc.js");
const RAIZ = path.resolve(__dirname, "..", "..");
const painel = require(path.join(RAIZ, "config", "painel.json"));
const parametros = require(path.join(RAIZ, "config", "parametros.json"));

const CONFIG = {
  versao: painel.versao, papeisTop: painel.papeisTop, topsPrecoSeparado: painel.topsPrecoSeparado.tops,
  locaisExcluidos: painel.locaisExcluidos.locais, limites: painel.limites, codigoAntigoHabilitado: painel.codigoAntigo.habilitado,
  parametros: parametros.parametros, especiais: parametros.especiais, chavesLegadas: parametros.chavesLegadas
};

function valoresPadrao(extra) {
  const v = { CODEMP: 0, DT_INI: "2026-08-01", DT_FIM: "2026-11-17", LIMITE_FILA: 1000, LIMITE_OC: 300, TOPN_CONSUMO: 100,
    CODPROD_FILTRO: 0, FILTRO_FILA: "TODOS", FILTRO_OC: "TODAS", DIAG_NUM: 123 };
  for (const p of parametros.parametros) v[p.chave] = p.padrao;
  return Object.assign(v, extra || {});
}
/* valores lógicos -> binds {value,type} pela mesma rotina do navegador */
function binds(q, valores) {
  const escalados = {};
  const defs = {};
  for (const p of parametros.parametros) defs[p.chave] = p;
  for (const k of Object.keys(valores)) {
    const d = defs[k];
    escalados[k] = d && d.escala ? Math.round(valores[k] * d.escala) : valores[k];
  }
  return Calc.montarParams(q, escalados, parametros.especiais);
}
function porNome(q, bindsLista) {
  const o = {};
  q.params.forEach((n, i) => { o[n] = bindsLista[i].value; });
  return o;
}
function normalizar(v) {
  if (v === "" || v === undefined) return null;
  if (typeof v === "string" && /^\d{4}-\d{2}-\d{2}T00:00:00$/.test(v)) return v.slice(0, 10);
  return v;
}
/* Fronteira de arredondamento: o DuckDB calcula em DOUBLE e o Oracle em NUMBER decimal; um valor como
   x,xx5 pode arredondar para lados diferentes. Aceita-se no máximo 1 unidade na última casa exibida,
   e cada ocorrência é contada em `fronteiras` para aparecer no relatório. */
const fronteiras = [];
function casas(v) { const m = /\.(\d+)$/.exec(String(v)); return m ? m[1].length : 0; }
function iguais(a, b, tol, rotulo) {
  a = normalizar(a); b = normalizar(b);
  if (a === null || b === null) return a === b;
  if (typeof a === "number" || typeof b === "number") {
    const x = Number(a), y = Number(b), d = Math.abs(x - y);
    if (d <= (tol || 1e-6) * Math.max(1, Math.abs(x), Math.abs(y))) return true;
    const passo = Math.pow(10, -Math.max(casas(a), casas(b)));
    if (passo < 1 && d <= passo * 1.000001) { fronteiras.push((rotulo || "") + " " + a + " x " + b); return true; }
    return false;
  }
  return String(a) === String(b);
}
/* Compara listas de linhas; devolve lista de divergências legíveis (vazia = iguais). */
function comparar(sql, js, chaveFn, tol) {
  const dif = [];
  if (sql.length !== js.length) dif.push("quantidade de linhas: SQL " + sql.length + " x JS " + js.length);
  const mapa = {};
  js.forEach((l) => { mapa[chaveFn(l)] = l; });
  for (const l of sql) {
    const k = chaveFn(l), o = mapa[k];
    if (!o) { dif.push("linha só no SQL: " + k); continue; }
    const cols = new Set(Object.keys(l).concat(Object.keys(o)));
    for (const c of cols) {
      if (!(c in l)) { dif.push(k + "." + c + " só no JS"); continue; }
      if (!(c in o)) { dif.push(k + "." + c + " só no SQL"); continue; }
      if (!iguais(l[c], o[c], tol, k + "." + c)) dif.push(k + "." + c + ": SQL=" + JSON.stringify(l[c]) + " JS=" + JSON.stringify(o[c]));
    }
  }
  return dif;
}
module.exports = { CONFIG, valoresPadrao, binds, porNome, comparar, iguais, fronteiras, RAIZ };

/* Executa a mesma consulta no motor JS e no SQL gerado (DuckDB, se disponível). */
const Motor = require("../../src/motor.js");
const S = require("./sql_runner.js");
const SYSDATE = "2026-11-17 10:30:00";
function configCom(ajuste) {
  const c = JSON.parse(JSON.stringify(CONFIG));
  if (ajuste) ajuste(c);
  return c;
}
function rodarAmbos(banco, id, valores, opcoes) {
  opcoes = opcoes || {};
  const config = opcoes.config || CONFIG;
  const Q = S.consultas(opcoes.ajustePainel, opcoes.nomeConfig);
  const b = binds(Q[id], valoresPadrao(valores));
  let js, erroJs = null;
  try { js = Motor.executar(id, porNome(Q[id], b), banco, { config, sysdate: opcoes.sysdate || SYSDATE }); } catch (e) { erroJs = e.message; }
  let sql = null, erroSql = null, disponivel = false;
  const r = S.rodar(banco, [{ id, params: b, sysdate: opcoes.sysdate || SYSDATE }], Q);
  if (r) { disponivel = true; if (r[0].ok) sql = r[0].linhas; else erroSql = r[0].erro; }
  return { js, erroJs, sql, erroSql, sqlDisponivel: disponivel };
}
module.exports.configCom = configCom;
module.exports.rodarAmbos = rodarAmbos;
module.exports.SYSDATE = SYSDATE;
