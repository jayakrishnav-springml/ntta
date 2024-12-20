CREATE PROC [dbo].[GET_SELECT_STRING_WITH_TYPES] @TABLE_NAME [VARCHAR](200),@SQL_STRING [VARCHAR](MAX) OUT AS

/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('dbo.GET_SELECT_STRING_WITH_TYPES') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE dbo.GET_SELECT_STRING_WITH_TYPES
GO

-- !!!! EXAMPLE !!!! --

DECLARE @SQL_STRING [VARCHAR](MAX),@TABLE_NAME [VARCHAR](200)  = 'STG.TP_TRIPS'

EXEC dbo.GET_SELECT_STRING_WITH_TYPES @TABLE_NAME, @SQL_STRING OUTPUT 

-- !!!! EXAMPLE !!!! --

*/

DECLARE @ERROR VARCHAR(MAX) = ''

IF @TABLE_NAME IS NULL SET @ERROR = @ERROR + 'Table name could not be NULL'

SET @SQL_STRING = '';

IF LEN(@ERROR) > 0
BEGIN
	PRINT @ERROR
END
ELSE
BEGIN

	DECLARE @SCHEMA [VARCHAR](100)
	DECLARE @TABLE [VARCHAR](200)
	DECLARE @NUM_OF_COLUMNS INT

	DECLARE @DOT INT = CHARINDEX('.',@TABLE_NAME)

	IF @DOT = 0
	BEGIN
		SET @SCHEMA = 'DBO'
		SET @TABLE = REPLACE(REPLACE(@TABLE_NAME,'[',''),']','')
	END
	ELSE
	BEGIN
		SET @SCHEMA = REPLACE(REPLACE(LEFT(@TABLE_NAME,@DOT - 1),'[',''),']','')
		SET @TABLE = REPLACE(REPLACE(SUBSTRING(@TABLE_NAME,@DOT + 1,200),'[',''),']','')
	END

	IF OBJECT_ID('tempdb..#TABLE_COLUMNS') IS NOT NULL DROP TABLE #TABLE_COLUMNS;
	CREATE TABLE #TABLE_COLUMNS WITH (HEAP, DISTRIBUTION = Replicate) AS 
	SELECT      s.name AS SchemaName, t.name AS TableName, c.name AS ColumnName, C.column_id, TYPE_NAME(c.system_type_id) AS ColumnType, c.max_length, c.PRECISION,c.scale,C.is_nullable, 
				ROW_NUMBER() OVER(ORDER BY C.column_id) AS RN
	FROM        sys.columns c
	JOIN        sys.tables  t   ON c.object_id = t.object_id AND t.name = @TABLE
	JOIN		sys.schemas S	ON S.schema_id = t.schema_id AND s.name = @SCHEMA

	SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #TABLE_COLUMNS

	DECLARE @SELECT_String VARCHAR(1000) = ''
	DECLARE @Delimiter VARCHAR(3) = ''
	DECLARE @INDICAT SMALLINT = 1
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty

	WHILE (@INDICAT <= @NUM_OF_COLUMNS)
	BEGIN
		
		SELECT 
			@SELECT_String = CASE WHEN m.is_nullable = 1 THEN '' ELSE 'ISNULL(' END + 'CAST([' + M.ColumnName + '] AS ' + M.ColumnType +
				--'[' + M.TableName + ']' + '.[' + M.ColumnName + '] AS ' + M.ColumnType +
			CASE 
				WHEN M.ColumnType = 'DATETIME2' THEN '(' + CAST(m.scale AS VARCHAR) +')'
				WHEN M.ColumnType IN ('BINARY','VARBINARY') THEN '(' + ISNULL(NULLIF(CAST(m.max_length AS VARCHAR),'-1'),'MAX') +')'
				WHEN M.ColumnType IN ('DECIMAL','NUMERIC') THEN '(' + CAST(m.PRECISION AS VARCHAR) + ',' + CAST(m.scale AS VARCHAR) +')'
				WHEN M.ColumnType LIKE '%CHAR' AND LEFT(M.ColumnType,1) = 'N' THEN '(' + ISNULL(NULLIF(CAST(m.max_length / 2 AS VARCHAR),'-1'),'MAX') +')'
				WHEN M.ColumnType LIKE '%CHAR' AND LEFT(M.ColumnType,1) != 'N' THEN '(' + ISNULL(NULLIF(CAST(m.max_length AS VARCHAR),'-1'),'MAX') +')'
				ELSE ''
			END + ')' + CASE 
							WHEN m.is_nullable = 1 THEN '' 
							ELSE ', ' +	
										CASE
											WHEN M.ColumnType LIKE '%DATE%' THEN '''1900-01-01'''
											WHEN M.ColumnType IN ('BINARY','VARBINARY') THEN '''CONVERT(VARBINARY(' + ISNULL(NULLIF(CAST(m.max_length AS VARCHAR),'-1'),'MAX') +'), 0)'''
											WHEN M.ColumnType LIKE '%CHAR' THEN ''''''
											ELSE '0'
										END + ')'
						END + ' AS [' + m.ColumnName + ']'
		FROM #TABLE_COLUMNS M
		WHERE M.RN = @INDICAT
		
		SET @SQL_STRING = @SQL_STRING + CHAR(13) + CHAR(10) + CHAR(9) + @Delimiter + @SELECT_String

		SET	@Delimiter = ', '
		SET @INDICAT += 1

	END

	--EXEC dbo.PRINT_LONG_VARIABLE_VALUE @SQL_STRING

END


















