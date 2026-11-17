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
/*@@CSS@@*/
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
<footer id="rodape">Somente leitura: o painel executa apenas SELECT e n&#xE3;o grava nada no Sankhya. N&#xE3;o homologado. Vers&#xE3;o @@VERSAO@@ &#xB7; build @@HASH@@.</footer>
<a id="dl" href="#" hidden>download</a>
<script>
/*@@JS@@*/
</script>
</body>
</html>
