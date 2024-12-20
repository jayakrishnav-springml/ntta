CREATE PROC [Utility].[Get_Where_String] @Table_Name [VARCHAR](130),@IdentifyingColumns [VARCHAR](400),@SQL_String [VARCHAR](4000) OUT AS
/*
USE LND_TBOS 
GO
IF OBJECT_ID ('Utility.Get_Where_String', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_Where_String
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @SQL_String VARCHAR(4000)
EXEC Utility.Get_Where_String '[COURT].[Counties]','[CountyID]', @SQL_String OUTPUT 
EXEC Utility.LongPrint @SQL_String
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning part of SQL statement to use in Where statement in the special queries - uses only from PartitionSwitch procs.
Returning string like '[Table].[ColumnID] = [NSET].[ColumnID]'

@Table_Name - Table name (with Schema) is example for copy
@IdentifyingColumns - List of the columns to uniqually identify rows in both tables.  Needed - can't be empty or Null. 
@SQL_String - Param to return SQL statement. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
###################################################################################################################
*/


BEGIN
	/*====================================== TESTING =======================================================================*/
	--DECLARE @SQL_String VARCHAR(4000), @Table_Name VARCHAR(200) = '[COURT].[Counties]', @IdentifyingColumns VARCHAR(100) = '[CountyID]'
	/*====================================== TESTING =======================================================================*/

	DECLARE @Error VARCHAR(MAX) = ''

	IF @Table_Name IS NULL SET @Error = @Error + 'Table name cannot be NULL'
	SET @SQL_String = '';

	IF LEN(@Error) > 0
	BEGIN
		PRINT @Error
	END
	ELSE
	BEGIN

		DECLARE @Schema VARCHAR(100), @Table VARCHAR(200), @NUM_OF_COLUMNS INT, @ColumnName VARCHAR(100), @INDICAT INT = 1, @Delimiter_AND VARCHAR(5) = ''
		DECLARE @Dot INT = CHARINDEX('.',@Table_Name)

		SELECT 
			@Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot + 1,200),'[',''),']','') END

		IF OBJECT_ID('tempdb..#Table_COLUMNS') IS NOT NULL DROP Table #Table_COLUMNS;
		SELECT      C.name AS ColumnName,
					ROW_NUMBER() OVER(ORDER BY C.column_id) AS RN
					INTO #Table_COLUMNS
		FROM sys.columns C
		JOIN sys.Tables  t ON C.[object_id] = t.[object_id]  AND t.name = @Table
		JOIN sys.schemas s ON t.[schema_id] = s.[schema_id] AND s.name = @Schema
		WHERE CHARINDEX('[' + C.name + ']', @IdentifyingColumns) > 0 

		SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #Table_COLUMNS
		WHILE (@INDICAT <= @NUM_OF_COLUMNS)
		BEGIN
			SELECT	  @ColumnName = M.ColumnName
			FROM #Table_COLUMNS M
			WHERE M.RN = @INDICAT
		
			SET @SQL_String = @SQL_String + @Delimiter_AND + '[' +@Table + '].[' + @ColumnName + ']' + ' = [NSET].[' + @ColumnName + ']'
			SET	@Delimiter_AND = ' AND '
			SET @INDICAT += 1
		END

	END

END

