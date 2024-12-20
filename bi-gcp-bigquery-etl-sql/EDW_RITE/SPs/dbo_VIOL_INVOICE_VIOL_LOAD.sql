CREATE PROC [DBO].[VIOL_INVOICE_VIOL_LOAD] AS

/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.VIOL_INVOICE_VIOL_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.VIOL_INVOICE_VIOL_LOAD
GO


EXEC EDW_RITE.DBO.VIOL_INVOICE_VIOL_LOAD

*/

/*	
SELECT TOP 100 * FROM EDW_RITE.DBO.VIOL_INVOICE_VIOL 
SELECT COUNT_BIG(1) FROM EDW_RITE.DBO.VIOL_INVOICE_VIOL -- 623 008 898
*/ 

/*
INSERT INTO EDW_RITE.dbo.VIOL_INVOICE_VIOL
	(	 	  
	VIOLATION_ID, VIOLATOR_ID, VIOL_INVOICE_ID, VIOL_STATUS, TOLL_DUE_AMOUNT, FINE_AMOUNT, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	)
	VALUES
	(-1,-1,-1,'',0,0,'I','2000-01-01')

*/
 
--Ranjith Nair 2017-02-02  Changed Incremental to Full Load

DECLARE @LAST_UPDATE_DATE datetime2(2), @ROW_COUNT BIGINT
EXEC dbo.GetLoadStartDatetime 'dbo.VIOL_INVOICE_VIOL', @LAST_UPDATE_DATE OUTPUT


IF OBJECT_ID('dbo.VIOL_INVOICE_VIOL_STAGE')>0
	DROP TABLE dbo.VIOL_INVOICE_VIOL_STAGE

CREATE TABLE dbo.VIOL_INVOICE_VIOL_STAGE WITH (HEAP, DISTRIBUTION = HASH(VIOLATION_ID))--DISTRIBUTION = HASH(VIOLATOR_ID))--, CLUSTERED INDEX (VIOLATOR_ID)) 
AS 
-- EXPLAIN
SELECT  
	ISNULL(CONVERT(BIGINT,A.VIOLATION_ID)		, -1) AS VIOLATION_ID
	--, ISNULL(CONVERT(BIGINT,B.VIOLATOR_ID)		, -1) AS VIOLATOR_ID
	, ISNULL(CONVERT(BIGINT,A.VIOL_INVOICE_ID)  , -1) AS VIOL_INVOICE_ID
	, A.VIOL_STATUS 
	, A.TOLL_DUE_AMOUNT, A.FINE_AMOUNT  
	, A.LAST_UPDATE_TYPE, A.LAST_UPDATE_DATE
FROM LND_LG_VPS.VP_OWNER.VIOL_INVOICE_VIOL A
--INNER JOIN LND_LG_VPS.VP_OWNER.VIOL_INVOICES B ON A.VIOL_INVOICE_ID = B.VIOL_INVOICE_ID
WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE
OPTION (LABEL = 'VIOL_INVOICE_VIOL_STAGE_LOAD: VIOL_INVOICE_VIOL_STAGE');

--CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_STAGE_003 ON DBO.VIOL_INVOICE_VIOL_STAGE (VIOLATOR_ID, VIOL_INVOICE_ID, VIOLATION_ID)

EXEC EDW_RITE.dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT

IF @ROW_COUNT > 0
BEGIN

	IF OBJECT_ID('dbo.VIOL_INVOICE_VIOL_NEW_STAGE')>0 	DROP TABLE dbo.VIOL_INVOICE_VIOL_NEW_STAGE

	CREATE TABLE dbo.VIOL_INVOICE_VIOL_NEW_STAGE WITH (CLUSTERED INDEX (VIOL_INVOICE_ID,VIOLATION_ID), DISTRIBUTION = HASH(VIOLATION_ID)) AS    
	SELECT
		VIOLATION_ID, VIOL_INVOICE_ID, VIOL_STATUS, TOLL_DUE_AMOUNT, FINE_AMOUNT, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM dbo.VIOL_INVOICE_VIOL AS F 
	WHERE NOT EXISTS (SELECT 1 FROM dbo.VIOL_INVOICE_VIOL_STAGE S WHERE S.VIOLATION_ID = F.VIOLATION_ID AND S.VIOL_INVOICE_ID = F.VIOL_INVOICE_ID) 

	  UNION ALL 
  
	SELECT	
		VIOLATION_ID, VIOL_INVOICE_ID, VIOL_STATUS, TOLL_DUE_AMOUNT, FINE_AMOUNT, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM dbo.VIOL_INVOICE_VIOL_STAGE AS N
	WHERE LAST_UPDATE_TYPE <> 'D'
	OPTION (LABEL = 'VIOL_INVOICE_VIOL_LOAD: INSERT/UPDATE');

	CREATE STATISTICS [STATS_VIOL_INVOICE_VIOL_001] ON [dbo].VIOL_INVOICE_VIOL_NEW_STAGE (VIOLATION_ID, [VIOL_STATUS]);

	--STEP #2: Replace OLD table with NEW
	IF OBJECT_ID('dbo.VIOL_INVOICE_VIOL_OLD')>0 	DROP TABLE dbo.VIOL_INVOICE_VIOL_OLD;
	IF OBJECT_ID('dbo.VIOL_INVOICE_VIOL')>0		RENAME OBJECT::dbo.VIOL_INVOICE_VIOL TO VIOL_INVOICE_VIOL_OLD;
	RENAME OBJECT::dbo.VIOL_INVOICE_VIOL_NEW_STAGE TO VIOL_INVOICE_VIOL;
	IF OBJECT_ID('dbo.VIOL_INVOICE_VIOL_OLD')>0 	DROP TABLE dbo.VIOL_INVOICE_VIOL_OLD;

END

IF OBJECT_ID('dbo.VIOL_INVOICE_VIOL_STAGE')>0 	DROP TABLE dbo.VIOL_INVOICE_VIOL_STAGE




	--IF OBJECT_ID('dbo.VIOL_INVOICE_VIOL')>0			RENAME OBJECT::dbo.VIOL_INVOICE_VIOL TO VIOL_INVOICE_VIOL_OLD;
	--IF OBJECT_ID('dbo.VIOL_INVOICE_VIOL_STAGE')>0	RENAME OBJECT::dbo.VIOL_INVOICE_VIOL_STAGE TO VIOL_INVOICE_VIOL;
	--IF OBJECT_ID('dbo.VIOL_INVOICE_VIOL_OLD')>0		DROP TABLE dbo.VIOL_INVOICE_VIOL_OLD;

