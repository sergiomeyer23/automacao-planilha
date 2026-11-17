/* Gera tests/fixtures/e2e_banco.json: banco sintético do modo demo + textos maliciosos para testar
   escape de HTML e proteção de CSV. Determinístico (semente e data fixas). */
"use strict";
const fs = require("fs");
const path = require("path");
const Demo = require("../../src/demo.js");
const SYSDATE = "2026-11-17 10:30:00";
const t = Demo.gerar(SYSDATE, false);
const p = t.TGFPRO[0];
p.DESCRPROD = "<img src=x onerror=\"window.__xss=1\">PRODUTO \"ASPAS\" ; =SOMA(1+1)";
t.TGFPAR[0].NOMEPARC = "=HYPERLINK(\"http://exemplo.invalido\",\"clique\") <script>window.__xss=2</script>";
t.TGFGRU[0].DESCRGRUPOPROD = "<b onmouseover=window.__xss=3>GRUPO</b>";
const destino = path.join(__dirname, "..", "fixtures", "e2e_banco.json");
fs.writeFileSync(destino, JSON.stringify({ sysdate: SYSDATE, periodo: { INI: "2026-08-19", FIN: "2026-11-17", CODEMP: "" }, tabelas: t }));
console.log("Fixture e2e: " + Object.keys(t).map((k) => k + "=" + t[k].length).join(" "));
