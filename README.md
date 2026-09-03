# 📊 Automação de Planilha de Vendas (Apache POI)

**O que faz:** lê a planilha de vendas do cliente (`.xlsx` que ele já usa) e gera automaticamente um **relatório fechado do mês** com 3 abas: Resumo (faturamento, nº de vendas, ticket médio, % por categoria), Vendas por Produto e Top 5 produtos.

**Quem compra isso:** distribuidoras, mercadinhos, lojas de Av. Brasil, açougues, padarias — qualquer negócio que anota vendas em Excel e perde tempo fechando o mês na calculadora.

---

## Como rodar (na sua máquina)

```bash
# 1ª vez (baixa as dependências sozinho):
mvn -q compile

# Passo 1 - gerar planilha de EXEMPLO (para demonstrar sem dados reais):
mvn -q exec:java -Dexec.mainClass=br.devlocal.relatorio.GerarPlanilhaExemplo

# Passo 2 - gerar o relatório a partir dela:
mvn -q exec:java -Dexec.mainClass=br.devlocal.relatorio.RelatorioVendasApp
```

Saída: `relatorio_vendas.xlsx` + resumo no terminal.

**Com a planilha REAL do cliente:** salve o arquivo dele como `vendas.xlsx` na pasta e rode o Passo 2.

## Formato esperado da planilha de entrada

| Data | Produto | Categoria | Quantidade | Preco Unitario (R$) |
|------|---------|-----------|------------|---------------------|
| 01/09/2026 | Cerveja Lata | Bebidas | 24 | 3,49 |

- Aceita data `DD/MM/AAAA` ou `AAAA-MM-DD`.
- Aceita preço como número puro (`3.49`) ou texto (`R$ 3,49`).
- O cabeçalho pode ter nome diferente (o código lê por posição: coluna A=data, B=produto, C=categoria, D=quantidade, E=preço).

## Como demonstrar para o cliente (roteiro de 3 minutos)

1. Abra a planilha de exemplo: *"Isto aqui é o que o senhor já faz hoje — lança as vendas no Excel, certo?"*
2. Rode o comando e mostre o terminal gerando os números.
3. Abra o `relatorio_vendas.xlsx`: *"Em 10 segundos o senhor tem o fechamento que costuma tomar uma tarde: faturamento, ticket médio, o que mais dá lucro, tudo por categoria."*
4. Feche: *"Deixo isso rodando com a SUA planilha, do jeito que o senhor já usa, sem mudar nada na sua rotina. Faço por R$ 400 e entrego em 2 dias. Topa ver funcionando com seus dados reais ainda hoje?"*

## O que falar (e o que não falar)

- ✅ "Fecha seu mês em 10 segundos" / "Sem erro de calculadora" / "Usa o Excel que o senhor já tem"
- ❌ Não fale "Apache POI", "Java", "algoritmo" — cliente compra resultado, não tecnologia.

## Cobrança sugerida

- Instalação + adaptação à planilha do cliente: **R$ 350–500** (prazo: 2 dias)
- Versão com e-mail automático do relatório todo dia 1º: **R$ 600–800**
