CREATE PROC [Utility].[PartitionSwitch_ExactValue] @Table_Name [VARCHAR](200),@New_Table_Name [VARCHAR](200),@IdentifyingColumns [VARCHAR](8000),@Filter [VARCHAR](8000) AS 
/*
IF OBJECT_ID ('Utility.PartitionSwitch_ExactValue', 'P') IS NOT NULL DROP PROCEDURE Utility.PartitionSwitch_ExactValue
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @IdentifyingColumns VARCHAR(400) = '[TPTRIPID]', @Table_Name VARCHAR(200) = 'Stage.TP_TRIPS', @Filter VARCHAR(4000) =  'UPDATEDDATE >= ''20150101'''
EXEC Utility.PartitionSwitch_ExactValue @Table_Name, Null, @IdentifyingColumns, @Filter
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc is used to move data from a stage table to Production Partitioned table. Partitions on the table should be based on Number type (int, BigInt).
Also the values on the table in the partition column should be always exactly the same, as values on the borders of partitions.
That mean if partition bgorders are 100,200,300,400 - values on the partotion column can be 200, 300 and can't be 201,350 ect.

@Table_Name - Production Partitioned Table name (with Schema) that should get all rows from the New Table.  
@New_Table_Name - The name of a table with the same columns as Table_Name (Nulls and Types can differ) with new data to update Production table. If empty or Null new name will be Table_Name on a 'New' schema
@IdentifyingColumns - List of the columns to uniqually identify rows in both tables.  Needed - can't be empty or Null. 
@Filter - String that needed to filter rows from source table. Source table name should have allias 'NSET', for Destination table allias = Table name. Can be Null.
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837	Andy	2020-04-26	New!
###################################################################################################################
*/

BEGIN
	/*====================================== TESTING =======================================================================*/
	--DECLARE @Table_Name VARCHAR(4000) = '[TollPlus].[TP_Customers]', @New_Table_Name VARCHAR(200), @IdentifyingColumns VARCHAR(400) = '[TPTRIPID]', @Filter VARCHAR(4000) 
	/*====================================== TESTING =======================================================================*/

	DECLARE @LOG_SOURCE VARCHAR(200) = @Table_Name, @Error VARCHAR(MAX) = ''
	DECLARE @START_DATE DATETIME2 (3) = SYSDATETIME(), @LOG_MESSAGE VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing

	IF @Table_Name IS NULL SET @Error = @Error + 'Source Table name cannot be NULL'
	IF @Table_Name = @New_Table_Name SET @Error = @Error + 'Destination Table name cannot be equal to Source Table name'

	IF LEN(@Error) > 0
	BEGIN
		PRINT @Error
		EXEC Utility.FastLog @LOG_SOURCE, @Error, -3
	END
	ELSE
	BEGIN
		DECLARE @Param VARCHAR(100) = 'Alias,Type,NoPrint'
		DECLARE @Table_DISTRIBUTION VARCHAR(100) = @Param, @Table_INDEX VARCHAR(MAX) = @Param, @Table_PARTITION VARCHAR(MAX) = @Param, @Table_PartitionColumn VARCHAR(100) = @Param
		DECLARE @Schema VARCHAR(100), @Table VARCHAR(200), @New_Schema VARCHAR(100), @New_Table VARCHAR(200)
		DECLARE @sql VARCHAR(MAX), @SQL_SELECT VARCHAR(MAX) = @Param, @SQL_WHERE VARCHAR(MAX)
		DECLARE @Cur_Part INT, @Cur_Part_Text VARCHAR(3), @LastSwitchLogID INT = 1
		DECLARE @Temp_PER VARCHAR(MAX), @NUM_IND INT, @CUR_IND INT, @PART_ROLL INT, @PARTITION_VALUES_ROLL INT
		DECLARE @SQL_GET_OLD VARCHAR(MAX) = '', @SQL_GET_New VARCHAR(MAX) = '', @SQL_ALTER VARCHAR(MAX) = '' 
		DECLARE @Dot INT = CHARINDEX('.',@Table_Name)
		DECLARE @Union_Parts VARCHAR(MAX) = '', @Union_Delimiter VARCHAR(1) = '';

		SELECT 
			@Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot + 1,200),'[',''),']','') END

		IF (@New_Table_Name IS NULL) OR (LEN(@New_Table_Name) = 0)
			SET @New_Table_Name = 'New.' + @Table

		SET @Dot = CHARINDEX('.',@New_Table_Name)

		SELECT 
			@New_Schema = CASE WHEN @Dot = 0 THEN 'New' ELSE REPLACE(REPLACE(REPLACE(LEFT(@New_Table_Name,@Dot),'[',''),']',''),'.','') END,
			@New_Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@New_Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@New_Table_Name,@Dot + 1,200),'[',''),']','') END

		EXEC Utility.Get_Distribution_String	@Table_Name, @Table_DISTRIBUTION OUTPUT 
		EXEC Utility.Get_Index_String			@Table_Name, @Table_INDEX OUTPUT 
		EXEC Utility.Get_Partition_String		@Table_Name, @Table_PARTITION OUTPUT 
		EXEC Utility.Get_Select_String			@Table_Name, @SQL_SELECT OUTPUT 
		EXEC Utility.Get_PartitionColumn		@Table_Name, @Table_PartitionColumn OUTPUT 
		EXEC Utility.Get_Where_String			@Table_Name, @IdentifyingColumns, @SQL_WHERE OUTPUT 
	
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
				END AS PARTITION_NUM,
				CASE WHEN CAST(pf.boundary_value_on_right AS INT) = 1 
					THEN ISNULL(CAST(rv.[value] AS BIGINT),CAST(0 AS BIGINT))
					ELSE ISNULL(CAST(rv.[value] AS BIGINT),CAST(9223372036854775800 AS BIGINT))
				END AS PARTITION_VALUES 
			FROM      sys.schemas s
			JOIN      sys.Tables t                  ON t.[schema_id]      = s.[schema_id] AND t.[name] = @Table
			JOIN      sys.partitions p              ON p.[object_id]      = t.[object_id] AND p.[index_id] <=1
			JOIN      sys.indexes i                 ON i.[object_id]      = p.[object_id] AND i.[index_id] = p.[index_id]
			JOIN      sys.data_spaces ds            ON ds.[data_space_id] = i.[data_space_id]
			LEFT JOIN sys.partition_schemes ps      ON ps.[data_space_id] = ds.[data_space_id]
			LEFT JOIN sys.partition_functions pf    ON pf.[function_id]   = ps.[function_id]
			LEFT JOIN sys.partition_range_values rv ON rv.[function_id]   = pf.[function_id] AND rv.[boundary_id] = p.[partition_number]
			WHERE s.name = @Schema  
		)
		SELECT
			PARTITION_NUM,
			CASE WHEN CAST(boundary_value_on_right AS INT) = 1 
				THEN ISNULL(PARTITION_VALUES,0)
				ELSE ISNULL(LAG(PARTITION_VALUES) OVER (ORDER BY PARTITION_NUM) + 1,CAST(0 AS BIGINT))
			END AS PARTITION_VALUES, 
			CASE WHEN CAST(boundary_value_on_right AS INT) = 1 
				THEN ISNULL(LEAD(PARTITION_VALUES) OVER (ORDER BY PARTITION_NUM) - 1, CAST(9223372036854775800 AS BIGINT))
				ELSE ISNULL(PARTITION_VALUES,CAST(9223372036854775800 AS BIGINT))
			END AS PARTITION_VALUES_END 
		FROM CTE

		IF @Trace_Flag = 1 SELECT '#PARTITIONS_VALUES' TableName, * FROM #PARTITIONS_VALUES ORDER BY PARTITION_NUM

		SELECT @LastSwitchLogID = MAX(SwitchLogID) + 1 FROM Utility.PartitionSwitchLog WHERE TableName = @Table_Name
		IF @LastSwitchLogID IS NULL SET @LastSwitchLogID = 1

			----EXPLAIN
		SET @SQL = '
		INSERT INTO Utility.PartitionSwitchLog
		SELECT
			' + CAST(@LastSwitchLogID AS VARCHAR(10)) + ' AS SwitchLogID,
			Row_Number() OVER (ORDER BY PARTITION_NUM) AS SeqID,
			''' + @Table_Name + ''' AS TableName,
			PARTITION_NUM AS PartitionNum, 
			PARTITION_VALUES AS NumberValueFrom, 
			PARTITION_VALUES_END AS NumberValueTo,
			NULL AS DateValueFrom,
			NULL AS DateValueTo,
			CNT AS Row_Count,
			SYSDATETIME() AS LogDate
		FROM 
		(	SELECT IQ.PARTITION_VALUES, IQ.PARTITION_VALUES_END, IQ.PARTITION_NUM, COUNT_BIG(1) AS CNT 
			FROM ' + @New_Schema + '.[' + @New_Table + ']	AS FN
			JOIN #PARTITIONS_VALUES AS IQ ON FN.' + @Table_PartitionColumn + ' = IQ.PARTITION_VALUES
			WHERE ' + @Filter + '
			GROUP BY IQ.PARTITION_VALUES,IQ.PARTITION_VALUES_END,IQ.PARTITION_NUM
			) A
		OPTION (LABEL = ''' + @Table_Name + ' LOAD: Get changed partitions query'');'		

		IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql

		EXEC (@SQL)

		IF @Trace_Flag = 1 SELECT 'Utility.PartitionSwitchLog' DataFromTable, * FROM Utility.PartitionSwitchLog WHERE TableName = @Table_Name AND SwitchLogID = @LastSwitchLogID ORDER BY SeqID

		-- Calculate period ranges from Utility.PARTITION_LOAD_DATES_CNT to use index on DAY_ID in a query below. And create a query for each period and UNION ALL them all.
		SET @NUM_IND = (SELECT MAX(SeqID) FROM Utility.PartitionSwitchLog WHERE TableName = @Table_Name AND SwitchLogID = @LastSwitchLogID)
		SET @CUR_IND = 1

		WHILE (@CUR_IND <= @NUM_IND) BEGIN
			-- Initiate all roll variables
			SELECT @PART_ROLL = PD.PartitionNum, @PARTITION_VALUES_ROLL = PD.NumberValueFrom 
			FROM Utility.PartitionSwitchLog AS PD WHERE PD.SeqID = @CUR_IND AND TableName = @Table_Name AND SwitchLogID = @LastSwitchLogID

			SET @SQL_ALTER = @SQL_ALTER + CHAR(13) + 'ALTER Table ' + @Schema + '.[' + @Table + '] SWITCH PARTITION ' + CAST(@PART_ROLL AS VARCHAR(10)) + ' TO Old.[' + @Table + '_Switch] PARTITION ' + CAST(@PART_ROLL AS VARCHAR(10)) + ';'
			SET @SQL_ALTER = @SQL_ALTER + CHAR(13) + 'ALTER Table Temp.[' + @Table + '] SWITCH PARTITION ' + CAST(@PART_ROLL AS VARCHAR(10)) + ' TO ' + @Schema + '.[' + @Table + '] PARTITION ' + CAST(@PART_ROLL AS VARCHAR(10)) + ';'

			SET @Union_Parts = @Union_Parts + @Union_Delimiter + CAST(@PARTITION_VALUES_ROLL AS VARCHAR(20))
			SET @Union_Delimiter = ','

			SET @CUR_IND += 1 -- 
		END;

		IF LEN(@Union_Parts) > 0
		BEGIN
			SET @sql = CHAR(13) + 'IF OBJECT_ID(''Temp.[' + @Table + ']'') IS NOT NULL DROP TABLE Temp.[' + @Table + '];' + CHAR(13)
			SET @sql = @sql + 'CREATE TABLE Temp.[' + @Table + '] WITH (' + @Table_INDEX + ', ' + @Table_DISTRIBUTION + @Table_PARTITION + ') AS' + CHAR(13) + 'SELECT	' + @SQL_SELECT + CHAR(13) + 'FROM ' + @Schema + '.[' + @Table + '] AS [' + @Table + ']' + CHAR(13)
			SET @sql = @sql + 'WHERE NOT EXISTS (SELECT 1 FROM ' + @New_Schema + '.[' + @New_Table + '] AS NSET WHERE ' + @SQL_WHERE + ') AND ' + @Table_PartitionColumn + ' IN ( '+ @Union_Parts + ')' + CHAR(13) + 'UNION ALL' + CHAR(13) + 'SELECT	' + REPLACE(@SQL_SELECT,'[' + @Table + '].','NSET.') + CHAR(13)
			SET @sql = @sql + 'FROM ' + @New_Schema + '.[' + @New_Table + '] AS NSET WHERE ' + @Table_PartitionColumn + ' IN ( '+ @Union_Parts + ') AND ' + @FILTER + CHAR(13) + 'OPTION (LABEL = ''Temp.' + @Table_Name + ' LOAD: Get all changed rows by partitions'');'

			IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
			EXECUTE (@sql); 

			EXEC Utility.ToLog @LOG_SOURCE, @START_DATE, '-1', 'I', -1, @sql

			--STEP #10: Switch all changed partitions from Stage to Fact.
			SET @sql = CHAR(13) + 'IF OBJECT_ID(''Old.[' + @Table + '_Switch]'') IS NOT NULL DROP Table Old.[' + @Table + '_Switch];' + CHAR(13)
			SET @sql = @sql + 'CREATE Table Old.[' + @Table + '_Switch] WITH (' + @Table_INDEX + ', ' + @Table_DISTRIBUTION + @Table_PARTITION + ') AS' + CHAR(13) + 'SELECT * FROM ' + @Schema + '.[' + @Table + '] WHERE 1=2'
			IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
			EXECUTE (@sql);

			IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL_ALTER
			EXECUTE (@SQL_ALTER);
			SET  @LOG_MESSAGE = 'Switched ' + CONVERT(VARCHAR,@NUM_IND) + ' Table partitions' + ISNULL('. @Filter: ' + NULLIF(@Filter,'1 = 1'),'')
			EXEC Utility.ToLog @LOG_SOURCE, @START_DATE, @LOG_MESSAGE, 'I', NULL, @SQL_ALTER

			SET @sql = CHAR(13) + 'IF OBJECT_ID(''Temp.[' + @Table + ']'') IS NOT NULL DROP Table Temp.[' + @Table + ']'
			IF @Trace_Flag = 0 EXECUTE (@sql);
		END

	END

	IF @Trace_Flag = 1 EXEC Utility.FromLog @LOG_SOURCE, @START_DATE

END	


