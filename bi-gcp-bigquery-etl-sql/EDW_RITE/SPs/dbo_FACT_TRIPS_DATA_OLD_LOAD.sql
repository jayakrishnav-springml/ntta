CREATE PROC [DBO].[FACT_TRIPS_DATA_OLD_LOAD] AS
-- @StartDate DATE
--AS
/*
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.[FACT_TRIPS_DATA_OLD_LOAD]') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.[FACT_TRIPS_DATA_OLD_LOAD]
GO


EXEC DBO.FACT_TRIPS_DATA_OLD_LOAD

SELECT TOP 1000
	TRIP_ID, Month_ID, DAY_ID,TIME_ID,SECOND_ID,TART_ID,DRIVER_ID,LICENSE_PLATE_ID,ACCT_ID,TT_ID,VIOLATOR_ID,SOURCE_CODE,VEHICLE_CLASS,TXN_TYPE,
	DIRECTION,LANE_ID,PLAZA_ID,FACILITY_ID,PREV_DIRECTION,PREV_PLAZA_ID,PREV_FACILITY_ID,AMOUNT,MILEAGE,MIN_FROM_PREV,TRIP_MIN,TRIP_SEC
FROM dbo.FACT_TRIPS_DETAIL
WHERE TXN_TYPE IN ('TT' ,'TT int','VT 1','VT 2','VT 2zc','VT 3' ,'VT 3zc','VT 4' ,'VT int','Video')

SELECT TOP 1000
	TRIP_ID,Month_ID,DAY_ID,TXN_TYPE,DRIVER_ID,LICENSE_PLATE_ID,ACCT_ID,TT_ID,VIOLATOR_ID,VEHICLE_CLASS,TRIP_MIN,TRIP_SEC,TRIP_MILEAGE,TRIP_AMOUNT,TRANS_CNT,
	START_FACILITY_ID,START_PLAZA_ID,START_DIRECTION,START_TIME_ID,END_FACILITY_ID,END_PLAZA_ID,END_DIRECTION,END_TIME_ID
FROM dbo.FACT_TRIPS_SUMMARY
WHERE TXN_TYPE IN ('TT' ,'TT int','VT 1','VT 2','VT 2zc','VT 3' ,'VT 3zc','VT 4' ,'VT int','Video')


-- !!! TESTING !!! --
DECLARE @StartDate DATE = '2018-10-01';	
-- !!! TESTING !!! --
*/

/*
SELECT * FROM dbo.PROCESS_LOG 
WHERE LOG_SOURCE = 'FACT_TRIPS_DATA' AND LOG_DATE > '2019-11-11 8:00:00' --AND LOG_MESSAGE LIKE '%proc #1%'
ORDER BY LOG_SOURCE, LOG_DATE
*/


DECLARE @StartDate DATE = '2016-01-01';	

IF @StartDate IS NULL SET @StartDate = '2018-01-01'

DECLARE @SOURCE VARCHAR(50), @RUN_DATE DATETIME2 (2), @LOG_MESSAGE VARCHAR(1000), @ROW_COUNT BIGINT 
DECLARE @SQL_DDL VARCHAR(max) = ''		
DECLARE @MILLENIUM_DATE DATE = '20010101'

SELECT  @SOURCE = 'FACT_TRIPS_DATA', @RUN_DATE = SYSDATETIME(), @LOG_MESSAGE = 'Started full load'

DECLARE @START_DAY_ID INT = CAST(CONVERT(VARCHAR(8), @StartDate,112) AS INT);
DECLARE @END_DAY_ID INT = CAST(CONVERT(VARCHAR(8), @RUN_DATE,112) AS INT);

EXEC    dbo.LOG_PROCESS @SOURCE, @RUN_DATE, @LOG_MESSAGE,  NULL


--IF OBJECT_ID('dbo.FACT_TRIPS_DRIVER') IS NULL
BEGIN
	IF OBJECT_ID('dbo.FACT_TRIPS_DRIVER') IS NOT NULL DROP TABLE dbo.FACT_TRIPS_DRIVER;	
	-- EXPLAIN
	CREATE TABLE dbo.FACT_TRIPS_DRIVER WITH (HEAP, DISTRIBUTION = HASH(DRIVER_ID)) AS 
	SELECT 
		COALESCE(CAST(10000000000000 AS BIGINT) + NULLIF(LICENSE_PLATE_ID, -1),CAST(70000000000000 AS BIGINT) + NULLIF(ISNULL(T.TT_ID, I.TT_ID),-1),CAST(40000000000000 AS BIGINT) + NULLIF(CAST(VIOLATOR_ID AS BIGINT), -1), -1) AS DRIVER_ID,TART_ID,
		SOURCE_CODE,LICENSE_PLATE_ID,DAY_ID, Local_Time AS VIOL_DATE,POSTED_REV AS AMOUNT,CAST(VCLY_ID AS SMALLINT) AS VEHICLE_CLASS,LV.LANE_ID,VIOLATOR_ID, ACCT_ID, ISNULL(T.TT_ID, I.TT_ID) AS TT_ID,DIM_LANE.PLAZA_ID, DIM_LANE.FACILITY_ID, DIM_LANE.MILEAGE,
		--CASE 
		--	WHEN SOURCE_CODE IN ('H') THEN 'TollTag' 
		--	WHEN SOURCE_CODE IN ('I') THEN 'TollTag Int' 
		--	WHEN SOURCE_CODE IN ('V') THEN 'Vtoll 1'
		--	WHEN SOURCE_CODE IN ('W') THEN 'Vtoll 2'
		--	WHEN SOURCE_CODE IN ('X') THEN 'Vtoll 2 ZC'
		--	WHEN SOURCE_CODE IN ('M') THEN 'Vtoll 3' 
		--	WHEN SOURCE_CODE IN ('Z') THEN 'Vtoll 3 ZC'
		--	WHEN SOURCE_CODE IN ('O') THEN 'Vtoll 4' 
		--	WHEN SOURCE_CODE IN ('B') THEN 'Vtoll Int'
		--ELSE 'Unknown' END AS TXN_TYPE, 
		CASE 
			WHEN SOURCE_CODE IN ('H') THEN 'TT' 
			WHEN SOURCE_CODE IN ('I') THEN 'TT int' 
			WHEN SOURCE_CODE IN ('V') THEN 'VT 1'
			WHEN SOURCE_CODE IN ('W') THEN 'VT 2'
			WHEN SOURCE_CODE IN ('X') THEN 'VT 2zc'
			WHEN SOURCE_CODE IN ('M') THEN 'VT 3' 
			WHEN SOURCE_CODE IN ('Z') THEN 'VT 3zc'
			WHEN SOURCE_CODE IN ('O') THEN 'VT 4' 
			WHEN SOURCE_CODE IN ('B') THEN 'VT int'
		ELSE 'Video' END AS TXN_TYPE, 
		DIM_LANE.LANE_DIRECTION,DATEDIFF(SECOND,'20010101', Local_Time) AS SECOND_ID,DATEDIFF(SECOND,CAST(Local_Time AS DATE), Local_Time) AS TIME_ID
	FROM DBO.FACT_UNIFIED_VIOLATION_SNAPSHOT LV --_STAGE
	JOIN	dbo.DIM_LANE AS DIM_LANE ON LV.LANE_ID = DIM_LANE.LANE_ID
	LEFT JOIN [DBO].TOLL_TAGS T ON T.TAG_ID = LV.TAG_ID AND T.AGENCY_ID = LV.TAG_AGENCY_ID AND LV.IOP_FLAG = -1
	LEFT JOIN [DBO].IOP_TAGS I ON I.TAG_ID = LV.TAG_ID AND I.AGENCY_ID = LV.TAG_AGENCY_ID AND LV.IOP_FLAG > -1
	WHERE COALESCE(NULLIF(LICENSE_PLATE_ID,-1),NULLIF(ISNULL(T.TT_ID, I.TT_ID),-1),VIOLATOR_ID) > -1 
		AND DAY_ID BETWEEN @START_DAY_ID AND @END_DAY_ID  
		
	OPTION (LABEL = 'FACT_TRIPS_DRIVER LOAD');

	--SELECT COUNT_BIG(1) FROM dbo.FACT_TRIPS_DRIVER		-- 3740657795
	--WHERE DRIVER_ID < 0									-- 109869207


	EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
	SET  @LOG_MESSAGE = 'Finished FACT_TRIPS_DRIVER load'
	EXEC dbo.LOG_PROCESS @SOURCE, @RUN_DATE, @LOG_MESSAGE, @ROW_COUNT
END

--IF OBJECT_ID('dbo.FACT_TRIPS_LAG') IS NULL
BEGIN
	IF OBJECT_ID('dbo.FACT_TRIPS_LAG') IS NOT NULL DROP TABLE dbo.FACT_TRIPS_LAG;	
	-- EXPLAIN
	CREATE TABLE dbo.FACT_TRIPS_LAG WITH (CLUSTERED INDEX (DRIVER_ID,SECOND_ID), DISTRIBUTION = HASH(DRIVER_ID)) AS 
	SELECT 
		TART_ID,DAY_ID,DRIVER_ID,LICENSE_PLATE_ID,VIOLATOR_ID,ACCT_ID,TT_ID,VEHICLE_CLASS,LANE_ID,SOURCE_CODE,TXN_TYPE,AMOUNT,MILEAGE,TIME_ID,LANE_DIRECTION,PLAZA_ID,FACILITY_ID, 
		SECOND_ID + CASE WHEN LAG(SECOND_ID, 1, SECOND_ID) OVER (PARTITION BY DRIVER_ID ORDER BY VIOL_DATE, TART_ID) = SECOND_ID THEN 1 ELSE 0 END  AS SECOND_ID,
		--LAG(VIOL_DATE) OVER (PARTITION BY DRIVER_ID ORDER BY VIOL_DATE, TART_ID),
		(SECOND_ID - LAG(SECOND_ID, 1, SECOND_ID) OVER (PARTITION BY DRIVER_ID ORDER BY VIOL_DATE, TART_ID))  AS Sec_DIFF,
		(SECOND_ID - LAG(SECOND_ID, 1, SECOND_ID) OVER (PARTITION BY DRIVER_ID ORDER BY VIOL_DATE, TART_ID)) / 60 AS MIN_DIFF,
		LAG(LANE_DIRECTION) OVER (PARTITION BY DRIVER_ID ORDER BY VIOL_DATE, TART_ID) AS PREV_LANE_DIRECTION,
		LAG(PLAZA_ID) OVER (PARTITION BY DRIVER_ID ORDER BY VIOL_DATE, TART_ID) AS PREV_PLAZA_ID,
		LAG(FACILITY_ID) OVER (PARTITION BY DRIVER_ID ORDER BY VIOL_DATE, TART_ID) AS PREV_FACILITY_ID
	FROM FACT_TRIPS_DRIVER
	--WHERE DRIVER_ID > -1
	OPTION (LABEL = 'FACT_TRIPS_LAG LOAD');

	EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
	SET  @LOG_MESSAGE = 'Finished FACT_TRIPS_LAG load'
	EXEC dbo.LOG_PROCESS @SOURCE, @RUN_DATE, @LOG_MESSAGE, @ROW_COUNT
END

--IF OBJECT_ID('dbo.FACT_TRIPDRIVER_IDS') IS NULL
BEGIN
	IF OBJECT_ID('dbo.FACT_TRIPDRIVER_IDS') IS NOT NULL DROP TABLE dbo.FACT_TRIPDRIVER_IDS;	
	-- EXPLAIN
	CREATE TABLE dbo.FACT_TRIPDRIVER_IDS WITH (CLUSTERED INDEX (DRIVER_ID,TRIPDRIVER_ID), DISTRIBUTION = HASH(DRIVER_ID)) AS 
	WITH CTE_WF AS
	(
		SELECT 
			DAY_ID,TIME_ID,SECOND_ID,TART_ID,DRIVER_ID,LICENSE_PLATE_ID,ACCT_ID,TT_ID,VIOLATOR_ID,SOURCE_CODE,VEHICLE_CLASS,TXN_TYPE,LANE_DIRECTION,LANE_ID,PLAZA_ID,FACILITY_ID,
			PREV_LANE_DIRECTION,PREV_PLAZA_ID,PREV_FACILITY_ID,AMOUNT,MILEAGE,Sec_DIFF,MIN_DIFF,PC.MAX_TIME,PC.MIN_TIME,
			CASE	WHEN PREV_PLAZA_ID IS NULL THEN 1
					WHEN PC.MAX_TIME IS NULL THEN 1 -- No connection at all
					WHEN MIN_DIFF > PC.MAX_TIME THEN 1
					WHEN MIN_DIFF < PC.MIN_TIME THEN 1 -- That means it's a mistake
					--NOT EXISTS (SELECT 1 FROM dbo.PLAZA_PLAZA_XREF PC WHERE PC.FROM_PLAZA_ID = RD.PREV_PLAZA_ID AND PC.TO_PLAZA_ID = RD.PLAZA_ID AND PC.FROM_LANE_DIRECTION = RD.PREV_LANE_DIRECTION AND PC.TO_LANE_DIRECTION = RD.LANE_DIRECTION AND RD.MIN_DIFF <= PC.MAX_TIME) THEN 1
					ELSE 0 
			END AS IS_ENTRANCE
		FROM FACT_TRIPS_LAG AS RD
		LEFT JOIN dbo.PLAZA_PLAZA_XREF PC ON PC.FROM_PLAZA_ID = RD.PREV_PLAZA_ID AND PC.TO_PLAZA_ID = RD.PLAZA_ID AND PC.FROM_LANE_DIRECTION = RD.PREV_LANE_DIRECTION AND PC.TO_LANE_DIRECTION = RD.LANE_DIRECTION
	)
	SELECT	
		DAY_ID,TIME_ID,SECOND_ID,TART_ID,DRIVER_ID,LICENSE_PLATE_ID,ACCT_ID,TT_ID,VIOLATOR_ID,SOURCE_CODE,VEHICLE_CLASS,TXN_TYPE,LANE_DIRECTION,LANE_ID,PLAZA_ID,FACILITY_ID,
		PREV_LANE_DIRECTION,PREV_PLAZA_ID,PREV_FACILITY_ID,AMOUNT,MILEAGE,Sec_DIFF,MIN_DIFF,IS_ENTRANCE, (IS_ENTRANCE + 1) % 2 AS NOT_ENTRANCE,MAX_TIME,MIN_TIME,
		SUM(IS_ENTRANCE) OVER (PARTITION BY DRIVER_ID ORDER BY SECOND_ID, TART_ID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TRIPDRIVER_ID
	FROM CTE_WF
	OPTION (LABEL = 'FACT_TRIPDRIVER_IDS LOAD');

	EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
	SET  @LOG_MESSAGE = 'Finished FACT_TRIPS_Borders load'
	EXEC dbo.LOG_PROCESS @SOURCE, @RUN_DATE, @LOG_MESSAGE, @ROW_COUNT
END 


DECLARE @PART_RANGES VARCHAR(MAX) = '' --, @SQL_DDL VARCHAR(max) = '', @ROW_COUNT BIGINT
EXEC DBO.GET_PARTITION_MONTH_RANGE_STRING @PART_RANGES OUTPUT

--IF OBJECT_ID('dbo.FACT_TRIPS_DETAIL_NEW_SET') IS NULL
BEGIN
	IF OBJECT_ID('dbo.FACT_TRIPS_DETAIL_NEW_SET') IS NOT NULL DROP TABLE dbo.FACT_TRIPS_DETAIL_NEW_SET;	

	SET @SQL_DDL = '
	CREATE TABLE dbo.FACT_TRIPS_DETAIL_NEW_SET WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TART_ID), PARTITION (MONTH_ID RANGE RIGHT FOR VALUES (' + @PART_RANGES + '))) AS 
	-- EXPLAIN
	SELECT 
		MIN(TART_ID) OVER (PARTITION BY DRIVER_ID, TRIPDRIVER_ID) AS TRIP_ID, 
		DAY_ID / 100 AS Month_ID, DAY_ID,TIME_ID,SECOND_ID,TART_ID,DRIVER_ID,LICENSE_PLATE_ID,ACCT_ID,TT_ID,VIOLATOR_ID,SOURCE_CODE,VEHICLE_CLASS,
		TXN_TYPE,CAST(LEFT(LANE_DIRECTION,1) AS CHAR(1)) AS DIRECTION,LANE_ID,PLAZA_ID,FACILITY_ID,CAST(LEFT(PREV_LANE_DIRECTION,1) AS CHAR(1)) AS PREV_DIRECTION,PREV_PLAZA_ID,PREV_FACILITY_ID,AMOUNT,MILEAGE,MIN_DIFF AS MIN_FROM_PREV,
		NOT_ENTRANCE * MIN_DIFF AS TRIP_MIN, (NOT_ENTRANCE * (Sec_DIFF - MIN_DIFF * 60)) AS TRIP_SEC													
	FROM FACT_TRIPDRIVER_IDS
	OPTION (LABEL = ''FACT_TRIPS_STAGE LOAD'');'
	EXEC(@SQL_DDL)

	--TRHL_ID,TART_ID,TRIP_ID,SECOND_ID,DAY_ID,TIME_ID, TXN_TYPE, ACCT_ID, TAG_ID, VIOLATOR_ID, LICENSE_PLATE_ID,VEHICLE_CLASS,LANE_ID,PLAZA_ID,FACILITY_ID,DIRECTION,DURATION_MINUTES,MILEAGE,AMOUNT

	EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT

	CREATE STATISTICS FACT_TRIPS_DETAIL_001 ON [dbo].FACT_TRIPS_DETAIL_NEW_SET (TXN_TYPE,VEHICLE_CLASS)
	CREATE STATISTICS FACT_TRIPS_DETAIL_002 ON [dbo].FACT_TRIPS_DETAIL_NEW_SET (ACCT_ID,TT_ID)
	CREATE STATISTICS FACT_TRIPS_DETAIL_003 ON [dbo].FACT_TRIPS_DETAIL_NEW_SET (DAY_ID,TIME_ID)
	CREATE STATISTICS FACT_TRIPS_DETAIL_004 ON [dbo].FACT_TRIPS_DETAIL_NEW_SET (LICENSE_PLATE_ID)
	CREATE STATISTICS FACT_TRIPS_DETAIL_005 ON [dbo].FACT_TRIPS_DETAIL_NEW_SET (TRIP_ID)
	CREATE STATISTICS FACT_TRIPS_DETAIL_006 ON [dbo].FACT_TRIPS_DETAIL_NEW_SET (TART_ID)
	CREATE STATISTICS FACT_TRIPS_DETAIL_007 ON [dbo].FACT_TRIPS_DETAIL_NEW_SET (SECOND_ID)
	CREATE STATISTICS FACT_TRIPS_DETAIL_008 ON [dbo].FACT_TRIPS_DETAIL_NEW_SET (FACILITY_ID,PLAZA_ID)
	CREATE STATISTICS FACT_TRIPS_DETAIL_009 ON [dbo].FACT_TRIPS_DETAIL_NEW_SET (VIOLATOR_ID)

	SET  @LOG_MESSAGE = 'Finished FACT_TRIPS_DETAIL load'
	EXEC dbo.LOG_PROCESS @SOURCE, @RUN_DATE, @LOG_MESSAGE, @ROW_COUNT
END

IF OBJECT_ID('dbo.FACT_TRIPS_DETAIL_OLD') IS NOT NULL 	DROP TABLE dbo.FACT_TRIPS_DETAIL_OLD;
IF OBJECT_ID('dbo.FACT_TRIPS_DETAIL') IS NOT NULL		RENAME OBJECT::dbo.FACT_TRIPS_DETAIL TO FACT_TRIPS_DETAIL_OLD;
RENAME OBJECT::dbo.FACT_TRIPS_DETAIL_NEW_SET TO FACT_TRIPS_DETAIL;


--SELECT * FROM dbo.FACT_TRIPS_DETAIL

--DECLARE @PART_RANGES VARCHAR(MAX) = '', @SQL_DDL VARCHAR(max) = '', @ROW_COUNT BIGINT
--EXEC DBO.GET_PARTITION_MONTH_RANGE_STRING @PART_RANGES OUTPUT

--IF OBJECT_ID('dbo.FACT_TRIPS_SUMMARY_NEW_SET') IS NULL
BEGIN
	IF OBJECT_ID('dbo.FACT_TRIPS_SUMMARY_NEW_SET') IS NOT NULL DROP TABLE dbo.FACT_TRIPS_SUMMARY_NEW_SET;	

	SET @SQL_DDL = '
	CREATE TABLE dbo.FACT_TRIPS_SUMMARY_NEW_SET WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TRIP_ID), PARTITION (MONTH_ID RANGE RIGHT FOR VALUES ('+@PART_RANGES+'))) AS
	WITH CTE_GROUP_VALUES AS
	(
	SELECT
		TRIP_ID, MAX(SECOND_ID) AS MAX_ID, MIN(SECOND_ID) AS MIN_ID, (SUM(TRIP_MIN) + SUM(TRIP_SEC) / 60) AS TRIP_MIN, SUM(TRIP_SEC) % 60 TRIP_SEC,  SUM(MILEAGE) AS TRIP_MILEAGE,SUM(AMOUNT) AS TRIP_AMOUNT, COUNT(1) AS TRANS_CNT
	FROM dbo.FACT_TRIPS_DETAIL
	GROUP BY TRIP_ID
	)
	, CTE_FINAL AS
	(
		SELECT
			CTE.TRIP_ID,FR.TXN_TYPE,FR.Month_ID,FR.DAY_ID,
			ISNULL(NULLIF(FR.DRIVER_ID, -1), LR.DRIVER_ID) AS DRIVER_ID,
			ISNULL(NULLIF(FR.LICENSE_PLATE_ID, -1), LR.LICENSE_PLATE_ID) AS LICENSE_PLATE_ID,
			ISNULL(NULLIF(FR.ACCT_ID, -1), LR.ACCT_ID) AS ACCT_ID,
			ISNULL(NULLIF(FR.TT_ID, -1), LR.TT_ID) AS TT_ID,
			ISNULL(NULLIF(FR.VIOLATOR_ID, -1), LR.VIOLATOR_ID) AS VIOLATOR_ID,
			ISNULL(NULLIF(FR.VEHICLE_CLASS, -1), LR.VEHICLE_CLASS) AS VEHICLE_CLASS,
			CTE.TRIP_MIN,CTE.TRIP_SEC,CTE.TRIP_MILEAGE,CTE.TRIP_AMOUNT,CTE.TRANS_CNT,
			FR.FACILITY_ID AS START_FACILITY_ID,FR.PLAZA_ID AS START_PLAZA_ID,FR.DIRECTION AS START_DIRECTION,FR.TIME_ID AS START_TIME_ID,
			LR.FACILITY_ID AS END_FACILITY_ID,LR.PLAZA_ID AS END_PLAZA_ID,LR.DIRECTION AS END_DIRECTION,LR.TIME_ID AS END_TIME_ID,
			ROW_NUMBER() OVER (PARTITION BY CTE.TRIP_ID ORDER BY CTE.TRIP_MIN DESC, CTE.TRIP_AMOUNT DESC) RN
		FROM CTE_GROUP_VALUES AS CTE
			JOIN dbo.FACT_TRIPS_DETAIL AS FR ON FR.TRIP_ID = CTE.TRIP_ID AND FR.SECOND_ID = CTE.MIN_ID
			JOIN dbo.FACT_TRIPS_DETAIL AS LR ON LR.TRIP_ID = CTE.TRIP_ID AND LR.SECOND_ID = CTE.MAX_ID
	)
	SELECT  
		TRIP_ID,Month_ID,DAY_ID,TXN_TYPE,DRIVER_ID,LICENSE_PLATE_ID,ACCT_ID,TT_ID,VIOLATOR_ID,VEHICLE_CLASS,TRIP_MIN,TRIP_SEC,TRIP_MILEAGE,TRIP_AMOUNT,TRANS_CNT,
		START_FACILITY_ID,START_PLAZA_ID,START_DIRECTION,START_TIME_ID,END_FACILITY_ID,END_PLAZA_ID,END_DIRECTION,END_TIME_ID
	FROM CTE_FINAL
	WHERE RN = 1
	OPTION (LABEL = ''FACT_TRIPS_SUMMARY LOAD'');'
	EXEC(@SQL_DDL)   

	EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT

	CREATE STATISTICS FACT_TRIPS_SUMMARY_001 ON [dbo].FACT_TRIPS_SUMMARY_NEW_SET (TXN_TYPE,VEHICLE_CLASS)
	CREATE STATISTICS FACT_TRIPS_SUMMARY_002 ON [dbo].FACT_TRIPS_SUMMARY_NEW_SET (ACCT_ID,TT_ID)
	CREATE STATISTICS FACT_TRIPS_SUMMARY_003 ON [dbo].FACT_TRIPS_SUMMARY_NEW_SET (DAY_ID)
	CREATE STATISTICS FACT_TRIPS_SUMMARY_004 ON [dbo].FACT_TRIPS_SUMMARY_NEW_SET (LICENSE_PLATE_ID)
	CREATE STATISTICS FACT_TRIPS_SUMMARY_005 ON [dbo].FACT_TRIPS_SUMMARY_NEW_SET (TRIP_ID)
	CREATE STATISTICS FACT_TRIPS_SUMMARY_006 ON [dbo].FACT_TRIPS_SUMMARY_NEW_SET (VEHICLE_CLASS)
	CREATE STATISTICS FACT_TRIPS_SUMMARY_007 ON [dbo].FACT_TRIPS_SUMMARY_NEW_SET (START_FACILITY_ID,START_PLAZA_ID)
	CREATE STATISTICS FACT_TRIPS_SUMMARY_008 ON [dbo].FACT_TRIPS_SUMMARY_NEW_SET (END_FACILITY_ID,END_PLAZA_ID)
	CREATE STATISTICS FACT_TRIPS_SUMMARY_009 ON [dbo].FACT_TRIPS_SUMMARY_NEW_SET (VIOLATOR_ID)

	SET  @LOG_MESSAGE = 'Finished FACT_TRIPS_SUMMARY load'
	EXEC dbo.LOG_PROCESS @SOURCE, @RUN_DATE, @LOG_MESSAGE, @ROW_COUNT

END
IF OBJECT_ID('dbo.FACT_TRIPS_SUMMARY_OLD') IS NOT NULL 	DROP TABLE dbo.FACT_TRIPS_SUMMARY_OLD;
IF OBJECT_ID('dbo.FACT_TRIPS_SUMMARY') IS NOT NULL	RENAME OBJECT::dbo.FACT_TRIPS_SUMMARY TO FACT_TRIPS_SUMMARY_OLD;
RENAME OBJECT::dbo.FACT_TRIPS_SUMMARY_NEW_SET TO FACT_TRIPS_SUMMARY;

/*
SELECT TRANS_CNT, COUNT(1) CNT
FROM FACT_TRIPS_SUMMARY
GROUP BY TRANS_CNT
ORDER BY TRANS_CNT
*/

IF OBJECT_ID('dbo.FACT_TRIPS_DRIVER') IS NOT NULL DROP TABLE dbo.FACT_TRIPS_DRIVER;	
IF OBJECT_ID('dbo.FACT_TRIPS_LAG') IS NOT NULL DROP TABLE dbo.FACT_TRIPS_LAG;	
IF OBJECT_ID('dbo.FACT_TRIPDRIVER_IDS') IS NOT NULL DROP TABLE dbo.FACT_TRIPDRIVER_IDS;	
IF OBJECT_ID('dbo.FACT_TRIPS_STAGE') IS NOT NULL DROP TABLE dbo.FACT_TRIPS_STAGE;	

IF OBJECT_ID('dbo.FACT_TRIPS_DETAIL_OLD') IS NOT NULL 	DROP TABLE dbo.FACT_TRIPS_DETAIL_OLD;
IF OBJECT_ID('dbo.FACT_TRIPS_SUMMARY_OLD') IS NOT NULL 	DROP TABLE dbo.FACT_TRIPS_SUMMARY_OLD;









