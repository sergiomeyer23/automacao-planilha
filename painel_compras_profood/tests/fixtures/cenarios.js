/* Fixtures determinísticas dos cenários de teste. Data-base fixa: 17/11/2026 10:30 (SYSDATE simulado).
 * Janela padrão (MESES_MEDIA = 12): nov/2025 a out/2026; horizonte da série desde nov/2024.
 * Cada função devolve um banco mínimo (tabelas com só as colunas que as consultas usam). */
"use strict";

function novoBanco() {
  const t = { TGFPRO: [], TGFGRU: [{ CODGRUPOPROD: 1, DESCRGRUPOPROD: "GRUPO TESTE" }], TGFVOA: [], TGFEST: [], TGFCAB: [], TGFITE: [],
    TGFTOP: [{ CODTIPOPER: 99, DHALTER: "2020-01-01 00:00:00", DESCROPER: "COMPRA TESTE" }], TGFPAR: [{ CODPARC: 10, NOMEPARC: "FORNECEDOR TESTE" }],
    TGFVAR: [], TSILIB: [] };
  let nota = 1000;
  const api = {
    t,
    prod(cod, extra) {
      t.TGFPRO.push(Object.assign({ CODPROD: cod, DESCRPROD: "PRODUTO " + cod, CODVOL: "UN", CODGRUPOPROD: 1, ATIVO: "S", LEADTIME: 30,
        ESTMIN: null, AGRUPMIN: null, LOTECOMPMINIMO: null, CODPARCCONSIG: null }, extra || {}));
      return api;
    },
    est(cod, qtd, extra) {
      t.TGFEST.push(Object.assign({ CODEMP: 1, CODPROD: cod, CODLOCAL: 101, ESTOQUE: qtd, RESERVADO: 0, WMSBLOQUEADO: 0 }, extra || {}));
      return api;
    },
    voa(cod, vol, dm, q, ativo) { t.TGFVOA.push({ CODPROD: cod, CODVOL: vol, DIVIDEMULTIPLICA: dm, QUANTIDADE: q, ATIVO: ativo || "S" }); return api; },
    /* itens: [{cod, qtd, vol?, vlr?, ent?, pend?, canc?, conf?, os?}] */
    nota(top, dtneg, itens, extra) {
      nota++;
      const c = Object.assign({ NUNOTA: nota, CODEMP: 1, CODTIPOPER: top, DHTIPOPER: "2020-01-01 00:00:00", DTNEG: dtneg, DTPREVENT: null,
        STATUSNOTA: "L", CODPARC: 10, AD_OSTUICIAL: null }, extra || {});
      t.TGFCAB.push(c);
      itens.forEach((i, k) => {
        t.TGFITE.push({ NUNOTA: nota, SEQUENCIA: k + 1, CODPROD: i.cod, QTDNEG: i.qtd, CODVOL: i.vol === undefined ? "UN" : i.vol,
          VLRTOT: i.vlr === undefined ? i.qtd : i.vlr, VLRUNIT: null, QTDENTREGUE: i.ent || 0, QTDCONFERIDA: i.conf || 0,
          PENDENTE: i.pend === undefined ? "N" : i.pend, CANCELADO: i.canc || "N", AD_OS: i.os || null });
      });
      return nota;
    },
    /* consumo mensal: lista de [aaaa-mm, qtd] no dia 15 */
    consumoMensal(cod, meses, top) { meses.forEach((m) => api.nota(top || 1131, m[0] + "-15 09:00:00", [{ cod, qtd: m[1] }])); return api; },
    ultimaNota() { return nota; }
  };
  return api;
}

function mesesJanela(qtd) {
  const out = [];
  for (let i = 0; i < 12; i++) {
    const a = 2025 + Math.floor((10 + i) / 12), m = ((10 + i) % 12) + 1;
    out.push([a + "-" + String(m).padStart(2, "0"), qtd]);
  }
  return out; /* nov/2025 .. out/2026 */
}

/* Cenários de consumo e média (1 a 5, 13, 14). */
function consumo() {
  const b = novoBanco();
  /* 1. consumo e devolução; limites de data e de status */
  b.prod(1).est(1, 500).consumoMensal(1, [["2024-11", 100]].concat(mesesJanela(100)));
  b.nota(1131, "2026-10-31 23:30:00", [{ cod: 1, qtd: 10 }]);                 /* último instante de outubro: entra */
  b.nota(1200, "2026-10-20 10:00:00", [{ cod: 1, qtd: 20 }]);                 /* devolução */
  b.nota(1131, "2026-10-10 10:00:00", [{ cod: 1, qtd: 999 }], { STATUSNOTA: "A" }); /* não confirmada: fora */
  b.nota(1131, "2026-11-17 08:00:00", [{ cod: 1, qtd: 999 }]);                /* dia da data-base: fora */
  b.nota(1131, "2026-11-20 08:00:00", [{ cod: 1, qtd: 999 }]);                /* futuro: fora */
  b.nota(1131, "2026-11-05 08:00:00", [{ cod: 1, qtd: 50 }]);                 /* mês corrente (parcial) */
  b.nota(1131, "2026-10-12 08:00:00", [{ cod: 1, qtd: 777, canc: "S" }]);     /* item cancelado: fora */
  /* 3. produto novo: primeiro consumo em set/2026 */
  b.prod(2).consumoMensal(2, [["2026-09", 60], ["2026-10", 30]]);
  /* 4. produto antigo com meses sem movimento */
  b.prod(3).consumoMensal(3, [["2024-11", 120], ["2025-12", 120]]);
  /* 5. demanda zero com estoque; e só OC aberta sem estoque */
  b.prod(4).est(4, 50);
  b.prod(41);
  b.nota(99, "2026-11-01 10:00:00", [{ cod: 41, qtd: 10, pend: "S" }], { DTPREVENT: "2026-12-01 00:00:00" });
  /* 13. conversão por multiplicação (CX x12) e divisão (FD /2) */
  b.prod(12).voa(12, "CX", "M", 12).voa(12, "FD", "D", 2);
  b.nota(1131, "2026-10-05 10:00:00", [{ cod: 12, qtd: 10, vol: "CX" }, { cod: 12, qtd: 4, vol: "FD" }]);
  /* 14. conversão ambígua (PC com duas regras), inexistente (KG) e regra inativa (SC) */
  b.prod(13).voa(13, "PC", "M", 10).voa(13, "PC", "M", 12).voa(13, "SC", "M", 5, "N");
  b.nota(1131, "2026-10-05 10:00:00", [{ cod: 13, qtd: 5, vol: "PC" }, { cod: 13, qtd: 3, vol: "KG" }, { cod: 13, qtd: 2, vol: "SC" }, { cod: 13, qtd: 7, vol: "UN" }]);
  b.nota(99, "2026-11-01 10:00:00", [{ cod: 13, qtd: 4, vol: "PC", pend: "S", vlr: 40 }], { DTPREVENT: "2026-12-01 00:00:00" });
  return b.t;
}

/* Cenários de planejamento (6 a 12, 15, 16). DD = 10/dia quando consumo = 300/mês. */
function planejamento() {
  const b = novoBanco();
  const giro = (cod) => b.consumoMensal(cod, [["2024-11", 300]].concat(mesesJanela(300)));
  /* 6. estoque negativo, com preço de referência 2,00 */
  b.prod(5).est(5, -30); giro(5);
  b.nota(99, "2026-06-01 10:00:00", [{ cod: 5, qtd: 100, vlr: 200, ent: 100 }]);
  /* 7. reserva e pedido representando o mesmo compromisso */
  b.prod(6).est(6, 100, { RESERVADO: 40 }); giro(6);
  b.nota(1000, "2026-11-10 10:00:00", [{ cod: 6, qtd: 40, pend: "S", conf: 40 }]);
  /* 8. previsão e pedido firme */
  b.prod(7); giro(7);
  b.nota(1000, "2026-11-10 10:00:00", [{ cod: 7, qtd: 200, pend: "S" }]);
  /* 9. OC confirmada x não confirmada x liberação pendente */
  b.prod(8).est(8, 100); giro(8);
  b.nota(99, "2026-11-01 10:00:00", [{ cod: 8, qtd: 100, pend: "S" }], { DTPREVENT: "2026-12-20 00:00:00" });
  b.nota(99, "2026-11-02 10:00:00", [{ cod: 8, qtd: 50, pend: "S" }], { DTPREVENT: "2026-12-20 00:00:00", STATUSNOTA: "A" });
  const lib = b.nota(99, "2026-11-03 10:00:00", [{ cod: 8, qtd: 30, pend: "S" }], { DTPREVENT: "2026-12-20 00:00:00" });
  b.t.TSILIB.push({ TABELA: "TGFCAB", NUCHAVE: lib, DHLIB: "2026-11-03 12:00:00", REPROVADO: "N" });
  b.t.TSILIB.push({ TABELA: "TGFCAB", NUCHAVE: lib, DHLIB: null, REPROVADO: "N" });
  /* 10. OC atrasada e OC sem previsão */
  b.prod(9).est(9, 50); giro(9);
  b.nota(99, "2026-10-01 10:00:00", [{ cod: 9, qtd: 200, pend: "S" }], { DTPREVENT: "2026-11-10 00:00:00" });
  b.nota(99, "2026-10-02 10:00:00", [{ cod: 9, qtd: 100, pend: "S" }]);
  /* 10b. falta antes do próximo recebimento confirmado */
  b.prod(91).est(91, 50); giro(91);
  b.nota(99, "2026-11-01 10:00:00", [{ cod: 91, qtd: 400, pend: "S" }], { DTPREVENT: "2026-12-07 00:00:00" });
  /* 11. OC antiga ainda aberta (fora do corte de 24 meses do painel antigo) */
  b.prod(10).est(10, 0);
  b.nota(99, "2023-01-10 10:00:00", [{ cod: 10, qtd: 500, pend: "S" }], { DTPREVENT: "2023-02-10 00:00:00" });
  /* 12. cotação que virou OC em parte (TOP 1500 só é mapeada como COTACAO no teste) */
  b.prod(11); giro(11);
  b.nota(1500, "2026-11-01 10:00:00", [{ cod: 11, qtd: 500, ent: 300, pend: "S" }]);
  b.nota(99, "2026-11-05 10:00:00", [{ cod: 11, qtd: 300, pend: "S" }], { DTPREVENT: "2026-12-30 00:00:00" });
  /* 15. lote mínimo e múltiplo (necessidade 130 vinda só de pedido firme) */
  b.prod(14, { LOTECOMPMINIMO: 200, AGRUPMIN: 75 });
  b.prod(142, { AGRUPMIN: 50 });
  b.prod(143, { LOTECOMPMINIMO: -5 });
  [14, 142, 143].forEach((c) => b.nota(1000, "2026-11-10 10:00:00", [{ cod: c, qtd: 130, pend: "S" }]));
  /* 16. preço: unidade incompatível; normalização por conversão; TOP separada */
  b.prod(15); b.nota(1000, "2026-11-10 10:00:00", [{ cod: 15, qtd: 10, pend: "S" }]);
  b.nota(99, "2026-09-01 10:00:00", [{ cod: 15, qtd: 2, vol: "KG", vlr: 50, ent: 2 }]);
  b.prod(16).voa(16, "CX", "M", 12); b.nota(1000, "2026-11-10 10:00:00", [{ cod: 16, qtd: 10, pend: "S" }]);
  b.nota(99, "2026-08-01 10:00:00", [{ cod: 16, qtd: 10, vlr: 80, ent: 10 }]);
  b.nota(99, "2026-09-01 10:00:00", [{ cod: 16, qtd: 2, vol: "CX", vlr: 240, ent: 2 }]);
  b.prod(17); b.nota(1000, "2026-11-10 10:00:00", [{ cod: 17, qtd: 10, pend: "S" }]);
  b.nota(99, "2026-08-01 10:00:00", [{ cod: 17, qtd: 10, vlr: 90, ent: 10 }]);
  b.nota(1741, "2026-09-01 10:00:00", [{ cod: 17, qtd: 10, vlr: 50, ent: 10 }]);
  return b.t;
}

/* Cenários de carteira e vínculo (17, 18). Período de fluxo: 01/08/2026 a 17/11/2026. */
function carteira() {
  const b = novoBanco();
  b.t.TGFTOP.push({ CODTIPOPER: 259, DHALTER: "2020-01-01 00:00:00", DESCROPER: "ENTRADA OS" });
  b.prod(18).prod(19).prod(20);
  /* 17. mesma entrada por OS casa com duas OCs */
  b.nota(99, "2026-09-01 10:00:00", [{ cod: 18, qtd: 100, ent: 100 }], { AD_OSTUICIAL: " OS1 ", DTPREVENT: "2026-09-30 00:00:00" });
  b.nota(99, "2026-09-02 10:00:00", [{ cod: 18, qtd: 100, ent: 95 }], { AD_OSTUICIAL: "OS1", DTPREVENT: "2026-09-30 00:00:00" });
  b.nota(259, "2026-09-20 10:00:00", [{ cod: 18, qtd: 100, os: "OS1 " }]);
  /* vínculo nativo, no prazo */
  const oc = b.nota(99, "2026-09-03 10:00:00", [{ cod: 19, qtd: 50, ent: 50 }], { DTPREVENT: "2026-09-30 00:00:00" });
  const nf = b.nota(200, "2026-09-25 10:00:00", [{ cod: 19, qtd: 50 }]);
  b.t.TGFVAR.push({ NUNOTA: nf, NUNOTAORIG: oc, SEQUENCIAORIG: 1 });
  /* 18. pedido de venda misto (dois itens, dois produtos) */
  b.nota(1000, "2026-11-10 10:00:00", [{ cod: 19, qtd: 5, pend: "S" }, { cod: 20, qtd: 7, pend: "S" }]);
  /* OC com TOP sem versão correspondente em TGFTOP (não pode sumir da carteira) */
  b.nota(99, "2026-10-01 10:00:00", [{ cod: 20, qtd: 10, pend: "S" }], { DHTIPOPER: "2019-05-05 00:00:00", DTPREVENT: "2026-10-15 00:00:00" });
  return b.t;
}

module.exports = { novoBanco, consumo, planejamento, carteira, mesesJanela };
