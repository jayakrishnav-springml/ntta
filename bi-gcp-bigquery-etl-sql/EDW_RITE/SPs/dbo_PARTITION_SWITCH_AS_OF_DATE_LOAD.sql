CREATE PROC [DBO].[PARTITION_SWITCH_AS_OF_DATE_LOAD] @DEST_TABLE_NAME [varchar](255),@SRC_TABLE_NAME [varchar](255),@AS_OF_DATE [date] AS 

/*
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.PARTITION_SWITCH_AS_OF_DATE_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.PARTITION_SWITCH_AS_OF_DATE_LOAD
GO

EXEC dbo.PARTITION_SWITCH_AS_OF_DATE_LOAD @DEST_TABLE_NAME,@SRC_TABLE_NAME,@AS_OF_DATE


*/

--#1	Andy Filipps	2019-02-08	CREATED

DECLARE @PARTITION_BEGIN DATE = DATEADD(DAY,1,EOMONTH(GETDATE(),-1))
DECLARE @PARTITION_END DATE = EOMONTH(GETDATE())
--DECLARE @NEW_PARTITION_DATE DATE = (SELECT CONVERT(VARCHAR(6), DATEADD(MONTH,3,GETDATE()), 112) + '01')

IF ISNULL(@AS_OF_DATE, '19000101') > '20100101' 
BEGIN
	SET @PARTITION_BEGIN = DATEADD(DAY,1,EOMONTH(@AS_OF_DATE,-1)) -- Begining of the month
	SET @PARTITION_END = EOMONTH(@AS_OF_DATE) -- End of the month
END

--DECLARE @START_DATE DATETIME2 (2), @LOG_MESSAGE VARCHAR(1000), @ROW_COUNT BIGINT
DECLARE @sql VARCHAR(MAX)
DECLARE @PART_NUMBER INT

IF OBJECT_ID('tempdb..#PART_VALUES') IS NOT NULL DROP TABLE #PART_VALUES;
SELECT CAST(p.partition_number AS INT) + CAST(pf.boundary_value_on_right AS INT) AS PART_NUMBER
		, CONVERT(DATE, CONVERT(VARCHAR,rv.[value],112)) AS PART_VALUE
INTO #PART_VALUES
FROM        sys.tables t                    
JOIN        sys.partitions p              ON p.[object_id]      = t.[object_id] AND p.[index_id] <= 1
JOIN        sys.indexes i                 ON i.[object_id]      = p.[object_id] AND i.[index_id] = p.[index_id]
JOIN        sys.data_spaces ds            ON ds.[data_space_id] = i.[data_space_id]
LEFT JOIN   sys.partition_schemes ps      ON ps.[data_space_id] = ds.[data_space_id]
LEFT JOIN   sys.partition_functions pf    ON pf.[function_id]   = ps.[function_id]
LEFT JOIN   sys.partition_range_values rv ON rv.[function_id]   = pf.[function_id] AND rv.[boundary_id] = p.[partition_number]
WHERE t.[name] = @DEST_TABLE_NAME --'DIM_VIOLATOR_ASOF'

SELECT
	@PART_NUMBER = PART_NUMBER
FROM #PART_VALUES
	WHERE PART_VALUE BETWEEN @PARTITION_BEGIN AND @PARTITION_END 

IF OBJECT_ID('tempdb..#PART_VALUES') IS NOT NULL DROP TABLE #PART_VALUES;

SET @sql = '
IF OBJECT_ID(''dbo.[' + @SRC_TABLE_NAME + '_NEW_SET]'') IS NOT NULL 	DROP TABLE dbo.[' + @SRC_TABLE_NAME + '_NEW_SET];';	
EXECUTE (@sql);

-- First get all the date from Source table to the '_NEW_SET' table with the same structure and same Partitions as Destination table
EXEC DBO.GET_CREATE_TABLE_AS_SQL @DEST_TABLE_NAME, @sql OUTPUT 

SET @sql = REPLACE(@sql,@DEST_TABLE_NAME,@SRC_TABLE_NAME) -- Changing the names of the tables
EXECUTE (@sql);

SET @sql = '
IF OBJECT_ID(''dbo.[' + @DEST_TABLE_NAME + '_TRUNCATE]'') IS NOT NULL 	DROP TABLE dbo.[' + @DEST_TABLE_NAME + '_TRUNCATE];';	
EXECUTE (@sql);

-- Creating empty Truncate table
EXEC DBO.GET_CREATE_TRUNCATE_TABLE_SQL @DEST_TABLE_NAME, @sql OUTPUT 
EXECUTE (@sql);

-- Empty the partition before SWITCHing it
SET @sql = '
ALTER TABLE dbo.[' + @DEST_TABLE_NAME + '] SWITCH PARTITION ' + CAST(@PART_NUMBER AS VARCHAR(3))+' TO dbo.[' + @DEST_TABLE_NAME + '_TRUNCATE] PARTITION ' + CAST(@PART_NUMBER AS VARCHAR(3))+';
ALTER TABLE dbo.[' + @SRC_TABLE_NAME + '_NEW_SET] SWITCH PARTITION ' + CAST(@PART_NUMBER AS VARCHAR(3))+' TO dbo.[' + @DEST_TABLE_NAME + '] PARTITION ' + CAST(@PART_NUMBER AS VARCHAR(3))+';
'
EXECUTE (@sql);


SET @sql = '
IF OBJECT_ID(''dbo.[' + @DEST_TABLE_NAME + '_TRUNCATE]'') IS NOT NULL 	DROP TABLE dbo.[' + @DEST_TABLE_NAME + '_TRUNCATE];';	
EXECUTE (@sql);
SET @sql = '
IF OBJECT_ID(''dbo.[' + @SRC_TABLE_NAME + '_NEW_SET]'') IS NOT NULL 	DROP TABLE dbo.[' + @SRC_TABLE_NAME + '_NEW_SET];';	
EXECUTE (@sql);


