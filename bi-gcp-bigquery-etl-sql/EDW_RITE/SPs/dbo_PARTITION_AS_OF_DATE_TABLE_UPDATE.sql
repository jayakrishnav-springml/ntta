CREATE PROC [dbo].[PARTITION_AS_OF_DATE_TABLE_UPDATE] @TABLE_NAME [varchar](255),@AS_OF_DATE [date] AS

EXEC EDW_RITE.DBO.PARTITION_MANAGE_AS_OF_DATE_LOAD @TABLE_NAME

/*
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.PARTITION_AS_OF_DATE_TABLE_UPDATE') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.PARTITION_AS_OF_DATE_TABLE_UPDATE
GO


*/

DECLARE @DATA_AS_OF_DATE [date] = (SELECT MAX(PARTITION_DATE) FROM dbo.PARTITION_AS_OF_DATE_CONTROL) --  WHERE CURRENT_IND = 1)) 

IF @AS_OF_DATE > @DATA_AS_OF_DATE
BEGIN

	IF OBJECT_ID('EDW_RITE.dbo.PARTITION_AS_OF_DATE_CONTROL_NEW_SET') IS NOT NULL	DROP TABLE EDW_RITE.dbo.PARTITION_AS_OF_DATE_CONTROL_NEW_SET;
	CREATE TABLE EDW_RITE.dbo.[PARTITION_AS_OF_DATE_CONTROL_NEW_SET] WITH (CLUSTERED INDEX ( [PARTITION_DATE] ), DISTRIBUTION = REPLICATE)
	AS 
	SELECT 
			 ISNULL(CAST(main_table.[PARTITION_DATE] AS date), '1900-01-01') AS [PARTITION_DATE]
			, ISNULL(CAST(main_table.[DATA_AS_OF_DATE] AS date), '1900-01-01') AS [DATA_AS_OF_DATE]
			, ISNULL(CAST(main_table.[KEEP_PARTITION_IND] AS bit), 0) AS [KEEP_PARTITION_IND]
			, ISNULL(CAST('0' AS char(1)), '0') AS [CURRENT_IND]
	FROM EDW_RITE.dbo.[PARTITION_AS_OF_DATE_CONTROL] AS main_table
	WHERE [PARTITION_DATE] < @AS_OF_DATE
	UNION ALL
	SELECT 
			 ISNULL(CAST(@AS_OF_DATE AS date), '1900-01-01') AS [PARTITION_DATE]
			, ISNULL(CAST(DATEADD(DAY, -1, @AS_OF_DATE) AS date), '1900-01-01') AS [DATA_AS_OF_DATE]
			, ISNULL(CAST(1 AS bit), 0) AS [KEEP_PARTITION_IND]
			, ISNULL(CAST('1' AS char(1)), '1') AS [CURRENT_IND]
	OPTION (LABEL = 'PARTITION_AS_OF_DATE_CONTROL_NEW_SET LOAD');

	CREATE STATISTICS [STATS_PARTITION_AS_OF_DATE_CONTROL_001] ON EDW_RITE.dbo.[PARTITION_AS_OF_DATE_CONTROL_NEW_SET] ([PARTITION_DATE]);
	CREATE STATISTICS [STATS_PARTITION_AS_OF_DATE_CONTROL_002] ON EDW_RITE.dbo.[PARTITION_AS_OF_DATE_CONTROL_NEW_SET] ([PARTITION_DATE], [DATA_AS_OF_DATE]);
	CREATE STATISTICS [STATS_PARTITION_AS_OF_DATE_CONTROL_003] ON EDW_RITE.dbo.[PARTITION_AS_OF_DATE_CONTROL_NEW_SET] ([PARTITION_DATE], [KEEP_PARTITION_IND]);

	IF OBJECT_ID('EDW_RITE.dbo.PARTITION_AS_OF_DATE_CONTROL_OLD') IS NOT NULL		DROP TABLE EDW_RITE.dbo.[PARTITION_AS_OF_DATE_CONTROL_OLD];
	IF OBJECT_ID('EDW_RITE.dbo.PARTITION_AS_OF_DATE_CONTROL') IS NOT NULL			RENAME OBJECT::EDW_RITE.dbo.PARTITION_AS_OF_DATE_CONTROL TO [PARTITION_AS_OF_DATE_CONTROL_OLD];
	IF OBJECT_ID('EDW_RITE.dbo.PARTITION_AS_OF_DATE_CONTROL_NEW_SET') IS NOT NULL	RENAME OBJECT::EDW_RITE.dbo.PARTITION_AS_OF_DATE_CONTROL_NEW_SET TO [PARTITION_AS_OF_DATE_CONTROL];
	IF OBJECT_ID('EDW_RITE.dbo.PARTITION_AS_OF_DATE_CONTROL_OLD') IS NOT NULL		DROP TABLE EDW_RITE.dbo.[PARTITION_AS_OF_DATE_CONTROL_OLD];

END


-- Below the old code - keep it for couple months
/*
BEGIN 
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
DROP PROC [dbo].[PARTITION_AS_OF_DATE_TABLE_UPDATE] 

Purpose:   To Manage the Partitions on Tables with an AS_OF_DATE Partition

Notes:
		- The Table PARTITION_AS_OF_DATE_CONTROL contains a list for every parition loaded 
			- This control table has a bit field called KEEP_PARTITION_IND which allows any given day's parition to be left alone and not dropped
			- The default for the 1st day of each month is to keep the partition
			- The field called DATA_AS_OF_DATE is for the Front end to display the end of each month 
		 
 
		Setup for the Process
		- Target Table Must have a Field called AS_OF_DATE and Must Be Partitioned on AS_OF_DATE
		- The Name of the Target Partitioned Table must be entered into the table called "PARTITION_AS_OF_DATE_TABLE"
			- This Table has the Distribution SQL code and index code required to create each mirrored table for the switch that occurs
			- The Partition Switch table which will be [TABLE_NAME] + "_PARTITION_TRUNCATE" will have the last partition to be dropped 
				- This allows for possibility of recovery on any given day
		- 


		
	SELECT * FROM PARTITION_AS_OF_DATE_CONTROL
	SELECT * FROM PARTITION_AS_OF_DATE_INFO  WHERE TABLE_NAME = 'FACT_VIOLATION'


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

	--DECLARE @TABLE_NAME varchar(255) = 'DIM_VIOLATOR_ASOF'
	--DECLARE @AS_OF_DATE date  = '2019-01-01'
	SELECT * FROM PARTITION_AS_OF_DATE_CONTROL 

	SELECT * FROM PARTITION_AS_OF_DATE_TABLE WHERE TABLE_NAME = @TABLE_NAME
	SET @AS_OF_DATE = DATEADD(DAY,1,EOMONTH(@AS_OF_DATE,-1))

	--PRINT @AS_OF_DATE

	DECLARE @TABLE_NAME_FOR_TRUNCATE varchar(1000) = (SELECT @TABLE_NAME +  '_PARTITION_TRUNCATE')

	DECLARE @DEBUG_PRINT bit = 0
	DECLARE @EXECSQL bit = 1
	DECLARE @MSG varchar(500) = ''
	DECLARE @DISTRIBUTION_SQL varchar(500) = (SELECT DISTRIBUTION_SQL FROM PARTITION_AS_OF_DATE_TABLE WHERE TABLE_NAME = @TABLE_NAME)
	DECLARE @INDEX_SQL varchar(500) = (SELECT INDEX_SQL FROM PARTITION_AS_OF_DATE_TABLE WHERE TABLE_NAME = @TABLE_NAME)

	SET @MSG = 'Failure in Procedure PARTITION_AS_OF_DATE_TABLE_UPDATE. There was no entry in PARTITION_AS_OF_DATE_TABLE for table = ' + @TABLE_NAME 
	IF @DISTRIBUTION_SQL IS NULL or len(@DISTRIBUTION_SQL) = 0 
		BEGIN
			RAISERROR(@MSG,16,1)
		END 

	IF @INDEX_SQL IS NULL or len(@INDEX_SQL) = 0 
		RAISERROR(@MSG,16,1)

	-- Update the Partition Information for the Target Table
	EXEC PARTITION_AS_OF_DATE_INFO_UPDATE @TABLE_NAME
	IF @DEBUG_PRINT = 1
		SELECT 'PARTITION_AS_OF_DATE_INFO BEFORE' AS MESSAGE_CONTENT, * FROM PARTITION_AS_OF_DATE_INFO WHERE TABLE_NAME = 'DIM_VIOLATOR_ASOF' ORDER BY 1,2

	-- NEW PARTITION_AS_OF_DATE_CONTROL ENTRY
	DECLARE @SQLNewPartControlEntry varchar(8000) = 
		'INSERT INTO dbo.PARTITION_AS_OF_DATE_CONTROL SELECT ''' + convert(varchar(10),@AS_OF_DATE,121) + '''
		,''' + convert(varchar(10),DATEADD(d,-1,@AS_OF_DATE),121) + '''
		,CASE WHEN DATEPART(dd,''' + convert(varchar(10),@AS_OF_DATE,121) + ''') = 1 THEN 1 ELSE 0 END AS KEEP_PARTITION_IND
		, 0 AS CURRENT_IND
		WHERE NOT EXISTS(SELECT * FROM PARTITION_AS_OF_DATE_CONTROL WHERE PARTITION_DATE = ''' + convert(varchar(10),@AS_OF_DATE,121) + ''')'

	IF @DEBUG_PRINT = 1
		PRINT @SQLNewPartControlEntry
	--IF @EXECSQL = 1 -- REALLY CAN do this all the time
		EXEC(@SQLNewPartControlEntry)



	-- MAX AS OF DATE FROM the TARGET TABLE
	DECLARE @SQLMaxLastASOfDate varchar(8000) = 
		'IF OBJECT_ID(''tempdb..#AS_OF_DATE'')<>0
			DROP TABLE #AS_OF_DATE
		BEGIN 
			CREATE TABLE #AS_OF_DATE WITH (LOCATION = USER_DB, DISTRIBUTION=REPLICATE) 
			AS 

			SELECT TOP 1 RANGE_TO_INCLUDING AS AS_OF_DATE FROM PARTITION_AS_OF_DATE_INFO WHERE TABLE_NAME LIKE ''' + @TABLE_NAME + ''' AND RANGE_TO_INCLUDING <> ''9999-12-31'' ORDER BY RANGE_TO_INCLUDING DESC

		END
		'

/*
			SELECT PARTITION_DATE AS AS_OF_DATE FROM dbo.' + @TABLE_NAME + ' GROUP BY PARTITION_DATE
			UNION 
			SELECT PARTITION_DATE AS AS_OF_DATE FROM dbo.PARTITION_AS_OF_DATE_CONTROL GROUP BY PARTITION_DATE
*/
		


	IF @DEBUG_PRINT = 1
		PRINT (@SQLMaxLastASOfDate)
	--IF @EXECSQL = 1 -- REALLY CAN do this all the time
		EXEC (@SQLMaxLastASOfDate)

	DECLARE @MAX_LAST_AS_OF_DATE date = (SELECT TOP 1 AS_OF_DATE FROM #AS_OF_DATE ORDER BY AS_OF_DATE DESC)
	-- Drop as soon as possible on this temp table
	IF OBJECT_ID('tempdb..#AS_OF_DATE')<>0
			DROP TABLE #AS_OF_DATE

	DECLARE @TRUNC_PART_DATE date = (SELECT TOP 1 RANGE_TO_INCLUDING  FROM dbo.PARTITION_AS_OF_DATE_INFO WHERE TABLE_NAME = @TABLE_NAME AND @MAX_LAST_AS_OF_DATE >= RANGE_TO_INCLUDING ORDER BY RANGE_TO_INCLUDING ASC)
	DECLARE @MAX_PARTITION_NBR int = (SELECT TOP 1 PARTITION_NBR FROM dbo.PARTITION_AS_OF_DATE_INFO WHERE TABLE_NAME = @TABLE_NAME ORDER BY PARTITION_NBR DESC)
	DECLARE @PARTITION_NBR_FOR_AS_OF_DATE int = (SELECT TOP 1 PARTITION_NBR FROM dbo.PARTITION_AS_OF_DATE_INFO WHERE TABLE_NAME = @TABLE_NAME AND @MAX_LAST_AS_OF_DATE<= RANGE_TO_INCLUDING ORDER BY RANGE_TO_INCLUDING ASC)
	DECLARE @KEEP_LAST_PARTITION_IND int = (SELECT ISNULL(KEEP_PARTITION_IND,1) FROM PARTITION_AS_OF_DATE_CONTROL WHERE PARTITION_DATE = @MAX_LAST_AS_OF_DATE)

	IF @DEBUG_PRINT = 1
		SELECT 'Variables in Script'			AS MESSAGE_CONTENT
			, @MAX_PARTITION_NBR				AS MAX_PARTITION_NBR
			, @PARTITION_NBR_FOR_AS_OF_DATE		AS PARTITION_NBR_FOR_AS_OF_DATE
			, @TRUNC_PART_DATE					AS TRUNC_PART_DATE
			, @MAX_LAST_AS_OF_DATE				AS MAX_LAST_AS_OF_DATE
			, @KEEP_LAST_PARTITION_IND			AS KEEP_PARTITION_IND
			, @AS_OF_DATE						AS AS_OF_DATE
			, @DISTRIBUTION_SQL					AS DISTRIBUTION_SQL
			, @INDEX_SQL						AS INDEX_SQL


			DECLARE @SQLCreateTruncTbl varchar(8000) = '		
				IF OBJECT_ID(''' + @TABLE_NAME_FOR_TRUNCATE + ''')<>0
						DROP TABLE ' + @TABLE_NAME_FOR_TRUNCATE + '

					CREATE TABLE dbo.' + @TABLE_NAME_FOR_TRUNCATE + '
						WITH 
							(
								  DISTRIBUTION = ' + @DISTRIBUTION_SQL + '
								, ' + ISNULL(@INDEX_SQL,'') + '
								, PARTITION ( PARTITION_DATE 
											RANGE LEFT FOR VALUES 
											(
											   ''' + convert(varchar(10),@TRUNC_PART_DATE,121) + '''
											))

							) 
					AS 
					SELECT * FROM ' + @TABLE_NAME + ' WHERE 1=2'

				
			IF @DEBUG_PRINT = 1
				PRINT @SQLCreateTruncTbl
			--IF @EXECSQL = 1 -- REALLY CAN do this all the time
				EXEC (@SQLCreateTruncTbl)


			EXEC PARTITION_AS_OF_DATE_INFO_UPDATE @TABLE_NAME_FOR_TRUNCATE
			IF @DEBUG_PRINT = 1
				SELECT 'PARTITION_TRUNCATE' AS MESSAGE_CONTENT, * FROM PARTITION_AS_OF_DATE_INFO WHERE TABLE_NAME = @TABLE_NAME_FOR_TRUNCATE ORDER BY 1,2

			DECLARE @PARTITION_NBR_FOR_TRUNCATE int = (SELECT TOP 1 PARTITION_NBR FROM dbo.PARTITION_AS_OF_DATE_INFO WHERE TABLE_NAME = @TABLE_NAME_FOR_TRUNCATE AND @MAX_LAST_AS_OF_DATE<= RANGE_TO_INCLUDING ORDER BY RANGE_TO_INCLUDING ASC)

			IF @DEBUG_PRINT = 1
				SELECT @PARTITION_NBR_FOR_TRUNCATE AS PARTITION_NBR_FOR_TRUNCATE

			-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
			-- -- -- -- -- MOVE THE OLD DATA TO TRUNCATE TABLE -- -- -- -- -- 
			-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
			-- Move Old Partition to TRUNCATE TABLE 
			IF (ISNULL(@KEEP_LAST_PARTITION_IND,0) <> 1) OR (@MAX_LAST_AS_OF_DATE = @AS_OF_DATE)
			BEGIN 
				DECLARE @SQLSwitchPartitionToTruncateTbl varchar(8000) = 'ALTER TABLE ' + @TABLE_NAME + ' SWITCH PARTITION ' + convert(varchar(10),@PARTITION_NBR_FOR_AS_OF_DATE) + ' TO ' + @TABLE_NAME + '_PARTITION_TRUNCATE PARTITION ' + convert(varchar(100),@PARTITION_NBR_FOR_TRUNCATE) 
				IF @DEBUG_PRINT = 1
					PRINT @SQLSwitchPartitionToTruncateTbl
				--IF @EXECSQL = 1
					EXEC (@SQLSwitchPartitionToTruncateTbl)
			END
--PRINT 'DO NOT SPLIT Partition  IF YOU ARE REPROCESSING A DAY'
--PRINT '@MAX_LAST_AS_OF_DATE'
--PRINT @MAX_LAST_AS_OF_DATE
--PRINT '@AS_OF_DATE'
--PRINT @AS_OF_DATE
						
			-- DO NOT SPLIT Partition  IF YOU ARE REPROCESSING A DAY!!
			IF @MAX_LAST_AS_OF_DATE <> @AS_OF_DATE
			BEGIN TRY
			-- Creates the new Partition with SPLIT 
				DECLARE @SQLCreateSplitPart varchar(8000) = 'ALTER TABLE ' + @TABLE_NAME + ' SPLIT RANGE (''' + convert(varchar(10),@AS_OF_DATE,121) + ''')'
				IF @DEBUG_PRINT = 1
					PRINT @SQLCreateSplitPart
				IF @EXECSQL = 1
					EXEC (@SQLCreateSplitPart) 
			END TRY
			BEGIN CATCH
				DECLARE @SQLCreateSplitPartError varchar(8000) = (SELECT 'ERROR NUMBER:' + convert(varchar(1000),ERROR_NUMBER()) + ' ERROR_MESSAGE:' + ERROR_MESSAGE()  )
				PRINT @SQLCreateSplitPartError
			END CATCH 

			-- DO NOT MERGE (Meaning Collapse the Partition) IF YOU ARE REPROCESSING A DAY!!
			IF (@MAX_LAST_AS_OF_DATE <> @AS_OF_DATE) AND (ISNULL(@KEEP_LAST_PARTITION_IND,0) <> 1)
			BEGIN TRY
				-- Drop Old Partition 
				DECLARE @SQLMergeToRemovePartition varchar(8000) = 'ALTER TABLE ' + @TABLE_NAME + ' MERGE RANGE (''' + convert(varchar(10),@MAX_LAST_AS_OF_DATE,121) + ''')'
				IF @DEBUG_PRINT = 1
					PRINT @SQLMergeToRemovePartition
				IF @EXECSQL = 1
					EXEC (@SQLMergeToRemovePartition)
			END TRY
			BEGIN CATCH
				DECLARE @SQLMergeToRemovePartitionError varchar(8000) = (SELECT 'ERROR NUMBER:' + convert(varchar(1000),ERROR_NUMBER()) + ' ERROR_MESSAGE:' + ERROR_MESSAGE()  )
				PRINT @SQLMergeToRemovePartitionError
			END CATCH 
					
			IF (@MAX_LAST_AS_OF_DATE <> @AS_OF_DATE) -- DON't DELETE THE CONTROL REFERENCE IF YOU ARE REPROCESSING A DAY!!
			BEGIN 
				DECLARE @SQLDeletePartControlEntry varchar(8000) = 'DELETE FROM dbo.PARTITION_AS_OF_DATE_CONTROL WHERE PARTITION_DATE = ''' + convert(varchar(10),@MAX_LAST_AS_OF_DATE,121) + ''' AND KEEP_PARTITION_IND <> 1'
				IF @DEBUG_PRINT = 1
					PRINT @SQLDeletePartControlEntry 
				IF @EXECSQL = 1
					EXEC(@SQLDeletePartControlEntry)
			END

		----- UPDATE Partition Info
		EXEC PARTITION_AS_OF_DATE_INFO_UPDATE @TABLE_NAME
		IF @DEBUG_PRINT = 1
			SELECT 'PARTITION_AS_OF_DATE_INFO AFTER' AS MESSAGE_CONTENT, * FROM PARTITION_AS_OF_DATE_INFO WHERE TABLE_NAME = @TABLE_NAME ORDER BY 1,2

		-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
		-- -- -- --  TURN THE LAST PARTITION ON AS CURRENT_IND WHILE THE FACTS ARE PROCESSING -- -- -- -- 
		-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
		IF (
			SELECT COUNT(*)
			FROM PARTITION_AS_OF_DATE_CONTROL 
			WHERE PARTITION_DATE = (SELECT TOP 1 PARTITION_DATE FROM PARTITION_AS_OF_DATE_CONTROL ORDER BY PARTITION_DATE DESC) AND CURRENT_IND = 0
		) >0
		BEGIN 

			IF OBJECT_ID('tempdb..#PARTITION_AS_OF_DATE_CONTROL_TURN_ON_LAST_CURRENT_IND')<>0
				DROP TABLE #PARTITION_AS_OF_DATE_CONTROL_TURN_ON_LAST_CURRENT_IND

			CREATE TABLE #PARTITION_AS_OF_DATE_CONTROL_TURN_ON_LAST_CURRENT_IND
			(
				PARTITION_DATE date
			) WITH (LOCATION = USER_DB)

			INSERT INTO #PARTITION_AS_OF_DATE_CONTROL_TURN_ON_LAST_CURRENT_IND
				SELECT PARTITION_DATE 
				FROM PARTITION_AS_OF_DATE_CONTROL 
				WHERE PARTITION_DATE = 
					(
						SELECT TOP 1 PARTITION_DATE 
						FROM PARTITION_AS_OF_DATE_CONTROL 
						WHERE PARTITION_DATE < (SELECT TOP 1 PARTITION_DATE FROM PARTITION_AS_OF_DATE_CONTROL ORDER BY PARTITION_DATE DESC)
						ORDER  BY PARTITION_DATE DESC
					)
					
			UPDATE PARTITION_AS_OF_DATE_CONTROL
			SET CURRENT_IND = 1
			FROM #PARTITION_AS_OF_DATE_CONTROL_TURN_ON_LAST_CURRENT_IND
			WHERE PARTITION_AS_OF_DATE_CONTROL.PARTITION_DATE = #PARTITION_AS_OF_DATE_CONTROL_TURN_ON_LAST_CURRENT_IND.PARTITION_DATE

		END 

		IF OBJECT_ID ('#PARTITION_AS_OF_DATE_CONTROL_TURN_ON_LAST_CURRENT_IND')<>0
			DROP TABLE #PARTITION_AS_OF_DATE_CONTROL_TURN_ON_LAST_CURRENT_IND

	-- exec DropStats 'PARTITION_AS_OF_DATE_CONTROL' 
	---- exec CreateStats 'FACT_INVOICE_ANALYSIS'
	--CREATE STATISTICS STATS_PARTITION_AS_OF_DATE_CONTROL_1 ON PARTITION_AS_OF_DATE_CONTROL (PARTITION_DATE)
	--CREATE STATISTICS STATS_PARTITION_AS_OF_DATE_CONTROL_2 ON PARTITION_AS_OF_DATE_CONTROL (PARTITION_DATE, CURRENT_IND)

	--UPDATE PARTITION_AS_OF_DATE_CONTROL SET KEEP_PARTITION_IND = 1 WHERE KEEP_PARTITION_IND = 0 

END
*/
