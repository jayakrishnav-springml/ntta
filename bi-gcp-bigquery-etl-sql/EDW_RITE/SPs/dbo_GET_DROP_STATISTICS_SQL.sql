CREATE PROC [DBO].[GET_DROP_STATISTICS_SQL] @TABLE [VARCHAR](100),@SQL_STRING [VARCHAR](MAX) OUT AS
/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.GET_DROP_STATISTICS_SQL') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.GET_DROP_STATISTICS_SQL
GO

DECLARE @SQL_STRING [VARCHAR](MAX),@TABLE_NAME [VARCHAR](100)  = 'DIM_VEHICLE'

EXEC EDW_RITE.DBO.GET_DROP_STATISTICS_SQL @TABLE_NAME, @SQL_STRING   OUTPUT
print @SQL_STRING

*/

IF OBJECT_ID('TempDB..#TABLE_STATS') IS NOT NULL DROP TABLE #TABLE_STATS;
--CREATE TABLE dbo.TABLE_STATS WITH (HEAP, DISTRIBUTION = ROUND_ROBIN) AS 
WITH CTE AS
(
	SELECT DISTINCT
		s.[name] AS schemaName
		,t.[name] AS [table_name]
		,ss.[name] AS [stats_name]
	FROM        sys.schemas s
	JOIN        sys.tables t                    ON      t.[schema_id]  = s.[schema_id]
	JOIN		sys.stats ss					ON		ss.[object_id] = t.[object_id] AND ss.user_created = 1
	JOIN		sys.stats_columns sc			ON		sc.[object_id] = t.[object_id] AND ss.stats_id = sc.stats_id
	JOIN        sys.columns c                   ON      t.[object_id]  = c.[object_id] AND sc.column_id  = c.column_id
	WHERE  t.[name] = @TABLE 
)
	SELECT 
		schemaName
		,table_name
		,stats_name
		,'DROP STATISTICS ' + schemaName + '.[' + table_name + '].[' + stats_name + '];' AS SQL_STRING
		, ROW_NUMBER() OVER(ORDER BY stats_name) AS RN
	INTO #TABLE_STATS
FROM CTE

DECLARE @NUM_OF_COLUMNS INT
DECLARE @THIS_SQL_STRING VARCHAR(MAX) = ''
DECLARE @INDICAT SMALLINT = 1

SET @SQL_STRING  = ''

SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #TABLE_STATS
-- If only 1 period (and 1 partition) - @PART_RANGES is empty
WHILE (@INDICAT <= @NUM_OF_COLUMNS)
BEGIN
	SELECT @THIS_SQL_STRING = SQL_STRING FROM #TABLE_STATS WHERE RN = @INDICAT --ORDER BY stats_name
	SET @SQL_STRING = @SQL_STRING + '
	' + @THIS_SQL_STRING
	SET @INDICAT += 1
END

--EXECUTE (@SQL_STRING)


