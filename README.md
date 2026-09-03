# Automação de Relatório de Vendas

Aplicação Java de linha de comando que lê uma planilha de vendas (`.xlsx`) e gera automaticamente um relatório consolidado do mês em um novo arquivo Excel, com indicadores de desempenho por categoria e por produto.

## Funcionalidades

- Leitura de planilhas `.xlsx` com cabeçalho na primeira linha
- Conversão flexível de dados:
  - Datas em `DD/MM/AAAA` ou `AAAA-MM-DD` (ou célula formatada como data)
  - Preços como número puro (`3.49`) ou texto (`R$ 1.234,56`)
- Geração de relatório com 3 abas:
  - **Resumo do Mês** — faturamento total, número de vendas, itens vendidos, ticket médio e faturamento por categoria com percentual
  - **Vendas por Produto** — quantidade, receita e participação de cada produto
  - **Top 5 Produtos** — produtos de maior receita no período
- Resumo dos principais indicadores no terminal
- Gerador de planilha de exemplo com dados fictícios (`GerarPlanilhaExemplo`)

## Tecnologias

| Tecnologia | Versão | Uso |
|---|---|---|
| Java | 11+ | Linguagem |
| Apache POI | 5.3.0 | Leitura e escrita de arquivos Excel (.xlsx) |
| Maven | 3.x | Build e gerenciamento de dependências |

## Como executar

```bash
# compila (na primeira execução baixa as dependências)
mvn -q compile

# gera uma planilha de exemplo (vendas.xlsx) com 80 registros fictícios
mvn -q exec:java -Dexec.mainClass=br.devlocal.relatorio.GerarPlanilhaExemplo

# gera o relatório a partir da planilha
mvn -q exec:java -Dexec.mainClass=br.devlocal.relatorio.RelatorioVendasApp
```

Para usar uma planilha real, salve o arquivo como `vendas.xlsx` na raiz do projeto e execute o último comando (ou passe o caminho como argumento).

## Formato de entrada

Colunas lidas por posição (linha 1 = cabeçalho):

| Coluna | Campo | Exemplo |
|---|---|---|
| A | Data | `01/09/2026` |
| B | Produto | `Cerveja Lata 350ml` |
| C | Categoria | `Bebidas` |
| D | Quantidade | `24` |
| E | Preço unitário | `3,49` |

## Saída

- `relatorio_vendas.xlsx` — relatório com as abas Resumo do Mês, Vendas por Produto e Top 5 Produtos

## Estrutura do projeto

```
src/main/java/br/devlocal/relatorio/
├── RelatorioVendasApp.java     # leitura, consolidação e geração do relatório
└── GerarPlanilhaExemplo.java   # geração da planilha de demonstração
```
