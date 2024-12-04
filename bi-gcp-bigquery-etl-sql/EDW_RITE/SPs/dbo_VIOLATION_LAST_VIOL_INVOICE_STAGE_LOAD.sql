CREATE PROC [DBO].[VIOLATION_LAST_VIOL_INVOICE_STAGE_LOAD] AS 

select 'foo'

--IF OBJECT_ID('dbo.VIOLATION_LAST_VIOL_INVOICE_MAX_STAGE')>0
--	DROP TABLE dbo.VIOLATION_LAST_VIOL_INVOICE_MAX_STAGE

--CREATE TABLE dbo.VIOLATION_LAST_VIOL_INVOICE_MAX_STAGE WITH (DISTRIBUTION = HASH(VIOLATOR_ID), CLUSTERED INDEX (VIOLATOR_ID, VIOLATION_ID)) 
--AS 
---- EXPLAIN
--	SELECT VIV.VIOLATOR_ID, VIV.VIOLATION_ID, MAX(VI.INVOICE_DATE) AS LAST_VIOL_INVOICE_DATE
--	FROM DBO.VIOLATIONS_STAGE V
--	INNER JOIN DBO.VIOL_INVOICE_VIOL VIV ON V.VIOLATOR_ID = VIV.VIOLATOR_ID AND V.VIOLATION_ID = VIV.VIOLATION_ID
--	INNER JOIN DBO.VIOL_INVOICES VI ON VIV.VIOLATOR_ID = VI.VIOLATOR_ID AND VIV.VIOL_INVOICE_ID= VI.VIOL_INVOICE_ID
--	--WHERE V.VIOLATOR_ID=742195198 AND V.VIOLATION_ID=156647508
--	GROUP BY VIV.VIOLATOR_ID, VIV.VIOLATION_ID

--CREATE STATISTICS STATS_VIOLATION_LAST_VIOL_INVOICE_MAX_STAGE_001 ON VIOLATION_LAST_VIOL_INVOICE_MAX_STAGE(VIOLATOR_ID, VIOLATION_ID)

--IF OBJECT_ID('dbo.VIOLATION_LAST_VIOL_INVOICE_MAX_INVOICE_ID_STAGE')>0
--	DROP TABLE dbo.VIOLATION_LAST_VIOL_INVOICE_MAX_INVOICE_ID_STAGE

--CREATE TABLE dbo.VIOLATION_LAST_VIOL_INVOICE_MAX_INVOICE_ID_STAGE WITH (DISTRIBUTION = HASH(VIOLATOR_ID), CLUSTERED INDEX (VIOLATOR_ID, VIOLATION_ID)) 
--AS 
---- EXPLAIN
--	SELECT V.VIOLATOR_ID, V.VIOLATION_ID, V.LAST_VIOL_INVOICE_DATE, MAX(VI.VIOL_INVOICE_ID) AS VIOL_INVOICE_ID
--	FROM DBO.VIOLATION_LAST_VIOL_INVOICE_MAX_STAGE V
--	INNER JOIN DBO.VIOL_INVOICES VI ON V.VIOLATOR_ID = VI.VIOLATOR_ID AND V.LAST_VIOL_INVOICE_DATE= VI.INVOICE_DATE
--	INNER JOIN DBO.VIOL_INVOICE_VIOL VIV ON VI.VIOLATOR_ID = VIV.VIOLATOR_ID AND V.VIOLATION_ID = VIV.VIOLATION_ID
--	--WHERE V.VIOLATOR_ID=742195198 AND V.VIOLATION_ID=156647508
--	GROUP BY V.VIOLATOR_ID, V.VIOLATION_ID, V.LAST_VIOL_INVOICE_DATE
		
--CREATE STATISTICS STATS_VIOLATION_LAST_VIOL_INVOICE_MAX_INVOICE_ID_STAGE_001 ON VIOLATION_LAST_VIOL_INVOICE_MAX_INVOICE_ID_STAGE(VIOLATOR_ID, VIOLATION_ID)


--IF OBJECT_ID('dbo.VIOLATION_LAST_VIOL_INVOICE_STAGE')>0
--	DROP TABLE dbo.VIOLATION_LAST_VIOL_INVOICE_STAGE

--CREATE TABLE dbo.VIOLATION_LAST_VIOL_INVOICE_STAGE WITH (DISTRIBUTION = HASH(VIOLATOR_ID), CLUSTERED INDEX (VIOLATOR_ID, VIOLATION_ID)) 
--AS 
--	-- EXPLAIN
--	SELECT 
--		  LVINV.VIOLATOR_ID
--		, LVINV.VIOLATION_ID
--		, LVINV.VIOL_INVOICE_ID
--		, LVINV.LAST_VIOL_INVOICE_DATE
--		, VI.VIOL_INV_STATUS
--		, VIV.VIOL_STATUS
--	FROM  DBO.VIOLATION_LAST_VIOL_INVOICE_MAX_INVOICE_ID_STAGE LVINV
--	INNER JOIN DBO.VIOL_INVOICE_VIOL VIV 
--		ON		LVINV.VIOLATOR_ID = VIV.VIOLATOR_ID
--			AND LVINV.VIOL_INVOICE_ID = VIV.VIOL_INVOICE_ID 
--			AND LVINV.VIOLATION_ID = VIV.VIOLATION_ID 
--	INNER JOIN DBO.VIOL_INVOICES VI 
--		ON		LVINV.VIOLATOR_ID = VI.VIOLATOR_ID 
--			AND LVINV.VIOL_INVOICE_ID = VI.VIOL_INVOICE_ID 

--CREATE STATISTICS STATS_VIOLATION_LAST_VIOL_INVOICE_STAGE_001 ON VIOLATION_LAST_VIOL_INVOICE_STAGE(VIOLATOR_ID, VIOLATION_ID)



