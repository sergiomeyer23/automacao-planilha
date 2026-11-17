# Parâmetros e decisões a aprovar

Nada do que está abaixo foi aprovado. Enquanto não for, o painel serve para análise e **não para
decisão de compra**. Os valores são lidos de `BI_PARAM_COMPRA` (CHAVE/VALOR) quando a tabela existe.
Senão, valem os padrões de `config/parametros.json`. A tela mostra a origem de cada valor.

## A. Decisões de negócio que bloqueiam o uso decisório

| # | Decisão | Situação atual no painel | O que é preciso |
|---|---|---|---|
| A1 | **Classificação PRG × JIT por item** | Nenhum item é classificado ("Política não validada"). Reposição estatística e pedidos firmes aparecem como lentes separadas. | Fonte por **item** de pedido (pedido misto existe), com regra escrita e amostra conferida. SOLCOMPRA, AD_ABASTECIMENTO, AD_MRPTIPPAP e AD_CLIENTETPP não servem como estão (ver `MAPA_DE_DADOS.md`). A função `Calc.classificarPolitica` já exige classificador validado e por item. |
| A2 | Papéis das TOPs (consumo, devolução, empenho, OC) | Herdados do painel antigo | Lista conferida por TOP, incluindo TOPs novas/inativas e a TOP 1742 |
| A3 | TOPs de **perda** | Nenhuma: perdas não entram no consumo | Informar quais TOPs são perda, se devem entrar |
| A4 | Fonte de **cotação** | Não mapeada: "necessidade em negociação" indisponível | TOP (ou outra fonte) de cotação/solicitação, com saldo que baixa quando vira OC |
| A5 | "OC confirmada = contratada" | `STATUSNOTA = 'L'` sem liberação pendente/reprovada | Confirmar que a confirmação da OC equivale a compromisso com o fornecedor. Dizer se algum evento de TSILIB deve ser exigido (EVENTO não foi validado) |
| A6 | Regra previsão × pedido firme | MAIOR (proposta); SOMA exibida como cenário | Escolher a regra de consumo da previsão (ou fornecer datas de entrega dos pedidos para planejar por período) |
| A7 | TOP 1741 (e 1742) | Saldo conta como OC; preço separado | Definir se é industrialização, se cobre necessidade de produto acabado e com que preço |
| A8 | Locais excluídos (1030000, 2030000) | Excluídos (herdado) | Confirmar o que são e se há outros (ex.: estoque de terceiros, avariados) |
| A9 | Consignado sem cálculo | Necessidade = 0 se `CODPARCCONSIG > 0` (herdado) | Confirmar a regra |
| A10 | Compromisso: pedidos × RESERVADO | Pedidos (legado) | Escolher a fonte. O painel nunca desconta as duas |
| A11 | QTDCONFERIDA | Não descontada do compromisso (o original descontava) | Confirmar se a conferência baixa estoque ou não. Descontar libera estoque ainda fisicamente comprometido |
| A12 | Unidade de AGRUPMIN e LOTECOMPMINIMO | Não aplicados (`LOTE_MULTIPLO = 0`) | Confirmar a unidade (padrão ou de compra) com um produto real |
| A13 | Sentido de DIVIDEMULTIPLICA | M = multiplica, D = divide (herdado) | Conferir com um produto que tenha CX/PC cadastrado |
| A14 | Vínculo de recebimento por OS + produto | Só inferido e sinalizado; tolerância de 90% não aplicada | Regra aprovada de apropriação (uma entrada não pode ser contada em duas OCs) ou vínculo nativo |
| A15 | Preço de referência | Última OC confirmada, por unidade padrão | Aprovar como referência, ou indicar outra fonte de custo |
| A16 | Código antigo (AD_CODPRODANTIGO) | Desligado | Tabela, significado e regra de vínculo validados antes de qualquer consolidação |

## B. Indicadores indisponíveis e a extensão necessária

| Indicador | Falta | Extensão sugerida (não implementada) |
|---|---|---|
| OTIF | data de compromisso validada, quantidade por entrega vinculada à OC, regra de tolerância, tratamento de parcial | Entregas vinculadas por TGFVAR com quantidade atendida por documento, mais regra de tolerância aprovada |
| Aderência da sugestão / SLA de abertura | vínculo rastreável sugestão → OC | Snapshot diário da sugestão com identificador, revisões e unidade; a OC registra a sugestão de origem. Sem isso, proximidade de produto e data não comprova |
| Enviado ao fornecedor | registro no Sankhya | Campo/evento validado |
| Produção / situação da OS | integração com o eCalc (Tuicial) | API ou arquivo do eCalc. Sem isso: "não disponível", sem inferir pelo status da OC |
| Data necessária por OC | vínculo OC → demanda (pedido PRG / necessidade JIT) | Depende de A1 |

## C. Parâmetros numéricos

"Legado" = valor do painel antigo, nunca aprovado. "Proposta" = valor novo, também não aprovado.

| Chave | Padrão | Status | Pergunta ao negócio |
|---|---|---|---|
| DIAS_MES | 30 | legado | Lead time está em dias corridos ou úteis? Usar 30 (corridos) ou ~21,75 (úteis), coerente com o lead time |
| MESES_MEDIA | 12 | legado | Quantos meses completos representam a demanda? |
| MES_PARCIAL | 0 | proposta | Incluir o mês corrente proporcional? (recomendado: não) |
| MEDIA_MODO | 0 (simples) | legado | Simples ou ponderada (70% de peso nos 3 últimos meses)? |
| MIN_MESES_HIST | 3 | proposta | Abaixo de quantos meses o histórico é insuficiente? |
| LEADTIME_DEFAULT | 30 | legado | Lead time quando o cadastro está vazio (a tela conta quantos itens usam o padrão) |
| COBERTURA_ALVO_A / B / C | 45 / 30 / 21 | legado | Só valem se houver curva |
| COBERTURA_SEM_CURVA | 21 | proposta | Cobertura para produto sem curva (hoje, todos) |
| POLITICA_SEGURANCA | 1 (fração do LT) | proposta | Qual política única: nenhuma, fração do LT ou ESTMIN do cadastro? |
| SEGURANCA_PCT_LT | 0,20 | legado | Percentual de segurança (agora tem efeito: soma ao ponto de pedido e ao requisito) |
| MARGEM_ATENCAO_DIAS | 15 | legado | Margem do P3 |
| COBERTURA_MAX_DIAS | 90 | legado | Acima disso é excesso |
| FONTE_COMPROMISSO | 1 (pedidos) | legado | Ver A10 |
| DESCONTA_BLOQUEADO | 0 | legado | Descontar WMSBLOQUEADO? |
| REGRA_PREVISAO_FIRME | 1 (MAIOR) | proposta | Ver A6 |
| LOTE_MULTIPLO | 0 | proposta | Ver A12 |
| ABC_CALCULADA | 0 | proposta | Usar curva calculada por consumo × preço de compra? |
| ABC_LIMITE_A / B | 0,80 / 0,95 | proposta | Cortes da curva |
| OC_ANTIGA_MESES | 12 | proposta | A partir de quando uma OC aberta é "antiga"? |
| TOLERANCIA_ATRASO_DIAS | 0 | proposta | Tolerância do indicador aproximado de atendimento |

Faixas aceitas e validações cruzadas (`MIN_MESES_HIST ≤ MESES_MEDIA`, `ABC_LIMITE_B > ABC_LIMITE_A`)
ficam em `config/parametros.json`. Valor fora da faixa na tabela é recusado com aviso e o padrão é usado.

### Chaves antigas da BI_PARAM_COMPRA

| Chave | Tratamento |
|---|---|
| DIVISOR_MEDIA | Ignorada com aviso. O divisor global criava viés; agora o divisor é por produto |
| INCLUI_MES_ATUAL | Ignorada com aviso. No original, o mês parcial contava como mês inteiro; use MES_PARCIAL |
| JANELA_VINCULO_DIAS | Ignorada com aviso. Aderência por proximidade foi removida |

## D. Limites técnicos (configuração do build, não são regra de negócio)

| Chave | Valor | Efeito |
|---|---|---|
| LIMITE_FILA | 1000 | linhas da fila trazidas para a tela (o original usava 2000). Totais não são afetados |
| LIMITE_OC | 300 | itens de OC na lista |
| TOPN_CONSUMO | 100 (tela: 50/100/200) | produtos na matriz de consumo |
| Tempo de espera | 180 s | o painel para de esperar; **não cancela** a consulta no banco |
| Consultas simultâneas | 2 | evita disparar todas as consultas pesadas ao mesmo tempo |
