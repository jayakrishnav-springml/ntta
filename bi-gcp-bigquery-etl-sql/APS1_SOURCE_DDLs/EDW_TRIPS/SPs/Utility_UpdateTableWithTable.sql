CREATE PROC [Utility].[UpdateTableWithTable] @Source_Table_Name [VARCHAR](200),@Main_Table_Name [VARCHAR](200),@IdentifyingColumns [VARCHAR](8000),@Filter [VARCHAR](8000) AS 
/*
IF OBJECT_ID ('Utility.UpdateTableWithTable', 'P') IS NOT NULL DROP PROCEDURE Utility.UpdateTableWithTable
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @IdentifyingColumns VARCHAR(400) = '[TPTRIPID]', @Source_Table_Name VARCHAR(200) = 'dbo.Dim_CustomerTags_NEW', @Main_Table_Name VARCHAR(200) = 'dbo.Dim_CustomerTags', @Filter VARCHAR(4000) =  'UPDATEDDATE >= ''20150101'''
EXEC Utility.UpdateTableWithTable @Source_Table_Name, @Main_Table_Name, @IdentifyingColumns, @Filter
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc is used to move data from a stage table to Production Partitioned table. Partitions on the table should be based on Number type (int, BigInt).
Also the values on the table in the partition column should be always exactly the same, as values on the borders of partitions.
That mean if partition bgorders are 100,200,300,400 - values on the partotion column can be 200, 300 and can't be 201,350 ect.

@Main_Table_Name - Production Table name (with Schema) that should get all rows from the New Table.  
@Source_Table_Name - The name of a table with the same columns as Table_Name (Nulls and Types can differ) with new data to update Production table. If empty or Null new name will be Table_Name on a 'New' schema
@IdentifyingColumns - List of the columns to uniqually identify rows in both tables.  Needed - can't be empty or Null. 
@Filter - String that needed to filter rows from source table. Source table name should have allias 'NSET', for Destination table allias = Table name. Can be Null.
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0038319 	Andy		2021-03-08  New!
###################################################################################################################
*/

BEGIN
	/*====================================== TESTING =======================================================================*/
	--DECLARE @Main_Table_Name VARCHAR(4000) = 'dbo.Dim_CustomerTags', @Source_Table_Name VARCHAR(200) = 'dbo.Dim_CustomerTags_NEW', @IdentifyingColumns VARCHAR(400) = '[TPTRIPID]', @Filter VARCHAR(4000) 
	/*====================================== TESTING =======================================================================*/

	DECLARE @LOG_SOURCE VARCHAR(200) = @Main_Table_Name, @Error VARCHAR(MAX) = ''
	DECLARE @START_DATE DATETIME2 (3) = SYSDATETIME(), @LOG_MESSAGE VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing

	IF @Main_Table_Name IS NULL SET @Error = @Error + 'Source Table name cannot be NULL'
	IF @Main_Table_Name = @Source_Table_Name SET @Error = @Error + 'Destination Table name cannot be equal to Source Table name'

	IF LEN(@Error) > 0
	BEGIN
		PRINT @Error
		EXEC Utility.FastLog @LOG_SOURCE, @Error, -3
	END
	ELSE
	BEGIN
		DECLARE @Param VARCHAR(100) = 'Alias,Type,NoPrint'
		DECLARE @Table_DISTRIBUTION VARCHAR(100) = @Param, @Table_INDEX VARCHAR(MAX) = @Param, @Table_PARTITION VARCHAR(MAX) = @Param, @CreateStatistics_SQL VARCHAR(8000) = @Param
		DECLARE @Schema VARCHAR(30), @Table VARCHAR(100), @New_Schema VARCHAR(30), @New_Table VARCHAR(100)
		DECLARE @sql VARCHAR(MAX), @SQL_SELECT VARCHAR(MAX) = @Param, @SQL_WHERE VARCHAR(MAX)
		DECLARE @SQL_ALTER VARCHAR(MAX) = @Param + ',KeepOld', @TempTableName VARCHAR(100)
		DECLARE @Dot INT = CHARINDEX('.',@Main_Table_Name)

		SELECT 
			@Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Main_Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Main_Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Main_Table_Name,@Dot + 1,200),'[',''),']','') END

		IF (@Source_Table_Name IS NULL) OR (LEN(@Source_Table_Name) = 0)
			SET @Source_Table_Name = 'New.' + @Table

		SET @Dot = CHARINDEX('.',@Source_Table_Name)

		SELECT 
			@New_Schema = CASE WHEN @Dot = 0 THEN 'New' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Source_Table_Name,@Dot),'[',''),']',''),'.','') END,
			@New_Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Source_Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Source_Table_Name,@Dot + 1,200),'[',''),']','') END
		
		SET @TempTableName = '[Temp].[' + @Table + ']'

		EXEC Utility.Get_Distribution_String	@Main_Table_Name, @Table_DISTRIBUTION OUTPUT 
		EXEC Utility.Get_Index_String			@Main_Table_Name, @Table_INDEX OUTPUT 
		EXEC Utility.Get_Partition_String		@Main_Table_Name, @Table_PARTITION OUTPUT 
		EXEC Utility.Get_Select_String			@Main_Table_Name, @SQL_SELECT OUTPUT 
		EXEC Utility.Get_Where_String			@Main_Table_Name, @IdentifyingColumns, @SQL_WHERE OUTPUT 
		EXEC Utility.Get_CreateStatistics_SQL	@Main_Table_Name, @TempTableName, @CreateStatistics_SQL  OUTPUT
		EXEC Utility.Get_TransferObject_SQL		@TempTableName, @Main_Table_Name, @SQL_ALTER OUTPUT 
	
		SELECT @Filter = CASE WHEN ISNULL(@Filter,'') = '' THEN '1 = 1' ELSE @Filter END

		SET @sql = CHAR(13) + 'IF OBJECT_ID(''' + @TempTableName + ''') IS NOT NULL DROP TABLE ' + @TempTableName + ';' + CHAR(13)
		SET @sql = @sql + 'CREATE TABLE ' + @TempTableName + ' WITH (' + @Table_INDEX + ', ' + @Table_DISTRIBUTION + @Table_PARTITION + ') AS' + CHAR(13) + 'SELECT	' + @SQL_SELECT + CHAR(13) + 'FROM ' + @Schema + '.[' + @Table + '] AS [' + @Table + ']' + CHAR(13)
		SET @sql = @sql + 'WHERE NOT EXISTS (SELECT 1 FROM ' + @New_Schema + '.[' + @New_Table + '] AS NSET WHERE ' + @SQL_WHERE + ') ' + CHAR(13) + 'UNION ALL' + CHAR(13) + 'SELECT	' + REPLACE(@SQL_SELECT,'[' + @Table + '].','NSET.') + CHAR(13)
		SET @sql = @sql + 'FROM ' + @New_Schema + '.[' + @New_Table + '] AS NSET WHERE ' + @FILTER + CHAR(13) + 'OPTION (LABEL = ''' + @TempTableName + ' LOAD: Get all changed rows'');'

		IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
		EXECUTE (@sql); 
		EXEC Utility.ToLog @LOG_SOURCE, @START_DATE, '-1', 'I', -1, @sql

		IF @Trace_Flag = 1 EXEC Utility.LongPrint @CreateStatistics_SQL
		EXEC (@CreateStatistics_SQL)
		
		IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL_ALTER
		EXEC (@SQL_ALTER)

	END

	IF @Trace_Flag = 1 EXEC Utility.FromLog @LOG_SOURCE, @START_DATE

END	


