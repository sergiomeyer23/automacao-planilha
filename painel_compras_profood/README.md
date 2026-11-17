# Painel "Acompanhamento de Abertura de OC" — versão corrigida

Painel de compras para o componente **JavaScript Simples HTML5** do Construtor de BI do Sankhya.
É somente leitura e executa apenas `SELECT` via `executeQuery(sql, params, sucesso, erro)`.

> **Situação: NÃO HOMOLOGADO e NÃO APROVADO para decisão de compra.**
> O painel nunca foi executado em Oracle nem dentro do Sankhya (ver `RESULTADO_TESTES.md`).
> Política PRG/JIT, mapeamentos de TOP e parâmetros de cobertura ainda não foram aprovados
> (ver `PARAMETROS_A_APROVAR.md`). A fila é **análise**, não autorização de compra.

## O que mudou em uma frase

As 13 consultas copiadas e coladas (166 KB numa linha) viraram **8 consultas montadas a partir de
fragmentos e macros SQL compartilhados**, com um build determinístico. O cálculo foi corrigido nos pontos
apontados: segurança sem efeito, curva vazia, perdas inexistentes, mês parcial, divisor global, dupla
contagem de previsão + pedido, OC não aprovada contada como contratada, OTIF sem base e unidades
misturadas. Ele também passou a ser testado contra um motor de referência independente. Detalhes no
`CHANGELOG.md`.

## Estrutura

```
original/        painel original preservado + consultas extraídas (só referência)
entrega/         bi_oc_sankhya.jsp (o arquivo a importar) + MANIFESTO.json (hashes, tamanhos)
src/             template.jsp, styles.css, calc.js (funções puras), motor.js (motor de referência),
                 demo.js (dados simulados), app.js (interface)
sql/macros.sql   expressões compartilhadas (conversão de unidade, situação da OC, demanda, falta...)
sql/fragmentos/  blocos (CTEs) compartilhados: consumo, estoque, compromissos, OC, preço, plano...
sql/consultas/   as 8 consultas (cabeçalho @params + fragmentos + SELECT final)
sql/gerado/      consultas expandidas e formatadas (geradas pelo build; para revisão/DBA)
config/          painel.json (TOPs, locais, limites) e parametros.json (parâmetros e faixas)
scripts/         build.js, extrair_original.js
tests/           testes (Node), fixtures, simulação SQL (Python/DuckDB), e2e (Playwright)
```

Nunca edite `entrega/` nem `sql/gerado/` à mão: altere `src/`, `sql/` ou `config/` e rode o build.

## Build

Requer Node.js 18 ou superior. Não há dependências nem acesso à rede.

```bash
node scripts/build.js
```

O build expande macros e fragmentos e gera o bloco de parâmetros (`prm`) a partir de
`config/parametros.json`. Depois valida cada consulta e monta o JSP final. As validações são:

- somente `WITH`/`SELECT`; sem `;`, DML/DDL, `FETCH FIRST`, `ROWNUM`, `CONNECT BY`, `KEEP` ou database link;
- número de `?` igual ao de parâmetros declarados; nenhum `?` dentro de literal;
- identificadores com no máximo 30 caracteres (limite do Oracle anterior ao 12.2);
- sem alias de tabela com `AS` (inválido no Oracle);
- JavaScript em ES5;
- nenhum `${`, `#{` ou `<%` além das 3 expressões EL do Construtor (`PERIODO.INI`, `PERIODO.FIN`, `CODEMP`).

O artefato não tem data embutida: o identificador do build é um hash das fontes. Rodar duas vezes
gera o mesmo arquivo, byte a byte.

## Testes

```bash
npm test                      # build + todos os testes
```

| Nível | Requisito | O que prova |
|---|---|---|
| Unitário JS (`calc.test.js`) | Node | regras puras, CSV, escape, parâmetros, sequência de respostas |
| Build/contrato (`build.test.js`) | Node (+ Python/sqlglot opcional) | somente leitura, binds, JSP, determinismo, campos da tela × consultas, sintaxe e colunas no dialeto Oracle |
| Cenários (`cenarios.test.js`) | Node (+ Python/DuckDB para a parte SQL) | 20 cenários com valores calculados à mão, no motor JS **e** no SQL gerado (mapa dos 24 testes obrigatórios em `RESULTADO_TESTES.md`) |
| Paridade (`paridade.test.js`) | Python/DuckDB | SQL gerado × motor JS em 287 execuções |
| E2E (`e2e.test.js`) | Python/DuckDB + Playwright | a página final no Chromium com `executeQuery` simulado |

Para a parte SQL: `pip install -r tests/requirements.txt`. Se o Python não estiver no `PATH`, aponte
`PAINEL_PYTHON=/caminho/do/python`. Sem DuckDB ou Playwright, esses testes são **pulados com aviso**
e nunca aparecem como aprovados. Nenhum teste executa Oracle ou Sankhya.

## Modo demonstração

Abrindo o arquivo com `?modo=demo` na URL, o painel gera dados **simulados** no navegador e os processa
pelo motor de referência, sem chamar o `executeQuery`. Nesse modo aparecem:

- selo "MODO DEMONSTRAÇÃO · DADOS SIMULADOS";
- título prefixado com "[DEMONSTRAÇÃO]";
- aviso fixo no topo;
- prefixo `DEMO_` nos arquivos CSV.

Com `&opcionais=1`, as tabelas opcionais também são simuladas. No modo real, se `executeQuery` não
existir, a página **bloqueia** e não cai no modo demonstração.

## Uso (abas)

1. **Visão geral**: totais de todos os itens (sem limite de linhas), prioridades, os 15 primeiros da
   fila e o resumo de qualidade dos dados.
2. **Fila de análise**: universo filtrado no banco (atenção / revisar / excesso / todos), filtros de
   tela, ordenação, detalhe completo do cálculo por produto e exportação CSV das linhas visíveis.
3. **Carteira de OC**: saldo confirmado e não confirmado, previsão vencida, atendimento aproximado,
   OTIF (indisponível), funil, idade da carteira, qualidade do vínculo, OCs que não cobrem a
   necessidade e lista de itens abertos com detalhe.
4. **Consumo e média**: matriz mensal, série e divisor por produto, médias, desvio e CSV longo.
5. **Parâmetros e qualidade**: painel de qualidade, parâmetros em uso e sua origem, mapeamentos,
   diagnóstico do `executeQuery` e log das consultas.

Os filtros do topo valem para todas as abas. **Empresa** filtra o cálculo inteiro. **Fluxo de OC**
filtra só os indicadores de fluxo (funil, atendimento). A fila e o estoque usam sempre a data do
banco, porque a posição de estoque (TGFEST) não tem histórico. **Atualizar dados** descarta o cache.

## Limitações que impedem uso decisório

Resumo (lista completa em `PARAMETROS_A_APROVAR.md` e `HOMOLOGACAO.md`):

- nada foi executado em Oracle ou Sankhya;
- não existe classificador PRG/JIT validado;
- TOPs, locais e regras herdadas do painel antigo não foram validados;
- "OC confirmada = contratada" é premissa;
- não há fonte de cotação, nem de envio ao fornecedor ou de produção (eCalc);
- aderência, SLA e OTIF estão indisponíveis por falta de vínculo rastreável;
- a unidade do lote mínimo e do múltiplo não foi comprovada (por isso não são aplicados por padrão).
