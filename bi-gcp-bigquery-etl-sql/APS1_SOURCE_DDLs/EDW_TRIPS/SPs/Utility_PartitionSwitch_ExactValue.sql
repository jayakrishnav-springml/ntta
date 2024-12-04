CREATE PROC [Utility].[PartitionSwitch_ExactValue] @New_Table_Name [VARCHAR](200),@Main_Table_Name [VARCHAR](200),@IdentifyingColumns [VARCHAR](8000),@Filter [VARCHAR](8000) AS 
/*
IF OBJECT_ID ('Utility.PartitionSwitch_ExactValue', 'P') IS NOT NULL DROP PROCEDURE Utility.PartitionSwitch_ExactValue
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @IdentifyingColumns VARCHAR(400) = '[TpTripID]', @New_Table_Name VARCHAR(200) = 'dbo.Fact_TartAsOfDate', @Main_Table_Name VARCHAR(200) = 'dbo.Fact_TartSnapshot', @Filter VARCHAR(4000) = NULL --'UPDATEDDATE >= ''20150101'''
EXEC Utility.PartitionSwitch_ExactValue @New_Table_Name, @Main_Table_Name, @IdentifyingColumns, @Filter
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc is used to move data from a stage table to Production Partitioned table. Partitions on the table should be based on Number type (int, BigInt).
Also the values on the table in the partition column should be always exactly the same, as values on the borders of partitions.
That mean if partition bgorders are 100,200,300,400 - values on the partotion column can be 200, 300 and can't be 201,350 ect.

@Main_Table_Name - Production Partitioned Table name (with Schema) that should get all rows from the New Table.  
@New_Table_Name - The name of a table with the same columns as Table_Name (Nulls and Types can differ) with new data to update Production table. If empty or Null new name will be Table_Name on a 'New' schema
@IdentifyingColumns - List of the columns to uniqually identify rows in both tables.  Needed - can't be empty or Null. !!!!!!!!  EVERY COLUMN SHOULD BE IN [], Separator - up to you  !!!!!!!!!!!
@Filter - String that needed to filter rows from source table. Source table name should have allias 'NSET', for Destination table allias = Table name. Can be Null.
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837	Andy	2020-04-26	New!
CHG0038319 	Andy	2021-03-08  Changed: Added condition for Delete/Insert possibility, if new rows in source table is less then rows on the main table / 16.
CHG0038577 	Andy	2021-04-07	Fixed a mistake - din't make any changes if it's a new partition not presented in the main table at all. Also should help with deadlock INC0151637 (use # table for read in a loop)
###################################################################################################################
*/

BEGIN

	/*  --  TESTING / DEBAG PARAMETERS --  */
	--DECLARE @IdentifyingColumns VARCHAR(400) = '[TpTripID]', @Main_Table_Name VARCHAR(200) = 'dbo.Fact_TartSnapshot', @New_Table_Name VARCHAR(200) = 'dbo.Fact_TartAsOfDate', @Filter VARCHAR(4000)-- =  'UPDATEDDATE >= ''20150101'''
	/*  --  TESTING / DEBAG PARAMETERS --  */

	DECLARE @LOG_SOURCE VARCHAR(200) = @Main_Table_Name, @Error VARCHAR(MAX) = ''
	DECLARE @START_DATE DATETIME2 (3) = SYSDATETIME(), @LOG_MESSAGE VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing

	IF @Main_Table_Name IS NULL SET @Error = @Error + 'Source Table name cannot be NULL'
	IF @Main_Table_Name = @New_Table_Name SET @Error = @Error + 'Destination Table name cannot be equal to Source Table name'

	IF LEN(@Error) > 0
	BEGIN
		PRINT @Error
		EXEC Utility.FastLog @LOG_SOURCE, @Error, -3
	END
	ELSE
	BEGIN
		DECLARE @Params VARCHAR(100) = 'Alias,Type,NoPrint'
		DECLARE @Main_Table_DISTRIBUTION VARCHAR(100) = @Params, @Main_Table_INDEX VARCHAR(MAX) = @Params, @Main_Table_PARTITION VARCHAR(MAX) = @Params, @Main_Table_PartitionColumn VARCHAR(100) = @Params
		DECLARE @Main_Schema VARCHAR(100), @Main_Table VARCHAR(200), @New_Schema VARCHAR(100), @New_Table VARCHAR(200)
		DECLARE @sql VARCHAR(MAX), @SQL_SELECT VARCHAR(MAX) = @Params, @SQL_WHERE VARCHAR(MAX)
		DECLARE @Cur_Part INT, @Cur_Part_Text VARCHAR(3), @LastSwitchLogID INT
		DECLARE @Temp_PER VARCHAR(MAX), @PartitionCount INT, @Cur_Ind INT, @PartNum INT, @FromID INT
		DECLARE @USE_CREATE_AS SMALLINT = -1, @SQL_DELETE VARCHAR(MAX) = '', @SQL_INSERT VARCHAR(MAX) = '', @SQL_ALTER VARCHAR(MAX) = ''
		DECLARE @Create_ID_List VARCHAR(4000) = '', @Create_Delimiter CHAR(1) = ' '
		DECLARE @Insert_ID_List VARCHAR(4000) = '', @Insert_Delimiter CHAR(1) = ' '
		DECLARE @Dot INT = CHARINDEX('.',@Main_Table_Name)

		SELECT 
			@Main_Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Main_Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Main_Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Main_Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Main_Table_Name,@Dot + 1,200),'[',''),']','') END

		IF (@New_Table_Name IS NULL) OR (LEN(@New_Table_Name) = 0)
			SET @New_Table_Name = 'New.' + @Main_Table

		SET @Dot = CHARINDEX('.',@New_Table_Name)

		SELECT 
			@New_Schema = CASE WHEN @Dot = 0 THEN 'New' ELSE REPLACE(REPLACE(REPLACE(LEFT(@New_Table_Name,@Dot),'[',''),']',''),'.','') END,
			@New_Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@New_Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@New_Table_Name,@Dot + 1,200),'[',''),']','') END

		IF @Trace_Flag = 1 EXEC Utility.ToLog @LOG_SOURCE, @START_DATE, 'Started PartitionSwitch_ExactValue', 'I', NULL, NULL

		EXEC Utility.Get_Distribution_String	@Main_Table_Name, @Main_Table_DISTRIBUTION OUTPUT 
		EXEC Utility.Get_Index_String			@Main_Table_Name, @Main_Table_INDEX OUTPUT 
		EXEC Utility.Get_Partition_String		@Main_Table_Name, @Main_Table_PARTITION OUTPUT 
		EXEC Utility.Get_Select_String			@Main_Table_Name, @SQL_SELECT OUTPUT 
		EXEC Utility.Get_PartitionColumn		@Main_Table_Name, @Main_Table_PartitionColumn OUTPUT 
		EXEC Utility.Get_Where_String			@Main_Table_Name, @IdentifyingColumns, @SQL_WHERE OUTPUT 


		IF @Trace_Flag = 1 EXEC Utility.ToLog @LOG_SOURCE, @START_DATE, 'Got table parameters', 'I', NULL, NULL

		SELECT @Filter = CASE WHEN ISNULL(@Filter,'') = '' THEN '1 = 1' ELSE @Filter END

		IF OBJECT_ID('tempdb..#PARTITIONS_VALUES') IS NOT NULL DROP Table #PARTITIONS_VALUES
		CREATE Table #PARTITIONS_VALUES WITH (HEAP, DISTRIBUTION = REPLICATE)
		AS
		WITH CTE AS
		(
			SELECT  
				CAST(pf.boundary_value_on_right AS INT) AS boundary_value_on_right,
				CASE WHEN CAST(pf.boundary_value_on_right AS INT) = 1 
					THEN CASE WHEN rv.[value] IS NULL THEN 1 ELSE CAST(p.partition_number AS INT) + 1 END
					ELSE CAST(p.partition_number AS INT)
				END AS PartitionNum,
				CASE WHEN CAST(pf.boundary_value_on_right AS INT) = 1 
					THEN ISNULL(CAST(rv.[value] AS BIGINT),CAST(0 AS BIGINT))
					ELSE ISNULL(CAST(rv.[value] AS BIGINT),CAST(9223372036854775800 AS BIGINT))
				END AS NumberValueFrom 
			FROM      sys.schemas s
			JOIN      sys.Tables t                  ON t.[schema_id]      = s.[schema_id]
			JOIN      sys.partitions p              ON p.[object_id]      = t.[object_id] AND p.[index_id] <=1
			JOIN      sys.indexes i                 ON i.[object_id]      = p.[object_id] AND i.[index_id] = p.[index_id]
			JOIN      sys.data_spaces ds            ON ds.[data_space_id] = i.[data_space_id]
			LEFT JOIN sys.partition_schemes ps      ON ps.[data_space_id] = ds.[data_space_id]
			LEFT JOIN sys.partition_functions pf    ON pf.[function_id]   = ps.[function_id]
			LEFT JOIN sys.partition_range_values rv ON rv.[function_id]   = pf.[function_id] AND rv.[boundary_id] = p.[partition_number]
			WHERE s.[name] = @Main_Schema AND t.[name] = @Main_Table
		)
		SELECT
			PartitionNum,
			CASE WHEN CAST(boundary_value_on_right AS INT) = 1 
				THEN ISNULL(NumberValueFrom,0)
				ELSE ISNULL(LAG(NumberValueFrom) OVER (ORDER BY PartitionNum) + 1,CAST(0 AS BIGINT))
			END AS NumberValueFrom, 
			CASE WHEN CAST(boundary_value_on_right AS INT) = 1 
				THEN ISNULL(LEAD(NumberValueFrom) OVER (ORDER BY PartitionNum) - 1, CAST(9223372036854775800 AS BIGINT))
				ELSE ISNULL(NumberValueFrom,CAST(9223372036854775800 AS BIGINT))
			END AS NumberValueTo 
		FROM CTE

		IF @Trace_Flag = 1 EXEC Utility.ToLog @LOG_SOURCE, @START_DATE, 'Got #PARTITIONS_VALUES', 'I', NULL, NULL
		IF @Trace_Flag = 1 SELECT '#PARTITIONS_VALUES' TableName, * FROM #PARTITIONS_VALUES ORDER BY PartitionNum

		SELECT @LastSwitchLogID = ISNULL(MAX(SwitchLogID),0) + 1 FROM Utility.PartitionSwitchLog WHERE TableName = @Main_Table_Name

		IF OBJECT_ID('tempdb..#PartitionSwitchLog','U') IS NOT NULL			DROP TABLE #PartitionSwitchLog;		CREATE TABLE #PartitionSwitchLog (
			[SeqID] smallint NOT NULL, 
			[PartitionNum] int NOT NULL, 
			[NumberValueFrom] bigint NULL, 
			[NumberValueTo] bigint NULL, 
			--[DateValueFrom] date NULL, 
			--[DateValueTo] date NULL, 
			[NewRowCount] bigint NULL, 
			[TableRowCount] bigint NULL, 
			[ActionType] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL 
		)		WITH (HEAP, DISTRIBUTION = HASH([SeqID]));
			----EXPLAIN
		SET @SQL = '
		IF OBJECT_ID(''tempdb..#PartitionSwitch'') IS NOT NULL DROP Table #PartitionSwitch
		SELECT IQ.NumberValueFrom, IQ.NumberValueTo, IQ.PartitionNum, COUNT_BIG(1) AS NewRowCount 
		INTO #PartitionSwitch
		FROM ' + @New_Schema + '.[' + @New_Table + ']	AS FN
		JOIN #PARTITIONS_VALUES AS IQ ON FN.' + @Main_Table_PartitionColumn + ' = IQ.NumberValueFrom
		WHERE ' + @Filter + '
		GROUP BY IQ.NumberValueFrom,IQ.NumberValueTo,IQ.PartitionNum
		
		INSERT INTO #PartitionSwitchLog
		SELECT
			Row_Number() OVER (ORDER BY PartitionNum) AS SeqID,
			PartitionNum AS PartitionNum, 
			NumberValueFrom, 
			NumberValueTo,
			NewRowCount,
			TableRowCount,
			CASE WHEN NewRowCount > TableRowCount / 16 THEN ''Create/Switch'' ELSE ''Delete/Insert'' END  AS ActionType
		FROM 
		(	SELECT IQ.NumberValueFrom, IQ.NumberValueTo, IQ.PartitionNum, NewRowCount, ISNULL(FN.TableRowCount, 0) AS TableRowCount 
			FROM #PartitionSwitch IQ
			LEFT JOIN (
						SELECT PartitionNum, COUNT_BIG(1) AS TableRowCount FROM ' + @Main_Table_Name + ' AS FN
						JOIN #PARTITIONS_VALUES AS IQ ON FN.' + @Main_Table_PartitionColumn + ' = IQ.NumberValueFrom
						GROUP BY IQ.PartitionNum
						) AS FN ON FN.PartitionNum = IQ.PartitionNum
			) A


		INSERT INTO Utility.PartitionSwitchLog
		SELECT
			' + CAST(@LastSwitchLogID AS VARCHAR(10)) + ' AS SwitchLogID,
			SeqID,
			''' + @Main_Table_Name + ''' AS TableName,
			PartitionNum, 
			NumberValueFrom, 
			NumberValueTo,
			NULL AS DateValueFrom,
			NULL AS DateValueTo,
			NewRowCount,
			TableRowCount,
			ActionType,
			SYSDATETIME() AS LogDate
		FROM #PartitionSwitchLog
		OPTION (LABEL = ''' + @Main_Table_Name + ' LOAD: Get changed partitions query'');'		

		IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql

		EXEC (@SQL)

		IF @Trace_Flag = 1 EXEC Utility.ToLog @LOG_SOURCE, @START_DATE, 'Got Utility.PartitionSwitchLog', 'I', NULL, NULL
		--IF @Trace_Flag = 1 SELECT 'Utility.PartitionSwitchLog' DataFromTable, * FROM Utility.PartitionSwitchLog WHERE TableName = @Main_Table_Name AND SwitchLogID = @LastSwitchLogID ORDER BY SeqID
		IF @Trace_Flag = 1 SELECT 'Utility.PartitionSwitchLog' DataFromTable, * FROM #PartitionSwitchLog ORDER BY SeqID

		-- These variables are parts of repeatable query
		-- Calculate period ranges from Utility.PartitionSwitchLog to use index on DAYID in a query below. And create a query for each period and UNION ALL them all.
		--SET @PartitionCount = (SELECT ISNULL(MAX(SeqID),0) FROM Utility.PartitionSwitchLog WHERE TableName = @Main_Table_Name AND SwitchLogID = @LastSwitchLogID)
		SET @PartitionCount = (SELECT ISNULL(MAX(SeqID),0) FROM #PartitionSwitchLog)
		-- First not in the loop without any comma
		SET @FromID = -1
		SET @Cur_Part = -1
		SET @Cur_Ind = 1

		-- This approach allow us merge the close periods to one subquery - should work faster for last several months than make query for each month 
		WHILE (@Cur_Ind <= @PartitionCount) 
		BEGIN
			-- Initiate all roll variables
			SELECT @PartNum = PD.PartitionNum, @FromID = PD.NumberValueFrom, @USE_CREATE_AS = CASE WHEN PD.ActionType = 'Create/Switch' THEN 1 ELSE 0 END
			FROM #PartitionSwitchLog AS PD WHERE PD.SeqID = @Cur_Ind
			--FROM Utility.PartitionSwitchLog AS PD WHERE PD.SeqID = @Cur_Ind AND TableName = @Main_Table_Name AND SwitchLogID = @LastSwitchLogID

			IF @USE_CREATE_AS = 1
			BEGIN
				SET @SQL_ALTER = @SQL_ALTER + CHAR(13) + 'ALTER TABLE ' + @Main_Schema + '.[' + @Main_Table + '] SWITCH PARTITION ' + CAST(@PartNum AS VARCHAR(10)) + ' TO Old.[' + @Main_Table + '_Switch] PARTITION ' + CAST(@PartNum AS VARCHAR(10)) + ';'
				SET @SQL_ALTER = @SQL_ALTER + CHAR(13) + 'ALTER TABLE Temp.[' + @Main_Table + '] SWITCH PARTITION ' + CAST(@PartNum AS VARCHAR(10)) + ' TO ' + @Main_Schema + '.[' + @Main_Table + '] PARTITION ' + CAST(@PartNum AS VARCHAR(10)) + ';'
				SET @Create_ID_List = @Create_ID_List + @Create_Delimiter + CAST(@FromID AS VARCHAR(20))
				SET @Create_Delimiter = ','
			END
			ELSE
			BEGIN
				SET @Insert_ID_List = @Insert_ID_List + @Insert_Delimiter + CAST(@FromID AS VARCHAR(20))
				SET @Insert_Delimiter = ','
			END
			SET @Cur_Ind += 1 -- 
		END

		IF @Trace_Flag = 1 EXEC Utility.ToLog @LOG_SOURCE, @START_DATE, 'Got all Delete/Insert and Create/Switch queries', 'I', NULL, NULL

		IF LEN(@Insert_ID_List) > 0
		BEGIN
			SET @SQL_DELETE = 'DELETE	FROM ' + @Main_Schema + '.[' + @Main_Table + '] ' + CHAR(13) 
							+ 'WHERE EXISTS (' + CHAR(13) 
							+ '		SELECT 1 FROM ' + @New_Schema + '.[' + @New_Table + '] AS NSET ' + CHAR(13) 
							+ '		WHERE '+ @SQL_WHERE + ' AND ' + CHAR(13) 
							+ '			' + @Main_Table_PartitionColumn + 'IN ( '+ @Insert_ID_List + ')' + CHAR(13) 
							+ '		) AND ' + CHAR(13) 
							+ '		' + @Main_Table_PartitionColumn +  ' IN ( '+ @Insert_ID_List + ')'
			SET @SQL_INSERT = 'INSERT INTO ' + @Main_Schema + '.[' + @Main_Table + '] ' + CHAR(13) 
							+ 'SELECT	' + REPLACE(@SQL_SELECT,'[' + @Main_Table + ']','NSET') + CHAR(13) 
							+ 'FROM ' + @New_Schema + '.[' + @New_Table + '] AS NSET' + CHAR(13) 
							+ 'WHERE ' + @Filter + ' AND ' + CHAR(13) 
							+ '		' + @Main_Table_PartitionColumn +  ' IN ( '+ @Insert_ID_List + ')'


			IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL_DELETE
			EXECUTE (@SQL_DELETE);
			IF @Trace_Flag = 1 EXEC Utility.ToLog @LOG_SOURCE, @START_DATE, 'Deleted Old rows', 'I', NULL, @SQL_DELETE

			IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL_INSERT
			EXECUTE (@SQL_INSERT);

			SELECT @PartitionCount = COUNT(1)
			FROM #PartitionSwitchLog AS PD WHERE ActionType = 'Delete/Insert'
			--FROM Utility.PartitionSwitchLog AS PD WHERE TableName = @Main_Table_Name AND SwitchLogID = @LastSwitchLogID AND ActionType = 'Delete/Insert'

			SET  @LOG_MESSAGE = 'Inserted/Updated ' + CONVERT(VARCHAR,@PartitionCount) + ' Table partitions' + ISNULL('. @Filter: ' + NULLIF(@Filter,'1 = 1'),'')
			EXEC Utility.ToLog @LOG_SOURCE, @START_DATE, @LOG_MESSAGE, 'I', NULL, @SQL_INSERT

		END
		IF LEN(@Create_ID_List) > 0
		BEGIN
			SET @sql = CHAR(13) + 'IF OBJECT_ID(''Temp.[' + @Main_Table + ']'') IS NOT NULL DROP TABLE Temp.[' + @Main_Table + '];' + CHAR(13)
			SET @sql = @sql + 'CREATE TABLE Temp.[' + @Main_Table + '] WITH (' + @Main_Table_INDEX + ', ' + @Main_Table_DISTRIBUTION + @Main_Table_PARTITION + ') AS' + CHAR(13)
							+ 'SELECT	' + @SQL_SELECT + CHAR(13) 
							+ 'FROM ' + @Main_Schema + '.[' + @Main_Table + '] AS [' + @Main_Table + ']' + CHAR(13)
							+ 'WHERE NOT EXISTS (' + CHAR(13)
							+ '		SELECT 1 FROM ' + @New_Schema + '.[' + @New_Table + '] AS NSET WHERE ' + @SQL_WHERE + ' AND ' + @Main_Table_PartitionColumn +  ' IN ( '+ @Create_ID_List + ')' + CHAR(13)
							+ '		) AND ' + @Main_Table_PartitionColumn + ' IN ( '+ @Create_ID_List + ')' + CHAR(13) 
							+ 'UNION ALL' + CHAR(13) 
							+ 'SELECT	' + REPLACE(@SQL_SELECT,'[' + @Main_Table + ']','NSET') + CHAR(13)
							+ 'FROM ' + @New_Schema + '.[' + @New_Table + '] AS NSET WHERE ' + @Main_Table_PartitionColumn + ' IN ( '+ @Create_ID_List + ') AND ' + @FILTER + CHAR(13) 
							+ 'OPTION (LABEL = ''Temp.' + @Main_Table + ' LOAD: Get all changed rows by partitions'');'

			IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
			EXECUTE (@sql); 

			EXEC Utility.ToLog @LOG_SOURCE, @START_DATE, '-1', 'I', -1, @sql

			-- Switch all changed partitions from Stage to Fact.
			SET @sql = CHAR(13) + 'IF OBJECT_ID(''Old.[' + @Main_Table + '_Switch]'') IS NOT NULL DROP TABLE Old.[' + @Main_Table + '_Switch];' + CHAR(13)
			SET @sql = @sql + 'CREATE TABLE Old.[' + @Main_Table + '_Switch] WITH (' + @Main_Table_INDEX + ', ' + @Main_Table_DISTRIBUTION + @Main_Table_PARTITION + ') AS' + CHAR(13) + 'SELECT * FROM ' + @Main_Schema + '.[' + @Main_Table + '] WHERE 1=2'
			IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
			EXECUTE (@sql);

			IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL_ALTER
			EXECUTE (@SQL_ALTER);

			SELECT @PartitionCount = COUNT(1)
			FROM #PartitionSwitchLog AS PD WHERE ActionType = 'Create/Switch'
			--FROM Utility.PartitionSwitchLog AS PD WHERE TableName = @Main_Table_Name AND SwitchLogID = @LastSwitchLogID AND ActionType = 'Create/Switch'

			SET  @LOG_MESSAGE = 'Switched ' + CONVERT(VARCHAR,@PartitionCount) + ' Table partitions' + ISNULL('. @Filter: ' + NULLIF(@Filter,'1 = 1'),'')
			EXEC Utility.ToLog @LOG_SOURCE, @START_DATE, @LOG_MESSAGE, 'I', NULL, @SQL_ALTER

			SET @sql = CHAR(13) + 'IF OBJECT_ID(''Temp.[' + @Main_Table + ']'') IS NOT NULL DROP TABLE Temp.[' + @Main_Table + ']'
			IF @Trace_Flag = 0 EXECUTE (@sql);
		END

	END

	IF @Trace_Flag = 1 EXEC Utility.FromLog @LOG_SOURCE, @START_DATE

END	

/*

IF OBJECT_ID('dbo.PartitionSwitch_ExactValue_Test','U') IS NOT NULL			DROP TABLE dbo.PartitionSwitch_ExactValue_Test;CREATE TABLE dbo.PartitionSwitch_ExactValue_Test WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(CitationID), PARTITION (PartitionMonthID RANGE RIGHT FOR VALUES (202101,202102,202103,202104,202105,202106))) AS	SELECT
		ISNULL(CAST(202101 AS INT), 0) AS PartitionMonthID
		, ISNULL(CAST(1 AS BIGINT), 0) AS CitationID
		, CAST(1 AS BIGINT) AS CustomerID
		, CAST('This row should not be deleted' AS VARCHAR(200)) AS ExpectedResult
		, CAST(12.23 AS DECIMAL(19,2)) AS TollAmount
	UNION ALL
	SELECT
		ISNULL(CAST(202102 AS INT), 0) AS PartitionMonthID
		, ISNULL(CAST(2 AS BIGINT), 0) AS CitationID
		, CAST(2 AS BIGINT) AS CustomerID
		, CAST('This should have change the amount' AS VARCHAR(200)) AS ExpectedResult
		, CAST(34.45 AS DECIMAL(19,2)) AS TollAmount
	UNION ALL
	SELECT
		ISNULL(CAST(202102 AS INT), 0) AS PartitionMonthID
		, ISNULL(CAST(4 AS BIGINT), 0) AS CitationID
		, CAST(8 AS BIGINT) AS CustomerID
		, CAST('This row not presented in a new table - should stay the same' AS VARCHAR(200)) AS ExpectedResult
		, CAST(234.45 AS DECIMAL(19,2)) AS TollAmount

IF OBJECT_ID('dbo.PartitionSwitch_ExactValue_Test_New','U') IS NOT NULL			DROP TABLE dbo.PartitionSwitch_ExactValue_Test_New;CREATE TABLE dbo.PartitionSwitch_ExactValue_Test_New WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(CitationID), PARTITION (PartitionMonthID RANGE RIGHT FOR VALUES (202101,202102,202103,202104,202105,202106))) AS	SELECT
		ISNULL(CAST(202102 AS INT), 0) AS PartitionMonthID
		, ISNULL(CAST(2 AS BIGINT), 0) AS CitationID
		, CAST(2 AS BIGINT) AS CustomerID
		, CAST('This should have change the amount' AS VARCHAR(200)) AS ExpectedResult
		, CAST(56.67 AS DECIMAL(19,2)) AS TollAmount
	UNION ALL
	SELECT
		ISNULL(CAST(202102 AS INT), 0) AS PartitionMonthID
		, ISNULL(CAST(3 AS BIGINT), 0) AS CitationID
		, CAST(3 AS BIGINT) AS CustomerID
		, CAST('This is a new row to insert to 2-nd partition' AS VARCHAR(200)) AS ExpectedResult
		, CAST(23.34 AS DECIMAL(19,2)) AS TollAmount
	UNION ALL
	SELECT
		ISNULL(CAST(202103 AS INT), 0) AS PartitionMonthID
		, ISNULL(CAST(5 AS BIGINT), 0) AS CitationID
		, CAST(2 AS BIGINT) AS CustomerID
		, CAST('This is a new row to insert to 3-d partition' AS VARCHAR(200)) AS ExpectedResult
		, CAST(134.45 AS DECIMAL(19,2)) AS TollAmount

SELECT * FROM dbo.PartitionSwitch_ExactValue_Test ORDER BY PartitionMonthID,CitationID
SELECT * FROM dbo.PartitionSwitch_ExactValue_Test_New ORDER BY PartitionMonthID,CitationID

DECLARE @IdentifyingColumns VARCHAR(400) = '[CitationID]', @Main_Table_Name VARCHAR(200) = 'dbo.PartitionSwitch_ExactValue_Test', @New_Table_Name VARCHAR(200) = 'dbo.PartitionSwitch_ExactValue_Test_New', @Filter VARCHAR(4000)-- =  'UPDATEDDATE >= ''20150101'''
EXEC Utility.PartitionSwitch_ExactValue @New_Table_Name, @Main_Table_Name, @IdentifyingColumns, @Filter

SELECT * FROM dbo.PartitionSwitch_ExactValue_Test ORDER BY PartitionMonthID,CitationID

IF OBJECT_ID('dbo.PartitionSwitch_ExactValue_Test','U') IS NOT NULL			DROP TABLE dbo.PartitionSwitch_ExactValue_Test;IF OBJECT_ID('dbo.PartitionSwitch_ExactValue_Test_New','U') IS NOT NULL			DROP TABLE dbo.PartitionSwitch_ExactValue_Test_New;

*/
