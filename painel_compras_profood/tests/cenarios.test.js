/* Cenários com valores esperados calculados à mão. Cada caso roda:
 *   (a) no motor de referência JS e (b) no SQL GERADO executado no DuckDB (se disponível),
 * conferindo os valores esperados nos dois e a igualdade entre eles.
 * Data-base 17/11/2026; janela nov/2025–out/2026; DD = 10/dia quando consumo = 300/mês. */
"use strict";
const test = require("node:test");
const assert = require("node:assert/strict");
const A = require("./lib/apoio.js");
const F = require("./fixtures/cenarios.js");

const AVISO_SEM_SQL = "DuckDB indisponível: parte SQL não executada (ver RESULTADO_TESTES.md)";
const chavePlano = (l) => l.CODEMP + "/" + l.CODPROD;

/* roda nos dois motores, compara e devolve as linhas por chave (preferindo o SQL quando houver) */
function plano(banco, valores, opcoes, id) {
  const r = A.rodarAmbos(banco, id || "Q_PLANO", Object.assign({ FILTRO_FILA: "TODOS" }, valores), opcoes);
  assert.equal(r.erroJs, null, "motor JS falhou: " + r.erroJs);
  if (r.sqlDisponivel) {
    assert.equal(r.erroSql, null, "SQL falhou: " + r.erroSql);
    const chaves = { Q_OC_LISTA: (l) => l.NUNOTA + "/" + l.SEQUENCIA, Q_CARTEIRA: (l) => l.BLOCO + "/" + l.CHAVE + "/" + l.CHAVE2, Q_RESUMO: (l) => l.PRIORIDADE };
    const dif = A.comparar(r.sql, r.js, chaves[id] || chavePlano, 1e-6);
    assert.deepEqual(dif, [], "SQL e motor JS divergem");
  }
  const fontes = { js: r.js };
  if (r.sql) fontes.sql = r.sql;
  return fontes;
}
/* aplica a verificação nas duas fontes */
function cada(fontes, fn) { Object.keys(fontes).forEach((k) => fn(fontes[k], k)); }
function linha(l, cod) { const x = l.find((r) => r.CODPROD === cod); assert.ok(x, "produto " + cod + " ausente"); return x; }
function perto(a, b, msg) { assert.ok(Math.abs(Number(a) - b) < 1e-3, (msg || "") + " esperado " + b + ", obtido " + a); }
function motivos(r) { return String(r.MOTIVOS || "").split(";").filter(Boolean); }

test("SQL executável disponível para os cenários", { skip: false }, () => {
  if (!require("./lib/sql_runner.js").python()) console.log(AVISO_SEM_SQL);
});

test("1. consumo líquido: saídas − devoluções; status, cancelamento e limites de data com horário", () => {
  cada(plano(F.consumo(), {}), (l, f) => {
    const r = linha(l, 1);
    assert.equal(r.ORIGEM_SERIE, "ANTIGO", f);
    assert.equal(r.N_MESES, 12, f);
    perto(r.QTD_JANELA, 1190, f + " QTD_JANELA (1200 + 10 às 23h30 de 31/10 − 20 devolvidos)");
    perto(r.MEDIA_SIMPLES, 99.167, f);
    perto(r.MEDIA_PONDERADA, 97.667, f + " ponderada (pesos somam 1)");
    perto(r.QTD_PARCIAL, 50, f + " mês corrente só até ontem");
  });
});

test("2. mês corrente parcial: fora por padrão; proporcional quando MES_PARCIAL = 1", () => {
  cada(plano(F.consumo(), { MES_PARCIAL: 0 }), (l) => { perto(linha(l, 1).MEDIA_USADA, 99.167); perto(linha(l, 1).FRAC_USADA, 0); });
  cada(plano(F.consumo(), { MES_PARCIAL: 1 }), (l, f) => {
    const r = linha(l, 1);
    perto(r.FRAC_USADA, 0.5333, f + " 16 dias decorridos ÷ 30");
    perto(r.MEDIA_SIMPLES, 98.936, f + " (1190 + 50) ÷ 12,5333");
    perto(r.MEDIA_PONDERADA, 97.667, f + " ponderada ignora o mês parcial");
  });
});

test("3. produto novo: divisor desde o 1º consumo e histórico insuficiente", () => {
  cada(plano(F.consumo(), {}), (l, f) => {
    const r = linha(l, 2);
    assert.equal(r.ORIGEM_SERIE, "NOVO", f);
    assert.equal(r.N_MESES, 2, f);
    perto(r.MEDIA_SIMPLES, 45, f);
    perto(r.MEDIA_PONDERADA, 45, f);
    assert.equal(r.FL_HIST_INSUF, 1, f);
    assert.ok(motivos(r).includes("HISTORICO_INSUFICIENTE"), f);
  });
  cada(plano(F.consumo(), { MIN_MESES_HIST: 2 }), (l) => assert.equal(linha(l, 2).FL_HIST_INSUF, 0));
});

test("4. produto antigo: meses sem movimento contam como zero (divisor 12, não 1)", () => {
  cada(plano(F.consumo(), {}), (l, f) => {
    const r = linha(l, 3);
    assert.equal(r.ORIGEM_SERIE, "ANTIGO", f);
    assert.equal(r.N_MESES, 12, f);
    perto(r.MEDIA_SIMPLES, 10, f + " 120 ÷ 12");
  });
});

test("5. demanda zero não divide por zero e não vira falta", () => {
  cada(plano(F.consumo(), {}), (l, f) => {
    const r = linha(l, 4);
    assert.equal(r.DD, 0, f);
    assert.equal(r.COB_FISICA_DIAS, null, f);
    assert.equal(r.DT_FALTA_EST, null, f);
    assert.equal(r.PRIORIDADE, "P0_SEM_GIRO", f);
    perto(r.NEC_BRUTA, 0, f);
    const so = linha(l, 41);
    assert.equal(so.ORIGEM_SERIE, "SEM_CONSUMO", f);
    assert.equal(so.PRIORIDADE, "OK", f);
  });
});

test("6. estoque negativo: P1, motivo próprio e valor estimado só com preço", () => {
  cada(plano(F.planejamento(), {}), (l, f) => {
    const r = linha(l, 5);
    assert.equal(r.PRIORIDADE, "P1_CRITICO", f);
    assert.ok(motivos(r).includes("ESTOQUE_NEGATIVO"), f);
    assert.ok(!motivos(r).includes("COMPROMISSO_MAIOR_QUE_ESTOQUE"), f + " sem compromisso, não é esse o motivo");
    perto(r.PRECO_REF, 2, f);
    perto(r.VLR_FALTA_ATUAL, 60, f + " 30 × 2,00");
  });
});

test("7. reserva e pedido: uma única fonte de compromisso, sem dupla subtração", () => {
  cada(plano(F.planejamento(), { FONTE_COMPROMISSO: 1 }), (l, f) => {
    const r = linha(l, 6);
    perto(r.CMP, 40, f); perto(r.DISPONIVEL, 60, f); perto(r.QTD_RESERVADO, 40, f); perto(r.QTD_CONFERIDA, 40, f + " conferida só informa");
  });
  cada(plano(F.planejamento(), { FONTE_COMPROMISSO: 2 }), (l, f) => { perto(linha(l, 6).CMP, 40, f); perto(linha(l, 6).DISPONIVEL, 60, f); });
});

test("8. previsão e pedido firme: MAIOR evita dupla contagem; SOMA fica como cenário", () => {
  cada(plano(F.planejamento(), { REGRA_PREVISAO_FIRME: 1 }), (l, f) => {
    const r = linha(l, 7);
    perto(r.EST_SEG, 60, f + " 10 × 30 × 20%");
    perto(r.REQUISITO, 570, f + " max(200, 510) + 60");
    perto(r.REQUISITO_SOMA, 770, f);
    perto(r.NEC_BRUTA, 570, f); perto(r.NEC_MAIOR, 570, f); perto(r.NEC_SOMA, 770, f);
    perto(r.PONTO_PEDIDO, 360, f + " max(200, 300) + 60");
  });
  cada(plano(F.planejamento(), { REGRA_PREVISAO_FIRME: 2 }), (l, f) => { perto(linha(l, 7).NEC_BRUTA, 770, f); perto(linha(l, 7).PONTO_PEDIDO, 560, f); });
});

test("9. OC confirmada conta como contratada; não confirmada e liberação pendente não", () => {
  cada(plano(F.planejamento(), {}), (l, f) => {
    const r = linha(l, 8);
    perto(r.QTD_OC_CONF, 100, f); perto(r.QTD_OC_NAO_CONF, 80, f + " 50 (STATUSNOTA A) + 30 (liberação pendente)");
    perto(r.POS_CONTRATADA, 200, f);
    perto(r.NEC_BRUTA, 370, f); perto(r.NEC_EM_OC_NAO_CONF, 80, f); perto(r.NEC_NAO_SOLIC, 290, f);
    assert.equal(r.NEC_EM_COTACAO, null, f + " cotação não mapeada = nulo, não zero");
    assert.ok(motivos(r).includes("OC_NAO_CONFIRMADA"), f);
  });
});

test("10. OC atrasada/sem previsão não é pontual; falta antes do recebimento é detectada", () => {
  cada(plano(F.planejamento(), {}), (l, f) => {
    const r = linha(l, 9);
    perto(r.QTD_OC_CONF_ATRAS, 200, f); perto(r.QTD_OC_CONF_SEMPREV, 100, f); perto(r.QTD_OC_CONF_PRAZO, 0, f);
    perto(r.T_FALTA_PROJ, 5, f + " sem recebimento datado: 50 ÷ 10");
    assert.equal(r.DT_FALTA_EST, "2026-11-22", f);
    perto(r.COB_CONTRAT_DIAS, 35, f + " estimativa agregada (inclui as incertas)");
    assert.equal(r.PRIORIDADE, "P2_RUPTURA_IMINENTE", f);
    ["OC_ATRASADA", "OC_SEM_PREVISAO", "FALTA_DENTRO_LEAD_TIME"].forEach((m) => assert.ok(motivos(r).includes(m), f + " " + m));
    const x = linha(l, 91);
    assert.equal(x.FL_FALTA_ANTES_RECEB, 1, f);
    assert.equal(x.DT_FALTA_EST, "2026-11-22", f);
    assert.equal(x.DT_RECEB_APOS_FALTA, "2026-12-07", f);
    perto(x.QTD_FALTA_ANTES_RECEB, 150, f + " 20 dias × 10 − 50");
    assert.equal(x.DT_PROX_RECEB, "2026-12-07", f);
  });
});

test("11. OC antiga ainda aberta continua visível e sinalizada", () => {
  cada(plano(F.planejamento(), {}), (l, f) => {
    const r = linha(l, 10);
    perto(r.QTD_OC_CONF, 500, f); assert.equal(r.N_OC_ANTIGA, 1, f);
    assert.ok(motivos(r).includes("OC_ANTIGA_ABERTA"), f);
  });
  cada(plano(F.planejamento(), { FILTRO_OC: "ANTIGAS" }, {}, "Q_OC_LISTA"), (l, f) => {
    const r = l.find((x) => x.CODPROD === 10);
    assert.ok(r, f + " OC de 2023 precisa aparecer");
    assert.equal(r.FL_ANTIGA, 1); assert.equal(r.PRAZO, "ATRASADA");
  });
});

test("12. cotação que vira OC não é descontada duas vezes", () => {
  const ajuste = (painel) => { painel.papeisTop.COTACAO.tops = [1500]; };
  const config = A.configCom((c) => { c.papeisTop.COTACAO.tops = [1500]; });
  cada(plano(F.planejamento(), {}, { ajustePainel: ajuste, nomeConfig: "cotacao", config }), (l, f) => {
    const r = linha(l, 11);
    perto(r.QTD_COTACAO, 200, f + " 500 cotados − 300 já atendidos pela OC");
    perto(r.QTD_OC_CONF, 300, f);
    perto(r.NEC_BRUTA, 270, f); perto(r.NEC_EM_COTACAO, 200, f); perto(r.NEC_NAO_SOLIC, 70, f);
  });
  cada(plano(F.planejamento(), {}), (l, f) => {
    const r = linha(l, 11);
    assert.equal(r.QTD_COTACAO, null, f + " sem TOP mapeada: indisponível");
    perto(r.NEC_NAO_SOLIC, 270, f);
  });
});

test("13. conversão por multiplicação e divisão", () => {
  cada(plano(F.consumo(), {}), (l, f) => {
    const r = linha(l, 12);
    perto(r.QTD_JANELA, 122, f + " 10 CX × 12 + 4 FD ÷ 2");
    assert.equal(r.N_CONS_NAO_CONC, 0, f);
  });
});

test("14. conversão ambígua, inexistente ou inativa fica fora e é contada", () => {
  cada(plano(F.consumo(), {}), (l, f) => {
    const r = linha(l, 13);
    perto(r.QTD_JANELA, 7, f + " só os 7 UN");
    assert.equal(r.N_CONS_NAO_CONC, 3, f);
    assert.equal(r.N_OC_NAO_CONC, 1, f);
    perto(r.QTD_OC_CONF, 0, f + " OC em PC ambíguo não vira quantidade");
    assert.ok(motivos(r).includes("UNIDADE_NAO_CONCILIADA"), f);
  });
  cada(plano(F.consumo(), { FILTRO_OC: "TODAS", CODPROD_FILTRO: 13 }, {}, "Q_OC_LISTA"), (l, f) => {
    assert.equal(l.length, 1, f);
    assert.equal(l[0].STATUS_CONV, "AMBIGUA", f);
    assert.equal(l[0].SALDO_BASE, null, f);
    perto(l[0].SALDO_ORIG, 4, f);
  });
});

test("15. lote mínimo e múltiplo atendidos juntos; nunca negativo; desligado por padrão", () => {
  cada(plano(F.planejamento(), { LOTE_MULTIPLO: 1 }), (l, f) => {
    const a = linha(l, 14), b = linha(l, 142), c = linha(l, 143);
    perto(a.NEC_NAO_SOLIC, 130, f);
    perto(a.QTD_ARRED, 225, f + " max(130, 200) arredondado ao múltiplo de 75");
    perto(a.EXCESSO_ARRED, 95, f);
    assert.ok(a.QTD_ARRED >= 200 && a.QTD_ARRED % 75 === 0, f);
    perto(b.QTD_ARRED, 150, f);
    perto(c.QTD_ARRED, 130, f + " lote negativo ignorado");
    assert.equal(c.FL_LOTE_INVALIDO, 1, f);
  });
  cada(plano(F.planejamento(), { LOTE_MULTIPLO: 0 }), (l, f) => assert.equal(linha(l, 14).QTD_ARRED, null, f));
});

test("16. preço: unidade incompatível = sem preço; normalizado pela conversão; TOP separada não mistura", () => {
  cada(plano(F.planejamento(), {}), (l, f) => {
    const s = linha(l, 15);
    assert.equal(s.PRECO_REF, null, f); assert.equal(s.VLR_NEC_NAO_SOLIC, null, f);
    assert.ok(motivos(s).includes("SEM_PRECO_REFERENCIA"), f);
    const n = linha(l, 16);
    perto(n.PRECO_REF, 10, f + " 240 ÷ (2 CX × 12)"); assert.equal(n.PRECO_REF_DATA, "2026-09-01", f);
    perto(n.VLR_NEC_NAO_SOLIC, 100, f);
    const t = linha(l, 17);
    perto(t.PRECO_REF, 9, f); perto(t.PRECO_SEP, 5, f);
  });
  cada(plano(F.planejamento(), {}, {}, "Q_RESUMO"), (l, f) => {
    const n = l.reduce((s, r) => s + Number(r.N_NEC_SEM_PRECO), 0);
    assert.ok(n >= 1, f + " itens sem preço contados no resumo");
  });
});

test("17. recebimento por OS + produto compartilhado não vira vínculo comprovado", () => {
  cada(plano(F.carteira(), { FILTRO_OC: "TODAS" }, {}, "Q_CARTEIRA"), (l, f) => {
    const v = (k) => l.find((r) => r.BLOCO === "VINCULO" && r.CHAVE === k);
    assert.equal(Number(v("INFERIDO_OS_COMPARTILHADO").N_ITENS), 2, f);
    assert.equal(Number(v("NATIVO_TGFVAR").N_ITENS), 1, f);
    const q = l.find((r) => r.BLOCO === "QUALIDADE" && r.CHAVE === "ENTRADA_OS_COMPARTILHADA");
    assert.equal(Number(q.N_ITENS), 2, f);
    const p = (k) => { const x = l.find((r) => r.BLOCO === "PONTUALIDADE" && r.CHAVE === k); return x ? Number(x.N_ITENS) : 0; };
    assert.equal(p("INTEGRAL_NO_PRAZO"), 1, f + " só o vínculo nativo conta no prazo");
    assert.equal(p("EXCLUIDO_SEM_DATA_CONFIAVEL"), 1, f + " atendido só por OS: excluído");
    assert.equal(p("ENCERRADA_SEM_INTEGRAL"), 1, f + " encerrada com saldo não é integral");
    assert.equal(p("NAO_ATENDIDA_VENCIDA"), 1, f);
  });
  cada(plano(F.carteira(), { FILTRO_OC: "TODAS" }, {}, "Q_OC_LISTA"), (l, f) => {
    const r = l.find((x) => x.CODPROD === 20);
    assert.ok(r, f + " OC sem versão de TOP não some");
    assert.equal(r.DESCR_TOP, null, f);
  });
});

test("18. pedido misto PRG/JIT: nada é classificado sem regra validada", () => {
  cada(plano(F.carteira(), {}), (l, f) => {
    assert.equal(linha(l, 19).POLITICA, "NAO_VALIDADA", f);
    assert.equal(linha(l, 20).POLITICA, "NAO_VALIDADA", f);
  });
  const Q = require("./lib/sql_runner.js").consultas();
  const tudo = Object.keys(Q).map((k) => Q[k].sql).join(" ");
  ["SOLCOMPRA", "AD_ABASTECIMENTO", "AD_MRPTIPPAP", "AD_CLIENTETPP", "AD_CODPRODANTIGO"].forEach((c) => assert.ok(tudo.indexOf(c) < 0, c + " não pode ser usado"));
});

test("19. tabelas opcionais ausentes: ORA-00942 nos dois motores; presentes: dados", () => {
  const b = F.consumo();
  ["Q_PARAMS", "Q_SNAP_PROBE"].forEach((id) => {
    const r = A.rodarAmbos(b, id, {});
    assert.match(String(r.erroJs), /ORA-00942/);
    if (r.sqlDisponivel) assert.match(String(r.erroSql), /ORA-00942/);
  });
  b.BI_PARAM_COMPRA = [{ CHAVE: "MEDIA_MODO", VALOR: "1" }];
  const r = A.rodarAmbos(b, "Q_PARAMS", {});
  assert.equal(r.js.length, 1);
  if (r.sqlDisponivel) assert.equal(r.sql[0].VALOR, "1");
});

test("21. limite de linhas: a página é truncada, os totais do resumo não", () => {
  const b = F.planejamento();
  const todos = plano(b, {});
  const n = todos.js.length;
  cada(plano(b, { LIMITE_FILA: 2 }), (l, f) => {
    assert.equal(l.length, 2, f);
    assert.equal(Number(l[0].TOTAL_LINHAS), n, f);
  });
  cada(plano(b, {}, {}, "Q_RESUMO"), (l, f) => assert.equal(l.reduce((s, r) => s + Number(r.N_SKUS), 0), n, f));
});
