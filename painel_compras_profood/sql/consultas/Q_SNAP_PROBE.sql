-- @consulta Q_SNAP_PROBE
-- @descricao Verifica a tabela OPCIONAL de snapshots (BI_F_SUGESTAO_COMPRA). Só diagnóstico:
--            sem vínculo rastreável sugestão→OC, aderência e SLA continuam indisponíveis.
-- @params CODEMP DT_INI DT_FIM
WITH {{PRM}}
SELECT COUNT(*) AS N,
       TO_CHAR(MIN(S.DATA_SNAPSHOT), 'YYYY-MM-DD') AS PRIMEIRO,
       TO_CHAR(MAX(S.DATA_SNAPSHOT), 'YYYY-MM-DD') AS ULTIMO
FROM BI_F_SUGESTAO_COMPRA S
CROSS JOIN prm PR
WHERE S.DATA_SNAPSHOT >= PR.DT_INI
  AND S.DATA_SNAPSHOT < PR.DT_FIM + 1
  AND S.CODEMP = PR.CODEMP
