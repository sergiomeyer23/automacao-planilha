# Resultado dos testes

Execução: 17/11/2026, `npm test` (build + 5 arquivos), Node 22, Python 3.13, DuckDB 2.0, sqlglot 30,
Chromium via Playwright. Saída completa em `tests/resultado_ultima_execucao.txt`.

**54 testes, 54 aprovados, 0 falhas, 0 pulados.**

| Arquivo | Testes | Resultado |
|---|---|---|
| tests/calc.test.js | 15 | 15 ok |
| tests/build.test.js | 8 | 8 ok |
| tests/cenarios.test.js | 21 | 21 ok (cada cenário no motor JS **e** no SQL gerado) |
| tests/paridade.test.js | 1 | ok: 287 execuções, 63.501 linhas, 0 divergências |
| tests/e2e.test.js | 9 (1 + 8 subtestes) | 9 ok |

Para confirmar que a parte SQL é exercitada, um valor esperado foi adulterado de propósito
(570 → 571) e o teste correspondente reprovou.

## O que cada nível prova (e o que não prova)

| Nível | Executado? | Como | Limite |
|---|---|---|---|
| Teste matemático/JavaScript | **sim** | `calc.test.js` e o motor JS nos cenários | Prova as regras implementadas, não que elas sejam as regras certas para o negócio |
| Validação estática SQL | **sim** | validador do build (somente leitura, binds, portabilidade, identificadores) + sqlglot no dialeto Oracle: sintaxe e **qualificação de colunas** contra o esquema demonstrado (detecta coluna inexistente, alias do mesmo SELECT e GROUP BY por alias) | Não prova que o Oracle aceita; o esquema usado é o demonstrado no original, não o real |
| Simulação com fixtures | **sim** | o SQL **gerado** roda no DuckDB com um *shim* de funções Oracle (NVL, TRUNC, ADD_MONTHS, TO_CHAR, TO_DATE, SYSDATE fixo) e é comparado ao motor JS | DuckDB não é Oracle (diferenças abaixo) |
| Integração da página | **sim, simulada** | Chromium carrega o **artefato final**; o servidor de teste remove as diretivas JSP, resolve as 3 EL e expõe um `executeQuery(sql, params, ok, erro)` que responde no envelope citado no original (`{c:{b:"[...]"}}`) | Não é o Construtor de BI; o contrato real do `executeQuery` não foi observado |
| Execução real Oracle | **não** | — | sem acesso |
| Homologação no Sankhya | **não** | — | sem acesso; roteiro em `HOMOLOGACAO.md` |

## Os 24 testes obrigatórios

| # | Tema | Onde | Nível |
|---|---|---|---|
| 1 | Consumo e devolução | cenarios 1 (com status, cancelado, 23h30 do último dia, dia da base, futuro) | JS + SQL simulado |
| 2 | Mês atual parcial | cenarios 2 | JS + SQL simulado |
| 3 | Produto novo / histórico insuficiente | cenarios 3 | JS + SQL simulado |
| 4 | Meses sem movimento em produto antigo | cenarios 4 | JS + SQL simulado |
| 5 | Demanda zero | cenarios 5; calc 5 | JS + SQL simulado |
| 6 | Estoque negativo | cenarios 6 | JS + SQL simulado |
| 7 | Reserva/compromisso sem dupla subtração | cenarios 7 | JS + SQL simulado |
| 8 | Previsão e pedido firme sem dupla contagem | cenarios 8; calc 5 | JS + SQL simulado |
| 9 | OC aprovada × não aprovada | cenarios 9 (STATUSNOTA e TSILIB pendente) | JS + SQL simulado |
| 10 | OC atrasada / sem previsão; falta antes do recebimento | cenarios 10 | JS + SQL simulado |
| 11 | OC antiga ainda aberta | cenarios 11 (OC de 2023, fora do antigo corte de 24 meses) | JS + SQL simulado |
| 12 | Cotação migrando para OC sem duplo desconto | cenarios 12 (TOP 1500 mapeada **só no teste**) | JS + SQL simulado |
| 13 | Conversão por multiplicação e divisão | calc 13; cenarios 13 | JS + SQL simulado |
| 14 | Conversão inexistente, ambígua ou inativa | calc 14; cenarios 14 | JS + SQL simulado |
| 15 | Múltiplo e lote mínimo atendidos juntos | calc 15; cenarios 15 | JS + SQL simulado |
| 16 | Custo ausente e unidade de preço incompatível | cenarios 16 (+ TOP 1741 separada) | JS + SQL simulado |
| 17 | Recebimento repetido por OS + produto | cenarios 17 | JS + SQL simulado |
| 18 | Pedido misto PRG/JIT e política indefinida | calc 18; cenarios 18 (e ausência dos campos não validados no SQL) | JS + estático |
| 19 | Ausência das tabelas opcionais | cenarios 19; calc 19; e2e "parâmetros e qualidade" | JS + SQL simulado + página |
| 20 | Respostas assíncronas fora de ordem | calc 20/20b; e2e (5 trocas rápidas de filtro com atraso aleatório no servidor) | JS + página |
| 21 | Limite / paginação / exportação | cenarios 21; e2e "exportação CSV" | JS + SQL simulado + página |
| 22 | Textos maliciosos em HTML e CSV | calc 22/22b; e2e (`<img onerror>`, `<script>`, `=HYPERLINK`) | JS + página |
| 23 | Parâmetros inválidos | calc 23; e2e demonstração (chave legada e valor inválido) | JS + página |
| 24 | Paridade das métricas entre consultas e interface | paridade.test.js; build "contrato interface × consultas"; e2e (KPI = cálculo de referência) | SQL simulado + página |

## Diferenças conhecidas entre a simulação (DuckDB) e o Oracle

| Tema | Situação |
|---|---|
| DOUBLE × NUMBER | O DuckDB calcula em ponto flutuante; o Oracle, em decimal. Na paridade houve **9 diferenças de 1 centavo** na última casa (sempre o mesmo item: `VLR_NEC_NAO_SOLIC` 2.039,92 × 2.039,93, valor exatamente na metade). A comparação aceita no máximo 1 unidade na última casa e lista cada ocorrência |
| `GREATEST`/`LEAST` com NULL | Oracle devolve NULL; DuckDB ignora o NULL. O SQL só passa argumentos não nulos (com NVL), mas isso não foi verificado no Oracle |
| `''` = NULL no Oracle | `MOTIVOS` vazio vira NULL no Oracle e `''` no DuckDB; o teste normaliza. `NULLIF(TRIM(...), '')` cobre os dois casos |
| `ADD_MONTHS` no último dia do mês | O Oracle leva ao último dia do mês destino; o shim não. O motor JS segue o Oracle. Os testes usam data-base 17/11 |
| Alias do mesmo SELECT e GROUP BY por alias | DuckDB aceita, Oracle recusa. Coberto pela qualificação do sqlglot (validação estática) |
| Ordenação de texto | Com `NLS_SORT` linguístico, a ordem de chaves de texto pode mudar. A tela não depende da ordem dos blocos da carteira |
| Binds | O shim substitui `?` por literais; o `executeQuery` real envia parâmetros tipados (I/S) |
| Plano de execução e volume | Não simulados |

## O que NÃO foi testado

- Execução de qualquer consulta no **Oracle** (versão, otimizador, permissões, tempo, volume real).
- O painel dentro do **Construtor de BI**: compilação do JSP, taglibs, `<snk:load/>`, passagem dos
  parâmetros `PERIODO`/`CODEMP`, formato real do retorno do `executeQuery`, limite de tamanho do
  componente.
- Existência e significado das colunas no ambiente real, inclusive as customizadas `AD_OSTUICIAL` e
  `AD_OS`.
- Os mapeamentos de TOP, os locais excluídos e as regras herdadas, contra dados reais.
- Navegadores além do Chromium; comportamento de download dentro do iframe do Sankhya (há o botão
  "Ver CSV (copiar)" como alternativa).
- Desempenho: nenhum ganho é afirmado. Não houve benchmark.
- Dados reais: todas as fixtures são sintéticas (produtos "DEMO" e "PRODUTO n").

## Como reproduzir

```bash
pip install -r tests/requirements.txt          # DuckDB e sqlglot (só para testes)
npm test
```

Playwright precisa do Chromium. Sem Python/DuckDB ou Playwright, os testes de SQL e e2e aparecem como
**pulados** com o motivo, nunca como aprovados.
