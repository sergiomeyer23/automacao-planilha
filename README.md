# Automação de Relatório de Vendas

[![CI](https://github.com/sergiomeyer23/automacao-planilha/actions/workflows/ci.yml/badge.svg)](https://github.com/sergiomeyer23/automacao-planilha/actions/workflows/ci.yml)

Aplicação Java de linha de comando que lê uma planilha de vendas (`.xlsx`) e gera um relatório consolidado **por mês** em um novo arquivo Excel, com indicadores de desempenho por categoria e por produto.

O projeto foi pensado para o fluxo real de pequenos negócios: a planilha de entrada costuma vir com datas em formatos diferentes, preços como texto (`R$ 1.234,56`) e linhas incompletas. Em vez de quebrar ou gravar valores errados, a aplicação valida cada linha, ignora o que não é utilizável e informa o que foi descartado.

## Funcionalidades

- Leitura de planilhas `.xlsx` (e `.xls`) com cabeçalho na primeira linha.
- **Filtro por mês**: informe `AAAA-MM` ou `MM/AAAA`; se omitido, o relatório usa o mês mais recente encontrado na planilha.
- Conversão flexível de dados:
  - Datas como célula formatada como data, `AAAA-MM-DD`, `DD/MM/AAAA` ou `DD-MM-AAAA`.
  - Preços como número puro (`3.49`), formato brasileiro (`R$ 1.234,56`) ou americano (`1,234.56`).
- Validação por linha:
  - data e produto são obrigatórios;
  - quantidade deve ser um inteiro maior que zero;
  - preço deve ser maior ou igual a zero;
  - categoria vazia vira `Sem categoria`.
- Linhas inválidas são ignoradas e reportadas no terminal e na aba de resumo, sem interromper o processamento.
- Geração de relatório com 3 abas:
  - **Resumo do Mês** — período, faturamento total, número de vendas, itens vendidos, ticket médio, linhas ignoradas e faturamento por categoria com percentual;
  - **Vendas por Produto** — quantidade, receita e participação de cada produto, ordenados por receita, com linha de total;
  - **Top 5 Produtos** — produtos de maior receita no período.
- Saída configurável, criação automática de diretórios e proteção para não sobrescrever o arquivo de entrada.
- Proteção contra divisão por zero quando o faturamento do período é zero.
- Testes automatizados com JUnit 5 e integração contínua no GitHub Actions.
- Gerador de planilha de exemplo com 80 vendas fictícias do mês atual.

## Tecnologias

| Tecnologia | Versão | Uso |
|---|---|---|
| Java | 11+ | Linguagem |
| Apache POI | 5.3.0 | Leitura e escrita de arquivos Excel |
| Maven | 3.8+ | Build e gerenciamento de dependências |
| JUnit 5 | 5.10.2 | Testes automatizados |
| GitHub Actions | — | CI (build + testes) |

## Como executar

Pré-requisitos: Java 11 ou superior e Maven 3.8 ou superior.

```bash
# roda os testes
mvn test

# gera uma planilha de exemplo (vendas.xlsx) com 80 registros fictícios
mvn -q compile exec:java -Dexec.mainClass=br.devlocal.relatorio.GerarPlanilhaExemplo

# gera o relatório do mês mais recente da planilha
mvn -q compile exec:java -Dexec.mainClass=br.devlocal.relatorio.RelatorioVendasApp

# escolhe entrada, saída e mês
mvn -q compile exec:java -Dexec.mainClass=br.devlocal.relatorio.RelatorioVendasApp -Dexec.args="vendas.xlsx relatorio_outubro.xlsx 2026-10"
```

No PowerShell, coloque o argumento entre aspas:

```powershell
mvn -q compile exec:java "-Dexec.mainClass=br.devlocal.relatorio.RelatorioVendasApp" "-Dexec.args=vendas.xlsx relatorio_outubro.xlsx 2026-10"
```

### Linha de comando

```text
Uso: RelatorioVendasApp [entrada.xlsx] [saida.xlsx] [AAAA-MM]

Opções:
  --entrada=ARQUIVO  Planilha de vendas (padrão: vendas.xlsx)
  --saida=ARQUIVO    Relatório gerado (padrão: relatorio_vendas.xlsx)
  --mes=AAAA-MM      Mês de referência (padrão: mês mais recente da planilha)
  -h, --ajuda        Exibe a ajuda
```

Também é possível usar apenas opções nomeadas:

```bash
mvn -q compile exec:java -Dexec.mainClass=br.devlocal.relatorio.RelatorioVendasApp \
  -Dexec.args="--entrada=dados/vendas.xlsx --saida=relatorios/2026-10.xlsx --mes=2026-10"
```

## Formato de entrada

A aplicação lê a **primeira aba** e espera o cabeçalho na **primeira linha**. As colunas são lidas por posição:

| Coluna | Campo | Exemplo | Obrigatório |
|---|---|---|---|
| A | Data | `01/10/2026` | Sim |
| B | Produto | `Cerveja Lata 350ml` | Sim |
| C | Categoria | `Bebidas` | Não |
| D | Quantidade | `24` | Sim |
| E | Preço unitário | `3,49` | Sim |

## Regras de validação

| Campo | Regra | Quando inválido |
|---|---|---|
| Data | Aceita célula de data, `AAAA-MM-DD`, `DD/MM/AAAA` ou `DD-MM-AAAA` | Linha ignorada com aviso |
| Produto | Texto não vazio | Linha ignorada com aviso |
| Categoria | Texto opcional | Assume `Sem categoria` |
| Quantidade | Inteiro maior que zero | Linha ignorada com aviso |
| Preço | Número maior ou igual a zero | Linha ignorada com aviso |
| Linha vazia | Todas as colunas A–E vazias | Ignorada sem aviso |

## Saída

O arquivo gerado contém:

- **Resumo do Mês** — título com o mês de referência, período, arquivo de origem, faturamento total, número de vendas, itens vendidos, ticket médio, linhas ignoradas e receita por categoria com percentual.
- **Vendas por Produto** — produtos ordenados por receita, com quantidade, receita, participação e linha de total.
- **Top 5 Produtos** — os cinco produtos de maior receita.

No terminal, a aplicação imprime o caminho do arquivo gerado e os principais indicadores. Avisos de linhas inválidas são enviados para `stderr`.

## Estrutura do projeto

```text
src/main/java/br/devlocal/relatorio/
├── RelatorioVendasApp.java     # CLI, leitura, validação, consolidação e geração do Excel
└── GerarPlanilhaExemplo.java   # geração da planilha de demonstração

src/main/resources/
└── log4j2.xml                  # configuração de logging do Apache POI

src/test/java/br/devlocal/relatorio/
└── RelatorioVendasAppTest.java # testes de parsing, validação e geração do relatório
```

## Limitações

- Lê apenas a primeira aba da planilha.
- Assume as colunas na ordem A–E; não faz mapeamento por nome de cabeçalho.
- Fórmulas são lidas pelo valor em cache; fórmulas complexas ou não calculadas podem não refletir o resultado esperado.
- Planilhas protegidas por senha não são suportadas.
- O arquivo é processado em memória (Apache POI); planilhas muito grandes podem exigir mais heap.
- O filtro seleciona um mês por vez; não há consolidação multi-mês.

## Dados de exemplo

Os dados gerados por `GerarPlanilhaExemplo` são fictícios e servem apenas para demonstração. Nenhuma informação real de cliente é incluída no repositório.

## Licença

MIT — consulte [LICENSE](LICENSE).
