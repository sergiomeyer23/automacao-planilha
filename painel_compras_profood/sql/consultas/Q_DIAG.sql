-- @consulta Q_DIAG
-- @descricao Teste do executeQuery: um inteiro e uma data vinculados, sem tabela do ERP.
-- @params DIAG_NUM DT_FIM
WITH {{PRM}}
SELECT PR.DIAG_NUM AS NUMERO,
       TO_CHAR(PR.DT_FIM, 'DD/MM/YYYY') AS DATA,
       'TESTE' AS TEXTO
FROM prm PR
