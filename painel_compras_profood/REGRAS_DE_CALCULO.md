# Regras de cálculo

Fonte única das regras: `sql/fragmentos/*.sql` e `sql/macros.sql`. O motor de referência
(`src/motor.js`) reproduz as mesmas regras e é comparado ao SQL nos testes. Todos os valores de
parâmetro citados são padrões **não aprovados** (ver `PARAMETROS_A_APROVAR.md`).

Grão do cálculo: **empresa + produto** (`CODEMP`, `CODPROD`), apenas produtos ativos (`TGFPRO.ATIVO = 'S'`).
Com "Empresa: todas", cada empresa continua em linha própria. O estoque de uma empresa nunca cobre a
demanda de outra.

## 1. Datas

| Conceito | Regra |
|---|---|
| Data-base | `TRUNC(SYSDATE)` do **banco**. A posição de estoque é sempre a atual, então a fila sempre usa hoje. |
| PERIODO.INI / FIN | Filtram só o fluxo de OC (funil, atendimento aproximado, vínculo). Não mudam a fila. Padrão: últimos 90 dias. |
| Limites | `DTNEG >= início` e `DTNEG < fim + 1` (inclui o último dia inteiro, com horário). |
| Movimento futuro | Movimento com `DTNEG >= data-base` (inclusive o dia de hoje) não entra no consumo. |
| Janela de consumo | `MESES_MEDIA` meses completos antes do mês da data-base. Ex.: base 17/11/2026, 12 meses: nov/2025 a out/2026. |
| Mês corrente | Fora por padrão (`MES_PARCIAL = 0`). Com `MES_PARCIAL = 1`, entra o consumo de 01/11 até ontem, valendo 16/30 = 0,533 mês (só na média simples). |

## 2. Consumo

`Consumo líquido do mês = Σ saídas (papel CONSUMO) + Σ perdas (papel PERDA) − Σ devoluções (papel DEVOLUCAO)`

- Entram só notas confirmadas (`STATUSNOTA = 'L'`) e itens não cancelados.
- Os papéis vêm de `config/painel.json`. **Nenhuma TOP está mapeada como PERDA**, então perdas não
  entram, e a tela diz isso explicitamente.
- Quantidades convertidas para a unidade padrão (seção 4). Item sem conversão confiável **fica fora**
  da quantidade e é contado em `N_CONS_NAO_CONC`.
- Consumo líquido negativo na janela: a média é tratada como zero, com o alerta `CONSUMO_LIQUIDO_NEGATIVO`.

## 3. Série, divisor e médias

**Início da série** = mês do primeiro CONSUMO do produto (por empresa) no horizonte (`MESES_MEDIA + 12`
meses antes do mês corrente). É a única fonte de data demonstrada: as próprias notas. `TGFPRO` não teve
data de cadastro validada.

| Origem da série | Condição | Divisor (`N_MESES`) |
|---|---|---|
| ANTIGO | 1º consumo antes da janela | `MESES_MEDIA` (meses sem movimento contam como zero) |
| NOVO | 1º consumo dentro da janela | meses do 1º consumo até o mês anterior ao corrente |
| SO_MES_ATUAL | 1º consumo no mês corrente | 0 (+ fração se `MES_PARCIAL = 1`) |
| SEM_CONSUMO | sem consumo no horizonte | sem média (demanda zero) |

`HISTORICO_INSUFICIENTE` quando a série é NOVO/SO_MES_ATUAL e `N_MESES + fração < MIN_MESES_HIST` (padrão 3).

Limitação: um produto cujo último consumo foi há mais de 12 meses antes da janela e que volta a vender
dentro dela é tratado como NOVO (série desde a volta).

**Média simples** = `(consumo dos meses da série [+ consumo do mês parcial]) ÷ (N_MESES [+ fração])`

**Média ponderada** (`MEDIA_MODO = 1`): cada mês de idade `a` (1 = último mês completo) tem peso

```
w(a) = 0,5/3·[a ≤ 3] + 0,3/6·[a ≤ 6] + 0,2/N·[a ≤ N]
```

As janelas M3, M6 e M(janela) **se sobrepõem**: não são faixas independentes. Com 12 meses, cada um dos
3 últimos meses pesa 0,2333, cada mês de 4 a 6 pesa 0,0667 e cada mês de 7 a 12 pesa 0,0167. Os 3 meses
mais recentes somam 70% do peso. Os pesos somam 1. Para série curta, o resultado é dividido pela soma
dos pesos dos meses existentes (renormalização), sem tratar meses inexistentes como zero. O mês
parcial nunca entra na ponderada.

**Demanda diária** `DD = média usada ÷ DIAS_MES` (padrão 30, coerente com lead time em dias corridos).

## 4. Unidades (TGFVOA)

Regras ativas (`NVL(ATIVO,'S') = 'S'`) agrupadas por produto + unidade **antes** do join, o que impede
a multiplicação de linhas:

| Situação | Fator | Status |
|---|---|---|
| unidade do item = unidade do produto | 1 | PADRAO |
| uma regra, `DIVIDEMULTIPLICA = 'M'`, `QUANTIDADE > 0` | × QUANTIDADE | MULTIPLICA |
| uma regra, `DIVIDEMULTIPLICA = 'D'`, `QUANTIDADE > 0` | ÷ QUANTIDADE | DIVIDE |
| mais de uma regra distinta | não converte | AMBIGUA |
| sem regra ativa | não converte | SEM_REGRA |
| outro valor ou quantidade ≤ 0 | não converte | REGRA_INVALIDA |

O sentido M/D foi herdado do painel antigo e **precisa ser conferido com um produto real** (roteiro de
homologação). Quantidades de unidades diferentes nunca são somadas: sem fator, o item sai dos totais
de quantidade e o produto recebe `UNIDADE_NAO_CONCILIADA`. O resumo só soma contagens e R$, nunca
quantidades de produtos diferentes.

## 5. Estoque e compromissos

```
Estoque utilizável (EFP) = Σ TGFEST.ESTOQUE (locais não excluídos) − [WMSBLOQUEADO se DESCONTA_BLOQUEADO = 1]
Compromisso (CMP)        = pedidos pendentes (FONTE_COMPROMISSO = 1)  OU  TGFEST.RESERVADO (= 2)   — nunca os dois
Pedidos pendentes        = Σ (QTDNEG − QTDENTREGUE) × fator, itens das TOPs de EMPENHO com PENDENTE = 'S'
Disponível               = EFP − CMP
```

A outra fonte de compromisso e `QTDCONFERIDA` aparecem só como informação. Locais excluídos
(1030000, 2030000) estão na configuração, não no SQL.

## 6. Ordens de compra

Itens de OC com saldo vivo, **sem corte de data**: `PENDENTE = 'S'`, não cancelados e `QTDNEG > QTDENTREGUE`.
OC antiga continua no cálculo e recebe `OC_ANTIGA_ABERTA` quando foi negociada há mais de `OC_ANTIGA_MESES` meses.

| Situação comercial | Regra | Conta como |
|---|---|---|
| CONFIRMADA | `STATUSNOTA = 'L'` e nenhuma liberação pendente ou reprovada em TSILIB | **contratada** (premissa a aprovar) |
| APROVACAO_NAO_DETERMINADA | `STATUSNOTA = 'L'` com liberação pendente ou reprovada | não contratada |
| NAO_CONFIRMADA | `STATUSNOTA <> 'L'` | não contratada |

TSILIB é agregada por nota antes do join (o histórico não duplica itens).

| Prazo | Regra |
|---|---|
| NO_PRAZO | `DTPREVENT >= data-base` |
| ATRASADA | `DTPREVENT < data-base`: prazo incerto, fora da projeção datada |
| SEM_PREVISAO | `DTPREVENT` vazia: prazo incerto. A data "OC + lead time" é só informativa. |

## 7. Política de cobertura

```
LT                = TGFPRO.LEADTIME (> 0) ou LEADTIME_DEFAULT (30)
Cobertura alvo    = COBERTURA_ALVO_A/B/C se houver curva; senão COBERTURA_SEM_CURVA (21, categoria própria)
Segurança (SS)    = uma única política (POLITICA_SEGURANCA):
                      0 → 0
                      1 → DD × LT × SEGURANCA_PCT_LT (20%, legado não aprovado)   [padrão]
                      2 → TGFPRO.ESTMIN
D(t)              = demanda acumulada em t dias:
                      REGRA_PREVISAO_FIRME = 1 (MAIOR): max(CMP, DD × t)   [padrão]
                      REGRA_PREVISAO_FIRME = 2 (SOMA):  CMP + DD × t        (comportamento antigo)
Ponto de pedido   = D(LT) + SS
Requisito         = D(LT + cobertura alvo) + SS
```

SS entra **uma vez**: no ponto de pedido e no requisito. O detalhe do produto mostra quanto o
requisito seria sem ela. `TGFPRO.ESTMIN` só é segurança com a política 2; nas outras ela vira o
alerta informativo `ABAIXO_ESTMIN_CADASTRO`.

**Por que MAIOR?** A média histórica já contém a demanda que os pedidos firmes representam. Somar os
dois conta a mesma demanda duas vezes. A diferença entre SOMA e MAIOR é exatamente essa possível
dupla contagem, e os dois cenários aparecem lado a lado.

## 8. Necessidade

```
Posição contratada = EFP + OC confirmada (todas, inclusive atrasadas e sem previsão)
Necessidade bruta  = max(0, Requisito − Posição contratada)        (0 para consignado: regra herdada)
− já em OC não confirmada = min(OC não confirmada, bruta)
− em cotação              = min(cotação, restante)                  (NULO se não houver TOP de cotação)
= ainda não solicitada
```

A cotação nunca entra como contratada. O saldo da cotação é `QTDNEG − QTDENTREGUE`: o que virou OC sai
da cotação e entra na OC, sem desconto duplo.

**Lote e múltiplo** (só com `LOTE_MULTIPLO = 1`): `q = max(não solicitada, LOTECOMPMINIMO>0)` e depois
`CEIL(q ÷ AGRUPMIN) × AGRUPMIN`. O resultado atende os dois. Valor negativo no cadastro é ignorado e
sinalizado. O excesso do arredondamento é exibido. Por padrão nada é arredondado: a unidade desses
campos não foi comprovada.

Exemplo (teste 15): necessidade 130, lote 200, múltiplo 75 → max(130, 200) = 200 → 3 × 75 = **225**
(excesso 95).

## 9. Cobertura e falta (estimativa agregada)

`t*(S)` = dias até a oferta `S` não cobrir `D(t)`: 0 se `S < CMP`; nulo se `DD = 0` (sem demanda não
há falta); senão `(S − [CMP se SOMA]) ÷ DD`.

| Indicador | Regra |
|---|---|
| Cobertura física | `t*(EFP)` |
| Cobertura com OC confirmada | `t*(EFP + OC confirmada)`: inclui OCs atrasadas e sem previsão |
| Projeção datada | recebimentos confirmados com `DTPREVENT >= data-base`, em ordem; antes do recebimento *i*, a oferta é `EFP + Σ anteriores` |
| Falta antes do recebimento | primeiro recebimento *i* com `t*(oferta antes de i) < dias até i`. Quantidade em risco = `D(dias até i) − oferta antes de i` |
| Data estimada de falta | data-base + `t*`, só até 10 anos (evita estouro de data no Oracle) |

Isso **não é data garantida**: supõe consumo médio constante e não tem calendário de pedidos.
Entrada depois da falta não resolve a falta anterior; a sugestão é antecipar, não comprar de novo.

Exemplo (teste 10b): estoque 50, DD 10, OC confirmada de 400 prevista para 07/12 (20 dias).
`t*(50) = 5` < 20 → falta estimada em 22/11; quantidade em risco = 20 × 10 − 50 = **150**.

## 10. Prioridade (precedência de cima para baixo)

| Prioridade | Condição |
|---|---|
| P1 · Crítico | estoque físico < 0 **ou** cobertura física = 0 (compromisso maior que o estoque, ou estoque zerado com demanda) |
| P2 · Falta antes do lead time | falta estimada (projeção datada) em menos de LT dias: uma compra nova não chega a tempo |
| P3 · Atenção | posição contratada < ponto de pedido + DD × MARGEM_ATENCAO_DIAS |
| Revisar · sem giro com compromisso | sem consumo na série, com estoque e com compromisso: **não** é tratado como excesso |
| P0 · Excesso | DD > 0 e cobertura com OC confirmada > COBERTURA_MAX_DIAS |
| P0 · Sem giro | sem consumo na série e com estoque |
| OK | nenhuma das anteriores |

Estoque negativo e demanda sem cobertura são motivos separados (`ESTOQUE_NEGATIVO`,
`COMPROMISSO_MAIOR_QUE_ESTOQUE`, `SEM_COBERTURA_FISICA`). Toda linha mostra a lista completa de
motivos, de decisão e de qualidade. Rótulos em `src/calc.js` (`ROTULO_MOTIVO`).

## 11. Preço de referência e valores

- **Preço de referência** = `VLRTOT ÷ (QTDNEG × fator)` do item de OC **confirmada**, não cancelada,
  com unidade conciliada, mais recente no horizonte. TOPs de preço separado (1741) têm referência
  própria e nunca se misturam.
- Exibidos: valor por unidade padrão, data, nº da OC e TOP. Sem referência = **nulo**, nunca zero.
  Os itens sem preço são contados nos KPIs.
- **Falta atual estimada (R$)** = max(0, −Disponível) × preço. **Necessidade não solicitada (R$)** =
  não solicitada × preço. São **estimativas** a preço de última compra, não custo contábil, prejuízo
  comprovado ou valor de compra aprovado.

Exemplo (teste 16): última OC de 2 CX (CX = 12 UN) por R$ 240 → R$ 10,00/UN.

## 12. Curva ABC (opcional, `ABC_CALCULADA = 1`)

Por empresa: valor = consumo líquido da série × preço de referência de **compra** (não é faturamento).
Ordenação decrescente por valor, depois código. Classe pela participação acumulada **antes** do
item: < `ABC_LIMITE_A` (0,80) → A; < `ABC_LIMITE_B` (0,95) → B; senão C. Sem preço = sem curva.
Com `ABC_CALCULADA = 0` (padrão), todos ficam "sem curva" e usam `COBERTURA_SEM_CURVA`.

## 13. Carteira de OC

Escopo: itens negociados no período **ou** com saldo aberto.

| Situação de entrega | Regra |
|---|---|
| Atendida integralmente (registro) | `QTDENTREGUE >= QTDNEG > 0` |
| Encerrada com saldo | `PENDENTE = 'N'` com atendimento parcial (possível tolerância da customização; o saldo não é escondido) |
| Encerrada sem atendimento | `PENDENTE = 'N'` sem atendimento |
| Atendimento parcial / aberta sem atendimento | itens vivos |

| Vínculo de recebimento | Regra |
|---|---|
| Nativo (TGFVAR) | documento derivado confirmado. Usado só para a **data** |
| Inferido por OS + produto | entrada das TOPs ENTRADA_POR_OS com mesmo `AD_OS`/produto, após a data da OC. **Não comprova** |
| Inferido, compartilhado | a mesma entrada casa com mais de uma OC (contado, nunca somado) |
| Atendimento sem vínculo | `QTDENTREGUE > 0` sem documento encontrado |

A quantidade atendida é sempre `TGFITE.QTDENTREGUE`, o registro do sistema. O painel não recalcula
recebimento por OS nem aplica a tolerância de 90%.

**Atendimento integral até a previsão (aproximado, não é OTIF):** itens confirmados com `DTPREVENT` no
período e já vencida. Numerador = atendidos integralmente com último documento nativo até previsão +
`TOLERANCIA_ATRASO_DIAS`. Excluídos = atendidos sem data confiável. Encerrado com saldo conta como não
integral. A tela mostra numerador, denominador e exclusões.

**OTIF, aderência e SLA:** indisponíveis. Não há data de compromisso validada, quantidade por entrega,
regra de tolerância nem vínculo sugestão → OC.
