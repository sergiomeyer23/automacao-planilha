# Changelog

## 2.0.0-nao-homologado — 17/11/2026

Versão reescrita a partir de `original/bi_oc_sankhya.jsp` (sha256 `4b794ebf…3b1e5`). **Não homologada.**

### Divergências entre o resumo recebido e o arquivo real

- O original tem **13 consultas**, não 14: Q_DIAG, Q_PARAMS, Q_EXEC, Q_TOP15, Q_FILA, Q_NAO_COBRE,
  Q_OC_KPIS, Q_FUNIL, Q_AGING, Q_ATRASO, Q_SNAP_PROBE, Q_ADERENCIA, Q_CONSUMO.
- O rodapé dizia "não depende de tabelas criadas pelo DBA", mas o painel lia duas tabelas opcionais
  (BI_PARAM_COMPRA e BI_F_SUGESTAO_COMPRA).
- Q_EXEC/Q_FILA/Q_NAO_COBRE/Q_TOP15/Q_CONSUMO repetiam o mesmo bloco de S&OP, e o bloco de
  classificação de OC aparecia copiado em 10 das 13 consultas.
- Outros problemas encontrados no código e não citados no resumo, todos corrigidos:
  - `NVL(FATOR, 1)` somava quantidades sem conversão como se estivessem na unidade padrão;
  - `JOIN TGFTOP` por versão fazia sumir OCs cuja `DHTIPOPER` não tinha versão correspondente;
  - o consumo incluía itens cancelados;
  - o empenho descontava `QTDCONFERIDA`;
  - o recebimento por OS aceitava entradas até 365 dias **antes** da OC;
  - o "Ruptura R$" usava preço de qualquer OC não cancelada, sem normalizar unidade (`NVL(FATOR,1)`);
  - o atraso considerava a previsão estimada (OC + lead time) como compromisso;
  - o OTIF usava data estimada e vínculo por OS;
  - aderência e SLA eram calculados por proximidade de data;
  - `FL_SOB_ENCOMENDA` era constante 0;
  - a mensagem de timeout sugeria "materializar as views", embora o painel não use views.

### Arquitetura

- Fonte SQL única: `sql/macros.sql` + `sql/fragmentos/` + `sql/consultas/`. O build gera as consultas,
  o bloco de parâmetros e o JSP final. O SQL total caiu de ~166 KB (numa linha) para ~99 KB em 8 consultas.
- Build determinístico com validação de somente leitura, binds, portabilidade (Oracle 11g+: sem
  FETCH FIRST/ROWNUM/CONNECT BY/KEEP), identificadores ≤ 30 caracteres, ES5 e segurança do JSP (EL).
- Configuração separada: mapeamentos de TOP, locais excluídos, limites (`config/painel.json`) e
  parâmetros com faixas e status (`config/parametros.json`).
- Grão do cálculo: empresa + produto (antes: produto consolidado entre empresas).
- 13 consultas → 8: Q_RESUMO (totais globais), Q_PLANO (fila, top e "não cobre"), Q_CONSUMO,
  Q_CARTEIRA (blocos agregados), Q_OC_LISTA, Q_DIAG, Q_PARAMS, Q_SNAP_PROBE. Q_ADERENCIA removida.
- Motor de referência JS (`src/motor.js`) que reproduz as consultas, usado no modo demonstração e
  na prova de paridade com o SQL.

### Cálculo

- **Segurança (5.1)**: uma única política (`POLITICA_SEGURANCA`). A segurança agora entra no ponto
  de pedido e no requisito, uma vez só. Os 20% ficam marcados como legado não aprovado.
- **Curva ABC (5.2)**: "sem curva" é categoria própria, com `COBERTURA_SEM_CURVA`. Curva calculada
  opcional (consumo × preço de compra, cortes 80/95%), documentada.
- **Perdas (5.3)**: a tela descreve o cálculo efetivo. Perda só entra com TOP mapeada (hoje, nenhuma).
- **Mês parcial (5.4)**: fora por padrão. Opcionalmente proporcional aos dias decorridos, só na média
  simples. Exclui movimentos da data-base em diante. Limites de data com horário corrigidos.
  Data-base = data do banco, separada do período de fluxo.
- **Divisor (5.5)**: por produto, a partir do primeiro consumo. Meses sem movimento contam como zero.
  Produto novo é distinguido do antigo sem giro. "Histórico insuficiente" é sinalizado. Divisor exibido.
- **Médias (5.6)**: ponderada como pesos por mês (sobreposição documentada), renormalizada em série
  curta; sem divisão por zero.
- **Previsão × pedido firme (6.2)**: regra MAIOR por padrão, SOMA exibida como cenário.
- **Compromisso (6.1)**: uma única fonte (pedidos ou RESERVADO). Bloqueado WMS separado. Locais
  excluídos configuráveis.
- **OC (6.3)**: sem corte de 24 meses para saldo aberto. Situação confirmada / não confirmada /
  aprovação não determinada (liberações agregadas antes do join). Atrasada e sem previsão = prazo
  incerto, fora da projeção datada. OC antiga sinalizada.
- **Cotação (6.4)**: camadas separadas (física, contratada, em OC não confirmada, em negociação, não
  solicitada). Sem fonte de cotação: "não mapeada", nunca zero.
- **Cobertura e prioridade (6.5)**: cobertura física, cobertura com OC e projeção com recebimentos em
  ordem de data (falta antes do recebimento, quantidade em risco). Prioridades com precedência
  explícita e lista de motivos. Sem giro com compromisso não vira excesso. Datas limitadas a 10 anos.
- **Lote e múltiplo (6.6)**: lote e depois múltiplo, atendendo os dois. Negativos ignorados e
  sinalizados. Excesso exibido. Desligado por padrão (unidade não comprovada).
- **Unidades (7)**: unidade não conciliada sai das quantidades e é contada. Nunca soma unidades
  diferentes nos totais.
- **Preço (7)**: referência da última OC confirmada, normalizada pela unidade, com data/OC/TOP. TOP
  1741 separada. Ausência = nulo. Valores rotulados como estimativa.
- **Carteira (8, 9)**: situação de entrega sem confundir encerramento com recebimento. Vínculo nativo ×
  inferido por OS (com detecção de entrada compartilhada). OTIF indisponível, com indicador aproximado
  nomeado e numerador/denominador/exclusões visíveis. Aderência e SLA indisponíveis.
- **PRG/JIT (3)**: nenhuma classificação. "Política não validada" em todas as linhas.

### Interface

- 5 abas mantidas, renomeadas: Visão geral, Fila de análise, Carteira de OC, Consumo e média,
  Parâmetros e qualidade.
- Detalhe completo do cálculo por produto, drill-down de OCs e consumo do produto, detalhe por item de OC.
- Painel de qualidade (políticas não validadas, unidades, prazo, preço, vínculo, parâmetros legados).
- Prioridades com símbolo e texto (não só cor). Cabeçalho fixo, ordenação, busca e estados distintos
  para carregando, erro, vazio e indisponível.
- Truncamento explícito. KPIs sempre sobre todos os itens (Q_RESUMO). Exportação CSV das linhas
  visíveis, compatível com Excel pt-BR e protegida contra fórmula.
- Erro classificado: ORA-00942 em tabela opcional é informado como ausência; outros erros não são
  mascarados. O detalhe técnico fica no log.

### Robustez

- Cache por modo + build + consulta + todos os binds. "Atualizar dados" invalida o cache.
- Respostas antigas ignoradas por área. Até 2 consultas simultâneas. O tempo de espera não é
  descrito como cancelamento.
- Chaves antigas da BI_PARAM_COMPRA (DIVISOR_MEDIA, INCLUI_MES_ATUAL, JANELA_VINCULO_DIAS) ignoradas
  com aviso. Valores fora da faixa recusados.

### Comportamentos que mudaram e afetam números (conferir na homologação)

- Necessidade menor quando há pedido firme (regra MAIOR) e maior pela segurança, que agora tem efeito.
- Consumo sem itens não convertidos (antes contavam com fator 1) e sem itens cancelados.
- Média por produto com meses zerados (antes, divisor global por meses com dados).
- Mês corrente fora da média (antes, mês inteiro parcial).
- OC não confirmada não cobre a necessidade "contratada" (antes, cobria).
- Compromisso sem descontar QTDCONFERIDA.
- Limite da fila de 2000 para 1000 linhas (totais não dependem do limite).
