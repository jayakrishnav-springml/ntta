CREATE PROC [DBO].[GET_PARTITION_STRING] @TABLE [VARCHAR](100),@SQL_STRING [VARCHAR](MAX) OUT AS
/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.GET_PARTITION_STRING') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.GET_PARTITION_STRING
GO

DECLARE @SQL_STRING [VARCHAR](MAX)
EXEC EDW_RITE.DBO.GET_PARTITION_STRING 'FACT_UNIFIED_VIOLATION_SNAPSHOT', @SQL_STRING OUTPUT 
PRINT @SQL_STRING

DECLARE @SQL_STRING [VARCHAR](MAX)
EXEC EDW_RITE.DBO.GET_PARTITION_STRING 'FACT_INVOICE_ANALYSIS_DETAIL', @SQL_STRING OUTPUT 
PRINT @SQL_STRING

*/

DECLARE @ColumnName NVARCHAR(100) --COLLATE Latin1_General_100_CI_AS_KS_WS
DECLARE @ColumnType NVARCHAR(100) --COLLATE Latin1_General_100_CI_AS_KS_WS
DECLARE @Delimiter NVARCHAR(1) = ''

SET @SQL_STRING = ''

SELECT  
    @ColumnName =  '[' + CAST(c.name AS NVARCHAR) COLLATE DATABASE_DEFAULT + '] RANGE ' + CASE WHEN pf.boundary_value_on_right = 1 THEN 'RIGHT' ELSE 'LEFT' END
	, @ColumnType = TYPE_NAME(c.system_type_id)
FROM sys.tables AS t  
JOIN sys.indexes AS i ON t.[object_id] = i.[object_id] AND I.index_id <=1
JOIN sys.partition_schemes	AS ps ON ps.data_space_id	= i.data_space_id  
JOIN sys.index_columns		AS ic ON ic.[object_id]		= i.[object_id] AND ic.index_id = i.index_id AND ic.partition_ordinal >= 1 -- because 0 = non-partitioning column  
JOIN sys.columns			AS c  ON t.[object_id]		= c.[object_id] AND ic.column_id = c.column_id
JOIN sys.partition_functions   pf ON pf.[function_id]   = ps.[function_id]
WHERE  t.[name] = @TABLE --'FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_HIST'

IF @ColumnName IS NOT NULL
BEGIN
	IF OBJECT_ID('TempDB..#TABLE_valueS') IS NOT NULL DROP TABLE #TABLE_valueS;
	SELECT  
		CASE
			WHEN @ColumnType = 'TIME' THEN CHAR(39) + CONVERT(NVARCHAR, rv.value, 114) + CHAR(39)
			WHEN @ColumnType = 'DATE' THEN CHAR(39) + CONVERT(NVARCHAR, rv.value, 112) + CHAR(39)
			WHEN @ColumnType LIKE '%DATE%' THEN CHAR(39) + CONVERT(NVARCHAR, rv.value, 121) + CHAR(39)
			WHEN @ColumnType LIKE '%CHAR' THEN NCHAR(39) + CAST(rv.value AS NVARCHAR) + NCHAR(39)  --CONVERT(NVARCHAR, rv.value) + CHAR(39) COLLATE Latin1_General_CI_AS_KS_WS 
			ELSE CONVERT(NVARCHAR, rv.value)
		END AS RangeValue
		, ROW_NUMBER() OVER (ORDER BY rv.value) AS RN 
	INTO #TABLE_valueS
	FROM   sys.tables t
	JOIN   sys.partitions p              ON p.[object_id]      = t.[object_id] AND p.[index_id] <=1
	JOIN   sys.indexes i                 ON i.[object_id]      = p.[object_id] AND i.[index_id] = p.[index_id]
	JOIN   sys.data_spaces ds            ON ds.[data_space_id] = i.[data_space_id]
	JOIN   sys.partition_schemes ps      ON ps.[data_space_id] = ds.[data_space_id]
	JOIN   sys.partition_functions pf    ON pf.[function_id]   = ps.[function_id]
	JOIN   sys.partition_range_values rv ON rv.[function_id]   = pf.[function_id] AND rv.[boundary_id] = p.[partition_number]
	WHERE t.[name] = @TABLE AND rv.value IS NOT NULL -- 'FACT_INVOICE_ANALYSIS_DETAIL' --'FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_HIST'


	DECLARE @NUM_OF_COLUMNS INT
	DECLARE @THIS_RangeValue NVARCHAR(MAX) = ''
	DECLARE @INDICAT SMALLINT = 1
	DECLARE @RangeValue NVARCHAR(MAX) = ''

	SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #TABLE_valueS
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty
	WHILE (@INDICAT <= @NUM_OF_COLUMNS)
	BEGIN
		SELECT @THIS_RangeValue = RangeValue FROM #TABLE_valueS WHERE RN = @INDICAT --ORDER BY stats_name
		SET @RangeValue = @RangeValue + @Delimiter + @THIS_RangeValue
		SET @INDICAT += 1
		SET @Delimiter = ', '
	END

	SET @SQL_STRING  = ', PARTITION (' + @ColumnName + ' FOR VALUES (' + @RangeValue + '))' 

END



