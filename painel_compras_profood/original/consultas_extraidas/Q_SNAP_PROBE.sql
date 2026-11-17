-- Extraído do painel original (somente referência; NÃO é a fonte do painel novo)
-- Consulta: Q_SNAP_PROBE
-- Parâmetros (ordem dos ?): CODEMP, DT_INI, DT_FIM
-- Tipos: I, S, S

WITH prm AS (
    SELECT TO_NUMBER(?) AS CODEMP, TO_DATE(?, 'YYYY-MM-DD') AS DT_INI, TO_DATE(?, 'YYYY-MM-DD') AS DT_FIM FROM DUAL
)
SELECT TO_CHAR(MIN(S.DATA_SNAPSHOT), 'DD/MM/YYYY') AS PRIMEIRO,
       TO_CHAR(MAX(S.DATA_SNAPSHOT), 'DD/MM/YYYY') AS ULTIMO,
       COUNT(*)                                    AS N
FROM BI_F_SUGESTAO_COMPRA S
CROSS JOIN prm PR
WHERE S.DATA_SNAPSHOT >= PR.DT_INI AND S.DATA_SNAPSHOT < PR.DT_FIM + 1
  AND S.CODEMP = PR.CODEMP
