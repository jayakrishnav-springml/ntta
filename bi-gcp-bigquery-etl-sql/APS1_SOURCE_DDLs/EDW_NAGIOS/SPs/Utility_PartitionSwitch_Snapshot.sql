CREATE PROC [Utility].[PartitionSwitch_Snapshot] @New_Table_Name [VARCHAR](130),@Main_Table_Name [VARCHAR](130) AS 
/*
IF OBJECT_ID ('Utility.PartitionSwitch_Snapshot', 'P') IS NOT NULL DROP PROCEDURE Utility.PartitionSwitch_Snapshot
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Main_Table_Name VARCHAR(200) = 'dbo.Fact_InvoiceAgingSnapshot', @New_Table_Name VARCHAR(200) = 'dbo.Fact_InvoiceAgingSnapshot_NEW'
EXEC Utility.PartitionSwitch_Snapshot @New_Table_Name, @Main_Table_Name
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc is used to move data from a stage table to Production Partitioned table. Partitions on the table should be based on Number type (int, BigInt).
Both tables should be partitioned and having the same partition boundary values. It means the same partition values should be in the same purtitions (partition numbers are equal) in both tables.

@New_Table_Name - The name of a table with the same columns as Table_Name with new data to update Production table. If empty or Null new name will be Table_Name on a 'New' schema
@Main_Table_Name - Production Partitioned Table name (with Schema) that should get all rows from the New Table.  

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837	Andy	2020-04-26	New!
CHG0038319 	Andy	2021-03-08  Changed: Made proc better - now if tables are not the same it will create temp table using CREATE AS, if the same - just move partitions
CHG0038577 	Andy	2021-04-07	Fixed a mistake - din't make any changes if it's a new partition not presented in the main table at all. Also should help with deadlock INC0151637 (use # table for read in a loop)
###################################################################################################################
*/

BEGIN
	/*====================================== TESTING =======================================================================*/
	--DECLARE @Main_Table_Name VARCHAR(200) = 'dbo.Fact_InvoiceAgingSnapshot', @New_Table_Name = 'dbo.Fact_InvoiceAgingSnapshot_NEW' 
	/*====================================== TESTING =======================================================================*/

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
		DECLARE @Main_Schema VARCHAR(100), @Main_Table VARCHAR(200), @New_Schema VARCHAR(100), @New_Table VARCHAR(200), @SwitchTableName VARCHAR(200)
		DECLARE @sql VARCHAR(MAX), @SQL_SELECT VARCHAR(MAX) = @Params, @ComparisonResult VARCHAR(MAX) = @Params
		DECLARE @Cur_Part INT, @Cur_Part_Text VARCHAR(3), @LastSwitchLogID INT = 1
		DECLARE @PartitionCount INT, @Cur_Ind INT, @PartNum_Loop INT
		DECLARE @ToID INT, @ToID_Loop INT, @FromID INT, @FromID_Loop INT
		DECLARE @SQL_ALTER VARCHAR(MAX) = '', @SQL_NQT VARCHAR(MAX) = '', @SQL_CREATE VARCHAR(MAX) = ''
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
		
		SET @SwitchTableName = @New_Schema + '.[' + @New_Table + ']'

		EXEC Utility.Get_Distribution_String	@Main_Table_Name, @Main_Table_DISTRIBUTION OUTPUT 
		EXEC Utility.Get_Index_String			@Main_Table_Name, @Main_Table_INDEX OUTPUT 
		EXEC Utility.Get_Partition_String		@Main_Table_Name, @Main_Table_PARTITION OUTPUT
		EXEC Utility.Get_PartitionColumn		@Main_Table_Name, @Main_Table_PartitionColumn OUTPUT
		
		-- Checking if tables are the same we can do ALTER from a new table itself, if not - should create a new Temp table with the same metadata as Main table for Alter statement works fine
		EXEC Utility.CompareTablesMetadata			@New_Table_Name, @Main_Table_Name, @ComparisonResult OUTPUT
		IF @ComparisonResult <> '' -- Empty Result means tables are identical - no need to do more work
		BEGIN
			EXEC Utility.Get_Select_String			@Main_Table_Name, @SQL_SELECT OUTPUT
			SET @SwitchTableName = 'Temp.[' + @Main_Table + ']'
		END

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

		IF @Trace_Flag = 1 SELECT '#PARTITIONS_VALUES' TableName, * FROM #PARTITIONS_VALUES ORDER BY PartitionNum

		SELECT @LastSwitchLogID = MAX(SwitchLogID) + 1 FROM Utility.PartitionSwitchLog WHERE TableName = @Main_Table_Name
		IF @LastSwitchLogID IS NULL SET @LastSwitchLogID = 1

		IF OBJECT_ID('tempdb..#PartitionSwitchLog','U') IS NOT NULL			DROP TABLE #PartitionSwitchLog;
		CREATE TABLE #PartitionSwitchLog (
			[SeqID] smallint NOT NULL, 
			[PartitionNum] int NOT NULL, 
			[NumberValueFrom] bigint NULL, 
			[NumberValueTo] bigint NULL, 
			[NewRowCount] bigint NULL, 
			[TableRowCount] bigint NULL 
		)		WITH (HEAP, DISTRIBUTION = HASH([SeqID]));

		----EXPLAIN
		SET @SQL = '
		IF OBJECT_ID(''tempdb..#PartitionSwitch'') IS NOT NULL DROP Table #PartitionSwitch
		SELECT IQ.NumberValueFrom, IQ.NumberValueTo, IQ.PartitionNum, COUNT_BIG(1) AS NewRowCount 
		INTO #PartitionSwitch
		FROM ' + @New_Schema + '.[' + @New_Table + ']	AS FN
		JOIN #PARTITIONS_VALUES AS IQ ON FN.' + @Main_Table_PartitionColumn + ' >= IQ.NumberValueFrom AND FN.' + @Main_Table_PartitionColumn + ' <= IQ.NumberValueTo
		GROUP BY IQ.NumberValueFrom,IQ.NumberValueTo,IQ.PartitionNum
		
		INSERT INTO #PartitionSwitchLog
		SELECT
			Row_Number() OVER (ORDER BY PartitionNum) AS SeqID,
			PartitionNum AS PartitionNum, 
			NumberValueFrom, 
			NumberValueTo,
			NewRowCount,
			TableRowCount
		FROM 
		(	SELECT IQ.NumberValueFrom, IQ.NumberValueTo, IQ.PartitionNum, NewRowCount, ISNULL(FN.TableRowCount, 0) AS TableRowCount 
			FROM #PartitionSwitch IQ
			LEFT JOIN (
						SELECT PartitionNum, COUNT_BIG(1) AS TableRowCount FROM ' + @Main_Table_Name + ' AS FN
						JOIN #PARTITIONS_VALUES AS IQ ON FN.' + @Main_Table_PartitionColumn + ' >= IQ.NumberValueFrom AND FN.' + @Main_Table_PartitionColumn + ' <= IQ.NumberValueTo
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
			''Switch'' AS ActionType,
			SYSDATETIME() AS LogDate
		FROM #PartitionSwitchLog
		OPTION (LABEL = ''' + @Main_Table_Name + ' LOAD: Get changed partitions query'');'		

		IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql

		EXEC (@SQL)

		--IF @Trace_Flag = 1 SELECT 'Utility.PartitionSwitchLog' DataFromTable, * FROM Utility.PartitionSwitchLog WHERE TableName = @Main_Table_Name AND SwitchLogID = @LastSwitchLogID ORDER BY SeqID
		IF @Trace_Flag = 1 SELECT 'Utility.PartitionSwitchLog' DataFromTable, * FROM #PartitionSwitchLog ORDER BY SeqID

		-- Calculate period ranges from Utility.PARTITION_LOAD_DATES_CNT to use index on DAY_ID in a query below. And create a query for each period and UNION ALL them all.
		--SET @PartitionCount = (SELECT ISNULL(MAX(SeqID),0) FROM Utility.PartitionSwitchLog WHERE TableName = @Main_Table_Name AND SwitchLogID = @LastSwitchLogID)
		SET @PartitionCount = (SELECT ISNULL(MAX(SeqID),0) FROM #PartitionSwitchLog)

		SET @FromID = -1
		SET @Cur_Part = -1
		SET @Cur_Ind = 1

		-- MQT - NewTable Query Template
		IF @ComparisonResult <> ''
			SET @SQL_NQT = 'SELECT	' + REPLACE(@SQL_SELECT,'[' + @Main_Table + ']','NSET') + CHAR(13) + 'FROM ' + @New_Schema + '.[' + @New_Table + '] AS NSET' + CHAR(13) + 'WHERE '
	
		WHILE (@Cur_Ind <= @PartitionCount) BEGIN
			-- Initiate all roll variables
			SELECT @PartNum_Loop = PD.PartitionNum, @FromID_Loop = PD.NumberValueFrom, @ToID_Loop = PD.NumberValueTo 
			FROM #PartitionSwitchLog AS PD WHERE PD.SeqID = @Cur_Ind
			--FROM Utility.PartitionSwitchLog AS PD WHERE PD.SeqID = @Cur_Ind AND TableName = @Main_Table_Name AND SwitchLogID = @LastSwitchLogID

			SET @SQL_ALTER = @SQL_ALTER + CHAR(13) + 'ALTER Table ' + @Main_Schema + '.[' + @Main_Table + '] SWITCH PARTITION ' + CAST(@PartNum_Loop AS VARCHAR(10)) + ' TO Old.[' + @Main_Table + '_Switch] PARTITION ' + CAST(@PartNum_Loop AS VARCHAR(10)) + ';'
			SET @SQL_ALTER = @SQL_ALTER + CHAR(13) + 'ALTER Table ' + @SwitchTableName + ' SWITCH PARTITION ' + CAST(@PartNum_Loop AS VARCHAR(10)) + ' TO ' + @Main_Schema + '.[' + @Main_Table + '] PARTITION ' + CAST(@PartNum_Loop AS VARCHAR(10)) + ';'

			-- If they go one by one without a gap - merge 'em all!
			IF (@PartNum_Loop - 1) <> @Cur_Part -- On very first loop it will come inside always, then only if we have a gap between partitions
			-- If not - create a New part of query and start a New period...
			BEGIN
				IF @ComparisonResult <> '' AND @FromID > -1
					SET @SQL_CREATE = @SQL_CREATE + @SQL_NQT + @Main_Table_PartitionColumn + ' BETWEEN ' + CAST(@FromID AS VARCHAR(8)) + ' AND ' + CAST(@ToID AS VARCHAR(8)) + CHAR(13) + 'UNION ALL' + CHAR(13)

				SET @FromID = @FromID_Loop
			END
			SET @ToID = @ToID_Loop
			SET @Cur_Part = @PartNum_Loop
			SET @Cur_Ind += 1 -- 
		END;

		IF @FromID > -1 -- It will be > -1 if at least one loop was done
		BEGIN
			IF @ComparisonResult <> '' 
			BEGIN
				SET @SQL_CREATE = @SQL_CREATE + @SQL_NQT + @Main_Table_PartitionColumn + ' BETWEEN ' + CAST(@FromID AS VARCHAR(8)) + ' AND ' + CAST(@ToID AS VARCHAR(8))

				SET @sql = CHAR(13) + 'IF OBJECT_ID(''Temp.[' + @Main_Table + ']'') IS NOT NULL DROP TABLE Temp.[' + @Main_Table + '];' + CHAR(13)
				SET @sql = @sql + 'CREATE TABLE Temp.[' + @Main_Table + '] WITH (' + @Main_Table_INDEX + ', ' + @Main_Table_DISTRIBUTION + @Main_Table_PARTITION + ') AS' + CHAR(13) + @SQL_CREATE
				+ CHAR(13) + 'OPTION (LABEL = ''Temp.' + @Main_Table + ' LOAD: Get all rows by partitions'');'
				IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
				EXECUTE (@sql);

				EXEC Utility.ToLog @LOG_SOURCE, @START_DATE, '-1', 'I', -1, @sql
			END

			--Switch all changed partitions from Stage to Fact.
			SET @sql = CHAR(13) + 'IF OBJECT_ID(''Old.[' + @Main_Table + '_Switch]'') IS NOT NULL DROP Table Old.[' + @Main_Table + '_Switch];' + CHAR(13)
			SET @sql = @sql + 'CREATE Table Old.[' + @Main_Table + '_Switch] WITH (' + @Main_Table_INDEX + ', ' + @Main_Table_DISTRIBUTION + @Main_Table_PARTITION + ') AS' + CHAR(13) + 'SELECT * FROM ' + @Main_Schema + '.[' + @Main_Table + '] WHERE 1=2'
			IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
			EXECUTE (@sql);

			IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL_ALTER
			EXECUTE (@SQL_ALTER);
			SET  @LOG_MESSAGE = 'Switched ' + CONVERT(VARCHAR,@PartitionCount) + ' Table partitions'
			EXEC Utility.ToLog @LOG_SOURCE, @START_DATE, @LOG_MESSAGE, 'I', NULL, @SQL_ALTER

			SET @sql = CHAR(13) + 'IF OBJECT_ID(''Old.[' + @Main_Table + '_Switch]'') IS NOT NULL DROP Table Old.[' + @Main_Table + '_Switch]'
			IF @Trace_Flag = 0 EXECUTE (@sql);

			IF @ComparisonResult <> ''
			BEGIN
				SET @sql = CHAR(13) + 'IF OBJECT_ID(''Temp.[' + @Main_Table + ']'') IS NOT NULL DROP TABLE Temp.[' + @Main_Table + ']'
				IF @Trace_Flag = 0 EXECUTE (@sql);
			END
		END
	END

	IF @Trace_Flag = 1 EXEC Utility.FromLog @LOG_SOURCE, @START_DATE

END	

/*

IF OBJECT_ID('dbo.PartitionSwitch_Snapshot_Test','U') IS NOT NULL			DROP TABLE dbo.PartitionSwitch_Snapshot_Test;
CREATE TABLE dbo.PartitionSwitch_Snapshot_Test WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(SnapshotMonthID), PARTITION (SnapshotMonthID RANGE RIGHT FOR VALUES (202101,202102,202103,202104,202105,202106))) AS
	SELECT
		ISNULL(CAST(202101 AS INT), 0) AS SnapshotMonthID
		, CAST(5 AS BIGINT) AS CustomerID
		, CAST('This row and partition not presented in a new table - should stay the same' AS VARCHAR(200)) AS ExpectedResult
		, CAST(112.23 AS DECIMAL(19,2)) AS TollAmount
	UNION ALL
	SELECT
		ISNULL(CAST(202102 AS INT), 0) AS SnapshotMonthID
		, CAST(3 AS BIGINT) AS CustomerID
		, CAST('This should not change' AS VARCHAR(200)) AS ExpectedResult
		, CAST(132.23 AS DECIMAL(19,2)) AS TollAmount
	UNION ALL
	SELECT
		ISNULL(CAST(202102 AS INT), 0) AS SnapshotMonthID
		, CAST(2 AS BIGINT) AS CustomerID
		, CAST('This should have change the amount' AS VARCHAR(200)) AS ExpectedResult
		, CAST(34.45 AS DECIMAL(19,2)) AS TollAmount
	UNION ALL
	SELECT				
		ISNULL(CAST(202102 AS INT), 0) AS SnapshotMonthID
		, CAST(0 AS BIGINT) AS CustomerID
		, CAST('This row supposed to be deleted' AS VARCHAR(200)) AS ExpectedResult
		, CAST(01.12 AS DECIMAL(19,2)) AS TollAmount

IF OBJECT_ID('dbo.PartitionSwitch_Snapshot_Test_New','U') IS NOT NULL			DROP TABLE dbo.PartitionSwitch_Snapshot_Test_New;
CREATE TABLE dbo.PartitionSwitch_Snapshot_Test_New WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(SnapshotMonthID), PARTITION (SnapshotMonthID RANGE RIGHT FOR VALUES (202101,202102,202103,202104,202105,202106))) AS
	SELECT
		ISNULL(CAST(202102 AS INT), 0) AS SnapshotMonthID
		, CAST(3 AS BIGINT) AS CustomerID
		, CAST('This should not change' AS VARCHAR(200)) AS ExpectedResult
		, CAST(132.23 AS DECIMAL(19,2)) AS TollAmount
	UNION ALL
	SELECT
		ISNULL(CAST(202102 AS INT), 0) AS SnapshotMonthID
		, CAST(2 AS BIGINT) AS CustomerID
		, CAST('This should have change the amount' AS VARCHAR(200)) AS ExpectedResult
		, CAST(134.45 AS DECIMAL(19,2)) AS TollAmount
	UNION ALL
	SELECT
		ISNULL(CAST(202102 AS INT), 0) AS SnapshotMonthID
		, CAST(3 AS BIGINT) AS CustomerID
		, CAST('This is a new row to insert to 2-nd partition' AS VARCHAR(200))AS ExpectedResult
		, CAST(23.34 AS DECIMAL(19,2)) AS TollAmount
	UNION ALL
	SELECT
		ISNULL(CAST(202103 AS INT), 0) AS SnapshotMonthID
		, CAST(2 AS BIGINT) AS CustomerID
		, CAST('This is a new row to insert to 3-d partition' AS VARCHAR(200))AS ExpectedResult
		, CAST(134.45 AS DECIMAL(19,2)) AS TollAmount

SELECT * FROM dbo.PartitionSwitch_Snapshot_Test ORDER BY SnapshotMonthID,CustomerID
SELECT * FROM dbo.PartitionSwitch_Snapshot_Test_New ORDER BY SnapshotMonthID,CustomerID

DECLARE @Main_Table_Name VARCHAR(200) = 'dbo.PartitionSwitch_Snapshot_Test', @New_Table_Name VARCHAR(200) = 'dbo.PartitionSwitch_Snapshot_Test_New'
EXEC Utility.PartitionSwitch_Snapshot @New_Table_Name, @Main_Table_Name

SELECT * FROM dbo.PartitionSwitch_Snapshot_Test ORDER BY SnapshotMonthID,CustomerID

IF OBJECT_ID('dbo.PartitionSwitch_Snapshot_Test','U') IS NOT NULL			DROP TABLE dbo.PartitionSwitch_Snapshot_Test;
IF OBJECT_ID('dbo.PartitionSwitch_Snapshot_Test_New','U') IS NOT NULL			DROP TABLE dbo.PartitionSwitch_Snapshot_Test_New;



-- Test case of the code with a table where does it used

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
			WHERE s.[name] = 'dbo' AND t.[name] = 'Fact_InvoiceAgingSnapshot'
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

		IF OBJECT_ID('tempdb..#PartitionSwitch') IS NOT NULL DROP Table #PartitionSwitch
		SELECT IQ.NumberValueFrom, IQ.NumberValueTo, IQ.PartitionNum, COUNT_BIG(1) AS NewRowCount 
		INTO #PartitionSwitch
		FROM SANDBOX.dbo.Fact_InvoiceAgingSnapshot_NEW	AS FN
		JOIN #PARTITIONS_VALUES AS IQ ON FN.SnapshotMonthID >= IQ.NumberValueFrom AND FN.SnapshotMonthID <= IQ.NumberValueTo
		GROUP BY IQ.NumberValueFrom,IQ.NumberValueTo,IQ.PartitionNum

		INSERT INTO Utility.PartitionSwitchLog
		SELECT
			1 AS SwitchLogID,
			Row_Number() OVER (ORDER BY PartitionNum) AS SeqID,
			'dbo.Fact_InvoiceAgingSnapshot' AS TableName,
			PartitionNum AS PartitionNum, 
			NumberValueFrom, 
			NumberValueTo,
			NULL AS DateValueFrom,
			NULL AS DateValueTo,
			NewRowCount,
			TableRowCount,
			'Switch' AS ActionType,
			SYSDATETIME() AS LogDate
		FROM 
		(	SELECT IQ.NumberValueFrom, IQ.NumberValueTo, IQ.PartitionNum, NewRowCount, ISNULL(FN.TableRowCount, 0) AS TableRowCount
FROM #PartitionSwitch IQ
LEFT JOIN (	
				SELECT PartitionNum, COUNT_BIG(1) AS TableRowCount 
				FROM dbo.Fact_InvoiceAgingSnapshot FN
				JOIN #PARTITIONS_VALUES AS IQ ON FN.SnapshotMonthID >= IQ.NumberValueFrom AND FN.SnapshotMonthID <= IQ.NumberValueTo
				GROUP BY IQ.PartitionNum
			) AS FN ON FN.PartitionNum = IQ.PartitionNum
			) A
		OPTION (LABEL = ' LOAD: Get changed partitions query');		



*/
