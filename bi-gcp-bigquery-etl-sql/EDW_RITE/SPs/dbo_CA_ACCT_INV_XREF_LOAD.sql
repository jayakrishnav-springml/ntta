CREATE PROC [DBO].[CA_ACCT_INV_XREF_LOAD] AS

-- EXEC EDW_RITE.DBO.CA_ACCT_INV_XREF_LOAD
/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.CA_ACCT_INV_XREF_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.CA_ACCT_INV_XREF_LOAD
GO

*/

/*	SELECT TOP 100 * FROM CA_ACCT_INV_XREF */  
/*	SELECT COUNT_BIG(1) FROM CA_ACCT_INV_XREF -- 29 944 538 */ 


DECLARE @LAST_UPDATE_DATE datetime2(2) 
exec dbo.GetLoadStartDatetime 'dbo.CA_ACCT_INV_XREF', @LAST_UPDATE_DATE OUTPUT

IF OBJECT_ID('dbo.CA_ACCT_INV_XREF_STAGE')<>0
	DROP TABLE dbo.CA_ACCT_INV_XREF_STAGE

CREATE TABLE dbo.CA_ACCT_INV_XREF_STAGE WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (CA_ACCT_ID)) 
AS 
-- EXPLAIN
SELECT CA_ACCT_ID, VIOL_INVOICE_ID, CA_INV_STATUS, CA_ACCT_STATUS, LAST_UPDATE_DATE AS INSERT_DATE, LAST_UPDATE_DATE
FROM LND_LG_VPS.[VP_OWNER].[CA_ACCT_INV_XREF] 
WHERE 
	LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
OPTION (LABEL = 'CA_ACCT_INV_XREF_LOAD: CA_ACCT_INV_XREF_STAGE');

CREATE STATISTICS STATS_CA_ACCT_INV_XREF_STAGE_001 ON CA_ACCT_INV_XREF_STAGE (CA_ACCT_ID)



IF OBJECT_ID('dbo.CA_ACCT_INV_XREF_NEW_STAGE')>0 	DROP TABLE dbo.CA_ACCT_INV_XREF_NEW_STAGE

CREATE TABLE dbo.CA_ACCT_INV_XREF_NEW_STAGE WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(CA_ACCT_ID)) AS    
SELECT	
	CA_ACCT_ID, VIOL_INVOICE_ID, CA_INV_STATUS, CA_ACCT_STATUS, INSERT_DATE, LAST_UPDATE_DATE
FROM dbo.CA_ACCT_INV_XREF AS F 
WHERE	NOT EXISTS (SELECT 1 FROM dbo.CA_ACCT_INV_XREF_STAGE AS NSET WHERE NSET.CA_ACCT_ID = F.CA_ACCT_ID AND NSET.VIOL_INVOICE_ID = F.VIOL_INVOICE_ID) 

  UNION ALL 
  
SELECT	
	N.CA_ACCT_ID, N.VIOL_INVOICE_ID, N.CA_INV_STATUS, N.CA_ACCT_STATUS, ISNULL(F.INSERT_DATE, N.INSERT_DATE) AS INSERT_DATE, N.LAST_UPDATE_DATE
FROM dbo.CA_ACCT_INV_XREF_STAGE N
LEFT JOIN dbo.CA_ACCT_INV_XREF AS F ON N.CA_ACCT_ID = F.CA_ACCT_ID AND N.VIOL_INVOICE_ID = F.VIOL_INVOICE_ID 
OPTION (LABEL = 'CA_ACCT_INV_XREF_LOAD: INSERT/UPDATE');


--STEP #2: Replace OLD table with NEW
IF OBJECT_ID('dbo.CA_ACCT_INV_XREF_OLD')>0 	DROP TABLE dbo.CA_ACCT_INV_XREF_OLD;
IF OBJECT_ID('dbo.CA_ACCT_INV_XREF')>0		RENAME OBJECT::dbo.CA_ACCT_INV_XREF TO CA_ACCT_INV_XREF_OLD;
RENAME OBJECT::dbo.CA_ACCT_INV_XREF_NEW_STAGE TO CA_ACCT_INV_XREF;
IF OBJECT_ID('dbo.CA_ACCT_INV_XREF_OLD')>0 	DROP TABLE dbo.CA_ACCT_INV_XREF_OLD;

--STEP #3: Create Statistics --[dbo].[CreateStats] 'dbo', 'CA_ACCT_INV_XREF'
CREATE STATISTICS [STATS_CA_ACCT_INV_XREF_001] ON [dbo].[CA_ACCT_INV_XREF] ([CA_ACCT_ID]);
CREATE STATISTICS [STATS_CA_ACCT_INV_XREF_002] ON [dbo].[CA_ACCT_INV_XREF] ([VIOL_INVOICE_ID]);
CREATE STATISTICS [STATS_CA_ACCT_INV_XREF_003] ON [dbo].[CA_ACCT_INV_XREF] ([CA_ACCT_ID], [CA_INV_STATUS]);
CREATE STATISTICS [STATS_CA_ACCT_INV_XREF_004] ON [dbo].[CA_ACCT_INV_XREF] ([CA_ACCT_ID], [CA_ACCT_STATUS]);
CREATE STATISTICS [STATS_CA_ACCT_INV_XREF_005] ON [dbo].[CA_ACCT_INV_XREF] ([CA_ACCT_ID], [VIOL_INVOICE_ID]);
CREATE STATISTICS [STATS_CA_ACCT_INV_XREF_006] ON [dbo].[CA_ACCT_INV_XREF] ([VIOL_INVOICE_ID], [CA_ACCT_ID], [CA_ACCT_STATUS]);

IF OBJECT_ID('dbo.CA_ACCT_INV_XREF_STAGE')>0 	DROP TABLE dbo.CA_ACCT_INV_XREF_STAGE

--UPDATE dbo.CA_ACCT_INV_XREF
--SET  CA_INV_STATUS = B.CA_INV_STATUS
--	, CA_ACCT_STATUS = B.CA_ACCT_STATUS
--	, LAST_UPDATE_DATE = B.LAST_UPDATE_DATE
--FROM dbo.CA_ACCT_INV_XREF_STAGE B
--WHERE 
--	dbo.CA_ACCT_INV_XREF.CA_ACCT_ID = B.CA_ACCT_ID
--	AND dbo.CA_ACCT_INV_XREF.VIOL_INVOICE_ID = B.VIOL_INVOICE_ID
--	AND 
--	(
--		dbo.CA_ACCT_INV_XREF.CA_INV_STATUS <> B.CA_INV_STATUS
--		OR
--		dbo.CA_ACCT_INV_XREF.CA_ACCT_STATUS <> B.CA_ACCT_STATUS
--	)

	
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- -- -- -- FOR FULL LOAD ONLY
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
--IF (SELECT COUNT_BIG(*) FROM dbo.CA_ACCT_INV_XREF_STAGE) > 20111222

/*	
TRUNCATE TABLE dbo.CA_ACCT_INV_XREF
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


INSERT INTO dbo.CA_ACCT_INV_XREF (CA_ACCT_ID, VIOL_INVOICE_ID, CA_INV_STATUS, CA_ACCT_STATUS, INSERT_DATE, LAST_UPDATE_DATE)
SELECT A.CA_ACCT_ID, A.VIOL_INVOICE_ID, A.CA_INV_STATUS, A.CA_ACCT_STATUS, A.LAST_UPDATE_DATE, A.LAST_UPDATE_DATE
FROM dbo.CA_ACCT_INV_XREF_STAGE A
LEFT JOIN dbo.CA_ACCT_INV_XREF B ON A.CA_ACCT_ID = B.CA_ACCT_ID AND A.VIOL_INVOICE_ID = B.VIOL_INVOICE_ID
WHERE B.CA_ACCT_ID IS NULL OR B.VIOL_INVOICE_ID IS NULL


*/


