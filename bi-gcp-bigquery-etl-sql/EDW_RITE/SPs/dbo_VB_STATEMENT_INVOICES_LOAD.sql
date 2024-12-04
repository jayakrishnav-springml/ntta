CREATE PROC [DBO].[VB_STATEMENT_INVOICES_LOAD] AS

/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.VB_STATEMENT_INVOICES_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.VB_STATEMENT_INVOICES_LOAD
GO


EXEC EDW_RITE.DBO.VB_STATEMENT_INVOICES_LOAD
*/

/*	
SELECT TOP 100 * FROM EDW_RITE.DBO.VB_STATEMENT_INVOICES 
SELECT COUNT_BIG(1) FROM EDW_RITE.DBO.VB_STATEMENT_INVOICES -- 382 263 494
*/  

/*
INSERT INTO dbo.VB_STATEMENT_INVOICES
	(	 	  
	VBSI_STATEMENT_ID, VIOLATOR_ID, VBI_INVOICE_ID, VIOL_INVOICE_ID, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	)
	VALUES
	(-1,-1,-1,-1,'I','2000-01-01')
*/

-- GetFields 'dbo','VB_STATEMENT_INVOICES'
--    VBSI_STATEMENT_ID, VBI_INVOICE_ID, LAST_UPDATE_DATE, LAST_UPDATE_TYPE

--DECLARE @LAST_UPDATE_DATE datetime2(2), @LAST_UPDATE_DATE1 datetime2(2), @LAST_UPDATE_DATE2 datetime2(2) 
--exec dbo.GetLoadStartDatetime 'dbo.VB_STATEMENT_INVOICES', @LAST_UPDATE_DATE1 OUTPUT
--exec dbo.GetLoadStartDatetime 'dbo.VB_INVOICES', @LAST_UPDATE_DATE2 OUTPUT

--SET @LAST_UPDATE_DATE = CASE WHEN @LAST_UPDATE_DATE1 > @LAST_UPDATE_DATE2 THEN @LAST_UPDATE_DATE2 ELSE @LAST_UPDATE_DATE1 END

IF OBJECT_ID('dbo.VB_STATEMENT_INVOICES_STAGE')<>0	DROP TABLE dbo.VB_STATEMENT_INVOICES_STAGE

CREATE TABLE dbo.VB_STATEMENT_INVOICES_STAGE WITH (CLUSTERED INDEX (VBSI_STATEMENT_ID), DISTRIBUTION = HASH(VBI_INVOICE_ID)) 
AS 
-- EXPLAIN
SELECT   
	  A.VBSI_STATEMENT_ID, ISNULL(B.VIOLATOR_ID,((A.VBSI_STATEMENT_ID%200000)*-1)) AS VIOLATOR_ID
	, A.VBI_INVOICE_ID, A.VIOL_INVOICE_ID, A.LAST_UPDATE_TYPE, A.LAST_UPDATE_DATE
FROM LND_LG_VPS.[VP_OWNER].[VB_STATEMENT_INVOICES] A
INNER JOIN LND_LG_VPS.[VP_OWNER].[VB_INVOICES] B ON A.VBI_INVOICE_ID = B.VBI_INVOICE_ID
--WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE
OPTION (LABEL = 'VB_STATEMENT_INVOICES_LOAD: VB_STATEMENT_INVOICES_STAGE');

--CREATE STATISTICS STATS_VB_STATEMENT_INVOICES_STAGE_001 ON VB_STATEMENT_INVOICES_STAGE (VBI_INVOICE_ID)

/*
IF OBJECT_ID('dbo.VB_STATEMENT_INVOICES_NEW_STAGE')>0 	DROP TABLE dbo.VB_STATEMENT_INVOICES_NEW_STAGE

CREATE TABLE dbo.VB_STATEMENT_INVOICES_NEW_STAGE WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(VBI_INVOICE_ID)) AS    
SELECT	
	VBSI_STATEMENT_ID, VIOLATOR_ID, VBI_INVOICE_ID, VIOL_INVOICE_ID, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
FROM dbo.VB_STATEMENT_INVOICES AS F 
WHERE NOT EXISTS (SELECT 1 FROM dbo.VB_STATEMENT_INVOICES_STAGE AS N WHERE N.VBI_INVOICE_ID = F.VBI_INVOICE_ID) 

  UNION ALL 
  
SELECT	
	VBSI_STATEMENT_ID, VIOLATOR_ID, VBI_INVOICE_ID, VIOL_INVOICE_ID, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
FROM dbo.VB_STATEMENT_INVOICES_STAGE AS N
OPTION (LABEL = 'VB_STATEMENT_INVOICES_LOAD: INSERT/UPDATE');
*/
CREATE STATISTICS STATS_VB_STATEMENT_INVOICES_001 ON dbo.VB_STATEMENT_INVOICES_STAGE (VIOLATOR_ID,VBSI_STATEMENT_ID)
CREATE STATISTICS STATS_VB_STATEMENT_INVOICES_002 ON dbo.VB_STATEMENT_INVOICES_STAGE (VBI_INVOICE_ID,VIOLATOR_ID)
CREATE STATISTICS STATS_VB_STATEMENT_INVOICES_003 ON dbo.VB_STATEMENT_INVOICES_STAGE (VIOL_INVOICE_ID,VIOLATOR_ID)


--STEP #2: Replace OLD table with NEW
IF OBJECT_ID('dbo.VB_STATEMENT_INVOICES_OLD')>0 	DROP TABLE dbo.VB_STATEMENT_INVOICES_OLD;
IF OBJECT_ID('dbo.VB_STATEMENT_INVOICES')>0		RENAME OBJECT::dbo.VB_STATEMENT_INVOICES TO VB_STATEMENT_INVOICES_OLD;
RENAME OBJECT::dbo.VB_STATEMENT_INVOICES_STAGE TO VB_STATEMENT_INVOICES;
IF OBJECT_ID('dbo.VB_STATEMENT_INVOICES_OLD')>0 	DROP TABLE dbo.VB_STATEMENT_INVOICES_OLD;

--CREATE STATISTICS STATS_VB_STATEMENT_INVOICES_001 ON VB_STATEMENT_INVOICES (VBI_INVOICE_ID)
--CREATE STATISTICS STATS_VB_STATEMENT_INVOICES_002 ON VB_STATEMENT_INVOICES (VBI_INVOICE_ID,VIOLATOR_ID)
--CREATE STATISTICS STATS_VB_STATEMENT_INVOICES_003 ON VB_STATEMENT_INVOICES (VBI_INVOICE_ID,VBSI_STATEMENT_ID)
--CREATE STATISTICS STATS_VB_STATEMENT_INVOICES_004 ON VB_STATEMENT_INVOICES (VBI_INVOICE_ID,VIOL_INVOICE_ID)
--CREATE STATISTICS STATS_VB_STATEMENT_INVOICES_005 ON VB_STATEMENT_INVOICES (VBI_INVOICE_ID,VIOLATOR_ID,VBSI_STATEMENT_ID,VIOL_INVOICE_ID)

IF OBJECT_ID('dbo.VB_STATEMENT_INVOICES_STAGE')>0 	DROP TABLE dbo.VB_STATEMENT_INVOICES_STAGE



--TRUNCATE TABLE VB_STATEMENT_INVOICES

----UPDATE dbo.VB_STATEMENT_INVOICES
----SET  VBSI_STATEMENT_ID = B.VBSI_STATEMENT_ID
----	, LAST_UPDATE_TYPE = B.LAST_UPDATE_TYPE
----	, LAST_UPDATE_DATE = B.LAST_UPDATE_DATE
----FROM dbo.VB_STATEMENT_INVOICES_STAGE B
----WHERE 
----	dbo.VB_STATEMENT_INVOICES.VBI_INVOICE_ID = B.VBI_INVOICE_ID
----	AND dbo.VB_STATEMENT_INVOICES.VBSI_STATEMENT_ID <> B.VBSI_STATEMENT_ID 

--INSERT INTO dbo.VB_STATEMENT_INVOICES (VBSI_STATEMENT_ID, VIOLATOR_ID, VBI_INVOICE_ID, VIOL_INVOICE_ID, LAST_UPDATE_TYPE, LAST_UPDATE_DATE)
--SELECT A.VBSI_STATEMENT_ID, A.VIOLATOR_ID, A.VBI_INVOICE_ID, A.VIOL_INVOICE_ID, A.LAST_UPDATE_TYPE, A.LAST_UPDATE_DATE
--FROM dbo.VB_STATEMENT_INVOICES_STAGE A
--LEFT JOIN dbo.VB_STATEMENT_INVOICES B ON A.VIOLATOR_ID = B.VIOLATOR_ID AND A.VBSI_STATEMENT_ID = B.VBSI_STATEMENT_ID AND A.VBI_INVOICE_ID = B.VBI_INVOICE_ID AND A.VIOL_INVOICE_ID = B.VIOL_INVOICE_ID
--WHERE B.VIOLATOR_ID IS NULL AND B.VBSI_STATEMENT_ID IS NULL AND B.VBI_INVOICE_ID IS NULL AND B.VIOL_INVOICE_ID IS NULL

/*
	SELECT COUNT(*) FROM LND_LG_VPS.[VP_OWNER].[VB_STATEMENT_INVOICES]
	DBCC PDW_SHOWSPACEUSED (VB_STATEMENT_INVOICES)

*/



