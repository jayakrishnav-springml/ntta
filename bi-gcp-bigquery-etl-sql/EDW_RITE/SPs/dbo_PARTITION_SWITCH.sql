CREATE PROC [dbo].[PARTITION_SWITCH] @DEST_TABLE_NAME [varchar](255),@SRC_TABLE_NAME [varchar](255),@AS_OF_DATE [date] AS

EXEC dbo.PARTITION_SWITCH_AS_OF_DATE_LOAD @DEST_TABLE_NAME,@SRC_TABLE_NAME,@AS_OF_DATE


/*
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.PARTITION_SWITCH') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.PARTITION_SWITCH
GO


*/


-- Below the old code - keep it for couple months
/*

BEGIN 
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Purpose:   To switch the Partitions on Tables with an AS_OF_DATE Partition

Notes:
		- The Table PARTITION_AS_OF_DATE_CONTROL contains a list for every parition loaded 
			- This control table has a bit field called KEEP_PARTITION_IND which allows any given day's parition to be left alone and not dropped
			- The default for the 1st day of each month is to keep the partition
			- The field called DATA_AS_OF_DATE is for the Front end to display the end of each month 
		 
 
		Setup for the Process
		- Target Table Must have a Field called PARTITION_DATE and Must Be Partitioned on PARTITION_DATE
		- The Name of the Target Partitioned Table must be entered into the table called "PARTITION_AS_OF_DATE_TABLE"
			- This Table has the Distribution SQL code and index code required to create each mirrored table for the switch that occurs
			- The Partition Switch table which will be [TABLE_NAME] + "_PARTITION_SWITCH" will have the last partition to be dropped 
				- This allows for possibility of recovery on any given day
		- 


		
	SELECT * FROM PARTITION_AS_OF_DATE_CONTROL
	SELECT * FROM PARTITION_AS_OF_DATE_INFO  WHERE TABLE_NAME = 'FACT_VIOLATION'


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

	--DECLARE @DEST_TABLE_NAME varchar(255) = 'DIM_VIOLATOR_ASOF'
	--DECLARE @SRC_TABLE_NAME varchar(255) = 'DIM_VIOLATOR_ASOF_FINAL'
	--DECLARE @AS_OF_DATE date  = '8/31/2016'

	DECLARE @TABLE_NAME_FOR_SWITCH varchar(1000) = (SELECT @DEST_TABLE_NAME +  '_PARTITION_SWITCH')

	DECLARE @DEBUG_PRINT bit = 0
	DECLARE @EXECSQL bit = 1
	DECLARE @MSG varchar(500) = ''
	DECLARE @DISTRIBUTION_SQL varchar(500) = (SELECT DISTRIBUTION_SQL FROM PARTITION_AS_OF_DATE_TABLE WHERE TABLE_NAME = @DEST_TABLE_NAME)
	DECLARE @INDEX_SQL varchar(500) = (SELECT INDEX_SQL FROM PARTITION_AS_OF_DATE_TABLE WHERE TABLE_NAME = @DEST_TABLE_NAME)

	SET @MSG = 'Failure in Procedure PARTITION_AS_OF_DATE_TABLE_UPDATE. There was no entry in PARTITION_AS_OF_DATE_TABLE for table = ' + @DEST_TABLE_NAME 
	IF @DISTRIBUTION_SQL IS NULL or len(@DISTRIBUTION_SQL) = 0 
		BEGIN
			RAISERROR(@MSG,16,1)
		END 

	IF @INDEX_SQL IS NULL or len(@INDEX_SQL) = 0 
		RAISERROR(@MSG,16,1)

	-- Update the Partition Information for the Target Table
	-- EXEC PARTITION_AS_OF_DATE_INFO_UPDATE @DEST_TABLE_NAME
	IF @DEBUG_PRINT = 1
		SELECT 'PARTITION_AS_OF_DATE_INFO BEFORE' AS MESSAGE_CONTENT, * FROM PARTITION_AS_OF_DATE_INFO WHERE TABLE_NAME = @DEST_TABLE_NAME ORDER BY 1,2

	-- MAX AS OF DATE FROM the TARGET TABLE
	DECLARE @SQLMaxLastASOfDate varchar(8000) = 
		'IF OBJECT_ID(''tempdb..#AS_OF_DATE'')<>0
			DROP TABLE #AS_OF_DATE
		BEGIN 
			CREATE TABLE #AS_OF_DATE WITH (LOCATION = USER_DB, DISTRIBUTION=REPLICATE) 
			AS 

			SELECT TOP 1 RANGE_TO_INCLUDING AS AS_OF_DATE FROM PARTITION_AS_OF_DATE_INFO WHERE TABLE_NAME LIKE ''' + @DEST_TABLE_NAME + ''' AND RANGE_TO_INCLUDING <> ''9999-12-31'' ORDER BY RANGE_TO_INCLUDING DESC

		END
		'

/*
			SELECT PARTITION_DATE AS AS_OF_DATE FROM dbo.' + @DEST_TABLE_NAME + ' GROUP BY PARTITION_DATE
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

	--DECLARE @Switch_PART_DATE date = (SELECT TOP 1 RANGE_TO_INCLUDING  FROM dbo.PARTITION_AS_OF_DATE_INFO WHERE TABLE_NAME = @DEST_TABLE_NAME AND @MAX_LAST_AS_OF_DATE >= RANGE_TO_INCLUDING ORDER BY RANGE_TO_INCLUDING ASC)
	DECLARE @MAX_PARTITION_NBR int = (SELECT TOP 1 PARTITION_NBR FROM dbo.PARTITION_AS_OF_DATE_INFO WHERE TABLE_NAME = @DEST_TABLE_NAME ORDER BY PARTITION_NBR DESC)
	DECLARE @PARTITION_NBR_FOR_AS_OF_DATE int = (SELECT TOP 1 PARTITION_NBR FROM dbo.PARTITION_AS_OF_DATE_INFO WHERE TABLE_NAME = @DEST_TABLE_NAME AND @MAX_LAST_AS_OF_DATE<= RANGE_TO_INCLUDING ORDER BY RANGE_TO_INCLUDING ASC)
	DECLARE @KEEP_LAST_PARTITION_IND int = (SELECT ISNULL(KEEP_PARTITION_IND,1) FROM PARTITION_AS_OF_DATE_CONTROL WHERE PARTITION_DATE = @MAX_LAST_AS_OF_DATE)

	IF @DEBUG_PRINT = 1
		SELECT 'Variables in Script'			AS MESSAGE_CONTENT
			, @MAX_PARTITION_NBR				AS MAX_PARTITION_NBR
			, @PARTITION_NBR_FOR_AS_OF_DATE		AS PARTITION_NBR_FOR_AS_OF_DATE
			--, @Switch_PART_DATE					AS Switch_PART_DATE
			, @MAX_LAST_AS_OF_DATE				AS MAX_LAST_AS_OF_DATE
			, @KEEP_LAST_PARTITION_IND			AS KEEP_PARTITION_IND
			, @AS_OF_DATE						AS AS_OF_DATE
			, @DISTRIBUTION_SQL					AS DISTRIBUTION_SQL
			, @INDEX_SQL						AS INDEX_SQL


			DECLARE @SQLCreateSwitchTbl varchar(8000) = '		
				IF OBJECT_ID(''' + @TABLE_NAME_FOR_SWITCH + ''')<>0
						DROP TABLE ' + @TABLE_NAME_FOR_SWITCH + '

					CREATE TABLE dbo.' + @TABLE_NAME_FOR_SWITCH + '
						WITH 
							(
								  DISTRIBUTION = ' + @DISTRIBUTION_SQL + '
								, ' + ISNULL(@INDEX_SQL,'') + '
								, PARTITION ( PARTITION_DATE 
											RANGE LEFT FOR VALUES 
											(
											   '''+ CONVERT(VARCHAR(10),DATEADD(DAY,-1,@AS_OF_DATE),121) +N''', '''+ convert(varchar(10),@AS_OF_DATE,121) + '''
											))

							) 
					AS 
					SELECT * FROM ' + @DEST_TABLE_NAME + ' WHERE 1=2
					UNION ALL
					SELECT * FROM ' + @SRC_TABLE_NAME

				
			IF @DEBUG_PRINT = 1
				PRINT @SQLCreateSwitchTbl
			--IF @EXECSQL = 1 -- REALLY CAN do this all the time
				EXEC (@SQLCreateSwitchTbl)


			EXEC PARTITION_AS_OF_DATE_INFO_UPDATE @TABLE_NAME_FOR_SWITCH
			IF @DEBUG_PRINT = 1
				SELECT 'PARTITION_SWITCH' AS MESSAGE_CONTENT, * FROM PARTITION_AS_OF_DATE_INFO WHERE TABLE_NAME = @TABLE_NAME_FOR_SWITCH ORDER BY 1,2

			DECLARE @PARTITION_NBR_FOR_SWITCH int = (SELECT TOP 1 PARTITION_NBR FROM dbo.PARTITION_AS_OF_DATE_INFO WHERE TABLE_NAME = @TABLE_NAME_FOR_SWITCH AND @MAX_LAST_AS_OF_DATE<= RANGE_TO_INCLUDING ORDER BY RANGE_TO_INCLUDING ASC)

			IF @DEBUG_PRINT = 1
				SELECT @PARTITION_NBR_FOR_SWITCH AS PARTITION_NBR_FOR_SWITCH

			-- DO NOT SPLIT Partition  IF YOU ARE REPROCESSING A DAY!!
			IF @MAX_LAST_AS_OF_DATE <> @AS_OF_DATE
			BEGIN TRY
			-- Creates the new Partition with SPLIT 
				DECLARE @SQLCreateSplitPart varchar(8000) = 'ALTER TABLE ' + @DEST_TABLE_NAME + ' SPLIT RANGE (''' + convert(varchar(10),@AS_OF_DATE,121) + ''')'
				IF @DEBUG_PRINT = 1
					PRINT @SQLCreateSplitPart
				IF @EXECSQL = 1
					EXEC (@SQLCreateSplitPart) 
			END TRY
			BEGIN CATCH
				DECLARE @SQLCreateSplitPartError varchar(8000) = (SELECT 'ERROR NUMBER:' + convert(varchar(1000),ERROR_NUMBER()) + ' ERROR_MESSAGE:' + ERROR_MESSAGE()  )
				PRINT @SQLCreateSplitPartError
			END CATCH 

			-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
			-- -- -- -- -- MOVE PARTITION DATA FROM SWITCH TABLE -- -- -- -- -- 
			-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
			-- Move Old Partition to SWITCH TABLE 
			--IF (ISNULL(@KEEP_LAST_PARTITION_IND,0) <> 1) OR (@MAX_LAST_AS_OF_DATE = @AS_OF_DATE)
			BEGIN TRY
				DECLARE @SQLSwitchPartitionToSwitchTbl varchar(8000) = 'ALTER TABLE ' + @TABLE_NAME_FOR_SWITCH + ' SWITCH PARTITION 2 TO ' + @DEST_TABLE_NAME + ' PARTITION '+ convert(varchar(10),@PARTITION_NBR_FOR_AS_OF_DATE)
				IF @DEBUG_PRINT = 1
					PRINT @SQLSwitchPartitionToSwitchTbl
				IF @EXECSQL = 1
					EXEC (@SQLSwitchPartitionToSwitchTbl)
			END TRY
			BEGIN CATCH
				DECLARE @SQLSwitchPartitionToSwitchTblError varchar(8000) = (SELECT 'ERROR NUMBER:' + convert(varchar(1000),ERROR_NUMBER()) + ' ERROR_MESSAGE:' + ERROR_MESSAGE()  )
				PRINT @SQLSwitchPartitionToSwitchTblError
			END CATCH 
--PRINT 'DO NOT SPLIT Partition  IF YOU ARE REPROCESSING A DAY'
--PRINT '@MAX_LAST_AS_OF_DATE'
--PRINT @MAX_LAST_AS_OF_DATE
--PRINT '@AS_OF_DATE'
--PRINT @AS_OF_DATE
END
*/
