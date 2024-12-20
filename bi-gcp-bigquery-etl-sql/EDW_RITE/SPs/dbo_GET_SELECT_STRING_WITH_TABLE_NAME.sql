CREATE PROC [DBO].[GET_SELECT_STRING_WITH_TABLE_NAME] @TABLE_NAME [VARCHAR](100),@SQL_STRING [VARCHAR](MAX) OUT AS

/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.GET_SELECT_STRING_WITH_TABLE_NAME') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.GET_SELECT_STRING_WITH_TABLE_NAME
GO

-- !!!! EXAMPLE !!!! --

DECLARE @SQL_STRING [VARCHAR](MAX),@TABLE_NAME [VARCHAR](100)  = 'DIM_VIOLATOR_ASOF'

EXEC EDW_RITE.DBO.GET_SELECT_STRING_WITH_TABLE_NAME @TABLE_NAME, @SQL_STRING OUTPUT 
PRINT @SQL_STRING

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

	--IF OBJECT_ID('dbo.TABLE_COLUMNS') IS NOT NULL DROP TABLE dbo.TABLE_COLUMNS;
	IF OBJECT_ID('tempdb..#TABLE_COLUMNS') IS NOT NULL DROP TABLE #TABLE_COLUMNS;
	--CREATE TABLE dbo.TABLE_COLUMNS WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(ColumnName)) AS 
	SELECT      c.name AS ColumnName, 
				ROW_NUMBER() OVER(ORDER BY C.column_id) AS RN
				INTO #TABLE_COLUMNS
	FROM        sys.columns c
	JOIN        sys.tables  t   ON c.object_id = t.object_id
	WHERE       t.name = @TABLE_NAME

	--PRINT 'GOT NEW_TABLE_COLUMNS'
	DECLARE @NUM_OF_COLUMNS INT
	SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #TABLE_COLUMNS
	DECLARE @INDICAT SMALLINT = 1
	DECLARE @Delimiter VARCHAR(3) = ''
	DECLARE @SELECT_String VARCHAR(MAX) = ''
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty

	WHILE (@INDICAT <= @NUM_OF_COLUMNS)
	BEGIN
		SELECT @SELECT_String = '[' + @TABLE_NAME + '].[' + M.ColumnName + ']'
		FROM #TABLE_COLUMNS M
		WHERE M.RN = @INDICAT
		
		SET @SQL_STRING = @SQL_STRING + @Delimiter + @SELECT_String

		SET	@Delimiter = ','+ CHAR(13) + CHAR(10)
		SET @INDICAT += 1
	END

END


















