CREATE PROC [Utility].[Get_UpdateTable_SQL] @TableName [VARCHAR](200),@Source_TableName [VARCHAR](200),@IdentifyingColumns [VARCHAR](8000),@Params_In_SQL_Out [VARCHAR](MAX) OUT AS
/*
USE EDW_TRIPS
GO
IF OBJECT_ID ('Utility.Get_UpdateTable_SQL', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_UpdateTable_SQL
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'Table:NewSet,No[]'
	,@TableName VARCHAR(100)  = '[TollPlus].[TP_Customers]'
	,@Source_TableName VARCHAR(100)  = '[TollPlus].[TP_Customers_Attunity]'
	,@IdentifyingColumns VARCHAR(8000)  = '[CustomerID]'

EXEC Utility.Get_UpdateTable_SQL @TableName, @Source_TableName, @IdentifyingColumns, @Params_In_SQL_Out OUTPUT 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning SQL statement to update table using data from Source_TableName.
Updating only those columns, that have equal column names.
Identifying rows by IdentifyingColumns - values should be the same.

@Table_Name - Table name (with Schema) is table to update. Can't be Null.
@Source_TableName - Table with new values in some columns. Can't be Null.
@IdentifyingColumns - List of the columns to uniqually identify rows in both tables.  Needed - can't be empty or Null. 
@Params_In_SQL_Out - Param to return SQL statement. Can take some secondary parameters
	can include values: 	'No[],NoPrint,Table:Short or Long or YourName'
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
###################################################################################################################
*/

BEGIN

	DECLARE @Error VARCHAR(MAX) = ''
	DECLARE @Params VARCHAR(100) = ISNULL(@Params_In_SQL_Out,'')

	IF @TableName IS NULL SET @Error = @Error + 'Update Table name cannot be NULL'
	IF @Source_TableName IS NULL SET @Error = @Error + CHAR(13) + 'Source Table name cannot be NULL'

	IF @TableName = @Source_TableName SET @Error = @Error + CHAR(13) + 'Source Table cannot be the same as Update Table'

	SET @Params_In_SQL_Out = '';

	IF LEN(@Error) > 0
	BEGIN
		PRINT @Error
	END
	ELSE
	BEGIN

		DECLARE @Schema VARCHAR(100), @Table VARCHAR(200), @From_Schema VARCHAR(100),@From_Table VARCHAR(200), @Index INT
		DECLARE @Dot1 INT = CHARINDEX('.',@TableName), @Dot2 INT = CHARINDEX('.',@Source_TableName), @NoBrackets BIT = 0, @IDHasBrackets BIT = 0
		DECLARE @SQL_WHERE VARCHAR(MAX) = '', @SQL_Update VARCHAR(MAX) = '', @TableAlias VARCHAR(40) = 'NSet'
		DECLARE @ColumnsCnt INT, @Indicat INT = 1, @Delimiter VARCHAR(2) = '  ', @Delimiter_AND VARCHAR(8) = ''
		DECLARE @WHERE_String VARCHAR(MAX) = '', @Update_String VARCHAR(MAX) = '', @ColumnName VARCHAR(100) = ''

		SELECT 
			@Schema = CASE WHEN @Dot1 = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@TableName,@Dot1),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot1 = 0 THEN REPLACE(REPLACE(@TableName,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@TableName,@Dot1 + 1,200),'[',''),']','') END,
			@From_Schema = CASE WHEN @Dot2 = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Source_TableName,@Dot2),'[',''),']',''),'.','') END,
			@From_Table = CASE WHEN @Dot2 = 0 THEN REPLACE(REPLACE(@Source_TableName,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Source_TableName,@Dot2 + 1,200),'[',''),']','') END,
			@IDHasBrackets = CASE WHEN CHARINDEX('[',@IdentifyingColumns) > 0 THEN 1 ELSE 0 END

		SET @Params = REPLACE(REPLACE(@Params,' ',''),'	','')
		SELECT @Index = ISNULL(NULLIF(CHARINDEX('Alias:',@Params),0),CHARINDEX('Table:',@Params))
		IF @Index > 0 -- In this brackets only the table name can be we need to put in AS
		BEGIN
			SET @TableAlias = SUBSTRING(@Params,CHARINDEX(':',@Params,@Index) + 1, ISNULL(NULLIF(CHARINDEX(',',@Params,@Index),0), LEN(@Params) + 1) - CHARINDEX(':',@Params,@Index) - 1)

			SET @Params = REPLACE(REPLACE(@Params,'Table:' + @TableAlias,'Alias'),'Alias:' + @TableAlias,'Alias')-- If table include somehow one of the key word (like table, Type or Alias) - we have to remove it

			IF @TableAlias = 'Short'
				SELECT @TableAlias = AliasShort FROM Utility.TableAlias WHERE TableName = @From_Schema + '.' + @From_Table;
			IF @TableAlias = 'Long'
				SELECT @TableAlias = AliasLong FROM Utility.TableAlias WHERE TableName = @From_Schema + '.' + @From_Table;
			IF @TableAlias = 'Full'
				SELECT @TableAlias = @From_Table;
		END

		IF OBJECT_ID('tempdb..#TableColums') IS NOT NULL DROP TABLE #TableColums;
		-- Should get only columns that are matching by names
		SELECT      c.name AS ColumnName, 
					ROW_NUMBER() OVER(ORDER BY C.column_id) AS RN
		INTO #TableColums
		FROM        sys.columns c
		JOIN        sys.Tables  t   ON c.object_id = t.object_id AND t.name = @Table
		JOIN		sys.schemas s ON t.schema_id = s.schema_id AND s.name = @Schema
		JOIN        sys.columns c2 ON c2.name = C.name
		JOIN        sys.Tables  t2   ON c2.object_id = t2.object_id AND t2.name = @From_Table
		JOIN		sys.schemas s2 ON t2.schema_id = s2.schema_id AND s2.name = @From_Schema

		SELECT @ColumnsCnt = MAX(RN) FROM #TableColums

		WHILE (@Indicat <= @ColumnsCnt)
		BEGIN
			WITH CTE_Col AS
			(
				SELECT	  
					M.ColumnName,
					CASE WHEN @IDHasBrackets = 1 THEN '[' + M.ColumnName + ']' ELSE M.ColumnName END AS ColumnNameToLookFor
				FROM #TableColums M
				WHERE M.RN = @Indicat
			)
			SELECT	  
				@WHERE_String = CASE WHEN CHARINDEX(ColumnNameToLookFor, @IdentifyingColumns) > 0 THEN @Delimiter_AND + '[' + @Table + '].[' + ColumnName + '] = [' + @TableAlias + '].[' + ColumnName + ']' ELSE '' END,
				@Update_String = CASE WHEN CHARINDEX(ColumnNameToLookFor, @IdentifyingColumns) = 0 THEN @Delimiter + '[' + @Table + '].[' + ColumnName + '] = [' + @TableAlias + '].[' + ColumnName + ']' ELSE '' END
			FROM CTE_Col


			IF LEN(@WHERE_String) > 0 
			BEGIN
				SET @SQL_WHERE = @SQL_WHERE + @WHERE_String
				SET	@Delimiter_AND = CHAR(13) + CHAR(10) + CHAR(9) + 'AND '
			END
			IF LEN(@Update_String) > 0 
			BEGIN
				SET @SQL_Update = @SQL_Update + CHAR(13) + CHAR(10) + CHAR(9)  + @Update_String
				SET	@Delimiter = ', '
			END

			SET @Indicat += 1
		END

		SET @Params_In_SQL_Out = 'UPDATE [' + @Schema + '].[' + @Table + '] SET' + @SQL_Update + CHAR(13) + 'FROM	[' + @From_Schema + '].[' + @From_Table + '] AS [' + @TableAlias + ']' + CHAR(13) + 'WHERE ' + @SQL_WHERE

		IF CHARINDEX('No[]',@Params) > 0
			SET @Params_In_SQL_Out = REPLACE(REPLACE(@Params_In_SQL_Out,'[',''),']','')

		IF CHARINDEX('NoPrint',@Params) = 0
			EXEC Utility.LongPrint @Params_In_SQL_Out
	END
END
