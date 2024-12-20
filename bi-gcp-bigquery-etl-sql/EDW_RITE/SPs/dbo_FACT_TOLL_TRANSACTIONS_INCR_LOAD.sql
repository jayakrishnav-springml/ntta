CREATE PROC [DBO].[FACT_TOLL_TRANSACTIONS_INCR_LOAD] AS 

--#1	Shankar Metla	2018-09-08	CREATED
--#2	Andy Filipps	2018-10-02	Full rewrite for a new approach to avoid full month load
--#3	Andy Filipps	2019-04-25	Some changes in query, added check rownomber with source table
--#4	Andy Filipps	2019-12-12	Changes to remove all fields > 8 bytes, removed LIC_PLATE, added TT_ID, Statistics changed

/*
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.FACT_TOLL_TRANSACTIONS_INCR_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.FACT_TOLL_TRANSACTIONS_INCR_LOAD
GO


EXEC dbo.FACT_TOLL_TRANSACTIONS_INCR_LOAD


SELECT COUNT_BIG(1) FROM dbo.FACT_TOLL_TRANSACTIONS  -- 8005552712
SELECT COUNT_BIG(1) FROM LND_LG_TS.TAG_OWNER.TOLL_TRANSACTIONS  -- 8007234420

SELECT TOP 100 * dbo.FROM FACT_TOLL_TRANSACTIONS 

SELECT  TOP 100
	DAY_ID,TT_ID,TXN_DATE,ENTRY_TXN_DATE,POSTED_DATE,DISPOSITION,RECON_HOME_AGENCY_ID,TAG_AGENCY_ID,AGENCY_CODE,HIA_AGCY_ID,SOURCE_CODE,SOURCE_TXN_ID,LANE_ID,TVL_TAG_STATUS,
	LIC_PLATE_STATE,LICENSE_PLATE_ID,EARNED_CLASS,POSTED_CLASS,EARNED_REVENUE,POSTED_REVENUE,TRANSACTION_FILE_DETAIL_ID,LAST_UPDATE_TYPE,LAST_UPDATE_DATE
FROM dbo.FACT_TOLL_TRANSACTIONS

SELECT * FROM edw_rite.dbo.PROCESS_LOG 
WHERE LOG_SOURCE = 'FACT_TOLL_TRANSACTIONS' AND LOG_DATE > '2019-09-01 8:00:00'
ORDER BY LOG_SOURCE, LOG_DATE

*/


DECLARE @TABLE_NAME VARCHAR(100) = 'FACT_TOLL_TRANSACTIONS', @LOG_START_DATE DATETIME2 (2), @LOG_MESSAGE VARCHAR(1000), @ROW_COUNT BIGINT, @LOAD_CONTROL_DATE DATETIME2(2) 
DECLARE @sql VARCHAR(MAX)

-- STEP 1: Get the next Load Control Date from the Control Table
SET @LOG_START_DATE = GETDATE()


DECLARE @FULL_RELOAD BIT  
SELECT @FULL_RELOAD = CASE WHEN C.column_id IS NULL THEN 1 ELSE 0 END FROM sys.tables t LEFT JOIN sys.columns c ON c.object_id = t.object_id AND c.name = 'TT_ID' WHERE t.name = @TABLE_NAME

IF @FULL_RELOAD = 1 
BEGIN

	DECLARE @PART_RANGES VARCHAR(MAX) = ''
	--EXEC DBO.GET_PARTITION_MONTH_RANGE_STRING @PART_RANGES OUTPUT
	EXEC DBO.GET_PARTITION_DAYID_RANGE_STRING @PART_RANGES OUTPUT
	--PRINT @PART_RANGES
	IF OBJECT_ID('dbo.FACT_TOLL_TRANSACTIONS_NEW_SET') IS NOT NULL DROP TABLE dbo.FACT_TOLL_TRANSACTIONS_NEW_SET

	SET @sql = '
	CREATE TABLE dbo.[FACT_TOLL_TRANSACTIONS_NEW_SET] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([TTXN_ID]), PARTITION (DAY_ID RANGE RIGHT FOR VALUES (' + @PART_RANGES + '))) AS
	SELECT 
			 CAST(main_table.[DAY_ID] AS int) AS [DAY_ID]
			, main_table.[DAY_ID] / 100 AS MONTH_ID
			, ISNULL(CAST(main_table.[TTXN_ID] AS bigint),-1) AS [TTXN_ID]
			, ISNULL(CAST(main_table.[AMOUNT] AS decimal(6,2)), 0) AS [AMOUNT]
			, ISNULL(CAST(main_table.[TRANSACTION_DATE] AS datetime2(0)), ''1900-01-01'') AS [TRANSACTION_DATE]
			, CAST(main_table.[TRANSACTION_TIME_ID] AS int) AS [TRANSACTION_TIME_ID]
			, CAST(main_table.[CREDITED_FLAG] AS varchar(1)) AS [CREDITED_FLAG]
			, CAST(main_table.[DATE_CREDITED] AS date) AS [DATE_CREDITED]
			, CAST(main_table.[DATE_CREDITED_TIME_ID] AS int) AS [DATE_CREDITED_TIME_ID]
			, CAST(main_table.[ACCT_ID] AS bigint) AS [ACCT_ID]
			, ISNULL(CAST(main_table.[AGENCY_ID] AS varchar(6)), '''') AS [AGENCY_ID]
			, ISNULL(CAST(main_table.[LANE_ID] AS int), 0) AS [LANE_ID]
			, ISNULL(CAST(main_table.[VEHICLE_CLASS_CODE] AS varchar(1)), '''') AS [VEHICLE_CLASS_CODE]
			, ISNULL(CAST(main_table.[TAG_ID] AS varchar(12)), '''') AS [TAG_ID]
			, ATT.[TT_ID] AS [TT_ID]
			, CAST(main_table.[LICENSE_PLATE_ID] AS int) AS [LICENSE_PLATE_ID]
			, CAST(main_table.[LIC_PLATE] AS varchar(15)) AS [LIC_PLATE]
			, CAST(main_table.[LIC_STATE] AS varchar(3)) AS [LIC_STATE]
			, CAST(main_table.[POSTED_DATE] AS date) AS [POSTED_DATE]
			, CAST(main_table.[POSTED_TIME_ID] AS int) AS [POSTED_TIME_ID]
			, CAST(main_table.[TRANSACTION_FILE_DETAIL_ID] AS decimal(14,0)) AS [TRANSACTION_FILE_DETAIL_ID]
			, ISNULL(CAST(main_table.[SOURCE_CODE] AS varchar(1)), '''') AS [SOURCE_CODE]
			, ISNULL(CAST(main_table.[SOURCE_TRXN_ID] AS decimal(15,0)), 0) AS [SOURCE_TRXN_ID]
			, CAST(main_table.[TRANS_TYPE_ID] AS decimal(10,0)) AS [TRANS_TYPE_ID]
			, CAST(main_table.[LAST_UPDATE_TYPE] AS varchar(1)) AS [LAST_UPDATE_TYPE]
			, CAST(main_table.[LAST_UPDATE_DATE] AS datetime2(2)) AS [LAST_UPDATE_DATE]
	FROM dbo.[FACT_TOLL_TRANSACTIONS] AS main_table
	LEFT JOIN dbo.TOLL_TAGS ATT ON ATT.TAG_ID = main_table.TAG_ID AND ATT.AGENCY_ID = main_table.AGENCY_ID
	OPTION (LABEL = ''FACT_TOLL_TRANSACTIONS_NEW_SET LOAD'');'

	--EXEC DBO.GET_CREATE_TABLE_AS_SQL @TABLE_NAME, @sql OUTPUT
	--SET @sql = REPLACE(@sql,', CAST(main_table.[LIC_PLATE] AS varchar(15)) AS [LIC_PLATE]', '')
	--SET @sql = REPLACE(@sql,'ISNULL(CAST(main_table.[TAG_ID] AS varchar(12)), '') AS [TAG_ID]', 'ATT.[TT_ID] AS [TT_ID]')
	--SET @sql = REPLACE(@sql,'WHERE 1 = 1','LEFT JOIN dbo.TOLL_TAGS ATT ON ATT.TAG_ID = main_table.TAG_ID')

	EXEC (@sql)
	--EXEC dbo.PRINT_LONG_VARIABLE_VALUE @SQL_STRING
	EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT

	CREATE STATISTICS [STATS_FACT_TOLL_TRANSACTIONS_001] ON dbo.[FACT_TOLL_TRANSACTIONS_NEW_SET] ([DAY_ID],[SOURCE_CODE]);
	CREATE STATISTICS [STATS_FACT_TOLL_TRANSACTIONS_002] ON dbo.[FACT_TOLL_TRANSACTIONS_NEW_SET] ([TTXN_ID]);
	CREATE STATISTICS [STATS_FACT_TOLL_TRANSACTIONS_003] ON dbo.[FACT_TOLL_TRANSACTIONS_NEW_SET] ([TRANSACTION_FILE_DETAIL_ID]);
	CREATE STATISTICS [STATS_FACT_TOLL_TRANSACTIONS_004] ON dbo.[FACT_TOLL_TRANSACTIONS_NEW_SET] ([LANE_ID]);
	CREATE STATISTICS [STATS_FACT_TOLL_TRANSACTIONS_005] ON dbo.[FACT_TOLL_TRANSACTIONS_NEW_SET] (LICENSE_PLATE_ID);
	CREATE STATISTICS [STATS_FACT_TOLL_TRANSACTIONS_006] ON dbo.[FACT_TOLL_TRANSACTIONS_NEW_SET] ([SOURCE_CODE],CREDITED_FLAG);
	CREATE STATISTICS [STATS_FACT_TOLL_TRANSACTIONS_007] ON dbo.[FACT_TOLL_TRANSACTIONS_NEW_SET] ([ACCT_ID], [TT_ID]);
	CREATE STATISTICS [STATS_FACT_TOLL_TRANSACTIONS_008] ON dbo.[FACT_TOLL_TRANSACTIONS_NEW_SET] ([SOURCE_TRXN_ID]);
	CREATE STATISTICS [STATS_FACT_TOLL_TRANSACTIONS_009] ON dbo.[FACT_TOLL_TRANSACTIONS_NEW_SET] (CREDITED_FLAG,DATE_CREDITED);
	CREATE STATISTICS [STATS_FACT_TOLL_TRANSACTIONS_010] ON dbo.[FACT_TOLL_TRANSACTIONS_NEW_SET] (MONTH_ID,DAY_ID,SOURCE_TRXN_ID);


	SET @sql = '
	IF OBJECT_ID(''dbo.[' + @TABLE_NAME + '_PREV]'') IS NOT NULL	DROP TABLE dbo.[' + @TABLE_NAME + '_PREV];
	IF OBJECT_ID(''dbo.[' + @TABLE_NAME + ']'') IS NOT NULL			RENAME OBJECT::dbo.[' + @TABLE_NAME + '] TO [' + @TABLE_NAME + '_PREV];
	IF OBJECT_ID(''dbo.[' + @TABLE_NAME + '_NEW_SET]'') IS NOT NULL	RENAME OBJECT::dbo.[' + @TABLE_NAME + '_NEW_SET] TO [' + @TABLE_NAME + '];'
	EXEC (@sql)
	--EXEC dbo.PRINT_LONG_VARIABLE_VALUE @SQL_STRING

	SET  @LOG_MESSAGE = 'Complete Full reload of the Table with a new column <<TT_ID>>'
	EXEC dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, @ROW_COUNT

END


SELECT @LOAD_CONTROL_DATE = DATEADD(DAY, - 10, MAX(LAST_UPDATE_DATE)) FROM  dbo.FACT_TOLL_TRANSACTIONS --LND_LG_TS.TAG_OWNER.TOLL_TRANSACTIONS

IF @LOAD_CONTROL_DATE IS NULL 
BEGIN
	SET @LOAD_CONTROL_DATE = '1990-01-01' -- CAST(LEFT(CONVERT(VARCHAR(8), @LOG_START_DATE, 112), 6) + '01' AS DATETIME2(2)) 
END

---- !!!!!!!!!!!!!!!!!!!!! TESTING ONLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--SET @LOAD_CONTROL_DATE = CAST('2018-09-01 00:00:00.00' AS DATETIME2(2)) 
---- !!!!!!!!!!!!!!!!!!!!! TESTING ONLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

--PRINT @LOAD_CONTROL_DATE

-- STEP 2: Initiate LOG
SELECT  @LOG_MESSAGE = 'Started to load updates from ' + CONVERT(VARCHAR(19),@LOAD_CONTROL_DATE,121)
EXEC    dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE,  NULL

-- STEP 3: Get maximum Partition and it's baundry value
--EXEC DBO.PARTITION_MANAGE_MONTHLY_LOAD @TABLE_NAME

--STEP #7: -- Getting all changes to a new table
IF OBJECT_ID('dbo.FACT_TOLL_TRANSACTIONS_NEW_SET') IS NOT NULL DROP TABLE dbo.FACT_TOLL_TRANSACTIONS_NEW_SET

CREATE TABLE dbo.FACT_TOLL_TRANSACTIONS_NEW_SET WITH (CLUSTERED INDEX (TTXN_ID), DISTRIBUTION = HASH(TTXN_ID)) AS
WITH CTE_TRANSACTIONS AS
(
	SELECT  
		CAST(CONVERT(VARCHAR, TT.TRANSACTION_DATE, 112) AS INT) DAY_ID
		, ISNULL(CONVERT(bigint,TT.TTXN_ID),-1) AS TTXN_ID
		, TT.AMOUNT
		, TT.TRANSACTION_DATE AS TRANSACTION_DATE
		, DATEDIFF(SECOND,CAST(TT.TRANSACTION_DATE AS DATE), TT.TRANSACTION_DATE) AS TRANSACTION_TIME_ID
		, TT.CREDITED_FLAG
		, CONVERT(date,TT.DATE_CREDITED,121) AS DATE_CREDITED
		, DATEDIFF(SECOND,CAST(TT.DATE_CREDITED AS DATE), TT.DATE_CREDITED) AS DATE_CREDITED_TIME_ID
		, convert(bigint,TT.ACCT_ID) AS ACCT_ID
		, TT.AGENCY_ID
		, TT.LANE_ID
		, ISNULL(TT.VEHICLE_CLASS_CODE,'-1') AS VEHICLE_CLASS_CODE
		, TT.TAG_ID
		, COALESCE(AH.LIC_PLATE,ATH.LIC_PLATE,'-1') AS LIC_PLATE
		, COALESCE(AH.LIC_STATE,ATH.LIC_STATE,'-1') AS LIC_STATE
		, CONVERT(date,TT.POSTED_DATE,121) AS POSTED_DATE
		, DATEDIFF(SECOND,CAST(TT.POSTED_DATE AS DATE), TT.POSTED_DATE) AS POSTED_TIME_ID
		, TT.TRANSACTION_FILE_DETAIL_ID
		, TT.SOURCE_CODE
		, TT.SOURCE_TRXN_ID 
		, TT.TRANS_TYPE_ID
		, TT.LAST_UPDATE_TYPE
		, TT.LAST_UPDATE_DATE
		, ROW_NUMBER() OVER (PARTITION BY TT.TTXN_ID, TT.ACCT_ID,TT.TAG_ID,TT.TRANSACTION_DATE ORDER BY AH.TAG_HISTORY_SEQ DESC, AH.ASSIGNED_DATE DESC, ATH.ASSIGNED_DATE ASC) AS ROW_NUM
		--SELECT COUNT_BIG(*)
	FROM (SELECT * FROM LND_LG_TS.TAG_OWNER.TOLL_TRANSACTIONS WHERE LAST_UPDATE_DATE >= @LOAD_CONTROL_DATE) AS TT  
	LEFT JOIN LND_LG_TS.TAG_OWNER.ACCOUNT_TAG_HISTORY AS AH ON AH.ACCT_ID = TT.ACCT_ID AND AH.TAG_ID = TT.TAG_ID 
		AND TT.TRANSACTION_DATE BETWEEN ISNULL(AH.ASSIGNED_DATE,'9999-12-31') AND ISNULL(AH.EXPIRED_DATE,'9999-12-31')
	LEFT JOIN LND_LG_TS.TAG_OWNER.ACCOUNT_TAG_HISTORY AS ATH ON ATH.ACCT_ID = TT.ACCT_ID AND ATH.TAG_ID = TT.TAG_ID
		AND TT.TRANSACTION_DATE < ATH.ASSIGNED_DATE AND TT.TRANSACTION_DATE < ISNULL(ATH.EXPIRED_DATE,'9999-12-31')
)
SELECT 
	DAY_ID,DAY_ID/100 AS MONTH_ID,TTXN_ID,AMOUNT,TRANSACTION_DATE,TRANSACTION_TIME_ID,CREDITED_FLAG,DATE_CREDITED,DATE_CREDITED_TIME_ID,ACCT_ID,TT.AGENCY_ID,LANE_ID,VEHICLE_CLASS_CODE, ATT.TT_ID, TT.TAG_ID,
	LP.LICENSE_PLATE_ID,LIC_PLATE,LIC_STATE,POSTED_DATE,POSTED_TIME_ID,TRANSACTION_FILE_DETAIL_ID,SOURCE_CODE,SOURCE_TRXN_ID ,TRANS_TYPE_ID,TT.LAST_UPDATE_TYPE,TT.LAST_UPDATE_DATE
FROM CTE_TRANSACTIONS AS TT
LEFT JOIN dbo.DIM_LICENSE_PLATE AS LP ON TT.LIC_PLATE = LP.LICENSE_PLATE_NBR AND TT.LIC_STATE = LP.LICENSE_PLATE_STATE
LEFT JOIN dbo.TOLL_TAGS ATT ON ATT.TAG_ID = TT.TAG_ID AND ATT.AGENCY_ID = TT.AGENCY_ID
WHERE ROW_NUM = 1
OPTION (LABEL = 'FACT_TOLL_TRANSACTIONS LOAD');

-- Logging
EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
SET  @LOG_MESSAGE = 'Got all changed rows:'
EXEC dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, @ROW_COUNT


DECLARE @IDENTITY_COLUMNS VARCHAR(8000) = '[TTXN_ID]'

EXEC DBO.PARTITION_SWITCH_MONTHLY_LOAD @TABLE_NAME,	@IDENTITY_COLUMNS
--EXEC DBO.PARTITION_SWITCH_NUMBER_BASED_LOAD @TABLE_NAME,	@IDENTITY_COLUMNS

UPDATE STATISTICS [dbo].FACT_TOLL_TRANSACTIONS  

IF OBJECT_ID('dbo.FACT_TOLL_TRANSACTIONS_NEW_SET') IS NOT NULL DROP TABLE dbo.FACT_TOLL_TRANSACTIONS_NEW_SET

/*
DECLARE @CNT_EDW_RITE BIGINT
DECLARE @CNT_LND_LG_TS BIGINT

SELECT @CNT_EDW_RITE = COUNT_BIG(1) FROM FACT_TOLL_TRANSACTIONS 
SELECT @CNT_LND_LG_TS = COUNT_BIG(1) FROM LND_LG_TS.TAG_OWNER.TOLL_TRANSACTIONS

IF @CNT_EDW_RITE < @CNT_LND_LG_TS
BEGIN
	SET @ROW_COUNT = @CNT_LND_LG_TS - @CNT_EDW_RITE
	SET @LOG_MESSAGE = 'FOUND missed rows. Starting to returning them.'
	EXEC dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, @ROW_COUNT

	IF OBJECT_ID('dbo.FACT_TOLL_TRANSACTIONS_LOST_ROWS') IS NOT NULL DROP TABLE dbo.FACT_TOLL_TRANSACTIONS_LOST_ROWS
	CREATE TABLE dbo.FACT_TOLL_TRANSACTIONS_LOST_ROWS WITH (HEAP, DISTRIBUTION = HASH(TTXN_ID)) AS
	SELECT TTXN_ID FROM LND_LG_TS.TAG_OWNER.TOLL_TRANSACTIONS
	EXCEPT
	SELECT TTXN_ID FROM dbo.FACT_TOLL_TRANSACTIONS

	IF OBJECT_ID('dbo.FACT_TOLL_TRANSACTIONS_MISSED_SET') IS NOT NULL DROP TABLE dbo.FACT_TOLL_TRANSACTIONS_MISSED_SET
	CREATE TABLE dbo.FACT_TOLL_TRANSACTIONS_MISSED_SET WITH (HEAP, DISTRIBUTION = HASH(TTXN_ID)) AS
	WITH CTE_TRANSACTIONS AS
	(
		SELECT  
			CAST(CONVERT(VARCHAR, TT.TRANSACTION_DATE, 112) AS INT) DAY_ID
			, CONVERT(bigint,TT.TTXN_ID) AS TTXN_ID, TT.AMOUNT
			, TT.TRANSACTION_DATE AS TRANSACTION_DATE
			, DATEDIFF(SECOND,CAST(TT.TRANSACTION_DATE AS DATE), TT.TRANSACTION_DATE) AS TRANSACTION_TIME_ID
			, TT.CREDITED_FLAG
			, CONVERT(date,TT.DATE_CREDITED,121) AS DATE_CREDITED
			, DATEDIFF(SECOND,CAST(TT.DATE_CREDITED AS DATE), TT.DATE_CREDITED) AS DATE_CREDITED_TIME_ID
			, convert(bigint,TT.ACCT_ID) AS ACCT_ID
			, TT.AGENCY_ID
			, TT.LANE_ID
			, ISNULL(TT.VEHICLE_CLASS_CODE,'-1') AS VEHICLE_CLASS_CODE
			, TT.TAG_ID
			, COALESCE(AH.LIC_PLATE,ATH.LIC_PLATE,'-1') AS LIC_PLATE
			, COALESCE(AH.LIC_STATE,ATH.LIC_STATE,'-1') AS LIC_STATE
			, ROW_NUMBER() OVER (PARTITION BY TT.TTXN_ID, TT.ACCT_ID,TT.TAG_ID,TT.TRANSACTION_DATE ORDER BY AH.TAG_HISTORY_SEQ DESC, AH.ASSIGNED_DATE DESC, ATH.ASSIGNED_DATE ASC) AS ROW_NUM
			, CONVERT(date,TT.POSTED_DATE,121) AS POSTED_DATE
			, DATEDIFF(SECOND,CAST(TT.POSTED_DATE AS DATE), TT.POSTED_DATE) AS POSTED_TIME_ID
			, TT.TRANSACTION_FILE_DETAIL_ID
			, TT.SOURCE_CODE
			, TT.SOURCE_TRXN_ID 
			, TT.TRANS_TYPE_ID
			, TT.LAST_UPDATE_TYPE
			, TT.LAST_UPDATE_DATE --SELECT COUNT_BIG(*)
		FROM (SELECT * FROM LND_LG_TS.TAG_OWNER.TOLL_TRANSACTIONS WHERE TTXN_ID IN (SELECT TTXN_ID FROM dbo.FACT_TOLL_TRANSACTIONS_LOST_ROWS)) AS TT  
			LEFT JOIN LND_LG_TS.TAG_OWNER.ACCOUNT_TAG_HISTORY AS AH ON AH.ACCT_ID = TT.ACCT_ID AND AH.TAG_ID = TT.TAG_ID 
				AND TT.TRANSACTION_DATE BETWEEN ISNULL(AH.ASSIGNED_DATE,'9999-12-31') AND ISNULL(AH.EXPIRED_DATE,'9999-12-31')
			LEFT JOIN LND_LG_TS.TAG_OWNER.ACCOUNT_TAG_HISTORY AS ATH ON ATH.ACCT_ID = TT.ACCT_ID AND ATH.TAG_ID = TT.TAG_ID
				AND TT.TRANSACTION_DATE < ATH.ASSIGNED_DATE AND TT.TRANSACTION_DATE < ISNULL(ATH.EXPIRED_DATE,'9999-12-31')
	)
	SELECT 
		DAY_ID,TTXN_ID,AMOUNT,TRANSACTION_DATE,TRANSACTION_TIME_ID,CREDITED_FLAG,DATE_CREDITED,DATE_CREDITED_TIME_ID,ACCT_ID,AGENCY_ID,LANE_ID,VEHICLE_CLASS_CODE,ATT.TT_ID, --TAG_ID,
		LP.LICENSE_PLATE_ID,/*LIC_PLATE,*/LIC_STATE,POSTED_DATE,POSTED_TIME_ID,TRANSACTION_FILE_DETAIL_ID,SOURCE_CODE,SOURCE_TRXN_ID ,TRANS_TYPE_ID,LAST_UPDATE_TYPE,LAST_UPDATE_DATE
	FROM CTE_TRANSACTIONS AS TT
	LEFT JOIN dbo.DIM_LICENSE_PLATE AS LP ON TT.LIC_PLATE = LP.LICENSE_PLATE_NBR AND TT.LIC_STATE = LP.LICENSE_PLATE_STATE
	LEFT JOIN dbo.TOLL_TAGS ATT ON ATT.TAG_ID = TT.TAG_ID
	WHERE ROW_NUM = 1
	OPTION (LABEL = 'FACT_TOLL_TRANSACTIONS MISSING LOAD');

	-- Logging
	EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
	SET  @LOG_MESSAGE = 'Got all missed rows:'
	EXEC dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, @ROW_COUNT

	INSERT INTO dbo.FACT_TOLL_TRANSACTIONS
	SELECT * FROM dbo.FACT_TOLL_TRANSACTIONS_MISSED_SET

	IF OBJECT_ID('dbo.FACT_TOLL_TRANSACTIONS_LOST_ROWS') IS NOT NULL DROP TABLE dbo.FACT_TOLL_TRANSACTIONS_LOST_ROWS
	IF OBJECT_ID('dbo.FACT_TOLL_TRANSACTIONS_MISSED_SET') IS NOT NULL DROP TABLE dbo.FACT_TOLL_TRANSACTIONS_MISSED_SET
	UPDATE STATISTICS [dbo].FACT_TOLL_TRANSACTIONS  

END

IF @CNT_EDW_RITE > @CNT_LND_LG_TS
BEGIN

	IF OBJECT_ID('dbo.FACT_TOLL_TRANSACTIONS_DUPS') IS NOT NULL DROP TABLE dbo.FACT_TOLL_TRANSACTIONS_DUPS
	CREATE TABLE dbo.FACT_TOLL_TRANSACTIONS_DUPS WITH (HEAP, DISTRIBUTION = HASH(TTXN_ID)) AS --EXPLAIN
	SELECT TTXN_ID from edw_rite.[dbo].[FACT_TOLL_TRANSACTIONS] where day_id > 20150101 group by TTXN_ID having count(*) > 1

	IF OBJECT_ID('dbo.FACT_TOLL_TRANSACTIONS_TO_INSERT') IS NOT NULL DROP TABLE dbo.FACT_TOLL_TRANSACTIONS_TO_INSERT
	CREATE TABLE dbo.FACT_TOLL_TRANSACTIONS_TO_INSERT WITH (HEAP, DISTRIBUTION = HASH(TTXN_ID)) AS --EXPLAIN
	SELECT 
		[DAY_ID],[TTXN_ID],[AMOUNT],[TRANSACTION_DATE],[TRANSACTION_TIME_ID],[CREDITED_FLAG],[DATE_CREDITED],[DATE_CREDITED_TIME_ID],[ACCT_ID],[AGENCY_ID],[LANE_ID],[VEHICLE_CLASS_CODE],[TAG_ID],
		[LICENSE_PLATE_ID],[LIC_PLATE],[LIC_STATE],[POSTED_DATE],[POSTED_TIME_ID],[TRANSACTION_FILE_DETAIL_ID],[SOURCE_CODE],[SOURCE_TRXN_ID],[TRANS_TYPE_ID],[LAST_UPDATE_TYPE],[LAST_UPDATE_DATE]
	FROM (
		SELECT FT.*, 
			ROW_NUMBER() OVER (PARTITION BY TTXN_ID ORDER BY FT.TRANSACTION_DATE DESC) RN
		FROM FACT_TOLL_TRANSACTIONS FT WHERE TTXN_ID IN (SELECT TTXN_ID FROM dbo.FACT_TOLL_TRANSACTIONS_DUPS)
	) A
	WHERE RN = 1

	DELETE 
	FROM FACT_TOLL_TRANSACTIONS
	WHERE TTXN_ID IN (SELECT TTXN_ID FROM dbo.FACT_TOLL_TRANSACTIONS_DUPS)

	INSERT INTO FACT_TOLL_TRANSACTIONS
	SELECT * FROM dbo.FACT_TOLL_TRANSACTIONS_TO_INSERT

	IF OBJECT_ID('dbo.FACT_TOLL_TRANSACTIONS_DUPS') IS NOT NULL DROP TABLE dbo.FACT_TOLL_TRANSACTIONS_DUPS
	IF OBJECT_ID('dbo.FACT_TOLL_TRANSACTIONS_TO_INSERT') IS NOT NULL DROP TABLE dbo.FACT_TOLL_TRANSACTIONS_TO_INSERT
	UPDATE STATISTICS [dbo].FACT_TOLL_TRANSACTIONS  

END
*/

--STEP #13: UPDATE STATISTICS and delete temp tables




