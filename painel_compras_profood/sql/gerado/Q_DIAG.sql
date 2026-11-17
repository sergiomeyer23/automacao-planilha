-- GERADO por scripts/build.js (10db84899dd53b95). NÃO EDITAR: altere sql/consultas, sql/fragmentos ou sql/macros.sql.
-- Consulta: Q_DIAG
-- Teste do executeQuery: um inteiro e uma data vinculados, sem tabela do ERP.
-- Binds na ordem dos '?': DIAG_NUM:I, DT_FIM:S

WITH prm AS (
    SELECT CAST(TO_NUMBER(?) AS INTEGER) AS DIAG_NUM,
           TO_DATE(?, 'YYYY-MM-DD') AS DT_FIM
    FROM DUAL
)
SELECT PR.DIAG_NUM AS NUMERO,
       TO_CHAR(PR.DT_FIM, 'DD/MM/YYYY') AS DATA,
       'TESTE' AS TEXTO
FROM prm PR
