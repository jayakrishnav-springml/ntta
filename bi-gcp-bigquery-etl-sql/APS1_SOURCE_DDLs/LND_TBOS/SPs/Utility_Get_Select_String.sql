CREATE PROC [Utility].[Get_Select_String] @Table_Name [VARCHAR](200),@Params_In_SQL_Out [VARCHAR](MAX) OUT AS
/*
USE LND_TBOS 
GO
IF OBJECT_ID ('Utility.Get_Select_String', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_Select_String
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'Types,Alias,TitleCase,No[]',@Table_Name VARCHAR(200)  = '[TollPlus].[TP_Customers]'
EXEC Utility.Get_Select_String @Table_Name, @Params_In_SQL_Out OUTPUT 

DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'Alias:TPC,Types',@Table_Name VARCHAR(200)  = '[TollPlus].[TP_Customers]'
EXEC Utility.Get_Select_String @Table_Name, @Params_In_SQL_Out OUTPUT 

DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'Alias:Long,TitleCase,No[]',@Table_Name VARCHAR(200)  = '[TollPlus].[TP_Customers]'
EXEC Utility.Get_Select_String @Table_Name, @Params_In_SQL_Out OUTPUT 

DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'No[]',@Table_Name VARCHAR(200)  = '[TollPlus].[TP_Customers]'
EXEC Utility.Get_Select_String @Table_Name, @Params_In_SQL_Out OUTPUT 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning part of SQL statement of all table columns to use in queries like Select and Create as Select 
Depends on Parameters it can be just list of names devided by comma, or use cast, ISNULL and allias. See example.

@Table_Name - Table name (with Schema) - table for get columns from
@Params_In_SQL_Out - Param to return SQL statement. Can take some secondary parameters
	can include values: 	'Types,Alias:Short or Long or YourAlias,TitleCase,No[],NoPrint'
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
###################################################################################################################
*/


BEGIN
	SET NOCOUNT ON
	DECLARE @Error VARCHAR(MAX) = ''
	DECLARE @Params VARCHAR(100) = ISNULL(@Params_In_SQL_Out,'')
	SET @Params_In_SQL_Out = '';
	IF @Table_Name IS NULL SET @Error = @Error + 'Table Name cannot be NULL'
	IF LEN(@Error) > 0
		PRINT @Error
	ELSE
	BEGIN

		DECLARE @Schema VARCHAR(100), @Table VARCHAR(200), @NunOfColumns INT
		DECLARE @Dot INT = CHARINDEX('.',@Table_Name)
		DECLARE @Types TINYINT = 0, @Alias TINYINT = 0, @TitleCase TINYINT = 0, @TableAlias VARCHAR(40), @Index INT

		SELECT 
			@Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot + 1,200),'[',''),']','') END

		SET @TableAlias = @Table
		SET @Params = REPLACE(REPLACE(@Params,' ',''),'	','')
		SELECT @Index = ISNULL(NULLIF(CHARINDEX('Alias:',@Params),0),CHARINDEX('Table:',@Params))
		IF @Index > 0 -- In this brackets only the table name can be we need to put in AS
		BEGIN
			SET @TableAlias = SUBSTRING(@Params,CHARINDEX(':',@Params,@Index) + 1, ISNULL(NULLIF(CHARINDEX(',',@Params,@Index),0), LEN(@Params) + 1) - CHARINDEX(':',@Params,@Index) - 1)

			SET @Params = REPLACE(REPLACE(@Params,'Table:' + @TableAlias,'Alias'),'Alias:' + @TableAlias,'Alias')-- If table include somehow one of the key word (like table, Type or Alias) - we have to remove it

			IF @TableAlias = 'Short'
				SELECT @TableAlias = AliasShort FROM Utility.TableAlias WHERE TableName = @Schema + '.' + @Table;
			IF @TableAlias = 'Long'
				SELECT @TableAlias = AliasLong FROM Utility.TableAlias WHERE TableName = @Schema + '.' + @Table;
		END

		IF CHARINDEX('Type',@Params) > 0
			SET @Types = 1
		IF CHARINDEX('Alias',@Params) > 0
			SET @Alias = 1
		IF CHARINDEX('Title',@Params) > 0
			SET @TitleCase = 1

		IF OBJECT_ID('tempdb..#TableColums') IS NOT NULL DROP Table #TableColums;
		CREATE Table #TableColums WITH (HEAP, DISTRIBUTION = Replicate) AS 
		SELECT      s.name AS SchemaName, t.name AS TableName, c.name AS ColumnName, C.column_id, TYPE_NAME(c.system_type_id) AS ColumnType, c.max_length, c.PRECISION,c.scale,C.is_nullable, 
					ROW_NUMBER() OVER(ORDER BY C.column_id) AS RN
		FROM        sys.columns c
		JOIN        sys.Tables  t   ON c.object_id = t.object_id AND t.Name = @Table
		JOIN		sys.schemas s ON t.schema_id = s.schema_id AND s.Name = @Schema

		SELECT @NunOfColumns = MAX(RN) FROM #TableColums

		DECLARE @Indicat SMALLINT = 1
		DECLARE @Delimiter VARCHAR(3) = '  '
		DECLARE @SELECT_String VARCHAR(MAX) = ''
		DECLARE @ColumnName VARCHAR(100) = ''

		IF @TitleCase = 1
			SET @TableAlias = Utility.uf_TitleCase(@TableAlias) 

		WHILE (@Indicat <= @NunOfColumns)
		BEGIN

			WITH CTE_ColumnInfo AS
			(
				SELECT 
					--'[' + M.TableName + '].' AS TableName,
					M.ColumnName AS ColumnName,
					CASE WHEN m.is_nullable = 1 THEN '' ELSE 'ISNULL(' END + 'CAST(' AS IsNullBegin,
					')' + CASE 
							WHEN m.is_nullable = 1 THEN '' 
							ELSE ', ' +	
								CASE
									WHEN M.ColumnType LIKE '%DATE%' THEN '''1900-01-01'''
									WHEN M.ColumnType IN ('BINARY','VARBINARY') THEN '''CONVERT(VARBINARY(' + ISNULL(NULLIF(CAST(m.max_length AS VARCHAR),'-1'),'MAX') +'), 0)'''
									WHEN M.ColumnType LIKE '%CHAR' THEN ''''''
									ELSE '0'
								END + ')'
							END AS IsNullEnd,
					' AS ' + UPPER(M.ColumnType) +
					CASE 
						WHEN M.ColumnType = 'DATETIME2' THEN '(' + CAST(m.scale AS VARCHAR) +')'
						WHEN M.ColumnType IN ('BINARY','VARBINARY') THEN '(' + ISNULL(NULLIF(CAST(m.max_length AS VARCHAR),'-1'),'MAX') +')'
						WHEN M.ColumnType IN ('DECIMAL','NUMERIC') THEN '(' + CAST(m.PRECISION AS VARCHAR) + ',' + CAST(m.scale AS VARCHAR) +')'
						WHEN M.ColumnType LIKE '%CHAR' AND LEFT(M.ColumnType,1) = 'N' THEN '(' + ISNULL(CAST(NULLIF(m.max_length, -1) / 2 AS VARCHAR),'MAX') +')'
						WHEN M.ColumnType LIKE '%CHAR' AND LEFT(M.ColumnType,1) != 'N' THEN '(' + ISNULL(NULLIF(CAST(m.max_length AS VARCHAR),'-1'),'MAX') +')'
						ELSE ''
					END  AS ColumnType
				FROM #TableColums M
				WHERE M.RN = @Indicat
			)
			SELECT
				@ColumnName = ColumnName,
				@SELECT_String =
				CASE WHEN @Types = 1 THEN IsNullBegin ELSE '' END + 
				CASE WHEN @Alias = 1 THEN '[' + @TableAlias + '].' ELSE '' END + '[' + ColumnName + ']' + 
				CASE WHEN @Types = 1 THEN ColumnType + IsNullEnd ELSE '' END 
			FROM CTE_ColumnInfo

			IF @TitleCase = 1
				SET @ColumnName = Utility.uf_TitleCase(@ColumnName) 

			IF @TitleCase + @Types > 0
				SET @SELECT_String = @SELECT_String + ' AS [' + @ColumnName + ']'

			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + CHAR(9) + @Delimiter + @SELECT_String
			--SET @Params_In_SQL_Out = @Params_In_SQL_Out + @Delimiter + CHAR(13) + CHAR(10) + CHAR(9) + @SELECT_String

			SET	@Delimiter = ', ' 
			SET @Indicat += 1
		END

		IF CHARINDEX('No[]',@Params) > 0
			SET @Params_In_SQL_Out = REPLACE(REPLACE(@Params_In_SQL_Out,'[',''),']','')

		IF CHARINDEX('NoPrint',@Params) = 0
			EXEC Utility.LongPrint @Params_In_SQL_Out
	END
END




