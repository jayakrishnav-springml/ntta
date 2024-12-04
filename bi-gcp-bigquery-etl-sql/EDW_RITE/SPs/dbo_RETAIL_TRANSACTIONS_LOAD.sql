CREATE PROC [DBO].[RETAIL_TRANSACTIONS_LOAD] AS

-- EXEC EDW_RITE.DBO.RETAIL_TRANSACTIONS_LOAD
/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.RETAIL_TRANSACTIONS_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.RETAIL_TRANSACTIONS_LOAD
GO

*/

/*	
SELECT TOP 100 * FROM RETAIL_TRANSACTIONS
SELECT COUNT_BIG(1) FROM RETAIL_TRANSACTIONS -- 556 129 772 
*/ 

/*
INSERT INTO EDW_RITE.dbo.RETAIL_TRANSACTIONS
	(	 	  
	VIOLATOR_ID, RETAIL_TRANS_ID, PAYMENT_TXN_ID, POS_ID, INSERT_DATETIME, LAST_UPDATE_DATE
	)
	VALUES
	(-1,-1,-1,-1,'2000-01-01','2000-01-01')
*/

DECLARE @LAST_UPDATE_DATE datetime2(2) 
EXEC dbo.GetLoadStartDatetime 'dbo.RETAIL_TRANSACTIONS', @LAST_UPDATE_DATE OUTPUT

IF OBJECT_ID('dbo.RETAIL_TRANSACTIONS_STAGE')>0
	DROP TABLE dbo.RETAIL_TRANSACTIONS_STAGE

CREATE TABLE dbo.RETAIL_TRANSACTIONS_STAGE WITH (DISTRIBUTION = HASH(VIOLATOR_ID))--, CLUSTERED INDEX (VIOLATOR_ID, PAYMENT_TXN_ID, RETAIL_TRANS_ID)) 
AS 
-- EXPLAIN
SELECT 
	  convert(bigint,ISNULL(B.VIOLATOR_ID,(A.RETAIL_TRANS_ID%100000)*-1)) AS VIOLATOR_ID
	, Convert(bigint,A.RETAIL_TRANS_ID) AS RETAIL_TRANS_ID
	, convert(bigint,ISNULL(B.PAYMENT_TXN_ID,-1)) AS PAYMENT_TXN_ID
	, convert(bigint,A.POS_ID) AS POS_ID
	, A.LAST_UPDATE_DATE AS INSERT_DATETIME
	, A.LAST_UPDATE_DATE
FROM LND_LG_TS.[TAG_OWNER].RETAIL_TRANSACTIONS A 
LEFT JOIN LND_LG_VPS.[VP_OWNER].PAYMENTS B ON A.RETAIL_TRANS_ID = B.RETAIL_TRANS_ID
WHERE 	A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
OPTION (LABEL = 'RETAIL_TRANSACTIONS_LOAD: RETAIL_TRANSACTIONS_STAGE');

CREATE STATISTICS STATS_RETAIL_TRANSACTIONS_STAGE_001 ON RETAIL_TRANSACTIONS_STAGE (VIOLATOR_ID, PAYMENT_TXN_ID, RETAIL_TRANS_ID)


IF OBJECT_ID('dbo.RETAIL_TRANSACTIONS_NEW_STAGE')>0 	DROP TABLE dbo.RETAIL_TRANSACTIONS_NEW_STAGE

CREATE TABLE dbo.RETAIL_TRANSACTIONS_NEW_STAGE WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(VIOLATOR_ID)) AS    
SELECT	
	VIOLATOR_ID, RETAIL_TRANS_ID, PAYMENT_TXN_ID, POS_ID, INSERT_DATETIME, LAST_UPDATE_DATE
FROM dbo.RETAIL_TRANSACTIONS AS F 
WHERE	NOT EXISTS (SELECT 1 FROM dbo.RETAIL_TRANSACTIONS_STAGE AS N WHERE N.VIOLATOR_ID = F.VIOLATOR_ID AND N.PAYMENT_TXN_ID = F.PAYMENT_TXN_ID AND N.RETAIL_TRANS_ID = F.RETAIL_TRANS_ID) 

  UNION ALL 
  
SELECT	
	N.VIOLATOR_ID, N.RETAIL_TRANS_ID, N.PAYMENT_TXN_ID, N.POS_ID, ISNULL(F.INSERT_DATETIME, N.INSERT_DATETIME) AS INSERT_DATETIME, N.LAST_UPDATE_DATE
FROM dbo.RETAIL_TRANSACTIONS_STAGE AS N
LEFT JOIN dbo.RETAIL_TRANSACTIONS AS F ON N.VIOLATOR_ID = F.VIOLATOR_ID AND N.PAYMENT_TXN_ID = F.PAYMENT_TXN_ID AND N.RETAIL_TRANS_ID = F.RETAIL_TRANS_ID 
OPTION (LABEL = 'RETAIL_TRANSACTIONS_LOAD: INSERT/UPDATE');


--STEP #2: Replace OLD table with NEW
IF OBJECT_ID('dbo.RETAIL_TRANSACTIONS_OLD')>0 	DROP TABLE dbo.RETAIL_TRANSACTIONS_OLD;
IF OBJECT_ID('dbo.RETAIL_TRANSACTIONS')>0		RENAME OBJECT::dbo.RETAIL_TRANSACTIONS TO RETAIL_TRANSACTIONS_OLD;
RENAME OBJECT::dbo.RETAIL_TRANSACTIONS_NEW_STAGE TO RETAIL_TRANSACTIONS;
IF OBJECT_ID('dbo.RETAIL_TRANSACTIONS_OLD')>0 	DROP TABLE dbo.RETAIL_TRANSACTIONS_OLD;

CREATE STATISTICS [STATS_RETAIL_TRANSACTIONS_001] ON [dbo].[RETAIL_TRANSACTIONS] ([VIOLATOR_ID]);
CREATE STATISTICS [STATS_RETAIL_TRANSACTIONS_002] ON [dbo].[RETAIL_TRANSACTIONS] ([VIOLATOR_ID], [PAYMENT_TXN_ID], [RETAIL_TRANS_ID]);
CREATE STATISTICS [STATS_RETAIL_TRANSACTIONS_003] ON [dbo].[RETAIL_TRANSACTIONS] ([VIOLATOR_ID], [PAYMENT_TXN_ID], [RETAIL_TRANS_ID], [POS_ID]);
CREATE STATISTICS [STATS_RETAIL_TRANSACTIONS_004] ON [dbo].[RETAIL_TRANSACTIONS] ([RETAIL_TRANS_ID]);
CREATE STATISTICS [STATS_RETAIL_TRANSACTIONS_005] ON [dbo].[RETAIL_TRANSACTIONS] ([LAST_UPDATE_DATE]);

IF OBJECT_ID('dbo.RETAIL_TRANSACTIONS_STAGE')>0 	DROP TABLE dbo.RETAIL_TRANSACTIONS_STAGE



-- GetUpdateFields 'RETAIL_TRANSACTIONS'
-- EXPLAIN
/*
UPDATE DBO.RETAIL_TRANSACTIONS
SET   
	  dbo.RETAIL_TRANSACTIONS.POS_ID = B.POS_ID
FROM dbo.RETAIL_TRANSACTIONS_STAGE B
WHERE 
		DBO.RETAIL_TRANSACTIONS.VIOLATOR_ID = B.VIOLATOR_ID 
	AND DBO.RETAIL_TRANSACTIONS.PAYMENT_TXN_ID = B.PAYMENT_TXN_ID 
	AND DBO.RETAIL_TRANSACTIONS.RETAIL_TRANS_ID = B.RETAIL_TRANS_ID 
	--AND 
	--(
	--		dbo.RETAIL_TRANSACTIONS.POS_ID <> B.POS_ID
	--)
--	AND B.LAST_UPDATE_TYPE = 'U'
OPTION (LABEL = 'RETAIL_TRANSACTIONS_LOAD: UPDATE RETAIL_TRANSACTIONS');		

	 
-- GetFields 'RETAIL_TRANSACTIONS'
-- EXPLAIN 
INSERT INTO DBO.RETAIL_TRANSACTIONS
(
	  VIOLATOR_ID, RETAIL_TRANS_ID, PAYMENT_TXN_ID, POS_ID
	, INSERT_DATETIME, LAST_UPDATE_DATE
)
SELECT    DISTINCT
		  A.VIOLATOR_ID, A.RETAIL_TRANS_ID, A.PAYMENT_TXN_ID, A.POS_ID
		, A.LAST_UPDATE_DATE, A.LAST_UPDATE_DATE
FROM dbo.RETAIL_TRANSACTIONS_STAGE A
LEFT JOIN dbo.RETAIL_TRANSACTIONS B 
	ON		A.VIOLATOR_ID = B.VIOLATOR_ID 
		AND A.PAYMENT_TXN_ID = B.PAYMENT_TXN_ID 
		AND A.RETAIL_TRANS_ID = B.RETAIL_TRANS_ID 
WHERE B.VIOLATOR_ID IS NULL AND B.PAYMENT_TXN_ID IS NULL AND B.RETAIL_TRANS_ID IS NULL
OPTION (LABEL = 'RETAIL_TRANSACTIONS_LOAD: INSERT RETAIL_TRANSACTIONS');		

*/

