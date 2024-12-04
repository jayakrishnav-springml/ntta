CREATE PROC [DBO].[FACT_TRIP_ANALYSIS_PART_LOAD] AS
-- @StartDate DATE
--AS
/*
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.FACT_TRIP_ANALYSIS_PART_PART_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.[FACT_TRIP_ANALYSIS_PART_PART_LOAD]
GO

-- !!! TESTING !!! --
DECLARE @StartDate DATE = '2018-10-01';	
-- !!! TESTING !!! --
*/
DECLARE @StartDate DATE = NULL;	

--IF @StartDate IS NULL SET @StartDate = '2018-01-01'
IF @StartDate IS NULL SET @StartDate = '2019-05-01'

DECLARE @SOURCE VARCHAR(50), @RUN_DATE DATETIME2 (2), @LOG_MESSAGE VARCHAR(1000), @ROW_COUNT BIGINT, @TT_CONTROL_DATE DATETIME2(2), @LV_CONTROL_DATE DATETIME2(2) 
DECLARE @SQL_DDL VARCHAR(max) = ''		
DECLARE @MILLENIUM_DATE DATE = '20010101'

SELECT  @SOURCE = 'FACT_TRIP_ANALYSIS_PART', @RUN_DATE = SYSDATETIME(), @LOG_MESSAGE = 'Started full load'

--SET @RUN_DATE = '2018-11-01'
--SET @RUN_DATE = '2019-06-01'

DECLARE @START_DAY_ID INT = CAST(CONVERT(VARCHAR(8), @StartDate,112) AS INT);
DECLARE @END_DAY_ID INT = CAST(CONVERT(VARCHAR(8), @RUN_DATE,112) AS INT);

--SET @RUN_DATE = SYSDATETIME()


EXEC    EDW_RITE.dbo.LOG_PROCESS @SOURCE, @RUN_DATE, @LOG_MESSAGE,  NULL

--STEP #1: 	-- Calculate ranges from PARTITION_DAY_ID_CONTROL for whole table
DECLARE @PART_RANGES VARCHAR(MAX) = ''
EXEC EDW_RITE.DBO.GET_PARTITION_RANGE_STRING 'FACT_UNIFIED_VIOLATION', @PART_RANGES OUTPUT

--IF SELECT OBJECT_ID('dbo.FACT_TRIP_HISTORY_PART_STAGE') IS NOT NULL DROP TABLE dbo.FACT_TRIP_HISTORY_PART_STAGE;	

--SELECT COUNT_BIG(1) FROM dbo.FACT_TRIP_HISTORY_PART WHERE TART_ID = -1	-- 60176145
--SELECT COUNT_BIG(1) FROM dbo.FACT_TRIP_HISTORY_PART						-- 1080662546
--SELECT TOP 100 * FROM dbo.SOURCE_CODE_TOLL
--SELECT MAX(TTXN_ID) FROM EDW_RITE.DBO.FACT_TOLL_TRANSACTIONS -- 8 024 054 701
IF OBJECT_ID('dbo.FACT_TRIP_HISTORY_PART_STAGE') IS  NULL
BEGIN
	-- EXPLAIN
	CREATE TABLE dbo.FACT_TRIP_HISTORY_PART_STAGE WITH (HEAP, DISTRIBUTION = HASH(TRIP_ID)) AS --EXPLAIN
	WITH CTE_FST AS
	(
		SELECT --TOP(100) 
				ACCT_ID,TAG_ID,DAY_ID,AMOUNT,VEHICLE_CLASS_CODE AS VEHICLE_CLASS, LICENSE_PLATE_ID,
				DIM_LANE.LANE_DIRECTION,DIM_LANE.PLAZA_ID, DIM_LANE.FACILITY_ID,TT.LANE_ID,
				DATEDIFF(SECOND,'20010101', TRANSACTION_DATE) AS SECOND_ID,
				CAST(TRANSACTION_DATE AS DATETIME2(0)) AS TRANSACTION_DATE,
				TRANSACTION_TIME_ID AS TIME_ID,
				TT.TTXN_ID,TT.SOURCE_CODE,
				COALESCE(CASE WHEN TT.SOURCE_CODE = 'H' AND TT.CREDITED_FLAG = 'N' THEN TT.SOURCE_TRXN_ID ELSE HIX.TART_ID END, -1) AS TART_ID
				--COALESCE(X.TART_ID, HIX.TART_ID, -1) AS TART_ID
				--SELECT TOP 100 * --COUNT_BIG(1)
		FROM	EDW_RITE.DBO.FACT_TOLL_TRANSACTIONS AS TT --LND_LG_TS.TAG_OWNER.TOLL_TRANSACTIONS --EDW_RITE.[DBO].[TOLL_TRANSACTIONS] 
		JOIN	EDW_RITE.dbo.DIM_LANE AS DIM_LANE ON TT.LANE_ID = DIM_LANE.LANE_ID
		--LEFT JOIN	EDW_RITE.dbo.HOST_TGS_XREF X ON X.TTXN_ID = TT.TTXN_ID
		--LEFT JOIN	EDW_RITE.dbo.VPS_TGS_XREF VTX ON VTX.TTXN_ID = TT.TTXN_ID
		LEFT JOIN	EDW_RITE.dbo.ICRS_VPS_XREF IVX ON /*VTX.TRANSACTION_ID =*/ IVX.TRANSACTION_ID = TT.SOURCE_TRXN_ID AND TT.SOURCE_CODE IN ('M','O','V','W','X','Z') AND TT.CREDITED_FLAG = 'N'
		LEFT JOIN	EDW_RITE.dbo.HOST_ICRS_XREF HIX ON HIX.LANE_VIOL_ID = IVX.LANE_VIOL_ID
		WHERE TT.DAY_ID BETWEEN @START_DAY_ID AND @END_DAY_ID
		--AND ACCT_ID = 647762
		--AND		DIM_LANE.FACILITY_ID IN (260)
--TRHL_ID					TART_ID		TRIP_ID					SECOND_ID	DAY_ID		TIME_ID	TXN_TYPE	ACCT_ID	TAG_ID
--1080797190500579599661	15859721957	1080797190500579599661	579599661	20190515	28461	TollTag		647762	14192104
	)
	, CTE_RD AS
	(
		SELECT --TOP(100) 
				TART_ID,ACCT_ID, TAG_ID,DAY_ID,TIME_ID,AMOUNT,VEHICLE_CLASS, LICENSE_PLATE_ID,
				LANE_DIRECTION, PLAZA_ID, FACILITY_ID,LANE_ID,SECOND_ID,TTXN_ID,SOURCE_CODE,
				DATEDIFF(MINUTE, ISNULL(LAG(TRANSACTION_DATE) OVER (PARTITION BY ACCT_ID, TAG_ID ORDER BY SECOND_ID),'20010101'), TRANSACTION_DATE) AS MIN_DIFF,
				LAG(LANE_DIRECTION) OVER (PARTITION BY ACCT_ID, TAG_ID ORDER BY SECOND_ID) AS PREV_LANE_DIRECTION,
				LAG(PLAZA_ID) OVER (PARTITION BY ACCT_ID, TAG_ID ORDER BY SECOND_ID) AS PREV_PLAZA_ID,
				LAG(FACILITY_ID) OVER (PARTITION BY ACCT_ID, TAG_ID ORDER BY SECOND_ID) AS PREV_FACILITY_ID
				--SELECT TOP 100 * COUNT_BIG(1)
		FROM	CTE_FST 
		WHERE TART_ID > -1
	)
	, CTE_WF AS
	(
		SELECT 
			TART_ID,ACCT_ID,TAG_ID,DAY_ID,TIME_ID,SECOND_ID,AMOUNT,VEHICLE_CLASS, LICENSE_PLATE_ID,LANE_DIRECTION,LANE_ID,PLAZA_ID,FACILITY_ID,PREV_LANE_DIRECTION,PREV_PLAZA_ID,PREV_FACILITY_ID,MIN_DIFF,TTXN_ID,SOURCE_CODE,
			CASE	WHEN PREV_PLAZA_ID IS NULL THEN 0
					WHEN NOT EXISTS (
									SELECT 1 
									FROM EDW_RITE.dbo.PLAZA_PLAZA_XREF PC 
									WHERE PC.FROM_PLAZA_ID = RD.PREV_PLAZA_ID 
										AND PC.TO_PLAZA_ID = RD.PLAZA_ID 
										AND (PC.FROM_LANE_DIRECTION = RD.PREV_LANE_DIRECTION)
										AND (PC.TO_LANE_DIRECTION = RD.LANE_DIRECTION)
										AND RD.MIN_DIFF <= PC.MAX_TIME
									) THEN 0
					ELSE 1 -- Here we suppose if spent less then 30 mins- it's the same trip
			END AS IS_NOT_ENTRANCE
		FROM CTE_RD AS RD
	)--SELECT * FROM CTE_WF ORDER BY ACCT_ID, TAG_ID, DATE_TIME_ID
	, CTE_Borders AS
	(
	SELECT TTXN_ID,ACCT_ID,TAG_ID,SECOND_ID AS FROM_ID,
		(LEAD(SECOND_ID,1,1892169845) OVER (PARTITION BY ACCT_ID,TAG_ID ORDER BY (SECOND_ID)) - 1) AS TO_ID    -- 1 892 169 845 - Number of seconds for approximately 60 years - not very soon
		--ROW_NUMBER() OVER (PARTITION BY LANE_ID,SECOND_ID ORDER BY TAG_ID) AS RS
	FROM CTE_WF
	WHERE IS_NOT_ENTRANCE = 0
	)
	, CTE_FINAL AS 
	(
		SELECT 
			CTE_WF.TART_ID, CTE_WF.ACCT_ID,CTE_WF.TAG_ID,VEHICLE_CLASS, LICENSE_PLATE_ID,SECOND_ID,DAY_ID,TIME_ID,AMOUNT,LANE_DIRECTION,CTE_WF.LANE_ID,PLAZA_ID,FACILITY_ID,PREV_LANE_DIRECTION,PREV_PLAZA_ID,PREV_FACILITY_ID,
			(IS_NOT_ENTRANCE * MIN_DIFF) AS DURATION_MINUTES, IS_NOT_ENTRANCE, MIN_DIFF,SOURCE_CODE,													-- Because start point should not have duration
			1000000000000000000000 + CTE_Borders.TTXN_ID * 10000000000 + CAST(CTE_Borders.FROM_ID AS BIGINT) AS TRIP_ID,
			1000000000000000000000 + CTE_WF.TTXN_ID * 10000000000 + CAST(CTE_WF.SECOND_ID AS BIGINT) AS TRHL_ID
	FROM CTE_WF 
	JOIN CTE_Borders ON CTE_Borders.ACCT_ID = CTE_WF.ACCT_ID AND CTE_Borders.TAG_ID = CTE_WF.TAG_ID AND CTE_WF.SECOND_ID BETWEEN CTE_Borders.FROM_ID AND CTE_Borders.TO_ID
	)
	SELECT TRHL_ID,TART_ID,ACCT_ID,TAG_ID,TRIP_ID,LICENSE_PLATE_ID,SECOND_ID,DAY_ID,TIME_ID,VEHICLE_CLASS,LANE_DIRECTION,LANE_ID,PLAZA_ID,FACILITY_ID,AMOUNT,DURATION_MINUTES,
			CASE WHEN SOURCE_CODE IN ('H','I') THEN 'TollTag' ELSE 'VToll' END AS TXN_TYPE 
	FROM CTE_FINAL
	OPTION (LABEL = 'FACT_TRIP_HISTORY_PART_STAGE LOAD');
END

/*
SELECT COUNT_BIG(1) FROM FACT_TRIP_HISTORY_PART_STAGE
SELECT COUNT_BIG(1) FROM FACT_TRIP_HISTORY_PART_STAGE
SELECT * FROM FACT_TRIP_HISTORY_PART_STAGE ORDER BY SECOND_ID

*/
-- SELECT COUNT_BIG(1) FROM dbo.FACT_NET_REV_TFC_TRIPS -- 196 960 445

--SELECT COUNT_BIG(1) FROM EDW_RITE.DBO.FACT_VIOLATIONS_DETAIL WHERE VIOLATOR_ID = -1  -- 288 570 761

--SELECT MAX(LICENSE_PLATE_ID) FROM EDW_RITE.DBO.FACT_VIOLATIONS_DETAIL	-- 66136944
--SELECT MAX(VIOLATOR_ID) FROM EDW_RITE.DBO.FACT_VIOLATIONS_DETAIL		-- 804202269
																		-- 10000000000
--IF SELECT OBJECT_ID('dbo.FACT_NET_REV_TFC_TRIPS') IS NOT NULL DROP TABLE dbo.FACT_NET_REV_TFC_TRIPS;
IF OBJECT_ID('dbo.FACT_NET_REV_TFC_TRIPS') IS NULL
BEGIN
	CREATE TABLE dbo.FACT_NET_REV_TFC_TRIPS WITH (CLUSTERED INDEX (TRANSACTION_FILE_DETAIL_ID), DISTRIBUTION = HASH(TRANSACTION_FILE_DETAIL_ID)) AS --EXPLAIN
	SELECT TART_ID, TRANSACTION_FILE_DETAIL_ID 
	FROM EDW_RITE.dbo.FACT_NET_REV_TFC_EVTS 
	WHERE DAY_ID BETWEEN @START_DAY_ID AND @END_DAY_ID AND TRANSACTION_FILE_DETAIL_ID > -1
END

--IF SELECT OBJECT_ID('dbo.FACT_TRIP_LV_HISTORY_STAGE') IS NOT NULL DROP TABLE dbo.FACT_TRIP_LV_HISTORY_STAGE;	

IF OBJECT_ID('dbo.FACT_TRIP_LV_HISTORY_STAGE') IS NULL
BEGIN
	-- EXPLAIN
	CREATE TABLE dbo.FACT_TRIP_LV_HISTORY_STAGE WITH (HEAP, DISTRIBUTION = HASH(TRIP_ID)) AS --EXPLAIN
	WITH CTE_VIOL AS
	(
		SELECT 
			COALESCE(10000000000 + LICENSE_PLATE_ID,VIOLATOR_ID, -1) AS DRIVER_ID, LICENSE_PLATE_ID,DAY_ID,VIOL_DATE,TOLL_DUE,VEHICLE_CLASS,LANE_ID,TRANSACTION_FILE_DETAIL_ID,LANE_VIOL_ID,VIOLATOR_ID, VIOLATION_ID 
		FROM EDW_RITE.DBO.FACT_VIOLATIONS_DETAIL
		WHERE LIC_PLATE_NBR NOT LIKE '~%'	
			AND	VIOL_STATUS <> 'T' --NOT IN ('T','D')
			--AND	DISPOSITION <> 'F'
			AND	DAY_ID BETWEEN @START_DAY_ID AND @END_DAY_ID 
			--AND	DAY_ID > '20180101' 
	)  
	, CTE_RD AS
	(
		SELECT --TOP(100) 
			LV.DRIVER_ID, LV.LICENSE_PLATE_ID,LV.DAY_ID, LV.VIOL_DATE AS TRANSACTION_DATE, LV.TOLL_DUE AS AMOUNT, LV.VEHICLE_CLASS,
			DIM_LANE.LANE_DIRECTION,DIM_LANE.PLAZA_ID, DIM_LANE.FACILITY_ID, LV.LANE_ID, LV.VIOLATION_ID,LV.VIOLATOR_ID,
			DATEDIFF(SECOND,'20010101', LV.VIOL_DATE) AS SECOND_ID,
			DATEDIFF(SECOND,CAST(LV.VIOL_DATE AS DATE), LV.VIOL_DATE) AS TIME_ID,
			COALESCE(F.TART_ID, X.TART_ID, -1) AS TART_ID
			--SELECT COUNT_BIG(1)
		FROM CTE_VIOL AS LV
		JOIN	EDW_RITE.dbo.DIM_LANE AS DIM_LANE ON LV.LANE_ID = DIM_LANE.LANE_ID
		LEFT JOIN	EDW_RITE.dbo.FACT_NET_REV_TFC_TRIPS F ON LV.TRANSACTION_FILE_DETAIL_ID = F.TRANSACTION_FILE_DETAIL_ID
		LEFT JOIN	EDW_RITE.dbo.HOST_ICRS_XREF X ON X.LANE_VIOL_ID = LV.LANE_VIOL_ID
		WHERE DRIVER_ID > - 1
		--WHERE	DIM_LANE.FACILITY_ID IN (260)
	)
	, CTE_PR AS
	(
		SELECT --TOP(100) 
				TART_ID,DRIVER_ID,LICENSE_PLATE_ID,LANE_DIRECTION,DAY_ID,TIME_ID,AMOUNT,VEHICLE_CLASS,PLAZA_ID,FACILITY_ID,SECOND_ID,LANE_ID,VIOLATION_ID,VIOLATOR_ID,
				DATEDIFF(MINUTE, ISNULL(LAG(TRANSACTION_DATE) OVER (PARTITION BY DRIVER_ID ORDER BY SECOND_ID),'20010101'), TRANSACTION_DATE) AS MIN_DIFF,
				LAG(LANE_DIRECTION) OVER (PARTITION BY DRIVER_ID ORDER BY SECOND_ID) AS PREV_LANE_DIRECTION,
				LAG(PLAZA_ID) OVER (PARTITION BY DRIVER_ID ORDER BY SECOND_ID) AS PREV_PLAZA_ID,
				LAG(FACILITY_ID) OVER (PARTITION BY DRIVER_ID ORDER BY SECOND_ID) AS PREV_FACILITY_ID
				--SELECT COUNT_BIG(1)
		FROM	CTE_RD
		WHERE TART_ID > -1
	)
	, CTE_WF AS
	(
		SELECT 
			TART_ID,DRIVER_ID,LICENSE_PLATE_ID, DAY_ID,TIME_ID,SECOND_ID,AMOUNT,VEHICLE_CLASS,LANE_DIRECTION,LANE_ID,PLAZA_ID,FACILITY_ID,PREV_LANE_DIRECTION,PREV_PLAZA_ID,PREV_FACILITY_ID,MIN_DIFF,VIOLATION_ID,VIOLATOR_ID,
			CASE	WHEN PREV_PLAZA_ID IS NULL THEN 0
					WHEN NOT EXISTS (
									SELECT 1 
									FROM EDW_RITE.dbo.PLAZA_PLAZA_XREF PC 
									WHERE PC.FROM_PLAZA_ID = RD.PREV_PLAZA_ID 
										AND PC.TO_PLAZA_ID = RD.PLAZA_ID 
										AND (PC.FROM_LANE_DIRECTION = RD.PREV_LANE_DIRECTION)
										AND (PC.TO_LANE_DIRECTION = RD.LANE_DIRECTION)
										AND RD.MIN_DIFF <= PC.MAX_TIME
									) THEN 0
					ELSE 1 -- Here we suppose if spent less then 30 mins- it's the same trip
			END AS IS_NOT_ENTRANCE
		FROM CTE_PR AS RD
	)
	, CTE_Borders AS
	(
	SELECT VIOLATION_ID,DRIVER_ID, VIOLATOR_ID, SECOND_ID AS FROM_ID,
		(LEAD(SECOND_ID,1,1892169845) OVER (PARTITION BY DRIVER_ID  ORDER BY (SECOND_ID)) - 1) AS TO_ID
		--ROW_NUMBER() OVER (PARTITION BY LANE_ID,SECOND_ID ORDER BY LICENSE_PLATE_ID) AS RS
	FROM CTE_WF
	WHERE IS_NOT_ENTRANCE = 0
	)
	, CTE_FINAL AS 
	(
		SELECT 
			CTE_WF.TART_ID, ISNULL(CTE_WF.LICENSE_PLATE_ID, -1) LICENSE_PLATE_ID, VEHICLE_CLASS,SECOND_ID,DAY_ID,TIME_ID,AMOUNT,LANE_DIRECTION,CTE_WF.LANE_ID,PLAZA_ID,FACILITY_ID,PREV_LANE_DIRECTION,PREV_PLAZA_ID,PREV_FACILITY_ID,
			(IS_NOT_ENTRANCE * MIN_DIFF) AS DURATION_MINUTES, CTE_WF.VIOLATOR_ID,
			5000000000000000000000  + CAST(CTE_Borders.VIOLATION_ID AS BIGINT) * 10000000000 + CAST(CTE_Borders.FROM_ID AS BIGINT) AS TRIP_ID,
			5000000000000000000000  + CAST(CTE_WF.VIOLATION_ID AS BIGINT) * 10000000000 + CAST(CTE_WF.SECOND_ID AS BIGINT) AS TRHL_ID
	FROM CTE_WF 
	JOIN CTE_Borders ON CTE_Borders.DRIVER_ID = CTE_WF.DRIVER_ID AND CTE_WF.SECOND_ID BETWEEN CTE_Borders.FROM_ID AND CTE_Borders.TO_ID
	)
	SELECT TRHL_ID,TART_ID,LICENSE_PLATE_ID,TRIP_ID,SECOND_ID,DAY_ID,TIME_ID,VEHICLE_CLASS,LANE_DIRECTION,LANE_ID,PLAZA_ID,FACILITY_ID,AMOUNT,DURATION_MINUTES,VIOLATOR_ID
	FROM CTE_FINAL
	WHERE TART_ID NOT IN (SELECT TART_ID FROM dbo.FACT_TRIP_HISTORY_PART_STAGE)
	OPTION (LABEL = 'FACT_TRIP_LV_HISTORY_STAGE LOAD');
END


IF OBJECT_ID('dbo.FACT_TRIP_HISTORY_PART_NEW') IS NOT NULL DROP TABLE dbo.FACT_TRIP_HISTORY_PART_NEW;

SET @SQL_DDL = '
CREATE TABLE dbo.FACT_TRIP_HISTORY_PART_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TRIP_ID), PARTITION  (DAY_ID RANGE RIGHT FOR VALUES ('+@PART_RANGES+'))) AS
WITH CTE1 AS
(
	SELECT 
		TRHL_ID,TART_ID,TRIP_ID,SECOND_ID,DAY_ID,TIME_ID, TXN_TYPE AS TXN_TYPE, ACCT_ID, TAG_ID, -1 AS VIOLATOR_ID, LICENSE_PLATE_ID,VEHICLE_CLASS,LANE_ID,PLAZA_ID,FACILITY_ID,LANE_DIRECTION AS DIRECTION,DURATION_MINUTES,AMOUNT
	FROM dbo.FACT_TRIP_HISTORY_STAGE
	UNION ALL
	SELECT
		TRHL_ID,TART_ID,TRIP_ID,SECOND_ID,DAY_ID,TIME_ID, ''Video'' AS TXN_TYPE, -1 AS ACCT_ID, ''-1'' AS TAG_ID, VIOLATOR_ID, LICENSE_PLATE_ID,VEHICLE_CLASS,LANE_ID,PLAZA_ID,FACILITY_ID,LANE_DIRECTION AS DIRECTION,DURATION_MINUTES,AMOUNT
	FROM dbo.FACT_TRIP_LV_HISTORY_STAGE
)
, CTE2 AS
(
	SELECT 
		TRHL_ID,TART_ID,TRIP_ID,SECOND_ID,DAY_ID,TIME_ID, TXN_TYPE, ACCT_ID, TAG_ID, VIOLATOR_ID, LICENSE_PLATE_ID,VEHICLE_CLASS,LANE_ID,PLAZA_ID,FACILITY_ID,DIRECTION,DURATION_MINUTES,AMOUNT
		,ROW_NUMBER() OVER (PARTITION BY TART_ID ORDER BY SECOND_ID) AS RN
	FROM CTE1
)
SELECT 
	TRHL_ID,TART_ID,TRIP_ID,SECOND_ID,DAY_ID,TIME_ID, TXN_TYPE, ACCT_ID, TAG_ID, VIOLATOR_ID, LICENSE_PLATE_ID,VEHICLE_CLASS,LANE_ID,PLAZA_ID,FACILITY_ID,DIRECTION,DURATION_MINUTES,AMOUNT
FROM CTE2
WHERE RN = 1
OPTION (LABEL = ''FACT_TRIP_HISTORY_PART LOAD'');'
EXEC(@SQL_DDL)   
	
EXEC EDW_RITE.dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT

CREATE STATISTICS FACT_TRIP_HISTORY_001 ON [dbo].FACT_TRIP_HISTORY_PART_NEW (TXN_TYPE,VEHICLE_CLASS)
CREATE STATISTICS FACT_TRIP_HISTORY_002 ON [dbo].FACT_TRIP_HISTORY_PART_NEW (ACCT_ID,TAG_ID)
CREATE STATISTICS FACT_TRIP_HISTORY_003 ON [dbo].FACT_TRIP_HISTORY_PART_NEW (DAY_ID,TIME_ID)
CREATE STATISTICS FACT_TRIP_HISTORY_004 ON [dbo].FACT_TRIP_HISTORY_PART_NEW (LICENSE_PLATE_ID)
CREATE STATISTICS FACT_TRIP_HISTORY_005 ON [dbo].FACT_TRIP_HISTORY_PART_NEW (TRIP_ID)
CREATE STATISTICS FACT_TRIP_HISTORY_006 ON [dbo].FACT_TRIP_HISTORY_PART_NEW (TART_ID)
CREATE STATISTICS FACT_TRIP_HISTORY_007 ON [dbo].FACT_TRIP_HISTORY_PART_NEW (SECOND_ID)
CREATE STATISTICS FACT_TRIP_HISTORY_008 ON [dbo].FACT_TRIP_HISTORY_PART_NEW (FACILITY_ID,PLAZA_ID)
CREATE STATISTICS FACT_TRIP_HISTORY_009 ON [dbo].FACT_TRIP_HISTORY_PART_NEW (VIOLATOR_ID)


IF OBJECT_ID('dbo.FACT_TRIP_HISTORY_PART_OLD') IS NOT NULL 	DROP TABLE dbo.FACT_TRIP_HISTORY_PART_OLD;
IF OBJECT_ID('dbo.FACT_TRIP_HISTORY_PART') IS NOT NULL	RENAME OBJECT::dbo.FACT_TRIP_HISTORY_PART TO FACT_TRIP_HISTORY_PART_OLD;
RENAME OBJECT::dbo.FACT_TRIP_HISTORY_PART_NEW TO FACT_TRIP_HISTORY_PART;

SET  @LOG_MESSAGE = 'Finished TRIP_HISTORY load'
EXEC EDW_RITE.dbo.LOG_PROCESS @SOURCE, @RUN_DATE, @LOG_MESSAGE, @ROW_COUNT



--SELECT * FROM dbo.FACT_TRIP_HISTORY_PART

IF OBJECT_ID('dbo.FACT_TRIP_ANALYSIS_PART_NEW') IS NOT NULL DROP TABLE dbo.FACT_TRIP_ANALYSIS_PART_NEW;	
--DECLARE @PART_RANGES VARCHAR(MAX) = ''
--EXEC EDW_RITE.DBO.GET_PARTITION_RANGE_STRING 'FACT_UNIFIED_VIOLATION', @PART_RANGES OUTPUT
--DECLARE @SQL_DDL VARCHAR(max) = ''		

SET @SQL_DDL = '
CREATE TABLE dbo.FACT_TRIP_ANALYSIS_PART_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TRIP_ID), PARTITION  (START_DAY_ID RANGE RIGHT FOR VALUES ('+@PART_RANGES+'))) AS
WITH CTE_GROUP_VALUES AS
(
SELECT
	TRIP_ID, MAX(SECOND_ID) AS MAX_ID, MIN(SECOND_ID) AS MIN_ID,SUM(DURATION_MINUTES) AS TRIP_DURATION_MINUTES,SUM(AMOUNT) AS TRIP_AMOUNT
FROM dbo.FACT_TRIP_HISTORY_PART
GROUP BY TRIP_ID
)
SELECT
	CTE.TRIP_ID,FR.TXN_TYPE,
	ISNULL(NULLIF(FR.ACCT_ID, -1), LR.ACCT_ID) AS ACCT_ID,
	ISNULL(NULLIF(FR.TAG_ID, ''-1''), LR.TAG_ID) AS TAG_ID,
	ISNULL(NULLIF(FR.VIOLATOR_ID, -1), LR.VIOLATOR_ID) AS VIOLATOR_ID,
	ISNULL(NULLIF(FR.LICENSE_PLATE_ID, -1), LR.LICENSE_PLATE_ID) AS LICENSE_PLATE_ID,
	ISNULL(NULLIF(FR.VEHICLE_CLASS, ''-1''), LR.VEHICLE_CLASS) AS VEHICLE_CLASS,
	CTE.TRIP_DURATION_MINUTES,CTE.TRIP_AMOUNT,
	FR.FACILITY_ID AS START_FACILITY_ID,FR.PLAZA_ID AS START_PLAZA_ID,FR.DIRECTION AS START_DIRECTION,FR.DAY_ID AS START_DAY_ID,FR.TIME_ID AS START_TIME_ID,
	LR.FACILITY_ID AS END_FACILITY_ID,LR.PLAZA_ID AS END_PLAZA_ID,LR.DIRECTION AS END_DIRECTION,LR.DAY_ID AS END_DAY_ID,LR.TIME_ID AS END_TIME_ID
	
FROM CTE_GROUP_VALUES AS CTE
	JOIN dbo.FACT_TRIP_HISTORY_PART AS FR ON FR.TRIP_ID = CTE.TRIP_ID AND FR.SECOND_ID = CTE.MIN_ID 
	JOIN dbo.FACT_TRIP_HISTORY_PART AS LR ON LR.TRIP_ID = CTE.TRIP_ID AND LR.SECOND_ID = CTE.MAX_ID
OPTION (LABEL = ''FACT_TRIP_ANALYSIS_PART LOAD'');'
EXEC(@SQL_DDL)   

EXEC EDW_RITE.dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT

CREATE STATISTICS FACT_TRIP_ANALYSIS_001 ON [dbo].FACT_TRIP_ANALYSIS_PART_NEW (TXN_TYPE,VEHICLE_CLASS)
CREATE STATISTICS FACT_TRIP_ANALYSIS_002 ON [dbo].FACT_TRIP_ANALYSIS_PART_NEW (ACCT_ID,TAG_ID)
CREATE STATISTICS FACT_TRIP_ANALYSIS_003 ON [dbo].FACT_TRIP_ANALYSIS_PART_NEW (START_DAY_ID,END_DAY_ID)
CREATE STATISTICS FACT_TRIP_ANALYSIS_004 ON [dbo].FACT_TRIP_ANALYSIS_PART_NEW (LICENSE_PLATE_ID)
CREATE STATISTICS FACT_TRIP_ANALYSIS_005 ON [dbo].FACT_TRIP_ANALYSIS_PART_NEW (TRIP_ID,VIOLATOR_ID)
CREATE STATISTICS FACT_TRIP_ANALYSIS_006 ON [dbo].FACT_TRIP_ANALYSIS_PART_NEW (VEHICLE_CLASS)
CREATE STATISTICS FACT_TRIP_ANALYSIS_007 ON [dbo].FACT_TRIP_ANALYSIS_PART_NEW (START_FACILITY_ID,START_PLAZA_ID)
CREATE STATISTICS FACT_TRIP_ANALYSIS_008 ON [dbo].FACT_TRIP_ANALYSIS_PART_NEW (END_FACILITY_ID,END_PLAZA_ID)
CREATE STATISTICS FACT_TRIP_ANALYSIS_009 ON [dbo].FACT_TRIP_ANALYSIS_PART_NEW (VIOLATOR_ID)


IF OBJECT_ID('dbo.FACT_TRIP_ANALYSIS_PART_OLD') IS NOT NULL 	DROP TABLE dbo.FACT_TRIP_ANALYSIS_PART_OLD;
IF OBJECT_ID('dbo.FACT_TRIP_ANALYSIS_PART') IS NOT NULL	RENAME OBJECT::dbo.FACT_TRIP_ANALYSIS_PART TO FACT_TRIP_ANALYSIS_PART_OLD;
RENAME OBJECT::dbo.FACT_TRIP_ANALYSIS_PART_NEW TO FACT_TRIP_ANALYSIS_PART;


SET  @LOG_MESSAGE = 'Finished TRIP_ANALYSIS load'
EXEC EDW_RITE.dbo.LOG_PROCESS @SOURCE, @RUN_DATE, @LOG_MESSAGE, @ROW_COUNT


IF OBJECT_ID('dbo.FACT_TRIP_HISTORY_PART_STAGE') IS NOT NULL DROP TABLE dbo.FACT_TRIP_HISTORY_PART_STAGE;	
IF OBJECT_ID('dbo.FACT_TRIP_LV_HISTORY_STAGE') IS NOT NULL DROP TABLE dbo.FACT_TRIP_LV_HISTORY_STAGE;	
IF OBJECT_ID('dbo.FACT_TRIP_HISTORY_PART_OLD') IS NOT NULL 	DROP TABLE dbo.FACT_TRIP_HISTORY_PART_OLD;
IF OBJECT_ID('dbo.FACT_TRIP_ANALYSIS_PART_OLD') IS NOT NULL 	DROP TABLE dbo.FACT_TRIP_ANALYSIS_PART_OLD;
IF OBJECT_ID('dbo.FACT_NET_REV_TFC_TRIPS') IS NOT NULL DROP TABLE dbo.FACT_NET_REV_TFC_TRIPS;	

/*
SELECT COUNT_BIG(1) FROM FACT_TRIP_HISTORY_PART
SELECT COUNT_BIG(1) FROM FACT_TRIP_ANALYSIS_PART
SELECT * FROM FACT_TRIP_HISTORY_PART_STAGE ORDER BY SECOND_ID

SELECT START_DAY_ID / 100 AS TRIP_MONTH, COUNT_BIG(1), MIN(START_DAY_ID) START_DAY_ID1, MAX(START_DAY_ID) START_DAY_ID2 FROM FACT_TRIP_ANALYSIS_PART GROUP BY START_DAY_ID / 100 ORDER BY 1

*/


--SELECT TOP 10 TRIP_ID
--FROM
--(SELECT TRIP_ID FROM FACT_TRIP_ANALYSIS_PART GROUP BY TRIP_ID HAVING COUNT(1) > 1) A


--SELECT COUNT_BIG(1), MIN(START_DAY_ID), MAX(START_DAY_ID) FROM EDW_RITE.dbo.FACT_TRIP_ANALYSIS
--SELECT COUNT_BIG(1), MIN(START_DAY_ID), MAX(START_DAY_ID) FROM EDW_RITE.dbo.FACT_TRIP_ANALYSIS WHERE START_DAY_ID > 20190101
--SELECT LEFT(CONVERT(VARCHAR,START_DAY_ID),6) TRIP_MONTH, COUNT_BIG(1) ROW_CNT, MIN(START_DAY_ID) START_DAY_ID1, MAX(START_DAY_ID) START_DAY_ID2 FROM EDW_RITE.dbo.FACT_TRIP_ANALYSIS GROUP BY LEFT(CONVERT(VARCHAR,START_DAY_ID),6) ORDER BY 1
--SELECT LEFT(CONVERT(VARCHAR,START_DAY_ID),6) TRIP_MONTH, COUNT_BIG(DISTINCT TRIP_ID) DISTINCT_ROW_CNT, COUNT_BIG(1) ROW_CNT, MIN(START_DAY_ID) START_DAY_ID1, MAX(START_DAY_ID) START_DAY_ID2 FROM EDW_RITE.dbo.FACT_TRIP_ANALYSIS WHERE START_DAY_ID >= 20190601 GROUP BY LEFT(CONVERT(VARCHAR,START_DAY_ID),6) ORDER BY 1

--@TT_CONTROL_DATE DATETIME2(2), @LV_CONTROL_DATE DATETIME2(2)

--SELECT @TT_CONTROL_DATE = MAX(LAST_UPDATE_DATE) FROM  EDW_RITE.dbo.FACT_TOLL_TRANSACTIONS
--DELETE FROM EDW_RITE.dbo.LOAD_PROCESS_CONTROL WHERE TABLE_NAME = 'FACT_TRIP_HISTORY_PART%FACT_TOLL_TRANSACTIONS'
--INSERT	INTO EDW_RITE.dbo.LOAD_PROCESS_CONTROL SELECT TABLE_NAME = 'FACT_TRIP_HISTORY_PART%FACT_TOLL_TRANSACTIONS', LAST_RUN_DATE = @TT_CONTROL_DATE

--SELECT @LV_CONTROL_DATE = MAX(LAST_UPDATE_DATE) FROM  EDW_RITE.dbo.FACT_LANE_VIOLATIONS_DETAIL
--DELETE FROM EDW_RITE.dbo.LOAD_PROCESS_CONTROL WHERE TABLE_NAME = 'FACT_TRIP_HISTORY_PART%FACT_LANE_VIOLATIONS_DETAIL'
--INSERT	INTO EDW_RITE.dbo.LOAD_PROCESS_CONTROL SELECT TABLE_NAME = 'FACT_TRIP_HISTORY_PART%FACT_LANE_VIOLATIONS_DETAIL', LAST_RUN_DATE = @LV_CONTROL_DATE

/*
SELECT 
       ZIP_CASH,ACCT_ID,TAG_ID,LICENSE_PLATE_ID,TRIP_ID,VEHICLE_CLASS,
       FS.FACILITY_ABBREV AS START_FACILITY, PS.PLAZA_ABBREV AS START_PLAZA, START_DIRECTION AS START_DIRECTION,
	   CONVERT(VARCHAR, DATEADD(SECOND, START_TIME_ID, CONVERT(DATETIME2(0), CAST(START_DAY_ID AS VARCHAR), 112)), 121) AS START_DATETIME,
       FE.FACILITY_ABBREV AS END_FACILITY,PE.PLAZA_ABBREV AS END_PLAZA,END_DIRECTION AS END_DIRECTION,
	   CONVERT(VARCHAR, DATEADD(SECOND, END_TIME_ID, CONVERT(DATETIME2(0), CAST(END_DAY_ID AS VARCHAR), 112)), 121) AS END_DATETIME,
       TRIP_DURATION_MINUTES,TRIP_AMOUNT  --- select *
FROM edw_rite.[dbo].[FACT_TRIP_ANALYSIS_PART] AS A
JOIN edw_rite.dbo.DIM_PLAZA AS PS ON A.START_PLAZA_ID = PS.PLAZA_ID
JOIN edw_rite.dbo.DIM_PLAZA AS PE ON A.END_PLAZA_ID = PE.PLAZA_ID
JOIN edw_rite.dbo.DIM_FACILITY AS FS ON A.START_FACILITY_ID = FS.FACILITY_ID
JOIN edw_rite.dbo.DIM_FACILITY AS FE ON A.END_FACILITY_ID = FE.FACILITY_ID
WHERE [START_DAY_ID] >= 20180101 
ORDER BY [ZIP_CASH],[TRIP_ID]

*/


--SELECT TOP 1000 * FROM dbo.FACT_TRIP_ANALYSIS_PART WHERE ACCT_ID = 5052282 ORDER BY ACCT_LIC_PLATE,TAG_STATE,TRIP_ID
--SELECT TOP 1000 * FROM dbo.FACT_TRIP_HISTORY_PART WHERE TRIP_ID = 2017080100171006 ORDER BY ACCT_LIC_PLATE,TAG_STATE,TRIP_ID







