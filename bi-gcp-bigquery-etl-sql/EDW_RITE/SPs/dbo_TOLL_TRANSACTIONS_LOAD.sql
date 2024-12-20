CREATE PROC [DBO].[TOLL_TRANSACTIONS_LOAD] AS

-- EXEC EDW_RITE.DBO.TOLL_TRANSACTIONS_LOAD
/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.TOLL_TRANSACTIONS_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.TOLL_TRANSACTIONS_LOAD
GO

*/

/*	
SELECT TOP 100 * FROM TOLL_TRANSACTIONS 
SELECT COUNT_BIG(1) FROM TOLL_TRANSACTIONS -- 7 637 667 127
*/  

/*

INSERT INTO dbo.TOLL_TRANSACTIONS
	(	 	  
	TTXN_ID, AMOUNT, TRANSACTION_DATE, TRANSACTION_TIME_ID, CREDITED_FLAG, DATE_CREDITED, DATE_CREDITED_TIME_ID, ACCT_ID, AGENCY_ID, LANE_ID, VEHICLE_CLASS_CODE, TAG_ID, POSTED_DATE, POSTED_TIME_ID,
	TRANSACTION_FILE_DETAIL_ID, SOURCE_CODE, SOURCE_TRXN_ID, IS_ACCOUNT_ACTIVE, TRANS_TYPE_ID, LAST_UPDATE_TYPE, LAST_UPDATE_DATE	)
	VALUES
	(-1,0,NULL,NULL,'',NULL,NULL,-1,'-1',-1,'0','-1',NULL,NULL,-1,'',-1,0,-1,'I','2000-01-01')

*/

DECLARE @LAST_UPDATE_DATE datetime2(2) 
EXEC dbo.GetLoadStartDatetime 'dbo.TOLL_TRANSACTIONS', @LAST_UPDATE_DATE OUTPUT

--IF (SELECT COUNT_BIG(*) FROM LND_LG_TS.TAG_OWNER.TOLL_TRANSACTIONS) > 3000000000
	--TRUNCATE TABLE dbo.TOLL_TRANSACTIONS
	--BEGIN

	IF OBJECT_ID('dbo.TOLL_TRANSACTIONS_STAGE')>0		DROP TABLE dbo.TOLL_TRANSACTIONS_STAGE		

	CREATE TABLE dbo.TOLL_TRANSACTIONS_STAGE WITH (DISTRIBUTION = HASH([ACCT_ID]))
	AS 
	SELECT  
		  CONVERT(bigint,TT.TTXN_ID) AS TTXN_ID, TT.AMOUNT
		, CONVERT(date,TT.TRANSACTION_DATE,121) AS TRANSACTION_DATE
		, DATEDIFF(SECOND,CAST(TT.TRANSACTION_DATE AS DATE), TT.TRANSACTION_DATE) AS TRANSACTION_TIME_ID
		--, (DATEPART(HH,TT.TRANSACTION_DATE) * 3600) + (DATEPART(mi,TT.TRANSACTION_DATE) * 60) + DATEPART(SS,TT.TRANSACTION_DATE) AS TRANSACTION_TIME_ID
		, TT.CREDITED_FLAG
		, CONVERT(date,TT.DATE_CREDITED,121) AS DATE_CREDITED
		, DATEDIFF(SECOND,CAST(TT.DATE_CREDITED AS DATE), TT.DATE_CREDITED) AS DATE_CREDITED_TIME_ID
		--, (DATEPART(HH,TT.DATE_CREDITED) * 3600) + (DATEPART(mi,TT.DATE_CREDITED) * 60) + DATEPART(SS,TT.DATE_CREDITED) AS DATE_CREDITED_TIME_ID
		, convert(bigint,TT.ACCT_ID) AS ACCT_ID
		, AGENCY_ID
		, TT.LANE_ID
		, ISNULL(TT.VEHICLE_CLASS_CODE,'-1') AS VEHICLE_CLASS_CODE
		, TT.TAG_ID
		, CONVERT(date,TT.POSTED_DATE,121) AS POSTED_DATE
		, DATEDIFF(SECOND,CAST(TT.POSTED_DATE AS DATE), TT.POSTED_DATE) AS POSTED_TIME_ID
		--, (DATEPART(HH,TT.POSTED_DATE) * 3600) + (DATEPART(mi,TT.POSTED_DATE) * 60) + DATEPART(SS,TT.POSTED_DATE) AS POSTED_TIME_ID
		, TT.TRANSACTION_FILE_DETAIL_ID
		, TT.SOURCE_CODE
		, TT.SOURCE_TRXN_ID 
		, 0 AS IS_ACCOUNT_ACTIVE 
		, TT.TRANS_TYPE_ID
		, TT.LAST_UPDATE_TYPE
		, TT.LAST_UPDATE_DATE  
		--SELECT COUNT_BIG(1)
	FROM LND_LG_TS.TAG_OWNER.TOLL_TRANSACTIONS TT
	WHERE TT.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE


IF OBJECT_ID('dbo.TOLL_TRANSACTIONS_NEW_STAGE')>0 	DROP TABLE dbo.TOLL_TRANSACTIONS_NEW_STAGE

CREATE TABLE dbo.TOLL_TRANSACTIONS_NEW_STAGE WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TTXN_ID)) AS    
SELECT	
	TTXN_ID, AMOUNT, TRANSACTION_DATE, TRANSACTION_TIME_ID, CREDITED_FLAG, DATE_CREDITED, DATE_CREDITED_TIME_ID, ACCT_ID, AGENCY_ID, LANE_ID, VEHICLE_CLASS_CODE, TAG_ID, POSTED_DATE, POSTED_TIME_ID,
	TRANSACTION_FILE_DETAIL_ID, SOURCE_CODE, SOURCE_TRXN_ID, IS_ACCOUNT_ACTIVE, TRANS_TYPE_ID, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
FROM dbo.TOLL_TRANSACTIONS AS F 
WHERE	NOT EXISTS (SELECT 1 FROM dbo.TOLL_TRANSACTIONS_STAGE AS N WHERE N.ACCT_ID = F.ACCT_ID AND N.TTXN_ID = F.TTXN_ID) 

  UNION ALL 
  
SELECT	
	TTXN_ID, AMOUNT, TRANSACTION_DATE, TRANSACTION_TIME_ID, CREDITED_FLAG, DATE_CREDITED, DATE_CREDITED_TIME_ID, ACCT_ID, AGENCY_ID, LANE_ID, VEHICLE_CLASS_CODE, TAG_ID, POSTED_DATE, POSTED_TIME_ID,
	TRANSACTION_FILE_DETAIL_ID, SOURCE_CODE, SOURCE_TRXN_ID, IS_ACCOUNT_ACTIVE, TRANS_TYPE_ID, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
FROM dbo.TOLL_TRANSACTIONS_STAGE N
OPTION (LABEL = 'TOLL_TRANSACTIONS_LOAD: INSERT/UPDATE');

CREATE STATISTICS [STATS_TOLL_TRANSACTIONS_001] ON dbo.TOLL_TRANSACTIONS_NEW_STAGE ([ACCT_ID], [TTXN_ID]);
CREATE STATISTICS [STATS_TOLL_TRANSACTIONS_002] ON dbo.TOLL_TRANSACTIONS_NEW_STAGE ([TTXN_ID]);
CREATE STATISTICS [STATS_TOLL_TRANSACTIONS_003] ON dbo.TOLL_TRANSACTIONS_NEW_STAGE ([LAST_UPDATE_DATE]);
CREATE STATISTICS [STATS_TOLL_TRANSACTIONS_004] ON dbo.TOLL_TRANSACTIONS_NEW_STAGE (SOURCE_TRXN_ID);
CREATE STATISTICS [STATS_TOLL_TRANSACTIONS_005] ON dbo.TOLL_TRANSACTIONS_NEW_STAGE (SOURCE_CODE);
CREATE STATISTICS [STATS_TOLL_TRANSACTIONS_006] ON dbo.TOLL_TRANSACTIONS_NEW_STAGE (TRANSACTION_FILE_DETAIL_ID);


--STEP #2: Replace OLD table with NEW
IF OBJECT_ID('dbo.TOLL_TRANSACTIONS_OLD')>0 	DROP TABLE dbo.TOLL_TRANSACTIONS_OLD;
IF OBJECT_ID('dbo.TOLL_TRANSACTIONS')>0		RENAME OBJECT::dbo.TOLL_TRANSACTIONS TO TOLL_TRANSACTIONS_OLD;
RENAME OBJECT::dbo.TOLL_TRANSACTIONS_NEW_STAGE TO TOLL_TRANSACTIONS;
IF OBJECT_ID('dbo.TOLL_TRANSACTIONS_OLD')>0 	DROP TABLE dbo.TOLL_TRANSACTIONS_OLD;


IF OBJECT_ID('dbo.TOLL_TRANSACTIONS_STAGE')>0 	DROP TABLE dbo.TOLL_TRANSACTIONS_STAGE

/*
--GetUpdateFields 'dbo','TOLL_TRANSACTIONS'

UPDATE dbo.TOLL_TRANSACTIONS 
SET 
	  dbo.TOLL_TRANSACTIONS.AMOUNT = B.AMOUNT
	, dbo.TOLL_TRANSACTIONS.TRANSACTION_DATE = B.TRANSACTION_DATE
	, dbo.TOLL_TRANSACTIONS.TRANSACTION_TIME_ID = B.TRANSACTION_TIME_ID
	, dbo.TOLL_TRANSACTIONS.CREDITED_FLAG = B.CREDITED_FLAG
	, dbo.TOLL_TRANSACTIONS.DATE_CREDITED = B.DATE_CREDITED
	, dbo.TOLL_TRANSACTIONS.DATE_CREDITED_TIME_ID = B.DATE_CREDITED_TIME_ID
	, dbo.TOLL_TRANSACTIONS.LANE_ID = B.LANE_ID
	, dbo.TOLL_TRANSACTIONS.VEHICLE_CLASS_CODE = B.VEHICLE_CLASS_CODE
	, dbo.TOLL_TRANSACTIONS.TAG_ID = B.TAG_ID
	, dbo.TOLL_TRANSACTIONS.POSTED_DATE = B.POSTED_DATE
	, dbo.TOLL_TRANSACTIONS.POSTED_TIME_ID = B.POSTED_TIME_ID
	, dbo.TOLL_TRANSACTIONS.TRANSACTION_FILE_DETAIL_ID = B.TRANSACTION_FILE_DETAIL_ID
	, dbo.TOLL_TRANSACTIONS.SOURCE_CODE = B.SOURCE_CODE
	, dbo.TOLL_TRANSACTIONS.SOURCE_TRXN_ID = B.SOURCE_TRXN_ID
	, dbo.TOLL_TRANSACTIONS.IS_ACCOUNT_ACTIVE = B.IS_ACCOUNT_ACTIVE
	, dbo.TOLL_TRANSACTIONS.TRANS_TYPE_ID = B.TRANS_TYPE_ID
	, dbo.TOLL_TRANSACTIONS.LAST_UPDATE_DATE = B.LAST_UPDATE_DATE

FROM dbo.TOLL_TRANSACTIONS_UPDATES_STAGE B
WHERE dbo.TOLL_TRANSACTIONS.ACCT_ID = B.ACCT_ID AND dbo.TOLL_TRANSACTIONS.TTXN_ID = B.TTXN_ID
	--AND 
	--(
	--		dbo.TOLL_TRANSACTIONS.AMOUNT <> B.AMOUNT
	--	OR dbo.TOLL_TRANSACTIONS.TRANSACTION_DATE <> B.TRANSACTION_DATE
	--	OR dbo.TOLL_TRANSACTIONS.TRANSACTION_TIME_ID <> B.TRANSACTION_TIME_ID
	--	OR dbo.TOLL_TRANSACTIONS.CREDITED_FLAG <> B.CREDITED_FLAG
	--	OR dbo.TOLL_TRANSACTIONS.DATE_CREDITED <> B.DATE_CREDITED
	--	OR dbo.TOLL_TRANSACTIONS.LANE_ID <> B.LANE_ID
	--	OR dbo.TOLL_TRANSACTIONS.VEHICLE_CLASS_CODE <> B.VEHICLE_CLASS_CODE
	--	OR dbo.TOLL_TRANSACTIONS.TAG_ID <> B.TAG_ID
	--	OR dbo.TOLL_TRANSACTIONS.POSTED_DATE <> B.POSTED_DATE
	--	OR dbo.TOLL_TRANSACTIONS.POSTED_TIME_ID <> B.POSTED_TIME_ID
	--	OR dbo.TOLL_TRANSACTIONS.TRANSACTION_FILE_DETAIL_ID <> B.TRANSACTION_FILE_DETAIL_ID
	--	OR dbo.TOLL_TRANSACTIONS.SOURCE_CODE <> B.SOURCE_CODE
	--	OR dbo.TOLL_TRANSACTIONS.SOURCE_TRXN_ID <> B.SOURCE_TRXN_ID
	--	OR dbo.TOLL_TRANSACTIONS.IS_ACCOUNT_ACTIVE <> B.IS_ACCOUNT_ACTIVE
	--	OR dbo.TOLL_TRANSACTIONS.SUBSCRIBER_UNIQUE_ID <> B.SUBSCRIBER_UNIQUE_ID
	--	OR dbo.TOLL_TRANSACTIONS.RECEIVED_DATE <> B.RECEIVED_DATE
	--	OR dbo.TOLL_TRANSACTIONS.RECEIVED_DATE_TIME_ID <> B.RECEIVED_DATE_TIME_ID
	--	OR dbo.TOLL_TRANSACTIONS.IS_RETAIL_TRANSACTION_CREDIT <> B.IS_RETAIL_TRANSACTION_CREDIT
	--	OR dbo.TOLL_TRANSACTIONS.LAST_UPDATE_DATE <> B.LAST_UPDATE_DATE
	--)
--	AND B.LAST_UPDATE_TYPE = 'U'

*/

---- GetFields3 'TOLL_TRANSACTIONS_STAGE'	

--INSERT INTO [DBO].[TOLL_TRANSACTIONS]
--		( TTXN_ID, AMOUNT
--		, TRANSACTION_DATE
--		, TRANSACTION_TIME_ID
--		, CREDITED_FLAG
--		, DATE_CREDITED
--		, DATE_CREDITED_TIME_ID
--		, ACCT_ID
--		, AGENCY_ID
--		, LANE_ID
--		, VEHICLE_CLASS_CODE
--		, TAG_ID
--		, POSTED_DATE
--		, POSTED_TIME_ID
--		, TRANSACTION_FILE_DETAIL_ID
--		, SOURCE_CODE
--		, SOURCE_TRXN_ID
--		, IS_ACCOUNT_ACTIVE
--		, TRANS_TYPE_ID
--		, INSERT_DATE
--		, LAST_UPDATE_DATE
--		)
--CREATE TABLE TOLL_TRANSACTIONS_NEW WITH (CLUSTERED INDEX ( [ACCT_ID] ASC , [TTXN_ID] ASC ), DISTRIBUTION = HASH([ACCT_ID])) AS 
---- EXPLAIN 
--SELECT  
--		  TT.TTXN_ID, TT.AMOUNT
--		, TT.TRANSACTION_DATE
--		, TT.TRANSACTION_TIME_ID
--		, TT.CREDITED_FLAG
--		, TT.DATE_CREDITED
--		, TT.DATE_CREDITED_TIME_ID
--		, TT.ACCT_ID
--		, TT.AGENCY_ID
--		, TT.LANE_ID
--		, TT.VEHICLE_CLASS_CODE
--		, TT.TAG_ID
--		, TT.POSTED_DATE
--		, TT.POSTED_TIME_ID
--		, TT.TRANSACTION_FILE_DETAIL_ID
--		, TT.SOURCE_CODE
--		, TT.SOURCE_TRXN_ID
--		, 0 AS IS_ACCOUNT_ACTIVE 
--		, TT.TRANS_TYPE_ID
--		, TT.LAST_UPDATE_DATE AS INSERT_DATE
--		, TT.LAST_UPDATE_DATE
--	FROM dbo.TOLL_TRANSACTIONS_UPDATES_STAGE TT
--	--LEFT JOIN dbo.TOLL_TRANSACTIONS B ON TT.ACCT_ID = B.ACCT_ID AND TT.TTXN_ID = B.TTXN_ID
--	--WHERE  B.ACCT_ID IS NULL AND B.TTXN_ID IS NULL
	
--	IF OBJECT_ID('dbo.TOLL_TRANSACTIONS')>0		RENAME OBJECT::dbo.TOLL_TRANSACTIONS TO TOLL_TRANSACTIONS_OLD;

--	IF OBJECT_ID('dbo.TOLL_TRANSACTIONS_NEW')>0		RENAME OBJECT::dbo.TOLL_TRANSACTIONS_NEW TO TOLL_TRANSACTIONS;

--	IF OBJECT_ID('dbo.TOLL_TRANSACTIONS_OLD')>0	 DROP TABLE TOLL_TRANSACTIONS_OLD;

--END
