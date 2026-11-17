/* MODO DEMONSTRAÇÃO: gera tabelas SINTÉTICAS (nomes "DEMO") e as processa pelo Motor de referência.
 * Só é ativado com ?modo=demo na URL. Nunca é usado como fallback do modo real. ES5. */
var Demo = (function (Calc) {
  "use strict";
  function rng(seed) {
    var s = seed >>> 0;
    return function () { s = (Math.imul(s, 1664525) + 1013904223) >>> 0; return s / 4294967296; };
  }
  function iso(d) { return Calc.diaISO(d); }

  function gerar(sysdate, comOpcionais) {
    var r = rng(17112026), base = Calc.dia(sysdate), i, j;
    var T = { TGFPRO: [], TGFGRU: [], TGFVOA: [], TGFEST: [], TGFCAB: [], TGFITE: [], TGFTOP: [], TGFPAR: [], TGFVAR: [], TSILIB: [] };
    var grupos = [[10100, "DEMO PAPEL ACOPLADO"], [20200, "DEMO EMBALAGENS SELADAS"], [30200, "DEMO COPOS E POTES"], [40100, "DEMO SACOS E SACOLAS"]];
    grupos.forEach(function (g) { T.TGFGRU.push({ CODGRUPOPROD: g[0], DESCRGRUPOPROD: g[1] }); });
    [[99, "DEMO PEDIDO DE COMPRA"], [1741, "DEMO TOP SEPARADA"], [1131, "DEMO VENDA"], [1200, "DEMO DEVOLUCAO"], [1000, "DEMO PEDIDO DE VENDA"], [259, "DEMO ENTRADA OS"]]
      .forEach(function (t) { T.TGFTOP.push({ CODTIPOPER: t[0], DHALTER: "2020-01-01 00:00:00", DESCROPER: t[1] }); });
    for (i = 1; i <= 4; i++) T.TGFPAR.push({ CODPARC: 900 + i, NOMEPARC: "FORNECEDOR DEMO " + String.fromCharCode(64 + i) });

    var nota = 500000, prods = [];
    function cab(top, d, extra) {
      nota++;
      var c = { NUNOTA: nota, CODEMP: 1, CODTIPOPER: top, DHTIPOPER: "2020-01-01 00:00:00", DTNEG: iso(d) + " 10:00:00", DTPREVENT: null, STATUSNOTA: "L", CODPARC: null, AD_OSTUICIAL: null };
      for (var k in extra) if (Object.prototype.hasOwnProperty.call(extra, k)) c[k] = extra[k];
      T.TGFCAB.push(c);
      return c;
    }
    function ite(c, seq, codprod, qtd, codvol, vlr, extra) {
      var it = { NUNOTA: c.NUNOTA, SEQUENCIA: seq, CODPROD: codprod, QTDNEG: qtd, CODVOL: codvol, VLRTOT: vlr, VLRUNIT: qtd ? vlr / qtd : 0,
        QTDENTREGUE: 0, QTDCONFERIDA: 0, PENDENTE: "N", CANCELADO: "N", AD_OS: null };
      for (var k in extra) if (Object.prototype.hasOwnProperty.call(extra, k)) it[k] = extra[k];
      T.TGFITE.push(it);
      return it;
    }

    for (i = 1; i <= 90; i++) {
      var g = grupos[Math.floor(r() * grupos.length)], cod = 9000 + i, un = r() < 0.7 ? "UN" : "PC";
      var perfil = r();
      var media = perfil < 0.1 ? 0 : Math.round(20 + r() * r() * 1800);
      var novo = perfil > 0.93;
      var preco = Math.round((0.2 + r() * 4) * 100) / 100;
      var p = { CODPROD: cod, DESCRPROD: "PRODUTO DEMO " + cod + " " + g[1].replace("DEMO ", ""), REFERENCIA: null, CODVOL: un, MARCA: null,
        CODGRUPOPROD: g[0], ATIVO: "S", LEADTIME: r() < 0.8 ? (r() < 0.5 ? 30 : 45) : null, ESTMIN: r() < 0.2 ? Math.round(media * 0.5) : null,
        AGRUPMIN: r() < 0.3 ? 100 : null, LOTECOMPMINIMO: r() < 0.15 ? 500 : null, CODPARCCONSIG: null, AD_CODPRODANTIGO: null };
      T.TGFPRO.push(p);
      prods.push({ p: p, media: media, preco: preco, novo: novo });
      if (r() < 0.6) T.TGFVOA.push({ CODPROD: cod, CODVOL: "CX", DIVIDEMULTIPLICA: "M", QUANTIDADE: 100, ATIVO: "S" });
      if (i % 29 === 0) {
        T.TGFVOA.push({ CODPROD: cod, CODVOL: "FD", DIVIDEMULTIPLICA: "M", QUANTIDADE: 10, ATIVO: "S" });
        T.TGFVOA.push({ CODPROD: cod, CODVOL: "FD", DIVIDEMULTIPLICA: "M", QUANTIDADE: 12, ATIVO: "S" });
      }
      /* consumo mensal (24 meses), notas de venda e devoluções */
      var mesesHist = novo ? 2 : 24;
      for (j = mesesHist; j >= 0; j--) {
        if (!media) break;
        var m = Calc.addMonths(Calc.inicioMes(base), -j);
        var q = Math.round(media * (0.5 + r()));
        var diaNota = m + Math.floor(r() * 25);
        if (diaNota >= base) continue;
        var cv = cab(1131, diaNota, {});
        var usaCx = q >= 300 && r() < 0.5 && T.TGFVOA.some(function (v) { return v.CODPROD === cod && v.CODVOL === "CX"; });
        ite(cv, 1, cod, usaCx ? Math.round(q / 100) : q, usaCx ? "CX" : un, q * preco * 1.6);
        if (r() < 0.06) { var cd = cab(1200, diaNota + 2, {}); ite(cd, 1, cod, Math.round(q * 0.1), un, q * 0.1 * preco * 1.6); }
        if (i % 29 === 0 && r() < 0.5) { var cf = cab(1131, diaNota + 1, {}); ite(cf, 1, cod, 3, "FD", 300); }
      }
      /* estoque */
      var est = Math.round(media * (r() * 3.2 - 0.3)) + (media ? 0 : Math.round(r() * 400));
      T.TGFEST.push({ CODEMP: 1, CODPROD: cod, CODLOCAL: 101, ESTOQUE: est, RESERVADO: Math.round(media * r() * 0.3), WMSBLOQUEADO: r() < 0.1 ? 10 : 0 });
      if (r() < 0.1) T.TGFEST.push({ CODEMP: 1, CODPROD: cod, CODLOCAL: 1030000, ESTOQUE: 999, RESERVADO: 0, WMSBLOQUEADO: 0 });
      /* pedidos pendentes (compromissos) */
      if (r() < 0.45 && media) {
        var cp = cab(1000, base - Math.floor(r() * 20), {});
        ite(cp, 1, cod, Math.round(media * (0.2 + r() * 0.9)), un, 0, { PENDENTE: "S", QTDCONFERIDA: r() < 0.2 ? 10 : 0 });
      }
    }

    /* ordens de compra em vários estados */
    var estados = ["CONF_FUTURA", "CONF_FUTURA", "CONF_ATRASADA", "CONF_SEM_PREV", "NAO_CONF", "LIB_PENDENTE", "ENTREGUE", "ENTREGUE", "PARCIAL", "ENCERRADA_SALDO", "CANCELADA", "ANTIGA_ABERTA"];
    var os = 7000;
    for (i = 0; i < 110; i++) {
      var pr = prods[Math.floor(r() * prods.length)], st = estados[Math.floor(r() * estados.length)];
      if (!pr.media && st !== "ANTIGA_ABERTA") continue;
      var dn = st === "ANTIGA_ABERTA" ? base - 500 - Math.floor(r() * 200) : base - Math.floor(r() * 120);
      var prev = st === "CONF_SEM_PREV" ? null : (st === "CONF_ATRASADA" ? base - 1 - Math.floor(r() * 30) : dn + 20 + Math.floor(r() * 40));
      if (st === "CONF_FUTURA" && prev < base) prev = base + 3 + Math.floor(r() * 30);
      var top = r() < 0.08 ? 1741 : 99;
      var temOs = r() < 0.4;
      var oc = cab(top, dn, { DTPREVENT: prev === null ? null : iso(prev) + " 00:00:00", CODPARC: 901 + Math.floor(r() * 4),
        STATUSNOTA: st === "NAO_CONF" ? "A" : "L", AD_OSTUICIAL: temOs ? "OS" + (++os) : null });
      var qn = Math.round(Math.max(50, pr.media) * (0.5 + r() * 2));
      var qe = st === "ENTREGUE" ? qn : st === "PARCIAL" ? Math.round(qn * 0.4) : st === "ENCERRADA_SALDO" ? Math.round(qn * 0.92) : 0;
      var pend = (st === "ENTREGUE" || st === "ENCERRADA_SALDO" || st === "CANCELADA") ? "N" : "S";
      ite(oc, 1, pr.p.CODPROD, qn, pr.p.CODVOL, qn * pr.preco * (top === 1741 ? 0.6 : 1), { QTDENTREGUE: qe, PENDENTE: pend, CANCELADO: st === "CANCELADA" ? "S" : "N" });
      if (st === "LIB_PENDENTE") T.TSILIB.push({ TABELA: "TGFCAB", NUCHAVE: oc.NUNOTA, DHLIB: null, REPROVADO: "N" });
      if (qe > 0) {
        var dEnt = Math.min(base - 1, (prev || dn + 30) + Math.floor(r() * 12) - 5);
        if (temOs && r() < 0.6) {
          var ent = cab(259, dEnt, {});
          ite(ent, 1, pr.p.CODPROD, qe, pr.p.CODVOL, qe * pr.preco, { AD_OS: oc.AD_OSTUICIAL });
          if (r() < 0.3) {
            var oc2 = cab(99, dn + 1, { DTPREVENT: iso(dn + 25) + " 00:00:00", CODPARC: 901, AD_OSTUICIAL: oc.AD_OSTUICIAL });
            ite(oc2, 1, pr.p.CODPROD, qe, pr.p.CODVOL, qe * pr.preco, { QTDENTREGUE: qe, PENDENTE: "N" });
          }
        } else {
          var nf = cab(200, dEnt, {});
          ite(nf, 1, pr.p.CODPROD, qe, pr.p.CODVOL, qe * pr.preco);
          T.TGFVAR.push({ NUNOTA: nf.NUNOTA, NUNOTAORIG: oc.NUNOTA, SEQUENCIAORIG: 1 });
        }
      }
    }
    if (comOpcionais) {
      T.BI_PARAM_COMPRA = [{ CHAVE: "MEDIA_MODO", VALOR: "1" }, { CHAVE: "DIVISOR_MEDIA", VALOR: "6" }, { CHAVE: "SEGURANCA_PCT_LT", VALOR: "abc" }];
      T.BI_F_SUGESTAO_COMPRA = [{ CODEMP: 0, CODPROD: 9001, DATA_SNAPSHOT: iso(base - 10) + " 06:00:00", QTD_SUGERIDA: 10 }];
    }
    return T;
  }

  var cache = {};
  function banco(sysdate, comOpcionais) {
    var k = sysdate.slice(0, 10) + (comOpcionais ? "|o" : "");
    if (!cache[k]) cache[k] = gerar(sysdate, comOpcionais);
    return cache[k];
  }
  return { banco: banco, gerar: gerar };
})(typeof Calc !== "undefined" ? Calc : require("./calc.js"));
if (typeof module !== "undefined" && module.exports) module.exports = Demo;
