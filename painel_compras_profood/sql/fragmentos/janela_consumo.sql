-- Janela de consumo: MESES_MEDIA meses completos antes do mês da data-base.
-- HORIZ_INI: 12 meses antes da janela, só para saber se o produto já tinha consumo (série antiga).
-- FRAC: fração decorrida do mês corrente até ONTEM (usada só se MES_PARCIAL = 1).
janc AS (
    SELECT JA.DT_BASE, JA.M0,
           ADD_MONTHS(JA.M0, -PR.MESES_MEDIA) AS INI,
           ADD_MONTHS(JA.M0, -PR.MESES_MEDIA - 12) AS HORIZ_INI,
           EXTRACT(YEAR FROM JA.M0) * 12 + EXTRACT(MONTH FROM JA.M0) AS IDX_M0,
           PR.MESES_MEDIA AS N,
           CASE WHEN PR.MES_PARCIAL = 1
                THEN (JA.DT_BASE - JA.M0) / (ADD_MONTHS(JA.M0, 1) - JA.M0)
                ELSE 0 END AS FRAC
    FROM jan JA
    CROSS JOIN prm PR
)
