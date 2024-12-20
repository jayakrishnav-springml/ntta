CREATE PROC [DBO].[GET_SELECT_CAST_STRING] @TABLE_NAME [VARCHAR](100),@SQL_STRING [VARCHAR](MAX) OUT AS

/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.GET_SELECT_CAST_STRING') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.GET_SELECT_CAST_STRING
GO

-- !!!! EXAMPLE !!!! --

DECLARE @SQL_STRING [VARCHAR](MAX),@TABLE_NAME [VARCHAR](100)  = 'FACT_UNIFIED_VIOLATION_HISTORY'

EXEC EDW_RITE.DBO.GET_SELECT_CAST_STRING @TABLE_NAME, @SQL_STRING OUTPUT 
EXEC dbo.PRINT_LONG_VARIABLE_VALUE @SQL_STRING

-- !!!! EXAMPLE !!!! --

*/

SET NOCOUNT ON


DECLARE @ERROR VARCHAR(MAX) = ''


IF @TABLE_NAME IS NULL SET @ERROR = @ERROR + 'Table name could not be NULL'

IF LEN(@ERROR) > 0
BEGIN
	PRINT @ERROR
	SET @SQL_STRING = '';
END
ELSE
BEGIN

	DECLARE @NUM_OF_COLUMNS INT
	DECLARE @SELECT_String VARCHAR(MAX) = ''
	DECLARE @THIS_SELECT_String VARCHAR(MAX) = ''
	DECLARE @Delimiter VARCHAR(3) = ' '
	DECLARE @INDICAT SMALLINT = 1


	IF OBJECT_ID('tempdb..#TABLE_COLUMNS') IS NOT NULL DROP TABLE #TABLE_COLUMNS;
	CREATE TABLE #TABLE_COLUMNS WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(ColumnName)) AS 
	SELECT      s.name AS SchemaName, t.name AS TableName, c.name AS ColumnName, C.column_id, TYPE_NAME(c.system_type_id) AS ColumnType, c.max_length, c.PRECISION,c.scale,C.is_nullable, 
				ROW_NUMBER() OVER(ORDER BY C.column_id) AS RN
	FROM        sys.columns c
	JOIN        sys.tables  t   ON c.object_id = t.object_id
	JOIN		sys.schemas S	ON S.schema_id = t.schema_id
	WHERE       t.name = @TABLE_NAME

	--PRINT 'GOT NEW_TABLE_COLUMNS'

	SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #TABLE_COLUMNS

	WHILE (@INDICAT <= @NUM_OF_COLUMNS)
	BEGIN
		
		SELECT 
			@THIS_SELECT_String = CASE WHEN m.is_nullable = 1 THEN '' ELSE 'ISNULL(' END + 'CAST([' + M.ColumnName + '] AS ' + M.ColumnType +
			--M.TableName + '.[' + M.ColumnName + '] AS ' + M.ColumnType +
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
											WHEN M.ColumnType IN ('BINARY','VARBINARY') THEN ''''''
											WHEN M.ColumnType LIKE '%CHAR' THEN ''''''
											ELSE '0'
										END + ')'
						END + ' AS [' + m.ColumnName + ']'
		FROM #TABLE_COLUMNS M
		WHERE M.RN = @INDICAT
		
		SET @SELECT_String = @SELECT_String + CHAR(13) + CHAR(10) + @Delimiter + @THIS_SELECT_String

		SET	@Delimiter = ','
		SET @INDICAT += 1

	END

	SET @SQL_STRING = @SELECT_String

	IF OBJECT_ID('tempdb..#TABLE_COLUMNS') IS NOT NULL DROP TABLE #TABLE_COLUMNS;

END

SET NOCOUNT OFF

















