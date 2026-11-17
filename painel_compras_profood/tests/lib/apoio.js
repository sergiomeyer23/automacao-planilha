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
function iguais(a, b, tol) {
  a = normalizar(a); b = normalizar(b);
  if (a === null || b === null) return a === b;
  if (typeof a === "number" || typeof b === "number") {
    const x = Number(a), y = Number(b);
    return Math.abs(x - y) <= (tol || 1e-6) * Math.max(1, Math.abs(x), Math.abs(y));
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
      if (!iguais(l[c], o[c], tol)) dif.push(k + "." + c + ": SQL=" + JSON.stringify(l[c]) + " JS=" + JSON.stringify(o[c]));
    }
  }
  return dif;
}
module.exports = { CONFIG, valoresPadrao, binds, porNome, comparar, iguais, RAIZ };
