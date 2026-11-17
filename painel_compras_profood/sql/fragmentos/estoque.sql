-- Estoque físico atual por empresa+produto. Locais excluídos vêm da configuração do build.
est AS (
    SELECT E.CODEMP, E.CODPROD,
           SUM(NVL(E.ESTOQUE, 0)) AS QTD_ESTOQUE,
           SUM(NVL(E.RESERVADO, 0)) AS QTD_RESERVADO,
           SUM(NVL(E.WMSBLOQUEADO, 0)) AS QTD_BLOQUEADO
    FROM TGFEST E
    CROSS JOIN prm PR
    WHERE {{FILTRO_EMPRESA E.CODEMP}}
      {{EXCLUI_LOCAIS E.CODLOCAL}}
    GROUP BY E.CODEMP, E.CODPROD
)
