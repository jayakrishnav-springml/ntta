CREATE PROC [Utility].[DeleteDuplicateRows] @Table_Name [VARCHAR](130),@IdentifyingColumns [VARCHAR](800),@OrderByString [VARCHAR](800) AS
/*
USE EDW_TRIPS 
GO
IF OBJECT_ID ('Utility.DeleteDuplicateRows', 'P') IS NOT NULL DROP PROCEDURE Utility.DeleteDuplicateRows
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @IdentifyingColumns VARCHAR(400) = '[TpTripID]', @OrderByString VARCHAR(MAX) = 'TripDate DESC',@Table_Name VARCHAR(200)  = '[dbo].[Fact_Transaction]'
EXEC Utility.DeleteDuplicateRows @Table_Name, @IdentifyingColumns, @OrderByString  

DECLARE @IdentifyingColumns VARCHAR(400) = '[CitationID],[SnapshotMonthID]', @OrderByString VARCHAR(MAX) = 'TransactionDate DESC',@Table_Name VARCHAR(200)  = '[dbo].[Fact_InvoiceAgingSnapshot]'
EXEC Utility.DeleteDuplicateRows @Table_Name, @IdentifyingColumns, @OrderByString  

SELECT * FROM Utility.ProcessLog WHERE LogSource = 'Utility.DeleteDuplicateRows' ORDER BY 1 DESC
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc developed to find and Delete duplicates on the table

@Table_Name - Table name (with Schema) - table for get columns from
@IdentifyingColumns - List of the columns to uniqually identify rows in both tables.  Needed - can't be empty or Null. !!!!!!!!  EVERY COLUMN SHOULD BE IN [], Separator - up to you  !!!!!!!!!!!
@OrderByString - ORDER BY String to put to ROW_NUMBER() statement. Looks Like 'TripDate DESC, TPTripID ASC'. If empty it will create it from @IdentifyingColumns with DESC 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0038817	Andy	05/03/2020	New!
###################################################################################################################
*/


BEGIN
	
	BEGIN TRY

		SET NOCOUNT ON
		
		DECLARE @Log_Source VARCHAR(100) = 'Utility.DeleteDuplicateRows', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Error_Message VARCHAR(MAX), @Row_Count BIGINT, @Trace_Flag BIT = 1 -- Keep it ON!
		SET @Log_Message = 'Started Duplicate Rows cleanup in ' + ISNULL(@Table_Name,' ? table')
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
		
		--:: Validate input parameters
		IF @Table_Name IS NULL SET @Error_Message = @Error_Message + 'Table Name cannot be NULL'
		IF CHARINDEX(')',@OrderByString) > 0 SET @Error_Message = @Error_Message + 'Do not try to use SQL injection! It is forbidden!'
		IF LEN(@Error_Message) > 0
			RAISERROR (@Error_Message, 16, 1)

		DECLARE @Schema VARCHAR(100), @Table VARCHAR(200), @NumOfColumns INT, @ColumnName VARCHAR(100), @INDICAT INT = 1, @SQL VARCHAR(MAX), @ORDER_BY VARCHAR(400)
		DECLARE @WHERE VARCHAR(800) = '', @SQL_SELECT VARCHAR(MAX) = 'NoPrint', @DISTRIBUTION VARCHAR(400), @UID_Columns VARCHAR(400) = '', @Delimiter_AND VARCHAR(5) = '', @Delimiter_Comma VARCHAR(3) = ''
		DECLARE @Dot INT = CHARINDEX('.',@Table_Name)

		SELECT 
			@Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot + 1,200),'[',''),']','') END

		EXEC Utility.Get_Select_String	@Table_Name, @SQL_SELECT OUTPUT 

		IF OBJECT_ID('tempdb..#Table_COLUMNS') IS NOT NULL DROP Table #Table_COLUMNS;
		SELECT      C.name AS ColumnName,
					ROW_NUMBER() OVER(ORDER BY C.column_id) AS RN
					INTO #Table_COLUMNS
		FROM sys.columns C
		JOIN sys.Tables  t ON C.[object_id] = t.[object_id]  AND t.name = @Table
		JOIN sys.schemas s ON t.[schema_id] = s.[schema_id] AND s.name = @Schema
		WHERE CHARINDEX('[' + C.name + ']', @IdentifyingColumns) > 0 
		
		SET @DISTRIBUTION = LEFT(@IdentifyingColumns,CASE WHEN CHARINDEX(',',@IdentifyingColumns) = 0 THEN LEN(@IdentifyingColumns) ELSE CHARINDEX(',',@IdentifyingColumns)-1 END) -- It's only first column from the list of Identifying columns

		SELECT @NumOfColumns = MAX(RN) FROM #Table_COLUMNS
		WHILE (@INDICAT <= @NumOfColumns)
		BEGIN
			SELECT	  @ColumnName = M.ColumnName
			FROM #Table_COLUMNS M
			WHERE M.RN = @INDICAT
			
			SET @WHERE = @WHERE + @Delimiter_AND + '[' +@Table + '].[' + @ColumnName + '] = [Dups].[' + @ColumnName + ']'
			SET @ORDER_BY = @ORDER_BY + @Delimiter_AND + '[' + @ColumnName + '] DESC'
			SET @UID_Columns = @UID_Columns + @Delimiter_Comma + '[' +@ColumnName + ']'
			SET	@Delimiter_AND = ' AND '
			SET	@Delimiter_Comma = ', '
			SET @INDICAT += 1
		END

		IF @OrderByString IS NULL SET @OrderByString = @ORDER_BY

		IF @Trace_Flag = 1 SELECT * FROM #Table_COLUMNS
		IF @Trace_Flag = 1 SELECT @DISTRIBUTION [@DISTRIBUTION], @WHERE [@WHERE], @ORDER_BY [@ORDER_BY], @UID_Columns [@UID_Columns], @NumOfColumns [@NumOfColumns], @INDICAT [@INDICAT]

		--:: Find the duplicate rows
		SET @SQL = 'IF OBJECT_ID(''Temp.' + @Table + '_DUPS'') IS NOT NULL DROP TABLE Temp.' + @Table + '_DUPS;
		CREATE TABLE Temp.' + @Table + '_DUPS WITH (HEAP, DISTRIBUTION = HASH('+ @DISTRIBUTION +')) AS 
		SELECT ' + @UID_Columns + ', count(1) CNT 
		FROM ' + @Schema + '.[' + @Table + '] 
		GROUP BY ' + @UID_Columns + ' 
		HAVING count(1) > 1'

		IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL
		EXEC (@SQL)
		
		SET  @Log_Message = 'Loaded Temp.' + @Table + '_DUPS with duplicate keys'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, -1

		--:: Save all rows from main table related to the duplicate keys
		SET @SQL = 'IF OBJECT_ID(''Temp.' + @Table + '_TO_INSERT'') IS NOT NULL DROP TABLE Temp.' + @Table + '_TO_INSERT;
		CREATE TABLE Temp.' + @Table + '_TO_INSERT WITH (HEAP, DISTRIBUTION = HASH('+ @DISTRIBUTION +')) AS --EXPLAIN
		SELECT 
			*
		FROM (
			SELECT 
				' + @SQL_SELECT + ' 
				, ROW_NUMBER() OVER (PARTITION BY ' + @UID_Columns + ' ORDER BY ' + @OrderByString + ') RN
			FROM ' + @Schema + '.[' + @Table + '] AS [' + @Table + '] WHERE EXISTS (SELECT 1 FROM Temp.' + @Table + '_DUPS AS Dups WHERE '+ @WHERE + ')
		) A	'
		IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL

		BEGIN TRY
			EXEC (@SQL)
		END	TRY	
		BEGIN CATCH
			SET @Error_Message = 'Check out your input parameters! You have got an error! I assume you sent the wrong @OrderByString! Error massage: ' + ERROR_MESSAGE()
			RAISERROR (@Error_Message, 16, 1)
		END CATCH

		SET  @Log_Message = 'Loaded Temp.' + @Table + '_TO_INSERT with duplicate keys'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, -1

		--:: Delete all rows related to duplicate keys from the table and re-insert unique rows
		SET @SQL = '
		DELETE 
		FROM ' + @Schema + '.[' + @Table + ']
		WHERE EXISTS (SELECT 1 FROM Temp.' + @Table + '_DUPS AS Dups WHERE '+ @WHERE + ')

		INSERT INTO ' + @Schema + '.[' + @Table + ']
		SELECT ' + @SQL_SELECT + '
		FROM Temp.' + @Table + '_TO_INSERT
		WHERE RN = 1'

		IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL
		EXEC (@SQL)

		SET  @Log_Message = 'Deleted all rows related to duplicate keys from ' + @Schema + '.' + @Table + ' and inserted unique rows!' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, -1

		IF @Trace_Flag = 1
		BEGIN
			SET @SQL = '
			SELECT TOP 1000 ''Dup Before'' Result, *
			FROM Temp.' + @Table + '_TO_INSERT 
			ORDER BY ' + @UID_Columns + ', RN ASC' 
			EXEC (@SQL)
		
			SET @SQL = 'SELECT ''Dup After'' Result,' + @UID_Columns + ', count(1) DupRowCount 
			FROM ' + @Schema + '.[' + @Table + '] 
			GROUP BY ' + @UID_Columns + ' 
			HAVING count(1) > 1'
			EXEC (@SQL)
		END

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed Duplicate Rows cleanup', 'I', NULL, NULL
	END	TRY
	
	BEGIN CATCH
		
		SET @Error_Message = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error!
	
	END CATCH

END


