CREATE PROC [DBO].[FACT_UNIFIED_VIOLATION_CONTROL_LOAD] @SNAPSHOT_FIRST_DAY_ID [INT] AS  

/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.FACT_UNIFIED_VIOLATION_CONTROL_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.FACT_UNIFIED_VIOLATION_CONTROL_LOAD
GO

EXEC EDW_RITE.DBO.FACT_UNIFIED_VIOLATION_CONTROL_LOAD 20160101

*/

----TESTING PARAMETERS ONLY!!!!!!!!!!!!!!!!!!
--DECLARE	@SNAPSHOT_FIRST_DAY_ID [INT] = 20160101
--	@NUM_OF_PP TINYINT = 4 -- Number of parallel processes
--	,@MAX_PER TINYINT = 4 -- Number of period in one trunsaction
----TESTING PARAMETERS ONLY!!!!!!!!!!!!!!!!!!


DECLARE @SOURCE VARCHAR(50), @LOG_START_DATE DATETIME2 (2), @PROCEDURE_NAME VARCHAR(1000), @ERROR_MESSAGE VARCHAR(3000)--, @LOAD_CONTROL_DATE DATETIME2(2), @THIS_MONTH_BEGIN DATETIME2(2)
SELECT  @SOURCE = 'FACT_UNIFIED_VIOLATION_SNAPSHOT', @LOG_START_DATE = GETDATE(), @PROCEDURE_NAME = 'FACT_UNIFIED_VIOLATION_CONTROL_LOAD'


-- DEFAULT PARAMETERS
--IF ISNULL(@NUM_OF_PP, 0) = 0 SET @NUM_OF_PP = 4
--IF @NUM_OF_PP > 8 SET @NUM_OF_PP = 8 -- We have only 8 flags in a control table
--IF ISNULL(@MAX_PER, 0) = 0 SET @MAX_PER = 6
IF ISNULL(@SNAPSHOT_FIRST_DAY_ID, 0) < 19900101 SET @SNAPSHOT_FIRST_DAY_ID = 20150101

--IF OBJECT_ID('tempdb..#PartitionDates') IS NOT NULL DROP TABLE #PartitionDates

/*
-- USE THIS TO SET UP UPDATE_FLAG TO THE PERIODS YOU NEED TO LOAD MANUAL

	UPDATE EDW_RITE.DBO.PARTITION_DAY_ID_CONTROL
	SET UPDATE_FLAG = 1
	WHERE TABLE_NAME = 'FACT_UNIFIED_VIOLATION' AND UPDATE_FLAG = 0 AND DAY_ID >= 20180101
	
*/

--STEP #1: -- Checking the last partition - if it need to be splitted

-- Always go 1 month after to be sure the last partition have no data
DECLARE @LAST_DAY_ID INT = CAST((LEFT(CONVERT(VARCHAR(8), DATEADD(MONTH, 1, GetDate()) ,112), 6) + '01') AS INT)
DECLARE @TO_DAY_ID INT = CAST(CONVERT(VARCHAR(8), @LOG_START_DATE,112) AS INT)
DECLARE @sql NVARCHAR(1000)
DECLARE @MAX_PN INT
DECLARE @MAX_BVAL INT
DECLARE @NewStartDate DATE
DECLARE @New_DAY_ID INT

SELECT @MAX_BVAL = MAX(DAY_ID), @MAX_PN = MAX(PARTITION_NUM) FROM EDW_RITE.DBO.PARTITION_DAY_ID_CONTROL WHERE TABLE_NAME = 'FACT_UNIFIED_VIOLATION'

WHILE @MAX_BVAL <= @LAST_DAY_ID
BEGIN
	-- ADD a new row to the control table 
	SET @NewStartDate = DateAdd(MONTH,1,CAST(CAST(@MAX_BVAL AS VARCHAR) AS DATE))
	SET @New_DAY_ID = CONVERT(VARCHAR(8),@NewStartDate,112)  
	
	-- And split the last partition - add new range
	SET @MAX_PN += 1

	INSERT INTO EDW_RITE.DBO.PARTITION_DAY_ID_CONTROL
	SELECT
		TABLE_NAME = 'FACT_UNIFIED_VIOLATION'
		,DAY_ID = @New_DAY_ID
		,END_DAY_ID = CAST(CONVERT(VARCHAR(8),DateAdd(DAY,-1,DateAdd(MONTH,1,@NewStartDate)),112) AS INT)
		,StartDate = @NewStartDate
		,EndDate = DateAdd(DAY,-1,DateAdd(MONTH,1,@NewStartDate))
		,PARTITION_NUM = @MAX_PN
		,CURRENT_IND = CAST(0 AS BIT) 
		,UPDATE_FLAG = CAST(0 AS BIT) 
		,CAST(0 AS BIT) AS FLAG_1
		,CAST(0 AS BIT) AS FLAG_2
		,CAST(0 AS BIT) AS FLAG_3
		,CAST(0 AS BIT) AS FLAG_4
		,CAST(0 AS BIT) AS FLAG_5
		,CAST(0 AS BIT) AS FLAG_6
		,CAST(0 AS BIT) AS FLAG_7
		,CAST(0 AS BIT) AS FLAG_8

	SET @MAX_BVAL = CAST(@New_DAY_ID AS INT)
END -- WHILE @MAX_BVAL <= @LAST_DAY_ID

EXEC DBO.PARTITION_MANAGE_MONTHLY_LOAD 'FACT_UNIFIED_VIOLATION_SNAPSHOT'
EXEC DBO.PARTITION_MANAGE_MONTHLY_LOAD 'FACT_UNIFIED_VIOLATION_HISTORY'


--STEP #4: -- SET ALL flags to 0
-- Full renew table
/**/

CREATE TABLE EDW_RITE.DBO.PARTITION_DAY_ID_CONTROL_NEW
WITH (CLUSTERED INDEX (TABLE_NAME, DAY_ID), DISTRIBUTION = HASH([DAY_ID])) AS
SELECT
	TABLE_NAME
	,DAY_ID
	,END_DAY_ID
	,StartDate
	,EndDate
	,PARTITION_NUM
	,CASE WHEN TABLE_NAME = 'FACT_UNIFIED_VIOLATION' THEN CAST(0 AS BIT) ELSE CURRENT_IND END AS CURRENT_IND
	,CASE WHEN TABLE_NAME = 'FACT_UNIFIED_VIOLATION' THEN CAST(0 AS BIT) ELSE UPDATE_FLAG END AS UPDATE_FLAG
	,CASE WHEN TABLE_NAME = 'FACT_UNIFIED_VIOLATION' THEN CAST(0 AS BIT) ELSE FLAG_1 END AS FLAG_1
	,CASE WHEN TABLE_NAME = 'FACT_UNIFIED_VIOLATION' THEN CAST(0 AS BIT) ELSE FLAG_2 END AS FLAG_2
	,CASE WHEN TABLE_NAME = 'FACT_UNIFIED_VIOLATION' THEN CAST(0 AS BIT) ELSE FLAG_3 END AS FLAG_3
	,CASE WHEN TABLE_NAME = 'FACT_UNIFIED_VIOLATION' THEN CAST(0 AS BIT) ELSE FLAG_4 END AS FLAG_4
	,CASE WHEN TABLE_NAME = 'FACT_UNIFIED_VIOLATION' THEN CAST(0 AS BIT) ELSE FLAG_5 END AS FLAG_5
	,CASE WHEN TABLE_NAME = 'FACT_UNIFIED_VIOLATION' THEN CAST(0 AS BIT) ELSE FLAG_6 END AS FLAG_6
	,CASE WHEN TABLE_NAME = 'FACT_UNIFIED_VIOLATION' THEN CAST(0 AS BIT) ELSE FLAG_7 END AS FLAG_7
	,CASE WHEN TABLE_NAME = 'FACT_UNIFIED_VIOLATION' THEN CAST(0 AS BIT) ELSE FLAG_8 END AS FLAG_8
FROM EDW_RITE.DBO.PARTITION_DAY_ID_CONTROL

IF OBJECT_ID('EDW_RITE.dbo.PARTITION_DAY_ID_CONTROL_OLD') IS NOT NULL	DROP TABLE EDW_RITE.dbo.PARTITION_DAY_ID_CONTROL_OLD;
IF OBJECT_ID('EDW_RITE.dbo.PARTITION_DAY_ID_CONTROL') IS NOT NULL		RENAME OBJECT::EDW_RITE.dbo.PARTITION_DAY_ID_CONTROL TO PARTITION_DAY_ID_CONTROL_OLD;
IF OBJECT_ID('EDW_RITE.dbo.PARTITION_DAY_ID_CONTROL_NEW') IS NOT NULL	RENAME OBJECT::EDW_RITE.dbo.PARTITION_DAY_ID_CONTROL_NEW TO PARTITION_DAY_ID_CONTROL;
IF OBJECT_ID('EDW_RITE.dbo.PARTITION_DAY_ID_CONTROL_OLD') IS NOT NULL	DROP TABLE EDW_RITE.dbo.PARTITION_DAY_ID_CONTROL_OLD;

--STEP #5: -- Update all Flags depends on @NUM_OF_PP (Number of parallel processes) and @MAX_PER (Number of period in one trunsaction)
/*
DECLARE @LM_END_DATE DATE = EOMONTH(GETDATE(),-1)
DECLARE @LM_START_DATE DATE = DATEADD(DAY,1,EOMONTH(@LM_END_DATE,-1))
DECLARE @FIELD_VALUE BIGINT
DECLARE @NEW_FIELD_VALUE BIGINT
DECLARE @LM_START_DAY_ID VARCHAR(8) = CONVERT(VARCHAR,@LM_START_DATE, 112)
DECLARE @LM_END_DAY_ID VARCHAR(8) = CONVERT(VARCHAR,@LM_END_DATE, 112) 
DECLARE @N_OF_CHECK SMALLINT = (SELECT MAX(CHECK_NUMBER) FROM dbo.MONTHLY_LOAD_CHECK_SOURCE_TABLES)
DECLARE @INDICAT SMALLINT = 1
DECLARE @ERRORS SMALLINT = 0
DECLARE @TABLE_NAME NVARCHAR(100)
DECLARE @FILTER_PATTERN NVARCHAR(100)
DECLARE @FIELD_NAME NVARCHAR(100)
DECLARE @FailNotice nvarchar(500)
DECLARE @ParmDefinition nvarchar(100) = N'@NEW_VALUE BIGINT OUTPUT'

WHILE (@INDICAT <= @N_OF_CHECK)
BEGIN

	SELECT @TABLE_NAME = TABLE_NAME, @FILTER_PATTERN = FILTER_PATTERN, @FIELD_NAME = FIELD_NAME, @FIELD_VALUE = FIELD_VALUE 
	FROM dbo.MONTHLY_LOAD_CHECK_SOURCE_TABLES WHERE CHECK_NUMBER = @INDICAT

	--DECLARE @NEW_FIELD_VALUE BIGINT
	DECLARE @Nsql NVARCHAR(1000)

	SET @Nsql = '
	SELECT @NEW_VALUE = ' + @FIELD_NAME + '
	FROM ' + @TABLE_NAME + ' AS T
	WHERE T.' + @FILTER_PATTERN + ' AND DAY_ID BETWEEN ' + @LM_START_DAY_ID + ' AND ' + @LM_END_DAY_ID 
	PRINT @Nsql
	EXECUTE sp_executesql @Nsql, @ParmDefinition, @NEW_VALUE = @NEW_FIELD_VALUE OUTPUT  
	
	SET @FailNotice = 'Check the table ' + @TABLE_NAME + ' <<' + @FILTER_PATTERN + ' >> = ' + CAST(@NEW_FIELD_VALUE AS VARCHAR) + ' not even close to  ' + CAST(@FIELD_VALUE AS VARCHAR)

	IF (@FIELD_VALUE = 0 OR (@NEW_FIELD_VALUE BETWEEN @FIELD_VALUE * 0.8 AND @FIELD_VALUE * 1.2))
	BEGIN
		UPDATE dbo.MONTHLY_LOAD_CHECK_SOURCE_TABLES
		SET FIELD_VALUE = @NEW_FIELD_VALUE
		WHERE CHECK_NUMBER = @INDICAT
	END
	ELSE
	BEGIN
		SET @ERROR_MESSAGE = @PROCEDURE_NAME + ' FAILED: ' + @FailNotice
		EXEC  EDW_RITE.dbo.LOG_PROCESS @SOURCE, @LOG_START_DATE, @ERROR_MESSAGE,  NULL
		SET @ERRORS += 1
	END
	SET @INDICAT += 1
END

IF @ERRORS = 0  -- ALL checks done and everything is OK
BEGIN
*/

	UPDATE EDW_RITE.DBO.PARTITION_DAY_ID_CONTROL
	SET FLAG_1 = 1
	WHERE TABLE_NAME = 'FACT_UNIFIED_VIOLATION' AND DAY_ID BETWEEN @SNAPSHOT_FIRST_DAY_ID AND @TO_DAY_ID

	--EXEC EDW_RITE.DBO.FACT_UNIFIED_VIOLATION_RUN_SNAPSHOT_STAGE_LOAD

	--EXEC EDW_RITE.DBO.FACT_UNIFIED_VIOLATION_RUN_SNAPSHOT_FINAL_LOAD

--END

-- Do not use this now, but should keep it - good algorithm
/*
IF @ERRORS = 0  -- ALL checks done and everything is OK
BEGIN
	SELECT 
		PDC.DAY_ID
		,PDC.PARTITION_NUM
		,Row_Number() OVER (ORDER BY PDC.PARTITION_NUM) AS INDICAT
		,LAG(PDC.PARTITION_NUM, 1, 0) OVER (ORDER BY PDC.PARTITION_NUM) AS PREV_NUM
	INTO #PartitionDates
	FROM EDW_RITE.dbo.PARTITION_DAY_ID_CONTROL AS PDC 
	WHERE PDC.TABLE_NAME = 'FACT_UNIFIED_VIOLATION' AND PDC.UPDATE_FLAG = 1 AND PDC.DAY_ID BETWEEN @SNAPSHOT_FIRST_DAY_ID AND @TO_DAY_ID

	DECLARE @PART_NUM_BEGIN TINYINT
	DECLARE @MAX_NUM TINYINT

	SELECT 
		@PART_NUM_BEGIN = MIN(PDC.PARTITION_NUM)
		,@MAX_NUM = MAX(PDC.INDICAT)
	FROM #PartitionDates AS PDC

	-- DEFAULT parameters
	DECLARE @Cur_Part SMALLINT = @PART_NUM_BEGIN -- (SELECT MIN(PARTITION_NUM) FROM #PartitionDates)
	DECLARE @CUR_PER_NUM TINYINT = 1
	DECLARE @CUR_PROC_NUMBER TINYINT = 1
	DECLARE @PART_ROLL TINYINT
	SET @INDICAT = 1

	SET @sql = '
	UPDATE EDW_RITE.DBO.PARTITION_DAY_ID_CONTROL
	SET FLAG_' + CAST(@CUR_PROC_NUMBER AS VARCHAR) + ' = 1
	WHERE TABLE_NAME = ' + CHAR(39) + 'FACT_UNIFIED_VIOLATION' + CHAR(39) + ' AND PARTITION_NUM = ' + CAST(@Cur_Part AS VARCHAR) + ';'

	EXECUTE (@sql);

	-- If only 1 period (and 1 partition) - @PART_RANGES is empty
	WHILE (@INDICAT < @MAX_NUM)
	BEGIN
		SET @INDICAT += 1

		SELECT @Cur_Part = PD.PARTITION_NUM, @PART_ROLL = PD.PREV_NUM  FROM #PartitionDates AS PD WHERE PD.INDICAT = @INDICAT

		IF (@PART_ROLL + 1) = @Cur_Part -- They goes on by one without gaps
		BEGIN
			-- GET next period
			SET @CUR_PER_NUM = @CUR_PER_NUM + 1
		
			IF  @CUR_PER_NUM > @MAX_PER
			BEGIN
				SET @CUR_PROC_NUMBER = (@CUR_PROC_NUMBER % @NUM_OF_PP) + 1
				SET @CUR_PER_NUM = 1
			END
		END
		ELSE
		BEGIN
			SET @CUR_PROC_NUMBER = (@CUR_PROC_NUMBER % @NUM_OF_PP) + 1
			SET @CUR_PER_NUM = 1
		END

		SET @sql = '
		UPDATE EDW_RITE.DBO.PARTITION_DAY_ID_CONTROL
		SET FLAG_' + CAST(@CUR_PROC_NUMBER AS VARCHAR) + ' = 1
		WHERE TABLE_NAME = ' + CHAR(39) + 'FACT_UNIFIED_VIOLATION' + CHAR(39) + ' AND PARTITION_NUM = ' + CAST(@Cur_Part AS VARCHAR) + ';'

		EXECUTE (@sql);

	END;
	
END

*/
-- THEN we use flags FLAG1 - FLAG8 (depends on number of parallel processes)
-- If it's full load - set flags for all partitions from start date to end date
-- if it's not a full load - use flag UPDATE_FLAG to find only changed periods and set FLAG1 - FLAG8 only for them


-- CREATE AND FIRST FILL dbo.MONTHLY_LOAD_CHECK_SOURCE_TABLES


/*
 DROP TABLE dbo.MONTHLY_LOAD_CHECK_SOURCE_TABLES
 */
 /*
CREATE TABLE dbo.MONTHLY_LOAD_CHECK_SOURCE_TABLES 
WITH (heap, DISTRIBUTION = ROUND_ROBIN)
AS -- EXPLAIN
SELECT
	1 AS CHECK_NUMBER,
	'EDW_RITE.dbo.FACT_NET_REV_TFC_EVTS' AS TABLE_NAME,
	'PMTY_ID = 3' AS FILTER_PATTERN,
	'COUNT_BIG(1)' AS FIELD_NAME,
	CAST(0 AS BIGINT) AS FIELD_VALUE
UNION ALL	
SELECT
	2 AS CHECK_NUMBER,
	'EDW_RITE.dbo.FACT_NET_REV_TFC_EVTS' AS TABLE_NAME,
	'PMTY_ID IN (7,8)' AS FILTER_PATTERN,
	'COUNT_BIG(1)' AS FIELD_NAME,
	CAST(0 AS BIGINT) AS FIELD_VALUE
UNION ALL	
SELECT
	3 AS CHECK_NUMBER,
	'EDW_RITE.dbo.FACT_LANE_VIOLATIONS_DETAIL' AS TABLE_NAME,
	'REVIEW_STATUS IN (''O'')' AS FILTER_PATTERN,
	'COUNT_BIG(1)' AS FIELD_NAME,
	CAST(0 AS BIGINT) AS FIELD_VALUE
UNION ALL	
SELECT
	4 AS CHECK_NUMBER,
	'EDW_RITE.dbo.FACT_LANE_VIOLATIONS_DETAIL' AS TABLE_NAME,
	'REVIEW_STATUS IN (''D'',''R'',''E'')' AS FILTER_PATTERN,
	'COUNT_BIG(1)' AS FIELD_NAME,
	CAST(0 AS BIGINT) AS FIELD_VALUE
*/

/*
DECLARE @LM_END_DATE DATE = EOMONTH(GETDATE(),-1)
DECLARE @LM_START_DATE DATE = DATEADD(DAY,1,EOMONTH(@LM_END_DATE,-1))-- Before this year there was very low number of trunsactions
DECLARE @NEW_FIELD_VALUE BIGINT
DECLARE @LM_START_DAY_ID VARCHAR(8) = CONVERT(VARCHAR,@LM_START_DATE, 112)
DECLARE @LM_END_DAY_ID VARCHAR(8) = CONVERT(VARCHAR,@LM_END_DATE, 112) 
DECLARE @N_OF_CHECK SMALLINT = (SELECT MAX(CHECK_NUMBER) FROM dbo.MONTHLY_LOAD_CHECK_SOURCE_TABLES)
DECLARE @INDICAT SMALLINT = 1
DECLARE @TABLE_NAME NVARCHAR(100)
DECLARE @FILTER_PATTERN NVARCHAR(100)
DECLARE @FIELD_NAME NVARCHAR(100)
DECLARE @ParmDefinition nvarchar(100) = N'@NEW_VALUE BIGINT OUTPUT'

WHILE (@INDICAT <= @N_OF_CHECK)
BEGIN

	SELECT @TABLE_NAME = TABLE_NAME, @FILTER_PATTERN = FILTER_PATTERN, @FIELD_NAME = FIELD_NAME 
	FROM dbo.MONTHLY_LOAD_CHECK_SOURCE_TABLES WHERE CHECK_NUMBER = @INDICAT

	SET @sql = '
	SELECT @NEW_VALUE = ' + @FIELD_NAME + '
	FROM ' + @TABLE_NAME + ' AS T
	WHERE T.' + @FILTER_PATTERN + ' AND DAY_ID BETWEEN ' + @LM_START_DAY_ID + ' AND ' + @LM_END_DAY_ID 

	EXECUTE sp_executesql @sql, @ParmDefinition, @NEW_VALUE = @NEW_FIELD_VALUE OUTPUT  
	
	UPDATE dbo.MONTHLY_LOAD_CHECK_SOURCE_TABLES
	SET FIELD_VALUE = @NEW_FIELD_VALUE
	WHERE CHECK_NUMBER = @INDICAT

	SET @INDICAT += 1

END
*/
