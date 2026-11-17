<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Acompanhamento de Abertura de OC</title>
<snk:load/>
<style>
:root{--azul:#1f4e79;--txt:#1d2733;--cinza:#5b6875;--borda:#dde3ea;--fundo:#f4f6f9;--verm:#b42318;--laranja:#b54708;--amar:#8a5300;--verde:#1e6b34}
*{box-sizing:border-box}
[hidden]{display:none !important}
html,body{margin:0;padding:0}
body{font-family:"Segoe UI",Roboto,Arial,sans-serif;font-size:13px;color:var(--txt);background:var(--fundo)}
.topo{background:#fff;border-bottom:1px solid var(--borda);padding:8px 16px;display:flex;flex-wrap:wrap;gap:8px;align-items:center;justify-content:space-between}
.marca{display:flex;flex-wrap:wrap;gap:6px;align-items:center}
h1{font-size:17px;margin:0 6px 0 0;color:var(--azul)}
h2{font-size:15px;margin:0}
h3{font-size:13px;margin:0 0 8px;color:var(--azul)}
h4{font-size:12px;margin:10px 0 4px;color:var(--azul)}
.selo{display:inline-block;font-size:11px;font-weight:700;padding:2px 8px;border-radius:10px;letter-spacing:.2px}
.selo-alerta{background:#fdecea;color:var(--verm)}
.selo-aviso{background:#fff4e0;color:var(--amar)}
.selo-demo{background:#e8f0fb;color:var(--azul);outline:2px dashed var(--azul)}
.filtros{display:flex;gap:8px;align-items:center;flex-wrap:wrap}
.filtros label,.ctl label{font-size:12px;color:var(--cinza);display:flex;gap:4px;align-items:center}
input,select,button,textarea{font:inherit;font-size:12px;padding:4px 6px;border:1px solid var(--borda);border-radius:4px;background:#fff;color:var(--txt)}
button{cursor:pointer;background:var(--azul);color:#fff;border-color:var(--azul)}
button.sec{background:#fff;color:var(--azul)}
button.link{background:none;border:none;color:var(--azul);text-decoration:underline;padding:0 2px}
button:focus-visible,input:focus-visible,select:focus-visible,tr.lin:focus-visible{outline:2px solid #2e75b6;outline-offset:1px}
.contexto{padding:5px 16px;font-size:12px;color:var(--cinza);background:#fbfcfd;border-bottom:1px solid var(--borda)}
.contexto b{color:var(--txt)}
.abas{display:flex;gap:2px;padding:0 16px;background:#fff;border-bottom:1px solid var(--borda);flex-wrap:wrap}
.abas button{background:none;border:none;border-bottom:3px solid transparent;color:var(--cinza);border-radius:0;padding:9px 12px;font-weight:600}
.abas button.ativa{color:var(--azul);border-bottom-color:var(--azul)}
main{padding:12px 16px}
.kpis{display:grid;grid-template-columns:repeat(auto-fill,minmax(205px,1fr));gap:8px;margin-bottom:10px}
.kpi{background:#fff;border:1px solid var(--borda);border-radius:6px;padding:9px 11px;border-left:4px solid var(--azul)}
.kpi-t{font-size:12px;color:var(--cinza);font-weight:600}
.kpi-v{font-size:20px;font-weight:700;margin:3px 0 2px}
.kpi-s{font-size:11px;color:var(--cinza);line-height:1.4}
.kpi.k-crit{border-left-color:var(--verm)}
.kpi.k-aviso{border-left-color:#c99a2e}
.kpi.indisp{border-left-color:#9aa5b1;background:#fafbfc}
.kpi.indisp .kpi-v{font-size:13px;color:var(--amar);font-weight:600}
.kpi.falha{border-left-color:var(--verm)}
.kpi.falha .kpi-v{font-size:13px;color:var(--verm)}
details.def{margin-top:4px;font-size:11px;color:var(--cinza)}
details.def summary{cursor:pointer;color:var(--azul)}
.card{background:#fff;border:1px solid var(--borda);border-radius:6px;padding:10px 12px;margin-bottom:10px;overflow:auto}
.grid2{display:grid;grid-template-columns:repeat(auto-fit,minmax(400px,1fr));gap:10px}
table{border-collapse:separate;border-spacing:0;width:100%;font-size:12px}
th,td{padding:4px 6px;border-bottom:1px solid #edf0f3;text-align:left;white-space:nowrap;vertical-align:top}
th{position:sticky;top:0;background:#f2f5f8;color:var(--cinza);font-weight:600;z-index:2}
th.ord{cursor:pointer;user-select:none}
th.ord:after{content:" \2195";color:#b0bac4}
th[aria-sort=ascending]:after{content:" \25B2";color:var(--azul)}
th[aria-sort=descending]:after{content:" \25BC";color:var(--azul)}
td.n,th.n{text-align:right}
td.prod{max-width:300px;overflow:hidden;text-overflow:ellipsis}
tr.lin{cursor:pointer}
tr.lin:hover td{background:#f7fafd}
tr.lin.aberta td{background:#eef4fb}
tr.det td{background:#fbfcfe;white-space:normal;padding:10px 14px;border-bottom:2px solid var(--azul)}
.chip{display:inline-block;padding:1px 7px;border-radius:9px;font-size:11px;font-weight:700;border:1px solid transparent}
.chip.P1_CRITICO{background:#fdecea;color:var(--verm);border-color:#f3b8b2}
.chip.P2_RUPTURA_IMINENTE{background:#fff1e6;color:var(--laranja);border-color:#f7c8a3}
.chip.P3_ATENCAO{background:#fff8db;color:var(--amar);border-color:#ecd98a}
.chip.REVISAR_SEM_GIRO{background:#f1ecfb;color:#5b3a99;border-color:#d3c4ef}
.chip.P0_EXCESSO,.chip.P0_SEM_GIRO{background:#e8f0fb;color:var(--azul);border-color:#bcd0ea}
.chip.OK{background:#e9f6ec;color:var(--verde);border-color:#bfe3c8}
.tag{display:inline-block;font-size:10.5px;padding:0 5px;border-radius:3px;margin:0 2px 1px 0;background:#f0f2f5;color:#4a5562;border:1px solid #dfe4ea}
.tag.q{background:#fff4e0;color:var(--amar);border-color:#f1d7a6}
.tabwrap{max-height:64vh;overflow:auto;border:1px solid var(--borda);border-radius:6px;background:#fff}
.av{margin:6px 16px 0;padding:6px 10px;border-radius:5px;font-size:12px;border-left:4px solid}
.av-info{background:#eef4fb;color:var(--azul);border-color:#7fa6d4}
.av-aviso{background:#fff7e8;color:var(--amar);border-color:#e0b155}
.av-alerta{background:#fdecea;color:var(--verm);border-color:#e57e73}
.erro{background:#fdecea;color:var(--verm);padding:8px 10px;border-radius:5px;font-size:12px;white-space:normal}
.erro .cod{font-family:Consolas,monospace;font-size:11px;color:#7a271a}
.vazio{color:var(--cinza);padding:10px;font-style:italic}
.indisp{color:var(--amar);font-weight:600}
.carregando{color:var(--cinza);font-style:italic;padding:6px 0}
.carregando:before{content:"\23F3 "}
.nota{font-size:11px;color:var(--cinza);margin-top:6px;line-height:1.5}
.resumo{font-size:12px;color:var(--txt);margin:4px 0 6px;line-height:1.5}
.faixa-aviso{background:#fff7e8;border:1px solid #f1d7a6;color:var(--amar);padding:6px 10px;border-radius:5px;margin-bottom:8px;font-size:12px}
.ctl{display:flex;gap:8px;flex-wrap:wrap;align-items:center;margin-bottom:8px}
.bar{display:inline-block;height:9px;border-radius:2px;vertical-align:middle;margin-right:6px;background:var(--azul)}
.funil .et{display:grid;grid-template-columns:230px 1fr 250px;gap:8px;align-items:center;margin:5px 0}
.funil .bx{height:18px;border-radius:3px;background:var(--azul);min-width:2px}
.det-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(310px,1fr));gap:10px 22px}
.det-grid dl{margin:0;display:grid;grid-template-columns:auto auto;gap:2px 10px;font-size:12px}
.det-grid dt{color:var(--cinza)}
.det-grid dd{margin:0;text-align:right;font-variant-numeric:tabular-nums}
.det-grid dd.txt{text-align:left}
.lista-motivos{margin:4px 0 0 18px;padding:0;font-size:12px}
.bloqueio{max-width:680px;margin:40px auto;background:#fff;border:1px solid var(--borda);border-radius:8px;padding:22px;text-align:center;line-height:1.6}
footer{padding:8px 16px 16px;font-size:11px;color:#7d8a97}
svg text{font-size:12px;fill:#1d2733}
.hm td.v{text-align:right;min-width:50px}
.hm td.fora{color:#b8c1ca;text-align:center}
.hm th.parcial,.hm td.parcial{background:#fafafa;color:#8a99a8}
.pos{color:var(--verm);font-weight:600}.neg{color:var(--verde);font-weight:600}
textarea{width:100%;height:160px;font-family:Consolas,monospace;font-size:11px}
code{font-family:Consolas,monospace;font-size:11px;background:#f2f4f7;padding:0 3px;border-radius:3px}
.det-box{position:sticky;left:14px;max-width:calc(100vw - 80px)}
.det-grid dl{grid-template-columns:minmax(150px,3fr) minmax(90px,2fr)}
.det-grid dd{white-space:normal;overflow-wrap:anywhere}
.hm .fixa{position:sticky;left:0;background:#fff;z-index:1;box-shadow:1px 0 0 #edf0f3}
.hm th.fixa{z-index:3;background:#f2f5f8}

</style>
<script>
window.PARAMETROS_BI = {
  PERIODO_INI: "${PERIODO.INI}",
  PERIODO_FIN: "${PERIODO.FIN}",
  CODEMP: "${CODEMP}"
};
</script>
</head>
<body>
<header class="topo">
  <div class="marca">
    <h1>Acompanhamento de Abertura de OC</h1>
    <span class="selo selo-alerta" title="Nenhum roteiro de homologa&#xE7;&#xE3;o foi executado no Construtor de BI. Ver HOMOLOGACAO.md.">N&#xC3;O HOMOLOGADO</span>
    <span class="selo selo-aviso" title="N&#xE3;o h&#xE1; classificador PRG/JIT validado. A fila &#xE9; an&#xE1;lise, n&#xE3;o autoriza&#xE7;&#xE3;o de compra.">POL&#xCD;TICA PRG/JIT N&#xC3;O VALIDADA</span>
    <span class="selo selo-demo" id="selo-demo" hidden>MODO DEMONSTRA&#xC7;&#xC3;O &#xB7; DADOS SIMULADOS</span>
  </div>
  <form class="filtros" id="f-filtros" autocomplete="off">
    <label>Empresa <input type="text" inputmode="numeric" id="f-codemp" style="width:72px" placeholder="todas" maxlength="6"></label>
    <label title="Per&#xED;odo usado nos indicadores de fluxo de OC (funil, pontualidade). A posi&#xE7;&#xE3;o de estoque e a fila usam sempre a data do banco.">Fluxo de OC de <input type="date" id="f-ini"></label>
    <label>at&#xE9; <input type="date" id="f-fim"></label>
    <button type="submit">Aplicar</button>
    <button type="button" class="sec" id="b-atualizar" title="Descarta o cache e consulta o banco de novo">Atualizar dados</button>
  </form>
</header>
<div class="contexto" id="contexto" aria-live="polite"></div>
<div id="avisos" role="status"></div>
<nav class="abas" id="abas" role="tablist">
  <button type="button" role="tab" data-pg="exec" class="ativa">Vis&#xE3;o geral</button>
  <button type="button" role="tab" data-pg="fila">Fila de an&#xE1;lise</button>
  <button type="button" role="tab" data-pg="carteira">Carteira de OC</button>
  <button type="button" role="tab" data-pg="consumo">Consumo e m&#xE9;dia</button>
  <button type="button" role="tab" data-pg="param">Par&#xE2;metros e qualidade</button>
</nav>
<main id="conteudo">
  <div class="bloqueio" id="bloqueio" hidden></div>

  <section id="pg-exec" class="pg" role="tabpanel">
    <div class="kpis" id="exec-kpis"></div>
    <div class="grid2">
      <div class="card"><h3>Itens por prioridade (todos os itens do c&#xE1;lculo)</h3><div id="exec-prio"></div></div>
      <div class="card"><h3>Precisa de aten&#xE7;&#xE3;o agora</h3><div id="exec-top"></div></div>
    </div>
    <div class="card"><h3>Qualidade dos dados que afetam a decis&#xE3;o</h3><div id="exec-qual"></div></div>
    <div class="nota" id="exec-nota"></div>
  </section>

  <section id="pg-fila" class="pg" role="tabpanel" hidden>
    <div class="faixa-aviso">Fila de <b>an&#xE1;lise</b>: n&#xE3;o &#xE9; autoriza&#xE7;&#xE3;o de compra. Pol&#xED;tica PRG/JIT, par&#xE2;metros e regras de cobertura ainda n&#xE3;o foram aprovados.</div>
    <div class="ctl">
      <label>Universo <select id="ff-universo">
        <option value="ATENCAO">Precisa de aten&#xE7;&#xE3;o (P1&#x2013;P3 ou necessidade)</option>
        <option value="REVISAR">Revisar dados</option>
        <option value="EXCESSO">Excesso e sem giro</option>
        <option value="TODOS">Todos os itens</option>
      </select></label>
      <label>Prioridade <select id="ff-prio"></select></label>
      <label>Motivo <select id="ff-motivo"></select></label>
      <label>Grupo <select id="ff-grupo"></select></label>
      <label>Busca <input type="search" id="ff-busca" placeholder="c&#xF3;digo ou descri&#xE7;&#xE3;o" style="width:170px"></label>
      <button type="button" id="ff-csv">Exportar CSV</button>
      <button type="button" class="sec" id="ff-vercsv">Ver CSV (copiar)</button>
    </div>
    <div id="fila-resumo" class="resumo"></div>
    <div class="tabwrap" id="fila-tab"></div>
    <div id="fila-csvbox" hidden><textarea id="fila-csvtxt" readonly aria-label="CSV da fila"></textarea></div>
    <div class="nota">Clique numa linha para ver o c&#xE1;lculo completo do produto. Quantidades na unidade padr&#xE3;o do produto; itens com unidade n&#xE3;o conciliada ficam fora das quantidades e aparecem marcados. Datas de falta s&#xE3;o <b>estimativas agregadas</b> (consumo m&#xE9;dio constante), n&#xE3;o datas garantidas.</div>
  </section>

  <section id="pg-carteira" class="pg" role="tabpanel" hidden>
    <div class="kpis" id="cart-kpis"></div>
    <div class="grid2">
      <div class="card"><h3>Funil dos itens de OC negociados no per&#xED;odo</h3><div id="cart-funil"></div></div>
      <div class="card"><h3>Idade da carteira aberta (valor do saldo)</h3><div id="cart-aging"></div></div>
    </div>
    <div class="grid2">
      <div class="card"><h3>Qualidade do v&#xED;nculo de recebimento (itens com atendimento no per&#xED;odo)</h3><div id="cart-vinculo"></div></div>
      <div class="card"><h3>Alertas da carteira</h3><div id="cart-qual"></div></div>
    </div>
    <div class="card"><h3>OCs abertas que n&#xE3;o cobrem a necessidade do produto</h3><div id="cart-naocobre"></div></div>
    <div class="card"><h3>Itens de OC com saldo aberto</h3>
      <div class="ctl">
        <label>Recorte <select id="fo-filtro">
          <option value="ATRASADAS">Previs&#xE3;o vencida</option>
          <option value="SEM_PREVISAO">Sem previs&#xE3;o</option>
          <option value="NAO_CONFIRMADAS">N&#xE3;o confirmadas / aprova&#xE7;&#xE3;o n&#xE3;o determinada</option>
          <option value="ANTIGAS">Antigas ainda abertas</option>
          <option value="TODAS">Todas as abertas</option>
        </select></label>
        <label>Busca <input type="search" id="fo-busca" placeholder="OC, produto ou fornecedor" style="width:190px"></label>
        <button type="button" id="fo-csv">Exportar CSV</button>
      </div>
      <div id="oc-resumo" class="resumo"></div>
      <div class="tabwrap" id="oc-tab"></div>
    </div>
  </section>

  <section id="pg-consumo" class="pg" role="tabpanel" hidden>
    <div class="ctl">
      <label>Produtos <select id="fc-topn"><option>50</option><option selected>100</option><option>200</option></select></label>
      <label>Busca <input type="search" id="fc-busca" placeholder="c&#xF3;digo ou descri&#xE7;&#xE3;o" style="width:170px"></label>
      <button type="button" class="sec" id="fc-csv">Exportar formato longo (CSV)</button>
    </div>
    <div id="cons-info" class="resumo"></div>
    <div class="tabwrap" id="cons-tab"></div>
    <div class="nota" id="cons-nota"></div>
  </section>

  <section id="pg-param" class="pg" role="tabpanel" hidden>
    <div class="card"><h3>Painel de qualidade</h3><div id="par-qual"></div></div>
    <div class="card"><h3>Par&#xE2;metros do c&#xE1;lculo (nenhum aprovado)</h3><div id="par-tab"></div></div>
    <div class="card"><h3>Mapeamentos de TOP e locais (configura&#xE7;&#xE3;o do build)</h3><div id="par-map"></div></div>
    <div class="card"><h3>Diagn&#xF3;stico</h3><div id="par-diag"></div></div>
    <div class="card"><h3>Consultas executadas nesta sess&#xE3;o</h3><div id="par-log"></div></div>
  </section>
</main>
<footer id="rodape">Somente leitura: o painel executa apenas SELECT e n&#xE3;o grava nada no Sankhya. N&#xE3;o homologado. Vers&#xE3;o 2.0.0-nao-homologado &#xB7; build 10db84899dd53b95.</footer>
<a id="dl" href="#" hidden>download</a>
<script>
(function () {
"use strict";
var BUILD = {"versao":"2.0.0-nao-homologado","hash":"10db84899dd53b95"};
var CONFIG = {"versao":"2.0.0-nao-homologado","titulo":"Acompanhamento de Abertura de OC","papeisTop":{"CONSUMO":{"tops":[1131,1118,1117,1729,1130,1727,1724,1730,1781,1782,1738],"origem":"painel original","validado":false},"DEVOLUCAO":{"tops":[1200,1201,1211,1206],"origem":"painel original","validado":false},"PERDA":{"tops":[],"origem":"nenhuma TOP mapeada no original; perdas NÃO entram no consumo até alguém mapear","validado":false},"EMPENHO":{"tops":[1000,1005,1008,1002,1009,1001,1728,1010],"origem":"painel original (pedidos/empenhos pendentes usados como compromisso)","validado":false},"ORDEM_COMPRA":{"tops":[99,100,101,108,1741,1742],"origem":"painel original","validado":false},"COTACAO":{"tops":[],"origem":"nenhuma fonte de cotação mapeada; 'necessidade em negociação' fica como NÃO DISPONÍVEL","validado":false},"ENTRADA_POR_OS":{"tops":[259,200],"origem":"painel original (fallback de recebimento por OS + produto; vínculo apenas inferido)","validado":false}},"topsPrecoSeparado":[1741],"locaisExcluidos":[1030000,2030000],"limites":{"LIMITE_FILA":1000,"LIMITE_OC":300,"TOPN_CONSUMO":100},"timeoutSegundos":180,"consultasSimultaneas":2,"codigoAntigoHabilitado":false,"parametros":[{"chave":"DIAS_MES","padrao":30,"min":1,"max":31,"inteiro":false,"escala":10000,"status":"LEGADO_NAO_APROVADO","descricao":"Dias por mês na conversão média mensal → demanda diária (30 = dias corridos, coerente com lead time em dias corridos)."},{"chave":"MESES_MEDIA","padrao":12,"min":1,"max":24,"inteiro":true,"status":"LEGADO_NAO_APROVADO","descricao":"Quantidade de meses COMPLETOS na janela de consumo."},{"chave":"MES_PARCIAL","padrao":0,"min":0,"max":1,"inteiro":true,"status":"PROPOSTA_NAO_APROVADA","descricao":"0 = só meses completos (recomendado). 1 = inclui o mês corrente até ontem, proporcional aos dias decorridos (só na média simples)."},{"chave":"MEDIA_MODO","padrao":0,"min":0,"max":1,"inteiro":true,"status":"LEGADO_NAO_APROVADO","descricao":"0 = média simples; 1 = ponderada por mês (pesos sobrepostos 0,5·M3 + 0,3·M6 + 0,2·Mjanela, normalizados ao histórico do produto)."},{"chave":"MIN_MESES_HIST","padrao":3,"min":1,"max":24,"inteiro":true,"status":"PROPOSTA_NAO_APROVADA","descricao":"Abaixo deste número de meses de série o produto é marcado como HISTÓRICO INSUFICIENTE. Não pode ser maior que MESES_MEDIA."},{"chave":"LEADTIME_DEFAULT","padrao":30,"min":0,"max":365,"inteiro":true,"status":"LEGADO_NAO_APROVADO","descricao":"Lead time (dias) usado quando TGFPRO.LEADTIME está vazio ou zero."},{"chave":"COBERTURA_ALVO_A","padrao":45,"min":0,"max":365,"inteiro":true,"status":"LEGADO_NAO_APROVADO","descricao":"Cobertura alvo (dias) da curva A. Só é usada se houver curva (ABC_CALCULADA = 1)."},{"chave":"COBERTURA_ALVO_B","padrao":30,"min":0,"max":365,"inteiro":true,"status":"LEGADO_NAO_APROVADO","descricao":"Cobertura alvo (dias) da curva B."},{"chave":"COBERTURA_ALVO_C","padrao":21,"min":0,"max":365,"inteiro":true,"status":"LEGADO_NAO_APROVADO","descricao":"Cobertura alvo (dias) da curva C."},{"chave":"COBERTURA_SEM_CURVA","padrao":21,"min":0,"max":365,"inteiro":true,"status":"PROPOSTA_NAO_APROVADA","descricao":"Cobertura alvo (dias) para produto SEM curva. Categoria própria: não é a curva C (o valor inicial apenas repete o número antigo)."},{"chave":"POLITICA_SEGURANCA","padrao":1,"min":0,"max":2,"inteiro":true,"status":"PROPOSTA_NAO_APROVADA","descricao":"Única política de estoque de segurança: 0 = nenhuma; 1 = fração da demanda do lead time (SEGURANCA_PCT_LT); 2 = estoque mínimo do cadastro (TGFPRO.ESTMIN)."},{"chave":"SEGURANCA_PCT_LT","padrao":0.2,"min":0,"max":1,"inteiro":false,"escala":10000,"status":"LEGADO_NAO_APROVADO","descricao":"Fração da demanda do lead time usada como segurança quando POLITICA_SEGURANCA = 1 (0,20 = 20%, valor do painel antigo, nunca aprovado)."},{"chave":"MARGEM_ATENCAO_DIAS","padrao":15,"min":0,"max":365,"inteiro":true,"status":"LEGADO_NAO_APROVADO","descricao":"Dias de demanda acima do ponto de pedido que ainda geram P3 (atenção)."},{"chave":"COBERTURA_MAX_DIAS","padrao":90,"min":1,"max":3650,"inteiro":true,"status":"LEGADO_NAO_APROVADO","descricao":"Cobertura com OC confirmada acima deste número de dias = P0 excesso."},{"chave":"FONTE_COMPROMISSO","padrao":1,"min":1,"max":2,"inteiro":true,"status":"LEGADO_NAO_APROVADO","descricao":"Uma única fonte de compromisso (nunca as duas): 1 = pedidos pendentes nas TOPs de empenho (como o original); 2 = TGFEST.RESERVADO."},{"chave":"DESCONTA_BLOQUEADO","padrao":0,"min":0,"max":1,"inteiro":true,"status":"LEGADO_NAO_APROVADO","descricao":"1 = desconta TGFEST.WMSBLOQUEADO do estoque utilizável. O original não descontava."},{"chave":"REGRA_PREVISAO_FIRME","padrao":1,"min":1,"max":2,"inteiro":true,"status":"PROPOSTA_NAO_APROVADA","descricao":"Como combinar demanda estatística e compromissos firmes: 1 = MAIOR entre os dois (evita dupla contagem); 2 = SOMA (comportamento antigo). Os dois cenários são sempre exibidos."},{"chave":"LOTE_MULTIPLO","padrao":0,"min":0,"max":1,"inteiro":true,"status":"PROPOSTA_NAO_APROVADA","descricao":"1 = aplica lote mínimo (LOTECOMPMINIMO) e múltiplo (AGRUPMIN) do cadastro. 0 = não aplica, porque a unidade desses campos não foi comprovada."},{"chave":"ABC_CALCULADA","padrao":0,"min":0,"max":1,"inteiro":true,"status":"PROPOSTA_NAO_APROVADA","descricao":"1 = calcula curva ABC por valor de consumo líquido da janela × preço de referência de compra (não é faturamento). 0 = sem curva."},{"chave":"ABC_LIMITE_A","padrao":0.8,"min":0.01,"max":0.99,"inteiro":false,"escala":10000,"status":"PROPOSTA_NAO_APROVADA","descricao":"Participação acumulada (antes do item) até a qual o item é curva A."},{"chave":"ABC_LIMITE_B","padrao":0.95,"min":0.01,"max":0.999,"inteiro":false,"escala":10000,"status":"PROPOSTA_NAO_APROVADA","descricao":"Participação acumulada (antes do item) até a qual o item é curva B. Deve ser maior que ABC_LIMITE_A."},{"chave":"OC_ANTIGA_MESES","padrao":12,"min":1,"max":120,"inteiro":true,"status":"PROPOSTA_NAO_APROVADA","descricao":"OC aberta negociada há mais que este número de meses é sinalizada como antiga (continua no cálculo)."},{"chave":"TOLERANCIA_ATRASO_DIAS","padrao":0,"min":0,"max":60,"inteiro":true,"status":"PROPOSTA_NAO_APROVADA","descricao":"Dias de tolerância no indicador aproximado de atendimento até a previsão (não é OTIF)."}],"especiais":[{"chave":"CODEMP","tipo":"I","descricao":"Empresa (0 = todas)."},{"chave":"DT_INI","tipo":"D","descricao":"Início do período de fluxo (YYYY-MM-DD)."},{"chave":"DT_FIM","tipo":"D","descricao":"Fim do período de fluxo, inclusive (YYYY-MM-DD)."},{"chave":"LIMITE_FILA","tipo":"I","descricao":"Máximo de linhas da fila trazidas para a tela."},{"chave":"LIMITE_OC","tipo":"I","descricao":"Máximo de itens de OC na lista."},{"chave":"TOPN_CONSUMO","tipo":"I","descricao":"Produtos na matriz de consumo."},{"chave":"CODPROD_FILTRO","tipo":"I","descricao":"0 = todos; >0 = um produto (detalhe)."},{"chave":"FILTRO_FILA","tipo":"C","valores":["ATENCAO","EXCESSO","REVISAR","TODOS"],"descricao":"Universo da fila (lista fechada)."},{"chave":"FILTRO_OC","tipo":"C","valores":["ATRASADAS","SEM_PREVISAO","NAO_CONFIRMADAS","ANTIGAS","TODAS"],"descricao":"Recorte da lista de OC (lista fechada)."},{"chave":"DIAG_NUM","tipo":"I","descricao":"Número fixo do teste de executeQuery."}],"chavesLegadas":{"DIVISOR_MEDIA":"Removido: o divisor global criava viés. O divisor agora é por produto (ver REGRAS_DE_CALCULO.md).","INCLUI_MES_ATUAL":"Ignorado: no original o mês corrente parcial contava como mês inteiro. Use MES_PARCIAL (semântica nova, proporcional).","JANELA_VINCULO_DIAS":"Removido: aderência por proximidade de datas não comprova atendimento (indicador indisponível)."}};
var Q = {"Q_CARTEIRA":{"sql":"WITH prm AS ( SELECT CAST(TO_NUMBER(?) AS INTEGER) AS CODEMP, TO_DATE(?, 'YYYY-MM-DD') AS DT_INI, TO_DATE(?, 'YYYY-MM-DD') AS DT_FIM, CAST(TO_NUMBER(?) AS INTEGER) AS TOLERANCIA_ATRASO_DIAS, CAST(TO_NUMBER(?) AS INTEGER) AS OC_ANTIGA_MESES FROM DUAL ), tops AS ( SELECT 1131 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1118 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1117 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1729 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1130 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1727 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1724 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1730 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1781 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1782 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1738 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1200 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1201 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1211 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1206 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1000 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1005 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1008 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1002 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1009 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1001 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1728 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1010 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 99 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 100 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 101 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 108 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1741 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'SEPARADO' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1742 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 259 AS CODTIPOPER, 'ENTRADA_POR_OS' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 200 AS CODTIPOPER, 'ENTRADA_POR_OS' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL ), jan AS ( SELECT TRUNC(SYSDATE) AS DT_BASE, TRUNC(SYSDATE, 'MM') AS M0, TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI') AS SNAPSHOT FROM DUAL ), voa AS ( SELECT V.CODPROD, V.CODVOL, MAX(V.DIVIDEMULTIPLICA) AS DM, MAX(V.QUANTIDADE) AS QC, COUNT(DISTINCT NVL(V.DIVIDEMULTIPLICA, '-') || '|' || NVL(CAST(V.QUANTIDADE AS VARCHAR(40)), '-')) AS N_REGRAS FROM TGFVOA V WHERE NVL(V.ATIVO, 'S') = 'S' GROUP BY V.CODPROD, V.CODVOL ), occ_it AS ( SELECT C.NUNOTA, I.SEQUENCIA, C.CODEMP, C.CODTIPOPER, C.DHTIPOPER, C.CODPARC, TP.GRUPO_PRECO, I.CODPROD, C.STATUSNOTA, TRUNC(C.DTNEG) AS DT_NEG, TRUNC(C.DTPREVENT) AS DT_PREV, NVL(I.PENDENTE, 'S') AS PENDENTE, NVL(I.CANCELADO, 'N') AS CANCELADO, NVL(I.QTDNEG, 0) AS QTDNEG, NVL(I.QTDENTREGUE, 0) AS QTDENT, NVL(I.VLRTOT, 0) AS VLRTOT, I.CODVOL AS UNID_ITEM, P.CODVOL AS UNID_PADRAO, CASE WHEN P.LEADTIME > 0 THEN P.LEADTIME END AS LT_CAD, NULLIF(TRIM(C.AD_OSTUICIAL), '') AS OS, (CASE WHEN I.CODVOL = P.CODVOL THEN 1 WHEN VO.N_REGRAS = 1 AND VO.DM = 'M' AND VO.QC > 0 THEN VO.QC WHEN VO.N_REGRAS = 1 AND VO.DM = 'D' AND VO.QC > 0 THEN 1 / VO.QC END) AS FATOR, (CASE WHEN I.CODVOL IS NULL THEN 'SEM_UNIDADE' WHEN I.CODVOL = P.CODVOL THEN 'PADRAO' WHEN VO.CODPROD IS NULL THEN 'SEM_REGRA' WHEN VO.N_REGRAS > 1 THEN 'AMBIGUA' WHEN VO.DM = 'M' AND VO.QC > 0 THEN 'MULTIPLICA' WHEN VO.DM = 'D' AND VO.QC > 0 THEN 'DIVIDE' ELSE 'REGRA_INVALIDA' END) AS STATUS_CONV, CASE WHEN C.DTNEG >= PR.DT_INI AND C.DTNEG < PR.DT_FIM + 1 THEN 1 ELSE 0 END AS FL_PERIODO, CASE WHEN (NVL(I.PENDENTE, 'S') = 'S' AND NVL(I.CANCELADO, 'N') <> 'S' AND NVL(I.QTDNEG, 0) > NVL(I.QTDENTREGUE, 0)) THEN 1 ELSE 0 END AS FL_ABERTO FROM TGFCAB C JOIN tops TP ON TP.CODTIPOPER = C.CODTIPOPER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA JOIN TGFPRO P ON P.CODPROD = I.CODPROD LEFT JOIN voa VO ON VO.CODPROD = I.CODPROD AND VO.CODVOL = I.CODVOL CROSS JOIN prm PR WHERE TP.PAPEL = 'ORDEM_COMPRA' AND (PR.CODEMP = 0 OR C.CODEMP = PR.CODEMP) AND ((C.DTNEG >= PR.DT_INI AND C.DTNEG < PR.DT_FIM + 1) OR (NVL(I.PENDENTE, 'S') = 'S' AND NVL(I.CANCELADO, 'N') <> 'S' AND NVL(I.QTDNEG, 0) > NVL(I.QTDENTREGUE, 0))) ), occ_lib AS ( SELECT L.NUCHAVE, SUM(CASE WHEN L.DHLIB IS NULL AND NVL(L.REPROVADO, 'N') <> 'S' THEN 1 ELSE 0 END) AS N_LIB_PEND, SUM(CASE WHEN NVL(L.REPROVADO, 'N') = 'S' THEN 1 ELSE 0 END) AS N_LIB_REPROV FROM TSILIB L WHERE L.TABELA = 'TGFCAB' AND L.NUCHAVE IN (SELECT OI.NUNOTA FROM occ_it OI) GROUP BY L.NUCHAVE ), occ_var AS ( SELECT V.NUNOTAORIG, V.SEQUENCIAORIG, COUNT(DISTINCT V.NUNOTA) AS N_DERIV, MAX(TRUNC(N.DTNEG)) AS DT_ULT_DERIV FROM TGFVAR V JOIN TGFCAB N ON N.NUNOTA = V.NUNOTA WHERE N.STATUSNOTA = 'L' AND V.NUNOTA <> V.NUNOTAORIG AND V.NUNOTAORIG IN (SELECT OI.NUNOTA FROM occ_it OI) GROUP BY V.NUNOTAORIG, V.SEQUENCIAORIG ), occ_os_par AS ( SELECT O.NUNOTA, O.SEQUENCIA, E.NUNOTA AS NUNOTA_ENT, E.SEQUENCIA AS SEQ_ENT, TRUNC(N.DTNEG) AS DT_ENT FROM occ_it O JOIN TGFITE E ON E.CODPROD = O.CODPROD AND NULLIF(TRIM(E.AD_OS), '') = O.OS JOIN TGFCAB N ON N.NUNOTA = E.NUNOTA JOIN tops TE ON TE.CODTIPOPER = N.CODTIPOPER WHERE TE.PAPEL = 'ENTRADA_POR_OS' AND O.OS IS NOT NULL AND N.STATUSNOTA = 'L' AND N.DTNEG >= O.DT_NEG ), occ_os AS ( SELECT X.NUNOTA, X.SEQUENCIA, COUNT(*) AS N_ENT_OS, MAX(X.DT_ENT) AS DT_ULT_ENT_OS, MAX(X.N_OC_MESMA_ENT) AS MAX_OC_MESMA_ENT FROM (SELECT Y.NUNOTA, Y.SEQUENCIA, Y.DT_ENT, COUNT(*) OVER (PARTITION BY Y.NUNOTA_ENT, Y.SEQ_ENT) AS N_OC_MESMA_ENT FROM occ_os_par Y) X GROUP BY X.NUNOTA, X.SEQUENCIA ), occ AS ( SELECT O.NUNOTA, O.SEQUENCIA, O.CODEMP, O.CODTIPOPER, O.DHTIPOPER, O.CODPARC, O.GRUPO_PRECO, O.CODPROD, O.STATUSNOTA, O.DT_NEG, O.DT_PREV, O.PENDENTE, O.CANCELADO, O.QTDNEG, O.QTDENT, O.VLRTOT, O.UNID_ITEM, O.UNID_PADRAO, O.OS, O.FATOR, O.STATUS_CONV, O.FL_PERIODO, O.FL_ABERTO, CASE WHEN O.LT_CAD IS NOT NULL THEN TRUNC(O.DT_NEG + O.LT_CAD) END AS DT_PREV_ESTIMADA, NVL(LB.N_LIB_PEND, 0) AS N_LIB_PEND, NVL(LB.N_LIB_REPROV, 0) AS N_LIB_REPROV, (CASE WHEN O.STATUSNOTA = 'L' AND NVL(LB.N_LIB_PEND, 0) = 0 AND NVL(LB.N_LIB_REPROV, 0) = 0 THEN 'CONFIRMADA' WHEN O.STATUSNOTA = 'L' THEN 'APROVACAO_NAO_DETERMINADA' ELSE 'NAO_CONFIRMADA' END) AS SITUACAO, (CASE WHEN O.DT_PREV IS NULL THEN 'SEM_PREVISAO' WHEN O.DT_PREV < JA.DT_BASE THEN 'ATRASADA' ELSE 'NO_PRAZO' END) AS PRAZO, (CASE WHEN O.CANCELADO = 'S' THEN 'CANCELADA' WHEN O.QTDNEG > 0 AND O.QTDENT >= O.QTDNEG THEN 'ATENDIDA_INTEGRAL' WHEN O.PENDENTE = 'N' AND O.QTDENT > 0 THEN 'ENCERRADA_COM_SALDO' WHEN O.PENDENTE = 'N' THEN 'ENCERRADA_SEM_ATENDIMENTO' WHEN O.QTDENT > 0 THEN 'ATENDIMENTO_PARCIAL' ELSE 'ABERTA_SEM_ATENDIMENTO' END) AS STATUS_ITEM, CASE WHEN O.FL_ABERTO = 1 AND O.DT_PREV < JA.DT_BASE THEN JA.DT_BASE - O.DT_PREV END AS DIAS_ATRASO, JA.DT_BASE - O.DT_NEG AS IDADE_DIAS, CASE WHEN O.DT_NEG < ADD_MONTHS(JA.DT_BASE, -PR.OC_ANTIGA_MESES) THEN 1 ELSE 0 END AS FL_ANTIGA, CASE WHEN O.FL_ABERTO = 1 AND O.QTDNEG > 0 THEN O.VLRTOT * (O.QTDNEG - O.QTDENT) / O.QTDNEG ELSE 0 END AS VLR_SALDO, CASE WHEN O.FL_ABERTO = 1 AND O.FATOR IS NOT NULL THEN (O.QTDNEG - O.QTDENT) * O.FATOR END AS SALDO_BASE, CASE WHEN O.PENDENTE = 'N' AND O.CANCELADO <> 'S' AND O.QTDENT > 0 AND O.QTDENT < O.QTDNEG THEN O.QTDNEG - O.QTDENT ELSE 0 END AS SALDO_ENCERRADO_ORIG, CASE WHEN O.QTDENT > O.QTDNEG THEN 1 ELSE 0 END AS FL_ACIMA_NEGOCIADO, NVL(VA.N_DERIV, 0) AS N_DERIV, VA.DT_ULT_DERIV, NVL(OSX.N_ENT_OS, 0) AS N_ENT_OS, OSX.DT_ULT_ENT_OS, NVL(OSX.MAX_OC_MESMA_ENT, 0) AS MAX_OC_MESMA_ENT, CASE WHEN NVL(VA.N_DERIV, 0) > 0 THEN 'NATIVO_TGFVAR' WHEN NVL(OSX.N_ENT_OS, 0) > 0 AND NVL(OSX.MAX_OC_MESMA_ENT, 0) > 1 THEN 'INFERIDO_OS_COMPARTILHADO' WHEN NVL(OSX.N_ENT_OS, 0) > 0 THEN 'INFERIDO_OS' WHEN O.QTDENT > 0 THEN 'ATENDIMENTO_SEM_VINCULO' ELSE 'SEM_ATENDIMENTO' END AS QUALIDADE_VINC FROM occ_it O LEFT JOIN occ_lib LB ON LB.NUCHAVE = O.NUNOTA LEFT JOIN occ_var VA ON VA.NUNOTAORIG = O.NUNOTA AND VA.SEQUENCIAORIG = O.SEQUENCIA LEFT JOIN occ_os OSX ON OSX.NUNOTA = O.NUNOTA AND OSX.SEQUENCIA = O.SEQUENCIA CROSS JOIN jan JA CROSS JOIN prm PR ), occ_fx AS ( SELECT O.NUNOTA, O.VLR_SALDO, CASE WHEN O.IDADE_DIAS <= 15 THEN '1_0_15' WHEN O.IDADE_DIAS <= 30 THEN '2_16_30' WHEN O.IDADE_DIAS <= 60 THEN '3_31_60' WHEN O.IDADE_DIAS <= 180 THEN '4_61_180' ELSE '5_181_MAIS' END AS FAIXA FROM occ O WHERE O.FL_ABERTO = 1 ), occ_pont AS ( SELECT O.NUNOTA, O.VLRTOT, CASE WHEN O.STATUS_ITEM = 'ATENDIDA_INTEGRAL' AND O.N_DERIV > 0 AND O.DT_ULT_DERIV <= O.DT_PREV + PR.TOLERANCIA_ATRASO_DIAS THEN 'INTEGRAL_NO_PRAZO' WHEN O.STATUS_ITEM = 'ATENDIDA_INTEGRAL' AND O.N_DERIV > 0 THEN 'INTEGRAL_FORA_PRAZO' WHEN O.STATUS_ITEM = 'ATENDIDA_INTEGRAL' THEN 'EXCLUIDO_SEM_DATA_CONFIAVEL' WHEN O.STATUS_ITEM IN ('ENCERRADA_COM_SALDO', 'ENCERRADA_SEM_ATENDIMENTO') THEN 'ENCERRADA_SEM_INTEGRAL' ELSE 'NAO_ATENDIDA_VENCIDA' END AS CLASSE FROM occ O CROSS JOIN prm PR CROSS JOIN jan JA WHERE O.SITUACAO = 'CONFIRMADA' AND O.CANCELADO <> 'S' AND O.QTDNEG > 0 AND O.DT_PREV >= PR.DT_INI AND O.DT_PREV < PR.DT_FIM + 1 AND O.DT_PREV < JA.DT_BASE ), occ_q AS ( SELECT 'OC_SEM_PREVISAO' AS CHAVE, O.NUNOTA FROM occ O WHERE O.FL_ABERTO = 1 AND O.PRAZO = 'SEM_PREVISAO' UNION ALL SELECT 'UNIDADE_NAO_CONCILIADA', O.NUNOTA FROM occ O WHERE O.FL_ABERTO = 1 AND O.FATOR IS NULL UNION ALL SELECT 'OC_ANTIGA_ABERTA', O.NUNOTA FROM occ O WHERE O.FL_ABERTO = 1 AND O.FL_ANTIGA = 1 UNION ALL SELECT 'NAO_CONFIRMADA', O.NUNOTA FROM occ O WHERE O.FL_ABERTO = 1 AND O.SITUACAO = 'NAO_CONFIRMADA' UNION ALL SELECT 'APROVACAO_NAO_DETERMINADA', O.NUNOTA FROM occ O WHERE O.FL_ABERTO = 1 AND O.SITUACAO = 'APROVACAO_NAO_DETERMINADA' UNION ALL SELECT 'ACIMA_NEGOCIADO', O.NUNOTA FROM occ O WHERE O.FL_ACIMA_NEGOCIADO = 1 UNION ALL SELECT 'ENCERRADA_COM_SALDO', O.NUNOTA FROM occ O WHERE O.FL_PERIODO = 1 AND O.STATUS_ITEM = 'ENCERRADA_COM_SALDO' UNION ALL SELECT 'ENTRADA_OS_COMPARTILHADA', O.NUNOTA FROM occ O WHERE O.MAX_OC_MESMA_ENT > 1 UNION ALL SELECT 'TOP_PRECO_SEPARADO_ABERTA', O.NUNOTA FROM occ O WHERE O.FL_ABERTO = 1 AND O.GRUPO_PRECO = 'SEPARADO' ), blocos AS ( SELECT 'ABERTO' AS BLOCO, O.SITUACAO AS CHAVE, O.PRAZO AS CHAVE2, COUNT(DISTINCT O.NUNOTA) AS N_OCS, COUNT(*) AS N_ITENS, SUM(O.VLR_SALDO) AS VLR, SUM(CASE WHEN O.FATOR IS NULL THEN 1 ELSE 0 END) AS N_AUX FROM occ O WHERE O.FL_ABERTO = 1 GROUP BY O.SITUACAO, O.PRAZO UNION ALL SELECT 'FUNIL', O.STATUS_ITEM, O.SITUACAO, COUNT(DISTINCT O.NUNOTA), COUNT(*), SUM(O.VLRTOT), 0 FROM occ O WHERE O.FL_PERIODO = 1 GROUP BY O.STATUS_ITEM, O.SITUACAO UNION ALL SELECT 'AGING', F.FAIXA, '-', COUNT(DISTINCT F.NUNOTA), COUNT(*), SUM(F.VLR_SALDO), 0 FROM occ_fx F GROUP BY F.FAIXA UNION ALL SELECT 'PONTUALIDADE', P.CLASSE, '-', COUNT(DISTINCT P.NUNOTA), COUNT(*), SUM(P.VLRTOT), 0 FROM occ_pont P GROUP BY P.CLASSE UNION ALL SELECT 'VINCULO', O.QUALIDADE_VINC, '-', COUNT(DISTINCT O.NUNOTA), COUNT(*), SUM(O.VLRTOT), 0 FROM occ O WHERE O.FL_PERIODO = 1 AND O.QTDENT > 0 GROUP BY O.QUALIDADE_VINC UNION ALL SELECT 'QUALIDADE', Q.CHAVE, '-', COUNT(DISTINCT Q.NUNOTA), COUNT(*), 0, 0 FROM occ_q Q GROUP BY Q.CHAVE ) SELECT B.BLOCO, B.CHAVE, B.CHAVE2, B.N_OCS, B.N_ITENS, ROUND(B.VLR, 2) AS VLR, B.N_AUX, TO_CHAR(JA.DT_BASE, 'YYYY-MM-DD') AS DT_BASE, JA.SNAPSHOT FROM blocos B CROSS JOIN jan JA ORDER BY B.BLOCO, B.CHAVE, B.CHAVE2","params":["CODEMP","DT_INI","DT_FIM","TOLERANCIA_ATRASO_DIAS","OC_ANTIGA_MESES"],"tipos":["I","S","S","I","I"]},"Q_CONSUMO":{"sql":"WITH prm AS ( SELECT CAST(TO_NUMBER(?) AS INTEGER) AS CODEMP, TO_NUMBER(?) / 10000 AS DIAS_MES, CAST(TO_NUMBER(?) AS INTEGER) AS MESES_MEDIA, CAST(TO_NUMBER(?) AS INTEGER) AS MES_PARCIAL, CAST(TO_NUMBER(?) AS INTEGER) AS MEDIA_MODO, CAST(TO_NUMBER(?) AS INTEGER) AS MIN_MESES_HIST, CAST(TO_NUMBER(?) AS INTEGER) AS LEADTIME_DEFAULT, CAST(TO_NUMBER(?) AS INTEGER) AS COBERTURA_ALVO_A, CAST(TO_NUMBER(?) AS INTEGER) AS COBERTURA_ALVO_B, CAST(TO_NUMBER(?) AS INTEGER) AS COBERTURA_ALVO_C, CAST(TO_NUMBER(?) AS INTEGER) AS COBERTURA_SEM_CURVA, CAST(TO_NUMBER(?) AS INTEGER) AS POLITICA_SEGURANCA, TO_NUMBER(?) / 10000 AS SEGURANCA_PCT_LT, CAST(TO_NUMBER(?) AS INTEGER) AS MARGEM_ATENCAO_DIAS, CAST(TO_NUMBER(?) AS INTEGER) AS COBERTURA_MAX_DIAS, CAST(TO_NUMBER(?) AS INTEGER) AS FONTE_COMPROMISSO, CAST(TO_NUMBER(?) AS INTEGER) AS DESCONTA_BLOQUEADO, CAST(TO_NUMBER(?) AS INTEGER) AS REGRA_PREVISAO_FIRME, CAST(TO_NUMBER(?) AS INTEGER) AS LOTE_MULTIPLO, CAST(TO_NUMBER(?) AS INTEGER) AS ABC_CALCULADA, TO_NUMBER(?) / 10000 AS ABC_LIMITE_A, TO_NUMBER(?) / 10000 AS ABC_LIMITE_B, CAST(TO_NUMBER(?) AS INTEGER) AS OC_ANTIGA_MESES, CAST(TO_NUMBER(?) AS INTEGER) AS TOPN_CONSUMO, CAST(TO_NUMBER(?) AS INTEGER) AS CODPROD_FILTRO FROM DUAL ), tops AS ( SELECT 1131 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1118 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1117 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1729 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1130 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1727 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1724 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1730 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1781 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1782 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1738 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1200 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1201 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1211 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1206 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1000 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1005 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1008 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1002 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1009 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1001 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1728 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1010 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 99 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 100 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 101 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 108 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1741 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'SEPARADO' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1742 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 259 AS CODTIPOPER, 'ENTRADA_POR_OS' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 200 AS CODTIPOPER, 'ENTRADA_POR_OS' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL ), jan AS ( SELECT TRUNC(SYSDATE) AS DT_BASE, TRUNC(SYSDATE, 'MM') AS M0, TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI') AS SNAPSHOT FROM DUAL ), janc AS ( SELECT JA.DT_BASE, JA.M0, ADD_MONTHS(JA.M0, -PR.MESES_MEDIA) AS INI, ADD_MONTHS(JA.M0, -PR.MESES_MEDIA - 12) AS HORIZ_INI, EXTRACT(YEAR FROM JA.M0) * 12 + EXTRACT(MONTH FROM JA.M0) AS IDX_M0, PR.MESES_MEDIA AS N, CASE WHEN PR.MES_PARCIAL = 1 THEN (JA.DT_BASE - JA.M0) / (ADD_MONTHS(JA.M0, 1) - JA.M0) ELSE 0 END AS FRAC FROM jan JA CROSS JOIN prm PR ), voa AS ( SELECT V.CODPROD, V.CODVOL, MAX(V.DIVIDEMULTIPLICA) AS DM, MAX(V.QUANTIDADE) AS QC, COUNT(DISTINCT NVL(V.DIVIDEMULTIPLICA, '-') || '|' || NVL(CAST(V.QUANTIDADE AS VARCHAR(40)), '-')) AS N_REGRAS FROM TGFVOA V WHERE NVL(V.ATIVO, 'S') = 'S' GROUP BY V.CODPROD, V.CODVOL ), cmov AS ( SELECT C.CODEMP, I.CODPROD, TP.PAPEL, TRUNC(C.DTNEG) AS DT, EXTRACT(YEAR FROM C.DTNEG) * 12 + EXTRACT(MONTH FROM C.DTNEG) AS IDX_MES, NVL(I.QTDNEG, 0) AS QTD_ORIG, NVL(I.VLRTOT, 0) AS VLR, (CASE WHEN I.CODVOL = P.CODVOL THEN 1 WHEN VO.N_REGRAS = 1 AND VO.DM = 'M' AND VO.QC > 0 THEN VO.QC WHEN VO.N_REGRAS = 1 AND VO.DM = 'D' AND VO.QC > 0 THEN 1 / VO.QC END) AS FATOR FROM TGFCAB C JOIN tops TP ON TP.CODTIPOPER = C.CODTIPOPER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA JOIN TGFPRO P ON P.CODPROD = I.CODPROD LEFT JOIN voa VO ON VO.CODPROD = I.CODPROD AND VO.CODVOL = I.CODVOL CROSS JOIN prm PR CROSS JOIN janc JC WHERE TP.PAPEL IN ('CONSUMO', 'DEVOLUCAO', 'PERDA') AND C.STATUSNOTA = 'L' AND NVL(I.CANCELADO, 'N') <> 'S' AND C.DTNEG >= JC.HORIZ_INI AND C.DTNEG < JC.DT_BASE AND (PR.CODEMP = 0 OR C.CODEMP = PR.CODEMP) ), cons_mes AS ( SELECT M.CODEMP, M.CODPROD, M.IDX_MES, SUM(CASE WHEN M.FATOR IS NULL THEN 0 WHEN M.PAPEL = 'DEVOLUCAO' THEN -M.QTD_ORIG * M.FATOR ELSE M.QTD_ORIG * M.FATOR END) AS QTD, SUM(CASE WHEN M.FATOR IS NOT NULL AND M.PAPEL = 'CONSUMO' THEN M.QTD_ORIG * M.FATOR ELSE 0 END) AS QTD_SAIDA, SUM(CASE WHEN M.FATOR IS NOT NULL AND M.PAPEL = 'DEVOLUCAO' THEN M.QTD_ORIG * M.FATOR ELSE 0 END) AS QTD_DEVOL, SUM(CASE WHEN M.FATOR IS NOT NULL AND M.PAPEL = 'PERDA' THEN M.QTD_ORIG * M.FATOR ELSE 0 END) AS QTD_PERDA, SUM(CASE WHEN M.PAPEL = 'CONSUMO' THEN M.VLR WHEN M.PAPEL = 'DEVOLUCAO' THEN -M.VLR ELSE 0 END) AS VLR_FAT, SUM(CASE WHEN M.FATOR IS NULL THEN 1 ELSE 0 END) AS N_NAO_CONC FROM cmov M GROUP BY M.CODEMP, M.CODPROD, M.IDX_MES ), serie AS ( SELECT M.CODEMP, M.CODPROD, MIN(M.IDX_MES) AS IDX_PRIM, MIN(M.DT) AS DT_PRIM FROM cmov M WHERE M.PAPEL = 'CONSUMO' GROUP BY M.CODEMP, M.CODPROD ), med0 AS ( SELECT S.CODEMP, S.CODPROD, S.IDX_PRIM, S.DT_PRIM, CASE WHEN S.IDX_PRIM < JC.IDX_M0 - JC.N THEN 'ANTIGO' WHEN S.IDX_PRIM < JC.IDX_M0 THEN 'NOVO' ELSE 'SO_MES_ATUAL' END AS ORIGEM_SERIE, CASE WHEN S.IDX_PRIM < JC.IDX_M0 - JC.N THEN JC.N WHEN S.IDX_PRIM < JC.IDX_M0 THEN JC.IDX_M0 - S.IDX_PRIM ELSE 0 END AS N_MESES FROM serie S CROSS JOIN janc JC ), cons_ag AS ( SELECT CM.CODEMP, CM.CODPROD, SUM(CASE WHEN JC.IDX_M0 - CM.IDX_MES BETWEEN 1 AND NVL(M0.N_MESES, 0) THEN CM.QTD ELSE 0 END) AS QTD_JANELA, SUM(CASE WHEN CM.IDX_MES = JC.IDX_M0 THEN CM.QTD ELSE 0 END) AS QTD_PARCIAL, SUM(CASE WHEN JC.IDX_M0 - CM.IDX_MES BETWEEN 1 AND LEAST(NVL(M0.N_MESES, 0), 3) THEN CM.QTD ELSE 0 END) AS QTD_3M, SUM(CASE WHEN JC.IDX_M0 - CM.IDX_MES BETWEEN 1 AND NVL(M0.N_MESES, 0) THEN CM.QTD * ((CASE WHEN JC.IDX_M0 - CM.IDX_MES <= 3 THEN 0.5 / 3 ELSE 0 END) + (CASE WHEN JC.IDX_M0 - CM.IDX_MES <= 6 THEN 0.3 / 6 ELSE 0 END) + 0.2 / JC.N) ELSE 0 END) AS POND_NUM, SUM(CASE WHEN JC.IDX_M0 - CM.IDX_MES BETWEEN 1 AND JC.N THEN CM.N_NAO_CONC WHEN CM.IDX_MES = JC.IDX_M0 AND PR.MES_PARCIAL = 1 THEN CM.N_NAO_CONC ELSE 0 END) AS N_CONS_NAO_CONC, SUM(CASE WHEN JC.IDX_M0 - CM.IDX_MES BETWEEN 1 AND JC.N THEN CM.VLR_FAT ELSE 0 END) AS VLR_FAT_JANELA FROM cons_mes CM LEFT JOIN med0 M0 ON M0.CODEMP = CM.CODEMP AND M0.CODPROD = CM.CODPROD CROSS JOIN janc JC CROSS JOIN prm PR GROUP BY CM.CODEMP, CM.CODPROD ), med AS ( SELECT K.CODEMP, K.CODPROD, NVL(M0.ORIGEM_SERIE, 'SEM_CONSUMO') AS ORIGEM_SERIE, M0.DT_PRIM AS DT_PRIM_CONSUMO, NVL(M0.N_MESES, 0) AS N_MESES, CASE WHEN PR.MES_PARCIAL = 1 AND M0.CODPROD IS NOT NULL THEN JC.FRAC ELSE 0 END AS FRAC_USADA, NVL(CA.QTD_JANELA, 0) AS QTD_JANELA, NVL(CA.QTD_PARCIAL, 0) AS QTD_PARCIAL, NVL(CA.QTD_3M, 0) AS QTD_3M, NVL(CA.POND_NUM, 0) AS POND_NUM, NVL(CA.N_CONS_NAO_CONC, 0) AS N_CONS_NAO_CONC, NVL(CA.VLR_FAT_JANELA, 0) AS VLR_FAT_JANELA FROM (SELECT CA0.CODEMP, CA0.CODPROD FROM cons_ag CA0 UNION SELECT MZ.CODEMP, MZ.CODPROD FROM med0 MZ) K LEFT JOIN med0 M0 ON M0.CODEMP = K.CODEMP AND M0.CODPROD = K.CODPROD LEFT JOIN cons_ag CA ON CA.CODEMP = K.CODEMP AND CA.CODPROD = K.CODPROD CROSS JOIN prm PR CROSS JOIN janc JC ), med2 AS ( SELECT MD.CODEMP, MD.CODPROD, MD.ORIGEM_SERIE, MD.DT_PRIM_CONSUMO, MD.N_MESES, MD.FRAC_USADA, MD.QTD_JANELA, MD.QTD_PARCIAL, MD.QTD_3M, MD.N_CONS_NAO_CONC, MD.VLR_FAT_JANELA, CASE WHEN MD.N_MESES + MD.FRAC_USADA > 0 THEN (MD.QTD_JANELA + CASE WHEN MD.FRAC_USADA > 0 THEN MD.QTD_PARCIAL ELSE 0 END) / (MD.N_MESES + MD.FRAC_USADA) END AS MEDIA_SIMPLES, CASE WHEN MD.N_MESES >= 1 THEN MD.POND_NUM / (0.5 / 3 * LEAST(MD.N_MESES, 3) + 0.3 / 6 * LEAST(MD.N_MESES, 6) + 0.2 / JC.N * MD.N_MESES) END AS MEDIA_PONDERADA, CASE WHEN MD.N_MESES >= 1 THEN MD.QTD_3M / LEAST(MD.N_MESES, 3) END AS MEDIA_3M FROM med MD CROSS JOIN janc JC ), med3 AS ( SELECT M2.CODEMP, M2.CODPROD, M2.ORIGEM_SERIE, M2.DT_PRIM_CONSUMO, M2.N_MESES, M2.FRAC_USADA, M2.QTD_JANELA, M2.QTD_PARCIAL, M2.QTD_3M, M2.N_CONS_NAO_CONC, M2.VLR_FAT_JANELA, M2.MEDIA_SIMPLES, M2.MEDIA_PONDERADA, M2.MEDIA_3M, CASE WHEN PR.MEDIA_MODO = 1 THEN M2.MEDIA_PONDERADA ELSE M2.MEDIA_SIMPLES END AS MEDIA_CALC, CASE WHEN M2.ORIGEM_SERIE IN ('NOVO', 'SO_MES_ATUAL') AND M2.N_MESES + M2.FRAC_USADA < PR.MIN_MESES_HIST THEN 1 ELSE 0 END AS FL_HIST_INSUF FROM med2 M2 CROSS JOIN prm PR ), prod AS ( SELECT P.CODPROD, P.DESCRPROD, P.CODVOL AS UNIDADE, P.CODGRUPOPROD AS GRUPO, G.DESCRGRUPOPROD AS GRUPO_DESCR, CASE WHEN P.LEADTIME > 0 THEN P.LEADTIME END AS LT_CAD, CASE WHEN P.ESTMIN > 0 THEN P.ESTMIN END AS ESTMIN_CAD, P.AGRUPMIN AS AGRUPMIN, P.LOTECOMPMINIMO AS LOTEMIN, CASE WHEN NVL(P.CODPARCCONSIG, 0) > 0 THEN 1 ELSE 0 END AS FL_CONSIGNADO, CAST(NULL AS VARCHAR(60)) AS COD_ANTIGO FROM TGFPRO P LEFT JOIN TGFGRU G ON G.CODGRUPOPROD = P.CODGRUPOPROD WHERE P.ATIVO = 'S' ), sel AS ( SELECT M.CODEMP, M.CODPROD, ROW_NUMBER() OVER (ORDER BY M.VLR_FAT_JANELA DESC, M.CODEMP, M.CODPROD) AS RK FROM med3 M JOIN prod PD ON PD.CODPROD = M.CODPROD CROSS JOIN prm PR WHERE PR.CODPROD_FILTRO = 0 OR M.CODPROD = PR.CODPROD_FILTRO ) SELECT S.RK, M.CODEMP, M.CODPROD, PD.DESCRPROD, PD.UNIDADE, M.ORIGEM_SERIE, TO_CHAR(M.DT_PRIM_CONSUMO, 'YYYY-MM-DD') AS DT_PRIM_CONSUMO, M.N_MESES, ROUND(M.FRAC_USADA, 4) AS FRAC_USADA, ROUND(M.QTD_JANELA, 3) AS QTD_JANELA, ROUND(M.QTD_PARCIAL, 3) AS QTD_PARCIAL, ROUND(M.MEDIA_SIMPLES, 3) AS MEDIA_SIMPLES, ROUND(M.MEDIA_PONDERADA, 3) AS MEDIA_PONDERADA, ROUND(GREATEST(NVL(M.MEDIA_CALC, 0), 0), 3) AS MEDIA_USADA, ROUND(M.MEDIA_3M, 3) AS MEDIA_3M, CASE WHEN M.MEDIA_CALC > 0 AND M.MEDIA_3M IS NOT NULL THEN ROUND(M.MEDIA_3M / M.MEDIA_CALC - 1, 4) END AS DESVIO, M.FL_HIST_INSUF, M.N_CONS_NAO_CONC, ROUND(M.VLR_FAT_JANELA, 2) AS VLR_FAT_JANELA, CM.IDX_MES, ROUND(CM.QTD, 3) AS QTD, ROUND(CM.QTD_SAIDA, 3) AS QTD_SAIDA, ROUND(CM.QTD_DEVOL, 3) AS QTD_DEVOL, ROUND(CM.QTD_PERDA, 3) AS QTD_PERDA, CM.N_NAO_CONC, JC.IDX_M0, JC.N AS MESES_JANELA, TO_CHAR(JC.INI, 'YYYY-MM-DD') AS JANELA_INI, TO_CHAR(JC.DT_BASE, 'YYYY-MM-DD') AS DT_BASE FROM sel S JOIN med3 M ON M.CODEMP = S.CODEMP AND M.CODPROD = S.CODPROD JOIN prod PD ON PD.CODPROD = S.CODPROD CROSS JOIN janc JC CROSS JOIN prm PR LEFT JOIN cons_mes CM ON CM.CODEMP = S.CODEMP AND CM.CODPROD = S.CODPROD AND CM.IDX_MES >= JC.IDX_M0 - JC.N AND CM.IDX_MES <= JC.IDX_M0 WHERE S.RK <= PR.TOPN_CONSUMO ORDER BY S.RK, CM.IDX_MES NULLS FIRST","params":["CODEMP","DIAS_MES","MESES_MEDIA","MES_PARCIAL","MEDIA_MODO","MIN_MESES_HIST","LEADTIME_DEFAULT","COBERTURA_ALVO_A","COBERTURA_ALVO_B","COBERTURA_ALVO_C","COBERTURA_SEM_CURVA","POLITICA_SEGURANCA","SEGURANCA_PCT_LT","MARGEM_ATENCAO_DIAS","COBERTURA_MAX_DIAS","FONTE_COMPROMISSO","DESCONTA_BLOQUEADO","REGRA_PREVISAO_FIRME","LOTE_MULTIPLO","ABC_CALCULADA","ABC_LIMITE_A","ABC_LIMITE_B","OC_ANTIGA_MESES","TOPN_CONSUMO","CODPROD_FILTRO"],"tipos":["I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I"]},"Q_DIAG":{"sql":"WITH prm AS ( SELECT CAST(TO_NUMBER(?) AS INTEGER) AS DIAG_NUM, TO_DATE(?, 'YYYY-MM-DD') AS DT_FIM FROM DUAL ) SELECT PR.DIAG_NUM AS NUMERO, TO_CHAR(PR.DT_FIM, 'DD/MM/YYYY') AS DATA, 'TESTE' AS TEXTO FROM prm PR","params":["DIAG_NUM","DT_FIM"],"tipos":["I","S"]},"Q_OC_LISTA":{"sql":"WITH prm AS ( SELECT CAST(TO_NUMBER(?) AS INTEGER) AS CODEMP, TO_DATE(?, 'YYYY-MM-DD') AS DT_INI, TO_DATE(?, 'YYYY-MM-DD') AS DT_FIM, CAST(TO_NUMBER(?) AS INTEGER) AS TOLERANCIA_ATRASO_DIAS, CAST(TO_NUMBER(?) AS INTEGER) AS OC_ANTIGA_MESES, CAST(TO_NUMBER(?) AS INTEGER) AS LIMITE_OC, CAST(? AS VARCHAR(30)) AS FILTRO_OC, CAST(TO_NUMBER(?) AS INTEGER) AS CODPROD_FILTRO FROM DUAL ), tops AS ( SELECT 1131 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1118 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1117 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1729 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1130 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1727 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1724 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1730 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1781 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1782 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1738 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1200 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1201 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1211 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1206 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1000 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1005 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1008 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1002 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1009 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1001 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1728 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1010 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 99 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 100 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 101 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 108 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1741 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'SEPARADO' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1742 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 259 AS CODTIPOPER, 'ENTRADA_POR_OS' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 200 AS CODTIPOPER, 'ENTRADA_POR_OS' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL ), jan AS ( SELECT TRUNC(SYSDATE) AS DT_BASE, TRUNC(SYSDATE, 'MM') AS M0, TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI') AS SNAPSHOT FROM DUAL ), voa AS ( SELECT V.CODPROD, V.CODVOL, MAX(V.DIVIDEMULTIPLICA) AS DM, MAX(V.QUANTIDADE) AS QC, COUNT(DISTINCT NVL(V.DIVIDEMULTIPLICA, '-') || '|' || NVL(CAST(V.QUANTIDADE AS VARCHAR(40)), '-')) AS N_REGRAS FROM TGFVOA V WHERE NVL(V.ATIVO, 'S') = 'S' GROUP BY V.CODPROD, V.CODVOL ), occ_it AS ( SELECT C.NUNOTA, I.SEQUENCIA, C.CODEMP, C.CODTIPOPER, C.DHTIPOPER, C.CODPARC, TP.GRUPO_PRECO, I.CODPROD, C.STATUSNOTA, TRUNC(C.DTNEG) AS DT_NEG, TRUNC(C.DTPREVENT) AS DT_PREV, NVL(I.PENDENTE, 'S') AS PENDENTE, NVL(I.CANCELADO, 'N') AS CANCELADO, NVL(I.QTDNEG, 0) AS QTDNEG, NVL(I.QTDENTREGUE, 0) AS QTDENT, NVL(I.VLRTOT, 0) AS VLRTOT, I.CODVOL AS UNID_ITEM, P.CODVOL AS UNID_PADRAO, CASE WHEN P.LEADTIME > 0 THEN P.LEADTIME END AS LT_CAD, NULLIF(TRIM(C.AD_OSTUICIAL), '') AS OS, (CASE WHEN I.CODVOL = P.CODVOL THEN 1 WHEN VO.N_REGRAS = 1 AND VO.DM = 'M' AND VO.QC > 0 THEN VO.QC WHEN VO.N_REGRAS = 1 AND VO.DM = 'D' AND VO.QC > 0 THEN 1 / VO.QC END) AS FATOR, (CASE WHEN I.CODVOL IS NULL THEN 'SEM_UNIDADE' WHEN I.CODVOL = P.CODVOL THEN 'PADRAO' WHEN VO.CODPROD IS NULL THEN 'SEM_REGRA' WHEN VO.N_REGRAS > 1 THEN 'AMBIGUA' WHEN VO.DM = 'M' AND VO.QC > 0 THEN 'MULTIPLICA' WHEN VO.DM = 'D' AND VO.QC > 0 THEN 'DIVIDE' ELSE 'REGRA_INVALIDA' END) AS STATUS_CONV, CASE WHEN C.DTNEG >= PR.DT_INI AND C.DTNEG < PR.DT_FIM + 1 THEN 1 ELSE 0 END AS FL_PERIODO, CASE WHEN (NVL(I.PENDENTE, 'S') = 'S' AND NVL(I.CANCELADO, 'N') <> 'S' AND NVL(I.QTDNEG, 0) > NVL(I.QTDENTREGUE, 0)) THEN 1 ELSE 0 END AS FL_ABERTO FROM TGFCAB C JOIN tops TP ON TP.CODTIPOPER = C.CODTIPOPER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA JOIN TGFPRO P ON P.CODPROD = I.CODPROD LEFT JOIN voa VO ON VO.CODPROD = I.CODPROD AND VO.CODVOL = I.CODVOL CROSS JOIN prm PR WHERE TP.PAPEL = 'ORDEM_COMPRA' AND (PR.CODEMP = 0 OR C.CODEMP = PR.CODEMP) AND ((C.DTNEG >= PR.DT_INI AND C.DTNEG < PR.DT_FIM + 1) OR (NVL(I.PENDENTE, 'S') = 'S' AND NVL(I.CANCELADO, 'N') <> 'S' AND NVL(I.QTDNEG, 0) > NVL(I.QTDENTREGUE, 0))) ), occ_lib AS ( SELECT L.NUCHAVE, SUM(CASE WHEN L.DHLIB IS NULL AND NVL(L.REPROVADO, 'N') <> 'S' THEN 1 ELSE 0 END) AS N_LIB_PEND, SUM(CASE WHEN NVL(L.REPROVADO, 'N') = 'S' THEN 1 ELSE 0 END) AS N_LIB_REPROV FROM TSILIB L WHERE L.TABELA = 'TGFCAB' AND L.NUCHAVE IN (SELECT OI.NUNOTA FROM occ_it OI) GROUP BY L.NUCHAVE ), occ_var AS ( SELECT V.NUNOTAORIG, V.SEQUENCIAORIG, COUNT(DISTINCT V.NUNOTA) AS N_DERIV, MAX(TRUNC(N.DTNEG)) AS DT_ULT_DERIV FROM TGFVAR V JOIN TGFCAB N ON N.NUNOTA = V.NUNOTA WHERE N.STATUSNOTA = 'L' AND V.NUNOTA <> V.NUNOTAORIG AND V.NUNOTAORIG IN (SELECT OI.NUNOTA FROM occ_it OI) GROUP BY V.NUNOTAORIG, V.SEQUENCIAORIG ), occ_os_par AS ( SELECT O.NUNOTA, O.SEQUENCIA, E.NUNOTA AS NUNOTA_ENT, E.SEQUENCIA AS SEQ_ENT, TRUNC(N.DTNEG) AS DT_ENT FROM occ_it O JOIN TGFITE E ON E.CODPROD = O.CODPROD AND NULLIF(TRIM(E.AD_OS), '') = O.OS JOIN TGFCAB N ON N.NUNOTA = E.NUNOTA JOIN tops TE ON TE.CODTIPOPER = N.CODTIPOPER WHERE TE.PAPEL = 'ENTRADA_POR_OS' AND O.OS IS NOT NULL AND N.STATUSNOTA = 'L' AND N.DTNEG >= O.DT_NEG ), occ_os AS ( SELECT X.NUNOTA, X.SEQUENCIA, COUNT(*) AS N_ENT_OS, MAX(X.DT_ENT) AS DT_ULT_ENT_OS, MAX(X.N_OC_MESMA_ENT) AS MAX_OC_MESMA_ENT FROM (SELECT Y.NUNOTA, Y.SEQUENCIA, Y.DT_ENT, COUNT(*) OVER (PARTITION BY Y.NUNOTA_ENT, Y.SEQ_ENT) AS N_OC_MESMA_ENT FROM occ_os_par Y) X GROUP BY X.NUNOTA, X.SEQUENCIA ), occ AS ( SELECT O.NUNOTA, O.SEQUENCIA, O.CODEMP, O.CODTIPOPER, O.DHTIPOPER, O.CODPARC, O.GRUPO_PRECO, O.CODPROD, O.STATUSNOTA, O.DT_NEG, O.DT_PREV, O.PENDENTE, O.CANCELADO, O.QTDNEG, O.QTDENT, O.VLRTOT, O.UNID_ITEM, O.UNID_PADRAO, O.OS, O.FATOR, O.STATUS_CONV, O.FL_PERIODO, O.FL_ABERTO, CASE WHEN O.LT_CAD IS NOT NULL THEN TRUNC(O.DT_NEG + O.LT_CAD) END AS DT_PREV_ESTIMADA, NVL(LB.N_LIB_PEND, 0) AS N_LIB_PEND, NVL(LB.N_LIB_REPROV, 0) AS N_LIB_REPROV, (CASE WHEN O.STATUSNOTA = 'L' AND NVL(LB.N_LIB_PEND, 0) = 0 AND NVL(LB.N_LIB_REPROV, 0) = 0 THEN 'CONFIRMADA' WHEN O.STATUSNOTA = 'L' THEN 'APROVACAO_NAO_DETERMINADA' ELSE 'NAO_CONFIRMADA' END) AS SITUACAO, (CASE WHEN O.DT_PREV IS NULL THEN 'SEM_PREVISAO' WHEN O.DT_PREV < JA.DT_BASE THEN 'ATRASADA' ELSE 'NO_PRAZO' END) AS PRAZO, (CASE WHEN O.CANCELADO = 'S' THEN 'CANCELADA' WHEN O.QTDNEG > 0 AND O.QTDENT >= O.QTDNEG THEN 'ATENDIDA_INTEGRAL' WHEN O.PENDENTE = 'N' AND O.QTDENT > 0 THEN 'ENCERRADA_COM_SALDO' WHEN O.PENDENTE = 'N' THEN 'ENCERRADA_SEM_ATENDIMENTO' WHEN O.QTDENT > 0 THEN 'ATENDIMENTO_PARCIAL' ELSE 'ABERTA_SEM_ATENDIMENTO' END) AS STATUS_ITEM, CASE WHEN O.FL_ABERTO = 1 AND O.DT_PREV < JA.DT_BASE THEN JA.DT_BASE - O.DT_PREV END AS DIAS_ATRASO, JA.DT_BASE - O.DT_NEG AS IDADE_DIAS, CASE WHEN O.DT_NEG < ADD_MONTHS(JA.DT_BASE, -PR.OC_ANTIGA_MESES) THEN 1 ELSE 0 END AS FL_ANTIGA, CASE WHEN O.FL_ABERTO = 1 AND O.QTDNEG > 0 THEN O.VLRTOT * (O.QTDNEG - O.QTDENT) / O.QTDNEG ELSE 0 END AS VLR_SALDO, CASE WHEN O.FL_ABERTO = 1 AND O.FATOR IS NOT NULL THEN (O.QTDNEG - O.QTDENT) * O.FATOR END AS SALDO_BASE, CASE WHEN O.PENDENTE = 'N' AND O.CANCELADO <> 'S' AND O.QTDENT > 0 AND O.QTDENT < O.QTDNEG THEN O.QTDNEG - O.QTDENT ELSE 0 END AS SALDO_ENCERRADO_ORIG, CASE WHEN O.QTDENT > O.QTDNEG THEN 1 ELSE 0 END AS FL_ACIMA_NEGOCIADO, NVL(VA.N_DERIV, 0) AS N_DERIV, VA.DT_ULT_DERIV, NVL(OSX.N_ENT_OS, 0) AS N_ENT_OS, OSX.DT_ULT_ENT_OS, NVL(OSX.MAX_OC_MESMA_ENT, 0) AS MAX_OC_MESMA_ENT, CASE WHEN NVL(VA.N_DERIV, 0) > 0 THEN 'NATIVO_TGFVAR' WHEN NVL(OSX.N_ENT_OS, 0) > 0 AND NVL(OSX.MAX_OC_MESMA_ENT, 0) > 1 THEN 'INFERIDO_OS_COMPARTILHADO' WHEN NVL(OSX.N_ENT_OS, 0) > 0 THEN 'INFERIDO_OS' WHEN O.QTDENT > 0 THEN 'ATENDIMENTO_SEM_VINCULO' ELSE 'SEM_ATENDIMENTO' END AS QUALIDADE_VINC FROM occ_it O LEFT JOIN occ_lib LB ON LB.NUCHAVE = O.NUNOTA LEFT JOIN occ_var VA ON VA.NUNOTAORIG = O.NUNOTA AND VA.SEQUENCIAORIG = O.SEQUENCIA LEFT JOIN occ_os OSX ON OSX.NUNOTA = O.NUNOTA AND OSX.SEQUENCIA = O.SEQUENCIA CROSS JOIN jan JA CROSS JOIN prm PR ), lista AS ( SELECT O.*, PA.NOMEPARC AS FORNECEDOR, T.DESCROPER AS DESCR_TOP, PD.DESCRPROD FROM occ O JOIN TGFPRO PD ON PD.CODPROD = O.CODPROD LEFT JOIN TGFPAR PA ON PA.CODPARC = O.CODPARC LEFT JOIN TGFTOP T ON T.CODTIPOPER = O.CODTIPOPER AND T.DHALTER = O.DHTIPOPER CROSS JOIN prm PR WHERE O.FL_ABERTO = 1 AND (PR.CODPROD_FILTRO = 0 OR O.CODPROD = PR.CODPROD_FILTRO) AND (PR.FILTRO_OC = 'TODAS' OR (PR.FILTRO_OC = 'ATRASADAS' AND O.PRAZO = 'ATRASADA') OR (PR.FILTRO_OC = 'SEM_PREVISAO' AND O.PRAZO = 'SEM_PREVISAO') OR (PR.FILTRO_OC = 'NAO_CONFIRMADAS' AND O.SITUACAO <> 'CONFIRMADA') OR (PR.FILTRO_OC = 'ANTIGAS' AND O.FL_ANTIGA = 1)) ), ord AS ( SELECT L.*, COUNT(*) OVER () AS TOTAL_LINHAS, SUM(L.VLR_SALDO) OVER () AS TOTAL_VLR_SALDO, ROW_NUMBER() OVER (ORDER BY L.DIAS_ATRASO DESC NULLS LAST, L.VLR_SALDO DESC, L.NUNOTA, L.SEQUENCIA) AS RN FROM lista L ) SELECT O.RN, O.TOTAL_LINHAS, ROUND(O.TOTAL_VLR_SALDO, 2) AS TOTAL_VLR_SALDO, O.NUNOTA, O.SEQUENCIA, O.CODEMP, O.CODTIPOPER, O.DESCR_TOP, O.GRUPO_PRECO, O.CODPARC, O.FORNECEDOR, O.CODPROD, O.DESCRPROD, O.UNID_ITEM, O.UNID_PADRAO, ROUND(O.FATOR, 6) AS FATOR, O.STATUS_CONV, ROUND(O.QTDNEG, 3) AS QTDNEG, ROUND(O.QTDENT, 3) AS QTDENT, ROUND(O.QTDNEG - O.QTDENT, 3) AS SALDO_ORIG, ROUND(O.SALDO_BASE, 3) AS SALDO_BASE, ROUND(O.VLR_SALDO, 2) AS VLR_SALDO, TO_CHAR(O.DT_NEG, 'YYYY-MM-DD') AS DT_NEG, TO_CHAR(O.DT_PREV, 'YYYY-MM-DD') AS DT_PREV, TO_CHAR(O.DT_PREV_ESTIMADA, 'YYYY-MM-DD') AS DT_PREV_ESTIMADA, O.PRAZO, O.DIAS_ATRASO, O.IDADE_DIAS, O.FL_ANTIGA, O.STATUSNOTA, O.SITUACAO, O.N_LIB_PEND, O.N_LIB_REPROV, O.STATUS_ITEM, O.OS, O.QUALIDADE_VINC, O.N_DERIV, TO_CHAR(O.DT_ULT_DERIV, 'YYYY-MM-DD') AS DT_ULT_DERIV, O.N_ENT_OS, O.MAX_OC_MESMA_ENT, TO_CHAR(O.DT_ULT_ENT_OS, 'YYYY-MM-DD') AS DT_ULT_ENT_OS, 'NAO_VALIDADA' AS POLITICA FROM ord O CROSS JOIN prm PR WHERE O.RN <= PR.LIMITE_OC ORDER BY O.RN","params":["CODEMP","DT_INI","DT_FIM","TOLERANCIA_ATRASO_DIAS","OC_ANTIGA_MESES","LIMITE_OC","FILTRO_OC","CODPROD_FILTRO"],"tipos":["I","S","S","I","I","I","S","I"]},"Q_PARAMS":{"sql":"SELECT P.CHAVE, P.VALOR FROM BI_PARAM_COMPRA P","params":[],"tipos":[]},"Q_PLANO":{"sql":"WITH prm AS ( SELECT CAST(TO_NUMBER(?) AS INTEGER) AS CODEMP, TO_NUMBER(?) / 10000 AS DIAS_MES, CAST(TO_NUMBER(?) AS INTEGER) AS MESES_MEDIA, CAST(TO_NUMBER(?) AS INTEGER) AS MES_PARCIAL, CAST(TO_NUMBER(?) AS INTEGER) AS MEDIA_MODO, CAST(TO_NUMBER(?) AS INTEGER) AS MIN_MESES_HIST, CAST(TO_NUMBER(?) AS INTEGER) AS LEADTIME_DEFAULT, CAST(TO_NUMBER(?) AS INTEGER) AS COBERTURA_ALVO_A, CAST(TO_NUMBER(?) AS INTEGER) AS COBERTURA_ALVO_B, CAST(TO_NUMBER(?) AS INTEGER) AS COBERTURA_ALVO_C, CAST(TO_NUMBER(?) AS INTEGER) AS COBERTURA_SEM_CURVA, CAST(TO_NUMBER(?) AS INTEGER) AS POLITICA_SEGURANCA, TO_NUMBER(?) / 10000 AS SEGURANCA_PCT_LT, CAST(TO_NUMBER(?) AS INTEGER) AS MARGEM_ATENCAO_DIAS, CAST(TO_NUMBER(?) AS INTEGER) AS COBERTURA_MAX_DIAS, CAST(TO_NUMBER(?) AS INTEGER) AS FONTE_COMPROMISSO, CAST(TO_NUMBER(?) AS INTEGER) AS DESCONTA_BLOQUEADO, CAST(TO_NUMBER(?) AS INTEGER) AS REGRA_PREVISAO_FIRME, CAST(TO_NUMBER(?) AS INTEGER) AS LOTE_MULTIPLO, CAST(TO_NUMBER(?) AS INTEGER) AS ABC_CALCULADA, TO_NUMBER(?) / 10000 AS ABC_LIMITE_A, TO_NUMBER(?) / 10000 AS ABC_LIMITE_B, CAST(TO_NUMBER(?) AS INTEGER) AS OC_ANTIGA_MESES, CAST(TO_NUMBER(?) AS INTEGER) AS LIMITE_FILA, CAST(? AS VARCHAR(30)) AS FILTRO_FILA FROM DUAL ), tops AS ( SELECT 1131 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1118 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1117 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1729 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1130 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1727 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1724 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1730 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1781 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1782 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1738 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1200 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1201 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1211 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1206 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1000 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1005 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1008 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1002 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1009 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1001 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1728 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1010 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 99 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 100 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 101 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 108 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1741 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'SEPARADO' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1742 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 259 AS CODTIPOPER, 'ENTRADA_POR_OS' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 200 AS CODTIPOPER, 'ENTRADA_POR_OS' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL ), jan AS ( SELECT TRUNC(SYSDATE) AS DT_BASE, TRUNC(SYSDATE, 'MM') AS M0, TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI') AS SNAPSHOT FROM DUAL ), janc AS ( SELECT JA.DT_BASE, JA.M0, ADD_MONTHS(JA.M0, -PR.MESES_MEDIA) AS INI, ADD_MONTHS(JA.M0, -PR.MESES_MEDIA - 12) AS HORIZ_INI, EXTRACT(YEAR FROM JA.M0) * 12 + EXTRACT(MONTH FROM JA.M0) AS IDX_M0, PR.MESES_MEDIA AS N, CASE WHEN PR.MES_PARCIAL = 1 THEN (JA.DT_BASE - JA.M0) / (ADD_MONTHS(JA.M0, 1) - JA.M0) ELSE 0 END AS FRAC FROM jan JA CROSS JOIN prm PR ), voa AS ( SELECT V.CODPROD, V.CODVOL, MAX(V.DIVIDEMULTIPLICA) AS DM, MAX(V.QUANTIDADE) AS QC, COUNT(DISTINCT NVL(V.DIVIDEMULTIPLICA, '-') || '|' || NVL(CAST(V.QUANTIDADE AS VARCHAR(40)), '-')) AS N_REGRAS FROM TGFVOA V WHERE NVL(V.ATIVO, 'S') = 'S' GROUP BY V.CODPROD, V.CODVOL ), cmov AS ( SELECT C.CODEMP, I.CODPROD, TP.PAPEL, TRUNC(C.DTNEG) AS DT, EXTRACT(YEAR FROM C.DTNEG) * 12 + EXTRACT(MONTH FROM C.DTNEG) AS IDX_MES, NVL(I.QTDNEG, 0) AS QTD_ORIG, NVL(I.VLRTOT, 0) AS VLR, (CASE WHEN I.CODVOL = P.CODVOL THEN 1 WHEN VO.N_REGRAS = 1 AND VO.DM = 'M' AND VO.QC > 0 THEN VO.QC WHEN VO.N_REGRAS = 1 AND VO.DM = 'D' AND VO.QC > 0 THEN 1 / VO.QC END) AS FATOR FROM TGFCAB C JOIN tops TP ON TP.CODTIPOPER = C.CODTIPOPER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA JOIN TGFPRO P ON P.CODPROD = I.CODPROD LEFT JOIN voa VO ON VO.CODPROD = I.CODPROD AND VO.CODVOL = I.CODVOL CROSS JOIN prm PR CROSS JOIN janc JC WHERE TP.PAPEL IN ('CONSUMO', 'DEVOLUCAO', 'PERDA') AND C.STATUSNOTA = 'L' AND NVL(I.CANCELADO, 'N') <> 'S' AND C.DTNEG >= JC.HORIZ_INI AND C.DTNEG < JC.DT_BASE AND (PR.CODEMP = 0 OR C.CODEMP = PR.CODEMP) ), cons_mes AS ( SELECT M.CODEMP, M.CODPROD, M.IDX_MES, SUM(CASE WHEN M.FATOR IS NULL THEN 0 WHEN M.PAPEL = 'DEVOLUCAO' THEN -M.QTD_ORIG * M.FATOR ELSE M.QTD_ORIG * M.FATOR END) AS QTD, SUM(CASE WHEN M.FATOR IS NOT NULL AND M.PAPEL = 'CONSUMO' THEN M.QTD_ORIG * M.FATOR ELSE 0 END) AS QTD_SAIDA, SUM(CASE WHEN M.FATOR IS NOT NULL AND M.PAPEL = 'DEVOLUCAO' THEN M.QTD_ORIG * M.FATOR ELSE 0 END) AS QTD_DEVOL, SUM(CASE WHEN M.FATOR IS NOT NULL AND M.PAPEL = 'PERDA' THEN M.QTD_ORIG * M.FATOR ELSE 0 END) AS QTD_PERDA, SUM(CASE WHEN M.PAPEL = 'CONSUMO' THEN M.VLR WHEN M.PAPEL = 'DEVOLUCAO' THEN -M.VLR ELSE 0 END) AS VLR_FAT, SUM(CASE WHEN M.FATOR IS NULL THEN 1 ELSE 0 END) AS N_NAO_CONC FROM cmov M GROUP BY M.CODEMP, M.CODPROD, M.IDX_MES ), serie AS ( SELECT M.CODEMP, M.CODPROD, MIN(M.IDX_MES) AS IDX_PRIM, MIN(M.DT) AS DT_PRIM FROM cmov M WHERE M.PAPEL = 'CONSUMO' GROUP BY M.CODEMP, M.CODPROD ), med0 AS ( SELECT S.CODEMP, S.CODPROD, S.IDX_PRIM, S.DT_PRIM, CASE WHEN S.IDX_PRIM < JC.IDX_M0 - JC.N THEN 'ANTIGO' WHEN S.IDX_PRIM < JC.IDX_M0 THEN 'NOVO' ELSE 'SO_MES_ATUAL' END AS ORIGEM_SERIE, CASE WHEN S.IDX_PRIM < JC.IDX_M0 - JC.N THEN JC.N WHEN S.IDX_PRIM < JC.IDX_M0 THEN JC.IDX_M0 - S.IDX_PRIM ELSE 0 END AS N_MESES FROM serie S CROSS JOIN janc JC ), cons_ag AS ( SELECT CM.CODEMP, CM.CODPROD, SUM(CASE WHEN JC.IDX_M0 - CM.IDX_MES BETWEEN 1 AND NVL(M0.N_MESES, 0) THEN CM.QTD ELSE 0 END) AS QTD_JANELA, SUM(CASE WHEN CM.IDX_MES = JC.IDX_M0 THEN CM.QTD ELSE 0 END) AS QTD_PARCIAL, SUM(CASE WHEN JC.IDX_M0 - CM.IDX_MES BETWEEN 1 AND LEAST(NVL(M0.N_MESES, 0), 3) THEN CM.QTD ELSE 0 END) AS QTD_3M, SUM(CASE WHEN JC.IDX_M0 - CM.IDX_MES BETWEEN 1 AND NVL(M0.N_MESES, 0) THEN CM.QTD * ((CASE WHEN JC.IDX_M0 - CM.IDX_MES <= 3 THEN 0.5 / 3 ELSE 0 END) + (CASE WHEN JC.IDX_M0 - CM.IDX_MES <= 6 THEN 0.3 / 6 ELSE 0 END) + 0.2 / JC.N) ELSE 0 END) AS POND_NUM, SUM(CASE WHEN JC.IDX_M0 - CM.IDX_MES BETWEEN 1 AND JC.N THEN CM.N_NAO_CONC WHEN CM.IDX_MES = JC.IDX_M0 AND PR.MES_PARCIAL = 1 THEN CM.N_NAO_CONC ELSE 0 END) AS N_CONS_NAO_CONC, SUM(CASE WHEN JC.IDX_M0 - CM.IDX_MES BETWEEN 1 AND JC.N THEN CM.VLR_FAT ELSE 0 END) AS VLR_FAT_JANELA FROM cons_mes CM LEFT JOIN med0 M0 ON M0.CODEMP = CM.CODEMP AND M0.CODPROD = CM.CODPROD CROSS JOIN janc JC CROSS JOIN prm PR GROUP BY CM.CODEMP, CM.CODPROD ), med AS ( SELECT K.CODEMP, K.CODPROD, NVL(M0.ORIGEM_SERIE, 'SEM_CONSUMO') AS ORIGEM_SERIE, M0.DT_PRIM AS DT_PRIM_CONSUMO, NVL(M0.N_MESES, 0) AS N_MESES, CASE WHEN PR.MES_PARCIAL = 1 AND M0.CODPROD IS NOT NULL THEN JC.FRAC ELSE 0 END AS FRAC_USADA, NVL(CA.QTD_JANELA, 0) AS QTD_JANELA, NVL(CA.QTD_PARCIAL, 0) AS QTD_PARCIAL, NVL(CA.QTD_3M, 0) AS QTD_3M, NVL(CA.POND_NUM, 0) AS POND_NUM, NVL(CA.N_CONS_NAO_CONC, 0) AS N_CONS_NAO_CONC, NVL(CA.VLR_FAT_JANELA, 0) AS VLR_FAT_JANELA FROM (SELECT CA0.CODEMP, CA0.CODPROD FROM cons_ag CA0 UNION SELECT MZ.CODEMP, MZ.CODPROD FROM med0 MZ) K LEFT JOIN med0 M0 ON M0.CODEMP = K.CODEMP AND M0.CODPROD = K.CODPROD LEFT JOIN cons_ag CA ON CA.CODEMP = K.CODEMP AND CA.CODPROD = K.CODPROD CROSS JOIN prm PR CROSS JOIN janc JC ), med2 AS ( SELECT MD.CODEMP, MD.CODPROD, MD.ORIGEM_SERIE, MD.DT_PRIM_CONSUMO, MD.N_MESES, MD.FRAC_USADA, MD.QTD_JANELA, MD.QTD_PARCIAL, MD.QTD_3M, MD.N_CONS_NAO_CONC, MD.VLR_FAT_JANELA, CASE WHEN MD.N_MESES + MD.FRAC_USADA > 0 THEN (MD.QTD_JANELA + CASE WHEN MD.FRAC_USADA > 0 THEN MD.QTD_PARCIAL ELSE 0 END) / (MD.N_MESES + MD.FRAC_USADA) END AS MEDIA_SIMPLES, CASE WHEN MD.N_MESES >= 1 THEN MD.POND_NUM / (0.5 / 3 * LEAST(MD.N_MESES, 3) + 0.3 / 6 * LEAST(MD.N_MESES, 6) + 0.2 / JC.N * MD.N_MESES) END AS MEDIA_PONDERADA, CASE WHEN MD.N_MESES >= 1 THEN MD.QTD_3M / LEAST(MD.N_MESES, 3) END AS MEDIA_3M FROM med MD CROSS JOIN janc JC ), med3 AS ( SELECT M2.CODEMP, M2.CODPROD, M2.ORIGEM_SERIE, M2.DT_PRIM_CONSUMO, M2.N_MESES, M2.FRAC_USADA, M2.QTD_JANELA, M2.QTD_PARCIAL, M2.QTD_3M, M2.N_CONS_NAO_CONC, M2.VLR_FAT_JANELA, M2.MEDIA_SIMPLES, M2.MEDIA_PONDERADA, M2.MEDIA_3M, CASE WHEN PR.MEDIA_MODO = 1 THEN M2.MEDIA_PONDERADA ELSE M2.MEDIA_SIMPLES END AS MEDIA_CALC, CASE WHEN M2.ORIGEM_SERIE IN ('NOVO', 'SO_MES_ATUAL') AND M2.N_MESES + M2.FRAC_USADA < PR.MIN_MESES_HIST THEN 1 ELSE 0 END AS FL_HIST_INSUF FROM med2 M2 CROSS JOIN prm PR ), prod AS ( SELECT P.CODPROD, P.DESCRPROD, P.CODVOL AS UNIDADE, P.CODGRUPOPROD AS GRUPO, G.DESCRGRUPOPROD AS GRUPO_DESCR, CASE WHEN P.LEADTIME > 0 THEN P.LEADTIME END AS LT_CAD, CASE WHEN P.ESTMIN > 0 THEN P.ESTMIN END AS ESTMIN_CAD, P.AGRUPMIN AS AGRUPMIN, P.LOTECOMPMINIMO AS LOTEMIN, CASE WHEN NVL(P.CODPARCCONSIG, 0) > 0 THEN 1 ELSE 0 END AS FL_CONSIGNADO, CAST(NULL AS VARCHAR(60)) AS COD_ANTIGO FROM TGFPRO P LEFT JOIN TGFGRU G ON G.CODGRUPOPROD = P.CODGRUPOPROD WHERE P.ATIVO = 'S' ), est AS ( SELECT E.CODEMP, E.CODPROD, SUM(NVL(E.ESTOQUE, 0)) AS QTD_ESTOQUE, SUM(NVL(E.RESERVADO, 0)) AS QTD_RESERVADO, SUM(NVL(E.WMSBLOQUEADO, 0)) AS QTD_BLOQUEADO FROM TGFEST E CROSS JOIN prm PR WHERE (PR.CODEMP = 0 OR E.CODEMP = PR.CODEMP) AND E.CODLOCAL NOT IN (1030000, 2030000) GROUP BY E.CODEMP, E.CODPROD ), cmp_it AS ( SELECT C.CODEMP, I.CODPROD, NVL(I.QTDNEG, 0) - NVL(I.QTDENTREGUE, 0) AS SALDO_ORIG, NVL(I.QTDCONFERIDA, 0) AS CONF_ORIG, (CASE WHEN I.CODVOL = P.CODVOL THEN 1 WHEN VO.N_REGRAS = 1 AND VO.DM = 'M' AND VO.QC > 0 THEN VO.QC WHEN VO.N_REGRAS = 1 AND VO.DM = 'D' AND VO.QC > 0 THEN 1 / VO.QC END) AS FATOR FROM TGFCAB C JOIN tops TP ON TP.CODTIPOPER = C.CODTIPOPER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA JOIN TGFPRO P ON P.CODPROD = I.CODPROD LEFT JOIN voa VO ON VO.CODPROD = I.CODPROD AND VO.CODVOL = I.CODVOL CROSS JOIN prm PR WHERE TP.PAPEL = 'EMPENHO' AND I.PENDENTE = 'S' AND (NVL(I.PENDENTE, 'S') = 'S' AND NVL(I.CANCELADO, 'N') <> 'S' AND NVL(I.QTDNEG, 0) > NVL(I.QTDENTREGUE, 0)) AND (PR.CODEMP = 0 OR C.CODEMP = PR.CODEMP) ), cmp AS ( SELECT X.CODEMP, X.CODPROD, SUM(CASE WHEN X.FATOR IS NULL THEN 0 ELSE X.SALDO_ORIG * X.FATOR END) AS QTD_PEDIDOS, SUM(CASE WHEN X.FATOR IS NULL THEN 0 ELSE X.CONF_ORIG * X.FATOR END) AS QTD_CONFERIDA, SUM(CASE WHEN X.FATOR IS NULL THEN 1 ELSE 0 END) AS N_PED_NAO_CONC FROM cmp_it X GROUP BY X.CODEMP, X.CODPROD ), oc_it AS ( SELECT C.NUNOTA, I.SEQUENCIA, C.CODEMP, C.CODTIPOPER, TP.GRUPO_PRECO, I.CODPROD, C.STATUSNOTA, TRUNC(C.DTNEG) AS DT_NEG, TRUNC(C.DTPREVENT) AS DT_PREV, NVL(I.QTDNEG, 0) AS QTDNEG, NVL(I.QTDENTREGUE, 0) AS QTDENT, (CASE WHEN I.CODVOL = P.CODVOL THEN 1 WHEN VO.N_REGRAS = 1 AND VO.DM = 'M' AND VO.QC > 0 THEN VO.QC WHEN VO.N_REGRAS = 1 AND VO.DM = 'D' AND VO.QC > 0 THEN 1 / VO.QC END) AS FATOR FROM TGFCAB C JOIN tops TP ON TP.CODTIPOPER = C.CODTIPOPER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA JOIN TGFPRO P ON P.CODPROD = I.CODPROD LEFT JOIN voa VO ON VO.CODPROD = I.CODPROD AND VO.CODVOL = I.CODVOL CROSS JOIN prm PR WHERE TP.PAPEL = 'ORDEM_COMPRA' AND (NVL(I.PENDENTE, 'S') = 'S' AND NVL(I.CANCELADO, 'N') <> 'S' AND NVL(I.QTDNEG, 0) > NVL(I.QTDENTREGUE, 0)) AND (PR.CODEMP = 0 OR C.CODEMP = PR.CODEMP) ), oc_lib AS ( SELECT L.NUCHAVE, SUM(CASE WHEN L.DHLIB IS NULL AND NVL(L.REPROVADO, 'N') <> 'S' THEN 1 ELSE 0 END) AS N_LIB_PEND, SUM(CASE WHEN NVL(L.REPROVADO, 'N') = 'S' THEN 1 ELSE 0 END) AS N_LIB_REPROV FROM TSILIB L WHERE L.TABELA = 'TGFCAB' AND L.NUCHAVE IN (SELECT OI.NUNOTA FROM oc_it OI) GROUP BY L.NUCHAVE ), oc_ab AS ( SELECT O.NUNOTA, O.SEQUENCIA, O.CODEMP, O.CODTIPOPER, O.GRUPO_PRECO, O.CODPROD, O.DT_NEG, O.DT_PREV, O.FATOR, (CASE WHEN O.STATUSNOTA = 'L' AND NVL(LB.N_LIB_PEND, 0) = 0 AND NVL(LB.N_LIB_REPROV, 0) = 0 THEN 'CONFIRMADA' WHEN O.STATUSNOTA = 'L' THEN 'APROVACAO_NAO_DETERMINADA' ELSE 'NAO_CONFIRMADA' END) AS SITUACAO, (CASE WHEN O.DT_PREV IS NULL THEN 'SEM_PREVISAO' WHEN O.DT_PREV < JA.DT_BASE THEN 'ATRASADA' ELSE 'NO_PRAZO' END) AS PRAZO, CASE WHEN O.FATOR IS NULL THEN NULL ELSE (O.QTDNEG - O.QTDENT) * O.FATOR END AS SALDO_BASE, CASE WHEN O.DT_NEG < ADD_MONTHS(JA.DT_BASE, -PR.OC_ANTIGA_MESES) THEN 1 ELSE 0 END AS FL_ANTIGA FROM oc_it O LEFT JOIN oc_lib LB ON LB.NUCHAVE = O.NUNOTA CROSS JOIN jan JA CROSS JOIN prm PR ), oc_pos AS ( SELECT A.CODEMP, A.CODPROD, SUM(CASE WHEN A.SITUACAO = 'CONFIRMADA' THEN NVL(A.SALDO_BASE, 0) ELSE 0 END) AS QTD_OC_CONF, SUM(CASE WHEN A.SITUACAO = 'CONFIRMADA' AND A.PRAZO = 'NO_PRAZO' THEN NVL(A.SALDO_BASE, 0) ELSE 0 END) AS QTD_OC_CONF_PRAZO, SUM(CASE WHEN A.SITUACAO = 'CONFIRMADA' AND A.PRAZO = 'ATRASADA' THEN NVL(A.SALDO_BASE, 0) ELSE 0 END) AS QTD_OC_CONF_ATRAS, SUM(CASE WHEN A.SITUACAO = 'CONFIRMADA' AND A.PRAZO = 'SEM_PREVISAO' THEN NVL(A.SALDO_BASE, 0) ELSE 0 END) AS QTD_OC_CONF_SEMPREV, SUM(CASE WHEN A.SITUACAO <> 'CONFIRMADA' THEN NVL(A.SALDO_BASE, 0) ELSE 0 END) AS QTD_OC_NAO_CONF, COUNT(DISTINCT A.NUNOTA) AS N_OCS_ABERTAS, SUM(CASE WHEN A.FATOR IS NULL THEN 1 ELSE 0 END) AS N_OC_NAO_CONC, SUM(CASE WHEN A.PRAZO = 'SEM_PREVISAO' THEN 1 ELSE 0 END) AS N_OC_SEM_PREV, SUM(CASE WHEN A.PRAZO = 'ATRASADA' THEN 1 ELSE 0 END) AS N_OC_ATRAS, SUM(A.FL_ANTIGA) AS N_OC_ANTIGA, SUM(CASE WHEN A.GRUPO_PRECO = 'SEPARADO' THEN 1 ELSE 0 END) AS N_OC_TOP_SEP FROM oc_ab A GROUP BY A.CODEMP, A.CODPROD ), rec AS ( SELECT A.CODEMP, A.CODPROD, A.DT_PREV, SUM(A.SALDO_BASE) AS QTD FROM oc_ab A WHERE A.SITUACAO = 'CONFIRMADA' AND A.PRAZO = 'NO_PRAZO' AND A.SALDO_BASE IS NOT NULL GROUP BY A.CODEMP, A.CODPROD, A.DT_PREV ), rec2 AS ( SELECT R.CODEMP, R.CODPROD, R.DT_PREV, R.QTD, NVL(SUM(R.QTD) OVER (PARTITION BY R.CODEMP, R.CODPROD ORDER BY R.DT_PREV ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS ACUM_ANTES, ROW_NUMBER() OVER (PARTITION BY R.CODEMP, R.CODPROD ORDER BY R.DT_PREV) AS ORDEM_REC FROM rec R ), cot_it AS ( SELECT C.CODEMP, I.CODPROD, NVL(I.QTDNEG, 0) - NVL(I.QTDENTREGUE, 0) AS SALDO_ORIG, (CASE WHEN I.CODVOL = P.CODVOL THEN 1 WHEN VO.N_REGRAS = 1 AND VO.DM = 'M' AND VO.QC > 0 THEN VO.QC WHEN VO.N_REGRAS = 1 AND VO.DM = 'D' AND VO.QC > 0 THEN 1 / VO.QC END) AS FATOR FROM TGFCAB C JOIN tops TP ON TP.CODTIPOPER = C.CODTIPOPER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA JOIN TGFPRO P ON P.CODPROD = I.CODPROD LEFT JOIN voa VO ON VO.CODPROD = I.CODPROD AND VO.CODVOL = I.CODVOL CROSS JOIN prm PR WHERE TP.PAPEL = 'COTACAO' AND (NVL(I.PENDENTE, 'S') = 'S' AND NVL(I.CANCELADO, 'N') <> 'S' AND NVL(I.QTDNEG, 0) > NVL(I.QTDENTREGUE, 0)) AND (PR.CODEMP = 0 OR C.CODEMP = PR.CODEMP) ), cot AS ( SELECT X.CODEMP, X.CODPROD, SUM(CASE WHEN X.FATOR IS NULL THEN 0 ELSE X.SALDO_ORIG * X.FATOR END) AS QTD_COTACAO, SUM(CASE WHEN X.FATOR IS NULL THEN 1 ELSE 0 END) AS N_COT_NAO_CONC FROM cot_it X GROUP BY X.CODEMP, X.CODPROD ), preco_it AS ( SELECT I.CODPROD, TP.GRUPO_PRECO, C.NUNOTA, C.CODTIPOPER, TRUNC(C.DTNEG) AS DT_NEG, NVL(I.VLRTOT, 0) / (NVL(I.QTDNEG, 0) * (CASE WHEN I.CODVOL = P.CODVOL THEN 1 WHEN VO.N_REGRAS = 1 AND VO.DM = 'M' AND VO.QC > 0 THEN VO.QC WHEN VO.N_REGRAS = 1 AND VO.DM = 'D' AND VO.QC > 0 THEN 1 / VO.QC END)) AS PRECO_BASE, ROW_NUMBER() OVER (PARTITION BY I.CODPROD, TP.GRUPO_PRECO ORDER BY C.DTNEG DESC, C.NUNOTA DESC, I.SEQUENCIA DESC) AS RN FROM TGFCAB C JOIN tops TP ON TP.CODTIPOPER = C.CODTIPOPER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA JOIN TGFPRO P ON P.CODPROD = I.CODPROD LEFT JOIN voa VO ON VO.CODPROD = I.CODPROD AND VO.CODVOL = I.CODVOL CROSS JOIN prm PR CROSS JOIN janc JC WHERE TP.PAPEL = 'ORDEM_COMPRA' AND C.STATUSNOTA = 'L' AND NVL(I.CANCELADO, 'N') <> 'S' AND NVL(I.QTDNEG, 0) > 0 AND NVL(I.VLRTOT, 0) > 0 AND (CASE WHEN I.CODVOL = P.CODVOL THEN 1 WHEN VO.N_REGRAS = 1 AND VO.DM = 'M' AND VO.QC > 0 THEN VO.QC WHEN VO.N_REGRAS = 1 AND VO.DM = 'D' AND VO.QC > 0 THEN 1 / VO.QC END) IS NOT NULL AND C.DTNEG >= JC.HORIZ_INI AND C.DTNEG < JC.DT_BASE + 1 AND (PR.CODEMP = 0 OR C.CODEMP = PR.CODEMP) ), preco AS ( SELECT X.CODPROD, MAX(CASE WHEN X.GRUPO_PRECO = 'PRINCIPAL' THEN X.PRECO_BASE END) AS PRECO_REF, MAX(CASE WHEN X.GRUPO_PRECO = 'PRINCIPAL' THEN X.DT_NEG END) AS PRECO_REF_DATA, MAX(CASE WHEN X.GRUPO_PRECO = 'PRINCIPAL' THEN X.NUNOTA END) AS PRECO_REF_NUNOTA, MAX(CASE WHEN X.GRUPO_PRECO = 'PRINCIPAL' THEN X.CODTIPOPER END) AS PRECO_REF_TOP, MAX(CASE WHEN X.GRUPO_PRECO = 'SEPARADO' THEN X.PRECO_BASE END) AS PRECO_SEP, MAX(CASE WHEN X.GRUPO_PRECO = 'SEPARADO' THEN X.DT_NEG END) AS PRECO_SEP_DATA FROM preco_it X WHERE X.RN = 1 GROUP BY X.CODPROD ), chaves AS ( SELECT ES.CODEMP, ES.CODPROD FROM est ES WHERE ES.QTD_ESTOQUE <> 0 OR ES.QTD_RESERVADO <> 0 OR ES.QTD_BLOQUEADO <> 0 UNION SELECT MD.CODEMP, MD.CODPROD FROM med3 MD UNION SELECT CP.CODEMP, CP.CODPROD FROM cmp CP UNION SELECT OP.CODEMP, OP.CODPROD FROM oc_pos OP UNION SELECT CT.CODEMP, CT.CODPROD FROM cot CT ), b1 AS ( SELECT K.CODEMP, K.CODPROD, PD.DESCRPROD, PD.UNIDADE, PD.GRUPO, PD.GRUPO_DESCR, PD.ESTMIN_CAD, PD.AGRUPMIN, PD.LOTEMIN, PD.FL_CONSIGNADO, PD.COD_ANTIGO, JA.DT_BASE, NVL(ES.QTD_ESTOQUE, 0) AS QTD_ESTOQUE, NVL(ES.QTD_RESERVADO, 0) AS QTD_RESERVADO, NVL(ES.QTD_BLOQUEADO, 0) AS QTD_BLOQUEADO, NVL(CP.QTD_PEDIDOS, 0) AS QTD_PEDIDOS, NVL(CP.QTD_CONFERIDA, 0) AS QTD_CONFERIDA, NVL(CP.N_PED_NAO_CONC, 0) AS N_PED_NAO_CONC, NVL(MD.ORIGEM_SERIE, 'SEM_CONSUMO') AS ORIGEM_SERIE, MD.DT_PRIM_CONSUMO, NVL(MD.N_MESES, 0) AS N_MESES, NVL(MD.FRAC_USADA, 0) AS FRAC_USADA, NVL(MD.QTD_JANELA, 0) AS QTD_JANELA, NVL(MD.QTD_PARCIAL, 0) AS QTD_PARCIAL, MD.MEDIA_SIMPLES, MD.MEDIA_PONDERADA, MD.MEDIA_3M, MD.MEDIA_CALC, NVL(MD.FL_HIST_INSUF, 0) AS FL_HIST_INSUF, NVL(MD.N_CONS_NAO_CONC, 0) AS N_CONS_NAO_CONC, CASE WHEN MD.MEDIA_CALC < 0 THEN 1 ELSE 0 END AS FL_CONSUMO_NEG, NVL(OP.QTD_OC_CONF, 0) AS QTD_OC_CONF, NVL(OP.QTD_OC_CONF_PRAZO, 0) AS QTD_OC_CONF_PRAZO, NVL(OP.QTD_OC_CONF_ATRAS, 0) AS QTD_OC_CONF_ATRAS, NVL(OP.QTD_OC_CONF_SEMPREV, 0) AS QTD_OC_CONF_SEMPREV, NVL(OP.QTD_OC_NAO_CONF, 0) AS QTD_OC_NAO_CONF, NVL(OP.N_OCS_ABERTAS, 0) AS N_OCS_ABERTAS, NVL(OP.N_OC_NAO_CONC, 0) AS N_OC_NAO_CONC, NVL(OP.N_OC_SEM_PREV, 0) AS N_OC_SEM_PREV, NVL(OP.N_OC_ATRAS, 0) AS N_OC_ATRAS, NVL(OP.N_OC_ANTIGA, 0) AS N_OC_ANTIGA, NVL(OP.N_OC_TOP_SEP, 0) AS N_OC_TOP_SEP, CASE WHEN 0 = 1 THEN NVL(CT.QTD_COTACAO, 0) END AS QTD_COTACAO, NVL(CT.N_COT_NAO_CONC, 0) AS N_COT_NAO_CONC, PZ.PRECO_REF, PZ.PRECO_REF_DATA, PZ.PRECO_REF_NUNOTA, PZ.PRECO_REF_TOP, PZ.PRECO_SEP, PZ.PRECO_SEP_DATA, CASE WHEN PD.LT_CAD > 0 THEN PD.LT_CAD ELSE PR.LEADTIME_DEFAULT END AS LT, CASE WHEN PD.LT_CAD > 0 THEN 0 ELSE 1 END AS FL_LT_PADRAO, NVL(ES.QTD_ESTOQUE, 0) - CASE WHEN PR.DESCONTA_BLOQUEADO = 1 THEN NVL(ES.QTD_BLOQUEADO, 0) ELSE 0 END AS EFP, CASE WHEN PR.FONTE_COMPROMISSO = 2 THEN NVL(ES.QTD_RESERVADO, 0) ELSE NVL(CP.QTD_PEDIDOS, 0) END AS CMP, GREATEST(NVL(MD.MEDIA_CALC, 0), 0) AS MEDIA_USADA, GREATEST(NVL(MD.MEDIA_CALC, 0), 0) / PR.DIAS_MES AS DD, CASE WHEN GREATEST(NVL(MD.MEDIA_CALC, 0), 0) = 0 AND NVL(MD.ORIGEM_SERIE, 'SEM_CONSUMO') <> 'SO_MES_ATUAL' THEN 1 ELSE 0 END AS FL_SEM_GIRO FROM chaves K JOIN prod PD ON PD.CODPROD = K.CODPROD LEFT JOIN est ES ON ES.CODEMP = K.CODEMP AND ES.CODPROD = K.CODPROD LEFT JOIN cmp CP ON CP.CODEMP = K.CODEMP AND CP.CODPROD = K.CODPROD LEFT JOIN med3 MD ON MD.CODEMP = K.CODEMP AND MD.CODPROD = K.CODPROD LEFT JOIN oc_pos OP ON OP.CODEMP = K.CODEMP AND OP.CODPROD = K.CODPROD LEFT JOIN cot CT ON CT.CODEMP = K.CODEMP AND CT.CODPROD = K.CODPROD LEFT JOIN preco PZ ON PZ.CODPROD = K.CODPROD CROSS JOIN prm PR CROSS JOIN jan JA ), abc AS ( SELECT B.CODEMP, B.CODPROD, CASE WHEN B.PRECO_REF IS NOT NULL AND B.QTD_JANELA > 0 THEN B.QTD_JANELA * B.PRECO_REF ELSE 0 END AS VALOR_ABC FROM b1 B ), abc2 AS ( SELECT A.CODEMP, A.CODPROD, A.VALOR_ABC, SUM(A.VALOR_ABC) OVER (PARTITION BY A.CODEMP) AS TOT_ABC, NVL(SUM(A.VALOR_ABC) OVER (PARTITION BY A.CODEMP ORDER BY A.VALOR_ABC DESC, A.CODPROD ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS ACUM_ANT FROM abc A ), b2 AS ( SELECT B.*, CASE WHEN PR.ABC_CALCULADA = 1 AND B.PRECO_REF IS NOT NULL AND A2.TOT_ABC > 0 THEN CASE WHEN A2.ACUM_ANT / A2.TOT_ABC < PR.ABC_LIMITE_A THEN 'A' WHEN A2.ACUM_ANT / A2.TOT_ABC < PR.ABC_LIMITE_B THEN 'B' ELSE 'C' END END AS CURVA, CASE WHEN PR.ABC_CALCULADA = 1 THEN 'CALCULADA' ELSE 'SEM_FONTE' END AS CURVA_ORIGEM, A2.VALOR_ABC FROM b1 B LEFT JOIN abc2 A2 ON A2.CODEMP = B.CODEMP AND A2.CODPROD = B.CODPROD CROSS JOIN prm PR ), b3 AS ( SELECT B.*, CASE B.CURVA WHEN 'A' THEN PR.COBERTURA_ALVO_A WHEN 'B' THEN PR.COBERTURA_ALVO_B WHEN 'C' THEN PR.COBERTURA_ALVO_C ELSE PR.COBERTURA_SEM_CURVA END AS COB_ALVO, CASE PR.POLITICA_SEGURANCA WHEN 1 THEN B.DD * B.LT * PR.SEGURANCA_PCT_LT WHEN 2 THEN NVL(B.ESTMIN_CAD, 0) ELSE 0 END AS EST_SEG, B.EFP - B.CMP AS DISPONIVEL, B.EFP + B.QTD_OC_CONF AS POS_CONTRATADA FROM b2 B CROSS JOIN prm PR ), b4 AS ( SELECT B.*, B.LT + B.COB_ALVO AS HORIZONTE, (CASE WHEN PR.REGRA_PREVISAO_FIRME = 2 THEN B.CMP + B.DD * B.LT ELSE GREATEST(B.CMP, B.DD * B.LT) END) + B.EST_SEG AS PONTO_PEDIDO, (CASE WHEN PR.REGRA_PREVISAO_FIRME = 2 THEN B.CMP + B.DD * (B.LT + B.COB_ALVO) ELSE GREATEST(B.CMP, B.DD * (B.LT + B.COB_ALVO)) END) + B.EST_SEG AS REQUISITO, B.CMP + B.DD * (B.LT + B.COB_ALVO) + B.EST_SEG AS REQUISITO_SOMA, GREATEST(B.CMP, B.DD * (B.LT + B.COB_ALVO)) + B.EST_SEG AS REQUISITO_MAIOR, (CASE WHEN B.EFP < B.CMP THEN 0 WHEN B.DD <= 0 THEN NULL ELSE (B.EFP - CASE WHEN PR.REGRA_PREVISAO_FIRME = 2 THEN B.CMP ELSE 0 END) / B.DD END) AS COB_FISICA_DIAS, (CASE WHEN (B.EFP + B.QTD_OC_CONF) < B.CMP THEN 0 WHEN B.DD <= 0 THEN NULL ELSE ((B.EFP + B.QTD_OC_CONF) - CASE WHEN PR.REGRA_PREVISAO_FIRME = 2 THEN B.CMP ELSE 0 END) / B.DD END) AS COB_CONTRAT_DIAS FROM b3 B CROSS JOIN prm PR ), proj AS ( SELECT B.CODEMP, B.CODPROD, R.DT_PREV, R.DT_PREV - B.DT_BASE AS D_I, (CASE WHEN (B.EFP + R.ACUM_ANTES) < B.CMP THEN 0 WHEN B.DD <= 0 THEN NULL ELSE ((B.EFP + R.ACUM_ANTES) - CASE WHEN PR.REGRA_PREVISAO_FIRME = 2 THEN B.CMP ELSE 0 END) / B.DD END) AS T_ANTES, (CASE WHEN PR.REGRA_PREVISAO_FIRME = 2 THEN B.CMP + B.DD * (R.DT_PREV - B.DT_BASE) ELSE GREATEST(B.CMP, B.DD * (R.DT_PREV - B.DT_BASE)) END) - (B.EFP + R.ACUM_ANTES) AS FALTA_ANTES FROM b4 B JOIN rec2 R ON R.CODEMP = B.CODEMP AND R.CODPROD = B.CODPROD CROSS JOIN prm PR ), proj1 AS ( SELECT P.CODEMP, P.CODPROD, P.DT_PREV, P.T_ANTES, P.FALTA_ANTES, ROW_NUMBER() OVER (PARTITION BY P.CODEMP, P.CODPROD ORDER BY P.DT_PREV) AS RN FROM proj P WHERE P.T_ANTES IS NOT NULL AND P.T_ANTES < P.D_I ), recsum AS ( SELECT R.CODEMP, R.CODPROD, SUM(R.QTD) AS QTD_DATADA, MIN(R.DT_PREV) AS DT_PROX_RECEB, SUM(CASE WHEN R.ORDEM_REC = 1 THEN R.QTD ELSE 0 END) AS QTD_PROX_RECEB FROM rec2 R GROUP BY R.CODEMP, R.CODPROD ), b5 AS ( SELECT B.*, RS.DT_PROX_RECEB, RS.QTD_PROX_RECEB, NVL(RS.QTD_DATADA, 0) AS QTD_OC_DATADA, CASE WHEN P1.CODPROD IS NOT NULL THEN 1 ELSE 0 END AS FL_FALTA_ANTES_RECEB, P1.DT_PREV AS DT_RECEB_APOS_FALTA, P1.FALTA_ANTES AS QTD_FALTA_ANTES_RECEB, CASE WHEN P1.CODPROD IS NOT NULL THEN P1.T_ANTES ELSE (CASE WHEN (B.EFP + NVL(RS.QTD_DATADA, 0)) < B.CMP THEN 0 WHEN B.DD <= 0 THEN NULL ELSE ((B.EFP + NVL(RS.QTD_DATADA, 0)) - CASE WHEN PR.REGRA_PREVISAO_FIRME = 2 THEN B.CMP ELSE 0 END) / B.DD END) END AS T_FALTA_PROJ FROM b4 B LEFT JOIN proj1 P1 ON P1.CODEMP = B.CODEMP AND P1.CODPROD = B.CODPROD AND P1.RN = 1 LEFT JOIN recsum RS ON RS.CODEMP = B.CODEMP AND RS.CODPROD = B.CODPROD CROSS JOIN prm PR ), b6 AS ( SELECT B.*, CASE WHEN B.T_FALTA_PROJ IS NOT NULL AND B.T_FALTA_PROJ <= 3650 THEN B.DT_BASE + CAST(FLOOR(B.T_FALTA_PROJ) AS INTEGER) END AS DT_FALTA_EST, CASE WHEN B.FL_CONSIGNADO = 1 THEN 0 ELSE GREATEST(B.REQUISITO - B.POS_CONTRATADA, 0) END AS NEC_BRUTA, CASE WHEN B.FL_CONSIGNADO = 1 THEN 0 ELSE GREATEST(B.REQUISITO_SOMA - B.POS_CONTRATADA, 0) END AS NEC_SOMA, CASE WHEN B.FL_CONSIGNADO = 1 THEN 0 ELSE GREATEST(B.REQUISITO_MAIOR - B.POS_CONTRATADA, 0) END AS NEC_MAIOR FROM b5 B ), b7 AS ( SELECT B.*, LEAST(B.QTD_OC_NAO_CONF, B.NEC_BRUTA) AS NEC_EM_OC_NAO_CONF FROM b6 B ), b8 AS ( SELECT B.*, CASE WHEN 0 = 1 THEN LEAST(NVL(B.QTD_COTACAO, 0), B.NEC_BRUTA - B.NEC_EM_OC_NAO_CONF) END AS NEC_EM_COTACAO FROM b7 B ), b9 AS ( SELECT B.*, B.NEC_BRUTA - B.NEC_EM_OC_NAO_CONF - NVL(B.NEC_EM_COTACAO, 0) AS NEC_NAO_SOLIC, CASE WHEN NVL(B.LOTEMIN, 0) < 0 OR NVL(B.AGRUPMIN, 0) < 0 THEN 1 ELSE 0 END AS FL_LOTE_INVALIDO FROM b8 B ), b10 AS ( SELECT B.*, CASE WHEN PR.LOTE_MULTIPLO = 1 AND B.NEC_NAO_SOLIC > 0 THEN CASE WHEN NVL(B.AGRUPMIN, 0) > 0 THEN CEIL(ROUND(GREATEST(B.NEC_NAO_SOLIC, CASE WHEN B.LOTEMIN > 0 THEN B.LOTEMIN ELSE 0 END) / B.AGRUPMIN, 6)) * B.AGRUPMIN ELSE GREATEST(B.NEC_NAO_SOLIC, CASE WHEN B.LOTEMIN > 0 THEN B.LOTEMIN ELSE 0 END) END END AS QTD_ARRED FROM b9 B CROSS JOIN prm PR ), plano AS ( SELECT B.*, CASE WHEN B.QTD_ARRED IS NOT NULL THEN B.QTD_ARRED - B.NEC_NAO_SOLIC END AS EXCESSO_ARRED, CASE WHEN B.PRECO_REF IS NOT NULL AND B.DISPONIVEL < 0 THEN -B.DISPONIVEL * B.PRECO_REF END AS VLR_FALTA_ATUAL, CASE WHEN B.PRECO_REF IS NOT NULL THEN B.NEC_NAO_SOLIC * B.PRECO_REF END AS VLR_NEC_NAO_SOLIC, B.N_CONS_NAO_CONC + B.N_PED_NAO_CONC + B.N_OC_NAO_CONC + B.N_COT_NAO_CONC AS N_NAO_CONC, CASE WHEN B.QTD_ESTOQUE < 0 OR B.COB_FISICA_DIAS = 0 THEN 'P1_CRITICO' WHEN B.T_FALTA_PROJ IS NOT NULL AND FLOOR(B.T_FALTA_PROJ) < B.LT THEN 'P2_RUPTURA_IMINENTE' WHEN B.POS_CONTRATADA < B.PONTO_PEDIDO + B.DD * PR.MARGEM_ATENCAO_DIAS THEN 'P3_ATENCAO' WHEN B.FL_SEM_GIRO = 1 AND B.QTD_ESTOQUE > 0 AND (B.QTD_PEDIDOS > 0 OR B.CMP > 0) THEN 'REVISAR_SEM_GIRO' WHEN B.DD > 0 AND B.COB_CONTRAT_DIAS > PR.COBERTURA_MAX_DIAS THEN 'P0_EXCESSO' WHEN B.FL_SEM_GIRO = 1 AND B.QTD_ESTOQUE > 0 THEN 'P0_SEM_GIRO' ELSE 'OK' END AS PRIORIDADE, CASE WHEN B.QTD_ESTOQUE < 0 THEN 'ESTOQUE_NEGATIVO;' ELSE '' END || CASE WHEN B.DISPONIVEL < 0 THEN 'COMPROMISSO_MAIOR_QUE_ESTOQUE;' ELSE '' END || CASE WHEN B.COB_FISICA_DIAS = 0 AND B.QTD_ESTOQUE >= 0 AND B.DISPONIVEL >= 0 THEN 'SEM_COBERTURA_FISICA;' ELSE '' END || CASE WHEN B.FL_FALTA_ANTES_RECEB = 1 THEN 'FALTA_ANTES_RECEBIMENTO;' ELSE '' END || CASE WHEN B.T_FALTA_PROJ IS NOT NULL AND FLOOR(B.T_FALTA_PROJ) < B.LT THEN 'FALTA_DENTRO_LEAD_TIME;' ELSE '' END || CASE WHEN B.POS_CONTRATADA < B.PONTO_PEDIDO THEN 'ABAIXO_PONTO_PEDIDO;' WHEN B.POS_CONTRATADA < B.PONTO_PEDIDO + B.DD * PR.MARGEM_ATENCAO_DIAS THEN 'PROXIMO_PONTO_PEDIDO;' ELSE '' END || CASE WHEN B.FL_SEM_GIRO = 1 AND B.QTD_ESTOQUE > 0 AND (B.QTD_PEDIDOS > 0 OR B.CMP > 0) THEN 'SEM_GIRO_COM_COMPROMISSO;' WHEN B.FL_SEM_GIRO = 1 AND B.QTD_ESTOQUE > 0 THEN 'SEM_GIRO;' ELSE '' END || CASE WHEN B.DD > 0 AND B.COB_CONTRAT_DIAS > PR.COBERTURA_MAX_DIAS THEN 'COBERTURA_ACIMA_MAXIMO;' ELSE '' END || CASE WHEN B.FL_HIST_INSUF = 1 THEN 'HISTORICO_INSUFICIENTE;' ELSE '' END || CASE WHEN B.FL_CONSUMO_NEG = 1 THEN 'CONSUMO_LIQUIDO_NEGATIVO;' ELSE '' END || CASE WHEN B.N_CONS_NAO_CONC + B.N_PED_NAO_CONC + B.N_OC_NAO_CONC + B.N_COT_NAO_CONC > 0 THEN 'UNIDADE_NAO_CONCILIADA;' ELSE '' END || CASE WHEN B.QTD_OC_NAO_CONF > 0 THEN 'OC_NAO_CONFIRMADA;' ELSE '' END || CASE WHEN B.N_OC_ATRAS > 0 THEN 'OC_ATRASADA;' ELSE '' END || CASE WHEN B.N_OC_SEM_PREV > 0 THEN 'OC_SEM_PREVISAO;' ELSE '' END || CASE WHEN B.N_OC_ANTIGA > 0 THEN 'OC_ANTIGA_ABERTA;' ELSE '' END || CASE WHEN B.PRECO_REF IS NULL THEN 'SEM_PRECO_REFERENCIA;' ELSE '' END || CASE WHEN B.FL_LT_PADRAO = 1 THEN 'LEAD_TIME_PADRAO;' ELSE '' END || CASE WHEN B.FL_CONSIGNADO = 1 THEN 'CONSIGNADO_SEM_CALCULO;' ELSE '' END || CASE WHEN B.ESTMIN_CAD > 0 AND B.DISPONIVEL < B.ESTMIN_CAD THEN 'ABAIXO_ESTMIN_CADASTRO;' ELSE '' END || CASE WHEN B.FL_LOTE_INVALIDO = 1 THEN 'LOTE_MULTIPLO_INVALIDO;' ELSE '' END AS MOTIVOS FROM b10 B CROSS JOIN prm PR ), fila AS ( SELECT PL.*, CASE WHEN PR.FILTRO_FILA = 'TODOS' THEN 1 WHEN PR.FILTRO_FILA = 'ATENCAO' AND (PL.PRIORIDADE IN ('P1_CRITICO', 'P2_RUPTURA_IMINENTE', 'P3_ATENCAO') OR PL.NEC_BRUTA > 0) THEN 1 WHEN PR.FILTRO_FILA = 'EXCESSO' AND PL.PRIORIDADE IN ('P0_EXCESSO', 'P0_SEM_GIRO') THEN 1 WHEN PR.FILTRO_FILA = 'REVISAR' AND (PL.PRIORIDADE = 'REVISAR_SEM_GIRO' OR PL.N_NAO_CONC > 0 OR PL.FL_HIST_INSUF = 1 OR (PL.NEC_BRUTA > 0 AND PL.PRECO_REF IS NULL) OR PL.N_OC_SEM_PREV > 0 OR PL.N_OC_ATRAS > 0 OR PL.FL_LOTE_INVALIDO = 1 OR PL.FL_CONSUMO_NEG = 1) THEN 1 ELSE 0 END AS NO_FILTRO FROM plano PL CROSS JOIN prm PR ), ord AS ( SELECT F.*, COUNT(*) OVER () AS TOTAL_LINHAS, ROW_NUMBER() OVER (ORDER BY (CASE F.PRIORIDADE WHEN 'P1_CRITICO' THEN 1 WHEN 'P2_RUPTURA_IMINENTE' THEN 2 WHEN 'P3_ATENCAO' THEN 3 WHEN 'REVISAR_SEM_GIRO' THEN 4 WHEN 'P0_EXCESSO' THEN 5 WHEN 'P0_SEM_GIRO' THEN 6 ELSE 7 END), F.T_FALTA_PROJ ASC NULLS LAST, F.VLR_FALTA_ATUAL DESC NULLS LAST, F.VLR_NEC_NAO_SOLIC DESC NULLS LAST, F.CODEMP, F.CODPROD) AS RN FROM fila F WHERE F.NO_FILTRO = 1 ) SELECT O.RN, O.TOTAL_LINHAS, O.CODEMP, O.CODPROD, O.DESCRPROD, O.UNIDADE, O.GRUPO, O.GRUPO_DESCR, O.COD_ANTIGO, O.CURVA, O.CURVA_ORIGEM, 'NAO_VALIDADA' AS POLITICA, O.PRIORIDADE, O.MOTIVOS, ROUND(O.QTD_ESTOQUE, 3) AS QTD_ESTOQUE, ROUND(O.QTD_RESERVADO, 3) AS QTD_RESERVADO, ROUND(O.QTD_BLOQUEADO, 3) AS QTD_BLOQUEADO, ROUND(O.QTD_PEDIDOS, 3) AS QTD_PEDIDOS, ROUND(O.QTD_CONFERIDA, 3) AS QTD_CONFERIDA, ROUND(O.CMP, 3) AS CMP, ROUND(O.EFP, 3) AS EFP, ROUND(O.DISPONIVEL, 3) AS DISPONIVEL, O.ORIGEM_SERIE, TO_CHAR(O.DT_PRIM_CONSUMO, 'YYYY-MM-DD') AS DT_PRIM_CONSUMO, O.N_MESES, ROUND(O.FRAC_USADA, 4) AS FRAC_USADA, ROUND(O.QTD_JANELA, 3) AS QTD_JANELA, ROUND(O.QTD_PARCIAL, 3) AS QTD_PARCIAL, ROUND(O.MEDIA_SIMPLES, 3) AS MEDIA_SIMPLES, ROUND(O.MEDIA_PONDERADA, 3) AS MEDIA_PONDERADA, ROUND(O.MEDIA_USADA, 3) AS MEDIA_USADA, ROUND(O.DD, 4) AS DD, O.FL_HIST_INSUF, O.FL_CONSUMO_NEG, O.FL_SEM_GIRO, O.LT, O.FL_LT_PADRAO, O.COB_ALVO, ROUND(O.EST_SEG, 3) AS EST_SEG, ROUND(O.PONTO_PEDIDO, 3) AS PONTO_PEDIDO, ROUND(O.REQUISITO, 3) AS REQUISITO, ROUND(O.REQUISITO_SOMA, 3) AS REQUISITO_SOMA, ROUND(O.REQUISITO_MAIOR, 3) AS REQUISITO_MAIOR, ROUND(O.QTD_OC_CONF, 3) AS QTD_OC_CONF, ROUND(O.QTD_OC_CONF_PRAZO, 3) AS QTD_OC_CONF_PRAZO, ROUND(O.QTD_OC_CONF_ATRAS, 3) AS QTD_OC_CONF_ATRAS, ROUND(O.QTD_OC_CONF_SEMPREV, 3) AS QTD_OC_CONF_SEMPREV, ROUND(O.QTD_OC_NAO_CONF, 3) AS QTD_OC_NAO_CONF, O.N_OCS_ABERTAS, O.N_OC_ATRAS, O.N_OC_SEM_PREV, O.N_OC_ANTIGA, O.N_OC_TOP_SEP, ROUND(O.QTD_COTACAO, 3) AS QTD_COTACAO, ROUND(O.POS_CONTRATADA, 3) AS POS_CONTRATADA, ROUND(O.COB_FISICA_DIAS, 1) AS COB_FISICA_DIAS, ROUND(O.COB_CONTRAT_DIAS, 1) AS COB_CONTRAT_DIAS, TO_CHAR(O.DT_PROX_RECEB, 'YYYY-MM-DD') AS DT_PROX_RECEB, ROUND(O.QTD_PROX_RECEB, 3) AS QTD_PROX_RECEB, O.FL_FALTA_ANTES_RECEB, TO_CHAR(O.DT_RECEB_APOS_FALTA, 'YYYY-MM-DD') AS DT_RECEB_APOS_FALTA, ROUND(O.QTD_FALTA_ANTES_RECEB, 3) AS QTD_FALTA_ANTES_RECEB, ROUND(O.T_FALTA_PROJ, 1) AS T_FALTA_PROJ, TO_CHAR(O.DT_FALTA_EST, 'YYYY-MM-DD') AS DT_FALTA_EST, ROUND(O.NEC_BRUTA, 3) AS NEC_BRUTA, ROUND(O.NEC_SOMA, 3) AS NEC_SOMA, ROUND(O.NEC_MAIOR, 3) AS NEC_MAIOR, ROUND(O.NEC_EM_OC_NAO_CONF, 3) AS NEC_EM_OC_NAO_CONF, ROUND(O.NEC_EM_COTACAO, 3) AS NEC_EM_COTACAO, ROUND(O.NEC_NAO_SOLIC, 3) AS NEC_NAO_SOLIC, O.AGRUPMIN, O.LOTEMIN, O.FL_LOTE_INVALIDO, ROUND(O.QTD_ARRED, 3) AS QTD_ARRED, ROUND(O.EXCESSO_ARRED, 3) AS EXCESSO_ARRED, ROUND(O.PRECO_REF, 6) AS PRECO_REF, TO_CHAR(O.PRECO_REF_DATA, 'YYYY-MM-DD') AS PRECO_REF_DATA, O.PRECO_REF_NUNOTA, O.PRECO_REF_TOP, ROUND(O.PRECO_SEP, 6) AS PRECO_SEP, TO_CHAR(O.PRECO_SEP_DATA, 'YYYY-MM-DD') AS PRECO_SEP_DATA, ROUND(O.VLR_FALTA_ATUAL, 2) AS VLR_FALTA_ATUAL, ROUND(O.VLR_NEC_NAO_SOLIC, 2) AS VLR_NEC_NAO_SOLIC, O.ESTMIN_CAD, O.FL_CONSIGNADO, O.N_CONS_NAO_CONC, O.N_PED_NAO_CONC, O.N_OC_NAO_CONC, O.N_COT_NAO_CONC, O.N_NAO_CONC, ROUND(O.VALOR_ABC, 2) AS VALOR_ABC FROM ord O CROSS JOIN prm PR WHERE O.RN <= PR.LIMITE_FILA ORDER BY O.RN","params":["CODEMP","DIAS_MES","MESES_MEDIA","MES_PARCIAL","MEDIA_MODO","MIN_MESES_HIST","LEADTIME_DEFAULT","COBERTURA_ALVO_A","COBERTURA_ALVO_B","COBERTURA_ALVO_C","COBERTURA_SEM_CURVA","POLITICA_SEGURANCA","SEGURANCA_PCT_LT","MARGEM_ATENCAO_DIAS","COBERTURA_MAX_DIAS","FONTE_COMPROMISSO","DESCONTA_BLOQUEADO","REGRA_PREVISAO_FIRME","LOTE_MULTIPLO","ABC_CALCULADA","ABC_LIMITE_A","ABC_LIMITE_B","OC_ANTIGA_MESES","LIMITE_FILA","FILTRO_FILA"],"tipos":["I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","S"]},"Q_RESUMO":{"sql":"WITH prm AS ( SELECT CAST(TO_NUMBER(?) AS INTEGER) AS CODEMP, TO_NUMBER(?) / 10000 AS DIAS_MES, CAST(TO_NUMBER(?) AS INTEGER) AS MESES_MEDIA, CAST(TO_NUMBER(?) AS INTEGER) AS MES_PARCIAL, CAST(TO_NUMBER(?) AS INTEGER) AS MEDIA_MODO, CAST(TO_NUMBER(?) AS INTEGER) AS MIN_MESES_HIST, CAST(TO_NUMBER(?) AS INTEGER) AS LEADTIME_DEFAULT, CAST(TO_NUMBER(?) AS INTEGER) AS COBERTURA_ALVO_A, CAST(TO_NUMBER(?) AS INTEGER) AS COBERTURA_ALVO_B, CAST(TO_NUMBER(?) AS INTEGER) AS COBERTURA_ALVO_C, CAST(TO_NUMBER(?) AS INTEGER) AS COBERTURA_SEM_CURVA, CAST(TO_NUMBER(?) AS INTEGER) AS POLITICA_SEGURANCA, TO_NUMBER(?) / 10000 AS SEGURANCA_PCT_LT, CAST(TO_NUMBER(?) AS INTEGER) AS MARGEM_ATENCAO_DIAS, CAST(TO_NUMBER(?) AS INTEGER) AS COBERTURA_MAX_DIAS, CAST(TO_NUMBER(?) AS INTEGER) AS FONTE_COMPROMISSO, CAST(TO_NUMBER(?) AS INTEGER) AS DESCONTA_BLOQUEADO, CAST(TO_NUMBER(?) AS INTEGER) AS REGRA_PREVISAO_FIRME, CAST(TO_NUMBER(?) AS INTEGER) AS LOTE_MULTIPLO, CAST(TO_NUMBER(?) AS INTEGER) AS ABC_CALCULADA, TO_NUMBER(?) / 10000 AS ABC_LIMITE_A, TO_NUMBER(?) / 10000 AS ABC_LIMITE_B, CAST(TO_NUMBER(?) AS INTEGER) AS OC_ANTIGA_MESES FROM DUAL ), tops AS ( SELECT 1131 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1118 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1117 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1729 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1130 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1727 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1724 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1730 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1781 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1782 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1738 AS CODTIPOPER, 'CONSUMO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1200 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1201 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1211 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1206 AS CODTIPOPER, 'DEVOLUCAO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1000 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1005 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1008 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1002 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1009 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1001 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1728 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1010 AS CODTIPOPER, 'EMPENHO' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 99 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 100 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 101 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 108 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1741 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'SEPARADO' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 1742 AS CODTIPOPER, 'ORDEM_COMPRA' AS PAPEL, 'PRINCIPAL' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 259 AS CODTIPOPER, 'ENTRADA_POR_OS' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL UNION ALL SELECT 200 AS CODTIPOPER, 'ENTRADA_POR_OS' AS PAPEL, 'NA' AS GRUPO_PRECO FROM DUAL ), jan AS ( SELECT TRUNC(SYSDATE) AS DT_BASE, TRUNC(SYSDATE, 'MM') AS M0, TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI') AS SNAPSHOT FROM DUAL ), janc AS ( SELECT JA.DT_BASE, JA.M0, ADD_MONTHS(JA.M0, -PR.MESES_MEDIA) AS INI, ADD_MONTHS(JA.M0, -PR.MESES_MEDIA - 12) AS HORIZ_INI, EXTRACT(YEAR FROM JA.M0) * 12 + EXTRACT(MONTH FROM JA.M0) AS IDX_M0, PR.MESES_MEDIA AS N, CASE WHEN PR.MES_PARCIAL = 1 THEN (JA.DT_BASE - JA.M0) / (ADD_MONTHS(JA.M0, 1) - JA.M0) ELSE 0 END AS FRAC FROM jan JA CROSS JOIN prm PR ), voa AS ( SELECT V.CODPROD, V.CODVOL, MAX(V.DIVIDEMULTIPLICA) AS DM, MAX(V.QUANTIDADE) AS QC, COUNT(DISTINCT NVL(V.DIVIDEMULTIPLICA, '-') || '|' || NVL(CAST(V.QUANTIDADE AS VARCHAR(40)), '-')) AS N_REGRAS FROM TGFVOA V WHERE NVL(V.ATIVO, 'S') = 'S' GROUP BY V.CODPROD, V.CODVOL ), cmov AS ( SELECT C.CODEMP, I.CODPROD, TP.PAPEL, TRUNC(C.DTNEG) AS DT, EXTRACT(YEAR FROM C.DTNEG) * 12 + EXTRACT(MONTH FROM C.DTNEG) AS IDX_MES, NVL(I.QTDNEG, 0) AS QTD_ORIG, NVL(I.VLRTOT, 0) AS VLR, (CASE WHEN I.CODVOL = P.CODVOL THEN 1 WHEN VO.N_REGRAS = 1 AND VO.DM = 'M' AND VO.QC > 0 THEN VO.QC WHEN VO.N_REGRAS = 1 AND VO.DM = 'D' AND VO.QC > 0 THEN 1 / VO.QC END) AS FATOR FROM TGFCAB C JOIN tops TP ON TP.CODTIPOPER = C.CODTIPOPER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA JOIN TGFPRO P ON P.CODPROD = I.CODPROD LEFT JOIN voa VO ON VO.CODPROD = I.CODPROD AND VO.CODVOL = I.CODVOL CROSS JOIN prm PR CROSS JOIN janc JC WHERE TP.PAPEL IN ('CONSUMO', 'DEVOLUCAO', 'PERDA') AND C.STATUSNOTA = 'L' AND NVL(I.CANCELADO, 'N') <> 'S' AND C.DTNEG >= JC.HORIZ_INI AND C.DTNEG < JC.DT_BASE AND (PR.CODEMP = 0 OR C.CODEMP = PR.CODEMP) ), cons_mes AS ( SELECT M.CODEMP, M.CODPROD, M.IDX_MES, SUM(CASE WHEN M.FATOR IS NULL THEN 0 WHEN M.PAPEL = 'DEVOLUCAO' THEN -M.QTD_ORIG * M.FATOR ELSE M.QTD_ORIG * M.FATOR END) AS QTD, SUM(CASE WHEN M.FATOR IS NOT NULL AND M.PAPEL = 'CONSUMO' THEN M.QTD_ORIG * M.FATOR ELSE 0 END) AS QTD_SAIDA, SUM(CASE WHEN M.FATOR IS NOT NULL AND M.PAPEL = 'DEVOLUCAO' THEN M.QTD_ORIG * M.FATOR ELSE 0 END) AS QTD_DEVOL, SUM(CASE WHEN M.FATOR IS NOT NULL AND M.PAPEL = 'PERDA' THEN M.QTD_ORIG * M.FATOR ELSE 0 END) AS QTD_PERDA, SUM(CASE WHEN M.PAPEL = 'CONSUMO' THEN M.VLR WHEN M.PAPEL = 'DEVOLUCAO' THEN -M.VLR ELSE 0 END) AS VLR_FAT, SUM(CASE WHEN M.FATOR IS NULL THEN 1 ELSE 0 END) AS N_NAO_CONC FROM cmov M GROUP BY M.CODEMP, M.CODPROD, M.IDX_MES ), serie AS ( SELECT M.CODEMP, M.CODPROD, MIN(M.IDX_MES) AS IDX_PRIM, MIN(M.DT) AS DT_PRIM FROM cmov M WHERE M.PAPEL = 'CONSUMO' GROUP BY M.CODEMP, M.CODPROD ), med0 AS ( SELECT S.CODEMP, S.CODPROD, S.IDX_PRIM, S.DT_PRIM, CASE WHEN S.IDX_PRIM < JC.IDX_M0 - JC.N THEN 'ANTIGO' WHEN S.IDX_PRIM < JC.IDX_M0 THEN 'NOVO' ELSE 'SO_MES_ATUAL' END AS ORIGEM_SERIE, CASE WHEN S.IDX_PRIM < JC.IDX_M0 - JC.N THEN JC.N WHEN S.IDX_PRIM < JC.IDX_M0 THEN JC.IDX_M0 - S.IDX_PRIM ELSE 0 END AS N_MESES FROM serie S CROSS JOIN janc JC ), cons_ag AS ( SELECT CM.CODEMP, CM.CODPROD, SUM(CASE WHEN JC.IDX_M0 - CM.IDX_MES BETWEEN 1 AND NVL(M0.N_MESES, 0) THEN CM.QTD ELSE 0 END) AS QTD_JANELA, SUM(CASE WHEN CM.IDX_MES = JC.IDX_M0 THEN CM.QTD ELSE 0 END) AS QTD_PARCIAL, SUM(CASE WHEN JC.IDX_M0 - CM.IDX_MES BETWEEN 1 AND LEAST(NVL(M0.N_MESES, 0), 3) THEN CM.QTD ELSE 0 END) AS QTD_3M, SUM(CASE WHEN JC.IDX_M0 - CM.IDX_MES BETWEEN 1 AND NVL(M0.N_MESES, 0) THEN CM.QTD * ((CASE WHEN JC.IDX_M0 - CM.IDX_MES <= 3 THEN 0.5 / 3 ELSE 0 END) + (CASE WHEN JC.IDX_M0 - CM.IDX_MES <= 6 THEN 0.3 / 6 ELSE 0 END) + 0.2 / JC.N) ELSE 0 END) AS POND_NUM, SUM(CASE WHEN JC.IDX_M0 - CM.IDX_MES BETWEEN 1 AND JC.N THEN CM.N_NAO_CONC WHEN CM.IDX_MES = JC.IDX_M0 AND PR.MES_PARCIAL = 1 THEN CM.N_NAO_CONC ELSE 0 END) AS N_CONS_NAO_CONC, SUM(CASE WHEN JC.IDX_M0 - CM.IDX_MES BETWEEN 1 AND JC.N THEN CM.VLR_FAT ELSE 0 END) AS VLR_FAT_JANELA FROM cons_mes CM LEFT JOIN med0 M0 ON M0.CODEMP = CM.CODEMP AND M0.CODPROD = CM.CODPROD CROSS JOIN janc JC CROSS JOIN prm PR GROUP BY CM.CODEMP, CM.CODPROD ), med AS ( SELECT K.CODEMP, K.CODPROD, NVL(M0.ORIGEM_SERIE, 'SEM_CONSUMO') AS ORIGEM_SERIE, M0.DT_PRIM AS DT_PRIM_CONSUMO, NVL(M0.N_MESES, 0) AS N_MESES, CASE WHEN PR.MES_PARCIAL = 1 AND M0.CODPROD IS NOT NULL THEN JC.FRAC ELSE 0 END AS FRAC_USADA, NVL(CA.QTD_JANELA, 0) AS QTD_JANELA, NVL(CA.QTD_PARCIAL, 0) AS QTD_PARCIAL, NVL(CA.QTD_3M, 0) AS QTD_3M, NVL(CA.POND_NUM, 0) AS POND_NUM, NVL(CA.N_CONS_NAO_CONC, 0) AS N_CONS_NAO_CONC, NVL(CA.VLR_FAT_JANELA, 0) AS VLR_FAT_JANELA FROM (SELECT CA0.CODEMP, CA0.CODPROD FROM cons_ag CA0 UNION SELECT MZ.CODEMP, MZ.CODPROD FROM med0 MZ) K LEFT JOIN med0 M0 ON M0.CODEMP = K.CODEMP AND M0.CODPROD = K.CODPROD LEFT JOIN cons_ag CA ON CA.CODEMP = K.CODEMP AND CA.CODPROD = K.CODPROD CROSS JOIN prm PR CROSS JOIN janc JC ), med2 AS ( SELECT MD.CODEMP, MD.CODPROD, MD.ORIGEM_SERIE, MD.DT_PRIM_CONSUMO, MD.N_MESES, MD.FRAC_USADA, MD.QTD_JANELA, MD.QTD_PARCIAL, MD.QTD_3M, MD.N_CONS_NAO_CONC, MD.VLR_FAT_JANELA, CASE WHEN MD.N_MESES + MD.FRAC_USADA > 0 THEN (MD.QTD_JANELA + CASE WHEN MD.FRAC_USADA > 0 THEN MD.QTD_PARCIAL ELSE 0 END) / (MD.N_MESES + MD.FRAC_USADA) END AS MEDIA_SIMPLES, CASE WHEN MD.N_MESES >= 1 THEN MD.POND_NUM / (0.5 / 3 * LEAST(MD.N_MESES, 3) + 0.3 / 6 * LEAST(MD.N_MESES, 6) + 0.2 / JC.N * MD.N_MESES) END AS MEDIA_PONDERADA, CASE WHEN MD.N_MESES >= 1 THEN MD.QTD_3M / LEAST(MD.N_MESES, 3) END AS MEDIA_3M FROM med MD CROSS JOIN janc JC ), med3 AS ( SELECT M2.CODEMP, M2.CODPROD, M2.ORIGEM_SERIE, M2.DT_PRIM_CONSUMO, M2.N_MESES, M2.FRAC_USADA, M2.QTD_JANELA, M2.QTD_PARCIAL, M2.QTD_3M, M2.N_CONS_NAO_CONC, M2.VLR_FAT_JANELA, M2.MEDIA_SIMPLES, M2.MEDIA_PONDERADA, M2.MEDIA_3M, CASE WHEN PR.MEDIA_MODO = 1 THEN M2.MEDIA_PONDERADA ELSE M2.MEDIA_SIMPLES END AS MEDIA_CALC, CASE WHEN M2.ORIGEM_SERIE IN ('NOVO', 'SO_MES_ATUAL') AND M2.N_MESES + M2.FRAC_USADA < PR.MIN_MESES_HIST THEN 1 ELSE 0 END AS FL_HIST_INSUF FROM med2 M2 CROSS JOIN prm PR ), prod AS ( SELECT P.CODPROD, P.DESCRPROD, P.CODVOL AS UNIDADE, P.CODGRUPOPROD AS GRUPO, G.DESCRGRUPOPROD AS GRUPO_DESCR, CASE WHEN P.LEADTIME > 0 THEN P.LEADTIME END AS LT_CAD, CASE WHEN P.ESTMIN > 0 THEN P.ESTMIN END AS ESTMIN_CAD, P.AGRUPMIN AS AGRUPMIN, P.LOTECOMPMINIMO AS LOTEMIN, CASE WHEN NVL(P.CODPARCCONSIG, 0) > 0 THEN 1 ELSE 0 END AS FL_CONSIGNADO, CAST(NULL AS VARCHAR(60)) AS COD_ANTIGO FROM TGFPRO P LEFT JOIN TGFGRU G ON G.CODGRUPOPROD = P.CODGRUPOPROD WHERE P.ATIVO = 'S' ), est AS ( SELECT E.CODEMP, E.CODPROD, SUM(NVL(E.ESTOQUE, 0)) AS QTD_ESTOQUE, SUM(NVL(E.RESERVADO, 0)) AS QTD_RESERVADO, SUM(NVL(E.WMSBLOQUEADO, 0)) AS QTD_BLOQUEADO FROM TGFEST E CROSS JOIN prm PR WHERE (PR.CODEMP = 0 OR E.CODEMP = PR.CODEMP) AND E.CODLOCAL NOT IN (1030000, 2030000) GROUP BY E.CODEMP, E.CODPROD ), cmp_it AS ( SELECT C.CODEMP, I.CODPROD, NVL(I.QTDNEG, 0) - NVL(I.QTDENTREGUE, 0) AS SALDO_ORIG, NVL(I.QTDCONFERIDA, 0) AS CONF_ORIG, (CASE WHEN I.CODVOL = P.CODVOL THEN 1 WHEN VO.N_REGRAS = 1 AND VO.DM = 'M' AND VO.QC > 0 THEN VO.QC WHEN VO.N_REGRAS = 1 AND VO.DM = 'D' AND VO.QC > 0 THEN 1 / VO.QC END) AS FATOR FROM TGFCAB C JOIN tops TP ON TP.CODTIPOPER = C.CODTIPOPER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA JOIN TGFPRO P ON P.CODPROD = I.CODPROD LEFT JOIN voa VO ON VO.CODPROD = I.CODPROD AND VO.CODVOL = I.CODVOL CROSS JOIN prm PR WHERE TP.PAPEL = 'EMPENHO' AND I.PENDENTE = 'S' AND (NVL(I.PENDENTE, 'S') = 'S' AND NVL(I.CANCELADO, 'N') <> 'S' AND NVL(I.QTDNEG, 0) > NVL(I.QTDENTREGUE, 0)) AND (PR.CODEMP = 0 OR C.CODEMP = PR.CODEMP) ), cmp AS ( SELECT X.CODEMP, X.CODPROD, SUM(CASE WHEN X.FATOR IS NULL THEN 0 ELSE X.SALDO_ORIG * X.FATOR END) AS QTD_PEDIDOS, SUM(CASE WHEN X.FATOR IS NULL THEN 0 ELSE X.CONF_ORIG * X.FATOR END) AS QTD_CONFERIDA, SUM(CASE WHEN X.FATOR IS NULL THEN 1 ELSE 0 END) AS N_PED_NAO_CONC FROM cmp_it X GROUP BY X.CODEMP, X.CODPROD ), oc_it AS ( SELECT C.NUNOTA, I.SEQUENCIA, C.CODEMP, C.CODTIPOPER, TP.GRUPO_PRECO, I.CODPROD, C.STATUSNOTA, TRUNC(C.DTNEG) AS DT_NEG, TRUNC(C.DTPREVENT) AS DT_PREV, NVL(I.QTDNEG, 0) AS QTDNEG, NVL(I.QTDENTREGUE, 0) AS QTDENT, (CASE WHEN I.CODVOL = P.CODVOL THEN 1 WHEN VO.N_REGRAS = 1 AND VO.DM = 'M' AND VO.QC > 0 THEN VO.QC WHEN VO.N_REGRAS = 1 AND VO.DM = 'D' AND VO.QC > 0 THEN 1 / VO.QC END) AS FATOR FROM TGFCAB C JOIN tops TP ON TP.CODTIPOPER = C.CODTIPOPER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA JOIN TGFPRO P ON P.CODPROD = I.CODPROD LEFT JOIN voa VO ON VO.CODPROD = I.CODPROD AND VO.CODVOL = I.CODVOL CROSS JOIN prm PR WHERE TP.PAPEL = 'ORDEM_COMPRA' AND (NVL(I.PENDENTE, 'S') = 'S' AND NVL(I.CANCELADO, 'N') <> 'S' AND NVL(I.QTDNEG, 0) > NVL(I.QTDENTREGUE, 0)) AND (PR.CODEMP = 0 OR C.CODEMP = PR.CODEMP) ), oc_lib AS ( SELECT L.NUCHAVE, SUM(CASE WHEN L.DHLIB IS NULL AND NVL(L.REPROVADO, 'N') <> 'S' THEN 1 ELSE 0 END) AS N_LIB_PEND, SUM(CASE WHEN NVL(L.REPROVADO, 'N') = 'S' THEN 1 ELSE 0 END) AS N_LIB_REPROV FROM TSILIB L WHERE L.TABELA = 'TGFCAB' AND L.NUCHAVE IN (SELECT OI.NUNOTA FROM oc_it OI) GROUP BY L.NUCHAVE ), oc_ab AS ( SELECT O.NUNOTA, O.SEQUENCIA, O.CODEMP, O.CODTIPOPER, O.GRUPO_PRECO, O.CODPROD, O.DT_NEG, O.DT_PREV, O.FATOR, (CASE WHEN O.STATUSNOTA = 'L' AND NVL(LB.N_LIB_PEND, 0) = 0 AND NVL(LB.N_LIB_REPROV, 0) = 0 THEN 'CONFIRMADA' WHEN O.STATUSNOTA = 'L' THEN 'APROVACAO_NAO_DETERMINADA' ELSE 'NAO_CONFIRMADA' END) AS SITUACAO, (CASE WHEN O.DT_PREV IS NULL THEN 'SEM_PREVISAO' WHEN O.DT_PREV < JA.DT_BASE THEN 'ATRASADA' ELSE 'NO_PRAZO' END) AS PRAZO, CASE WHEN O.FATOR IS NULL THEN NULL ELSE (O.QTDNEG - O.QTDENT) * O.FATOR END AS SALDO_BASE, CASE WHEN O.DT_NEG < ADD_MONTHS(JA.DT_BASE, -PR.OC_ANTIGA_MESES) THEN 1 ELSE 0 END AS FL_ANTIGA FROM oc_it O LEFT JOIN oc_lib LB ON LB.NUCHAVE = O.NUNOTA CROSS JOIN jan JA CROSS JOIN prm PR ), oc_pos AS ( SELECT A.CODEMP, A.CODPROD, SUM(CASE WHEN A.SITUACAO = 'CONFIRMADA' THEN NVL(A.SALDO_BASE, 0) ELSE 0 END) AS QTD_OC_CONF, SUM(CASE WHEN A.SITUACAO = 'CONFIRMADA' AND A.PRAZO = 'NO_PRAZO' THEN NVL(A.SALDO_BASE, 0) ELSE 0 END) AS QTD_OC_CONF_PRAZO, SUM(CASE WHEN A.SITUACAO = 'CONFIRMADA' AND A.PRAZO = 'ATRASADA' THEN NVL(A.SALDO_BASE, 0) ELSE 0 END) AS QTD_OC_CONF_ATRAS, SUM(CASE WHEN A.SITUACAO = 'CONFIRMADA' AND A.PRAZO = 'SEM_PREVISAO' THEN NVL(A.SALDO_BASE, 0) ELSE 0 END) AS QTD_OC_CONF_SEMPREV, SUM(CASE WHEN A.SITUACAO <> 'CONFIRMADA' THEN NVL(A.SALDO_BASE, 0) ELSE 0 END) AS QTD_OC_NAO_CONF, COUNT(DISTINCT A.NUNOTA) AS N_OCS_ABERTAS, SUM(CASE WHEN A.FATOR IS NULL THEN 1 ELSE 0 END) AS N_OC_NAO_CONC, SUM(CASE WHEN A.PRAZO = 'SEM_PREVISAO' THEN 1 ELSE 0 END) AS N_OC_SEM_PREV, SUM(CASE WHEN A.PRAZO = 'ATRASADA' THEN 1 ELSE 0 END) AS N_OC_ATRAS, SUM(A.FL_ANTIGA) AS N_OC_ANTIGA, SUM(CASE WHEN A.GRUPO_PRECO = 'SEPARADO' THEN 1 ELSE 0 END) AS N_OC_TOP_SEP FROM oc_ab A GROUP BY A.CODEMP, A.CODPROD ), rec AS ( SELECT A.CODEMP, A.CODPROD, A.DT_PREV, SUM(A.SALDO_BASE) AS QTD FROM oc_ab A WHERE A.SITUACAO = 'CONFIRMADA' AND A.PRAZO = 'NO_PRAZO' AND A.SALDO_BASE IS NOT NULL GROUP BY A.CODEMP, A.CODPROD, A.DT_PREV ), rec2 AS ( SELECT R.CODEMP, R.CODPROD, R.DT_PREV, R.QTD, NVL(SUM(R.QTD) OVER (PARTITION BY R.CODEMP, R.CODPROD ORDER BY R.DT_PREV ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS ACUM_ANTES, ROW_NUMBER() OVER (PARTITION BY R.CODEMP, R.CODPROD ORDER BY R.DT_PREV) AS ORDEM_REC FROM rec R ), cot_it AS ( SELECT C.CODEMP, I.CODPROD, NVL(I.QTDNEG, 0) - NVL(I.QTDENTREGUE, 0) AS SALDO_ORIG, (CASE WHEN I.CODVOL = P.CODVOL THEN 1 WHEN VO.N_REGRAS = 1 AND VO.DM = 'M' AND VO.QC > 0 THEN VO.QC WHEN VO.N_REGRAS = 1 AND VO.DM = 'D' AND VO.QC > 0 THEN 1 / VO.QC END) AS FATOR FROM TGFCAB C JOIN tops TP ON TP.CODTIPOPER = C.CODTIPOPER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA JOIN TGFPRO P ON P.CODPROD = I.CODPROD LEFT JOIN voa VO ON VO.CODPROD = I.CODPROD AND VO.CODVOL = I.CODVOL CROSS JOIN prm PR WHERE TP.PAPEL = 'COTACAO' AND (NVL(I.PENDENTE, 'S') = 'S' AND NVL(I.CANCELADO, 'N') <> 'S' AND NVL(I.QTDNEG, 0) > NVL(I.QTDENTREGUE, 0)) AND (PR.CODEMP = 0 OR C.CODEMP = PR.CODEMP) ), cot AS ( SELECT X.CODEMP, X.CODPROD, SUM(CASE WHEN X.FATOR IS NULL THEN 0 ELSE X.SALDO_ORIG * X.FATOR END) AS QTD_COTACAO, SUM(CASE WHEN X.FATOR IS NULL THEN 1 ELSE 0 END) AS N_COT_NAO_CONC FROM cot_it X GROUP BY X.CODEMP, X.CODPROD ), preco_it AS ( SELECT I.CODPROD, TP.GRUPO_PRECO, C.NUNOTA, C.CODTIPOPER, TRUNC(C.DTNEG) AS DT_NEG, NVL(I.VLRTOT, 0) / (NVL(I.QTDNEG, 0) * (CASE WHEN I.CODVOL = P.CODVOL THEN 1 WHEN VO.N_REGRAS = 1 AND VO.DM = 'M' AND VO.QC > 0 THEN VO.QC WHEN VO.N_REGRAS = 1 AND VO.DM = 'D' AND VO.QC > 0 THEN 1 / VO.QC END)) AS PRECO_BASE, ROW_NUMBER() OVER (PARTITION BY I.CODPROD, TP.GRUPO_PRECO ORDER BY C.DTNEG DESC, C.NUNOTA DESC, I.SEQUENCIA DESC) AS RN FROM TGFCAB C JOIN tops TP ON TP.CODTIPOPER = C.CODTIPOPER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA JOIN TGFPRO P ON P.CODPROD = I.CODPROD LEFT JOIN voa VO ON VO.CODPROD = I.CODPROD AND VO.CODVOL = I.CODVOL CROSS JOIN prm PR CROSS JOIN janc JC WHERE TP.PAPEL = 'ORDEM_COMPRA' AND C.STATUSNOTA = 'L' AND NVL(I.CANCELADO, 'N') <> 'S' AND NVL(I.QTDNEG, 0) > 0 AND NVL(I.VLRTOT, 0) > 0 AND (CASE WHEN I.CODVOL = P.CODVOL THEN 1 WHEN VO.N_REGRAS = 1 AND VO.DM = 'M' AND VO.QC > 0 THEN VO.QC WHEN VO.N_REGRAS = 1 AND VO.DM = 'D' AND VO.QC > 0 THEN 1 / VO.QC END) IS NOT NULL AND C.DTNEG >= JC.HORIZ_INI AND C.DTNEG < JC.DT_BASE + 1 AND (PR.CODEMP = 0 OR C.CODEMP = PR.CODEMP) ), preco AS ( SELECT X.CODPROD, MAX(CASE WHEN X.GRUPO_PRECO = 'PRINCIPAL' THEN X.PRECO_BASE END) AS PRECO_REF, MAX(CASE WHEN X.GRUPO_PRECO = 'PRINCIPAL' THEN X.DT_NEG END) AS PRECO_REF_DATA, MAX(CASE WHEN X.GRUPO_PRECO = 'PRINCIPAL' THEN X.NUNOTA END) AS PRECO_REF_NUNOTA, MAX(CASE WHEN X.GRUPO_PRECO = 'PRINCIPAL' THEN X.CODTIPOPER END) AS PRECO_REF_TOP, MAX(CASE WHEN X.GRUPO_PRECO = 'SEPARADO' THEN X.PRECO_BASE END) AS PRECO_SEP, MAX(CASE WHEN X.GRUPO_PRECO = 'SEPARADO' THEN X.DT_NEG END) AS PRECO_SEP_DATA FROM preco_it X WHERE X.RN = 1 GROUP BY X.CODPROD ), chaves AS ( SELECT ES.CODEMP, ES.CODPROD FROM est ES WHERE ES.QTD_ESTOQUE <> 0 OR ES.QTD_RESERVADO <> 0 OR ES.QTD_BLOQUEADO <> 0 UNION SELECT MD.CODEMP, MD.CODPROD FROM med3 MD UNION SELECT CP.CODEMP, CP.CODPROD FROM cmp CP UNION SELECT OP.CODEMP, OP.CODPROD FROM oc_pos OP UNION SELECT CT.CODEMP, CT.CODPROD FROM cot CT ), b1 AS ( SELECT K.CODEMP, K.CODPROD, PD.DESCRPROD, PD.UNIDADE, PD.GRUPO, PD.GRUPO_DESCR, PD.ESTMIN_CAD, PD.AGRUPMIN, PD.LOTEMIN, PD.FL_CONSIGNADO, PD.COD_ANTIGO, JA.DT_BASE, NVL(ES.QTD_ESTOQUE, 0) AS QTD_ESTOQUE, NVL(ES.QTD_RESERVADO, 0) AS QTD_RESERVADO, NVL(ES.QTD_BLOQUEADO, 0) AS QTD_BLOQUEADO, NVL(CP.QTD_PEDIDOS, 0) AS QTD_PEDIDOS, NVL(CP.QTD_CONFERIDA, 0) AS QTD_CONFERIDA, NVL(CP.N_PED_NAO_CONC, 0) AS N_PED_NAO_CONC, NVL(MD.ORIGEM_SERIE, 'SEM_CONSUMO') AS ORIGEM_SERIE, MD.DT_PRIM_CONSUMO, NVL(MD.N_MESES, 0) AS N_MESES, NVL(MD.FRAC_USADA, 0) AS FRAC_USADA, NVL(MD.QTD_JANELA, 0) AS QTD_JANELA, NVL(MD.QTD_PARCIAL, 0) AS QTD_PARCIAL, MD.MEDIA_SIMPLES, MD.MEDIA_PONDERADA, MD.MEDIA_3M, MD.MEDIA_CALC, NVL(MD.FL_HIST_INSUF, 0) AS FL_HIST_INSUF, NVL(MD.N_CONS_NAO_CONC, 0) AS N_CONS_NAO_CONC, CASE WHEN MD.MEDIA_CALC < 0 THEN 1 ELSE 0 END AS FL_CONSUMO_NEG, NVL(OP.QTD_OC_CONF, 0) AS QTD_OC_CONF, NVL(OP.QTD_OC_CONF_PRAZO, 0) AS QTD_OC_CONF_PRAZO, NVL(OP.QTD_OC_CONF_ATRAS, 0) AS QTD_OC_CONF_ATRAS, NVL(OP.QTD_OC_CONF_SEMPREV, 0) AS QTD_OC_CONF_SEMPREV, NVL(OP.QTD_OC_NAO_CONF, 0) AS QTD_OC_NAO_CONF, NVL(OP.N_OCS_ABERTAS, 0) AS N_OCS_ABERTAS, NVL(OP.N_OC_NAO_CONC, 0) AS N_OC_NAO_CONC, NVL(OP.N_OC_SEM_PREV, 0) AS N_OC_SEM_PREV, NVL(OP.N_OC_ATRAS, 0) AS N_OC_ATRAS, NVL(OP.N_OC_ANTIGA, 0) AS N_OC_ANTIGA, NVL(OP.N_OC_TOP_SEP, 0) AS N_OC_TOP_SEP, CASE WHEN 0 = 1 THEN NVL(CT.QTD_COTACAO, 0) END AS QTD_COTACAO, NVL(CT.N_COT_NAO_CONC, 0) AS N_COT_NAO_CONC, PZ.PRECO_REF, PZ.PRECO_REF_DATA, PZ.PRECO_REF_NUNOTA, PZ.PRECO_REF_TOP, PZ.PRECO_SEP, PZ.PRECO_SEP_DATA, CASE WHEN PD.LT_CAD > 0 THEN PD.LT_CAD ELSE PR.LEADTIME_DEFAULT END AS LT, CASE WHEN PD.LT_CAD > 0 THEN 0 ELSE 1 END AS FL_LT_PADRAO, NVL(ES.QTD_ESTOQUE, 0) - CASE WHEN PR.DESCONTA_BLOQUEADO = 1 THEN NVL(ES.QTD_BLOQUEADO, 0) ELSE 0 END AS EFP, CASE WHEN PR.FONTE_COMPROMISSO = 2 THEN NVL(ES.QTD_RESERVADO, 0) ELSE NVL(CP.QTD_PEDIDOS, 0) END AS CMP, GREATEST(NVL(MD.MEDIA_CALC, 0), 0) AS MEDIA_USADA, GREATEST(NVL(MD.MEDIA_CALC, 0), 0) / PR.DIAS_MES AS DD, CASE WHEN GREATEST(NVL(MD.MEDIA_CALC, 0), 0) = 0 AND NVL(MD.ORIGEM_SERIE, 'SEM_CONSUMO') <> 'SO_MES_ATUAL' THEN 1 ELSE 0 END AS FL_SEM_GIRO FROM chaves K JOIN prod PD ON PD.CODPROD = K.CODPROD LEFT JOIN est ES ON ES.CODEMP = K.CODEMP AND ES.CODPROD = K.CODPROD LEFT JOIN cmp CP ON CP.CODEMP = K.CODEMP AND CP.CODPROD = K.CODPROD LEFT JOIN med3 MD ON MD.CODEMP = K.CODEMP AND MD.CODPROD = K.CODPROD LEFT JOIN oc_pos OP ON OP.CODEMP = K.CODEMP AND OP.CODPROD = K.CODPROD LEFT JOIN cot CT ON CT.CODEMP = K.CODEMP AND CT.CODPROD = K.CODPROD LEFT JOIN preco PZ ON PZ.CODPROD = K.CODPROD CROSS JOIN prm PR CROSS JOIN jan JA ), abc AS ( SELECT B.CODEMP, B.CODPROD, CASE WHEN B.PRECO_REF IS NOT NULL AND B.QTD_JANELA > 0 THEN B.QTD_JANELA * B.PRECO_REF ELSE 0 END AS VALOR_ABC FROM b1 B ), abc2 AS ( SELECT A.CODEMP, A.CODPROD, A.VALOR_ABC, SUM(A.VALOR_ABC) OVER (PARTITION BY A.CODEMP) AS TOT_ABC, NVL(SUM(A.VALOR_ABC) OVER (PARTITION BY A.CODEMP ORDER BY A.VALOR_ABC DESC, A.CODPROD ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS ACUM_ANT FROM abc A ), b2 AS ( SELECT B.*, CASE WHEN PR.ABC_CALCULADA = 1 AND B.PRECO_REF IS NOT NULL AND A2.TOT_ABC > 0 THEN CASE WHEN A2.ACUM_ANT / A2.TOT_ABC < PR.ABC_LIMITE_A THEN 'A' WHEN A2.ACUM_ANT / A2.TOT_ABC < PR.ABC_LIMITE_B THEN 'B' ELSE 'C' END END AS CURVA, CASE WHEN PR.ABC_CALCULADA = 1 THEN 'CALCULADA' ELSE 'SEM_FONTE' END AS CURVA_ORIGEM, A2.VALOR_ABC FROM b1 B LEFT JOIN abc2 A2 ON A2.CODEMP = B.CODEMP AND A2.CODPROD = B.CODPROD CROSS JOIN prm PR ), b3 AS ( SELECT B.*, CASE B.CURVA WHEN 'A' THEN PR.COBERTURA_ALVO_A WHEN 'B' THEN PR.COBERTURA_ALVO_B WHEN 'C' THEN PR.COBERTURA_ALVO_C ELSE PR.COBERTURA_SEM_CURVA END AS COB_ALVO, CASE PR.POLITICA_SEGURANCA WHEN 1 THEN B.DD * B.LT * PR.SEGURANCA_PCT_LT WHEN 2 THEN NVL(B.ESTMIN_CAD, 0) ELSE 0 END AS EST_SEG, B.EFP - B.CMP AS DISPONIVEL, B.EFP + B.QTD_OC_CONF AS POS_CONTRATADA FROM b2 B CROSS JOIN prm PR ), b4 AS ( SELECT B.*, B.LT + B.COB_ALVO AS HORIZONTE, (CASE WHEN PR.REGRA_PREVISAO_FIRME = 2 THEN B.CMP + B.DD * B.LT ELSE GREATEST(B.CMP, B.DD * B.LT) END) + B.EST_SEG AS PONTO_PEDIDO, (CASE WHEN PR.REGRA_PREVISAO_FIRME = 2 THEN B.CMP + B.DD * (B.LT + B.COB_ALVO) ELSE GREATEST(B.CMP, B.DD * (B.LT + B.COB_ALVO)) END) + B.EST_SEG AS REQUISITO, B.CMP + B.DD * (B.LT + B.COB_ALVO) + B.EST_SEG AS REQUISITO_SOMA, GREATEST(B.CMP, B.DD * (B.LT + B.COB_ALVO)) + B.EST_SEG AS REQUISITO_MAIOR, (CASE WHEN B.EFP < B.CMP THEN 0 WHEN B.DD <= 0 THEN NULL ELSE (B.EFP - CASE WHEN PR.REGRA_PREVISAO_FIRME = 2 THEN B.CMP ELSE 0 END) / B.DD END) AS COB_FISICA_DIAS, (CASE WHEN (B.EFP + B.QTD_OC_CONF) < B.CMP THEN 0 WHEN B.DD <= 0 THEN NULL ELSE ((B.EFP + B.QTD_OC_CONF) - CASE WHEN PR.REGRA_PREVISAO_FIRME = 2 THEN B.CMP ELSE 0 END) / B.DD END) AS COB_CONTRAT_DIAS FROM b3 B CROSS JOIN prm PR ), proj AS ( SELECT B.CODEMP, B.CODPROD, R.DT_PREV, R.DT_PREV - B.DT_BASE AS D_I, (CASE WHEN (B.EFP + R.ACUM_ANTES) < B.CMP THEN 0 WHEN B.DD <= 0 THEN NULL ELSE ((B.EFP + R.ACUM_ANTES) - CASE WHEN PR.REGRA_PREVISAO_FIRME = 2 THEN B.CMP ELSE 0 END) / B.DD END) AS T_ANTES, (CASE WHEN PR.REGRA_PREVISAO_FIRME = 2 THEN B.CMP + B.DD * (R.DT_PREV - B.DT_BASE) ELSE GREATEST(B.CMP, B.DD * (R.DT_PREV - B.DT_BASE)) END) - (B.EFP + R.ACUM_ANTES) AS FALTA_ANTES FROM b4 B JOIN rec2 R ON R.CODEMP = B.CODEMP AND R.CODPROD = B.CODPROD CROSS JOIN prm PR ), proj1 AS ( SELECT P.CODEMP, P.CODPROD, P.DT_PREV, P.T_ANTES, P.FALTA_ANTES, ROW_NUMBER() OVER (PARTITION BY P.CODEMP, P.CODPROD ORDER BY P.DT_PREV) AS RN FROM proj P WHERE P.T_ANTES IS NOT NULL AND P.T_ANTES < P.D_I ), recsum AS ( SELECT R.CODEMP, R.CODPROD, SUM(R.QTD) AS QTD_DATADA, MIN(R.DT_PREV) AS DT_PROX_RECEB, SUM(CASE WHEN R.ORDEM_REC = 1 THEN R.QTD ELSE 0 END) AS QTD_PROX_RECEB FROM rec2 R GROUP BY R.CODEMP, R.CODPROD ), b5 AS ( SELECT B.*, RS.DT_PROX_RECEB, RS.QTD_PROX_RECEB, NVL(RS.QTD_DATADA, 0) AS QTD_OC_DATADA, CASE WHEN P1.CODPROD IS NOT NULL THEN 1 ELSE 0 END AS FL_FALTA_ANTES_RECEB, P1.DT_PREV AS DT_RECEB_APOS_FALTA, P1.FALTA_ANTES AS QTD_FALTA_ANTES_RECEB, CASE WHEN P1.CODPROD IS NOT NULL THEN P1.T_ANTES ELSE (CASE WHEN (B.EFP + NVL(RS.QTD_DATADA, 0)) < B.CMP THEN 0 WHEN B.DD <= 0 THEN NULL ELSE ((B.EFP + NVL(RS.QTD_DATADA, 0)) - CASE WHEN PR.REGRA_PREVISAO_FIRME = 2 THEN B.CMP ELSE 0 END) / B.DD END) END AS T_FALTA_PROJ FROM b4 B LEFT JOIN proj1 P1 ON P1.CODEMP = B.CODEMP AND P1.CODPROD = B.CODPROD AND P1.RN = 1 LEFT JOIN recsum RS ON RS.CODEMP = B.CODEMP AND RS.CODPROD = B.CODPROD CROSS JOIN prm PR ), b6 AS ( SELECT B.*, CASE WHEN B.T_FALTA_PROJ IS NOT NULL AND B.T_FALTA_PROJ <= 3650 THEN B.DT_BASE + CAST(FLOOR(B.T_FALTA_PROJ) AS INTEGER) END AS DT_FALTA_EST, CASE WHEN B.FL_CONSIGNADO = 1 THEN 0 ELSE GREATEST(B.REQUISITO - B.POS_CONTRATADA, 0) END AS NEC_BRUTA, CASE WHEN B.FL_CONSIGNADO = 1 THEN 0 ELSE GREATEST(B.REQUISITO_SOMA - B.POS_CONTRATADA, 0) END AS NEC_SOMA, CASE WHEN B.FL_CONSIGNADO = 1 THEN 0 ELSE GREATEST(B.REQUISITO_MAIOR - B.POS_CONTRATADA, 0) END AS NEC_MAIOR FROM b5 B ), b7 AS ( SELECT B.*, LEAST(B.QTD_OC_NAO_CONF, B.NEC_BRUTA) AS NEC_EM_OC_NAO_CONF FROM b6 B ), b8 AS ( SELECT B.*, CASE WHEN 0 = 1 THEN LEAST(NVL(B.QTD_COTACAO, 0), B.NEC_BRUTA - B.NEC_EM_OC_NAO_CONF) END AS NEC_EM_COTACAO FROM b7 B ), b9 AS ( SELECT B.*, B.NEC_BRUTA - B.NEC_EM_OC_NAO_CONF - NVL(B.NEC_EM_COTACAO, 0) AS NEC_NAO_SOLIC, CASE WHEN NVL(B.LOTEMIN, 0) < 0 OR NVL(B.AGRUPMIN, 0) < 0 THEN 1 ELSE 0 END AS FL_LOTE_INVALIDO FROM b8 B ), b10 AS ( SELECT B.*, CASE WHEN PR.LOTE_MULTIPLO = 1 AND B.NEC_NAO_SOLIC > 0 THEN CASE WHEN NVL(B.AGRUPMIN, 0) > 0 THEN CEIL(ROUND(GREATEST(B.NEC_NAO_SOLIC, CASE WHEN B.LOTEMIN > 0 THEN B.LOTEMIN ELSE 0 END) / B.AGRUPMIN, 6)) * B.AGRUPMIN ELSE GREATEST(B.NEC_NAO_SOLIC, CASE WHEN B.LOTEMIN > 0 THEN B.LOTEMIN ELSE 0 END) END END AS QTD_ARRED FROM b9 B CROSS JOIN prm PR ), plano AS ( SELECT B.*, CASE WHEN B.QTD_ARRED IS NOT NULL THEN B.QTD_ARRED - B.NEC_NAO_SOLIC END AS EXCESSO_ARRED, CASE WHEN B.PRECO_REF IS NOT NULL AND B.DISPONIVEL < 0 THEN -B.DISPONIVEL * B.PRECO_REF END AS VLR_FALTA_ATUAL, CASE WHEN B.PRECO_REF IS NOT NULL THEN B.NEC_NAO_SOLIC * B.PRECO_REF END AS VLR_NEC_NAO_SOLIC, B.N_CONS_NAO_CONC + B.N_PED_NAO_CONC + B.N_OC_NAO_CONC + B.N_COT_NAO_CONC AS N_NAO_CONC, CASE WHEN B.QTD_ESTOQUE < 0 OR B.COB_FISICA_DIAS = 0 THEN 'P1_CRITICO' WHEN B.T_FALTA_PROJ IS NOT NULL AND FLOOR(B.T_FALTA_PROJ) < B.LT THEN 'P2_RUPTURA_IMINENTE' WHEN B.POS_CONTRATADA < B.PONTO_PEDIDO + B.DD * PR.MARGEM_ATENCAO_DIAS THEN 'P3_ATENCAO' WHEN B.FL_SEM_GIRO = 1 AND B.QTD_ESTOQUE > 0 AND (B.QTD_PEDIDOS > 0 OR B.CMP > 0) THEN 'REVISAR_SEM_GIRO' WHEN B.DD > 0 AND B.COB_CONTRAT_DIAS > PR.COBERTURA_MAX_DIAS THEN 'P0_EXCESSO' WHEN B.FL_SEM_GIRO = 1 AND B.QTD_ESTOQUE > 0 THEN 'P0_SEM_GIRO' ELSE 'OK' END AS PRIORIDADE, CASE WHEN B.QTD_ESTOQUE < 0 THEN 'ESTOQUE_NEGATIVO;' ELSE '' END || CASE WHEN B.DISPONIVEL < 0 THEN 'COMPROMISSO_MAIOR_QUE_ESTOQUE;' ELSE '' END || CASE WHEN B.COB_FISICA_DIAS = 0 AND B.QTD_ESTOQUE >= 0 AND B.DISPONIVEL >= 0 THEN 'SEM_COBERTURA_FISICA;' ELSE '' END || CASE WHEN B.FL_FALTA_ANTES_RECEB = 1 THEN 'FALTA_ANTES_RECEBIMENTO;' ELSE '' END || CASE WHEN B.T_FALTA_PROJ IS NOT NULL AND FLOOR(B.T_FALTA_PROJ) < B.LT THEN 'FALTA_DENTRO_LEAD_TIME;' ELSE '' END || CASE WHEN B.POS_CONTRATADA < B.PONTO_PEDIDO THEN 'ABAIXO_PONTO_PEDIDO;' WHEN B.POS_CONTRATADA < B.PONTO_PEDIDO + B.DD * PR.MARGEM_ATENCAO_DIAS THEN 'PROXIMO_PONTO_PEDIDO;' ELSE '' END || CASE WHEN B.FL_SEM_GIRO = 1 AND B.QTD_ESTOQUE > 0 AND (B.QTD_PEDIDOS > 0 OR B.CMP > 0) THEN 'SEM_GIRO_COM_COMPROMISSO;' WHEN B.FL_SEM_GIRO = 1 AND B.QTD_ESTOQUE > 0 THEN 'SEM_GIRO;' ELSE '' END || CASE WHEN B.DD > 0 AND B.COB_CONTRAT_DIAS > PR.COBERTURA_MAX_DIAS THEN 'COBERTURA_ACIMA_MAXIMO;' ELSE '' END || CASE WHEN B.FL_HIST_INSUF = 1 THEN 'HISTORICO_INSUFICIENTE;' ELSE '' END || CASE WHEN B.FL_CONSUMO_NEG = 1 THEN 'CONSUMO_LIQUIDO_NEGATIVO;' ELSE '' END || CASE WHEN B.N_CONS_NAO_CONC + B.N_PED_NAO_CONC + B.N_OC_NAO_CONC + B.N_COT_NAO_CONC > 0 THEN 'UNIDADE_NAO_CONCILIADA;' ELSE '' END || CASE WHEN B.QTD_OC_NAO_CONF > 0 THEN 'OC_NAO_CONFIRMADA;' ELSE '' END || CASE WHEN B.N_OC_ATRAS > 0 THEN 'OC_ATRASADA;' ELSE '' END || CASE WHEN B.N_OC_SEM_PREV > 0 THEN 'OC_SEM_PREVISAO;' ELSE '' END || CASE WHEN B.N_OC_ANTIGA > 0 THEN 'OC_ANTIGA_ABERTA;' ELSE '' END || CASE WHEN B.PRECO_REF IS NULL THEN 'SEM_PRECO_REFERENCIA;' ELSE '' END || CASE WHEN B.FL_LT_PADRAO = 1 THEN 'LEAD_TIME_PADRAO;' ELSE '' END || CASE WHEN B.FL_CONSIGNADO = 1 THEN 'CONSIGNADO_SEM_CALCULO;' ELSE '' END || CASE WHEN B.ESTMIN_CAD > 0 AND B.DISPONIVEL < B.ESTMIN_CAD THEN 'ABAIXO_ESTMIN_CADASTRO;' ELSE '' END || CASE WHEN B.FL_LOTE_INVALIDO = 1 THEN 'LOTE_MULTIPLO_INVALIDO;' ELSE '' END AS MOTIVOS FROM b10 B CROSS JOIN prm PR ), res AS ( SELECT PL.PRIORIDADE, COUNT(*) AS N_SKUS, SUM(CASE WHEN PL.DISPONIVEL < 0 THEN 1 ELSE 0 END) AS N_FALTA_ATUAL, SUM(NVL(PL.VLR_FALTA_ATUAL, 0)) AS VLR_FALTA_ATUAL, SUM(CASE WHEN PL.DISPONIVEL < 0 AND PL.PRECO_REF IS NULL THEN 1 ELSE 0 END) AS N_FALTA_SEM_PRECO, SUM(CASE WHEN PL.NEC_NAO_SOLIC > 0 THEN 1 ELSE 0 END) AS N_NEC, SUM(NVL(PL.VLR_NEC_NAO_SOLIC, 0)) AS VLR_NEC_NAO_SOLIC, SUM(CASE WHEN PL.NEC_NAO_SOLIC > 0 AND PL.PRECO_REF IS NULL THEN 1 ELSE 0 END) AS N_NEC_SEM_PRECO, SUM(CASE WHEN PL.NEC_EM_OC_NAO_CONF > 0 THEN 1 ELSE 0 END) AS N_NEC_OC_NAO_CONF, SUM(CASE WHEN PL.NEC_EM_COTACAO > 0 THEN 1 ELSE 0 END) AS N_NEC_COTACAO, SUM(PL.FL_FALTA_ANTES_RECEB) AS N_FALTA_ANTES_RECEB, SUM(PL.FL_HIST_INSUF) AS N_HIST_INSUF, SUM(CASE WHEN PL.N_NAO_CONC > 0 THEN 1 ELSE 0 END) AS N_UN_NAO_CONC, SUM(CASE WHEN PL.PRECO_REF IS NULL THEN 1 ELSE 0 END) AS N_SEM_PRECO, SUM(PL.FL_LT_PADRAO) AS N_LT_PADRAO, SUM(CASE WHEN PL.N_OC_ATRAS > 0 THEN 1 ELSE 0 END) AS N_OC_ATRAS, SUM(CASE WHEN PL.N_OC_SEM_PREV > 0 THEN 1 ELSE 0 END) AS N_OC_SEM_PREV, SUM(CASE WHEN PL.QTD_OC_NAO_CONF > 0 THEN 1 ELSE 0 END) AS N_OC_NAO_CONF, SUM(CASE WHEN PL.N_OC_ANTIGA > 0 THEN 1 ELSE 0 END) AS N_OC_ANTIGA, SUM(CASE WHEN PL.N_OC_TOP_SEP > 0 THEN 1 ELSE 0 END) AS N_OC_TOP_SEP, SUM(PL.FL_CONSIGNADO) AS N_CONSIGNADO, SUM(PL.FL_LOTE_INVALIDO) AS N_LOTE_INVALIDO, SUM(PL.FL_CONSUMO_NEG) AS N_CONSUMO_NEG, SUM(CASE WHEN PL.CURVA IS NULL THEN 1 ELSE 0 END) AS N_SEM_CURVA FROM plano PL GROUP BY PL.PRIORIDADE ) SELECT R.PRIORIDADE, R.N_SKUS, R.N_FALTA_ATUAL, ROUND(R.VLR_FALTA_ATUAL, 2) AS VLR_FALTA_ATUAL, R.N_FALTA_SEM_PRECO, R.N_NEC, ROUND(R.VLR_NEC_NAO_SOLIC, 2) AS VLR_NEC_NAO_SOLIC, R.N_NEC_SEM_PRECO, R.N_NEC_OC_NAO_CONF, R.N_NEC_COTACAO, R.N_FALTA_ANTES_RECEB, R.N_HIST_INSUF, R.N_UN_NAO_CONC, R.N_SEM_PRECO, R.N_LT_PADRAO, R.N_OC_ATRAS, R.N_OC_SEM_PREV, R.N_OC_NAO_CONF, R.N_OC_ANTIGA, R.N_OC_TOP_SEP, R.N_CONSIGNADO, R.N_LOTE_INVALIDO, R.N_CONSUMO_NEG, R.N_SEM_CURVA, 0 AS COTACAO_MAPEADA, TO_CHAR(JC.DT_BASE, 'YYYY-MM-DD') AS DT_BASE, JA.SNAPSHOT, TO_CHAR(JC.INI, 'YYYY-MM-DD') AS JANELA_INI, TO_CHAR(ADD_MONTHS(JC.M0, -1), 'YYYY-MM-DD') AS JANELA_FIM, ROUND(JC.FRAC, 4) AS FRAC_PARCIAL, (SELECT COUNT(*) FROM TGFPRO PX WHERE PX.ATIVO = 'S' AND PX.CODPROD NOT IN (SELECT KX.CODPROD FROM chaves KX)) AS N_ATIVOS_FORA FROM res R CROSS JOIN janc JC CROSS JOIN jan JA ORDER BY (CASE R.PRIORIDADE WHEN 'P1_CRITICO' THEN 1 WHEN 'P2_RUPTURA_IMINENTE' THEN 2 WHEN 'P3_ATENCAO' THEN 3 WHEN 'REVISAR_SEM_GIRO' THEN 4 WHEN 'P0_EXCESSO' THEN 5 WHEN 'P0_SEM_GIRO' THEN 6 ELSE 7 END)","params":["CODEMP","DIAS_MES","MESES_MEDIA","MES_PARCIAL","MEDIA_MODO","MIN_MESES_HIST","LEADTIME_DEFAULT","COBERTURA_ALVO_A","COBERTURA_ALVO_B","COBERTURA_ALVO_C","COBERTURA_SEM_CURVA","POLITICA_SEGURANCA","SEGURANCA_PCT_LT","MARGEM_ATENCAO_DIAS","COBERTURA_MAX_DIAS","FONTE_COMPROMISSO","DESCONTA_BLOQUEADO","REGRA_PREVISAO_FIRME","LOTE_MULTIPLO","ABC_CALCULADA","ABC_LIMITE_A","ABC_LIMITE_B","OC_ANTIGA_MESES"],"tipos":["I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I"]},"Q_SNAP_PROBE":{"sql":"WITH prm AS ( SELECT CAST(TO_NUMBER(?) AS INTEGER) AS CODEMP, TO_DATE(?, 'YYYY-MM-DD') AS DT_INI, TO_DATE(?, 'YYYY-MM-DD') AS DT_FIM FROM DUAL ) SELECT COUNT(*) AS N, TO_CHAR(MIN(S.DATA_SNAPSHOT), 'YYYY-MM-DD') AS PRIMEIRO, TO_CHAR(MAX(S.DATA_SNAPSHOT), 'YYYY-MM-DD') AS ULTIMO FROM BI_F_SUGESTAO_COMPRA S CROSS JOIN prm PR WHERE S.DATA_SNAPSHOT >= PR.DT_INI AND S.DATA_SNAPSHOT < PR.DT_FIM + 1 AND S.CODEMP = PR.CODEMP","params":["CODEMP","DT_INI","DT_FIM"],"tipos":["I","S","S"]}};
/* ===== src/calc.js ===== */
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

/* ===== src/motor.js ===== */
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

/* ===== src/demo.js ===== */
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

/* ===== src/app.js ===== */
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

})();
</script>
</body>
</html>
