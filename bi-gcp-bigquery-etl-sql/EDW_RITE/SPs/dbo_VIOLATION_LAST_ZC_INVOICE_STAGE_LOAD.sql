CREATE PROC [DBO].[VIOLATION_LAST_ZC_INVOICE_STAGE_LOAD] AS 

select 'foo'
--IF OBJECT_ID('dbo.VIOLATION_LAST_ZC_INVOICE_MAX_STAGE')>0
--	DROP TABLE dbo.VIOLATION_LAST_ZC_INVOICE_MAX_STAGE

--CREATE TABLE dbo.VIOLATION_LAST_ZC_INVOICE_MAX_STAGE WITH (DISTRIBUTION = HASH(VIOLATOR_ID), CLUSTERED INDEX (VIOLATOR_ID, VIOLATION_ID)) 
--AS 
---- EXPLAIN
--	SELECT VBIV.VIOLATOR_ID, VBIV.VIOLATION_ID,  MAX(VBI.INVOICE_DATE) AS LAST_ZC_INVOICE_DATE
--	FROM DBO.VIOLATIONS_STAGE V
--	INNER JOIN DBO.VB_INVOICE_VIOL VBIV ON V.VIOLATOR_ID = VBIV.VIOLATOR_ID AND V.VIOLATION_ID = VBIV.VIOLATION_ID
--	INNER JOIN DBO.VB_INVOICES VBI ON VBIV.VIOLATOR_ID = VBI.VIOLATOR_ID  AND VBIV.VBI_INVOICE_ID = VBI.VBI_INVOICE_ID 
--	--WHERE V.VIOLATOR_ID = 742195198 AND V.VIOLATION_ID=156647508
--	GROUP BY VBIV.VIOLATOR_ID, VBIV.VIOLATION_ID

--CREATE STATISTICS STATS_VIOLATION_LAST_ZC_INVOICE_001 ON VIOLATION_LAST_ZC_INVOICE_MAX_STAGE(VIOLATOR_ID, VIOLATION_ID)


--IF OBJECT_ID('dbo.VIOLATION_LAST_ZC_INVOICE_MAX_INVOICE_ID_STAGE')>0
--	DROP TABLE dbo.VIOLATION_LAST_ZC_INVOICE_MAX_INVOICE_ID_STAGE

--CREATE TABLE dbo.VIOLATION_LAST_ZC_INVOICE_MAX_INVOICE_ID_STAGE WITH (DISTRIBUTION = HASH(VIOLATOR_ID), CLUSTERED INDEX (VIOLATOR_ID, MAX_VBI_INVOICE_ID)) 
--AS 
---- EXPLAIN
--	SELECT LZCINV.VIOLATOR_ID, LZCINV.VIOLATION_ID, LZCINV.LAST_ZC_INVOICE_DATE, MAX(VBI.VBI_INVOICE_ID) AS MAX_VBI_INVOICE_ID
--	FROM dbo.VIOLATION_LAST_ZC_INVOICE_MAX_STAGE LZCINV
--	INNER JOIN DBO.VB_INVOICES VBI 
--		ON	LZCINV.VIOLATOR_ID = VBI.VIOLATOR_ID AND LZCINV.LAST_ZC_INVOICE_DATE = VBI.INVOICE_DATE 	
----	WHERE LZCINV.VIOLATOR_ID = 742195198 AND LZCINV.VIOLATION_ID=156647508
--	GROUP BY LZCINV.VIOLATOR_ID, LZCINV.VIOLATION_ID, VBI.VIOLATOR_ID, LZCINV.LAST_ZC_INVOICE_DATE

--CREATE STATISTICS STATS_VIOLATION_LAST_ZC_INVOICE_MAX_INVOICE_ID_STAGE_001 ON VIOLATION_LAST_ZC_INVOICE_MAX_INVOICE_ID_STAGE(VIOLATOR_ID, MAX_VBI_INVOICE_ID)
	
	

---- WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (violation_id, LAST_ZC_INVOICE_DATE)) 
--IF OBJECT_ID('dbo.VIOLATION_LAST_ZC_INVOICE_STAGE')>0
--	DROP TABLE dbo.VIOLATION_LAST_ZC_INVOICE_STAGE
--	-- 
--CREATE TABLE dbo.VIOLATION_LAST_ZC_INVOICE_STAGE WITH (DISTRIBUTION = HASH(VIOLATOR_ID), CLUSTERED INDEX (VIOLATOR_ID, VIOLATION_ID)) 
--AS 
---- EXPLAIN
--SELECT 
--	  LZCINV.VIOLATOR_ID, LZCINV.VIOLATION_ID
--	, LZCINV.MAX_VBI_INVOICE_ID AS VBI_INVOICE_ID
--	, LZCINV.LAST_ZC_INVOICE_DATE	
--	, VBI.VBI_STATUS
--	, VBIV.VIOL_STATUS
--FROM  DBO.VIOLATION_LAST_ZC_INVOICE_MAX_INVOICE_ID_STAGE LZCINV
--INNER JOIN DBO.VB_INVOICE_VIOL VBIV 
--	ON		LZCINV.VIOLATOR_ID = VBIV.VIOLATOR_ID
--		AND LZCINV.MAX_VBI_INVOICE_ID = VBIV.VBI_INVOICE_ID
--		AND LZCINV.VIOLATION_ID = VBIV.VIOLATION_ID
--INNER JOIN  dbo.VB_INVOICES VBI 
--	ON 
--			LZCINV.VIOLATOR_ID = VBI.VIOLATOR_ID 
--		AND LZCINV.MAX_VBI_INVOICE_ID = VBI.VBI_INVOICE_ID
		
--CREATE STATISTICS STATS_VIOLATION_LAST_ZC_INVOICE_STAGE_001 ON VIOLATION_LAST_ZC_INVOICE_STAGE(VIOLATOR_ID, VIOLATION_ID)



