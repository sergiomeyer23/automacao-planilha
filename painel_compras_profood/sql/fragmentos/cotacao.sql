-- Necessidade em negociação. Só existe se houver TOPs no papel COTACAO (config).
-- Saldo = QTDNEG - QTDENTREGUE: ao virar OC o atendimento sai da cotação e entra na OC
-- (sem desconto duplo). Sem TOP mapeada, este bloco não retorna linhas e o painel mostra "não mapeado".
cot_it AS (
    SELECT C.CODEMP, I.CODPROD,
           NVL(I.QTDNEG, 0) - NVL(I.QTDENTREGUE, 0) AS SALDO_ORIG,
           {{FATOR I, P, VO}} AS FATOR
    FROM TGFCAB C
    JOIN tops TP ON TP.CODTIPOPER = C.CODTIPOPER
    JOIN TGFITE I ON I.NUNOTA = C.NUNOTA
    JOIN TGFPRO P ON P.CODPROD = I.CODPROD
    LEFT JOIN voa VO ON VO.CODPROD = I.CODPROD AND VO.CODVOL = I.CODVOL
    CROSS JOIN prm PR
    WHERE TP.PAPEL = 'COTACAO'
      AND {{ITEM_ABERTO I}}
      AND {{FILTRO_EMPRESA C.CODEMP}}
),
cot AS (
    SELECT X.CODEMP, X.CODPROD,
           SUM(CASE WHEN X.FATOR IS NULL THEN 0 ELSE X.SALDO_ORIG * X.FATOR END) AS QTD_COTACAO,
           SUM(CASE WHEN X.FATOR IS NULL THEN 1 ELSE 0 END) AS N_COT_NAO_CONC
    FROM cot_it X
    GROUP BY X.CODEMP, X.CODPROD
)
