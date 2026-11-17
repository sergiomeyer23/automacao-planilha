-- Data-base do cálculo: data do BANCO (SYSDATE), nunca do navegador.
-- A posição de estoque (TGFEST) é sempre a atual; por isso a data-base é hoje.
jan AS (
    SELECT TRUNC(SYSDATE) AS DT_BASE,
           TRUNC(SYSDATE, 'MM') AS M0,
           TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI') AS SNAPSHOT
    FROM DUAL
)
