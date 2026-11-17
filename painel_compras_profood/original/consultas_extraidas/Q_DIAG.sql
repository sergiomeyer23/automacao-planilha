-- Extraído do painel original (somente referência; NÃO é a fonte do painel novo)
-- Consulta: Q_DIAG
-- Parâmetros (ordem dos ?): DIAG_NUM, DT_FIM
-- Tipos: I, S

SELECT TO_NUMBER(?) AS NUMERO, TO_CHAR(TO_DATE(?, 'YYYY-MM-DD'), 'DD/MM/YYYY') AS DATA, 'TESTE' AS TEXTO FROM DUAL
