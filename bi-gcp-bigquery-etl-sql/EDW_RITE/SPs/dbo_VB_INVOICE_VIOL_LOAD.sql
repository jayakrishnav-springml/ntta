CREATE PROC [DBO].[VB_INVOICE_VIOL_LOAD] AS

/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.VB_INVOICE_VIOL_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.VB_INVOICE_VIOL_LOAD
GO


EXEC EDW_RITE.DBO.VB_INVOICE_VIOL_LOAD

*/

/*	
SELECT TOP 100 * FROM VB_INVOICE_VIOL 
SELECT COUNT_BIG(1) FROM VB_INVOICE_VIOL -- 1 181 593 740 
*/ 

/*
INSERT INTO dbo.VB_INVOICE_VIOL
	(	 	  
	VBI_INVOICE_ID,VIOLATOR_ID,VIOLATION_ID,TOLL_DUE,VIOL_STATUS,DATE_CREATED,LAST_UPDATE_TYPE,LAST_UPDATE_DATE
	)
	VALUES
	(-1,-1,-1,0,'','2000-01-01','I','2000-01-01')

*/

--Ranjith Nair 2017-02-02  Changed Incremental to Full Load
-- Andy Filipps 2018-12-10 - returned incremental load of a new approach

DECLARE @LAST_UPDATE_DATE datetime2(2), @ROW_COUNT BIGINT

EXEC dbo.GetLoadStartDatetime 'dbo.VB_INVOICE_VIOL', @LAST_UPDATE_DATE OUTPUT

PRINT @LAST_UPDATE_DATE

IF OBJECT_ID('dbo.VB_INVOICE_VIOL_STAGE')>0	DROP TABLE dbo.VB_INVOICE_VIOL_STAGE

	CREATE TABLE dbo.VB_INVOICE_VIOL_STAGE WITH (HEAP, DISTRIBUTION = HASH(VBI_INVOICE_ID)) --DISTRIBUTION = HASH(VIOLATOR_ID))--, CLUSTERED INDEX (VIOLATOR_ID)) 
	AS 
	-- EXPLAIN
	SELECT 
		  ISNULL(convert(bigint,A.VBI_INVOICE_ID) , -1) AS VBI_INVOICE_ID
		--, ISNULL(convert(bigint,B.VIOLATOR_ID)    , -1) AS VIOLATOR_ID
		, ISNULL(convert(bigint,A.VIOLATION_ID)   , -1) AS VIOLATION_ID
		, A.TOLL_DUE
		, A.VIOL_STATUS
		, CONVERT(DATE,A.DATE_CREATED) AS DATE_CREATED
		, A.LAST_UPDATE_TYPE
		, A.LAST_UPDATE_DATE
	FROM LND_LG_VPS.[VP_OWNER].[VB_INVOICE_VIOL] A
	--INNER JOIN LND_LG_VPS.[VP_OWNER].[VB_INVOICES] B ON A.VBI_INVOICE_ID = B.VBI_INVOICE_ID
	WHERE	A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'VB_INVOICE_VIOL_STAGE_LOAD: VB_INVOICE_VIOL_STAGE');
EXEC EDW_RITE.dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT

	--CREATE STATISTICS STATS_VB_INVOICE_VIOL_STAGE_001 ON VB_INVOICE_VIOL_STAGE (VIOLATOR_ID, VBI_INVOICE_ID, VIOLATION_ID)

IF @ROW_COUNT > 0
BEGIN

	IF OBJECT_ID('dbo.VB_INVOICE_VIOL_NEW_STAGE')>0 	DROP TABLE dbo.VB_INVOICE_VIOL_NEW_STAGE

	CREATE TABLE dbo.VB_INVOICE_VIOL_NEW_STAGE WITH (CLUSTERED INDEX (VBI_INVOICE_ID ASC, VIOLATION_ID ASC), DISTRIBUTION = HASH(VBI_INVOICE_ID)) AS    
	SELECT	
		VBI_INVOICE_ID,VIOLATION_ID,TOLL_DUE,VIOL_STATUS,DATE_CREATED,LAST_UPDATE_TYPE,LAST_UPDATE_DATE
	FROM dbo.VB_INVOICE_VIOL AS F 
	WHERE NOT EXISTS (SELECT 1 FROM dbo.VB_INVOICE_VIOL_STAGE S WHERE S.VIOLATION_ID = F.VIOLATION_ID AND S.VBI_INVOICE_ID = F.VBI_INVOICE_ID) 
		UNION ALL 
	SELECT	
		VBI_INVOICE_ID,VIOLATION_ID,TOLL_DUE,VIOL_STATUS,DATE_CREATED,LAST_UPDATE_TYPE,LAST_UPDATE_DATE
	FROM dbo.VB_INVOICE_VIOL_STAGE AS N
	WHERE LAST_UPDATE_TYPE <> 'D'
	OPTION (LABEL = 'VB_INVOICE_VIOL_LOAD: INSERT/UPDATE');

	CREATE STATISTICS [STAT_VB_INVOICE_VIOL_001] ON [dbo].VB_INVOICE_VIOL_NEW_STAGE ([VIOLATION_ID], [VIOL_STATUS]);

	--STEP #2: Replace OLD table with NEW
	IF OBJECT_ID('dbo.VB_INVOICE_VIOL_OLD')>0 	DROP TABLE dbo.VB_INVOICE_VIOL_OLD;
	IF OBJECT_ID('dbo.VB_INVOICE_VIOL')>0		RENAME OBJECT::dbo.VB_INVOICE_VIOL TO VB_INVOICE_VIOL_OLD;
	RENAME OBJECT::dbo.VB_INVOICE_VIOL_NEW_STAGE TO VB_INVOICE_VIOL;
	IF OBJECT_ID('dbo.VB_INVOICE_VIOL_OLD')>0 	DROP TABLE dbo.VB_INVOICE_VIOL_OLD;

END


IF OBJECT_ID('dbo.VB_INVOICE_VIOL_STAGE')>0 	DROP TABLE dbo.VB_INVOICE_VIOL_STAGE
