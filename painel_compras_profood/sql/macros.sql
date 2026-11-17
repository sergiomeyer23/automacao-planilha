-- =====================================================================
-- Macros SQL do painel. Uso nas consultas: {{NOME arg1, arg2, ...}}
-- Cada $PARAM do corpo é trocado pelo argumento na mesma posição.
-- Regra de portabilidade (Oracle 11g+): sem FETCH FIRST, sem ROWNUM,
-- sem CONNECT BY, sem KEEP, GREATEST/LEAST só com argumentos não nulos.
-- =====================================================================

--#macro FATOR($I, $P, $VO)
-- Fator para converter a quantidade do item para a unidade padrão do produto.
-- NULL = unidade não conciliada (sem regra, regra ambígua ou inválida).
(CASE WHEN $I.CODVOL = $P.CODVOL THEN 1
      WHEN $VO.N_REGRAS = 1 AND $VO.DM = 'M' AND $VO.QC > 0 THEN $VO.QC
      WHEN $VO.N_REGRAS = 1 AND $VO.DM = 'D' AND $VO.QC > 0 THEN 1 / $VO.QC
 END)
--#fim

--#macro STATUS_CONV($I, $P, $VO)
(CASE WHEN $I.CODVOL IS NULL THEN 'SEM_UNIDADE'
      WHEN $I.CODVOL = $P.CODVOL THEN 'PADRAO'
      WHEN $VO.CODPROD IS NULL THEN 'SEM_REGRA'
      WHEN $VO.N_REGRAS > 1 THEN 'AMBIGUA'
      WHEN $VO.DM = 'M' AND $VO.QC > 0 THEN 'MULTIPLICA'
      WHEN $VO.DM = 'D' AND $VO.QC > 0 THEN 'DIVIDE'
      ELSE 'REGRA_INVALIDA'
 END)
--#fim

--#macro ITEM_ABERTO($I)
-- Item com saldo vivo: pendente, não cancelado e negociado > atendido.
(NVL($I.PENDENTE, 'S') = 'S' AND NVL($I.CANCELADO, 'N') <> 'S' AND NVL($I.QTDNEG, 0) > NVL($I.QTDENTREGUE, 0))
--#fim

--#macro FILTRO_EMPRESA($COL)
(PR.CODEMP = 0 OR $COL = PR.CODEMP)
--#fim

--#macro SITUACAO_OC($STATUS, $NPEND, $NREPROV)
-- Situação comercial. CONFIRMADA = STATUSNOTA 'L' sem liberação pendente/reprovada
-- (premissa a aprovar: confirmada = contratada). Liberação ambígua NÃO vira aprovação.
(CASE WHEN $STATUS = 'L' AND $NPEND = 0 AND $NREPROV = 0 THEN 'CONFIRMADA'
      WHEN $STATUS = 'L' THEN 'APROVACAO_NAO_DETERMINADA'
      ELSE 'NAO_CONFIRMADA'
 END)
--#fim

--#macro PRAZO_OC($DTPREV, $DTBASE)
-- Só DTPREVENT informada conta como previsão. Data estimada (OC + lead time) é apenas informativa.
(CASE WHEN $DTPREV IS NULL THEN 'SEM_PREVISAO'
      WHEN $DTPREV < $DTBASE THEN 'ATRASADA'
      ELSE 'NO_PRAZO'
 END)
--#fim

--#macro STATUS_ITEM_OC($CANC, $PEND, $QN, $QE)
(CASE WHEN $CANC = 'S' THEN 'CANCELADA'
      WHEN $QN > 0 AND $QE >= $QN THEN 'ATENDIDA_INTEGRAL'
      WHEN $PEND = 'N' AND $QE > 0 THEN 'ENCERRADA_COM_SALDO'
      WHEN $PEND = 'N' THEN 'ENCERRADA_SEM_ATENDIMENTO'
      WHEN $QE > 0 THEN 'ATENDIMENTO_PARCIAL'
      ELSE 'ABERTA_SEM_ATENDIMENTO'
 END)
--#fim

--#macro LIB_PEND($L)
SUM(CASE WHEN $L.DHLIB IS NULL AND NVL($L.REPROVADO, 'N') <> 'S' THEN 1 ELSE 0 END)
--#fim

--#macro LIB_REPROV($L)
SUM(CASE WHEN NVL($L.REPROVADO, 'N') = 'S' THEN 1 ELSE 0 END)
--#fim

--#macro D_DEMANDA($CMP, $DD, $T, $REGRA)
-- Demanda acumulada até t dias. Regra 2 (SOMA, antiga) soma compromissos e previsão;
-- regra 1 (MAIOR) assume que a previsão já contém os compromissos.
(CASE WHEN $REGRA = 2 THEN $CMP + $DD * $T ELSE GREATEST($CMP, $DD * $T) END)
--#fim

--#macro T_FALTA($S, $CMP, $DD, $REGRA)
-- Dias até a oferta $S não cobrir a demanda acumulada. 0 = já falta. NULL = sem demanda (nunca falta).
(CASE WHEN $S < $CMP THEN 0
      WHEN $DD <= 0 THEN NULL
      ELSE ($S - CASE WHEN $REGRA = 2 THEN $CMP ELSE 0 END) / $DD
 END)
--#fim

--#macro ORDEM_PRIORIDADE($P)
(CASE $P WHEN 'P1_CRITICO' THEN 1 WHEN 'P2_RUPTURA_IMINENTE' THEN 2 WHEN 'P3_ATENCAO' THEN 3
         WHEN 'REVISAR_SEM_GIRO' THEN 4 WHEN 'P0_EXCESSO' THEN 5 WHEN 'P0_SEM_GIRO' THEN 6 ELSE 7 END)
--#fim
