/* Motor de REFERÊNCIA em JavaScript: reproduz as consultas do painel sobre tabelas em memória.
 * Usos: (1) modo demonstração (dados sintéticos, nunca no modo real); (2) testes de paridade:
 * a mesma fixture roda aqui e no SQL gerado (DuckDB) e os resultados precisam coincidir.
 * Cada função espelha um bloco (CTE) de sql/fragmentos. ES5. */
var Motor = (function (Calc) {
  "use strict";
  var num = Calc.num, arred = Calc.arred, dia = Calc.dia, diaISO = Calc.diaISO, idxMes = Calc.idxMes;

  function nvl(v, d) { return v === null || v === undefined ? d : v; }
  function n0(v) { var x = num(v); return x === null ? 0 : x; }
  function instante(v) {
    if (v === null || v === undefined || v === "") return null;
    var m = /^(\d{4})-(\d{2})-(\d{2})(?:[ T](\d{2}):(\d{2})(?::(\d{2}))?)?/.exec(String(v));
    if (!m) return null;
    return Date.UTC(+m[1], +m[2] - 1, +m[3], +(m[4] || 0), +(m[5] || 0), +(m[6] || 0));
  }
  function trimOracle(s) {
    if (s === null || s === undefined) return null;
    var t = String(s).replace(/^ +| +$/g, "");
    return t === "" ? null : t;
  }
  function chave(a, b) { return a + "|" + b; }
  function oraErro(cod, txt) { var e = new Error(cod + ": " + txt); e.ora = cod; return e; }
  function cmpNum(a, b) { return a < b ? -1 : a > b ? 1 : 0; }
  /* ordenação com NULLS LAST explícito */
  function cmpNullsLast(a, b, desc) {
    var an = a === null || a === undefined, bn = b === null || b === undefined;
    if (an && bn) return 0;
    if (an) return 1;
    if (bn) return -1;
    return desc ? cmpNum(b, a) : cmpNum(a, b);
  }

  /* ------------------------------------------------------------ parâmetros (espelha o bloco prm) */
  function lerParams(binds, config) {
    var defs = {}, i, P = {};
    for (i = 0; i < config.parametros.length; i++) defs[config.parametros[i].chave] = config.parametros[i];
    for (i = 0; i < config.especiais.length; i++) defs[config.especiais[i].chave] = config.especiais[i];
    for (var k in binds) {
      if (!Object.prototype.hasOwnProperty.call(binds, k)) continue;
      var d = defs[k], v = binds[k];
      if (!d) throw new Error("Parâmetro desconhecido no motor: " + k);
      if (d.tipo === "D") P[k] = dia(v);
      else if (d.tipo === "C") P[k] = String(v);
      else if (d.escala) P[k] = Number(v) / d.escala;
      else { if (!/^-?\d+$/.test(String(v))) throw oraErro("ORA-01722", "invalid number"); P[k] = parseInt(v, 10); }
    }
    return P;
  }

  /* ------------------------------------------------------------ contexto (tabelas indexadas) */
  function criarContexto(banco, config, sysdate) {
    var c = { banco: banco, config: config, papel: {}, pro: {}, itens: {}, cab: banco.TGFCAB || [] };
    c.dtBase = dia(sysdate);
    c.m0 = Calc.inicioMes(c.dtBase);
    c.snapshot = (function () {
      var m = /^(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2})/.exec(sysdate);
      return m ? m[3] + "/" + m[2] + "/" + m[1] + " " + m[4] + ":" + m[5] : null;
    })();
    var sep = config.topsPrecoSeparado || [];
    for (var papel in config.papeisTop) {
      if (!Object.prototype.hasOwnProperty.call(config.papeisTop, papel)) continue;
      var tops = config.papeisTop[papel].tops;
      for (var i = 0; i < tops.length; i++) {
        c.papel[tops[i]] = { papel: papel, grupo: papel !== "ORDEM_COMPRA" ? "NA" : (sep.indexOf(tops[i]) >= 0 ? "SEPARADO" : "PRINCIPAL") };
      }
    }
    (banco.TGFPRO || []).forEach(function (p) { c.pro[p.CODPROD] = p; });
    (banco.TGFITE || []).forEach(function (it) { (c.itens[it.NUNOTA] = c.itens[it.NUNOTA] || []).push(it); });
    c.voa = Calc.agruparVoa(banco.TGFVOA || []);
    c.cabPorNota = {};
    c.cab.forEach(function (x) { c.cabPorNota[x.NUNOTA] = x; });
    return c;
  }
  function conv(ctx, it) {
    var p = ctx.pro[it.CODPROD];
    return Calc.conversao(nvl(it.CODVOL, null), p.CODVOL, ctx.voa[chave(it.CODPROD, it.CODVOL)]);
  }
  function itemAberto(it) {
    return nvl(it.PENDENTE, "S") === "S" && nvl(it.CANCELADO, "N") !== "S" && n0(it.QTDNEG) > n0(it.QTDENTREGUE);
  }
  /* percorre cabeçalho × item com papel, filtro de empresa e join com TGFPRO */
  function cada(ctx, P, papeis, fn) {
    ctx.cab.forEach(function (c) {
      var tp = ctx.papel[c.CODTIPOPER];
      if (!tp || papeis.indexOf(tp.papel) < 0) return;
      if (!(P.CODEMP === 0 || c.CODEMP === P.CODEMP)) return;
      (ctx.itens[c.NUNOTA] || []).forEach(function (it) {
        if (!ctx.pro[it.CODPROD]) return;
        fn(c, it, tp);
      });
    });
  }

  /* ------------------------------------------------------------ janela */
  function janc(ctx, P) {
    var N = P.MESES_MEDIA, m0 = ctx.m0;
    return {
      DT_BASE: ctx.dtBase, M0: m0, N: N,
      INI: Calc.addMonths(m0, -N),
      HORIZ_INI: Calc.addMonths(m0, -N - 12),
      IDX_M0: idxMes(m0),
      FRAC: P.MES_PARCIAL === 1 ? (ctx.dtBase - m0) / (Calc.addMonths(m0, 1) - m0) : 0
    };
  }

  /* ------------------------------------------------------------ consumo (cmov → med3) */
  function consumo(ctx, P, J) {
    var cmov = [];
    cada(ctx, P, ["CONSUMO", "DEVOLUCAO", "PERDA"], function (c, it, tp) {
      if (c.STATUSNOTA !== "L" || nvl(it.CANCELADO, "N") === "S") return;
      var d = dia(c.DTNEG);
      if (d < J.HORIZ_INI || d >= J.DT_BASE) return;
      cmov.push({ CODEMP: c.CODEMP, CODPROD: it.CODPROD, PAPEL: tp.papel, DT: d, IDX: idxMes(d),
        QTD_ORIG: n0(it.QTDNEG), VLR: n0(it.VLRTOT), FATOR: conv(ctx, it).fator });
    });
    var mes = {}, serie = {};
    cmov.forEach(function (m) {
      var k = chave(chave(m.CODEMP, m.CODPROD), m.IDX);
      var x = mes[k] || (mes[k] = { CODEMP: m.CODEMP, CODPROD: m.CODPROD, IDX_MES: m.IDX, QTD: 0, QTD_SAIDA: 0, QTD_DEVOL: 0, QTD_PERDA: 0, VLR_FAT: 0, N_NAO_CONC: 0 });
      if (m.FATOR === null) x.N_NAO_CONC++;
      else {
        var q = m.QTD_ORIG * m.FATOR;
        x.QTD += m.PAPEL === "DEVOLUCAO" ? -q : q;
        if (m.PAPEL === "CONSUMO") x.QTD_SAIDA += q;
        if (m.PAPEL === "DEVOLUCAO") x.QTD_DEVOL += q;
        if (m.PAPEL === "PERDA") x.QTD_PERDA += q;
      }
      x.VLR_FAT += m.PAPEL === "CONSUMO" ? m.VLR : (m.PAPEL === "DEVOLUCAO" ? -m.VLR : 0);
      if (m.PAPEL === "CONSUMO") {
        var ks = chave(m.CODEMP, m.CODPROD);
        var s = serie[ks] || (serie[ks] = { CODEMP: m.CODEMP, CODPROD: m.CODPROD, IDX_PRIM: m.IDX, DT_PRIM: m.DT });
        if (m.IDX < s.IDX_PRIM) s.IDX_PRIM = m.IDX;
        if (m.DT < s.DT_PRIM) s.DT_PRIM = m.DT;
      }
    });
    var med0 = {};
    Object.keys(serie).forEach(function (k) {
      var s = serie[k], o;
      if (s.IDX_PRIM < J.IDX_M0 - J.N) o = ["ANTIGO", J.N];
      else if (s.IDX_PRIM < J.IDX_M0) o = ["NOVO", J.IDX_M0 - s.IDX_PRIM];
      else o = ["SO_MES_ATUAL", 0];
      med0[k] = { CODEMP: s.CODEMP, CODPROD: s.CODPROD, DT_PRIM: s.DT_PRIM, ORIGEM_SERIE: o[0], N_MESES: o[1] };
    });
    var ag = {};
    Object.keys(mes).forEach(function (k) {
      var cm = mes[k], ks = chave(cm.CODEMP, cm.CODPROD), nm = med0[ks] ? med0[ks].N_MESES : 0, a = J.IDX_M0 - cm.IDX_MES;
      var x = ag[ks] || (ag[ks] = { CODEMP: cm.CODEMP, CODPROD: cm.CODPROD, QTD_JANELA: 0, QTD_PARCIAL: 0, QTD_3M: 0, POND_NUM: 0, N_CONS_NAO_CONC: 0, VLR_FAT_JANELA: 0 });
      if (a >= 1 && a <= nm) { x.QTD_JANELA += cm.QTD; x.POND_NUM += cm.QTD * Calc.pesoMes(a, J.N); }
      if (cm.IDX_MES === J.IDX_M0) x.QTD_PARCIAL += cm.QTD;
      if (a >= 1 && a <= Math.min(nm, 3)) x.QTD_3M += cm.QTD;
      if (a >= 1 && a <= J.N) x.N_CONS_NAO_CONC += cm.N_NAO_CONC;
      else if (cm.IDX_MES === J.IDX_M0 && P.MES_PARCIAL === 1) x.N_CONS_NAO_CONC += cm.N_NAO_CONC;
      if (a >= 1 && a <= J.N) x.VLR_FAT_JANELA += cm.VLR_FAT;
    });
    var med3 = {}, chavesMed = {};
    Object.keys(ag).forEach(function (k) { chavesMed[k] = ag[k]; });
    Object.keys(med0).forEach(function (k) { chavesMed[k] = med0[k]; });
    Object.keys(chavesMed).forEach(function (k) {
      var m0 = med0[k], ca = ag[k] || {};
      var r = {
        CODEMP: chavesMed[k].CODEMP, CODPROD: chavesMed[k].CODPROD,
        ORIGEM_SERIE: m0 ? m0.ORIGEM_SERIE : "SEM_CONSUMO",
        DT_PRIM_CONSUMO: m0 ? m0.DT_PRIM : null,
        N_MESES: m0 ? m0.N_MESES : 0,
        FRAC_USADA: P.MES_PARCIAL === 1 && m0 ? J.FRAC : 0,
        QTD_JANELA: n0(ca.QTD_JANELA), QTD_PARCIAL: n0(ca.QTD_PARCIAL), QTD_3M: n0(ca.QTD_3M),
        POND_NUM: n0(ca.POND_NUM), N_CONS_NAO_CONC: n0(ca.N_CONS_NAO_CONC), VLR_FAT_JANELA: n0(ca.VLR_FAT_JANELA)
      };
      r.MEDIA_SIMPLES = r.N_MESES + r.FRAC_USADA > 0 ? (r.QTD_JANELA + (r.FRAC_USADA > 0 ? r.QTD_PARCIAL : 0)) / (r.N_MESES + r.FRAC_USADA) : null;
      r.MEDIA_PONDERADA = r.N_MESES >= 1 ? r.POND_NUM / Calc.somaPesos(r.N_MESES, J.N) : null;
      r.MEDIA_3M = r.N_MESES >= 1 ? r.QTD_3M / Math.min(r.N_MESES, 3) : null;
      r.MEDIA_CALC = P.MEDIA_MODO === 1 ? r.MEDIA_PONDERADA : r.MEDIA_SIMPLES;
      r.FL_HIST_INSUF = (r.ORIGEM_SERIE === "NOVO" || r.ORIGEM_SERIE === "SO_MES_ATUAL") && r.N_MESES + r.FRAC_USADA < P.MIN_MESES_HIST ? 1 : 0;
      med3[k] = r;
    });
    return { med3: med3, mes: mes };
  }

  /* ------------------------------------------------------------ produtos ativos */
  function prod(ctx) {
    var out = {}, gru = {};
    (ctx.banco.TGFGRU || []).forEach(function (g) { gru[g.CODGRUPOPROD] = g; });
    (ctx.banco.TGFPRO || []).forEach(function (p) {
      if (p.ATIVO !== "S") return;
      out[p.CODPROD] = {
        CODPROD: p.CODPROD, DESCRPROD: nvl(p.DESCRPROD, null), UNIDADE: nvl(p.CODVOL, null), GRUPO: nvl(p.CODGRUPOPROD, null),
        GRUPO_DESCR: gru[p.CODGRUPOPROD] ? nvl(gru[p.CODGRUPOPROD].DESCRGRUPOPROD, null) : null,
        LT_CAD: num(p.LEADTIME) > 0 ? num(p.LEADTIME) : null,
        ESTMIN_CAD: num(p.ESTMIN) > 0 ? num(p.ESTMIN) : null,
        AGRUPMIN: num(p.AGRUPMIN), LOTEMIN: num(p.LOTECOMPMINIMO),
        FL_CONSIGNADO: n0(p.CODPARCCONSIG) > 0 ? 1 : 0,
        COD_ANTIGO: ctx.config.codigoAntigoHabilitado && p.AD_CODPRODANTIGO !== null && p.AD_CODPRODANTIGO !== undefined ? String(p.AD_CODPRODANTIGO) : null
      };
    });
    return out;
  }

  /* ------------------------------------------------------------ estoque, compromissos, cotação */
  function estoque(ctx, P) {
    var out = {}, exc = ctx.config.locaisExcluidos || [];
    (ctx.banco.TGFEST || []).forEach(function (e) {
      if (!(P.CODEMP === 0 || e.CODEMP === P.CODEMP)) return;
      if (exc.indexOf(e.CODLOCAL) >= 0) return;
      var k = chave(e.CODEMP, e.CODPROD);
      var x = out[k] || (out[k] = { CODEMP: e.CODEMP, CODPROD: e.CODPROD, QTD_ESTOQUE: 0, QTD_RESERVADO: 0, QTD_BLOQUEADO: 0 });
      x.QTD_ESTOQUE += n0(e.ESTOQUE); x.QTD_RESERVADO += n0(e.RESERVADO); x.QTD_BLOQUEADO += n0(e.WMSBLOQUEADO);
    });
    return out;
  }
  function compromissos(ctx, P) {
    var out = {};
    cada(ctx, P, ["EMPENHO"], function (c, it) {
      if (it.PENDENTE !== "S" || !itemAberto(it)) return;
      var f = conv(ctx, it).fator, k = chave(c.CODEMP, it.CODPROD);
      var x = out[k] || (out[k] = { CODEMP: c.CODEMP, CODPROD: it.CODPROD, QTD_PEDIDOS: 0, QTD_CONFERIDA: 0, N_PED_NAO_CONC: 0 });
      if (f === null) x.N_PED_NAO_CONC++;
      else { x.QTD_PEDIDOS += (n0(it.QTDNEG) - n0(it.QTDENTREGUE)) * f; x.QTD_CONFERIDA += n0(it.QTDCONFERIDA) * f; }
    });
    return out;
  }
  function cotacao(ctx, P) {
    var out = {};
    cada(ctx, P, ["COTACAO"], function (c, it) {
      if (!itemAberto(it)) return;
      var f = conv(ctx, it).fator, k = chave(c.CODEMP, it.CODPROD);
      var x = out[k] || (out[k] = { CODEMP: c.CODEMP, CODPROD: it.CODPROD, QTD_COTACAO: 0, N_COT_NAO_CONC: 0 });
      if (f === null) x.N_COT_NAO_CONC++; else x.QTD_COTACAO += (n0(it.QTDNEG) - n0(it.QTDENTREGUE)) * f;
    });
    return out;
  }

  /* ------------------------------------------------------------ liberações (TSILIB) */
  function liberacoes(ctx, notas) {
    var out = {};
    (ctx.banco.TSILIB || []).forEach(function (l) {
      if (l.TABELA !== "TGFCAB" || !notas[l.NUCHAVE]) return;
      var x = out[l.NUCHAVE] || (out[l.NUCHAVE] = { N_LIB_PEND: 0, N_LIB_REPROV: 0 });
      var rep = nvl(l.REPROVADO, "N");
      if ((l.DHLIB === null || l.DHLIB === undefined) && rep !== "S") x.N_LIB_PEND++;
      if (rep === "S") x.N_LIB_REPROV++;
    });
    return out;
  }
  function situacao(status, pend, reprov) {
    if (status === "L" && pend === 0 && reprov === 0) return "CONFIRMADA";
    if (status === "L") return "APROVACAO_NAO_DETERMINADA";
    return "NAO_CONFIRMADA";
  }
  function prazo(dtPrev, dtBase) { return dtPrev === null ? "SEM_PREVISAO" : (dtPrev < dtBase ? "ATRASADA" : "NO_PRAZO"); }

  /* ------------------------------------------------------------ OC para planejamento */
  function ocPlanejamento(ctx, P) {
    var its = [], notas = {};
    cada(ctx, P, ["ORDEM_COMPRA"], function (c, it, tp) {
      if (!itemAberto(it)) return;
      notas[c.NUNOTA] = 1;
      its.push({ NUNOTA: c.NUNOTA, CODEMP: c.CODEMP, GRUPO_PRECO: tp.grupo, CODPROD: it.CODPROD, STATUSNOTA: c.STATUSNOTA,
        DT_NEG: dia(c.DTNEG), DT_PREV: dia(c.DTPREVENT), QTDNEG: n0(it.QTDNEG), QTDENT: n0(it.QTDENTREGUE), FATOR: conv(ctx, it).fator });
    });
    var lib = liberacoes(ctx, notas), pos = {}, rec = {};
    var limiteAntiga = Calc.addMonths(ctx.dtBase, -P.OC_ANTIGA_MESES);
    its.forEach(function (o) {
      var lb = lib[o.NUNOTA] || { N_LIB_PEND: 0, N_LIB_REPROV: 0 };
      var sit = situacao(o.STATUSNOTA, lb.N_LIB_PEND, lb.N_LIB_REPROV), pz = prazo(o.DT_PREV, ctx.dtBase);
      var saldo = o.FATOR === null ? null : (o.QTDNEG - o.QTDENT) * o.FATOR;
      var k = chave(o.CODEMP, o.CODPROD);
      var x = pos[k] || (pos[k] = { CODEMP: o.CODEMP, CODPROD: o.CODPROD, QTD_OC_CONF: 0, QTD_OC_CONF_PRAZO: 0, QTD_OC_CONF_ATRAS: 0,
        QTD_OC_CONF_SEMPREV: 0, QTD_OC_NAO_CONF: 0, notas: {}, N_OC_NAO_CONC: 0, N_OC_SEM_PREV: 0, N_OC_ATRAS: 0, N_OC_ANTIGA: 0, N_OC_TOP_SEP: 0 });
      var s0 = saldo === null ? 0 : saldo;
      if (sit === "CONFIRMADA") {
        x.QTD_OC_CONF += s0;
        if (pz === "NO_PRAZO") x.QTD_OC_CONF_PRAZO += s0;
        if (pz === "ATRASADA") x.QTD_OC_CONF_ATRAS += s0;
        if (pz === "SEM_PREVISAO") x.QTD_OC_CONF_SEMPREV += s0;
      } else x.QTD_OC_NAO_CONF += s0;
      x.notas[o.NUNOTA] = 1;
      if (o.FATOR === null) x.N_OC_NAO_CONC++;
      if (pz === "SEM_PREVISAO") x.N_OC_SEM_PREV++;
      if (pz === "ATRASADA") x.N_OC_ATRAS++;
      if (o.DT_NEG < limiteAntiga) x.N_OC_ANTIGA++;
      if (o.GRUPO_PRECO === "SEPARADO") x.N_OC_TOP_SEP++;
      if (sit === "CONFIRMADA" && pz === "NO_PRAZO" && saldo !== null) {
        var lista = rec[k] || (rec[k] = {});
        lista[o.DT_PREV] = (lista[o.DT_PREV] || 0) + saldo;
      }
    });
    Object.keys(pos).forEach(function (k) { pos[k].N_OCS_ABERTAS = Object.keys(pos[k].notas).length; });
    var rec2 = {};
    Object.keys(rec).forEach(function (k) {
      var datas = Object.keys(rec[k]).map(Number).sort(cmpNum), acum = 0;
      rec2[k] = datas.map(function (d, i) { var r = { DT_PREV: d, QTD: rec[k][d], ACUM_ANTES: acum, ORDEM_REC: i + 1 }; acum += rec[k][d]; return r; });
    });
    return { pos: pos, rec2: rec2 };
  }

  /* ------------------------------------------------------------ preço de referência */
  function preco(ctx, P, J) {
    var melhor = {};
    cada(ctx, P, ["ORDEM_COMPRA"], function (c, it, tp) {
      if (c.STATUSNOTA !== "L" || nvl(it.CANCELADO, "N") === "S" || !(n0(it.QTDNEG) > 0) || !(n0(it.VLRTOT) > 0)) return;
      var f = conv(ctx, it).fator;
      if (f === null) return;
      var d = dia(c.DTNEG);
      if (d < J.HORIZ_INI || d > J.DT_BASE) return;
      var k = chave(it.CODPROD, tp.grupo), ord = [instante(c.DTNEG), c.NUNOTA, it.SEQUENCIA];
      var atual = melhor[k];
      var maior = !atual || ord[0] > atual.ord[0] || (ord[0] === atual.ord[0] && (ord[1] > atual.ord[1] || (ord[1] === atual.ord[1] && ord[2] > atual.ord[2])));
      if (maior) melhor[k] = { ord: ord, PRECO: n0(it.VLRTOT) / (n0(it.QTDNEG) * f), DT: d, NUNOTA: c.NUNOTA, TOP: c.CODTIPOPER };
    });
    var out = {};
    Object.keys(melhor).forEach(function (k) {
      var cod = k.split("|")[0], g = k.split("|")[1], m = melhor[k];
      var x = out[cod] || (out[cod] = { PRECO_REF: null, PRECO_REF_DATA: null, PRECO_REF_NUNOTA: null, PRECO_REF_TOP: null, PRECO_SEP: null, PRECO_SEP_DATA: null });
      if (g === "PRINCIPAL") { x.PRECO_REF = m.PRECO; x.PRECO_REF_DATA = m.DT; x.PRECO_REF_NUNOTA = m.NUNOTA; x.PRECO_REF_TOP = m.TOP; }
      if (g === "SEPARADO") { x.PRECO_SEP = m.PRECO; x.PRECO_SEP_DATA = m.DT; }
    });
    return out;
  }

  /* ------------------------------------------------------------ plano (espelha plano.sql) */
  function plano(ctx, P) {
    var J = janc(ctx, P), cons = consumo(ctx, P, J), med3 = cons.med3, pr = prod(ctx), es = estoque(ctx, P);
    var cp = compromissos(ctx, P), oc = ocPlanejamento(ctx, P), ct = cotacao(ctx, P), pz = preco(ctx, P, J);
    var cotMap = ctx.config.papeisTop.COTACAO.tops.length ? 1 : 0;
    var chaves = {};
    Object.keys(es).forEach(function (k) { var e = es[k]; if (e.QTD_ESTOQUE !== 0 || e.QTD_RESERVADO !== 0 || e.QTD_BLOQUEADO !== 0) chaves[k] = e; });
    [med3, cp, oc.pos, ct].forEach(function (m) { Object.keys(m).forEach(function (k) { chaves[k] = m[k]; }); });
    var linhas = [];
    Object.keys(chaves).forEach(function (k) {
      var codemp = chaves[k].CODEMP, codprod = chaves[k].CODPROD, PD = pr[codprod];
      if (!PD) return;
      var ES = es[k] || {}, CP = cp[k] || {}, MD = med3[k] || {}, OP = oc.pos[k] || {}, CT = ct[k] || {}, PZ = pz[codprod] || {};
      var mc = MD.MEDIA_CALC === undefined ? null : MD.MEDIA_CALC;
      var b = {
        CODEMP: codemp, CODPROD: codprod, DESCRPROD: PD.DESCRPROD, UNIDADE: PD.UNIDADE, GRUPO: PD.GRUPO, GRUPO_DESCR: PD.GRUPO_DESCR,
        ESTMIN_CAD: PD.ESTMIN_CAD, AGRUPMIN: PD.AGRUPMIN, LOTEMIN: PD.LOTEMIN, FL_CONSIGNADO: PD.FL_CONSIGNADO, COD_ANTIGO: PD.COD_ANTIGO,
        DT_BASE: ctx.dtBase,
        QTD_ESTOQUE: n0(ES.QTD_ESTOQUE), QTD_RESERVADO: n0(ES.QTD_RESERVADO), QTD_BLOQUEADO: n0(ES.QTD_BLOQUEADO),
        QTD_PEDIDOS: n0(CP.QTD_PEDIDOS), QTD_CONFERIDA: n0(CP.QTD_CONFERIDA), N_PED_NAO_CONC: n0(CP.N_PED_NAO_CONC),
        ORIGEM_SERIE: nvl(MD.ORIGEM_SERIE, "SEM_CONSUMO"), DT_PRIM_CONSUMO: nvl(MD.DT_PRIM_CONSUMO, null),
        N_MESES: n0(MD.N_MESES), FRAC_USADA: n0(MD.FRAC_USADA), QTD_JANELA: n0(MD.QTD_JANELA), QTD_PARCIAL: n0(MD.QTD_PARCIAL),
        MEDIA_SIMPLES: nvl(MD.MEDIA_SIMPLES, null), MEDIA_PONDERADA: nvl(MD.MEDIA_PONDERADA, null), MEDIA_3M: nvl(MD.MEDIA_3M, null), MEDIA_CALC: mc,
        FL_HIST_INSUF: n0(MD.FL_HIST_INSUF), N_CONS_NAO_CONC: n0(MD.N_CONS_NAO_CONC),
        FL_CONSUMO_NEG: mc !== null && mc < 0 ? 1 : 0,
        QTD_OC_CONF: n0(OP.QTD_OC_CONF), QTD_OC_CONF_PRAZO: n0(OP.QTD_OC_CONF_PRAZO), QTD_OC_CONF_ATRAS: n0(OP.QTD_OC_CONF_ATRAS),
        QTD_OC_CONF_SEMPREV: n0(OP.QTD_OC_CONF_SEMPREV), QTD_OC_NAO_CONF: n0(OP.QTD_OC_NAO_CONF), N_OCS_ABERTAS: n0(OP.N_OCS_ABERTAS),
        N_OC_NAO_CONC: n0(OP.N_OC_NAO_CONC), N_OC_SEM_PREV: n0(OP.N_OC_SEM_PREV), N_OC_ATRAS: n0(OP.N_OC_ATRAS),
        N_OC_ANTIGA: n0(OP.N_OC_ANTIGA), N_OC_TOP_SEP: n0(OP.N_OC_TOP_SEP),
        QTD_COTACAO: cotMap === 1 ? n0(CT.QTD_COTACAO) : null, N_COT_NAO_CONC: n0(CT.N_COT_NAO_CONC),
        PRECO_REF: nvl(PZ.PRECO_REF, null), PRECO_REF_DATA: nvl(PZ.PRECO_REF_DATA, null), PRECO_REF_NUNOTA: nvl(PZ.PRECO_REF_NUNOTA, null),
        PRECO_REF_TOP: nvl(PZ.PRECO_REF_TOP, null), PRECO_SEP: nvl(PZ.PRECO_SEP, null), PRECO_SEP_DATA: nvl(PZ.PRECO_SEP_DATA, null),
        LT: PD.LT_CAD > 0 ? PD.LT_CAD : P.LEADTIME_DEFAULT, FL_LT_PADRAO: PD.LT_CAD > 0 ? 0 : 1
      };
      b.EFP = b.QTD_ESTOQUE - (P.DESCONTA_BLOQUEADO === 1 ? b.QTD_BLOQUEADO : 0);
      b.CMP = P.FONTE_COMPROMISSO === 2 ? b.QTD_RESERVADO : b.QTD_PEDIDOS;
      b.MEDIA_USADA = Math.max(mc === null ? 0 : mc, 0);
      b.DD = b.MEDIA_USADA / P.DIAS_MES;
      b.FL_SEM_GIRO = b.MEDIA_USADA === 0 && b.ORIGEM_SERIE !== "SO_MES_ATUAL" ? 1 : 0;
      b.__rec = oc.rec2[k] || [];
      linhas.push(b);
    });
    /* ABC opcional */
    var porEmp = {};
    linhas.forEach(function (b) {
      b.VALOR_ABC = b.PRECO_REF !== null && b.QTD_JANELA > 0 ? b.QTD_JANELA * b.PRECO_REF : 0;
      (porEmp[b.CODEMP] = porEmp[b.CODEMP] || []).push(b);
    });
    Object.keys(porEmp).forEach(function (e) {
      var l = porEmp[e].slice().sort(function (a, c) { return cmpNum(c.VALOR_ABC, a.VALOR_ABC) || cmpNum(a.CODPROD, c.CODPROD); });
      var tot = 0, acum = 0;
      l.forEach(function (b) { tot += b.VALOR_ABC; });
      l.forEach(function (b) { b.__tot = tot; b.__acum = acum; acum += b.VALOR_ABC; });
    });
    var R = P.REGRA_PREVISAO_FIRME;
    linhas.forEach(function (b) {
      b.CURVA = null;
      if (P.ABC_CALCULADA === 1 && b.PRECO_REF !== null && b.__tot > 0) {
        var f = b.__acum / b.__tot;
        b.CURVA = f < P.ABC_LIMITE_A ? "A" : (f < P.ABC_LIMITE_B ? "B" : "C");
      }
      b.CURVA_ORIGEM = P.ABC_CALCULADA === 1 ? "CALCULADA" : "SEM_FONTE";
      b.COB_ALVO = b.CURVA === "A" ? P.COBERTURA_ALVO_A : b.CURVA === "B" ? P.COBERTURA_ALVO_B : b.CURVA === "C" ? P.COBERTURA_ALVO_C : P.COBERTURA_SEM_CURVA;
      b.EST_SEG = P.POLITICA_SEGURANCA === 1 ? b.DD * b.LT * P.SEGURANCA_PCT_LT : (P.POLITICA_SEGURANCA === 2 ? n0(b.ESTMIN_CAD) : 0);
      b.DISPONIVEL = b.EFP - b.CMP;
      b.POS_CONTRATADA = b.EFP + b.QTD_OC_CONF;
      b.HORIZONTE = b.LT + b.COB_ALVO;
      b.PONTO_PEDIDO = Calc.dDemanda(b.CMP, b.DD, b.LT, R) + b.EST_SEG;
      b.REQUISITO = Calc.dDemanda(b.CMP, b.DD, b.LT + b.COB_ALVO, R) + b.EST_SEG;
      b.REQUISITO_SOMA = b.CMP + b.DD * (b.LT + b.COB_ALVO) + b.EST_SEG;
      b.REQUISITO_MAIOR = Math.max(b.CMP, b.DD * (b.LT + b.COB_ALVO)) + b.EST_SEG;
      b.COB_FISICA_DIAS = Calc.tFalta(b.EFP, b.CMP, b.DD, R);
      b.COB_CONTRAT_DIAS = Calc.tFalta(b.EFP + b.QTD_OC_CONF, b.CMP, b.DD, R);
      /* projeção */
      var p1 = null, datada = 0;
      b.__rec.forEach(function (r) {
        datada += r.QTD;
        if (p1) return;
        var di = r.DT_PREV - b.DT_BASE, t = Calc.tFalta(b.EFP + r.ACUM_ANTES, b.CMP, b.DD, R);
        if (t !== null && t < di) p1 = { DT_PREV: r.DT_PREV, T_ANTES: t, FALTA_ANTES: Calc.dDemanda(b.CMP, b.DD, di, R) - (b.EFP + r.ACUM_ANTES) };
      });
      b.DT_PROX_RECEB = b.__rec.length ? b.__rec[0].DT_PREV : null;
      b.QTD_PROX_RECEB = b.__rec.length ? b.__rec[0].QTD : null;
      b.QTD_OC_DATADA = datada;
      b.FL_FALTA_ANTES_RECEB = p1 ? 1 : 0;
      b.DT_RECEB_APOS_FALTA = p1 ? p1.DT_PREV : null;
      b.QTD_FALTA_ANTES_RECEB = p1 ? p1.FALTA_ANTES : null;
      b.T_FALTA_PROJ = p1 ? p1.T_ANTES : Calc.tFalta(b.EFP + datada, b.CMP, b.DD, R);
      b.DT_FALTA_EST = b.T_FALTA_PROJ !== null && b.T_FALTA_PROJ <= 3650 ? b.DT_BASE + Math.floor(b.T_FALTA_PROJ) : null;
      b.NEC_BRUTA = b.FL_CONSIGNADO === 1 ? 0 : Math.max(b.REQUISITO - b.POS_CONTRATADA, 0);
      b.NEC_SOMA = b.FL_CONSIGNADO === 1 ? 0 : Math.max(b.REQUISITO_SOMA - b.POS_CONTRATADA, 0);
      b.NEC_MAIOR = b.FL_CONSIGNADO === 1 ? 0 : Math.max(b.REQUISITO_MAIOR - b.POS_CONTRATADA, 0);
      b.NEC_EM_OC_NAO_CONF = Math.min(b.QTD_OC_NAO_CONF, b.NEC_BRUTA);
      b.NEC_EM_COTACAO = cotMap === 1 ? Math.min(n0(b.QTD_COTACAO), b.NEC_BRUTA - b.NEC_EM_OC_NAO_CONF) : null;
      b.NEC_NAO_SOLIC = b.NEC_BRUTA - b.NEC_EM_OC_NAO_CONF - n0(b.NEC_EM_COTACAO);
      var lt = Calc.arredondarLote(b.NEC_NAO_SOLIC, b.LOTEMIN, b.AGRUPMIN, P.LOTE_MULTIPLO === 1);
      b.FL_LOTE_INVALIDO = (n0(b.LOTEMIN) < 0 || n0(b.AGRUPMIN) < 0) ? 1 : 0;
      b.QTD_ARRED = lt.qtd;
      b.EXCESSO_ARRED = lt.qtd === null ? null : lt.qtd - b.NEC_NAO_SOLIC;
      b.VLR_FALTA_ATUAL = b.PRECO_REF !== null && b.DISPONIVEL < 0 ? -b.DISPONIVEL * b.PRECO_REF : null;
      b.VLR_NEC_NAO_SOLIC = b.PRECO_REF !== null ? b.NEC_NAO_SOLIC * b.PRECO_REF : null;
      b.N_NAO_CONC = b.N_CONS_NAO_CONC + b.N_PED_NAO_CONC + b.N_OC_NAO_CONC + b.N_COT_NAO_CONC;
      var dentroLT = b.T_FALTA_PROJ !== null && Math.floor(b.T_FALTA_PROJ) < b.LT;
      var semGiroCmp = b.FL_SEM_GIRO === 1 && b.QTD_ESTOQUE > 0 && (b.QTD_PEDIDOS > 0 || b.CMP > 0);
      var excesso = b.DD > 0 && b.COB_CONTRAT_DIAS !== null && b.COB_CONTRAT_DIAS > P.COBERTURA_MAX_DIAS;
      var margem = b.PONTO_PEDIDO + b.DD * P.MARGEM_ATENCAO_DIAS;
      b.PRIORIDADE = (b.QTD_ESTOQUE < 0 || b.COB_FISICA_DIAS === 0) ? "P1_CRITICO"
        : dentroLT ? "P2_RUPTURA_IMINENTE"
        : b.POS_CONTRATADA < margem ? "P3_ATENCAO"
        : semGiroCmp ? "REVISAR_SEM_GIRO"
        : excesso ? "P0_EXCESSO"
        : (b.FL_SEM_GIRO === 1 && b.QTD_ESTOQUE > 0) ? "P0_SEM_GIRO" : "OK";
      var m = "";
      if (b.QTD_ESTOQUE < 0) m += "ESTOQUE_NEGATIVO;";
      if (b.DISPONIVEL < 0) m += "COMPROMISSO_MAIOR_QUE_ESTOQUE;";
      if (b.COB_FISICA_DIAS === 0 && b.QTD_ESTOQUE >= 0 && b.DISPONIVEL >= 0) m += "SEM_COBERTURA_FISICA;";
      if (b.FL_FALTA_ANTES_RECEB === 1) m += "FALTA_ANTES_RECEBIMENTO;";
      if (dentroLT) m += "FALTA_DENTRO_LEAD_TIME;";
      if (b.POS_CONTRATADA < b.PONTO_PEDIDO) m += "ABAIXO_PONTO_PEDIDO;";
      else if (b.POS_CONTRATADA < margem) m += "PROXIMO_PONTO_PEDIDO;";
      if (semGiroCmp) m += "SEM_GIRO_COM_COMPROMISSO;";
      else if (b.FL_SEM_GIRO === 1 && b.QTD_ESTOQUE > 0) m += "SEM_GIRO;";
      if (excesso) m += "COBERTURA_ACIMA_MAXIMO;";
      if (b.FL_HIST_INSUF === 1) m += "HISTORICO_INSUFICIENTE;";
      if (b.FL_CONSUMO_NEG === 1) m += "CONSUMO_LIQUIDO_NEGATIVO;";
      if (b.N_NAO_CONC > 0) m += "UNIDADE_NAO_CONCILIADA;";
      if (b.QTD_OC_NAO_CONF > 0) m += "OC_NAO_CONFIRMADA;";
      if (b.N_OC_ATRAS > 0) m += "OC_ATRASADA;";
      if (b.N_OC_SEM_PREV > 0) m += "OC_SEM_PREVISAO;";
      if (b.N_OC_ANTIGA > 0) m += "OC_ANTIGA_ABERTA;";
      if (b.PRECO_REF === null) m += "SEM_PRECO_REFERENCIA;";
      if (b.FL_LT_PADRAO === 1) m += "LEAD_TIME_PADRAO;";
      if (b.FL_CONSIGNADO === 1) m += "CONSIGNADO_SEM_CALCULO;";
      if (b.ESTMIN_CAD > 0 && b.DISPONIVEL < b.ESTMIN_CAD) m += "ABAIXO_ESTMIN_CADASTRO;";
      if (b.FL_LOTE_INVALIDO === 1) m += "LOTE_MULTIPLO_INVALIDO;";
      b.MOTIVOS = m === "" ? null : m;
      delete b.__rec; delete b.__tot; delete b.__acum;
    });
    return { linhas: linhas, J: J, pr: pr };
  }

  /* ------------------------------------------------------------ saídas das consultas */
  function r3(x) { return x === null || x === undefined ? null : arred(x, 3); }
  function saidaPlano(o) {
    return {
      CODEMP: o.CODEMP, CODPROD: o.CODPROD, DESCRPROD: o.DESCRPROD, UNIDADE: o.UNIDADE, GRUPO: o.GRUPO, GRUPO_DESCR: o.GRUPO_DESCR, COD_ANTIGO: o.COD_ANTIGO,
      CURVA: o.CURVA, CURVA_ORIGEM: o.CURVA_ORIGEM, POLITICA: "NAO_VALIDADA", PRIORIDADE: o.PRIORIDADE, MOTIVOS: o.MOTIVOS,
      QTD_ESTOQUE: r3(o.QTD_ESTOQUE), QTD_RESERVADO: r3(o.QTD_RESERVADO), QTD_BLOQUEADO: r3(o.QTD_BLOQUEADO), QTD_PEDIDOS: r3(o.QTD_PEDIDOS),
      QTD_CONFERIDA: r3(o.QTD_CONFERIDA), CMP: r3(o.CMP), EFP: r3(o.EFP), DISPONIVEL: r3(o.DISPONIVEL),
      ORIGEM_SERIE: o.ORIGEM_SERIE, DT_PRIM_CONSUMO: diaISO(o.DT_PRIM_CONSUMO), N_MESES: o.N_MESES, FRAC_USADA: arred(o.FRAC_USADA, 4),
      QTD_JANELA: r3(o.QTD_JANELA), QTD_PARCIAL: r3(o.QTD_PARCIAL), MEDIA_SIMPLES: r3(o.MEDIA_SIMPLES), MEDIA_PONDERADA: r3(o.MEDIA_PONDERADA),
      MEDIA_USADA: r3(o.MEDIA_USADA), DD: arred(o.DD, 4), FL_HIST_INSUF: o.FL_HIST_INSUF, FL_CONSUMO_NEG: o.FL_CONSUMO_NEG, FL_SEM_GIRO: o.FL_SEM_GIRO,
      LT: o.LT, FL_LT_PADRAO: o.FL_LT_PADRAO, COB_ALVO: o.COB_ALVO, EST_SEG: r3(o.EST_SEG), PONTO_PEDIDO: r3(o.PONTO_PEDIDO),
      REQUISITO: r3(o.REQUISITO), REQUISITO_SOMA: r3(o.REQUISITO_SOMA), REQUISITO_MAIOR: r3(o.REQUISITO_MAIOR),
      QTD_OC_CONF: r3(o.QTD_OC_CONF), QTD_OC_CONF_PRAZO: r3(o.QTD_OC_CONF_PRAZO), QTD_OC_CONF_ATRAS: r3(o.QTD_OC_CONF_ATRAS),
      QTD_OC_CONF_SEMPREV: r3(o.QTD_OC_CONF_SEMPREV), QTD_OC_NAO_CONF: r3(o.QTD_OC_NAO_CONF),
      N_OCS_ABERTAS: o.N_OCS_ABERTAS, N_OC_ATRAS: o.N_OC_ATRAS, N_OC_SEM_PREV: o.N_OC_SEM_PREV, N_OC_ANTIGA: o.N_OC_ANTIGA, N_OC_TOP_SEP: o.N_OC_TOP_SEP,
      QTD_COTACAO: r3(o.QTD_COTACAO), POS_CONTRATADA: r3(o.POS_CONTRATADA),
      COB_FISICA_DIAS: o.COB_FISICA_DIAS === null ? null : arred(o.COB_FISICA_DIAS, 1),
      COB_CONTRAT_DIAS: o.COB_CONTRAT_DIAS === null ? null : arred(o.COB_CONTRAT_DIAS, 1),
      DT_PROX_RECEB: diaISO(o.DT_PROX_RECEB), QTD_PROX_RECEB: r3(o.QTD_PROX_RECEB), FL_FALTA_ANTES_RECEB: o.FL_FALTA_ANTES_RECEB,
      DT_RECEB_APOS_FALTA: diaISO(o.DT_RECEB_APOS_FALTA), QTD_FALTA_ANTES_RECEB: r3(o.QTD_FALTA_ANTES_RECEB),
      T_FALTA_PROJ: o.T_FALTA_PROJ === null ? null : arred(o.T_FALTA_PROJ, 1), DT_FALTA_EST: diaISO(o.DT_FALTA_EST),
      NEC_BRUTA: r3(o.NEC_BRUTA), NEC_SOMA: r3(o.NEC_SOMA), NEC_MAIOR: r3(o.NEC_MAIOR), NEC_EM_OC_NAO_CONF: r3(o.NEC_EM_OC_NAO_CONF),
      NEC_EM_COTACAO: r3(o.NEC_EM_COTACAO), NEC_NAO_SOLIC: r3(o.NEC_NAO_SOLIC), AGRUPMIN: o.AGRUPMIN, LOTEMIN: o.LOTEMIN,
      FL_LOTE_INVALIDO: o.FL_LOTE_INVALIDO, QTD_ARRED: r3(o.QTD_ARRED), EXCESSO_ARRED: r3(o.EXCESSO_ARRED),
      PRECO_REF: o.PRECO_REF === null ? null : arred(o.PRECO_REF, 6), PRECO_REF_DATA: diaISO(o.PRECO_REF_DATA),
      PRECO_REF_NUNOTA: o.PRECO_REF_NUNOTA, PRECO_REF_TOP: o.PRECO_REF_TOP,
      PRECO_SEP: o.PRECO_SEP === null ? null : arred(o.PRECO_SEP, 6), PRECO_SEP_DATA: diaISO(o.PRECO_SEP_DATA),
      VLR_FALTA_ATUAL: o.VLR_FALTA_ATUAL === null ? null : arred(o.VLR_FALTA_ATUAL, 2),
      VLR_NEC_NAO_SOLIC: o.VLR_NEC_NAO_SOLIC === null ? null : arred(o.VLR_NEC_NAO_SOLIC, 2),
      ESTMIN_CAD: o.ESTMIN_CAD, FL_CONSIGNADO: o.FL_CONSIGNADO,
      N_CONS_NAO_CONC: o.N_CONS_NAO_CONC, N_PED_NAO_CONC: o.N_PED_NAO_CONC, N_OC_NAO_CONC: o.N_OC_NAO_CONC, N_COT_NAO_CONC: o.N_COT_NAO_CONC,
      N_NAO_CONC: o.N_NAO_CONC, VALOR_ABC: arred(o.VALOR_ABC, 2)
    };
  }
  var ORD = {};
  Calc.ORDEM_PRIORIDADE.forEach(function (p, i) { ORD[p] = i + 1; });

  function qPlano(ctx, P) {
    var pl = plano(ctx, P).linhas.filter(function (b) {
      var f = P.FILTRO_FILA;
      if (f === "TODOS") return true;
      if (f === "ATENCAO") return ["P1_CRITICO", "P2_RUPTURA_IMINENTE", "P3_ATENCAO"].indexOf(b.PRIORIDADE) >= 0 || b.NEC_BRUTA > 0;
      if (f === "EXCESSO") return b.PRIORIDADE === "P0_EXCESSO" || b.PRIORIDADE === "P0_SEM_GIRO";
      if (f === "REVISAR") return b.PRIORIDADE === "REVISAR_SEM_GIRO" || b.N_NAO_CONC > 0 || b.FL_HIST_INSUF === 1 ||
        (b.NEC_BRUTA > 0 && b.PRECO_REF === null) || b.N_OC_SEM_PREV > 0 || b.N_OC_ATRAS > 0 || b.FL_LOTE_INVALIDO === 1 || b.FL_CONSUMO_NEG === 1;
      return false;
    });
    pl.sort(function (a, b) {
      return cmpNum(ORD[a.PRIORIDADE], ORD[b.PRIORIDADE]) || cmpNullsLast(a.T_FALTA_PROJ, b.T_FALTA_PROJ, false) ||
        cmpNullsLast(a.VLR_FALTA_ATUAL, b.VLR_FALTA_ATUAL, true) || cmpNullsLast(a.VLR_NEC_NAO_SOLIC, b.VLR_NEC_NAO_SOLIC, true) ||
        cmpNum(a.CODEMP, b.CODEMP) || cmpNum(a.CODPROD, b.CODPROD);
    });
    var total = pl.length;
    return pl.slice(0, P.LIMITE_FILA).map(function (o, i) {
      var s = saidaPlano(o), r = { RN: i + 1, TOTAL_LINHAS: total };
      for (var k in s) if (Object.prototype.hasOwnProperty.call(s, k)) r[k] = s[k];
      return r;
    });
  }

  function qResumo(ctx, P) {
    var res = plano(ctx, P), g = {}, J = res.J;
    res.linhas.forEach(function (b) {
      var x = g[b.PRIORIDADE] || (g[b.PRIORIDADE] = { PRIORIDADE: b.PRIORIDADE, N_SKUS: 0, N_FALTA_ATUAL: 0, VLR_FALTA_ATUAL: 0, N_FALTA_SEM_PRECO: 0,
        N_NEC: 0, VLR_NEC_NAO_SOLIC: 0, N_NEC_SEM_PRECO: 0, N_NEC_OC_NAO_CONF: 0, N_NEC_COTACAO: 0, N_FALTA_ANTES_RECEB: 0, N_HIST_INSUF: 0,
        N_UN_NAO_CONC: 0, N_SEM_PRECO: 0, N_LT_PADRAO: 0, N_OC_ATRAS: 0, N_OC_SEM_PREV: 0, N_OC_NAO_CONF: 0, N_OC_ANTIGA: 0, N_OC_TOP_SEP: 0,
        N_CONSIGNADO: 0, N_LOTE_INVALIDO: 0, N_CONSUMO_NEG: 0, N_SEM_CURVA: 0 });
      x.N_SKUS++;
      if (b.DISPONIVEL < 0) x.N_FALTA_ATUAL++;
      x.VLR_FALTA_ATUAL += n0(b.VLR_FALTA_ATUAL);
      if (b.DISPONIVEL < 0 && b.PRECO_REF === null) x.N_FALTA_SEM_PRECO++;
      if (b.NEC_NAO_SOLIC > 0) x.N_NEC++;
      x.VLR_NEC_NAO_SOLIC += n0(b.VLR_NEC_NAO_SOLIC);
      if (b.NEC_NAO_SOLIC > 0 && b.PRECO_REF === null) x.N_NEC_SEM_PRECO++;
      if (b.NEC_EM_OC_NAO_CONF > 0) x.N_NEC_OC_NAO_CONF++;
      if (b.NEC_EM_COTACAO !== null && b.NEC_EM_COTACAO > 0) x.N_NEC_COTACAO++;
      x.N_FALTA_ANTES_RECEB += b.FL_FALTA_ANTES_RECEB;
      x.N_HIST_INSUF += b.FL_HIST_INSUF;
      if (b.N_NAO_CONC > 0) x.N_UN_NAO_CONC++;
      if (b.PRECO_REF === null) x.N_SEM_PRECO++;
      x.N_LT_PADRAO += b.FL_LT_PADRAO;
      if (b.N_OC_ATRAS > 0) x.N_OC_ATRAS++;
      if (b.N_OC_SEM_PREV > 0) x.N_OC_SEM_PREV++;
      if (b.QTD_OC_NAO_CONF > 0) x.N_OC_NAO_CONF++;
      if (b.N_OC_ANTIGA > 0) x.N_OC_ANTIGA++;
      if (b.N_OC_TOP_SEP > 0) x.N_OC_TOP_SEP++;
      x.N_CONSIGNADO += b.FL_CONSIGNADO;
      x.N_LOTE_INVALIDO += b.FL_LOTE_INVALIDO;
      x.N_CONSUMO_NEG += b.FL_CONSUMO_NEG;
      if (b.CURVA === null) x.N_SEM_CURVA++;
    });
    var noUniverso = {};
    res.linhas.forEach(function (b) { noUniverso[b.CODPROD] = 1; });
    var fora = 0;
    (ctx.banco.TGFPRO || []).forEach(function (p) { if (p.ATIVO === "S" && !noUniverso[p.CODPROD]) fora++; });
    var cot = ctx.config.papeisTop.COTACAO.tops.length ? 1 : 0;
    return Object.keys(g).sort(function (a, b) { return ORD[a] - ORD[b]; }).map(function (k) {
      var x = g[k];
      x.VLR_FALTA_ATUAL = arred(x.VLR_FALTA_ATUAL, 2);
      x.VLR_NEC_NAO_SOLIC = arred(x.VLR_NEC_NAO_SOLIC, 2);
      x.COTACAO_MAPEADA = cot;
      x.DT_BASE = diaISO(J.DT_BASE);
      x.SNAPSHOT = ctx.snapshot;
      x.JANELA_INI = diaISO(J.INI);
      x.JANELA_FIM = diaISO(Calc.addMonths(J.M0, -1));
      x.FRAC_PARCIAL = arred(J.FRAC, 4);
      x.N_ATIVOS_FORA = fora;
      return x;
    });
  }

  function qConsumo(ctx, P) {
    var J = janc(ctx, P), cons = consumo(ctx, P, J), pr = prod(ctx);
    var sel = Object.keys(cons.med3).map(function (k) { return cons.med3[k]; }).filter(function (m) {
      return pr[m.CODPROD] && (P.CODPROD_FILTRO === 0 || m.CODPROD === P.CODPROD_FILTRO);
    });
    sel.sort(function (a, b) { return cmpNum(b.VLR_FAT_JANELA, a.VLR_FAT_JANELA) || cmpNum(a.CODEMP, b.CODEMP) || cmpNum(a.CODPROD, b.CODPROD); });
    var out = [];
    sel.slice(0, P.TOPN_CONSUMO).forEach(function (m, i) {
      var meses = Object.keys(cons.mes).map(function (k) { return cons.mes[k]; }).filter(function (c) {
        return c.CODEMP === m.CODEMP && c.CODPROD === m.CODPROD && c.IDX_MES >= J.IDX_M0 - J.N && c.IDX_MES <= J.IDX_M0;
      }).sort(function (a, b) { return a.IDX_MES - b.IDX_MES; });
      if (!meses.length) meses = [null];
      meses.forEach(function (c) {
        out.push({
          RK: i + 1, CODEMP: m.CODEMP, CODPROD: m.CODPROD, DESCRPROD: pr[m.CODPROD].DESCRPROD, UNIDADE: pr[m.CODPROD].UNIDADE,
          ORIGEM_SERIE: m.ORIGEM_SERIE, DT_PRIM_CONSUMO: diaISO(m.DT_PRIM_CONSUMO), N_MESES: m.N_MESES, FRAC_USADA: arred(m.FRAC_USADA, 4),
          QTD_JANELA: r3(m.QTD_JANELA), QTD_PARCIAL: r3(m.QTD_PARCIAL), MEDIA_SIMPLES: r3(m.MEDIA_SIMPLES), MEDIA_PONDERADA: r3(m.MEDIA_PONDERADA),
          MEDIA_USADA: r3(Math.max(m.MEDIA_CALC === null ? 0 : m.MEDIA_CALC, 0)), MEDIA_3M: r3(m.MEDIA_3M),
          DESVIO: m.MEDIA_CALC > 0 && m.MEDIA_3M !== null ? arred(m.MEDIA_3M / m.MEDIA_CALC - 1, 4) : null,
          FL_HIST_INSUF: m.FL_HIST_INSUF, N_CONS_NAO_CONC: m.N_CONS_NAO_CONC, VLR_FAT_JANELA: arred(m.VLR_FAT_JANELA, 2),
          IDX_MES: c ? c.IDX_MES : null, QTD: c ? r3(c.QTD) : null, QTD_SAIDA: c ? r3(c.QTD_SAIDA) : null, QTD_DEVOL: c ? r3(c.QTD_DEVOL) : null,
          QTD_PERDA: c ? r3(c.QTD_PERDA) : null, N_NAO_CONC: c ? c.N_NAO_CONC : null,
          IDX_M0: J.IDX_M0, MESES_JANELA: J.N, JANELA_INI: diaISO(J.INI), DT_BASE: diaISO(J.DT_BASE)
        });
      });
    });
    return out;
  }

  /* ------------------------------------------------------------ carteira (espelha oc_carteira.sql) */
  function carteira(ctx, P) {
    var its = [], notas = {};
    cada(ctx, P, ["ORDEM_COMPRA"], function (c, it, tp) {
      var d = dia(c.DTNEG), noPeriodo = d >= P.DT_INI && d <= P.DT_FIM, aberto = itemAberto(it);
      if (!noPeriodo && !aberto) return;
      var cv = conv(ctx, it), p = ctx.pro[it.CODPROD];
      notas[c.NUNOTA] = 1;
      its.push({ NUNOTA: c.NUNOTA, SEQUENCIA: it.SEQUENCIA, CODEMP: c.CODEMP, CODTIPOPER: c.CODTIPOPER, DHTIPOPER: c.DHTIPOPER, CODPARC: nvl(c.CODPARC, null),
        GRUPO_PRECO: tp.grupo, CODPROD: it.CODPROD, STATUSNOTA: c.STATUSNOTA, DT_NEG: d, DT_PREV: dia(c.DTPREVENT),
        PENDENTE: nvl(it.PENDENTE, "S"), CANCELADO: nvl(it.CANCELADO, "N"), QTDNEG: n0(it.QTDNEG), QTDENT: n0(it.QTDENTREGUE), VLRTOT: n0(it.VLRTOT),
        UNID_ITEM: nvl(it.CODVOL, null), UNID_PADRAO: nvl(p.CODVOL, null), LT_CAD: num(p.LEADTIME) > 0 ? num(p.LEADTIME) : null,
        OS: trimOracle(c.AD_OSTUICIAL), FATOR: cv.fator, STATUS_CONV: cv.status, FL_PERIODO: noPeriodo ? 1 : 0, FL_ABERTO: aberto ? 1 : 0 });
    });
    var lib = liberacoes(ctx, notas), vr = {};
    (ctx.banco.TGFVAR || []).forEach(function (v) {
      var n = ctx.cabPorNota[v.NUNOTA];
      if (!n || n.STATUSNOTA !== "L" || v.NUNOTA === v.NUNOTAORIG || !notas[v.NUNOTAORIG]) return;
      var k = chave(v.NUNOTAORIG, v.SEQUENCIAORIG);
      var x = vr[k] || (vr[k] = { notas: {}, DT: null });
      x.notas[v.NUNOTA] = 1;
      var d = dia(n.DTNEG);
      if (x.DT === null || d > x.DT) x.DT = d;
    });
    var pares = [], porEntrada = {};
    its.forEach(function (o) {
      if (o.OS === null) return;
      (ctx.banco.TGFITE || []).forEach(function (e) {
        if (e.CODPROD !== o.CODPROD || trimOracle(e.AD_OS) !== o.OS) return;
        var n = ctx.cabPorNota[e.NUNOTA];
        if (!n) return;
        var tp = ctx.papel[n.CODTIPOPER];
        if (!tp || tp.papel !== "ENTRADA_POR_OS" || n.STATUSNOTA !== "L" || dia(n.DTNEG) < o.DT_NEG) return;
        var par = { o: chave(o.NUNOTA, o.SEQUENCIA), e: chave(e.NUNOTA, e.SEQUENCIA), DT: dia(n.DTNEG) };
        pares.push(par);
        porEntrada[par.e] = (porEntrada[par.e] || 0) + 1;
      });
    });
    var os = {};
    pares.forEach(function (p) {
      var x = os[p.o] || (os[p.o] = { N_ENT_OS: 0, DT: null, MAX: 0 });
      x.N_ENT_OS++;
      if (x.DT === null || p.DT > x.DT) x.DT = p.DT;
      x.MAX = Math.max(x.MAX, porEntrada[p.e]);
    });
    var limiteAntiga = Calc.addMonths(ctx.dtBase, -P.OC_ANTIGA_MESES);
    return its.map(function (o) {
      var lb = lib[o.NUNOTA] || { N_LIB_PEND: 0, N_LIB_REPROV: 0 }, v = vr[chave(o.NUNOTA, o.SEQUENCIA)], x = os[chave(o.NUNOTA, o.SEQUENCIA)];
      o.DT_PREV_ESTIMADA = o.LT_CAD !== null ? o.DT_NEG + Math.floor(o.LT_CAD) : null;
      o.N_LIB_PEND = lb.N_LIB_PEND; o.N_LIB_REPROV = lb.N_LIB_REPROV;
      o.SITUACAO = situacao(o.STATUSNOTA, lb.N_LIB_PEND, lb.N_LIB_REPROV);
      o.PRAZO = prazo(o.DT_PREV, ctx.dtBase);
      o.STATUS_ITEM = o.CANCELADO === "S" ? "CANCELADA" : (o.QTDNEG > 0 && o.QTDENT >= o.QTDNEG) ? "ATENDIDA_INTEGRAL"
        : (o.PENDENTE === "N" && o.QTDENT > 0) ? "ENCERRADA_COM_SALDO" : o.PENDENTE === "N" ? "ENCERRADA_SEM_ATENDIMENTO"
        : o.QTDENT > 0 ? "ATENDIMENTO_PARCIAL" : "ABERTA_SEM_ATENDIMENTO";
      o.DIAS_ATRASO = o.FL_ABERTO === 1 && o.DT_PREV !== null && o.DT_PREV < ctx.dtBase ? ctx.dtBase - o.DT_PREV : null;
      o.IDADE_DIAS = ctx.dtBase - o.DT_NEG;
      o.FL_ANTIGA = o.DT_NEG < limiteAntiga ? 1 : 0;
      o.VLR_SALDO = o.FL_ABERTO === 1 && o.QTDNEG > 0 ? o.VLRTOT * (o.QTDNEG - o.QTDENT) / o.QTDNEG : 0;
      o.SALDO_BASE = o.FL_ABERTO === 1 && o.FATOR !== null ? (o.QTDNEG - o.QTDENT) * o.FATOR : null;
      o.FL_ACIMA_NEGOCIADO = o.QTDENT > o.QTDNEG ? 1 : 0;
      o.N_DERIV = v ? Object.keys(v.notas).length : 0;
      o.DT_ULT_DERIV = v ? v.DT : null;
      o.N_ENT_OS = x ? x.N_ENT_OS : 0;
      o.DT_ULT_ENT_OS = x ? x.DT : null;
      o.MAX_OC_MESMA_ENT = x ? x.MAX : 0;
      o.QUALIDADE_VINC = o.N_DERIV > 0 ? "NATIVO_TGFVAR" : (o.N_ENT_OS > 0 && o.MAX_OC_MESMA_ENT > 1) ? "INFERIDO_OS_COMPARTILHADO"
        : o.N_ENT_OS > 0 ? "INFERIDO_OS" : o.QTDENT > 0 ? "ATENDIMENTO_SEM_VINCULO" : "SEM_ATENDIMENTO";
      return o;
    });
  }

  function qCarteira(ctx, P) {
    var occ = carteira(ctx, P), g = {};
    function add(bloco, k1, k2, nota, vlr, aux) {
      var k = bloco + "|" + k1 + "|" + k2;
      var x = g[k] || (g[k] = { BLOCO: bloco, CHAVE: k1, CHAVE2: k2, notas: {}, N_ITENS: 0, VLR: 0, N_AUX: 0 });
      x.notas[nota] = 1; x.N_ITENS++; x.VLR += vlr; x.N_AUX += aux;
    }
    occ.forEach(function (o) {
      if (o.FL_ABERTO === 1) {
        add("ABERTO", o.SITUACAO, o.PRAZO, o.NUNOTA, o.VLR_SALDO, o.FATOR === null ? 1 : 0);
        var fx = o.IDADE_DIAS <= 15 ? "1_0_15" : o.IDADE_DIAS <= 30 ? "2_16_30" : o.IDADE_DIAS <= 60 ? "3_31_60" : o.IDADE_DIAS <= 180 ? "4_61_180" : "5_181_MAIS";
        add("AGING", fx, "-", o.NUNOTA, o.VLR_SALDO, 0);
      }
      if (o.FL_PERIODO === 1) add("FUNIL", o.STATUS_ITEM, o.SITUACAO, o.NUNOTA, o.VLRTOT, 0);
      if (o.SITUACAO === "CONFIRMADA" && o.CANCELADO !== "S" && o.QTDNEG > 0 && o.DT_PREV !== null &&
          o.DT_PREV >= P.DT_INI && o.DT_PREV <= P.DT_FIM && o.DT_PREV < ctx.dtBase) {
        var cl = o.STATUS_ITEM === "ATENDIDA_INTEGRAL" && o.N_DERIV > 0 && o.DT_ULT_DERIV <= o.DT_PREV + P.TOLERANCIA_ATRASO_DIAS ? "INTEGRAL_NO_PRAZO"
          : o.STATUS_ITEM === "ATENDIDA_INTEGRAL" && o.N_DERIV > 0 ? "INTEGRAL_FORA_PRAZO"
          : o.STATUS_ITEM === "ATENDIDA_INTEGRAL" ? "EXCLUIDO_SEM_DATA_CONFIAVEL"
          : (o.STATUS_ITEM === "ENCERRADA_COM_SALDO" || o.STATUS_ITEM === "ENCERRADA_SEM_ATENDIMENTO") ? "ENCERRADA_SEM_INTEGRAL" : "NAO_ATENDIDA_VENCIDA";
        add("PONTUALIDADE", cl, "-", o.NUNOTA, o.VLRTOT, 0);
      }
      if (o.FL_PERIODO === 1 && o.QTDENT > 0) add("VINCULO", o.QUALIDADE_VINC, "-", o.NUNOTA, o.VLRTOT, 0);
      var q = [];
      if (o.FL_ABERTO === 1 && o.PRAZO === "SEM_PREVISAO") q.push("OC_SEM_PREVISAO");
      if (o.FL_ABERTO === 1 && o.FATOR === null) q.push("UNIDADE_NAO_CONCILIADA");
      if (o.FL_ABERTO === 1 && o.FL_ANTIGA === 1) q.push("OC_ANTIGA_ABERTA");
      if (o.FL_ABERTO === 1 && o.SITUACAO === "NAO_CONFIRMADA") q.push("NAO_CONFIRMADA");
      if (o.FL_ABERTO === 1 && o.SITUACAO === "APROVACAO_NAO_DETERMINADA") q.push("APROVACAO_NAO_DETERMINADA");
      if (o.FL_ACIMA_NEGOCIADO === 1) q.push("ACIMA_NEGOCIADO");
      if (o.FL_PERIODO === 1 && o.STATUS_ITEM === "ENCERRADA_COM_SALDO") q.push("ENCERRADA_COM_SALDO");
      if (o.MAX_OC_MESMA_ENT > 1) q.push("ENTRADA_OS_COMPARTILHADA");
      if (o.FL_ABERTO === 1 && o.GRUPO_PRECO === "SEPARADO") q.push("TOP_PRECO_SEPARADO_ABERTA");
      q.forEach(function (c) { add("QUALIDADE", c, "-", o.NUNOTA, 0, 0); });
    });
    return Object.keys(g).sort().map(function (k) {
      var x = g[k];
      return { BLOCO: x.BLOCO, CHAVE: x.CHAVE, CHAVE2: x.CHAVE2, N_OCS: Object.keys(x.notas).length, N_ITENS: x.N_ITENS,
        VLR: arred(x.VLR, 2), N_AUX: x.N_AUX, DT_BASE: diaISO(ctx.dtBase), SNAPSHOT: ctx.snapshot };
    });
  }

  function qOcLista(ctx, P) {
    var par = {}, top = {}, pro = ctx.pro;
    (ctx.banco.TGFPAR || []).forEach(function (p) { par[p.CODPARC] = p; });
    (ctx.banco.TGFTOP || []).forEach(function (t) { top[t.CODTIPOPER + "|" + instante(t.DHALTER)] = t; });
    var l = carteira(ctx, P).filter(function (o) {
      if (o.FL_ABERTO !== 1) return false;
      if (P.CODPROD_FILTRO !== 0 && o.CODPROD !== P.CODPROD_FILTRO) return false;
      var f = P.FILTRO_OC;
      return f === "TODAS" || (f === "ATRASADAS" && o.PRAZO === "ATRASADA") || (f === "SEM_PREVISAO" && o.PRAZO === "SEM_PREVISAO") ||
        (f === "NAO_CONFIRMADAS" && o.SITUACAO !== "CONFIRMADA") || (f === "ANTIGAS" && o.FL_ANTIGA === 1);
    });
    l.sort(function (a, b) {
      return cmpNullsLast(a.DIAS_ATRASO, b.DIAS_ATRASO, true) || cmpNum(b.VLR_SALDO, a.VLR_SALDO) || cmpNum(a.NUNOTA, b.NUNOTA) || cmpNum(a.SEQUENCIA, b.SEQUENCIA);
    });
    var total = l.length, totVlr = 0;
    l.forEach(function (o) { totVlr += o.VLR_SALDO; });
    return l.slice(0, P.LIMITE_OC).map(function (o, i) {
      var t = top[o.CODTIPOPER + "|" + instante(o.DHTIPOPER)];
      return {
        RN: i + 1, TOTAL_LINHAS: total, TOTAL_VLR_SALDO: arred(totVlr, 2),
        NUNOTA: o.NUNOTA, SEQUENCIA: o.SEQUENCIA, CODEMP: o.CODEMP, CODTIPOPER: o.CODTIPOPER, DESCR_TOP: t ? nvl(t.DESCROPER, null) : null,
        GRUPO_PRECO: o.GRUPO_PRECO, CODPARC: o.CODPARC, FORNECEDOR: par[o.CODPARC] ? nvl(par[o.CODPARC].NOMEPARC, null) : null,
        CODPROD: o.CODPROD, DESCRPROD: nvl(pro[o.CODPROD].DESCRPROD, null),
        UNID_ITEM: o.UNID_ITEM, UNID_PADRAO: o.UNID_PADRAO, FATOR: o.FATOR === null ? null : arred(o.FATOR, 6), STATUS_CONV: o.STATUS_CONV,
        QTDNEG: r3(o.QTDNEG), QTDENT: r3(o.QTDENT), SALDO_ORIG: r3(o.QTDNEG - o.QTDENT), SALDO_BASE: r3(o.SALDO_BASE),
        VLR_SALDO: arred(o.VLR_SALDO, 2), DT_NEG: diaISO(o.DT_NEG), DT_PREV: diaISO(o.DT_PREV), DT_PREV_ESTIMADA: diaISO(o.DT_PREV_ESTIMADA),
        PRAZO: o.PRAZO, DIAS_ATRASO: o.DIAS_ATRASO, IDADE_DIAS: o.IDADE_DIAS, FL_ANTIGA: o.FL_ANTIGA,
        STATUSNOTA: o.STATUSNOTA, SITUACAO: o.SITUACAO, N_LIB_PEND: o.N_LIB_PEND, N_LIB_REPROV: o.N_LIB_REPROV,
        STATUS_ITEM: o.STATUS_ITEM, OS: o.OS, QUALIDADE_VINC: o.QUALIDADE_VINC, N_DERIV: o.N_DERIV, DT_ULT_DERIV: diaISO(o.DT_ULT_DERIV),
        N_ENT_OS: o.N_ENT_OS, MAX_OC_MESMA_ENT: o.MAX_OC_MESMA_ENT, DT_ULT_ENT_OS: diaISO(o.DT_ULT_ENT_OS), POLITICA: "NAO_VALIDADA"
      };
    });
  }

  /* ------------------------------------------------------------ despacho */
  function executar(id, binds, banco, opcoes) {
    var ctx = criarContexto(banco, opcoes.config, opcoes.sysdate);
    var P = lerParams(binds, opcoes.config);
    switch (id) {
      case "Q_DIAG": return [{ NUMERO: P.DIAG_NUM, DATA: Calc.fData(diaISO(P.DT_FIM)), TEXTO: "TESTE" }];
      case "Q_PARAMS":
        if (!banco.BI_PARAM_COMPRA) throw oraErro("ORA-00942", "table or view does not exist");
        return banco.BI_PARAM_COMPRA.map(function (r) { return { CHAVE: r.CHAVE, VALOR: r.VALOR }; });
      case "Q_SNAP_PROBE": {
        if (!banco.BI_F_SUGESTAO_COMPRA) throw oraErro("ORA-00942", "table or view does not exist");
        var l = banco.BI_F_SUGESTAO_COMPRA.filter(function (s) { var d = dia(s.DATA_SNAPSHOT); return d >= P.DT_INI && d <= P.DT_FIM && s.CODEMP === P.CODEMP; });
        var ds = l.map(function (s) { return dia(s.DATA_SNAPSHOT); }).sort(cmpNum);
        return [{ N: l.length, PRIMEIRO: ds.length ? diaISO(ds[0]) : null, ULTIMO: ds.length ? diaISO(ds[ds.length - 1]) : null }];
      }
      case "Q_PLANO": return qPlano(ctx, P);
      case "Q_RESUMO": return qResumo(ctx, P);
      case "Q_CONSUMO": return qConsumo(ctx, P);
      case "Q_CARTEIRA": return qCarteira(ctx, P);
      case "Q_OC_LISTA": return qOcLista(ctx, P);
      default: throw new Error("Consulta desconhecida no motor: " + id);
    }
  }

  return { executar: executar, lerParams: lerParams };
})(typeof Calc !== "undefined" ? Calc : require("./calc.js"));
if (typeof module !== "undefined" && module.exports) module.exports = Motor;
