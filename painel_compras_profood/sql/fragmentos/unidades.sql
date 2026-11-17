-- Regras de conversão ativas, agrupadas ANTES do join (nunca multiplicam linhas).
-- Mais de uma regra distinta para o mesmo produto+unidade = AMBIGUA (não converte).
voa AS (
    SELECT V.CODPROD, V.CODVOL,
           MAX(V.DIVIDEMULTIPLICA) AS DM,
           MAX(V.QUANTIDADE) AS QC,
           COUNT(DISTINCT NVL(V.DIVIDEMULTIPLICA, '-') || '|' || NVL(CAST(V.QUANTIDADE AS VARCHAR(40)), '-')) AS N_REGRAS
    FROM TGFVOA V
    WHERE NVL(V.ATIVO, 'S') = 'S'
    GROUP BY V.CODPROD, V.CODVOL
)
