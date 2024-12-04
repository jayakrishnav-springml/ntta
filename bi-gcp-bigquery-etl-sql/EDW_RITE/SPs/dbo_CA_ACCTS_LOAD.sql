CREATE PROC [DBO].[CA_ACCTS_LOAD] AS

-- EXEC EDW_RITE.DBO.CA_ACCTS_LOAD
/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.CA_ACCTS_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.CA_ACCTS_LOAD
GO

*/

/*	SELECT TOP 100 * FROM CA_ACCTS */  
/*	SELECT COUNT_BIG(1) FROM CA_ACCTS -- 22 772 914 */  

-- GetFields 'CA_ACCTS'
--   CA_ACCT_ID, CA_COMPANY_ID, FILE_GEN_DATE

DECLARE @LAST_UPDATE_DATE datetime2(2) 
EXEC DBO.GETLOADSTARTDATETIME 'DBO.CA_ACCTS', @LAST_UPDATE_DATE OUTPUT; --PRINT @LAST_UPDATE_DATE


IF OBJECT_ID('dbo.CA_ACCTS_STAGE')<>0
	DROP TABLE dbo.CA_ACCTS_STAGE


	--STEP #1: CA_ACCTS_STAGE
CREATE TABLE dbo.CA_ACCTS_STAGE WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (CA_ACCT_ID)) 
AS 
-- EXPLAIN
SELECT   CA_ACCT_ID, CA_COMPANY_ID, FILE_GEN_DATE, LAST_UPDATE_TYPE, LAST_UPDATE_DATE--SELECT COUNT(1) --17,417,052
FROM LND_LG_VPS.[VP_OWNER].[CA_ACCTS] A
WHERE LAST_UPDATE_DATE >= @LAST_UPDATE_DATE
OPTION (LABEL = 'CA_ACCTS_LOAD: CA_ACCTS_STAGE');



IF OBJECT_ID('dbo.CA_ACCTS_NEW_STAGE')>0 	DROP TABLE dbo.CA_ACCTS_NEW_STAGE

CREATE TABLE dbo.CA_ACCTS_NEW_STAGE WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(CA_ACCT_ID)) AS    
SELECT	
	CA_ACCT_ID, CA_COMPANY_ID, FILE_GEN_DATE, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
FROM dbo.CA_ACCTS AS F 
WHERE	NOT EXISTS (SELECT 1 FROM dbo.CA_ACCTS_STAGE AS NSET WHERE NSET.CA_ACCT_ID = F.CA_ACCT_ID) 

  UNION ALL 
  
SELECT	
	CA_ACCT_ID, CA_COMPANY_ID, FILE_GEN_DATE, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
FROM dbo.CA_ACCTS_STAGE
OPTION (LABEL = 'CA_ACCTS_LOAD: INSERT/UPDATE');


--STEP #2: Replace OLD table with NEW
IF OBJECT_ID('dbo.CA_ACCTS_OLD')>0 	DROP TABLE dbo.CA_ACCTS_OLD;
IF OBJECT_ID('dbo.CA_ACCTS')>0		RENAME OBJECT::dbo.CA_ACCTS TO CA_ACCTS_OLD;
RENAME OBJECT::dbo.CA_ACCTS_NEW_STAGE TO CA_ACCTS;
IF OBJECT_ID('dbo.CA_ACCTS_OLD')>0 	DROP TABLE dbo.CA_ACCTS_OLD;


IF OBJECT_ID('dbo.CA_ACCTS_STAGE')>0 	DROP TABLE dbo.CA_ACCTS_STAGE

--STEP #3: Create Statistics --[dbo].[CreateStats] 'dbo', 'CA_ACCTS'
CREATE STATISTICS [STATS_CA_ACCTS_001] ON [dbo].[CA_ACCTS] ([CA_ACCT_ID]);
CREATE STATISTICS [STATS_CA_ACCTS_002] ON [dbo].[CA_ACCTS] ([CA_ACCT_ID], [CA_COMPANY_ID], [FILE_GEN_DATE]);
CREATE STATISTICS [STATS_CA_ACCTS_005] ON [dbo].[CA_ACCTS] ([LAST_UPDATE_DATE]);


