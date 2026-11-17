/* Ponte Node -> Python/DuckDB para executar o SQL gerado sobre fixtures. */
"use strict";
const path = require("path");
const fs = require("fs");
const { spawnSync } = require("child_process");
const build = require("../../scripts/build.js");

const RAIZ = path.resolve(__dirname, "..", "..");

function python() {
  const candidatos = [process.env.PAINEL_PYTHON, path.join(RAIZ, ".venv", "bin", "python"), "python3", "python"].filter(Boolean);
  for (const c of candidatos) {
    const r = spawnSync(c, ["-c", "import duckdb"], { encoding: "utf8" });
    if (r.status === 0) return c;
  }
  return null;
}

let cacheConsultas = null;
function consultas() {
  if (!cacheConsultas) {
    const conf = build.carregarConfig();
    const c = build.montarConsultas(conf, build.carregarMacros());
    cacheConsultas = {};
    for (const id of Object.keys(c)) cacheConsultas[id] = { sql: c[id].sql, params: c[id].params, tipos: c[id].tipos };
  }
  return cacheConsultas;
}

function rodar(tabelas, casos) {
  const py = python();
  if (!py) return null;
  const r = spawnSync(py, [path.join(RAIZ, "tests", "sql", "executar_sql.py")], {
    input: JSON.stringify({ consultas: consultas(), tabelas, casos }), encoding: "utf8", maxBuffer: 256 * 1024 * 1024
  });
  if (r.status !== 0) throw new Error("Falha ao executar SQL no DuckDB: " + r.stderr);
  return JSON.parse(r.stdout);
}

module.exports = { python, consultas, rodar, RAIZ };
