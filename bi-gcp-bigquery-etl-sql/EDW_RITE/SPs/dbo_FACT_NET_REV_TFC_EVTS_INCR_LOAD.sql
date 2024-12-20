CREATE PROC [DBO].[FACT_NET_REV_TFC_EVTS_INCR_LOAD] AS 
/*
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.FACT_NET_REV_TFC_EVTS_INCR_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.FACT_NET_REV_TFC_EVTS_INCR_LOAD
GO

EXEC DBO.FACT_NET_REV_TFC_EVTS_INCR_LOAD

SELECT COUNT_BIG(1) FROM dbo.FACT_NET_REV_TFC_EVTS  -- 

SELECT  TOP 100
	DAY_ID,MONTH_ID,TART_ID,LANE_ID,ATD_ID,OPNM_ID,PMTY_ID,VCLY_ID,TIME_ID,DATE_TIME,Local_Time,EAR_REV,EXP_REV,ACT_REV, 
	ATT_FARE,MISCLASS_CT, SIGN_FLG, ADJ_STATUS, TXID_ID, VES_SERIAL_NO, VES_DATE_TIME,TRANSACTION_FILE_DETAIL_ID, 
	AVI_HANDSHAKE, AVI_TAG_STATUS, VEH_SPEED,DELETED,LAST_UPDATE_DATE 
FROM dbo.FACT_NET_REV_TFC_EVTS


SELECT * FROM edw_rite.dbo.PROCESS_LOG 
WHERE LOG_SOURCE = 'FACT_NET_REV_TFC_EVTS' AND LOG_DATE > '2019-09-01 8:00:00'
ORDER BY LOG_SOURCE, LOG_DATE


*/

/*	SELECT TOP 100 * FROM FACT_NET_REV_TFC_EVTS --SELECT TOP 100 * FROM IOP_TXNS */  
--#1	RANJITH NAIR	2017-11-09	FOUND DUPLICATES DUE TO MULTIPLE SOURCE CODES
--#2    CHRIS SVOCHAK   2018-02-02  CHANGED TO INCREMENTAL PROCESS
--#3    SHANKAR METLA   2018-09-19  ADDED VEH_SPEED
--#4	Andy Filipps	2018-10-02	Full rewrite for a new approach to avoid full month load
--#5	Andy Filipps	2019-12-12	Changes to remove all fields > 8 bytes, Statistics changed

DECLARE @TABLE_NAME VARCHAR(100) = 'FACT_NET_REV_TFC_EVTS', @LOG_START_DATE DATETIME2 (2), @LOG_MESSAGE VARCHAR(1000), @ROW_COUNT BIGINT, @LOAD_CONTROL_DATE DATETIME2(2) 
DECLARE @sql VARCHAR(MAX)

DECLARE @FULL_RELOAD BIT  
--EXEC dbo.GetLoadStartDatetime 'dbo.PAYMENT_LINE_ITEMS_VPS', @LAST_UPDATE_DATE OUTPUT
SELECT @FULL_RELOAD = CASE WHEN C.column_id IS NULL THEN 1 ELSE 0 END FROM sys.tables t LEFT JOIN sys.columns c ON c.object_id = t.object_id AND c.name = 'MONTH_ID' WHERE t.name = @TABLE_NAME

IF @FULL_RELOAD = 1 
BEGIN

	DECLARE @PART_RANGES VARCHAR(MAX) = ''
	--EXEC DBO.GET_PARTITION_MONTH_RANGE_STRING @PART_RANGES OUTPUT
	EXEC DBO.GET_PARTITION_DAYID_RANGE_STRING @PART_RANGES OUTPUT

	--PRINT @PART_RANGES
	IF OBJECT_ID('dbo.FACT_NET_REV_TFC_EVTS_NEW_SET') IS NOT NULL DROP TABLE dbo.FACT_NET_REV_TFC_EVTS_NEW_SET

	SET @sql = '
	CREATE TABLE dbo.[FACT_NET_REV_TFC_EVTS_NEW_SET] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([TART_ID]), PARTITION (DAY_ID RANGE RIGHT FOR VALUES (' + @PART_RANGES + '))) AS
	SELECT 
			CAST(main_table.[DAY_ID] AS int) AS [DAY_ID]
			, main_table.[DAY_ID] / 100 AS MONTH_ID
			, ISNULL(CAST(main_table.[TART_ID] AS BIGINT),-1) AS [TART_ID]
			, CAST(main_table.[LANE_ID] AS INT) AS [LANE_ID]
			, CAST(main_table.[ATD_ID] AS BIGINT) AS [ATD_ID]
			, ISNULL(CAST(main_table.[OPNM_ID] AS SMALLINT), -1) AS [OPNM_ID]
			, ISNULL(CAST(main_table.[PMTY_ID] AS SMALLINT), -1) AS [PMTY_ID]
			, ISNULL(CAST(main_table.[VCLY_ID] AS SMALLINT), -1) AS [VCLY_ID]
			, CAST(main_table.[TIME_ID] AS int) AS [TIME_ID]
			, ISNULL(CAST(main_table.[DATE_TIME] AS datetime2(0)), ''1900-01-01'') AS [DATE_TIME]
			, CAST(main_table.[Local_Time] AS datetime2(0)) AS [Local_Time]
			, CAST(main_table.[EAR_REV] AS decimal(10,2)) AS [EAR_REV]
			, CAST(main_table.[EXP_REV] AS decimal(10,2)) AS [EXP_REV]
			, CAST(main_table.[ACT_REV] AS decimal(10,2)) AS [ACT_REV]
			--, CAST(main_table.[AVIT_EARNED_REVENUE] AS decimal(10,2)) AS [AVIT_EARNED_REVENUE]
			--, CAST(main_table.[AVIT_POSTED_REVENUE] AS decimal(10,2)) AS [AVIT_POSTED_REVENUE]
			--, CAST(ATT.TT_ID AS BIGINT) AS AVIT_TT_ID
			--, CAST(main_table.[IOP_TXNS_EARNED_REVENUE] AS decimal(5,2)) AS [IOP_TXNS_EARNED_REVENUE]
			--, CAST(main_table.[IOP_TXNS_POSTED_REVENUE] AS decimal(5,2)) AS [IOP_TXNS_POSTED_REVENUE]
			--, CAST(ITT.TT_ID AS BIGINT) AS IOP_TT_ID
			, CAST(main_table.[ATT_FARE] AS decimal(6,2)) AS [ATT_FARE]
			, ISNULL(CAST(main_table.[MISCLASS_CT] AS SMALLINT), 0) AS [MISCLASS_CT]
			, ISNULL(CAST(main_table.[SIGN_FLG] AS SMALLINT), 0) AS [SIGN_FLG]
			, ISNULL(CAST(main_table.[ADJ_STATUS] AS varchar(1)), '''') AS [ADJ_STATUS]
			, CAST(main_table.[TXID_ID] AS Int) AS [TXID_ID]
			, CAST(main_table.[VES_SERIAL_NO] AS BIGINT) AS [VES_SERIAL_NO]
			--, CAST(main_table.[VES_DATE_TIME] AS datetime2(0)) AS [VES_DATE_TIME]
			, CAST(T.[VES_DATE_TIME_LOCAL] AS datetime2(0)) AS [VES_DATE_TIME]
			, CAST(main_table.[TRANSACTION_FILE_DETAIL_ID] AS decimal(14,0)) AS [TRANSACTION_FILE_DETAIL_ID]
			--, CAST(main_table.[AVIT_SOURCE_CODE] AS varchar(1)) AS [AVIT_SOURCE_CODE]
			--, CAST(main_table.[AVIT_AGENCY_ID] AS varchar(6)) AS [AVIT_AGENCY_ID]
			--, CAST(main_table.[AVIT_POSTED_DATE] AS datetime2(0)) AS [AVIT_POSTED_DATE]
			--, CAST(main_table.[IOP_TXNS_SOURCE_CODE] AS varchar(1)) AS [IOP_TXNS_SOURCE_CODE]
			--, CAST(main_table.[IOP_TXNS_AGENCY_ID] AS varchar(6)) AS [IOP_TXNS_AGENCY_ID]
			--, CAST(main_table.[IOP_TXNS_POSTED_DATE] AS datetime2(0)) AS [IOP_TXNS_POSTED_DATE]
			, CAST(main_table.[AVI_HANDSHAKE] AS float) AS [AVI_HANDSHAKE]
			, CAST(main_table.[AVI_TAG_STATUS] AS varchar(2)) AS [AVI_TAG_STATUS]
			, CAST(main_table.[VEH_SPEED] AS decimal(8,2)) AS [VEH_SPEED]
			, CAST(main_table.[DELETED] AS bit) AS [DELETED]
			, CAST(main_table.[LAST_UPDATE_DATE] AS datetime2(3)) AS [LAST_UPDATE_DATE]
	FROM dbo.[FACT_NET_REV_TFC_EVTS] AS main_table
	LEFT JOIN dbo.TOTAL_NET_REV_TFC_EVTS T ON T.TART_TART_ID = main_table.[TART_ID]
	--LEFT JOIN dbo.TOLL_TAGS ATT ON ATT.TAG_ID = main_table.AVIT_TAG_ID
	--LEFT JOIN dbo.TOLL_TAGS ITT ON ITT.TAG_ID = main_table.IOP_TXNS_TAG_ID
	OPTION (LABEL = ''FACT_NET_REV_TFC_EVTS_NEW_SET LOAD'');'
	EXEC (@sql)

	CREATE STATISTICS [STATS_FACT_NET_REV_TFC_EVTS_001] ON dbo.[FACT_NET_REV_TFC_EVTS_NEW_SET] ([DAY_ID],[TART_ID]);
	CREATE STATISTICS [STATS_FACT_NET_REV_TFC_EVTS_002] ON dbo.[FACT_NET_REV_TFC_EVTS_NEW_SET] ([TART_ID],[LANE_ID]);
	CREATE STATISTICS [STATS_FACT_NET_REV_TFC_EVTS_003] ON dbo.[FACT_NET_REV_TFC_EVTS_NEW_SET] ([LANE_ID],[DAY_ID]);
	CREATE STATISTICS [STATS_FACT_NET_REV_TFC_EVTS_004] ON dbo.[FACT_NET_REV_TFC_EVTS_NEW_SET] ([TRANSACTION_FILE_DETAIL_ID]);
	CREATE STATISTICS [STATS_FACT_NET_REV_TFC_EVTS_005] ON dbo.[FACT_NET_REV_TFC_EVTS_NEW_SET] (Local_Time);
	CREATE STATISTICS [STATS_FACT_NET_REV_TFC_EVTS_006] ON dbo.[FACT_NET_REV_TFC_EVTS_NEW_SET] (DELETED);
	CREATE STATISTICS [STATS_FACT_NET_REV_TFC_EVTS_007] ON dbo.[FACT_NET_REV_TFC_EVTS_NEW_SET] (LAST_UPDATE_DATE);
	CREATE STATISTICS [STATS_FACT_NET_REV_TFC_EVTS_008] ON dbo.[FACT_NET_REV_TFC_EVTS_NEW_SET] (MONTH_ID,[DAY_ID],[TART_ID]);
	CREATE STATISTICS [STATS_FACT_NET_REV_TFC_EVTS_009] ON dbo.[FACT_NET_REV_TFC_EVTS_NEW_SET] (VES_SERIAL_NO,MONTH_ID);

	IF OBJECT_ID('dbo.[FACT_NET_REV_TFC_EVTS_PREV]') IS NOT NULL	DROP TABLE dbo.[FACT_NET_REV_TFC_EVTS_PREV];
	IF OBJECT_ID('dbo.[FACT_NET_REV_TFC_EVTS]') IS NOT NULL			RENAME OBJECT::dbo.[FACT_NET_REV_TFC_EVTS] TO [FACT_NET_REV_TFC_EVTS_PREV];
	IF OBJECT_ID('dbo.[FACT_NET_REV_TFC_EVTS_NEW_SET]') IS NOT NULL	RENAME OBJECT::dbo.[FACT_NET_REV_TFC_EVTS_NEW_SET] TO [FACT_NET_REV_TFC_EVTS];

END


-- STEP 1: Get the next Load Control Date from the Control Table
SET @LOG_START_DATE = GETDATE()

SELECT @LOAD_CONTROL_DATE =	DATEADD(DAY,-3,MAX(LAST_UPDATE_DATE)) FROM  dbo.FACT_NET_REV_TFC_EVTS -- Use -3 days from this to avoid lost in data

--SELECT	@LOAD_CONTROL_DATE = LAST_RUN_DATE FROM	dbo.LOAD_PROCESS_CONTROL WHERE	TABLE_NAME = 'FACT_NET_REV_TFC_EVTS'
IF @LOAD_CONTROL_DATE IS NULL 
BEGIN
	SET @LOAD_CONTROL_DATE = '1990-01-01' --CAST(LEFT(CONVERT(VARCHAR(8), @LOG_START_DATE, 112), 6) + '01' AS DATETIME2(2)) 
END

---- !!!!!!!!!!!!!!!!!!!!! TESTING ONLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--SET @LOAD_CONTROL_DATE = CAST('2019-04-01 00:00:00.00' AS DATETIME2(2)) 
---- !!!!!!!!!!!!!!!!!!!!! TESTING ONLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

--PRINT @LOAD_CONTROL_DATE

-- STEP 2: Initiate LOG
SELECT  @LOG_MESSAGE = 'Started to load updates from ' + CONVERT(VARCHAR(19),@LOAD_CONTROL_DATE,121)
EXEC    dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE,  NULL
DECLARE @LOAD_START_DATE VARCHAR(26) = CONVERT(VARCHAR(26), CAST(@LOAD_CONTROL_DATE AS DATETIME2(6)), 121)

-- STEP 3: Get maximum Partition and it's baundry value
--EXEC DBO.PARTITION_MANAGE_MONTHLY_LOAD @TABLE_NAME

--STEP #7: -- Getting all changes to a new table

--IF OBJECT_ID('dbo.FACT_NET_REV_TFC_EVTS_TART_IDS') IS NOT NULL DROP TABLE dbo.FACT_NET_REV_TFC_EVTS_TART_IDS

--CREATE TABLE dbo.FACT_NET_REV_TFC_EVTS_TART_IDS WITH (HEAP, DISTRIBUTION = HASH(TART_ID)) AS
--SELECT DISTINCT TART_ID
----INTO #TART_IDS
--FROM (
--		SELECT TART_TART_ID AS TART_ID
--		FROM dbo.TOTAL_NET_REV_TFC_EVTS 
--		WHERE	LAST_UPDATE_DATE >= @LOAD_CONTROL_DATE
--		UNION
--		SELECT TRANSACTION_ID AS TART_ID
--		FROM LND_LG_HOST.TXNOWNER.AVI_TRANSACTIONS 
--		WHERE	SOURCE_CODE = 'H' AND LAST_UPDATE_DATE >= @LOAD_CONTROL_DATE
--		UNION
--		SELECT TRANSACTION_ID AS TART_ID
--		FROM LND_LG_HOST.TXNOWNER.IOP_TRANSACTIONS
--		WHERE	SOURCE_CODE = 'H' AND LAST_UPDATE_DATE >= @LOAD_CONTROL_DATE
--	) AS A
--OPTION (LABEL = 'FACT_NET_REV_TFC_EVTS LOAD: TART_IDS');


IF OBJECT_ID('dbo.FACT_NET_REV_TFC_EVTS_NEW_SET') IS NOT NULL DROP TABLE dbo.FACT_NET_REV_TFC_EVTS_NEW_SET
	-- EXPLAIN
CREATE TABLE dbo.FACT_NET_REV_TFC_EVTS_NEW_SET WITH (CLUSTERED INDEX (TART_ID), DISTRIBUTION = HASH(TART_ID)) AS
--WITH TOTAL_NET_REV_TFC_CTE AS 
--(
	SELECT	 
		CAST(CONVERT(VARCHAR(8), Local_Time,112) AS INT) AS DAY_ID, 
		CAST(CONVERT(VARCHAR(6), Local_Time,112) AS INT) AS MONTH_ID, 
		ISNULL(CAST(TART_TART_ID AS BIGINT),-1) AS TART_ID, 
		CAST(LANE_LANE_ID AS INT) AS LANE_ID,
		CAST(ATD_ID AS BIGINT) AS ATD_ID, 
		ISNULL(CAST(OPNM_OPNM_ID AS SMALLINT), -1) AS OPNM_ID, 
		ISNULL(CAST(PMTY_PMTY_ID AS SMALLINT), -1) AS PMTY_ID, 
		ISNULL(CAST(VCLY_VCLY_ID AS SMALLINT), -1) AS VCLY_ID,  
		DATEDIFF(SECOND, CAST(Local_Time AS DATE), Local_Time) AS TIME_ID,
		ISNULL(CAST(DATE_TIME AS datetime2(0)), '1900-01-01') AS DATE_TIME, 
		Local_Time AS Local_Time, 
		CAST(CASE WHEN SIGN_FLG = 0 
			THEN EAR_REV  / 100 
			ELSE ATT_FARE / 100 
		END AS DECIMAL(10,2)) AS EAR_REV, 
		CAST(EXP_REV AS DECIMAL(10,2)) AS EXP_REV, 
		CAST(ACT_REV/100.00 AS DECIMAL(10,2)) AS ACT_REV, 
		ATT_FARE							AS ATT_FARE,
		ISNULL(CAST(MISCLASS_CT AS SMALLINT), 0) AS MISCLASS_CT, 
		ISNULL(CAST(SIGN_FLG AS SMALLINT), 0) AS SIGN_FLG, 
		ISNULL(ADJ_STATUS, '') AS ADJ_STATUS, 
		CAST(TRTE.TXID_ID AS Int) AS TXID_ID, 
		CAST(TRTE.VES_SERIAL_NO AS BIGINT) AS VES_SERIAL_NO, 
		TRTE.VES_DATE_TIME_LOCAL AS VES_DATE_TIME,
		TRTE.TRANSACTION_FILE_DETAIL_ID, 
		AVI_HANDSHAKE, 
		CAST(AVI_TAG_STATUS AS VARCHAR(2)) AS AVI_TAG_STATUS,
		TRTE.VEH_SPEED,
		TRTE.DELETED,
		CAST(TRTE.LAST_UPDATE_DATE AS datetime2(3)) AS LAST_UPDATE_DATE
			--SELECT COUNT_BIG(*) -- SELECT TOP 2 * 
	FROM	dbo.TOTAL_NET_REV_TFC_EVTS TRTE
	WHERE	LAST_UPDATE_DATE >= @LOAD_CONTROL_DATE
	--WHERE TART_TART_ID IN (SELECT TART_ID FROM dbo.FACT_NET_REV_TFC_EVTS_TART_IDS)  --#TART_IDS) --dbo.FACT_NET_REV_TFC_EVTS_TART_IDS)  --
--)
--,AVI_TRANSACTIONS_CTE AS
--(
--	SELECT	TRANSACTION_ID, CAST(EARNED_REVENUE AS DECIMAL(10,2)) AS EARNED_REVENUE, CAST(POSTED_REVENUE AS DECIMAL(10,2)) AS POSTED_REVENUE
--	FROM	LND_LG_HOST.TXNOWNER.AVI_TRANSACTIONS AVT
--	WHERE	SOURCE_CODE = 'H' AND DISPOSITION = 'P'  AND TRANSACTION_ID IN (SELECT TART_ID FROM dbo.FACT_NET_REV_TFC_EVTS_TART_IDS)	 
--)
--,IOP_TXNS AS
--(
--	SELECT	TRANSACTION_ID, EARNED_REVENUE, POSTED_REVENUE
--	FROM	LND_LG_HOST.TXNOWNER.IOP_TRANSACTIONS --dbo.FACT_IOP_TGS IOP 
--	WHERE	SOURCE_CODE = 'H' AND DISPOSITION = 'P' AND TRANSACTION_ID IN (SELECT TART_ID FROM dbo.FACT_NET_REV_TFC_EVTS_TART_IDS) 
--)
--SELECT	 
--	TRTE.DAY_ID, TRTE.DAY_ID / 100 AS MONTH_ID, TRTE.TART_ID, TRTE.LANE_ID, TRTE.ATD_ID, OPNM_ID, PMTY_ID, VCLY_ID,  
--	TRTE.TIME_ID, TRTE.DATE_TIME, TRTE.Local_Time, TRTE.EAR_REV, TRTE.EXP_REV, TRTE.ACT_REV, 
--	AVIT.EARNED_REVENUE AS AVIT_EARNED_REVENUE, AVIT.POSTED_REVENUE AS AVIT_POSTED_REVENUE,	--AVIT.TT_ID AS AVIT_TT_ID,
--	IOP.EARNED_REVENUE AS IOP_TXNS_EARNED_REVENUE, IOP.POSTED_REVENUE AS IOP_TXNS_POSTED_REVENUE,	--IOP.TT_ID AS IOP_TT_ID,
--	ATT_FARE,TRTE.MISCLASS_CT, TRTE.SIGN_FLG, TRTE.ADJ_STATUS, TRTE.TXID_ID, TRTE.VES_SERIAL_NO, TRTE.VES_DATE_TIME,TRTE.TRANSACTION_FILE_DETAIL_ID, 
--	--AVIT.SOURCE_CODE AS AVIT_SOURCE_CODE,AVIT.AGENCY_ID AS AVIT_AGENCY_ID,AVIT.POSTED_DATE AS AVIT_POSTED_DATE,
--	--IOP.SOURCE_CODE AS IOP_TXNS_SOURCE_CODE,IOP.AGENCY_ID AS IOP_TXNS_AGENCY_ID,IOP.POSTED_DATE AS IOP_TXNS_POSTED_DATE,
--	TRTE.AVI_HANDSHAKE, TRTE.AVI_TAG_STATUS, TRTE.VEH_SPEED,TRTE.DELETED,TRTE.LAST_UPDATE_DATE 
--		--SELECT COUNT_BIG(*) -- SELECT TOP 2 * 
--FROM	TOTAL_NET_REV_TFC_CTE TRTE
--LEFT JOIN  	AVI_TRANSACTIONS_CTE AVIT
--	ON		AVIT.TRANSACTION_ID = TRTE.TART_ID
--LEFT JOIN  IOP_TXNS IOP
--	ON		IOP.TRANSACTION_ID = TRTE.TART_ID
OPTION (LABEL = 'FACT_NET_REV_TFC_EVTS LOAD');

-- Logging
EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
SET  @LOG_MESSAGE = 'Got all changed rows:'
EXEC dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, @ROW_COUNT


--
--DECLARE @SQL_SELECT VARCHAR(8000) = '
--DAY_ID, TART_ID, LANE_ID, ATD_ID, OPNM_ID, PMTY_ID, VCLY_ID,TIME_ID, DATE_TIME, Local_Time, EAR_REV, EXP_REV, ACT_REV, 
--AVIT_EARNED_REVENUE, AVIT_POSTED_REVENUE,AVIT_TT_ID,IOP_TXNS_EARNED_REVENUE, IOP_TXNS_POSTED_REVENUE,IOP_TT_ID,
--ATT_FARE,MISCLASS_CT, SIGN_FLG, ADJ_STATUS, TXID_ID, VES_SERIAL_NO, VES_DATE_TIME,TRANSACTION_FILE_DETAIL_ID, 
--AVIT_SOURCE_CODE,AVIT_AGENCY_ID,AVIT_POSTED_DATE,IOP_TXNS_SOURCE_CODE,IOP_TXNS_AGENCY_ID,IOP_TXNS_POSTED_DATE,
--AVI_HANDSHAKE, AVI_TAG_STATUS, VEH_SPEED,DELETED,LAST_UPDATE_DATE 

DECLARE @IDENTITY_COLUMNS VARCHAR(8000) = '[TART_ID]'

EXEC DBO.PARTITION_SWITCH_MONTHLY_LOAD @TABLE_NAME,	@IDENTITY_COLUMNS
--EXEC DBO.PARTITION_SWITCH_NUMBER_BASED_LOAD @TABLE_NAME,	@IDENTITY_COLUMNS

--STEP #13: UPDATE STATISTICS and delete temp tables
UPDATE STATISTICS dbo.FACT_NET_REV_TFC_EVTS  

IF OBJECT_ID('dbo.FACT_NET_REV_TFC_EVTS_NEW_SET') IS NOT NULL DROP TABLE dbo.FACT_NET_REV_TFC_EVTS_NEW_SET
--IF OBJECT_ID('dbo.FACT_NET_REV_TFC_EVTS_TART_IDS') IS NOT NULL DROP TABLE dbo.FACT_NET_REV_TFC_EVTS_TART_IDS


