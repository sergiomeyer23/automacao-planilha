/* Interface do painel. Depende de: Calc, Motor, Demo, Q, CONFIG, BUILD (definidos no bundle). ES5. */
var App = (function () {
  "use strict";
  var esc = Calc.esc, num = Calc.num, fN = Calc.fN, fQ = Calc.fQ, fR = Calc.fR, fRc = Calc.fRc, fP = Calc.fP, fData = Calc.fData;
  function $(id) { return document.getElementById(id); }

  var DEFS = {};
  CONFIG.parametros.forEach(function (p) { DEFS[p.chave] = p; });

  var est = {
    modo: "real", demoOpcionais: false, codemp: 0, dtIni: "", dtFim: "",
    cfg: {}, cfgOrigem: {}, tabelaParams: "NAO_CONSULTADA", tabelaParamsErro: "",
    avisos: [], cache: {}, log: [], atual: "exec", carregadas: {},
    resumo: null, filaUniverso: "ATENCAO", fila: [], filaVisivel: [], ordFila: null,
    carteira: null, ocFiltro: "ATRASADAS", oc: [], ocVisivel: [], ordOc: null,
    consumo: [], diag: null, snap: null, formatoRetorno: ""
  };
  var seq = Calc.criarSequenciador();
  var filaExec = Calc.criarFila(CONFIG.consultasSimultaneas || 2);

  var ROT_SITUACAO = { CONFIRMADA: "Confirmada", NAO_CONFIRMADA: "Não confirmada", APROVACAO_NAO_DETERMINADA: "Aprovação não determinada" };
  var ROT_PRAZO = { NO_PRAZO: "Previsão futura", ATRASADA: "Previsão vencida", SEM_PREVISAO: "Sem previsão" };
  var ROT_STATUS_ITEM = { CANCELADA: "Cancelada", ATENDIDA_INTEGRAL: "Atendida integralmente (registro)", ENCERRADA_COM_SALDO: "Encerrada com saldo",
    ENCERRADA_SEM_ATENDIMENTO: "Encerrada sem atendimento", ATENDIMENTO_PARCIAL: "Atendimento parcial", ABERTA_SEM_ATENDIMENTO: "Aberta sem atendimento" };
  var ROT_VINC = { NATIVO_TGFVAR: "Vínculo nativo (TGFVAR)", INFERIDO_OS: "Inferido por OS + produto (não comprovado)",
    INFERIDO_OS_COMPARTILHADO: "Inferido por OS + produto, entrada compartilhada com outras OCs", ATENDIMENTO_SEM_VINCULO: "Atendimento registrado sem vínculo encontrado",
    SEM_ATENDIMENTO: "Sem atendimento" };
  var ROT_SERIE = { ANTIGO: "Antigo (série completa)", NOVO: "Novo (série desde o 1º consumo)", SO_MES_ATUAL: "Só mês corrente", SEM_CONSUMO: "Sem consumo no horizonte" };
  var ROT_QUAL_OC = { OC_SEM_PREVISAO: "Itens abertos sem previsão (prazo incerto)", UNIDADE_NAO_CONCILIADA: "Itens abertos com unidade não conciliada",
    OC_ANTIGA_ABERTA: "Itens antigos ainda abertos", NAO_CONFIRMADA: "Itens abertos não confirmados", APROVACAO_NAO_DETERMINADA: "Itens abertos com aprovação não determinada",
    ACIMA_NEGOCIADO: "Itens com atendido acima do negociado", ENCERRADA_COM_SALDO: "Itens do período encerrados com saldo (possível tolerância)",
    ENTRADA_OS_COMPARTILHADA: "Itens cuja entrada por OS casa com mais de uma OC", TOP_PRECO_SEPARADO_ABERTA: "Itens abertos em TOP de preço separado (ex.: 1741)" };

  /* ================================================================ utilidades de tela */
  function carregando(t) { return "<div class=\"carregando\">" + esc(t || "Consultando…") + "</div>"; }
  function vazio(t) { return "<div class=\"vazio\">" + esc(t) + "</div>"; }
  function indisp(t) { return "<span class=\"indisp\">Indisponível</span> <span class=\"nota\">" + esc(t) + "</span>"; }
  function chip(p) {
    return "<span class=\"chip " + esc(p) + "\" title=\"" + esc(Calc.ROTULO_PRIORIDADE[p] || p) + "\">" +
      esc((Calc.SIMBOLO_PRIORIDADE[p] || "") + " " + (Calc.ROTULO_PRIORIDADE[p] || p)) + "</span>";
  }
  function erroHTML(titulo, e) {
    var msg = Calc.textoErro(e), c = Calc.classificarErro(msg);
    return "<div class=\"erro\" role=\"alert\"><b>" + esc(titulo) + ":</b> " + esc(c.texto) +
      (c.codigo ? " <span class=\"cod\">" + esc(c.codigo) + "</span>" : "") +
      " <span class=\"nota\">Detalhe técnico no log (aba Parâmetros e qualidade).</span></div>";
  }
  function aviso(tipo, texto) {
    for (var i = 0; i < est.avisos.length; i++) if (est.avisos[i].texto === texto) return;
    est.avisos.push({ tipo: tipo, texto: texto });
    $("avisos").innerHTML = est.avisos.map(function (a) { return "<div class=\"av av-" + esc(a.tipo) + "\">" + esc(a.texto) + "</div>"; }).join("");
  }
  function kpi(t, valor, sub, classe, definicao) {
    return "<div class=\"kpi" + (classe ? " " + classe : "") + "\"><div class=\"kpi-t\">" + esc(t) + "</div><div class=\"kpi-v\">" + valor +
      "</div><div class=\"kpi-s\">" + (sub || "") + "</div>" +
      (definicao ? "<details class=\"def\"><summary>Como é calculado</summary>" + esc(definicao) + "</details>" : "") + "</div>";
  }
  function barras(itens, larguraRot) {
    var max = 0, i;
    for (i = 0; i < itens.length; i++) if (itens[i].val > max) max = itens[i].val;
    if (!max) max = 1;
    var h = 26, W = 600, L = larguraRot || 200, H = itens.length * h + 6;
    var s = "<svg viewBox=\"0 0 " + W + " " + H + "\" width=\"100%\" height=\"" + H + "\" role=\"img\" aria-label=\"Gráfico de barras\">";
    for (i = 0; i < itens.length; i++) {
      var it = itens[i], y = i * h + 4, w = Math.max(1, (W - L - 150) * it.val / max);
      s += "<text x=\"0\" y=\"" + (y + 14) + "\">" + esc(it.rot) + "</text>";
      s += "<rect x=\"" + L + "\" y=\"" + y + "\" width=\"" + w.toFixed(1) + "\" height=\"18\" rx=\"3\" fill=\"" + esc(it.cor || "#1f4e79") + "\"><title>" + esc(it.tip || it.txt) + "</title></rect>";
      s += "<text x=\"" + (L + w + 6).toFixed(1) + "\" y=\"" + (y + 14) + "\">" + esc(it.txt) + "</text>";
    }
    return s + "</svg>";
  }
  var COR_PRIO = { P1_CRITICO: "#c0392b", P2_RUPTURA_IMINENTE: "#d9822b", P3_ATENCAO: "#d4ac0d", REVISAR_SEM_GIRO: "#7d5fb2", P0_EXCESSO: "#2e75b6", P0_SEM_GIRO: "#7fa6d4", OK: "#4f9a5f" };
  function motivoPrincipal(r) {
    var ms = Calc.motivos(r.MOTIVOS);
    for (var i = 0; i < ms.length; i++) if (Calc.MOTIVOS_DECISAO.indexOf(ms[i]) >= 0) return ms[i];
    return ms[0] || null;
  }
  function tagsQualidade(r) {
    var ms = Calc.motivos(r.MOTIVOS), t = [];
    function tem(m) { return ms.indexOf(m) >= 0; }
    if (tem("UNIDADE_NAO_CONCILIADA")) t.push(["Unidade?", "Unidade não conciliada em algum movimento"]);
    if (tem("SEM_PRECO_REFERENCIA")) t.push(["Sem preço", "Sem preço de referência"]);
    if (tem("HISTORICO_INSUFICIENTE")) t.push(["Hist. curto", "Histórico insuficiente"]);
    if (tem("LEAD_TIME_PADRAO")) t.push(["LT padrão", "Lead time padrão"]);
    if (tem("OC_SEM_PREVISAO")) t.push(["OC sem prev.", "OC sem previsão"]);
    if (tem("OC_ATRASADA")) t.push(["OC atrasada", "OC com previsão vencida"]);
    if (tem("OC_NAO_CONFIRMADA")) t.push(["OC não conf.", "OC não confirmada"]);
    return t.map(function (x) { return "<span class=\"tag q\" title=\"" + esc(x[1]) + "\">" + esc(x[0]) + "</span>"; }).join("");
  }
  function ordenar(lista, col, desc) {
    var c = lista.slice();
    c.sort(function (a, b) {
      var x = a[col], y = b[col], xn = num(x), yn = num(y);
      var xv = x === null || x === undefined || x === "", yv = y === null || y === undefined || y === "";
      if (xv && yv) return 0;
      if (xv) return 1;
      if (yv) return -1;
      var r = (xn !== null && yn !== null) ? xn - yn : String(x).localeCompare(String(y), "pt-BR");
      return desc ? -r : r;
    });
    return c;
  }
  function th(col, titulo, classe, ord) {
    var s = ord && ord.col === col ? (ord.desc ? "descending" : "ascending") : "none";
    return "<th class=\"ord" + (classe ? " " + classe : "") + "\" data-col=\"" + esc(col) + "\" aria-sort=\"" + s + "\" tabindex=\"0\">" + esc(titulo) + "</th>";
  }
  function baixar(nome, texto) {
    var a = $("dl");
    try {
      if (window.Blob && window.URL && URL.createObjectURL) {
        var url = URL.createObjectURL(new Blob([texto], { type: "text/csv;charset=utf-8" }));
        a.href = url; a.download = nome; a.click();
        setTimeout(function () { URL.revokeObjectURL(url); }, 5000);
        return;
      }
    } catch (e) { /* cai para data: URI */ }
    a.href = "data:text/csv;charset=utf-8," + encodeURIComponent(texto);
    a.download = nome; a.click();
  }
  function sufixoArquivo() { return (est.modo === "demo" ? "DEMO_" : "") + "emp" + (est.codemp || "todas") + "_" + Calc.hojeISO(0); }

  /* ================================================================ parâmetros do Construtor */
  function lerBI(nome) {
    var p = window.PARAMETROS_BI || {}, v = p[nome];
    if (v === undefined || v === null) return "";
    v = String(v).replace(/^\s+|\s+$/g, "");
    return v.charAt(0) === "$" ? "" : v;
  }
  function iniciarFiltros() {
    var ini = lerBI("PERIODO_INI"), fim = lerBI("PERIODO_FIN"), emp = lerBI("CODEMP");
    var dI = Calc.normData(ini), dF = Calc.normData(fim);
    if (ini && !dI) aviso("aviso", "PERIODO.INI em formato não reconhecido; usado o padrão (registrar na homologação).");
    if (fim && !dF) aviso("aviso", "PERIODO.FIN em formato não reconhecido; usado o padrão (registrar na homologação).");
    est.dtIni = dI || Calc.hojeISO(-89);
    est.dtFim = dF || Calc.hojeISO(0);
    if (est.dtIni > est.dtFim) { var t = est.dtIni; est.dtIni = est.dtFim; est.dtFim = t; aviso("aviso", "Data inicial depois da final: datas invertidas."); }
    if (emp === "" || emp === "0") est.codemp = 0;
    else if (/^\d{1,6}$/.test(emp)) est.codemp = parseInt(emp, 10);
    else { est.codemp = 0; aviso("aviso", "CODEMP recebido não é um código único: usando todas as empresas."); }
    $("f-codemp").value = est.codemp ? String(est.codemp) : "";
    $("f-ini").value = est.dtIni;
    $("f-fim").value = est.dtFim;
  }

  /* ================================================================ execução de consultas */
  function valorLogico(nome, extra) {
    if (extra && Object.prototype.hasOwnProperty.call(extra, nome)) return extra[nome];
    if (nome === "CODEMP") return est.codemp;
    if (nome === "DT_INI") return est.dtIni;
    if (nome === "DT_FIM") return est.dtFim;
    if (nome === "DIAG_NUM") return 123;
    if (nome === "FILTRO_FILA") return est.filaUniverso;
    if (nome === "FILTRO_OC") return est.ocFiltro;
    if (nome === "CODPROD_FILTRO") return 0;
    if (Object.prototype.hasOwnProperty.call(CONFIG.limites, nome)) return CONFIG.limites[nome];
    var d = DEFS[nome];
    if (d) return d.escala ? Math.round(est.cfg[nome] * d.escala) : Math.round(est.cfg[nome]);
    throw new Error("Parâmetro sem valor: " + nome);
  }
  function bindsDe(id, extra) {
    var q = Q[id], valores = {};
    for (var i = 0; i < q.params.length; i++) valores[q.params[i]] = valorLogico(q.params[i], extra);
    return Calc.montarParams(q, valores, CONFIG.especiais);
  }
  function sysdateDemo() {
    var d = new Date(), p = Calc.pad2;
    return d.getFullYear() + "-" + p(d.getMonth() + 1) + "-" + p(d.getDate()) + " " + p(d.getHours()) + ":" + p(d.getMinutes()) + ":00";
  }
  function registrar(id, ok, ms, info) {
    est.log.push({ id: id, ok: ok, ms: ms, info: info, quando: new Date().toLocaleTimeString("pt-BR") });
    if (est.atual === "param") renderLog();
  }
  function rodar(id, extra) {
    var params;
    try { params = bindsDe(id, extra); } catch (e) { registrar(id, false, 0, Calc.primeiraLinha(e.message)); return Promise.reject(e); }
    var chave = est.modo + "|" + BUILD.hash + "|" + id + "|" + JSON.stringify(params);
    if (est.cache[chave]) return est.cache[chave];
    var limite = (CONFIG.timeoutSegundos || 180) * 1000;
    var p = new Promise(function (ok, falha) {
      filaExec.executar(function (liberar) {
        var t0 = Date.now(), feito = false, timer;
        function concluir(err, linhas) {
          if (feito) return;
          feito = true; clearTimeout(timer); liberar();
          if (err) { registrar(id, false, Date.now() - t0, Calc.primeiraLinha(Calc.textoErro(err), 300)); falha(err); }
          else { registrar(id, true, Date.now() - t0, linhas.length + " linhas"); ok(linhas); }
        }
        timer = setTimeout(function () {
          concluir(new Error("Sem resposta em " + (limite / 1000) + " s. O painel parou de esperar; isso NÃO cancela a consulta no banco."));
        }, limite);
        if (est.modo === "demo") {
          setTimeout(function () {
            try {
              var sd = sysdateDemo(), porNome = {};
              Q[id].params.forEach(function (n, i) { porNome[n] = params[i].value; });
              var l = Motor.executar(id, porNome, Demo.banco(sd, est.demoOpcionais), { config: CONFIG, sysdate: sd });
              concluir(null, Calc.lerRetorno(JSON.stringify(l)));
            } catch (e) { concluir(e); }
          }, 40 + Math.floor(Math.random() * 250));
          return;
        }
        try {
          executeQuery(Q[id].sql, params, function (valor) {
            if (!est.formatoRetorno) est.formatoRetorno = Calc.descreverValor(valor);
            var linhas;
            try { linhas = Calc.lerRetorno(valor); } catch (e) { concluir(e); return; }
            concluir(null, linhas);
          }, function (erro) { concluir(new Error(Calc.textoErro(erro))); });
        } catch (e) { concluir(e); }
      });
    });
    est.cache[chave] = p;
    p.then(null, function () { if (est.cache[chave] === p) delete est.cache[chave]; });
    return p;
  }

  /* ================================================================ parâmetros (BI_PARAM_COMPRA) */
  function carregarParametros() {
    CONFIG.parametros.forEach(function (p) { est.cfg[p.chave] = p.padrao; est.cfgOrigem[p.chave] = "padrão"; });
    return rodar("Q_PARAMS").then(function (linhas) {
      est.tabelaParams = "OK";
      linhas.forEach(function (l) {
        var k = String(l.CHAVE || "").replace(/^\s+|\s+$/g, "").toUpperCase();
        if (CONFIG.chavesLegadas[k]) { aviso("aviso", "BI_PARAM_COMPRA." + k + ": " + CONFIG.chavesLegadas[k]); return; }
        var d = DEFS[k];
        if (!d) return;
        var v = num(String(l.VALOR === null || l.VALOR === undefined ? "" : l.VALOR).replace(",", "."));
        if (v === null || !Calc.validarParametro(d, v)) {
          aviso("aviso", "BI_PARAM_COMPRA." + k + " fora da faixa aceita (" + d.min + " a " + d.max + "): usado o padrão " + String(d.padrao).replace(".", ",") + ".");
          return;
        }
        est.cfg[k] = v; est.cfgOrigem[k] = "tabela";
      });
      Calc.validarCruzado(est.cfg).forEach(function (k) {
        est.cfg[k] = DEFS[k].padrao; est.cfgOrigem[k] = "padrão (valor da tabela incoerente)";
        aviso("aviso", "BI_PARAM_COMPRA." + k + " incoerente com outro parâmetro: usado o padrão.");
      });
    }, function (e) {
      var c = Calc.classificarErro(Calc.textoErro(e));
      if (c.tipo === "OBJETO_AUSENTE") {
        est.tabelaParams = "AUSENTE";
        aviso("info", "Tabela opcional BI_PARAM_COMPRA não encontrada: parâmetros PADRÃO em uso (nenhum aprovado). Ver aba Parâmetros e qualidade.");
      } else {
        est.tabelaParams = "ERRO";
        est.tabelaParamsErro = c.texto + (c.codigo ? " (" + c.codigo + ")" : "");
        aviso("alerta", "Erro ao ler BI_PARAM_COMPRA (não é ausência da tabela): " + est.tabelaParamsErro + ". Parâmetros PADRÃO em uso.");
      }
    });
  }

  /* ================================================================ linha de contexto */
  function renderContexto() {
    var r = est.resumo && est.resumo[0], partes = [];
    partes.push("Modo: <b>" + (est.modo === "demo" ? "DEMONSTRAÇÃO (dados simulados)" : "real (executeQuery)") + "</b>");
    partes.push("Empresa: <b>" + esc(est.codemp ? est.codemp : "todas") + "</b>");
    if (r) {
      partes.push("Data-base do cálculo: <b>" + esc(fData(r.DT_BASE)) + "</b> (relógio do banco, consulta " + esc(r.SNAPSHOT || "") + ")");
      partes.push("Consumo: <b>" + esc(Calc.fMes(r.JANELA_INI)) + " a " + esc(Calc.fMes(r.JANELA_FIM)) + "</b> (" + esc(est.cfg.MESES_MEDIA) + " meses completos" +
        (est.cfg.MES_PARCIAL === 1 ? " + mês corrente proporcional " + esc(fP(r.FRAC_PARCIAL, 0)) : "; mês corrente fora") + ", média " +
        (est.cfg.MEDIA_MODO === 1 ? "ponderada" : "simples") + ")");
    }
    partes.push("Fluxo de OC: <b>" + esc(fData(est.dtIni)) + " a " + esc(fData(est.dtFim)) + "</b>");
    partes.push("Parâmetros: <b>" + (est.tabelaParams === "OK" ? "BI_PARAM_COMPRA + padrões" : "padrões do código") + "</b> (não aprovados)");
    $("contexto").innerHTML = partes.join(" · ");
  }

  /* ================================================================ VISÃO GERAL */
  function totaisResumo(l) {
    var t = { porPrio: {} }, campos = ["N_SKUS", "N_FALTA_ATUAL", "VLR_FALTA_ATUAL", "N_FALTA_SEM_PRECO", "N_NEC", "VLR_NEC_NAO_SOLIC", "N_NEC_SEM_PRECO",
      "N_NEC_OC_NAO_CONF", "N_NEC_COTACAO", "N_FALTA_ANTES_RECEB", "N_HIST_INSUF", "N_UN_NAO_CONC", "N_SEM_PRECO", "N_LT_PADRAO", "N_OC_ATRAS",
      "N_OC_SEM_PREV", "N_OC_NAO_CONF", "N_OC_ANTIGA", "N_OC_TOP_SEP", "N_CONSIGNADO", "N_LOTE_INVALIDO", "N_CONSUMO_NEG", "N_SEM_CURVA"];
    campos.forEach(function (c) { t[c] = 0; });
    l.forEach(function (r) { t.porPrio[r.PRIORIDADE] = r; campos.forEach(function (c) { t[c] += num(r[c]) || 0; }); });
    t.cotacaoMapeada = l.length ? num(l[0].COTACAO_MAPEADA) === 1 : false;
    t.foraUniverso = l.length ? num(l[0].N_ATIVOS_FORA) : null;
    return t;
  }
  function blocos(l) {
    var b = {};
    l.forEach(function (r) { (b[r.BLOCO] = b[r.BLOCO] || []).push(r); });
    return b;
  }
  function somaBloco(lista, filtro, campo) {
    var s = 0;
    (lista || []).forEach(function (r) { if (!filtro || filtro(r)) s += num(r[campo]) || 0; });
    return s;
  }
  function indicadoresOC(bl) {
    var ab = bl.ABERTO || [], pt = bl.PONTUALIDADE || [];
    var itensAbertos = somaBloco(ab, null, "N_ITENS");
    var comPrev = somaBloco(ab, function (r) { return r.CHAVE2 !== "SEM_PREVISAO"; }, "N_ITENS");
    var atras = somaBloco(ab, function (r) { return r.CHAVE2 === "ATRASADA"; }, "N_ITENS");
    var semPrev = somaBloco(ab, function (r) { return r.CHAVE2 === "SEM_PREVISAO"; }, "N_ITENS");
    var excl = somaBloco(pt, function (r) { return r.CHAVE === "EXCLUIDO_SEM_DATA_CONFIAVEL"; }, "N_ITENS");
    var tot = somaBloco(pt, null, "N_ITENS"), noPrazo = somaBloco(pt, function (r) { return r.CHAVE === "INTEGRAL_NO_PRAZO"; }, "N_ITENS");
    return { itensAbertos: itensAbertos, comPrev: comPrev, atras: atras, semPrev: semPrev, pontTot: tot, pontExcl: excl, pontDen: tot - excl, pontNum: noPrazo,
      vlrConf: somaBloco(ab, function (r) { return r.CHAVE === "CONFIRMADA"; }, "VLR"),
      vlrNaoConf: somaBloco(ab, function (r) { return r.CHAVE !== "CONFIRMADA"; }, "VLR") };
  }
  function cardsOC(oc) {
    var h = "";
    h += kpi("Itens de OC com previsão vencida", oc.comPrev ? esc(fP(oc.atras / oc.comPrev)) : "—",
      esc(fN(oc.atras) + " de " + fN(oc.comPrev) + " itens abertos com previsão informada · " + fN(oc.semPrev) + " sem previsão (fora do denominador, prazo incerto)"),
      oc.atras ? "k-aviso" : "", "Itens de OC com saldo aberto cuja DTPREVENT é anterior à data-base, dividido pelos itens abertos com DTPREVENT. Previsão estimada por lead time não é usada.");
    h += kpi("Atendimento integral até a previsão (aproximado, não é OTIF)", oc.pontDen ? esc(fP(oc.pontNum / oc.pontDen)) : "—",
      esc(fN(oc.pontNum) + " de " + fN(oc.pontDen) + " itens confirmados com previsão no período, já vencida · " + fN(oc.pontExcl) +
        " excluídos (atendidos sem data confiável) · tolerância " + est.cfg.TOLERANCIA_ATRASO_DIAS + " dia(s), não aprovada"), "",
      "Numerador: item com QTDENTREGUE ≥ QTDNEG e último documento derivado confirmado (TGFVAR) até a previsão + tolerância. Denominador: itens confirmados com DTPREVENT no período e anterior à data-base, menos os excluídos. Encerrado com saldo conta como não integral.");
    h += kpi("OTIF", indisp("vínculo insuficiente"), esc("Faltam: data de compromisso validada, quantidade por entrega vinculada à OC, regra de tolerância aprovada. Recebimento por OS + produto não comprova vínculo."), "indisp");
    return h;
  }
  function carregarExec() {
    var tk = seq.novo("exec");
    $("exec-kpis").innerHTML = carregando("Calculando indicadores…");
    $("exec-prio").innerHTML = carregando();
    $("exec-top").innerHTML = carregando();
    $("exec-qual").innerHTML = carregando();
    var pResumo = rodar("Q_RESUMO"), pCart = rodar("Q_CARTEIRA"), pPlano = rodar("Q_PLANO", { FILTRO_FILA: "ATENCAO" });
    pResumo.then(function (l) {
      if (!seq.valido("exec", tk)) return;
      est.resumo = l;
      renderContexto();
      var t = totaisResumo(l), p1 = t.porPrio.P1_CRITICO ? num(t.porPrio.P1_CRITICO.N_SKUS) : 0, p2 = t.porPrio.P2_RUPTURA_IMINENTE ? num(t.porPrio.P2_RUPTURA_IMINENTE.N_SKUS) : 0;
      var h = "";
      h += kpi("Itens críticos e com falta antes do lead time", esc(fN(p1 + p2)),
        esc("P1: " + fN(p1) + " · P2: " + fN(p2) + " · de " + fN(t.N_SKUS) + " empresa+produto no cálculo") , p1 ? "k-crit" : "",
        "P1 = estoque físico negativo ou sem cobertura física agora. P2 = falta estimada (consumo médio constante, só recebimentos confirmados com data futura) antes do lead time.");
      h += kpi("Falta atual estimada", esc(fRc(t.VLR_FALTA_ATUAL)),
        esc(fN(t.N_FALTA_ATUAL) + " itens com compromisso maior que o estoque") + (t.N_FALTA_SEM_PRECO ? " · <b>" + esc(fN(t.N_FALTA_SEM_PRECO)) + " sem preço (não valorizados)</b>" : ""),
        t.N_FALTA_ATUAL ? "k-crit" : "", "Σ max(0, compromisso − estoque utilizável) × preço de referência (última OC confirmada). É estimativa, não prejuízo comprovado.");
      h += kpi("Necessidade ainda não solicitada (estimativa)", esc(fRc(t.VLR_NEC_NAO_SOLIC)),
        esc(fN(t.N_NEC) + " itens") + (t.N_NEC_SEM_PRECO ? " · <b>" + esc(fN(t.N_NEC_SEM_PRECO)) + " sem preço</b>" : "") +
        " · " + esc(fN(t.N_NEC_OC_NAO_CONF)) + " com parte em OC não confirmada · cotação: " + (t.cotacaoMapeada ? esc(fN(t.N_NEC_COTACAO)) + " itens" : "<span class=\"indisp\">não mapeada</span>"),
        "", "Necessidade além do estoque e das OCs confirmadas, menos o que já está em OC não confirmada ou cotação, a preço de referência. Não é valor de compra aprovado.");
      h += kpi("Falta antes do próximo recebimento", esc(fN(t.N_FALTA_ANTES_RECEB)), "itens em que a OC confirmada chega depois da falta estimada (antecipar, não comprar de novo)",
        t.N_FALTA_ANTES_RECEB ? "k-aviso" : "", "Projeção com consumo médio constante e recebimentos confirmados com previsão futura, em ordem de data.");
      h += kpi("Aderência da sugestão e SLA de abertura", indisp("sem vínculo rastreável sugestão → OC"),
        esc("Proximidade de produto e data não comprova atendimento. Ver extensão necessária em PARAMETROS_A_APROVAR.md."), "indisp");
      h += "<span id=\"exec-kpis-oc\">" + carregando("Indicadores de OC…") + "</span>";
      $("exec-kpis").innerHTML = h;
      var itens = Calc.ORDEM_PRIORIDADE.filter(function (p) { return t.porPrio[p]; }).map(function (p) {
        var x = t.porPrio[p];
        return { rot: (Calc.SIMBOLO_PRIORIDADE[p] || "") + " " + Calc.ROTULO_PRIORIDADE[p], val: num(x.N_SKUS) || 0, cor: COR_PRIO[p],
          txt: fN(x.N_SKUS) + " itens" + (num(x.VLR_NEC_NAO_SOLIC) ? " · nec. " + fRc(x.VLR_NEC_NAO_SOLIC) : "") };
      });
      $("exec-prio").innerHTML = itens.length ? barras(itens, 250) : vazio("Nenhum item com estoque, consumo, compromisso ou OC.");
      $("exec-qual").innerHTML = qualidadeResumoHTML(t, null);
      $("exec-nota").innerHTML = esc("Totais sobre todos os itens do cálculo (sem limite de linhas). " +
        (t.foraUniverso !== null ? fN(t.foraUniverso) + " produtos ativos sem estoque, consumo, compromisso ou OC ficam fora do cálculo. " : "") +
        "Valores em R$ usam preço de referência, não custo contábil.");
      pCart.then(function (lc) {
        if (!seq.valido("exec", tk) || !$("exec-kpis-oc")) return;
        est.carteira = lc;
        $("exec-kpis-oc").outerHTML = cardsOC(indicadoresOC(blocos(lc)));
      }, function (e) { if (seq.valido("exec", tk) && $("exec-kpis-oc")) $("exec-kpis-oc").outerHTML = kpi("Indicadores de OC", "erro", erroHTML("Q_CARTEIRA", e), "falha"); });
    }, function (e) {
      if (!seq.valido("exec", tk)) return;
      $("exec-kpis").innerHTML = erroHTML("Falha no cálculo do resumo (Q_RESUMO)", e);
      $("exec-prio").innerHTML = ""; $("exec-qual").innerHTML = "";
    });
    pPlano.then(function (l) {
      if (!seq.valido("exec", tk)) return;
      var top = l.filter(function (r) { return r.PRIORIDADE === "P1_CRITICO" || r.PRIORIDADE === "P2_RUPTURA_IMINENTE"; }).slice(0, 15);
      if (!top.length) { $("exec-top").innerHTML = vazio("Nenhum item em P1 ou P2."); return; }
      var h = "<table><thead><tr><th>Prioridade</th><th>Produto</th><th>Por quê</th><th class=\"n\">Disponível</th><th>Falta estimada</th><th class=\"n\">Não solicitada</th></tr></thead><tbody>";
      top.forEach(function (r) {
        var m = motivoPrincipal(r);
        h += "<tr><td>" + chip(r.PRIORIDADE) + "</td><td class=\"prod\" title=\"" + esc(r.DESCRPROD) + "\">" + esc(r.CODPROD) + " · " + esc(r.DESCRPROD) +
          (est.codemp ? "" : " <span class=\"tag\">emp " + esc(r.CODEMP) + "</span>") + "</td><td>" + esc(m ? Calc.ROTULO_MOTIVO[m] || m : "—") +
          "</td><td class=\"n\">" + esc(fQ(r.DISPONIVEL)) + " " + esc(r.UNIDADE) + "</td><td>" + esc(r.DT_FALTA_EST ? fData(r.DT_FALTA_EST) : "—") +
          "</td><td class=\"n\">" + esc(fQ(r.NEC_NAO_SOLIC)) + "</td></tr>";
      });
      $("exec-top").innerHTML = h + "</tbody></table><div class=\"nota\">Os 15 primeiros da fila (ordem: prioridade, data estimada de falta, valor). Detalhe completo na aba Fila de análise.</div>";
    }, function (e) { if (seq.valido("exec", tk)) $("exec-top").innerHTML = erroHTML("Falha na fila (Q_PLANO)", e); });
  }

  function qualidadeResumoHTML(t, oc) {
    var linhas = [
      ["Política PRG/JIT", "não validada", "Sem classificador aprovado por item. SOLCOMPRA, AD_ABASTECIMENTO, AD_MRPTIPPAP e AD_CLIENTETPP não são usados."],
      ["Itens com unidade não conciliada", fN(t.N_UN_NAO_CONC), "Movimentos sem conversão confiável ficam fora das quantidades."],
      ["Itens sem preço de referência", fN(t.N_SEM_PRECO), "Sem preço não é custo zero: o valor não é estimado."],
      ["Itens com histórico insuficiente", fN(t.N_HIST_INSUF), "Produto novo na janela; média instável."],
      ["Itens com lead time padrão", fN(t.N_LT_PADRAO), "TGFPRO.LEADTIME vazio; usado LEADTIME_DEFAULT."],
      ["Itens com OC sem previsão", fN(t.N_OC_SEM_PREV), "Cobertura de prazo incerto, fora da projeção datada."],
      ["Itens com OC atrasada", fN(t.N_OC_ATRAS), "Previsão vencida: prazo incerto, não é tratada como pontual."],
      ["Itens com OC não confirmada", fN(t.N_OC_NAO_CONF), "Não conta como cobertura contratada."],
      ["Itens com OC antiga aberta", fN(t.N_OC_ANTIGA), "Continuam no cálculo; verificar se ainda vão chegar."],
      ["Itens sem curva ABC", fN(t.N_SEM_CURVA), est.cfg.ABC_CALCULADA === 1 ? "Curva calculada; sem curva = sem preço ou sem valor." : "Sem fonte validada de curva: cobertura de fallback COBERTURA_SEM_CURVA (a aprovar)."],
      ["Consignados sem cálculo", fN(t.N_CONSIGNADO), "Regra herdada do painel antigo (CODPARCCONSIG > 0)."]
    ];
    if (t.N_LOTE_INVALIDO) linhas.push(["Lote/múltiplo negativo no cadastro", fN(t.N_LOTE_INVALIDO), "Ignorado no arredondamento."]);
    if (t.N_CONSUMO_NEG) linhas.push(["Consumo líquido negativo", fN(t.N_CONSUMO_NEG), "Devoluções maiores que saídas; média tratada como zero."]);
    var h = "<table><thead><tr><th>Ponto</th><th class=\"n\">Quantidade</th><th>Efeito</th></tr></thead><tbody>";
    linhas.forEach(function (l) { h += "<tr><td>" + esc(l[0]) + "</td><td class=\"n\">" + esc(l[1]) + "</td><td style=\"white-space:normal\">" + esc(l[2]) + "</td></tr>"; });
    return h + "</tbody></table>";
  }

  /* ================================================================ FILA */
  var COLS_FILA = [
    ["PRIORIDADE", "Prioridade"], ["MOTIVO", "Por quê"], ["CODPROD", "Produto"], ["QTD_ESTOQUE", "Estoque físico", "n"], ["CMP", "Compromissos", "n"],
    ["DISPONIVEL", "Disponível", "n"], ["QTD_OC_CONF", "OC confirmada", "n"], ["QTD_OC_NAO_CONF", "OC não conf.", "n"], ["DD", "Demanda/dia", "n"],
    ["COB_FISICA_DIAS", "Cobertura física (dias)", "n"], ["DT_FALTA_EST", "Falta estimada"], ["NEC_NAO_SOLIC", "Não solicitada", "n"],
    ["VLR_NEC_NAO_SOLIC", "R$ estimado", "n"], ["QUAL", "Qualidade"]
  ];
  function carregarFila() {
    var tk = seq.novo("fila");
    $("fila-tab").innerHTML = carregando("Calculando a fila…");
    $("fila-resumo").innerHTML = "";
    rodar("Q_PLANO", { FILTRO_FILA: est.filaUniverso }).then(function (l) {
      if (!seq.valido("fila", tk)) return;
      est.fila = l;
      est.ordFila = null;
      opcoes("ff-prio", Calc.ORDEM_PRIORIDADE.filter(function (p) { return l.some(function (r) { return r.PRIORIDADE === p; }); }), "todas", function (p) { return Calc.ROTULO_PRIORIDADE[p]; });
      var ms = {};
      l.forEach(function (r) { Calc.motivos(r.MOTIVOS).forEach(function (m) { ms[m] = 1; }); });
      opcoes("ff-motivo", Object.keys(ms).sort(), "todos", function (m) { return Calc.ROTULO_MOTIVO[m] || m; });
      opcoes("ff-grupo", distintos(l, grupoDe), "todos");
      renderFila();
    }, function (e) { if (seq.valido("fila", tk)) { est.fila = []; $("fila-tab").innerHTML = erroHTML("Falha na fila (Q_PLANO)", e); } });
  }
  function opcoes(sel, valores, rotTodos, rotulo) {
    var atual = $(sel).value;
    var h = "<option value=\"\">" + esc(rotTodos) + "</option>";
    valores.forEach(function (v) { h += "<option value=\"" + esc(v) + "\">" + esc(rotulo ? rotulo(v) : v) + "</option>"; });
    $(sel).innerHTML = h;
    if (valores.indexOf(atual) >= 0) $(sel).value = atual;
  }
  function distintos(l, f) {
    var v = {}, out = [];
    l.forEach(function (r) { var x = f(r); if (!Object.prototype.hasOwnProperty.call(v, x)) { v[x] = 1; out.push(x); } });
    return out.sort();
  }
  function grupoDe(r) { return r.GRUPO === null || r.GRUPO === undefined ? "(sem grupo)" : String(r.GRUPO) + (r.GRUPO_DESCR ? " · " + r.GRUPO_DESCR : ""); }
  function filaFiltrada() {
    var p = $("ff-prio").value, m = $("ff-motivo").value, g = $("ff-grupo").value, b = $("ff-busca").value.toUpperCase().replace(/^\s+|\s+$/g, "");
    var out = est.fila.filter(function (r) {
      if (p && r.PRIORIDADE !== p) return false;
      if (m && Calc.motivos(r.MOTIVOS).indexOf(m) < 0) return false;
      if (g && grupoDe(r) !== g) return false;
      if (b && (String(r.CODPROD) + " " + String(r.DESCRPROD || "")).toUpperCase().indexOf(b) < 0) return false;
      return true;
    });
    if (est.ordFila) out = ordenar(out, est.ordFila.col, est.ordFila.desc);
    return out;
  }
  function renderFila() {
    var l = filaFiltrada(), total = est.fila.length ? num(est.fila[0].TOTAL_LINHAS) : 0;
    est.filaVisivel = l;
    var trunc = total > est.fila.length;
    $("fila-resumo").innerHTML = (trunc ? "<b class=\"pos\">Lista truncada:</b> " : "") + esc(fN(total) + " itens no universo “" + $("ff-universo").options[$("ff-universo").selectedIndex].text +
      "” · " + fN(est.fila.length) + " carregados" + (trunc ? " (limite " + fN(CONFIG.limites.LIMITE_FILA) + ")" : "") + " · " + fN(l.length) + " após filtros de tela") +
      (trunc ? "<br><span class=\"nota\">Filtros de tela, ordenação e exportação valem só para as linhas carregadas. Os totais da Visão geral consideram todos os itens.</span>" : "");
    if (!est.fila.length) { $("fila-tab").innerHTML = vazio("Nenhum item neste universo."); return; }
    if (!l.length) { $("fila-tab").innerHTML = vazio("Nenhum item com estes filtros de tela."); return; }
    var h = "<table><thead><tr>";
    COLS_FILA.forEach(function (c) { h += c[0] === "MOTIVO" || c[0] === "QUAL" ? "<th>" + esc(c[1]) + "</th>" : th(c[0], c[1], c[2], est.ordFila); });
    h += "</tr></thead><tbody>";
    l.forEach(function (r, i) {
      var m = motivoPrincipal(r), nm = Calc.motivos(r.MOTIVOS).filter(function (x) { return Calc.MOTIVOS_DECISAO.indexOf(x) >= 0; }).length;
      h += "<tr class=\"lin\" tabindex=\"0\" data-i=\"" + i + "\"><td>" + chip(r.PRIORIDADE) + "</td><td style=\"white-space:normal;min-width:180px\">" +
        esc(m ? Calc.ROTULO_MOTIVO[m] || m : "—") + (nm > 1 ? " <span class=\"tag\">+" + (nm - 1) + "</span>" : "") + "</td>" +
        "<td class=\"prod\" title=\"" + esc(r.DESCRPROD) + "\">" + esc(r.CODPROD) + " · " + esc(r.DESCRPROD) + " <span class=\"nota\">(" + esc(r.UNIDADE) + ")</span>" +
        (est.codemp ? "" : " <span class=\"tag\">emp " + esc(r.CODEMP) + "</span>") + "</td>" +
        "<td class=\"n\">" + esc(fQ(r.QTD_ESTOQUE)) + "</td><td class=\"n\">" + esc(fQ(r.CMP)) + "</td><td class=\"n\">" + esc(fQ(r.DISPONIVEL)) + "</td>" +
        "<td class=\"n\">" + esc(fQ(r.QTD_OC_CONF)) + "</td><td class=\"n\">" + esc(fQ(r.QTD_OC_NAO_CONF)) + "</td>" +
        "<td class=\"n\">" + esc(fN(r.DD, 2)) + "</td><td class=\"n\">" + (r.COB_FISICA_DIAS === null ? "<span title=\"Sem demanda nem compromisso\">sem demanda</span>" : esc(fN(r.COB_FISICA_DIAS, 1))) + "</td>" +
        "<td>" + (r.DT_FALTA_EST ? esc(fData(r.DT_FALTA_EST)) + " <span class=\"nota\">estim.</span>" : (r.T_FALTA_PROJ !== null ? "&gt; 10 anos" : "—")) + "</td>" +
        "<td class=\"n\"><b>" + esc(fQ(r.NEC_NAO_SOLIC)) + "</b></td><td class=\"n\">" + (r.PRECO_REF === null && num(r.NEC_NAO_SOLIC) > 0 ? "<span class=\"tag q\">sem preço</span>" : esc(fR(r.VLR_NEC_NAO_SOLIC))) + "</td>" +
        "<td>" + tagsQualidade(r) + "</td></tr>";
    });
    $("fila-tab").innerHTML = h + "</tbody></table>";
  }
  function dl(pares) {
    return "<dl>" + pares.map(function (p) { return "<dt>" + esc(p[0]) + "</dt><dd" + (p[2] ? " class=\"txt\"" : "") + ">" + (p[3] ? p[1] : esc(p[1])) + "</dd>"; }).join("") + "</dl>";
  }
  function detalheProduto(r) {
    var un = r.UNIDADE || "", q = function (v) { return fQ(v) + " " + un; };
    var regra = est.cfg.REGRA_PREVISAO_FIRME === 2 ? "SOMA (antiga)" : "MAIOR entre previsão e compromissos";
    var pol = est.cfg.POLITICA_SEGURANCA === 1 ? "fração do lead time (" + fP(est.cfg.SEGURANCA_PCT_LT, 0) + ", legado não aprovado)"
      : est.cfg.POLITICA_SEGURANCA === 2 ? "estoque mínimo do cadastro (TGFPRO.ESTMIN)" : "nenhuma";
    var ms = Calc.motivos(r.MOTIVOS);
    var h = "<div class=\"det-grid\">";
    h += "<div><h4>Situação</h4>" + chip(r.PRIORIDADE) + "<ul class=\"lista-motivos\">" +
      (ms.length ? ms.map(function (m) { return "<li>" + esc(Calc.ROTULO_MOTIVO[m] || m) + "</li>"; }).join("") : "<li>Sem alerta</li>") + "</ul>" +
      "<div class=\"nota\">Política PRG/JIT: <b>não validada</b>. Esta linha é análise, não autorização de compra.</div></div>";
    h += "<div><h4>Estoque e compromissos</h4>" + dl([
      ["Estoque físico (TGFEST, locais excluídos " + (CONFIG.locaisExcluidos.join(", ") || "nenhum") + ")", q(r.QTD_ESTOQUE)],
      ["Bloqueado WMS " + (est.cfg.DESCONTA_BLOQUEADO === 1 ? "(descontado)" : "(não descontado)"), q(r.QTD_BLOQUEADO)],
      ["Estoque utilizável", q(r.EFP)],
      ["Pedidos pendentes (TOPs de empenho)", q(r.QTD_PEDIDOS)],
      ["Reservado (TGFEST.RESERVADO)", q(r.QTD_RESERVADO)],
      ["Compromisso usado (" + (est.cfg.FONTE_COMPROMISSO === 2 ? "RESERVADO" : "pedidos") + "; a outra fonte só informa)", q(r.CMP)],
      ["Conferida dos pedidos (só informa)", q(r.QTD_CONFERIDA)],
      ["Disponível = utilizável − compromisso", q(r.DISPONIVEL)]
    ]) + "</div>";
    h += "<div><h4>Demanda</h4>" + dl([
      ["Série", ROT_SERIE[r.ORIGEM_SERIE] || r.ORIGEM_SERIE, 1],
      ["1º consumo no horizonte", fData(r.DT_PRIM_CONSUMO)],
      ["Meses considerados (divisor)", fN(r.N_MESES) + (num(r.FRAC_USADA) ? " + " + fN(r.FRAC_USADA, 2) + " (mês corrente)" : "")],
      ["Consumo líquido nos meses da série", q(r.QTD_JANELA)],
      ["Média simples / ponderada", fQ(r.MEDIA_SIMPLES) + " / " + fQ(r.MEDIA_PONDERADA)],
      ["Média usada (" + (est.cfg.MEDIA_MODO === 1 ? "ponderada" : "simples") + ")", q(r.MEDIA_USADA) + "/mês"],
      ["Demanda diária (÷ " + fN(est.cfg.DIAS_MES, 2) + ")", fN(r.DD, 4)]
    ]) + "</div>";
    h += "<div><h4>Política de cobertura (parâmetros não aprovados)</h4>" + dl([
      ["Lead time", fN(r.LT) + " dias" + (num(r.FL_LT_PADRAO) ? " (padrão)" : " (cadastro)")],
      ["Curva / cobertura alvo", (r.CURVA ? "Curva " + r.CURVA + " (calculada)" : "Sem curva (fallback)") + " · " + fN(r.COB_ALVO) + " dias"],
      ["Segurança: " + pol, q(r.EST_SEG)],
      ["Regra de demanda", regra, 1],
      ["Ponto de pedido = demanda no LT + segurança", q(r.PONTO_PEDIDO)],
      ["Requisito no horizonte (LT + cobertura) + segurança", q(r.REQUISITO)],
      ["Cenário SOMA / MAIOR", q(r.REQUISITO_SOMA) + " / " + q(r.REQUISITO_MAIOR)]
    ]) + "<div class=\"nota\">A segurança entra uma única vez: no ponto de pedido e no requisito. Sem ela o requisito seria " + esc(q(num(r.REQUISITO) - num(r.EST_SEG))) + ".</div></div>";
    h += "<div><h4>Suprimento</h4>" + dl([
      ["OC confirmada — previsão futura", q(r.QTD_OC_CONF_PRAZO)],
      ["OC confirmada — previsão vencida (prazo incerto)", q(r.QTD_OC_CONF_ATRAS)],
      ["OC confirmada — sem previsão (prazo incerto)", q(r.QTD_OC_CONF_SEMPREV)],
      ["OC não confirmada / aprovação não determinada", q(r.QTD_OC_NAO_CONF)],
      ["Cotação em aberto", r.QTD_COTACAO === null ? "<span class=\"indisp\">não mapeada</span>" : esc(q(r.QTD_COTACAO)), 0, 1],
      ["Próximo recebimento confirmado", r.DT_PROX_RECEB ? fData(r.DT_PROX_RECEB) + " · " + q(r.QTD_PROX_RECEB) : "—"],
      ["OCs abertas", fN(r.N_OCS_ABERTAS) + (num(r.N_OC_TOP_SEP) ? " (" + fN(r.N_OC_TOP_SEP) + " itens em TOP de preço separado)" : "")]
    ]) + "</div>";
    h += "<div><h4>Cobertura (estimativa agregada)</h4>" + dl([
      ["Física", r.COB_FISICA_DIAS === null ? "sem demanda" : fN(r.COB_FISICA_DIAS, 1) + " dias"],
      ["Com OC confirmada (todas)", r.COB_CONTRAT_DIAS === null ? "sem demanda" : fN(r.COB_CONTRAT_DIAS, 1) + " dias"],
      ["Falta estimada em", r.DT_FALTA_EST ? fData(r.DT_FALTA_EST) : (r.T_FALTA_PROJ !== null ? "> 10 anos" : "sem falta prevista")],
      ["Falta antes do recebimento de", r.FL_FALTA_ANTES_RECEB === 1 ? fData(r.DT_RECEB_APOS_FALTA) + " · " + q(r.QTD_FALTA_ANTES_RECEB) + " em risco" : "não"]
    ]) + "<div class=\"nota\">Consumo médio constante; só recebimentos confirmados com previsão futura entram na projeção datada. Não é data garantida.</div></div>";
    var lote = r.QTD_ARRED === null
      ? ["Lote/múltiplo do cadastro", fQ(r.LOTEMIN) + " / " + fQ(r.AGRUPMIN) + " (não aplicado: unidade não comprovada)"]
      : ["Com lote " + fQ(r.LOTEMIN) + " e múltiplo " + fQ(r.AGRUPMIN), q(r.QTD_ARRED) + " (excesso do arredondamento " + q(r.EXCESSO_ARRED) + ")"];
    h += "<div><h4>Necessidade</h4>" + dl([
      ["Além de estoque + OC confirmada", q(r.NEC_BRUTA)],
      ["− já em OC não confirmada", q(r.NEC_EM_OC_NAO_CONF)],
      ["− em cotação", r.NEC_EM_COTACAO === null ? "<span class=\"indisp\">não mapeada</span>" : esc(q(r.NEC_EM_COTACAO)), 0, 1],
      ["= ainda não solicitada", "<b>" + esc(q(r.NEC_NAO_SOLIC)) + "</b>", 0, 1],
      ["Cenário SOMA / MAIOR", q(r.NEC_SOMA) + " / " + q(r.NEC_MAIOR)],
      lote
    ]) + "</div>";
    h += "<div><h4>Preço de referência (não é custo)</h4>" + dl([
      ["Por " + un, r.PRECO_REF === null ? "<span class=\"indisp\">sem referência</span>" : esc(fR(r.PRECO_REF)), 0, 1],
      ["Origem", r.PRECO_REF === null ? "—" : "OC " + r.PRECO_REF_NUNOTA + " · TOP " + r.PRECO_REF_TOP + " · " + fData(r.PRECO_REF_DATA)],
      ["TOP de preço separado", r.PRECO_SEP === null ? "—" : fR(r.PRECO_SEP) + " · " + fData(r.PRECO_SEP_DATA)],
      ["Necessidade não solicitada (R$)", r.VLR_NEC_NAO_SOLIC === null ? "não estimada" : fR(r.VLR_NEC_NAO_SOLIC)]
    ]) + "</div>";
    h += "<div><h4>Qualidade</h4>" + dl([
      ["Itens não conciliados: consumo / pedidos / OC / cotação", fN(r.N_CONS_NAO_CONC) + " / " + fN(r.N_PED_NAO_CONC) + " / " + fN(r.N_OC_NAO_CONC) + " / " + fN(r.N_COT_NAO_CONC)],
      ["Estoque mínimo do cadastro", fQ(r.ESTMIN_CAD)],
      ["Código antigo", CONFIG.codigoAntigoHabilitado ? (r.COD_ANTIGO || "—") + " (só exibido, sem consolidar histórico)" : "não habilitado"]
    ]) + "</div></div>";
    var sufixo = esc(r.CODEMP + "-" + r.CODPROD);
    h += "<div class=\"ctl\" style=\"margin-top:8px\"><button type=\"button\" class=\"sec\" data-acao=\"ocs-prod\" data-codprod=\"" + esc(r.CODPROD) + "\" data-alvo=\"dpo-" + sufixo + "\">OCs abertas do produto</button>" +
      "<button type=\"button\" class=\"sec\" data-acao=\"cons-prod\" data-codprod=\"" + esc(r.CODPROD) + "\" data-alvo=\"dpc-" + sufixo + "\">Consumo mensal do produto</button></div>" +
      "<div id=\"dpo-" + sufixo + "\"></div><div id=\"dpc-" + sufixo + "\"></div>";
    return h;
  }
  function alternarDetalhe(tr, conteudoFn, ncols) {
    var prox = tr.nextSibling;
    if (prox && prox.className === "det") { prox.parentNode.removeChild(prox); tr.className = "lin"; return; }
    var det = document.createElement("tr");
    det.className = "det";
    det.innerHTML = "<td colspan=\"" + ncols + "\"><div class=\"det-box\">" + conteudoFn() + "</div></td>";
    tr.parentNode.insertBefore(det, tr.nextSibling);
    tr.className = "lin aberta";
  }
  var COLS_CSV_FILA = [
    ["PRIORIDADE", "Prioridade"], [function (r) { var m = motivoPrincipal(r); return m ? Calc.ROTULO_MOTIVO[m] || m : ""; }, "Motivo principal"], ["MOTIVOS", "Motivos (codigos)"],
    ["POLITICA", "Politica PRG/JIT"], ["CODEMP", "Empresa"], ["CODPROD", "Codigo"], ["DESCRPROD", "Produto"], ["UNIDADE", "Unidade padrao"], ["GRUPO", "Grupo"], ["GRUPO_DESCR", "Grupo descricao"],
    ["CURVA", "Curva"], ["QTD_ESTOQUE", "Estoque fisico", "auto"], ["QTD_BLOQUEADO", "Bloqueado WMS", "auto"], ["QTD_RESERVADO", "Reservado", "auto"], ["QTD_PEDIDOS", "Pedidos pendentes", "auto"],
    ["CMP", "Compromisso usado", "auto"], ["DISPONIVEL", "Disponivel", "auto"], ["ORIGEM_SERIE", "Serie"], ["N_MESES", "Meses (divisor)", "auto"], ["MEDIA_USADA", "Media mensal usada", "auto"],
    ["DD", "Demanda diaria", "auto"], ["LT", "Lead time", "auto"], ["COB_ALVO", "Cobertura alvo", "auto"], ["EST_SEG", "Estoque de seguranca", "auto"], ["PONTO_PEDIDO", "Ponto de pedido", "auto"],
    ["REQUISITO", "Requisito", "auto"], ["QTD_OC_CONF", "OC confirmada", "auto"], ["QTD_OC_CONF_ATRAS", "OC confirmada atrasada", "auto"], ["QTD_OC_CONF_SEMPREV", "OC confirmada sem previsao", "auto"],
    ["QTD_OC_NAO_CONF", "OC nao confirmada", "auto"], ["QTD_COTACAO", "Cotacao", "auto"], ["COB_FISICA_DIAS", "Cobertura fisica dias", "auto"], ["COB_CONTRAT_DIAS", "Cobertura com OC dias", "auto"],
    ["DT_FALTA_EST", "Falta estimada (data)"], ["FL_FALTA_ANTES_RECEB", "Falta antes do recebimento (1=sim)", "auto"], ["NEC_BRUTA", "Necessidade bruta", "auto"],
    ["NEC_EM_OC_NAO_CONF", "Em OC nao confirmada", "auto"], ["NEC_EM_COTACAO", "Em cotacao", "auto"], ["NEC_NAO_SOLIC", "Nao solicitada", "auto"], ["NEC_SOMA", "Cenario SOMA", "auto"],
    ["NEC_MAIOR", "Cenario MAIOR", "auto"], ["QTD_ARRED", "Com lote/multiplo", "auto"], ["PRECO_REF", "Preco referencia", "auto"], ["PRECO_REF_DATA", "Data preco"],
    ["VLR_NEC_NAO_SOLIC", "R$ nao solicitada (estimativa)", "auto"], ["VLR_FALTA_ATUAL", "R$ falta atual (estimativa)", "auto"], ["N_NAO_CONC", "Itens unidade nao conciliada", "auto"]
  ];

  /* ================================================================ CARTEIRA */
  function carregarCarteira() {
    var tk = seq.novo("carteira");
    ["cart-kpis", "cart-funil", "cart-aging", "cart-vinculo", "cart-qual", "cart-naocobre"].forEach(function (id) { $(id).innerHTML = carregando(); });
    rodar("Q_CARTEIRA").then(function (l) {
      if (!seq.valido("carteira", tk)) return;
      est.carteira = l;
      var b = blocos(l), oc = indicadoresOC(b);
      $("cart-kpis").innerHTML =
        kpi("Saldo aberto em OC confirmada", esc(fRc(oc.vlrConf)), "valor do saldo pelo VLRTOT proporcional; " + esc(fN(oc.itensAbertos)) + " itens abertos no total", "",
          "Σ VLRTOT × (QTDNEG − QTDENTREGUE) ÷ QTDNEG dos itens abertos confirmados. Não depende de conversão de unidade.") +
        kpi("Saldo aberto não confirmado", esc(fRc(oc.vlrNaoConf)), "não confirmada ou aprovação não determinada: não é fornecimento contratado", oc.vlrNaoConf ? "k-aviso" : "") +
        cardsOC(oc);
      $("cart-funil").innerHTML = funilHTML(b.FUNIL || []);
      var faixas = { "1_0_15": "0–15 dias", "2_16_30": "16–30 dias", "3_31_60": "31–60 dias", "4_61_180": "61–180 dias", "5_181_MAIS": "mais de 180 dias" };
      var ag = (b.AGING || []).map(function (r) { return { rot: faixas[r.CHAVE] || r.CHAVE, val: num(r.VLR) || 0, txt: fRc(r.VLR) + " · " + fN(r.N_ITENS) + " itens" }; });
      $("cart-aging").innerHTML = ag.length ? barras(ag, 140) + "<div class=\"nota\">Idade = data-base − data da OC. OCs antigas continuam no cálculo de cobertura e são sinalizadas.</div>" : vazio("Nenhum item de OC com saldo aberto.");
      var vc = b.VINCULO || [];
      $("cart-vinculo").innerHTML = vc.length ? "<table><thead><tr><th>Vínculo</th><th class=\"n\">Itens</th><th class=\"n\">OCs</th></tr></thead><tbody>" +
        vc.map(function (r) { return "<tr><td>" + esc(ROT_VINC[r.CHAVE] || r.CHAVE) + "</td><td class=\"n\">" + esc(fN(r.N_ITENS)) + "</td><td class=\"n\">" + esc(fN(r.N_OCS)) + "</td></tr>"; }).join("") +
        "</tbody></table><div class=\"nota\">Só TGFVAR é vínculo nativo. O casamento por OS + produto reproduz a lógica da customização e pode atribuir a mesma entrada a várias OCs: é mostrado, nunca somado como recebimento.</div>"
        : vazio("Nenhum item com atendimento registrado no período.");
      var ql = b.QUALIDADE || [];
      $("cart-qual").innerHTML = ql.length ? "<table><thead><tr><th>Alerta</th><th class=\"n\">Itens</th><th class=\"n\">OCs</th></tr></thead><tbody>" +
        ql.map(function (r) { return "<tr><td style=\"white-space:normal\">" + esc(ROT_QUAL_OC[r.CHAVE] || r.CHAVE) + "</td><td class=\"n\">" + esc(fN(r.N_ITENS)) + "</td><td class=\"n\">" + esc(fN(r.N_OCS)) + "</td></tr>"; }).join("") +
        "</tbody></table>" : vazio("Nenhum alerta.");
    }, function (e) {
      if (!seq.valido("carteira", tk)) return;
      $("cart-kpis").innerHTML = erroHTML("Falha nos indicadores de OC (Q_CARTEIRA)", e);
      ["cart-funil", "cart-aging", "cart-vinculo", "cart-qual"].forEach(function (id) { $(id).innerHTML = ""; });
    });
    rodar("Q_PLANO", { FILTRO_FILA: "ATENCAO" }).then(function (l) {
      if (!seq.valido("carteira", tk)) return;
      var nc = l.filter(function (r) { return num(r.N_OCS_ABERTAS) > 0 && num(r.NEC_NAO_SOLIC) > 0; });
      nc = ordenar(nc, "VLR_NEC_NAO_SOLIC", true);
      var trunc = l.length && num(l[0].TOTAL_LINHAS) > l.length;
      if (!nc.length) { $("cart-naocobre").innerHTML = vazio("Nenhum produto com OC aberta e necessidade ainda não solicitada" + (trunc ? " entre as linhas carregadas." : ".")); return; }
      var h = "<div class=\"resumo\">" + esc(fN(nc.length) + " itens têm OC aberta e ainda precisam de solicitação adicional" + (trunc ? " (entre as " + fN(l.length) + " linhas carregadas; fila truncada)" : "")) + "</div>";
      h += "<div class=\"tabwrap\" style=\"max-height:40vh\"><table><thead><tr><th>Prioridade</th><th>Produto</th><th class=\"n\">OC confirmada</th><th class=\"n\">OC não conf.</th><th class=\"n\">Ainda não solicitada</th><th class=\"n\">R$ estimado</th><th class=\"n\">OCs</th></tr></thead><tbody>";
      nc.slice(0, 100).forEach(function (r) {
        h += "<tr><td>" + chip(r.PRIORIDADE) + "</td><td class=\"prod\">" + esc(r.CODPROD) + " · " + esc(r.DESCRPROD) + "</td><td class=\"n\">" + esc(fQ(r.QTD_OC_CONF)) + " " + esc(r.UNIDADE) +
          "</td><td class=\"n\">" + esc(fQ(r.QTD_OC_NAO_CONF)) + "</td><td class=\"n\"><b>" + esc(fQ(r.NEC_NAO_SOLIC)) + "</b></td><td class=\"n\">" + esc(fR(r.VLR_NEC_NAO_SOLIC)) +
          "</td><td class=\"n\">" + esc(fN(r.N_OCS_ABERTAS)) + "</td></tr>";
      });
      $("cart-naocobre").innerHTML = h + "</tbody></table></div>";
    }, function (e) { if (seq.valido("carteira", tk)) $("cart-naocobre").innerHTML = erroHTML("Falha na necessidade (Q_PLANO)", e); });
    carregarOcLista();
  }
  function funilHTML(f) {
    function soma(fn) { var s = 0, v = 0; f.forEach(function (r) { if (fn(r)) { s += num(r.N_ITENS) || 0; v += num(r.VLR) || 0; } }); return { n: s, v: v }; }
    var criados = soma(function (r) { return r.CHAVE !== "CANCELADA"; });
    var etapas = [
      { rot: "1 · Sugestão gerada", ind: "sem snapshot com vínculo rastreável" },
      { rot: "2 · Itens de OC criados (não cancelados)", x: criados },
      { rot: "3 · Confirmados (STATUSNOTA = L, sem liberação pendente)", x: soma(function (r) { return r.CHAVE !== "CANCELADA" && r.CHAVE2 === "CONFIRMADA"; }) },
      { rot: "4 · Enviados ao fornecedor", ind: "sem registro mapeado no Sankhya" },
      { rot: "5 · Em produção / OS", ind: "sem integração com o eCalc" },
      { rot: "6 · Com algum atendimento registrado", x: soma(function (r) { return ["ATENDIMENTO_PARCIAL", "ATENDIDA_INTEGRAL", "ENCERRADA_COM_SALDO"].indexOf(r.CHAVE) >= 0; }) },
      { rot: "7 · Atendidos integralmente (registro)", x: soma(function (r) { return r.CHAVE === "ATENDIDA_INTEGRAL"; }) }
    ];
    if (!f.length) return vazio("Nenhum item de OC negociado no período.");
    var base = criados.n || 1, h = "<div class=\"funil\">";
    etapas.forEach(function (e) {
      if (e.ind) { h += "<div class=\"et\"><div>" + esc(e.rot) + "</div><div>" + indisp(e.ind) + "</div><div></div></div>"; return; }
      var pct = 100 * e.x.n / base;
      h += "<div class=\"et\"><div>" + esc(e.rot) + "</div><div><div class=\"bx\" style=\"width:" + Math.max(0.5, Math.min(100, pct)).toFixed(1) + "%\"></div></div><div>" +
        esc(fN(e.x.n) + " itens · " + fRc(e.x.v) + " · " + fP(e.x.n / base, 0)) + "</div></div>";
    });
    var fora = ["CANCELADA", "ENCERRADA_SEM_ATENDIMENTO", "ENCERRADA_COM_SALDO"].map(function (k) {
      var s = soma(function (r) { return r.CHAVE === k; });
      return s.n ? ROT_STATUS_ITEM[k] + ": " + fN(s.n) + " itens" : null;
    }).filter(function (x) { return x; });
    return h + "</div><div class=\"nota\">Grão: item de OC negociado de " + esc(fData(est.dtIni)) + " a " + esc(fData(est.dtFim)) + ". Produção não é recebimento; encerramento não é recebimento integral." +
      (fora.length ? "<br>" + esc(fora.join(" · ")) : "") + "</div>";
  }
  var COLS_OC = [["NUNOTA", "OC/item"], ["CODPROD", "Produto"], ["FORNECEDOR", "Fornecedor"], ["SALDO_BASE", "Saldo (un. padrão)", "n"], ["VLR_SALDO", "R$ saldo", "n"],
    ["DT_PREV", "Previsão"], ["DIAS_ATRASO", "Atraso (dias)", "n"], ["SITUACAO", "Situação"], ["QUALIDADE_VINC", "Vínculo"], ["IDADE_DIAS", "Idade (dias)", "n"]];
  function carregarOcLista() {
    var tk = seq.novo("oclista");
    $("oc-tab").innerHTML = carregando("Consultando itens de OC…");
    $("oc-resumo").innerHTML = "";
    rodar("Q_OC_LISTA", { FILTRO_OC: est.ocFiltro }).then(function (l) {
      if (!seq.valido("oclista", tk)) return;
      est.oc = l; est.ordOc = null;
      renderOc();
    }, function (e) { if (seq.valido("oclista", tk)) { est.oc = []; $("oc-tab").innerHTML = erroHTML("Falha na lista de OC (Q_OC_LISTA)", e); } });
  }
  function ocFiltrada() {
    var b = $("fo-busca").value.toUpperCase().replace(/^\s+|\s+$/g, "");
    var l = est.oc.filter(function (r) {
      return !b || (String(r.NUNOTA) + " " + r.CODPROD + " " + (r.DESCRPROD || "") + " " + (r.FORNECEDOR || "")).toUpperCase().indexOf(b) >= 0;
    });
    return est.ordOc ? ordenar(l, est.ordOc.col, est.ordOc.desc) : l;
  }
  function renderOc() {
    var l = ocFiltrada(), total = est.oc.length ? num(est.oc[0].TOTAL_LINHAS) : 0;
    est.ocVisivel = l;
    var trunc = total > est.oc.length;
    $("oc-resumo").innerHTML = (trunc ? "<b class=\"pos\">Lista truncada:</b> " : "") + esc(fN(total) + " itens no recorte · saldo " + fR(est.oc.length ? est.oc[0].TOTAL_VLR_SALDO : 0) +
      " · " + fN(est.oc.length) + " carregados" + (trunc ? " (limite " + fN(CONFIG.limites.LIMITE_OC) + ")" : "") + " · " + fN(l.length) + " após a busca");
    if (!est.oc.length) { $("oc-tab").innerHTML = vazio("Nenhum item de OC aberto neste recorte."); return; }
    if (!l.length) { $("oc-tab").innerHTML = vazio("Nenhum item com esta busca."); return; }
    var h = "<table><thead><tr>";
    COLS_OC.forEach(function (c) { h += th(c[0], c[1], c[2], est.ordOc); });
    h += "</tr></thead><tbody>";
    l.forEach(function (r, i) {
      h += "<tr class=\"lin\" tabindex=\"0\" data-i=\"" + i + "\"><td>" + esc(r.NUNOTA) + "/" + esc(r.SEQUENCIA) + (r.GRUPO_PRECO === "SEPARADO" ? " <span class=\"tag\">TOP " + esc(r.CODTIPOPER) + "</span>" : "") + "</td>" +
        "<td class=\"prod\" title=\"" + esc(r.DESCRPROD) + "\">" + esc(r.CODPROD) + " · " + esc(r.DESCRPROD) + "</td><td class=\"prod\">" + esc(r.FORNECEDOR || "—") + "</td>" +
        "<td class=\"n\">" + (r.SALDO_BASE === null ? "<span class=\"tag q\" title=\"" + esc("Unidade " + r.UNID_ITEM + " sem conversão confiável (" + r.STATUS_CONV + ")") + "\">não conciliada: " + esc(fQ(r.SALDO_ORIG) + " " + (r.UNID_ITEM || "")) + "</span>"
          : esc(fQ(r.SALDO_BASE) + " " + (r.UNID_PADRAO || ""))) + "</td><td class=\"n\">" + esc(fR(r.VLR_SALDO)) + "</td>" +
        "<td>" + (r.DT_PREV ? esc(fData(r.DT_PREV)) : "<span class=\"tag q\">sem previsão</span>") + "</td><td class=\"n\">" + esc(r.DIAS_ATRASO === null ? "" : fN(r.DIAS_ATRASO)) + "</td>" +
        "<td>" + esc(ROT_SITUACAO[r.SITUACAO] || r.SITUACAO) + "</td><td style=\"white-space:normal;min-width:160px\">" + esc(ROT_VINC[r.QUALIDADE_VINC] || r.QUALIDADE_VINC) + "</td>" +
        "<td class=\"n\">" + esc(fN(r.IDADE_DIAS)) + (num(r.FL_ANTIGA) ? " <span class=\"tag q\">antiga</span>" : "") + "</td></tr>";
    });
    $("oc-tab").innerHTML = h + "</tbody></table>";
  }
  function detalheOC(r) {
    return "<div class=\"det-grid\"><div><h4>Comercial</h4>" + dl([
      ["TOP", r.CODTIPOPER + (r.DESCR_TOP ? " · " + r.DESCR_TOP : " (versão da TOP não encontrada)"), 1],
      ["STATUSNOTA", r.STATUSNOTA || "—"],
      ["Situação", ROT_SITUACAO[r.SITUACAO] || r.SITUACAO, 1],
      ["Liberações pendentes / reprovadas", fN(r.N_LIB_PEND) + " / " + fN(r.N_LIB_REPROV)],
      ["Data da OC", fData(r.DT_NEG)],
      ["Política (PRG/JIT)", "não validada"]
    ]) + "</div><div><h4>Quantidades</h4>" + dl([
      ["Negociado / atendido (" + (r.UNID_ITEM || "") + ")", fQ(r.QTDNEG) + " / " + fQ(r.QTDENT)],
      ["Saldo na unidade do item", fQ(r.SALDO_ORIG) + " " + (r.UNID_ITEM || "")],
      ["Conversão", r.STATUS_CONV + (r.FATOR === null ? "" : " · fator " + fN(r.FATOR, 4))],
      ["Saldo na unidade padrão", r.SALDO_BASE === null ? "não conciliado" : fQ(r.SALDO_BASE) + " " + (r.UNID_PADRAO || "")],
      ["Situação de entrega", ROT_STATUS_ITEM[r.STATUS_ITEM] || r.STATUS_ITEM, 1]
    ]) + "</div><div><h4>Prazo</h4>" + dl([
      ["Previsão informada (DTPREVENT)", r.DT_PREV ? fData(r.DT_PREV) : "sem previsão"],
      ["Estimativa OC + lead time (só informa)", fData(r.DT_PREV_ESTIMADA)],
      ["Prazo", ROT_PRAZO[r.PRAZO] || r.PRAZO],
      ["Data necessária", "não disponível (sem vínculo OC → demanda)"]
    ]) + "</div><div><h4>Recebimento e OS</h4>" + dl([
      ["OS informada", r.OS || "—"],
      ["Documentos derivados confirmados (TGFVAR)", fN(r.N_DERIV) + (r.DT_ULT_DERIV ? " · último em " + fData(r.DT_ULT_DERIV) : "")],
      ["Entradas por OS + produto", fN(r.N_ENT_OS) + (r.DT_ULT_ENT_OS ? " · última em " + fData(r.DT_ULT_ENT_OS) : "")],
      ["Mesma entrada casa com quantas OCs", num(r.MAX_OC_MESMA_ENT) > 1 ? fN(r.MAX_OC_MESMA_ENT) + " (não comprova vínculo)" : fN(r.MAX_OC_MESMA_ENT)],
      ["Qualidade do vínculo", ROT_VINC[r.QUALIDADE_VINC] || r.QUALIDADE_VINC, 1],
      ["Produção / situação da OS", "não disponível (sem integração eCalc)"]
    ]) + "</div></div>";
  }
  var COLS_CSV_OC = [["NUNOTA", "OC"], ["SEQUENCIA", "Item"], ["CODEMP", "Empresa"], ["CODTIPOPER", "TOP"], ["DESCR_TOP", "Descricao TOP"], ["GRUPO_PRECO", "Grupo de preco"],
    ["CODPARC", "Cod. fornecedor"], ["FORNECEDOR", "Fornecedor"], ["CODPROD", "Codigo"], ["DESCRPROD", "Produto"], ["UNID_ITEM", "Unidade item"], ["UNID_PADRAO", "Unidade padrao"],
    ["STATUS_CONV", "Conversao"], ["FATOR", "Fator", "auto"], ["QTDNEG", "Negociado", "auto"], ["QTDENT", "Atendido", "auto"], ["SALDO_ORIG", "Saldo un. item", "auto"],
    ["SALDO_BASE", "Saldo un. padrao", "auto"], ["VLR_SALDO", "R$ saldo", "auto"], ["DT_NEG", "Data OC"], ["DT_PREV", "Previsao"], ["DT_PREV_ESTIMADA", "Previsao estimada (info)"],
    ["PRAZO", "Prazo"], ["DIAS_ATRASO", "Dias atraso", "auto"], ["SITUACAO", "Situacao"], ["STATUS_ITEM", "Entrega"], ["OS", "OS"], ["QUALIDADE_VINC", "Vinculo"],
    ["N_DERIV", "Docs derivados", "auto"], ["N_ENT_OS", "Entradas por OS", "auto"], ["MAX_OC_MESMA_ENT", "OCs na mesma entrada", "auto"], ["POLITICA", "Politica PRG/JIT"]];

  /* ================================================================ CONSUMO */
  function carregarConsumo() {
    var tk = seq.novo("consumo");
    $("cons-tab").innerHTML = carregando("Calculando consumo e médias…");
    rodar("Q_CONSUMO", { TOPN_CONSUMO: parseInt($("fc-topn").value, 10) || 100 }).then(function (l) {
      if (!seq.valido("consumo", tk)) return;
      est.consumo = l;
      renderConsumo();
    }, function (e) { if (seq.valido("consumo", tk)) { est.consumo = []; $("cons-tab").innerHTML = erroHTML("Falha no consumo (Q_CONSUMO)", e); } });
  }
  function rotIdx(idx) { var a = Math.floor((idx - 1) / 12), m = idx - a * 12; return Calc.pad2(m) + "/" + String(a).slice(2); }
  function matrizConsumo(l, opcoes) {
    if (!l.length) return vazio("Sem consumo na janela.");
    var r0 = l[0], m0 = num(r0.IDX_M0), n = num(r0.MESES_JANELA), meses = [], i;
    for (i = m0 - n; i < m0; i++) meses.push(i);
    var prods = [], idx = {};
    l.forEach(function (r) {
      var k = r.CODEMP + "|" + r.CODPROD;
      if (!Object.prototype.hasOwnProperty.call(idx, k)) { idx[k] = prods.length; prods.push({ r: r, m: {} }); }
      if (r.IDX_MES !== null && r.IDX_MES !== undefined) prods[idx[k]].m[num(r.IDX_MES)] = r;
    });
    var b = opcoes && opcoes.busca ? opcoes.busca.toUpperCase() : "";
    if (b) prods = prods.filter(function (p) { return (String(p.r.CODPROD) + " " + (p.r.DESCRPROD || "")).toUpperCase().indexOf(b) >= 0; });
    if (!prods.length) return vazio("Nenhum produto com esta busca.");
    var h = "<table class=\"hm\"><thead><tr><th class=\"fixa\">Produto</th>" +
      "<th>Série</th><th class=\"n\">Meses (divisor)</th><th class=\"n\">Média usada</th><th class=\"n\">Simples</th><th class=\"n\">Ponderada</th><th class=\"n\">Média 3M</th><th class=\"n\">Desvio</th><th class=\"n\">Não conc.</th>";
    meses.forEach(function (m) { h += "<th class=\"n\">" + esc(rotIdx(m)) + "</th>"; });
    h += "<th class=\"n parcial\" title=\"Mês corrente até ontem\">" + esc(rotIdx(m0)) + (est.cfg.MES_PARCIAL === 1 ? " (parcial)" : " (fora)") + "</th></tr></thead><tbody>";
    prods.forEach(function (p) {
      var r = p.r, ini = r.DT_PRIM_CONSUMO ? Calc.idxMes(Calc.dia(r.DT_PRIM_CONSUMO)) : null, mx = 0;
      meses.forEach(function (m) { var v = p.m[m] ? num(p.m[m].QTD) : 0; if (v > mx) mx = v; });
      var d = num(r.DESVIO), cls = d === null ? "" : (d > 0.3 ? "pos" : (d < -0.3 ? "neg" : ""));
      h += "<tr><td class=\"prod fixa\" title=\"" + esc(r.DESCRPROD) + "\">" + esc(r.CODPROD) + " · " + esc(r.DESCRPROD) + " <span class=\"nota\">(" + esc(r.UNIDADE) + ")</span>" +
        (est.codemp ? "" : " <span class=\"tag\">emp " + esc(r.CODEMP) + "</span>") + "</td>" +
        "<td>" + esc(ROT_SERIE[r.ORIGEM_SERIE] || r.ORIGEM_SERIE) + (num(r.FL_HIST_INSUF) ? " <span class=\"tag q\">hist. curto</span>" : "") + "</td>" +
        "<td class=\"n\">" + esc(fN(r.N_MESES)) + (num(r.FRAC_USADA) ? "+" + esc(fN(r.FRAC_USADA, 2)) : "") + "</td><td class=\"n\"><b>" + esc(fQ(r.MEDIA_USADA)) + "</b></td>" +
        "<td class=\"n\">" + esc(fQ(r.MEDIA_SIMPLES)) + "</td><td class=\"n\">" + esc(fQ(r.MEDIA_PONDERADA)) + "</td><td class=\"n\">" + esc(fQ(r.MEDIA_3M)) + "</td>" +
        "<td class=\"n " + cls + "\">" + (d === null ? "—" : esc((d > 0.3 ? "▲ " : d < -0.3 ? "▼ " : "") + (d > 0 ? "+" : "") + fP(d, 0))) + "</td>" +
        "<td class=\"n\">" + esc(fN(r.N_CONS_NAO_CONC)) + "</td>";
      meses.forEach(function (m) {
        if (ini === null || m < ini) { h += "<td class=\"fora\" title=\"Fora da série do produto (antes do 1º consumo no horizonte)\">·</td>"; return; }
        var x = p.m[m], v = x ? num(x.QTD) : 0, bg = "";
        if (v < 0) bg = "background:#fde3e1";
        else if (mx > 0 && v > 0) bg = "background:rgba(31,78,121," + (0.06 + 0.5 * v / mx).toFixed(2) + ")" + (v / mx > 0.6 ? ";color:#fff" : "");
        var tit = x ? "Saídas " + fQ(x.QTD_SAIDA) + " − devoluções " + fQ(x.QTD_DEVOL) + (num(x.QTD_PERDA) ? " + perdas " + fQ(x.QTD_PERDA) : "") + (num(x.N_NAO_CONC) ? " · " + x.N_NAO_CONC + " itens não conciliados (fora)" : "") : "Sem movimento (conta como zero)";
        h += "<td class=\"v\" style=\"" + bg + "\" title=\"" + esc(tit) + "\">" + esc(fQ(v)) + (x && num(x.N_NAO_CONC) ? "*" : "") + "</td>";
      });
      var xp = p.m[m0];
      h += "<td class=\"v parcial\">" + esc(xp ? fQ(xp.QTD) : "0") + "</td></tr>";
    });
    return h + "</tbody></table>";
  }
  function renderConsumo() {
    var l = est.consumo;
    $("cons-tab").innerHTML = matrizConsumo(l, { busca: $("fc-busca").value.replace(/^\s+|\s+$/g, "") });
    var perdas = CONFIG.papeisTop.PERDA.tops.length;
    $("cons-info").innerHTML = l.length ? esc("Janela: " + Calc.fMes(l[0].JANELA_INI) + " a " + rotIdx(num(l[0].IDX_M0) - 1) + " (" + l[0].MESES_JANELA + " meses completos) · média usada: " +
      (est.cfg.MEDIA_MODO === 1 ? "ponderada" : "simples") + " · produtos ordenados pelo valor faturado líquido das saídas (só para escolher quais exibir; não é custo).") : "";
    $("cons-nota").innerHTML = esc("Consumo = saídas mapeadas como consumo " + (perdas ? "+ perdas mapeadas " : "") + "− devoluções mapeadas, em notas confirmadas, na unidade padrão. " +
      (perdas ? "" : "Perdas: nenhuma TOP mapeada, portanto NÃO entram. ") +
      "“·” = mês antes do 1º consumo do produto (fora da série e do divisor). Mês sem movimento dentro da série conta como zero. * = havia itens com unidade não conciliada (excluídos). " +
      "Desvio = média dos 3 últimos meses completos ÷ média usada − 1; acima de ±30% é destacado com seta. Ponderada: pesos sobrepostos (M3 ⊂ M6 ⊂ janela) que somam 1 e são renormalizados ao histórico do produto.");
  }
  var COLS_CSV_CONS = [["CODEMP", "Empresa"], ["CODPROD", "Codigo"], ["DESCRPROD", "Produto"], ["UNIDADE", "Unidade"], [function (r) { return r.IDX_MES === null ? "" : rotIdx(num(r.IDX_MES)); }, "Mes"],
    ["QTD", "Consumo liquido", "auto"], ["QTD_SAIDA", "Saidas", "auto"], ["QTD_DEVOL", "Devolucoes", "auto"], ["QTD_PERDA", "Perdas", "auto"], ["N_NAO_CONC", "Itens nao conciliados", "auto"],
    ["ORIGEM_SERIE", "Serie"], ["DT_PRIM_CONSUMO", "Primeiro consumo"], ["N_MESES", "Meses divisor", "auto"], ["MEDIA_USADA", "Media usada", "auto"], ["MEDIA_SIMPLES", "Media simples", "auto"],
    ["MEDIA_PONDERADA", "Media ponderada", "auto"], ["MEDIA_3M", "Media 3M", "auto"], ["DESVIO", "Desvio", "auto"]];

  /* ================================================================ PARÂMETROS E QUALIDADE */
  function renderParametros() {
    var h = "<table><thead><tr><th>Chave</th><th class=\"n\">Valor em uso</th><th>Origem</th><th>Status</th><th>Descrição</th></tr></thead><tbody>";
    CONFIG.parametros.forEach(function (p) {
      var o = est.cfgOrigem[p.chave] || "padrão";
      h += "<tr><td><code>" + esc(p.chave) + "</code></td><td class=\"n\">" + esc(String(est.cfg[p.chave]).replace(".", ",")) + "</td><td>" + esc(o) + "</td><td>" +
        esc(p.status === "LEGADO_NAO_APROVADO" ? "legado, não aprovado" : "proposta, não aprovada") + "</td><td style=\"white-space:normal\">" + esc(p.descricao) + "</td></tr>";
    });
    Object.keys(CONFIG.limites).forEach(function (k) {
      h += "<tr><td><code>" + esc(k) + "</code></td><td class=\"n\">" + esc(CONFIG.limites[k]) + "</td><td>configuração do build</td><td>técnico</td><td>Limite de linhas trazidas para a tela (não afeta totais).</td></tr>";
    });
    $("par-tab").innerHTML = h + "</tbody></table><div class=\"nota\">Tabela BI_PARAM_COMPRA: " +
      esc(est.tabelaParams === "OK" ? "lida" : est.tabelaParams === "AUSENTE" ? "não existe (opcional)" : est.tabelaParams === "ERRO" ? "erro ao ler: " + est.tabelaParamsErro : "não consultada") +
      ". Chaves antigas ignoradas: " + esc(Object.keys(CONFIG.chavesLegadas).join(", ")) + ".</div>";
    var m = "<table><thead><tr><th>Papel</th><th>TOPs</th><th>Origem</th><th>Validado</th></tr></thead><tbody>";
    Object.keys(CONFIG.papeisTop).forEach(function (k) {
      var x = CONFIG.papeisTop[k];
      m += "<tr><td>" + esc(k) + "</td><td style=\"white-space:normal\">" + (x.tops.length ? esc(x.tops.join(", ")) : "<span class=\"indisp\">nenhuma</span>") + "</td><td style=\"white-space:normal\">" +
        esc(x.origem) + "</td><td>" + (x.validado ? "sim" : "<b>não</b>") + "</td></tr>";
    });
    m += "<tr><td>Preço separado</td><td>" + esc(CONFIG.topsPrecoSeparado.join(", ") || "—") + "</td><td>configuração</td><td><b>não</b></td></tr>";
    m += "<tr><td>Locais excluídos do estoque</td><td>" + esc(CONFIG.locaisExcluidos.join(", ") || "nenhum") + "</td><td>painel original</td><td><b>não</b></td></tr>";
    $("par-map").innerHTML = m + "</tbody></table>";
    renderQualidade();
    renderDiag();
    renderLog();
  }
  function renderQualidade() {
    var alvo = $("par-qual");
    if (!est.resumo) {
      alvo.innerHTML = carregando("Carregando resumo…");
      rodar("Q_RESUMO").then(function (l) { est.resumo = l; renderContexto(); if (est.atual === "param") renderQualidade(); },
        function (e) { alvo.innerHTML = erroHTML("Falha no resumo (Q_RESUMO)", e); });
      return;
    }
    var t = totaisResumo(est.resumo), h = qualidadeResumoHTML(t);
    var legados = CONFIG.parametros.filter(function (p) { return est.cfgOrigem[p.chave] !== "tabela"; }).length;
    h += "<h4>Políticas e regras não validadas</h4><ul class=\"lista-motivos\">" +
      "<li>Classificação PRG/JIT por item: inexistente; nenhum item recebe PRG ou JIT.</li>" +
      "<li>OC confirmada (STATUSNOTA = L, sem liberação pendente/reprovada) tratada como contratada.</li>" +
      "<li>Regra de consumo da previsão: " + (est.cfg.REGRA_PREVISAO_FIRME === 2 ? "SOMA (antiga)" : "MAIOR") + " — os dois cenários são exibidos.</li>" +
      "<li>Mapeamentos de TOP e locais excluídos herdados do painel antigo.</li>" +
      "<li>" + esc(fN(legados)) + " de " + esc(fN(CONFIG.parametros.length)) + " parâmetros vindos do código (padrão); nenhum aprovado.</li>" +
      "<li>Recebimento por OS + produto: vínculo apenas inferido; tolerância de 90% da customização não é aplicada.</li>" +
      "<li>Lote/múltiplo: " + (est.cfg.LOTE_MULTIPLO === 1 ? "aplicados (unidade assumida como padrão)" : "não aplicados (unidade não comprovada)") + ".</li></ul>";
    if (est.carteira) {
      var b = blocos(est.carteira), oc = indicadoresOC(b);
      h += "<h4>Carteira de OC</h4><ul class=\"lista-motivos\"><li>" + esc(fN(oc.semPrev)) + " itens abertos sem previsão.</li>" +
        (b.QUALIDADE || []).map(function (r) { return "<li>" + esc((ROT_QUAL_OC[r.CHAVE] || r.CHAVE) + ": " + fN(r.N_ITENS)) + "</li>"; }).join("") + "</ul>";
    }
    alvo.innerHTML = h;
  }
  function renderDiag() {
    var d = est.diag;
    var h = dl([
      ["Modo", est.modo === "demo" ? "demonstração (Motor JS sobre dados simulados)" : "real (executeQuery)"],
      ["Teste do executeQuery (Q_DIAG)", d ? (d.ok ? "ok · " + d.texto : "falhou · " + d.texto) : "—", 1],
      ["Formato do retorno", est.formatoRetorno || "—", 1],
      ["Consultas simultâneas / tempo de espera", (CONFIG.consultasSimultaneas || 2) + " / " + (CONFIG.timeoutSegundos || 180) + " s (esperar não cancela no banco)"],
      ["Build", BUILD.versao + " · " + BUILD.hash],
      ["Snapshot de sugestões (BI_F_SUGESTAO_COMPRA)", est.snap ? est.snap : "não verificado", 1]
    ]);
    $("par-diag").innerHTML = h + "<div class=\"ctl\"><button type=\"button\" class=\"sec\" id=\"b-snap\">Verificar tabela de snapshot (opcional)</button></div>";
  }
  function verificarSnapshot() {
    est.snap = "verificando…"; renderDiag();
    rodar("Q_SNAP_PROBE").then(function (l) {
      var r = l[0] || {};
      est.snap = "existe · " + fN(r.N) + " linhas no período para CODEMP " + est.codemp + (r.PRIMEIRO ? " (" + fData(r.PRIMEIRO) + " a " + fData(r.ULTIMO) + ")" : "") +
        ". Sem vínculo rastreável com OC, aderência e SLA continuam indisponíveis.";
      renderDiag();
    }, function (e) {
      var c = Calc.classificarErro(Calc.textoErro(e));
      est.snap = c.tipo === "OBJETO_AUSENTE" ? "tabela opcional não existe" : "erro ao verificar: " + c.texto + (c.codigo ? " (" + c.codigo + ")" : "");
      renderDiag();
    });
  }
  function renderLog() {
    if (!est.log.length) { $("par-log").innerHTML = vazio("Nenhuma consulta ainda."); return; }
    var h = "<table><thead><tr><th>Hora</th><th>Consulta</th><th>Resultado</th><th class=\"n\">Tempo</th><th>Detalhe</th></tr></thead><tbody>";
    for (var i = est.log.length - 1; i >= 0; i--) {
      var x = est.log[i];
      h += "<tr><td>" + esc(x.quando) + "</td><td>" + esc(x.id) + "</td><td style=\"color:" + (x.ok ? "#1e6b34" : "#b42318") + "\">" + (x.ok ? "ok" : "erro") +
        "</td><td class=\"n\">" + esc(fN(x.ms / 1000, 1)) + " s</td><td style=\"white-space:normal\">" + esc(x.info) + "</td></tr>";
    }
    $("par-log").innerHTML = h + "</tbody></table>";
  }

  /* ================================================================ navegação e eventos */
  var CARREGAR = { exec: carregarExec, fila: carregarFila, carteira: carregarCarteira, consumo: carregarConsumo, param: renderParametros };
  function abrir(pg) {
    est.atual = pg;
    var bts = $("abas").querySelectorAll("button");
    for (var i = 0; i < bts.length; i++) {
      var at = bts[i].getAttribute("data-pg") === pg;
      bts[i].className = at ? "ativa" : "";
      bts[i].setAttribute("aria-selected", at ? "true" : "false");
    }
    var secs = document.querySelectorAll("section.pg");
    for (i = 0; i < secs.length; i++) secs[i].hidden = secs[i].id !== "pg-" + pg;
    if (pg === "param") { renderParametros(); return; }
    if (!est.carregadas[pg]) { est.carregadas[pg] = true; CARREGAR[pg](); }
  }
  function recarregar(limparCache) {
    if (limparCache) est.cache = {};
    seq.invalidarTudo();
    est.carregadas = {}; est.resumo = null; est.carteira = null;
    abrir(est.atual);
  }
  function cliqueOrdenacao(ev, estado, render) {
    var t = ev.target;
    while (t && t.tagName !== "TH" && t !== ev.currentTarget) t = t.parentNode;
    if (!t || t.tagName !== "TH" || !t.getAttribute("data-col")) return false;
    var col = t.getAttribute("data-col"), o = est[estado];
    est[estado] = o && o.col === col ? { col: col, desc: !o.desc } : { col: col, desc: false };
    render();
    return true;
  }
  function linhaDe(ev) {
    var t = ev.target;
    while (t && t !== ev.currentTarget) { if (t.tagName === "TR" && t.className.indexOf("lin") >= 0) return t; if (t.tagName === "BUTTON") return null; t = t.parentNode; }
    return null;
  }
  function ligar() {
    $("abas").addEventListener("click", function (ev) { var pg = ev.target && ev.target.getAttribute ? ev.target.getAttribute("data-pg") : null; if (pg) abrir(pg); });
    $("f-filtros").addEventListener("submit", function (ev) {
      ev.preventDefault();
      var e = $("f-codemp").value.replace(/^\s+|\s+$/g, ""), di = $("f-ini").value, df = $("f-fim").value;
      if (e !== "" && !/^\d{1,6}$/.test(e)) { alert("Empresa deve ser um código numérico (ou vazio para todas)."); return; }
      if (!Calc.normData(di) || !Calc.normData(df) || di > df) { alert("Período inválido."); return; }
      est.codemp = e === "" ? 0 : parseInt(e, 10); est.dtIni = di; est.dtFim = df;
      recarregar(false);
    });
    $("b-atualizar").addEventListener("click", function () { recarregar(true); });
    $("ff-universo").addEventListener("change", function () { est.filaUniverso = $("ff-universo").value; carregarFila(); });
    ["ff-prio", "ff-motivo", "ff-grupo"].forEach(function (id) { $(id).addEventListener("change", renderFila); });
    $("ff-busca").addEventListener("input", renderFila);
    function teclaLinha(container, fn) {
      $(container).addEventListener("keydown", function (ev) { if (ev.key === "Enter" || ev.key === " ") { var tr = linhaDe(ev); if (tr) { ev.preventDefault(); fn(tr); } else if (ev.target.tagName === "TH") ev.target.click(); } });
    }
    function abrirFila(tr) { var r = est.filaVisivel[+tr.getAttribute("data-i")]; if (r) alternarDetalhe(tr, function () { return detalheProduto(r); }, COLS_FILA.length); }
    $("fila-tab").addEventListener("click", function (ev) {
      if (cliqueOrdenacao(ev, "ordFila", renderFila)) return;
      var bt = ev.target;
      if (bt && bt.getAttribute && bt.getAttribute("data-acao")) { acaoDetalhe(bt); return; }
      var tr = linhaDe(ev); if (tr) abrirFila(tr);
    });
    teclaLinha("fila-tab", abrirFila);
    $("ff-csv").addEventListener("click", function () {
      var l = filaFiltrada();
      baixar("fila_analise_" + est.filaUniverso + "_" + sufixoArquivo() + (est.fila.length && num(est.fila[0].TOTAL_LINHAS) > est.fila.length ? "_TRUNCADA" : "") + ".csv", Calc.montarCSV(l, COLS_CSV_FILA));
      aviso("info", "Exportadas " + fN(l.length) + " linhas: as carregadas que passam nos filtros de tela" + (est.fila.length && num(est.fila[0].TOTAL_LINHAS) > est.fila.length ? " (lista truncada pelo limite)" : "") + ".");
    });
    $("ff-vercsv").addEventListener("click", function () {
      var box = $("fila-csvbox");
      box.hidden = !box.hidden;
      if (!box.hidden) { $("fila-csvtxt").value = Calc.montarCSV(filaFiltrada(), COLS_CSV_FILA).slice(1); $("fila-csvtxt").select(); }
    });
    $("fo-filtro").addEventListener("change", function () { est.ocFiltro = $("fo-filtro").value; carregarOcLista(); });
    $("fo-busca").addEventListener("input", renderOc);
    function abrirOc(tr) { var r = est.ocVisivel[+tr.getAttribute("data-i")]; if (r) alternarDetalhe(tr, function () { return detalheOC(r); }, COLS_OC.length); }
    $("oc-tab").addEventListener("click", function (ev) { if (cliqueOrdenacao(ev, "ordOc", renderOc)) return; var tr = linhaDe(ev); if (tr) abrirOc(tr); });
    teclaLinha("oc-tab", abrirOc);
    $("fo-csv").addEventListener("click", function () { baixar("ocs_abertas_" + est.ocFiltro + "_" + sufixoArquivo() + ".csv", Calc.montarCSV(ocFiltrada(), COLS_CSV_OC)); });
    $("fc-topn").addEventListener("change", carregarConsumo);
    $("fc-busca").addEventListener("input", renderConsumo);
    $("fc-csv").addEventListener("click", function () { baixar("consumo_longo_" + sufixoArquivo() + ".csv", Calc.montarCSV(est.consumo, COLS_CSV_CONS)); });
    $("par-diag").addEventListener("click", function (ev) { if (ev.target && ev.target.id === "b-snap") verificarSnapshot(); });
  }
  function acaoDetalhe(bt) {
    var cod = parseInt(bt.getAttribute("data-codprod"), 10), alvo = $(bt.getAttribute("data-alvo")), acao = bt.getAttribute("data-acao");
    if (!alvo || !(cod > 0)) return;
    alvo.innerHTML = carregando();
    if (acao === "ocs-prod") {
      rodar("Q_OC_LISTA", { FILTRO_OC: "TODAS", CODPROD_FILTRO: cod }).then(function (l) {
        if (!l.length) { alvo.innerHTML = vazio("Nenhum item de OC aberto para este produto."); return; }
        alvo.innerHTML = "<h4>OCs abertas do produto</h4><table><thead><tr><th>OC/item</th><th>Fornecedor</th><th class=\"n\">Saldo</th><th>Previsão</th><th>Situação</th><th>Vínculo</th></tr></thead><tbody>" +
          l.map(function (r) {
            return "<tr><td>" + esc(r.NUNOTA + "/" + r.SEQUENCIA) + "</td><td>" + esc(r.FORNECEDOR || "—") + "</td><td class=\"n\">" + esc(r.SALDO_BASE === null ? "não conciliado (" + fQ(r.SALDO_ORIG) + " " + r.UNID_ITEM + ")" : fQ(r.SALDO_BASE) + " " + r.UNID_PADRAO) +
              "</td><td>" + esc(r.DT_PREV ? fData(r.DT_PREV) + (r.PRAZO === "ATRASADA" ? " (vencida)" : "") : "sem previsão") + "</td><td>" + esc(ROT_SITUACAO[r.SITUACAO] || r.SITUACAO) + "</td><td>" + esc(ROT_VINC[r.QUALIDADE_VINC] || r.QUALIDADE_VINC) + "</td></tr>";
          }).join("") + "</tbody></table>";
      }, function (e) { alvo.innerHTML = erroHTML("Falha nas OCs do produto (Q_OC_LISTA)", e); });
    } else {
      rodar("Q_CONSUMO", { TOPN_CONSUMO: 50, CODPROD_FILTRO: cod }).then(function (l) { alvo.innerHTML = "<h4>Consumo mensal</h4>" + matrizConsumo(l); },
        function (e) { alvo.innerHTML = erroHTML("Falha no consumo do produto (Q_CONSUMO)", e); });
    }
  }
  function bloquear(html) {
    var secs = document.querySelectorAll("section.pg");
    for (var i = 0; i < secs.length; i++) secs[i].hidden = true;
    $("abas").hidden = true;
    $("bloqueio").innerHTML = html;
    $("bloqueio").hidden = false;
  }
  function testarExecuteQuery() {
    return rodar("Q_DIAG").then(function (l) {
      var r = l[0] || {};
      est.diag = { ok: true, texto: "NUMERO=" + r.NUMERO + " · DATA=" + r.DATA + " · TEXTO=" + r.TEXTO };
    }, function (e) {
      var c = Calc.classificarErro(Calc.textoErro(e));
      est.diag = { ok: false, texto: c.texto + (c.codigo ? " (" + c.codigo + ")" : "") };
      aviso("alerta", "O teste básico do executeQuery (SELECT em DUAL) falhou: " + c.texto + ". As demais consultas também devem falhar; ver log na aba Parâmetros e qualidade.");
    });
  }
  function iniciar() {
    var busca = window.location.search || "";
    est.modo = /(^|[?&])modo=demo(&|$)/.test(busca) ? "demo" : "real";
    est.demoOpcionais = /(^|[?&])opcionais=1(&|$)/.test(busca);
    iniciarFiltros();
    ligar();
    if (est.modo === "demo") {
      $("selo-demo").hidden = false;
      document.title = "[DEMONSTRAÇÃO] " + document.title;
      aviso("info", "MODO DEMONSTRAÇÃO: dados SIMULADOS gerados no navegador e processados pelo motor de referência. Nada é consultado no Sankhya." +
        (est.demoOpcionais ? " Tabelas opcionais simuladas." : " Acrescente &opcionais=1 para simular as tabelas opcionais."));
    } else if (typeof executeQuery !== "function") {
      bloquear("<h2>Abra pelo componente HTML5 do Construtor de BI</h2><p>Esta página precisa da função <code>executeQuery</code>, que só existe quando o arquivo é aberto pelo componente " +
        "“JavaScript Simples HTML5” do Construtor de BI do Sankhya.</p><p class=\"nota\">Para ver o layout com dados simulados, abra com <code>?modo=demo</code> no endereço.</p>");
      return;
    }
    renderContexto();
    testarExecuteQuery().then(carregarParametros).then(function () { renderContexto(); abrir("exec"); });
  }
  return { iniciar: iniciar, _est: est };
})();
if (typeof window !== "undefined" && typeof document !== "undefined") {
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", App.iniciar);
  else App.iniciar();
}
