#!/usr/bin/env node
/* Build determinístico do painel.
 *   node scripts/build.js            -> gera entrega/bi_oc_sankhya.jsp, sql/gerado/*.sql, entrega/MANIFESTO.json
 *   node scripts/build.js --verificar -> só valida (não grava)
 * Sem dependências externas, sem rede, sem data/hora no artefato (o identificador é um hash das fontes).
 */
"use strict";
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

const RAIZ = path.resolve(__dirname, "..");
const SO_VERIFICAR = process.argv.includes("--verificar");

function ler(rel) { return fs.readFileSync(path.join(RAIZ, rel), "utf8").replace(/\r\n/g, "\n"); }
function erro(msg) { const e = new Error(msg); e.build = true; throw e; }

/* ------------------------------------------------------------------ config */
function carregarConfig() {
  const painel = JSON.parse(ler("config/painel.json"));
  const parametros = JSON.parse(ler("config/parametros.json"));
  const vistos = {};
  for (const papel of Object.keys(painel.papeisTop)) {
    for (const t of painel.papeisTop[papel].tops) {
      if (!Number.isInteger(t) || t <= 0) erro("TOP inválida em " + papel + ": " + t);
      if (vistos[t]) erro("TOP " + t + " aparece em dois papéis: " + vistos[t] + " e " + papel);
      vistos[t] = papel;
    }
  }
  for (const t of painel.topsPrecoSeparado.tops) {
    if (painel.papeisTop.ORDEM_COMPRA.tops.indexOf(t) < 0) erro("TOP de preço separado " + t + " não está em ORDEM_COMPRA");
  }
  for (const l of painel.locaisExcluidos.locais) if (!Number.isInteger(l)) erro("Local inválido: " + l);
  if (painel.codigoAntigo.habilitado && !/^AD_[A-Z0-9_]{1,27}$/.test(painel.codigoAntigo.coluna)) {
    erro("Coluna de código antigo inválida: " + painel.codigoAntigo.coluna);
  }
  const defs = {};
  for (const p of parametros.parametros) {
    if (!/^[A-Z][A-Z0-9_]{0,29}$/.test(p.chave)) erro("Chave de parâmetro inválida: " + p.chave);
    if (p.padrao < p.min || p.padrao > p.max) erro("Padrão fora da faixa: " + p.chave);
    defs[p.chave] = Object.assign({ tipo: "I" }, p);
  }
  for (const e of parametros.especiais) defs[e.chave] = Object.assign({ especial: true }, e);
  return { painel, parametros, defs };
}

/* ------------------------------------------------------------------ macros */
function carregarMacros() {
  const txt = ler("sql/macros.sql");
  const macros = {};
  const re = /--#macro\s+([A-Z_]+)\(([^)]*)\)\n([\s\S]*?)--#fim/g;
  let m;
  while ((m = re.exec(txt))) {
    const args = m[2].split(",").map((s) => s.trim()).filter(Boolean);
    const corpo = m[3].split("\n").filter((l) => !/^\s*--/.test(l)).join("\n").trim();
    macros[m[1]] = { args, corpo };
  }
  return macros;
}

function dividirArgs(s) {
  const out = []; let nivel = 0, atual = "", aspas = false;
  for (const c of s) {
    if (c === "'") aspas = !aspas;
    if (!aspas && c === "(") nivel++;
    if (!aspas && c === ")") nivel--;
    if (!aspas && nivel === 0 && c === ",") { out.push(atual.trim()); atual = ""; continue; }
    atual += c;
  }
  if (atual.trim()) out.push(atual.trim());
  return out;
}

function expandir(sql, ctx) {
  let anterior, voltas = 0;
  do {
    anterior = sql;
    sql = sql.replace(/\{\{([A-Z_]+)(?:\s+([^{}]*?))?\}\}/g, function (todo, nome, argsTxt) {
      if (nome === "PRM" || nome === "TOPS" || nome === "FRAGMENTOS") return todo;
      if (nome === "COTACAO_MAPEADA") return String(ctx.cotacaoMapeada);
      if (nome === "COL_COD_ANTIGO") return ctx.colCodAntigo;
      if (nome === "EXCLUI_LOCAIS") {
        const col = (argsTxt || "").trim();
        if (!/^[A-Z]+\.[A-Z_]+$/.test(col)) erro("EXCLUI_LOCAIS precisa de coluna qualificada");
        return ctx.locais.length ? "AND " + col + " NOT IN (" + ctx.locais.join(", ") + ")" : "";
      }
      const mac = ctx.macros[nome];
      if (!mac) erro("Macro/placeholder desconhecido: " + nome);
      const args = argsTxt ? dividirArgs(argsTxt) : [];
      if (args.length !== mac.args.length) erro("Macro " + nome + " espera " + mac.args.length + " argumentos, recebeu " + args.length + ": " + argsTxt);
      let corpo = mac.corpo;
      mac.args.forEach(function (a, i) {
        corpo = corpo.replace(new RegExp("\\" + a + "\\b", "g"), function () { return args[i]; });
      });
      return corpo;
    });
    if (++voltas > 20) erro("Expansão de macros não converge");
  } while (sql !== anterior);
  return sql;
}

/* ------------------------------------------------------------------ prm / tops */
function expandirParams(lista, conf) {
  const out = [];
  for (const item of lista) {
    if (conf.parametros.grupos[item]) {
      for (const p of conf.parametros.grupos[item]) if (out.indexOf(p) < 0) out.push(p);
    } else if (out.indexOf(item) < 0) out.push(item);
  }
  for (const p of out) if (!conf.defs[p]) erro("Parâmetro sem definição: " + p);
  return out;
}

function gerarPrm(nomes, conf) {
  if (!nomes.length) return { texto: "", tipos: [] };
  const linhas = [], tipos = [];
  for (const n of nomes) {
    const d = conf.defs[n];
    if (d.tipo === "D") { linhas.push("TO_DATE(?, 'YYYY-MM-DD') AS " + n); tipos.push("S"); }
    else if (d.tipo === "C") { linhas.push("CAST(? AS VARCHAR(30)) AS " + n); tipos.push("S"); }
    else if (d.escala) { linhas.push("TO_NUMBER(?) / " + d.escala + " AS " + n); tipos.push("I"); }
    else { linhas.push("CAST(TO_NUMBER(?) AS INTEGER) AS " + n); tipos.push("I"); }
  }
  return {
    texto: "prm AS (\n    SELECT " + linhas.join(",\n           ") + "\n    FROM DUAL\n)",
    tipos
  };
}

function gerarTops(conf) {
  const p = conf.painel, partes = [];
  for (const papel of Object.keys(p.papeisTop)) {
    for (const t of p.papeisTop[papel].tops) {
      const grupo = papel !== "ORDEM_COMPRA" ? "NA" : (p.topsPrecoSeparado.tops.indexOf(t) >= 0 ? "SEPARADO" : "PRINCIPAL");
      partes.push("SELECT " + t + " AS CODTIPOPER, '" + papel + "' AS PAPEL, '" + grupo + "' AS GRUPO_PRECO FROM DUAL");
    }
  }
  if (!partes.length) {
    return "tops AS (\n    SELECT CAST(NULL AS INTEGER) AS CODTIPOPER, CAST(NULL AS VARCHAR(20)) AS PAPEL, CAST(NULL AS VARCHAR(20)) AS GRUPO_PRECO FROM DUAL WHERE 1 = 0\n)";
  }
  return "-- Papéis das TOPs gerados de config/painel.json (não validados)\ntops AS (\n    " + partes.join("\n    UNION ALL ") + "\n)";
}

/* ------------------------------------------------------------------ limpeza e validação */
function semComentarios(sql) {
  let out = "", aspas = false;
  for (let i = 0; i < sql.length; i++) {
    const c = sql[i];
    if (c === "'") aspas = !aspas;
    if (!aspas && c === "-" && sql[i + 1] === "-") { while (i < sql.length && sql[i] !== "\n") i++; out += "\n"; continue; }
    out += c;
  }
  return out;
}
function semLiterais(sql) { return sql.replace(/'[^']*'/g, "''"); }
function compactar(sql) {
  return semComentarios(sql).split("\n").map((l) => l.trim()).filter(Boolean).join(" ").replace(/\s+/g, " ").trim();
}

const PROIBIDAS = ["INSERT", "UPDATE", "DELETE", "MERGE", "CREATE", "ALTER", "DROP", "TRUNCATE", "GRANT", "REVOKE",
  "EXECUTE", "EXEC", "BEGIN", "DECLARE", "CALL", "COMMIT", "ROLLBACK", "SAVEPOINT", "LOCK", "RENAME", "PURGE", "FLASHBACK"];
const CONSTRUCOES = [
  [/\bFETCH\s+FIRST\b/, "FETCH FIRST (exige Oracle 12c; use ROW_NUMBER)"],
  [/\bROWNUM\b/, "ROWNUM (use ROW_NUMBER, portável e testável)"],
  [/\bCONNECT\s+BY\b/, "CONNECT BY"],
  [/\bKEEP\s*\(/, "KEEP (DENSE_RANK ...)"],
  [/\bDBMS_|\bUTL_/, "pacotes DBMS_/UTL_"],
  [/@/, "database link (@)"],
  [/\bINTO\b/, "INTO"],
  [/\b(FROM|JOIN)\s+[A-Z0-9_]+\s+AS\s+[A-Z]/, "alias de tabela com AS (inválido no Oracle)"]
];

function validarSql(id, sql, nParams) {
  const limpo = semLiterais(semComentarios(sql)).toUpperCase();
  const problemas = [];
  if (!/^\s*(WITH|SELECT)\b/.test(limpo)) problemas.push("não começa com WITH/SELECT");
  if (limpo.indexOf(";") >= 0) problemas.push("contém ';'");
  for (const k of PROIBIDAS) if (new RegExp("\\b" + k + "\\b").test(limpo)) problemas.push("palavra proibida: " + k);
  for (const c of CONSTRUCOES) if (c[0].test(limpo)) problemas.push("construção não permitida: " + c[1]);
  const binds = (limpo.match(/\?/g) || []).length;
  if (binds !== nParams) problemas.push("binds (" + binds + ") diferente de parâmetros declarados (" + nParams + ")");
  if (/\{\{|--#|\$[A-Z]/.test(limpo)) problemas.push("placeholder/macro não resolvido");
  let nivel = 0;
  for (const c of limpo) { if (c === "(") nivel++; if (c === ")") nivel--; if (nivel < 0) break; }
  if (nivel !== 0) problemas.push("parênteses desbalanceados");
  const ids = [];
  limpo.replace(/\bAS\s+([A-Z_][A-Z0-9_$#]*)/g, function (t, n) { ids.push(n); return t; });
  limpo.replace(/(?:WITH|,)\s*([A-Z_][A-Z0-9_]*)\s+AS\s*\(/g, function (t, n) { ids.push(n); return t; });
  for (const n of ids) if (n.length > 30) problemas.push("identificador com mais de 30 caracteres: " + n);
  if ((sql.match(/'/g) || []).length % 2) problemas.push("aspas simples desbalanceadas");
  if ((semComentarios(sql).match(/'[^']*'/g) || []).some((lit) => lit.indexOf("?") >= 0)) problemas.push("'?' dentro de literal (confunde contagem de binds)");
  if (problemas.length) erro("Consulta " + id + " reprovada na validação:\n  - " + problemas.join("\n  - "));
}

/* ------------------------------------------------------------------ consultas */
function montarConsultas(conf, macros) {
  const dir = path.join(RAIZ, "sql", "consultas");
  const ctx = {
    macros,
    cotacaoMapeada: conf.painel.papeisTop.COTACAO.tops.length ? 1 : 0,
    colCodAntigo: conf.painel.codigoAntigo.habilitado ? "CAST(P." + conf.painel.codigoAntigo.coluna + " AS VARCHAR(60))" : "CAST(NULL AS VARCHAR(60))",
    locais: conf.painel.locaisExcluidos.locais
  };
  const tops = gerarTops(conf);
  const consultas = {};
  for (const arq of fs.readdirSync(dir).filter((f) => f.endsWith(".sql")).sort()) {
    const txt = ler("sql/consultas/" + arq);
    const id = (txt.match(/^-- @consulta\s+(\S+)/m) || [])[1];
    if (!id || id + ".sql" !== arq) erro("Cabeçalho @consulta ausente ou diferente do nome do arquivo: " + arq);
    const descricao = ((txt.match(/^-- @descricao\s+([\s\S]*?)\n-- @params/m) || [])[1] || "").replace(/\n--\s*/g, " ").trim();
    const paramsLinha = (txt.match(/^-- @params[ \t]*(.*)$/m) || [])[1];
    if (paramsLinha === undefined) erro("Cabeçalho @params ausente: " + arq);
    const nomes = expandirParams(paramsLinha.trim() ? paramsLinha.trim().split(/\s+/) : [], conf);
    const prm = gerarPrm(nomes, conf);
    let corpo = txt.split("\n").filter((l) => !/^-- @/.test(l) && !/^--\s{2,}\S/.test(l) || false).join("\n");
    corpo = corpo.replace("{{PRM}}", prm.texto).replace("{{TOPS}}", tops);
    corpo = corpo.replace(/\{\{FRAGMENTOS\s+([^}]+)\}\}/g, function (t, lista) {
      return lista.trim().split(/\s+/).map(function (f) {
        const p = "sql/fragmentos/" + f + ".sql";
        if (!fs.existsSync(path.join(RAIZ, p))) erro("Fragmento inexistente: " + f);
        return ler(p).trim();
      }).join(",\n");
    });
    corpo = expandir(corpo, ctx).trim();
    validarSql(id, corpo, nomes.length);
    const compacto = compactar(corpo);
    validarSql(id + " (compactada)", compacto, nomes.length);
    consultas[id] = { id, descricao, params: nomes, tipos: prm.tipos, formatada: corpo, sql: compacto };
  }
  return consultas;
}

/* ------------------------------------------------------------------ bundle */
function montarBundle(conf, consultas, hash) {
  const Q = {};
  for (const id of Object.keys(consultas).sort()) Q[id] = { sql: consultas[id].sql, params: consultas[id].params, tipos: consultas[id].tipos };
  const CONFIG = {
    versao: conf.painel.versao,
    titulo: conf.painel.titulo,
    papeisTop: conf.painel.papeisTop,
    topsPrecoSeparado: conf.painel.topsPrecoSeparado.tops,
    locaisExcluidos: conf.painel.locaisExcluidos.locais,
    limites: conf.painel.limites,
    timeoutSegundos: conf.painel.consultaTimeoutSegundos,
    consultasSimultaneas: conf.painel.consultasSimultaneas,
    codigoAntigoHabilitado: conf.painel.codigoAntigo.habilitado,
    parametros: conf.parametros.parametros,
    especiais: conf.parametros.especiais,
    chavesLegadas: conf.parametros.chavesLegadas
  };
  const BUILD = { versao: conf.painel.versao, hash };
  const partes = ["calc.js", "motor.js", "demo.js", "app.js"].map((f) => "/* ===== src/" + f + " ===== */\n" + ler("src/" + f));
  return "(function () {\n\"use strict\";\nvar BUILD = " + JSON.stringify(BUILD) + ";\nvar CONFIG = " + JSON.stringify(CONFIG) +
    ";\nvar Q = " + JSON.stringify(Q) + ";\n" + partes.join("\n") + "\n})();";
}

function validarParaJsp(nome, texto) {
  const p = [];
  if (texto.indexOf("${") >= 0) p.push("contém '${' (seria interpretado pela EL do JSP)");
  if (texto.indexOf("#{") >= 0) p.push("contém '#{' (EL diferida do JSP)");
  if (texto.indexOf("<%") >= 0 || texto.indexOf("%>") >= 0) p.push("contém delimitador de scriptlet JSP");
  if (/<\/script/i.test(texto)) p.push("contém '</script'");
  if (p.length) erro(nome + ": " + p.join("; "));
}

function validarES5(nome, js) {
  const semStr = js.replace(/"(?:[^"\\\n]|\\.)*"/g, "\"\"").replace(/'(?:[^'\\\n]|\\.)*'/g, "''").replace(/\/\*[\s\S]*?\*\//g, "").replace(/\/\/[^\n]*/g, "");
  const p = [];
  if (/=>/.test(semStr)) p.push("arrow function");
  if (/`/.test(semStr)) p.push("template string");
  if (/\b(let|const|class)\s+[A-Za-z_$]/.test(semStr)) p.push("let/const/class");
  if (/\.\.\.[A-Za-z_$[]/.test(semStr)) p.push("spread/rest");
  if (p.length) erro(nome + " usa sintaxe fora de ES5: " + p.join(", "));
}

/* ------------------------------------------------------------------ principal */
function hashFontes() {
  const h = crypto.createHash("sha256");
  const arquivos = [];
  for (const d of ["config", "sql/consultas", "sql/fragmentos", "src"]) {
    for (const f of fs.readdirSync(path.join(RAIZ, d)).sort()) arquivos.push(d + "/" + f);
  }
  arquivos.push("sql/macros.sql", "scripts/build.js");
  for (const a of arquivos) { h.update(a + "\n"); h.update(ler(a)); }
  return h.digest("hex").slice(0, 16);
}

function principal() {
  const conf = carregarConfig();
  const macros = carregarMacros();
  const consultas = montarConsultas(conf, macros);
  for (const f of ["calc.js", "motor.js", "demo.js", "app.js"]) validarES5("src/" + f, ler("src/" + f));
  const hash = hashFontes();
  const css = ler("src/styles.css");
  const bundle = montarBundle(conf, consultas, hash);
  validarParaJsp("CSS", css);
  validarParaJsp("JavaScript", bundle);
  const tpl = ler("src/template.jsp");
  if (tpl.indexOf("/*@@CSS@@*/") < 0 || tpl.indexOf("/*@@JS@@*/") < 0) erro("template.jsp sem marcadores @@CSS@@/@@JS@@");
  const jsp = tpl.replace("/*@@CSS@@*/", function () { return css; })
                 .replace("/*@@JS@@*/", function () { return bundle; })
                 .replace(/@@VERSAO@@/g, conf.painel.versao)
                 .replace(/@@HASH@@/g, hash);
  const els = jsp.match(/\$\{[^}]*\}/g) || [];
  const permitidos = ["${PERIODO.INI}", "${PERIODO.FIN}", "${CODEMP}"];
  for (const e of els) if (permitidos.indexOf(e) < 0) erro("Expressão EL não prevista no JSP: " + e);
  const kb = Buffer.byteLength(jsp, "utf8") / 1024;
  const manifesto = {
    versao: conf.painel.versao, hash,
    arquivo: "entrega/bi_oc_sankhya.jsp",
    tamanhoKB: Math.round(kb * 10) / 10,
    avisoTamanho: kb > conf.painel.tamanhoMaximoAvisoKB ? "acima de " + conf.painel.tamanhoMaximoAvisoKB + " KB: confirmar limite do componente na homologação" : null,
    sha256: crypto.createHash("sha256").update(jsp).digest("hex"),
    consultas: Object.keys(consultas).sort().map((id) => ({
      id, parametros: consultas[id].params.length, caracteres: consultas[id].sql.length,
      sha256: crypto.createHash("sha256").update(consultas[id].sql).digest("hex").slice(0, 16)
    }))
  };
  if (SO_VERIFICAR) { console.log("Verificação OK (" + Object.keys(consultas).length + " consultas, " + manifesto.tamanhoKB + " KB)"); return manifesto; }
  fs.mkdirSync(path.join(RAIZ, "entrega"), { recursive: true });
  fs.mkdirSync(path.join(RAIZ, "sql", "gerado"), { recursive: true });
  for (const f of fs.readdirSync(path.join(RAIZ, "sql", "gerado"))) fs.unlinkSync(path.join(RAIZ, "sql", "gerado", f));
  for (const id of Object.keys(consultas).sort()) {
    const c = consultas[id];
    const cab = "-- GERADO por scripts/build.js (" + hash + "). NÃO EDITAR: altere sql/consultas, sql/fragmentos ou sql/macros.sql.\n" +
      "-- Consulta: " + id + "\n-- " + c.descricao + "\n-- Binds na ordem dos '?': " + (c.params.map((p, i) => p + ":" + c.tipos[i]).join(", ") || "nenhum") + "\n\n";
    fs.writeFileSync(path.join(RAIZ, "sql", "gerado", id + ".sql"), cab + c.formatada + "\n");
  }
  const qjson = {};
  for (const id of Object.keys(consultas).sort()) qjson[id] = { sql: consultas[id].sql, params: consultas[id].params, tipos: consultas[id].tipos };
  fs.writeFileSync(path.join(RAIZ, "sql", "gerado", "consultas.json"), JSON.stringify({ hash, consultas: qjson }, null, 1) + "\n");
  fs.writeFileSync(path.join(RAIZ, "entrega", "bi_oc_sankhya.jsp"), jsp);
  fs.writeFileSync(path.join(RAIZ, "entrega", "MANIFESTO.json"), JSON.stringify(manifesto, null, 2) + "\n");
  console.log("Build " + hash + " OK: entrega/bi_oc_sankhya.jsp (" + manifesto.tamanhoKB + " KB), " + Object.keys(consultas).length + " consultas");
  if (manifesto.avisoTamanho) console.log("AVISO: " + manifesto.avisoTamanho);
  return manifesto;
}

if (require.main === module) {
  try { principal(); } catch (e) { console.error(e.build ? "ERRO DE BUILD: " + e.message : e.stack); process.exit(1); }
}
module.exports = { principal, carregarConfig, carregarMacros, montarConsultas, validarSql, compactar, expandir, gerarPrm, gerarTops };
