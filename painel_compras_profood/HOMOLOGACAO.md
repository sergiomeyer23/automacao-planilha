# Roteiro de homologação no Construtor de BI

Nada disto foi executado. É o roteiro para quem tiver acesso ao Sankhya e ao Oracle. Registre cada
passo (data, responsável, print ou export, resultado) numa planilha de evidências. O painel só pode
ser chamado de homologado depois que **todos** os critérios da seção 5 estiverem atendidos e
assinados.

## 0. Pré-requisitos

- Ambiente de **teste** (não produção) com cópia recente dos dados, se existir.
- Usuário com permissão de leitura nas tabelas de `MAPA_DE_DADOS.md`.
- Alguém de Compras/PCP para conferir números à mão e alguém com acesso SQL (DBA) para os passos 3 e 4.
- Arquivo `entrega/bi_oc_sankhya.jsp` e o `entrega/MANIFESTO.json` do mesmo build (confira o `sha256`).

## 1. Cópia de segurança e rollback do painel

1. No Construtor de BI, abra o painel atual e **exporte/baixe o arquivo** do componente HTML5 em uso.
   Guarde-o junto com `original/bi_oc_sankhya.jsp`. Se forem diferentes, registre a diferença: o original
   deste pacote é o arquivo recebido para a correção.
2. Anote a configuração do componente: parâmetros (`PERIODO` com `.INI`/`.FIN`, `CODEMP`), tipos e
   valores padrão, permissões de acesso ao painel.
3. **Rollback**: reimportar o arquivo guardado no item 1 no mesmo componente e restaurar a configuração
   do item 2. O painel não grava nada no banco, então o rollback se resume a voltar o arquivo.
4. Recomendado: importar a versão nova como **painel separado** ("v2 – teste") e manter o antigo
   intocado até o aceite.

## 2. Importação

1. Criar (ou duplicar) um dashboard com o componente **JavaScript Simples HTML5**.
2. Importar `entrega/bi_oc_sankhya.jsp` como está. Não editar o arquivo no Construtor: qualquer
   ajuste vai para as fontes e passa pelo build.
3. Configurar os parâmetros com os mesmos nomes do original: `PERIODO` (período, `PERIODO.INI` e
   `PERIODO.FIN`) e `CODEMP`.
4. **Tamanho**: o arquivo tem cerca de 275 KB (o original tinha 245 KB). Confirme que o componente
   aceita. Se houver limite, registre-o: é requisito de homologação, e o build avisa acima de 400 KB.

## 3. Verificações técnicas (na ordem)

| # | Verificação | Como | Esperado |
|---|---|---|---|
| T1 | `executeQuery` existe | abrir o painel | sem a tela "Abra pelo componente HTML5" |
| T2 | Teste básico | aba Parâmetros e qualidade → Diagnóstico | `Q_DIAG` ok, `NUMERO=123`, `DATA` = fim do período |
| T3 | Formato do retorno | mesmo lugar | formato registrado (print); nenhuma mensagem "formato não reconhecido" |
| T4 | Parâmetros do Construtor | linha de contexto | empresa e período iguais aos escolhidos; datas em formato reconhecido (sem aviso) |
| T5 | Tabela opcional | avisos | "BI_PARAM_COMPRA não encontrada" (ausente) **ou** valores com origem "tabela"; nunca "erro" sem explicação |
| T6 | Cada consulta executa | log (aba Parâmetros e qualidade) | as 8 consultas com "ok" (`Q_PARAMS`/`Q_SNAP_PROBE` podem dar ORA-00942 se as tabelas opcionais não existirem) |
| T7 | Colunas existem | log | nenhum ORA-00904. Se houver, anotar a coluna: é divergência do ambiente e exige ajuste no SQL |
| T8 | Tempo | coluna "Tempo" do log, com empresa "todas" e com uma empresa | anotar cada consulta. Acima de 60 s, levar o SQL de `sql/gerado/` ao DBA com o plano de execução |
| T9 | Mesmo SQL fora do painel | DBA executa `sql/gerado/Q_RESUMO.sql` no SQL Developer com os mesmos binds do log | mesmos totais que a Visão geral |
| T10 | Somente leitura | DBA confere no AWR/auditoria | só `SELECT` |
| T11 | Navegador | abrir no(s) navegador(es) usados pela equipe | sem erro no console (F12) |

## 4. Conferência de dados (amostra manual)

Escolher **5 produtos**: um P1, um P2/P3, um com OC atrasada, um com unidade alternativa (CX/PC) e um
produto novo. Para cada um, com o detalhe do produto aberto (clique na linha da fila):

| # | Conferir | Contra |
|---|---|---|
| D1 | Estoque físico, reservado e bloqueado | consulta de estoque do Sankhya, por local, excluindo os locais configurados |
| D2 | Pedidos pendentes | pedidos de venda em aberto do produto |
| D3 | Consumo mês a mês | relatório de vendas/saídas do produto, na unidade padrão |
| D4 | Conversão de unidade | cadastro do produto (aba de unidades alternativas): M multiplica, D divide? (A13) |
| D5 | Início da série e divisor | primeira venda do produto |
| D6 | OCs abertas, saldos, previsão e situação | central de compras / OC no Sankhya |
| D7 | Liberações | tela de liberações da OC (casos com pendência) |
| D8 | Preço de referência | última OC confirmada do produto |
| D9 | Vínculo de recebimento | notas de entrada ligadas à OC; casos "inferido por OS" |
| D10 | Lote/múltiplo | unidade de AGRUPMIN/LOTECOMPMINIMO no cadastro (A12) |

Registre cada diferença. Diferença de regra vai para `PARAMETROS_A_APROVAR.md`. Diferença de dado ou
coluna vai para ajuste no SQL.

## 5. Critérios de aceite

1. T1 a T11 sem pendência.
2. D1 a D10 conferidos nos 5 produtos, ou diferenças explicadas e aceitas por escrito.
3. Decisões A1 a A16 de `PARAMETROS_A_APROVAR.md` respondidas e parâmetros gravados na
   `BI_PARAM_COMPRA` (criada pelo DBA, não pelo painel). Sem A1 o painel pode ser usado para
   **análise**, mas não para decisão.
4. Tempo de carga aceito pelos usuários.
5. Registro assinado por Compras/PCP e TI.

Só então trocar o selo "NÃO HOMOLOGADO" (em `src/template.jsp`), atualizar a versão em
`config/painel.json`, rodar o build e os testes e reimportar.

## 6. Depois do aceite

- Toda mudança passa por: fonte (`sql/`, `src/`, `config/`) → `npm test` → build → importação →
  repetir T2, T6 e T9.
- Guardar o `MANIFESTO.json` de cada versão importada para saber qual build está em produção.
