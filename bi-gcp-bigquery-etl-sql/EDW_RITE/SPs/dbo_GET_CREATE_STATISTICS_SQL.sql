CREATE PROC [DBO].[GET_CREATE_STATISTICS_SQL] @TABLE [VARCHAR](100),@NEW_TABLE [VARCHAR](100),@SQL_STRING [VARCHAR](MAX) OUT AS

/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.GET_CREATE_STATISTICS_SQL') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.GET_CREATE_STATISTICS_SQL
GO

EXEC DBO.GET_CREATE_STATISTICS_SQL 'FACT_UNIFIED_VIOLATION_SNAPSHOT', 'FACT_UNIFIED_VIOLATION_SNAPSHOT_STAGE', @SQL_STRING  OUTPUT 
EXEC DBO.GET_CREATE_STATISTICS_SQL 'FACT_UNIFIED_VIOLATION_SNAPSHOT', NULL, @SQL_STRING  OUTPUT


*/
SET NOCOUNT ON

IF OBJECT_ID('TempDB..#TABLE_STATS') IS NOT NULL DROP TABLE #TABLE_STATS;
WITH CTE AS
(
	SELECT
		s.[name] AS schemaName
		,t.[name] AS [table_name]
		,ss.[name] AS [stats_name]
		,c.name AS [column_name]
		, ROW_NUMBER() OVER (PARTITION BY ss.[name] ORDER BY C.column_id) AS RN 
	FROM        sys.schemas s
	JOIN        sys.tables t                    ON      t.[schema_id]  = s.[schema_id]
	JOIN		sys.stats ss					ON		ss.[object_id] = t.[object_id] AND ss.user_created = 1
	JOIN		sys.stats_columns sc			ON		sc.[object_id] = t.[object_id] AND ss.stats_id = sc.stats_id
	JOIN        sys.columns c                   ON      t.[object_id]  = c.[object_id] AND sc.column_id  = c.column_id
	WHERE  t.[name] = @TABLE
)
, CTE_JOINT AS 
(
	SELECT 
		CTE1.schemaName
		,CTE1.table_name
		,CTE1.stats_name
		, '[' + CTE1.column_name + ']'
		+ ISNULL(', ['+ CTE2.column_name + ']', '')
		+ ISNULL(', ['+ CTE3.column_name + ']', '')
		+ ISNULL(', ['+ CTE4.column_name + ']', '')
		+ ISNULL(', ['+ CTE5.column_name + ']', '')
		+ ISNULL(', ['+ CTE6.column_name + ']', '')
		+ ISNULL(', ['+ CTE7.column_name + ']', '')
		+ ISNULL(', ['+ CTE8.column_name + ']', '')
		+ ISNULL(', ['+ CTE9.column_name + ']', '')
		+ ISNULL(', ['+ CTE10.column_name + ']', '') AS stats_COULUMNS
	FROM CTE AS CTE1
	LEFT JOIN CTE AS CTE2 ON CTE2.stats_name = CTE1.stats_name AND CTE2.RN = 2
	LEFT JOIN CTE AS CTE3 ON CTE3.stats_name = CTE1.stats_name AND CTE3.RN = 3
	LEFT JOIN CTE AS CTE4 ON CTE4.stats_name = CTE1.stats_name AND CTE4.RN = 4
	LEFT JOIN CTE AS CTE5 ON CTE5.stats_name = CTE1.stats_name AND CTE5.RN = 5
	LEFT JOIN CTE AS CTE6 ON CTE6.stats_name = CTE1.stats_name AND CTE6.RN = 6
	LEFT JOIN CTE AS CTE7 ON CTE7.stats_name = CTE1.stats_name AND CTE7.RN = 7
	LEFT JOIN CTE AS CTE8 ON CTE8.stats_name = CTE1.stats_name AND CTE8.RN = 8
	LEFT JOIN CTE AS CTE9 ON CTE9.stats_name = CTE1.stats_name AND CTE9.RN = 9
	LEFT JOIN CTE AS CTE10 ON CTE10.stats_name = CTE1.stats_name AND CTE10.RN = 10
	WHERE CTE1.RN = 1
)
	SELECT 
		schemaName
		,table_name
		,stats_name
		,stats_COULUMNS
		,'CREATE STATISTICS [' + stats_name + '] ON dbo.[' + CASE WHEN @NEW_TABLE IS NULL THEN table_name ELSE @NEW_TABLE END + '] (' + stats_COULUMNS + ');' AS SQL_STRING
		, ROW_NUMBER() OVER(ORDER BY stats_name) AS RN
	INTO #TABLE_STATS
FROM CTE_JOINT


DECLARE @NUM_OF_COLUMNS INT
DECLARE @THIS_SQL_STRING VARCHAR(MAX) = ''
DECLARE @INDICAT SMALLINT = 1

SET @SQL_STRING  = ''


SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #TABLE_STATS
SET @INDICAT = 1
-- If only 1 period (and 1 partition) - @PART_RANGES is empty
WHILE (@INDICAT <= @NUM_OF_COLUMNS)
BEGIN
		
	SELECT @THIS_SQL_STRING = SQL_STRING FROM #TABLE_STATS WHERE RN = @INDICAT --ORDER BY stats_name

	SET @SQL_STRING = @SQL_STRING + '
	' + @THIS_SQL_STRING

	SET @INDICAT += 1

END

SET NOCOUNT OFF

