-- GERADO por scripts/build.js (10db84899dd53b95). NÃO EDITAR: altere sql/consultas, sql/fragmentos ou sql/macros.sql.
-- Consulta: Q_SNAP_PROBE
-- Verifica a tabela OPCIONAL de snapshots (BI_F_SUGESTAO_COMPRA). Só diagnóstico: sem vínculo rastreável sugestão→OC, aderência e SLA continuam indisponíveis.
-- Binds na ordem dos '?': CODEMP:I, DT_INI:S, DT_FIM:S

WITH prm AS (
    SELECT CAST(TO_NUMBER(?) AS INTEGER) AS CODEMP,
           TO_DATE(?, 'YYYY-MM-DD') AS DT_INI,
           TO_DATE(?, 'YYYY-MM-DD') AS DT_FIM
    FROM DUAL
)
SELECT COUNT(*) AS N,
       TO_CHAR(MIN(S.DATA_SNAPSHOT), 'YYYY-MM-DD') AS PRIMEIRO,
       TO_CHAR(MAX(S.DATA_SNAPSHOT), 'YYYY-MM-DD') AS ULTIMO
FROM BI_F_SUGESTAO_COMPRA S
CROSS JOIN prm PR
WHERE S.DATA_SNAPSHOT >= PR.DT_INI
  AND S.DATA_SNAPSHOT < PR.DT_FIM + 1
  AND S.CODEMP = PR.CODEMP
