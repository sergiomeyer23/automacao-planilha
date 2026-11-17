/* Funções puras do painel: formatação, datas, unidades, regras de cálculo, CSV, leitura do retorno do
 * executeQuery, validação de parâmetros e controle de requisições. ES5 (sem bibliotecas).
 * Usado no navegador (dentro do bundle) e no Node (testes). Não acessa DOM. */
var Calc = (function () {
  "use strict";

  /* ---------------------------------------------------------------- básicos */
  function num(v) {
    if (v === null || v === undefined || v === "") return null;
    var n = typeof v === "number" ? v : Number(String(v).replace(/^\s+|\s+$/g, ""));
    return isNaN(n) || !isFinite(n) ? null : n;
  }
  /* ROUND do Oracle: meia unidade se afasta do zero. */
  function arred(x, casas) {
    if (x === null || x === undefined) return null;
    var f = Math.pow(10, casas || 0);
    var v = Math.abs(x) * f;
    var r = Math.floor(v + 0.5 + 1e-9);
    return (x < 0 ? -r : r) / f;
  }
  function esc(s) {
    return String(s === null || s === undefined ? "" : s).replace(/[&<>"'\x60]/g, function (c) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;", "'": "&#39;", "\x60": "&#96;" }[c];
    });
  }
  function pad2(n) { return (n < 10 ? "0" : "") + n; }

  /* ---------------------------------------------------------------- formatação pt-BR */
  function fN(v, d) {
    var n = num(v);
    if (n === null) return "—";
    d = d || 0;
    var s = Math.abs(n).toFixed(d).split(".");
    var inteiro = s[0].replace(/\B(?=(\d{3})+(?!\d))/g, ".");
    return (n < 0 && Number(n.toFixed(d)) !== 0 ? "-" : "") + inteiro + (d ? "," + s[1] : "");
  }
  function fQ(v) {
    var n = num(v);
    if (n === null) return "—";
    return fN(n, Math.abs(n - Math.round(n)) < 1e-9 ? 0 : 2);
  }
  function fR(v) { var n = num(v); return n === null ? "—" : "R$ " + fN(n, 2); }
  function fRc(v) {
    var n = num(v);
    if (n === null) return "—";
    var a = Math.abs(n);
    if (a >= 1e6) return "R$ " + fN(n / 1e6, 2) + " mi";
    if (a >= 1e4) return "R$ " + fN(n / 1e3, 1) + " mil";
    return "R$ " + fN(n, 0);
  }
  function fP(v, d) { var n = num(v); return n === null ? "—" : fN(n * 100, d === undefined ? 1 : d) + "%"; }
  function fData(iso) {
    if (!iso) return "—";
    var m = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(iso));
    return m ? m[3] + "/" + m[2] + "/" + m[1] : String(iso);
  }
  function fMes(iso) {
    var m = /^(\d{4})-(\d{2})/.exec(String(iso || ""));
    return m ? m[2] + "/" + m[1] : "—";
  }

  /* ---------------------------------------------------------------- datas (dias inteiros UTC) */
  function dia(v) {
    if (v === null || v === undefined || v === "") return null;
    var m = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(v));
    if (!m) return null;
    return Math.floor(Date.UTC(+m[1], +m[2] - 1, +m[3]) / 864e5);
  }
  function diaISO(d) {
    if (d === null || d === undefined) return null;
    var dt = new Date(d * 864e5);
    return dt.getUTCFullYear() + "-" + pad2(dt.getUTCMonth() + 1) + "-" + pad2(dt.getUTCDate());
  }
  function partes(d) { var dt = new Date(d * 864e5); return { a: dt.getUTCFullYear(), m: dt.getUTCMonth() + 1, d: dt.getUTCDate() }; }
  function idxMes(d) { var p = partes(d); return p.a * 12 + p.m; }
  function inicioMes(d) { var p = partes(d); return Math.floor(Date.UTC(p.a, p.m - 1, 1) / 864e5); }
  function diasNoMes(a, m) { return new Date(Date.UTC(a, m, 0)).getUTCDate(); }
  /* ADD_MONTHS do Oracle: se a data é o último dia do mês, o resultado é o último dia do mês alvo. */
  function addMonths(d, n) {
    var p = partes(d), t = p.a * 12 + (p.m - 1) + n, a = Math.floor(t / 12), m = t - a * 12 + 1;
    var ult = diasNoMes(a, m), ehUlt = p.d === diasNoMes(p.a, p.m);
    var dd = ehUlt ? ult : Math.min(p.d, ult);
    return Math.floor(Date.UTC(a, m - 1, dd) / 864e5);
  }
  function hojeISO(offset) {
    var d = new Date(); d.setDate(d.getDate() + (offset || 0));
    return d.getFullYear() + "-" + pad2(d.getMonth() + 1) + "-" + pad2(d.getDate());
  }
  function normData(v) {
    if (!v) return null;
    var m = /^(\d{4})-(\d{2})-(\d{2})/.exec(v);
    if (m) return dataValida(m[1], m[2], m[3]);
    m = /^(\d{2})\/(\d{2})\/(\d{4})/.exec(v);
    if (m) return dataValida(m[3], m[2], m[1]);
    return null;
  }
  function dataValida(a, m, d) {
    var dt = new Date(Date.UTC(+a, +m - 1, +d));
    if (dt.getUTCFullYear() !== +a || dt.getUTCMonth() + 1 !== +m || dt.getUTCDate() !== +d) return null;
    return a + "-" + m + "-" + d;
  }

  /* ---------------------------------------------------------------- unidades (TGFVOA) */
  /* Agrupa regras ativas por produto+unidade; mais de uma regra distinta = ambígua. */
  function agruparVoa(linhas) {
    var g = {};
    for (var i = 0; i < (linhas || []).length; i++) {
      var v = linhas[i];
      if ((v.ATIVO === null || v.ATIVO === undefined ? "S" : v.ATIVO) !== "S") continue;
      var k = v.CODPROD + "|" + v.CODVOL;
      var x = g[k] || (g[k] = { DM: null, QC: null, distintas: {}, CODPROD: v.CODPROD });
      var dm = v.DIVIDEMULTIPLICA === null || v.DIVIDEMULTIPLICA === undefined ? "-" : String(v.DIVIDEMULTIPLICA);
      var qc = v.QUANTIDADE === null || v.QUANTIDADE === undefined ? "-" : String(num(v.QUANTIDADE));
      x.distintas[dm + "|" + qc] = 1;
      if (v.DIVIDEMULTIPLICA !== null && v.DIVIDEMULTIPLICA !== undefined && (x.DM === null || String(v.DIVIDEMULTIPLICA) > x.DM)) x.DM = String(v.DIVIDEMULTIPLICA);
      if (num(v.QUANTIDADE) !== null && (x.QC === null || num(v.QUANTIDADE) > x.QC)) x.QC = num(v.QUANTIDADE);
    }
    for (var k2 in g) if (Object.prototype.hasOwnProperty.call(g, k2)) g[k2].N_REGRAS = Object.keys(g[k2].distintas).length;
    return g;
  }
  /* Espelha as macros FATOR/STATUS_CONV do SQL. fator null = unidade não conciliada. */
  function conversao(codvolItem, codvolPadrao, regra) {
    if (codvolItem === null || codvolItem === undefined) return { fator: null, status: "SEM_UNIDADE" };
    if (codvolItem === codvolPadrao) return { fator: 1, status: "PADRAO" };
    if (!regra) return { fator: null, status: "SEM_REGRA" };
    if (regra.N_REGRAS > 1) return { fator: null, status: "AMBIGUA" };
    if (regra.DM === "M" && regra.QC > 0) return { fator: regra.QC, status: "MULTIPLICA" };
    if (regra.DM === "D" && regra.QC > 0) return { fator: 1 / regra.QC, status: "DIVIDE" };
    return { fator: null, status: "REGRA_INVALIDA" };
  }

  /* ---------------------------------------------------------------- regras de cálculo */
  /* Peso do mês de idade a (1 = último mês completo) na média ponderada com janelas sobrepostas. */
  function pesoMes(a, N) { return (a <= 3 ? 0.5 / 3 : 0) + (a <= 6 ? 0.3 / 6 : 0) + 0.2 / N; }
  function somaPesos(n, N) { return 0.5 / 3 * Math.min(n, 3) + 0.3 / 6 * Math.min(n, 6) + 0.2 / N * n; }
  function dDemanda(cmp, dd, t, regra) { return regra === 2 ? cmp + dd * t : Math.max(cmp, dd * t); }
  function tFalta(s, cmp, dd, regra) {
    if (s < cmp) return 0;
    if (dd <= 0) return null;
    return (s - (regra === 2 ? cmp : 0)) / dd;
  }
  /* Lote mínimo e depois múltiplo: o resultado atende os dois. Nunca negativo. */
  function arredondarLote(nec, lote, mult, habilitado) {
    var invalido = (num(lote) !== null && lote < 0) || (num(mult) !== null && mult < 0);
    if (!habilitado || !(nec > 0)) return { qtd: null, excesso: null, invalido: invalido };
    var q1 = Math.max(nec, lote > 0 ? lote : 0);
    var q = mult > 0 ? Math.ceil(arred(q1 / mult, 6)) * mult : q1;
    return { qtd: q, excesso: q - nec, invalido: invalido };
  }
  /* Política PRG/JIT: só com classificador validado e por ITEM. Sem classificador = NAO_VALIDADA.
   * Campos de cabeçalho/cliente/produto (ex.: SOLCOMPRA, AD_ABASTECIMENTO) são ignorados de propósito. */
  function classificarPolitica(item, classificador) {
    if (!classificador || classificador.validado !== true || typeof classificador.porItem !== "function") return "NAO_VALIDADA";
    var v = classificador.porItem(item);
    return v === "PRG" || v === "JIT" ? v : "NAO_VALIDADA";
  }

  /* ---------------------------------------------------------------- CSV (Excel pt-BR) */
  /* Texto que o Excel interpretaria como fórmula ganha apóstrofo (CWE-1236). */
  function protegerFormula(s) { return /^[=+\-@\t\r|%]/.test(s) ? "'" + s : s; }
  function campoCSV(v, casas) {
    if (v === null || v === undefined) return "";
    if (casas !== undefined && casas !== null) {
      var n = num(v);
      if (n === null) return "";
      return (casas === "auto" ? String(arred(n, 6)) : n.toFixed(casas)).replace(".", ",");
    }
    var s = protegerFormula(String(v));
    return /[;"\r\n]/.test(s) ? "\"" + s.replace(/"/g, "\"\"") + "\"" : s;
  }
  /* cols: [[campo, titulo, casas?]] */
  function montarCSV(linhas, cols) {
    var out = [cols.map(function (c) { return campoCSV(c[1]); }).join(";")];
    for (var i = 0; i < linhas.length; i++) {
      var r = linhas[i];
      out.push(cols.map(function (c) { return campoCSV(typeof c[0] === "function" ? c[0](r) : r[c[0]], c[2]); }).join(";"));
    }
    return "﻿" + out.join("\r\n") + "\r\n";
  }

  /* ---------------------------------------------------------------- retorno do executeQuery */
  /* O modelo oficial faz JSON.parse(value). Aceita também texto embrulhado (objeto String/Java),
   * JSON duplo, lista pronta e invólucros comuns. Sem nome de coluna = erro explícito. */
  function ehTexto(v) { return typeof v === "string" || Object.prototype.toString.call(v) === "[object String]"; }
  function comoLinhas(v, nivel) {
    nivel = nivel || 0;
    if (nivel > 6 || v === null || v === undefined) return null;
    if (ehTexto(v)) {
      var s = String(v).replace(/^\s+|\s+$/g, "");
      if (s === "") return [];
      var p;
      try { p = JSON.parse(s); } catch (e) { return null; }
      return comoLinhas(p, nivel + 1);
    }
    if (Object.prototype.toString.call(v) === "[object Array]") return v;
    if (typeof v === "object") {
      if (typeof v.length === "number" && v.length >= 0 && (v.length === 0 || v[0] !== undefined)) return Array.prototype.slice.call(v);
      var comoTexto = null;
      try { comoTexto = String(v); } catch (e2) { comoTexto = null; }
      if (comoTexto && comoTexto !== "[object Object]" && /^\s*[\[{"]/.test(comoTexto)) {
        var viaTexto = comoLinhas(comoTexto, nivel + 1);
        if (viaTexto) return viaTexto;
      }
      var nomes = ["rows", "data", "dados", "result", "resultado", "registros", "lista", "responseBody", "value", "valor"];
      for (var i = 0; i < nomes.length; i++) {
        if (v[nomes[i]] === undefined || v[nomes[i]] === null) continue;
        var dentro = comoLinhas(v[nomes[i]], nivel + 1);
        if (!dentro) continue;
        var campos = v.fields || v.fieldsMetadata || v.columns || v.colunas || v.metadata;
        if (dentro.length && Object.prototype.toString.call(dentro[0]) === "[object Array]" && Object.prototype.toString.call(campos) === "[object Array]") {
          return dentro.map(function (r) {
            var o = {};
            for (var k = 0; k < campos.length; k++) {
              var c = campos[k];
              o[typeof c === "string" ? c : (c.name || c.nome || c.label || ("C" + k))] = r[k];
            }
            return o;
          });
        }
        return dentro;
      }
      for (var chave in v) {
        if (!Object.prototype.hasOwnProperty.call(v, chave)) continue;
        var x = v[chave];
        if (x === null || x === undefined || (typeof x !== "object" && !ehTexto(x))) continue;
        var achou = comoLinhas(x, nivel + 1);
        if (achou) return achou;
      }
    }
    return null;
  }
  function descreverValor(v) {
    var tipo = Object.prototype.toString.call(v), txt;
    try { txt = ehTexto(v) ? String(v) : JSON.stringify(v); } catch (e) { txt = String(v); }
    txt = String(txt === undefined ? v : txt);
    return tipo + " · " + txt.length + " caracteres";
  }
  function lerRetorno(valor) {
    var linhas = comoLinhas(valor, 0);
    if (linhas === null) throw new Error("Formato de retorno do executeQuery não reconhecido (" + descreverValor(valor) + ").");
    var out = [];
    for (var i = 0; i < linhas.length; i++) {
      var l = linhas[i];
      if (l === null || typeof l !== "object" || Object.prototype.toString.call(l) === "[object Array]") {
        throw new Error("Retorno do executeQuery sem nome de coluna (" + descreverValor(valor) + ").");
      }
      var o = {};
      for (var k in l) if (Object.prototype.hasOwnProperty.call(l, k)) o[String(k).toUpperCase()] = l[k];
      out.push(o);
    }
    return out;
  }

  /* ---------------------------------------------------------------- erros */
  function textoErro(e) {
    if (e === null || e === undefined) return "Erro sem mensagem.";
    if (typeof e === "string") return e;
    if (e.message) return String(e.message);
    try { return JSON.stringify(e); } catch (x) { return String(e); }
  }
  /* Só ORA-00942 vira "tabela ausente". Outros erros não são mascarados. */
  function classificarErro(msg) {
    msg = String(msg || "");
    var cod = (/ORA-\d{5}/.exec(msg) || [""])[0];
    if (cod === "ORA-00942") return { tipo: "OBJETO_AUSENTE", codigo: cod, texto: "Tabela ou view inexistente (ou sem permissão)." };
    if (cod === "ORA-00904") return { tipo: "COLUNA_AUSENTE", codigo: cod, texto: "Coluna inexistente nesta versão/ambiente." };
    if (cod === "ORA-01722") return { tipo: "PARAMETRO", codigo: cod, texto: "Número inválido em parâmetro ou dado." };
    if (/ORA-018[3-6]\d/.test(cod)) return { tipo: "PARAMETRO", codigo: cod, texto: "Data recusada pelo banco." };
    if (cod === "ORA-01013" || /Sem resposta|timeout/i.test(msg)) return { tipo: "TEMPO", codigo: cod, texto: "Tempo de espera esgotado." };
    if (cod === "ORA-01031") return { tipo: "PERMISSAO", codigo: cod, texto: "Sem permissão para o objeto." };
    if (/^Parâmetro|^Data inválida|^Valor fora/.test(msg)) return { tipo: "PARAMETRO", codigo: "", texto: "Parâmetro recusado antes do envio." };
    return { tipo: "OUTRO", codigo: cod, texto: "Erro na consulta." };
  }
  function primeiraLinha(s, max) { return String(s || "").split(/\r?\n/)[0].slice(0, max || 200); }

  /* ---------------------------------------------------------------- parâmetros */
  function validarParametro(def, v) {
    if (v === null || v === undefined || isNaN(v)) return false;
    if (v < def.min || v > def.max) return false;
    if (def.inteiro && v !== Math.round(v)) return false;
    return true;
  }
  /* Regras entre parâmetros; devolve lista de chaves que devem voltar ao padrão. */
  function validarCruzado(cfg) {
    var ruins = [];
    if (cfg.MIN_MESES_HIST > cfg.MESES_MEDIA) ruins.push("MIN_MESES_HIST");
    if (cfg.ABC_LIMITE_B <= cfg.ABC_LIMITE_A) ruins.push("ABC_LIMITE_B");
    return ruins;
  }
  /* Converte valores lógicos em binds {value,type}; recusa o que não passar no contrato. */
  function montarParams(q, valores, especiais) {
    var out = [];
    var esp = {};
    for (var e = 0; e < (especiais || []).length; e++) esp[especiais[e].chave] = especiais[e];
    for (var i = 0; i < q.params.length; i++) {
      var nome = q.params[i], t = q.tipos[i], v = valores[nome];
      if (v === undefined || v === null) throw new Error("Parâmetro sem valor: " + nome);
      var s = String(v);
      var d = esp[nome];
      if (t === "I") {
        if (!/^-?\d{1,12}$/.test(s)) throw new Error("Parâmetro " + nome + " inválido: " + primeiraLinha(s, 40));
      } else if (d && d.tipo === "D") {
        if (!/^\d{4}-\d{2}-\d{2}$/.test(s) || !normData(s)) throw new Error("Data inválida em " + nome + ": " + primeiraLinha(s, 40));
      } else if (d && d.tipo === "C") {
        if ((d.valores || []).indexOf(s) < 0) throw new Error("Valor fora da lista permitida em " + nome);
      } else {
        throw new Error("Parâmetro texto sem regra de validação: " + nome);
      }
      out.push({ value: s, type: t });
    }
    return out;
  }

  /* ---------------------------------------------------------------- requisições */
  /* Cada área da tela recebe um número de geração; resposta de geração antiga é ignorada. */
  function criarSequenciador() {
    var atual = {};
    return {
      novo: function (area) { atual[area] = (atual[area] || 0) + 1; return atual[area]; },
      valido: function (area, token) { return atual[area] === token; },
      invalidarTudo: function () { for (var k in atual) if (Object.prototype.hasOwnProperty.call(atual, k)) atual[k]++; }
    };
  }
  /* Limita execuções simultâneas (o painel não tenta cancelar nada no banco). */
  function criarFila(max) {
    var ativos = 0, espera = [];
    function proximo() {
      while (ativos < max && espera.length) {
        var t = espera.shift();
        ativos++;
        t.fn(function () { ativos--; proximo(); });
      }
    }
    return {
      executar: function (fn) { espera.push({ fn: fn }); proximo(); },
      ativos: function () { return ativos; },
      pendentes: function () { return espera.length; }
    };
  }

  /* ---------------------------------------------------------------- rótulos */
  var ROTULO_PRIORIDADE = {
    P1_CRITICO: "P1 · Crítico", P2_RUPTURA_IMINENTE: "P2 · Falta antes do lead time", P3_ATENCAO: "P3 · Atenção",
    REVISAR_SEM_GIRO: "Revisar · sem giro com compromisso", P0_EXCESSO: "P0 · Excesso", P0_SEM_GIRO: "P0 · Sem giro", OK: "OK"
  };
  var SIMBOLO_PRIORIDADE = { P1_CRITICO: "▲▲", P2_RUPTURA_IMINENTE: "▲", P3_ATENCAO: "△", REVISAR_SEM_GIRO: "?", P0_EXCESSO: "▽", P0_SEM_GIRO: "▽", OK: "✓" };
  var ORDEM_PRIORIDADE = ["P1_CRITICO", "P2_RUPTURA_IMINENTE", "P3_ATENCAO", "REVISAR_SEM_GIRO", "P0_EXCESSO", "P0_SEM_GIRO", "OK"];
  var ROTULO_MOTIVO = {
    ESTOQUE_NEGATIVO: "Estoque físico negativo (inconsistência a investigar)",
    COMPROMISSO_MAIOR_QUE_ESTOQUE: "Compromissos maiores que o estoque utilizável",
    SEM_COBERTURA_FISICA: "Sem cobertura física para a demanda",
    FALTA_ANTES_RECEBIMENTO: "Falta estimada antes do próximo recebimento confirmado",
    FALTA_DENTRO_LEAD_TIME: "Falta estimada antes de uma nova compra chegar (lead time)",
    ABAIXO_PONTO_PEDIDO: "Posição (estoque + OC confirmada) abaixo do ponto de pedido",
    PROXIMO_PONTO_PEDIDO: "Posição dentro da margem de atenção do ponto de pedido",
    SEM_GIRO_COM_COMPROMISSO: "Sem consumo na janela, mas com compromisso pendente (não tratado como excesso)",
    SEM_GIRO: "Sem consumo na janela, com estoque",
    COBERTURA_ACIMA_MAXIMO: "Cobertura com OC confirmada acima do máximo",
    HISTORICO_INSUFICIENTE: "Histórico insuficiente (produto novo na janela)",
    CONSUMO_LIQUIDO_NEGATIVO: "Devoluções maiores que as saídas na janela (média tratada como zero)",
    UNIDADE_NAO_CONCILIADA: "Unidade não conciliada em consumo, compromisso, OC ou cotação (excluída das quantidades)",
    OC_NAO_CONFIRMADA: "OC não confirmada ou com aprovação não determinada (não conta como contratada)",
    OC_ATRASADA: "OC com previsão vencida (prazo incerto)",
    OC_SEM_PREVISAO: "OC sem previsão de entrega (prazo incerto)",
    OC_ANTIGA_ABERTA: "OC antiga ainda aberta",
    SEM_PRECO_REFERENCIA: "Sem preço de referência (valor não estimado)",
    LEAD_TIME_PADRAO: "Lead time padrão (produto sem lead time no cadastro)",
    CONSIGNADO_SEM_CALCULO: "Consignado: necessidade não calculada (regra herdada)",
    ABAIXO_ESTMIN_CADASTRO: "Disponível abaixo do estoque mínimo do cadastro (informativo)",
    LOTE_MULTIPLO_INVALIDO: "Lote mínimo ou múltiplo negativo no cadastro"
  };
  var MOTIVOS_DECISAO = ["ESTOQUE_NEGATIVO", "COMPROMISSO_MAIOR_QUE_ESTOQUE", "SEM_COBERTURA_FISICA", "FALTA_ANTES_RECEBIMENTO",
    "FALTA_DENTRO_LEAD_TIME", "ABAIXO_PONTO_PEDIDO", "PROXIMO_PONTO_PEDIDO", "SEM_GIRO_COM_COMPROMISSO", "SEM_GIRO", "COBERTURA_ACIMA_MAXIMO"];
  function motivos(texto) { return String(texto || "").split(";").filter(function (x) { return x; }); }

  return {
    num: num, arred: arred, esc: esc, pad2: pad2,
    fN: fN, fQ: fQ, fR: fR, fRc: fRc, fP: fP, fData: fData, fMes: fMes,
    dia: dia, diaISO: diaISO, idxMes: idxMes, inicioMes: inicioMes, addMonths: addMonths, hojeISO: hojeISO, normData: normData,
    agruparVoa: agruparVoa, conversao: conversao,
    pesoMes: pesoMes, somaPesos: somaPesos, dDemanda: dDemanda, tFalta: tFalta, arredondarLote: arredondarLote,
    classificarPolitica: classificarPolitica,
    protegerFormula: protegerFormula, campoCSV: campoCSV, montarCSV: montarCSV,
    comoLinhas: comoLinhas, lerRetorno: lerRetorno, descreverValor: descreverValor,
    textoErro: textoErro, classificarErro: classificarErro, primeiraLinha: primeiraLinha,
    validarParametro: validarParametro, validarCruzado: validarCruzado, montarParams: montarParams,
    criarSequenciador: criarSequenciador, criarFila: criarFila,
    ROTULO_PRIORIDADE: ROTULO_PRIORIDADE, SIMBOLO_PRIORIDADE: SIMBOLO_PRIORIDADE, ORDEM_PRIORIDADE: ORDEM_PRIORIDADE,
    ROTULO_MOTIVO: ROTULO_MOTIVO, MOTIVOS_DECISAO: MOTIVOS_DECISAO, motivos: motivos
  };
})();
if (typeof module !== "undefined" && module.exports) module.exports = Calc;
