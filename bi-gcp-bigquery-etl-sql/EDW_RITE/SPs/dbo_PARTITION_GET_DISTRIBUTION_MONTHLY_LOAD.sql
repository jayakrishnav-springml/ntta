CREATE PROC [DBO].[PARTITION_GET_DISTRIBUTION_MONTHLY_LOAD] @TABLE_NAME [VARCHAR](100),@DISTRIBUTION [VARCHAR](100) OUT AS 

SELECT TOP 1 @DISTRIBUTION = DISTRIB 
FROM (
		SELECT 'FACT_LANE_VIOLATIONS_DETAIL'				AS TABLE_NAME, 'HASH(LANE_VIOL_ID)' AS DISTRIB
		UNION SELECT 'FACT_VIOLATIONS_DETAIL'				AS TABLE_NAME, 'HASH(VIOLATION_ID)' AS DISTRIB
		UNION SELECT 'FACT_VIOLATIONS_BR_DETAIL'			AS TABLE_NAME, 'HASH(VIOLATION_ID)' AS DISTRIB
		UNION SELECT 'FACT_VIOLATIONS_DMV_STATUS_DETAIL'	AS TABLE_NAME, 'HASH(VIOLATION_ID)' AS DISTRIB
		UNION SELECT 'FACT_IOP_TGS'							AS TABLE_NAME, 'HASH(SOURCE_TXN_ID)' AS DISTRIB
		UNION SELECT 'FACT_NET_REV_TFC_EVTS'				AS TABLE_NAME, 'HASH(TART_ID)' AS DISTRIB
		UNION SELECT 'FACT_TOLL_TRANSACTIONS'				AS TABLE_NAME, 'HASH(TTXN_ID)' AS DISTRIB
		UNION SELECT 'FACT_VTOLLS_DETAIL'					AS TABLE_NAME, 'HASH(TRANSACTION_ID)' AS DISTRIB
		UNION SELECT 'FACT_UNIFIED_VIOLATION_SNAPSHOT'		AS TABLE_NAME, 'HASH(TART_ID)' AS DISTRIB
		UNION SELECT 'FACT_UNIFIED_VIOLATION_HISTORY'		AS TABLE_NAME, 'HASH(TART_ID)' AS DISTRIB
		) A 
WHERE TABLE_NAME = @TABLE_NAME

IF ISNULL(@DISTRIBUTION, '') = '' SET @DISTRIBUTION = 'HASH(DAY_ID)'




