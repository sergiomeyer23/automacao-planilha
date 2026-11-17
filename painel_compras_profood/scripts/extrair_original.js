#!/usr/bin/env node
/* Extrai as consultas embutidas no painel original (linha "var Q = {...}") para
   original/consultas_extraidas/<ID>.sql, com cabeçalho de parâmetros. Somente leitura do original. */
"use strict";
const fs = require("fs");
const path = require("path");
const RAIZ = path.resolve(__dirname, "..");
const orig = fs.readFileSync(path.join(RAIZ, "original", "bi_oc_sankhya.jsp"), "utf8");
const linha = orig.split(/\r?\n/).find((l) => /^\s*var Q = \{/.test(l));
if (!linha) { console.error("Objeto Q não encontrado no original."); process.exit(1); }
const Q = JSON.parse(linha.replace(/^\s*var Q = /, "").replace(/;\s*$/, ""));
const dest = path.join(RAIZ, "original", "consultas_extraidas");
fs.mkdirSync(dest, { recursive: true });
const indice = [];
for (const id of Object.keys(Q)) {
  const q = Q[id];
  const cab = "-- Extraído do painel original (somente referência; NÃO é a fonte do painel novo)\n" +
    "-- Consulta: " + id + "\n-- Parâmetros (ordem dos ?): " + (q.params.join(", ") || "nenhum") +
    "\n-- Tipos: " + (q.tipos.join(", ") || "-") + "\n\n";
  fs.writeFileSync(path.join(dest, id + ".sql"), cab + q.sql + "\n");
  indice.push(id + "\t" + q.sql.length + " caracteres\t" + q.params.length + " parâmetros");
}
fs.writeFileSync(path.join(dest, "INDICE.txt"), indice.join("\n") + "\n");
console.log("Extraídas " + indice.length + " consultas para " + path.relative(RAIZ, dest));
