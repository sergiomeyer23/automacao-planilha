# Mapa de dados

Regra adotada: **só colunas que já apareciam no painel original** (demonstradas no ambiente, porque ele
executava contra elas), mais os novos usos dessas mesmas colunas. Nenhuma coluna nova foi inventada.
Exceção controlada: `AD_CODPRODANTIGO`, desligado por configuração e nunca usado no cálculo.

A existência e o significado de cada coluna **precisam ser confirmados na homologação**: o painel
original também nunca foi homologado.

## Tabelas e colunas

| Tabela | Colunas usadas | Uso | No original? |
|---|---|---|---|
| TGFCAB | NUNOTA, CODEMP, CODTIPOPER, DHTIPOPER, DTNEG, DTPREVENT, STATUSNOTA, CODPARC, AD_OSTUICIAL | cabeçalho de notas (consumo, pedidos, OC, entradas) | sim, todas |
| TGFITE | NUNOTA, SEQUENCIA, CODPROD, QTDNEG, CODVOL, VLRTOT, QTDENTREGUE, QTDCONFERIDA, PENDENTE, CANCELADO, AD_OS | itens | sim, todas (VLRUNIT deixou de ser usado) |
| TGFPRO | CODPROD, DESCRPROD, CODVOL, CODGRUPOPROD, ATIVO, LEADTIME, ESTMIN, AGRUPMIN, LOTECOMPMINIMO, CODPARCCONSIG | cadastro | sim (REFERENCIA e MARCA deixaram de ser lidas) |
| TGFGRU | CODGRUPOPROD, DESCRGRUPOPROD | descrição do grupo | sim |
| TGFVOA | CODPROD, CODVOL, DIVIDEMULTIPLICA, QUANTIDADE, ATIVO | conversão de unidade | sim |
| TGFEST | CODEMP, CODPROD, CODLOCAL, ESTOQUE, RESERVADO, WMSBLOQUEADO | estoque físico, reserva, bloqueio | sim (RESERVADO e WMSBLOQUEADO eram lidos e não usados) |
| TGFTOP | CODTIPOPER, DHALTER, DESCROPER | descrição da TOP na versão da nota | sim (agora LEFT JOIN: OC sem versão não some) |
| TGFPAR | CODPARC, NOMEPARC | nome do fornecedor | sim |
| TGFVAR | NUNOTA, NUNOTAORIG, SEQUENCIAORIG | vínculo nativo de documentos | sim |
| TSILIB | TABELA, NUCHAVE, DHLIB, REPROVADO | liberações da OC | sim |
| DUAL | — | parâmetros e constantes | sim |

### Tabelas opcionais (não criadas pelo painel)

| Tabela | Colunas | Se não existir |
|---|---|---|
| BI_PARAM_COMPRA | CHAVE, VALOR | ORA-00942 → padrões do código + aviso informativo. Outro erro → aviso de erro (não é tratado como ausência). |
| BI_F_SUGESTAO_COMPRA | CODEMP, DATA_SNAPSHOT (+ CODPROD, QTD_SUGERIDA no original) | Só a verificação manual de diagnóstico a consulta. Aderência e SLA continuam indisponíveis mesmo com ela (sem vínculo sugestão → OC). |

O painel não cria tabela, view, job, procedure, trigger nem campo.

## Papéis de TOP (config/painel.json, herdados, **não validados**)

| Papel | TOPs | Uso |
|---|---|---|
| CONSUMO | 1131, 1118, 1117, 1729, 1130, 1727, 1724, 1730, 1781, 1782, 1738 | saídas que formam o consumo |
| DEVOLUCAO | 1200, 1201, 1211, 1206 | abatem o consumo |
| PERDA | — (nenhuma) | perdas não entram |
| EMPENHO | 1000, 1005, 1008, 1002, 1009, 1001, 1728, 1010 | pedidos pendentes (compromisso) |
| ORDEM_COMPRA | 99, 100, 101, 108, 1741, 1742 | OCs (1741 com preço separado) |
| COTACAO | — (nenhuma) | necessidade em negociação: indisponível |
| ENTRADA_POR_OS | 259, 200 | vínculo inferido por OS + produto |

Uma TOP não pode ter dois papéis (o build recusa).

## Campos citados pelo negócio e **não usados**

| Campo | Motivo |
|---|---|
| TGFPRO.SOLCOMPRA ("Solicita compra?") | Reproduziu cinco itens conhecidos, mas não foi aprovado como classificador PRG/JIT. |
| TGFPAR.AD_ABASTECIMENTO | Classifica o cliente, não o item. Não resolve pedido misto. |
| AD_MRPTIPPAP | Tipo de papel, não política. |
| AD_CLIENTETPP | Rótulo de cliente e-commerce, não política. |
| AD_CODPRODANTIGO | Tabela e significado não confirmados. Com `codigoAntigo.habilitado = true` em `config/painel.json`, só é **exibido** (lido de TGFPRO). Nunca consolida histórico. |

Um teste falha se qualquer um desses nomes aparecer no SQL gerado com a configuração padrão.

## Saídas das consultas

| Consulta | Grão | Usada em |
|---|---|---|
| Q_DIAG | 1 linha | teste do `executeQuery` |
| Q_PARAMS | chave | parâmetros (opcional) |
| Q_RESUMO | prioridade (totais sem limite) | Visão geral, qualidade |
| Q_PLANO | empresa + produto (limitada, `TOTAL_LINHAS`) | Visão geral (15 primeiros), Fila, "não cobre" |
| Q_CONSUMO | empresa + produto + mês | Consumo, detalhe do produto |
| Q_CARTEIRA | bloco + chave (agregados) | Carteira, Visão geral |
| Q_OC_LISTA | item de OC (limitada, `TOTAL_LINHAS`) | Carteira, detalhe do produto |
| Q_SNAP_PROBE | 1 linha | diagnóstico (manual) |

Colunas de cada saída: SELECT final em `sql/consultas/*.sql`. O teste de contrato garante que todo
campo lido pela tela existe na saída.

Equivalência com o original: Q_EXEC → Q_RESUMO · Q_TOP15, Q_FILA, Q_NAO_COBRE → Q_PLANO ·
Q_OC_KPIS, Q_FUNIL, Q_AGING → Q_CARTEIRA · Q_ATRASO → Q_OC_LISTA · Q_ADERENCIA → removida.

## Propostas de índice (somente para avaliação do DBA; nenhuma DDL incluída; ganho não medido)

| Objeto | Colunas | Por quê |
|---|---|---|
| TGFCAB | (CODTIPOPER, DTNEG) | consumo, preço e carteira filtram por papel de TOP e período |
| TGFITE | (CODPROD, AD_OS) | vínculo inferido por OS. O `TRIM` na coluna impede o índice; avaliar índice por função ou padronizar o dado |
| TGFVAR | (NUNOTAORIG, SEQUENCIAORIG) | vínculo nativo |
| TSILIB | (TABELA, NUCHAVE) | liberações por nota |

Decidir com o plano de execução real (`EXPLAIN PLAN` / AWR) no ambiente. A seleção de itens abertos por
`PENDENTE = 'S'` tem baixa seletividade e não justifica índice próprio sem medir.
