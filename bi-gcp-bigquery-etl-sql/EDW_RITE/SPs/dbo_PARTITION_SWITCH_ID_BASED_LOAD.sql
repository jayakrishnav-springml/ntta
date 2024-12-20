CREATE PROC [DBO].[PARTITION_SWITCH_ID_BASED_LOAD] @TABLE_NAME [VARCHAR](100),@IDENTITY_COLUMNS [VARCHAR](8000),@Rows_in_One_Part [BIGINT] AS 

/*
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.PARTITION_SWITCH_ID_BASED_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.PARTITION_SWITCH_ID_BASED_LOAD
GO

DECLARE @IDENTITY_COLUMNS VARCHAR(8000) = '[TART_ID]'

EXEC DBO.PARTITION_SWITCH_ID_BASED_LOAD @TABLE_NAME, @IDENTITY_COLUMNS, 50000000


*/

--#1	Andy Filipps	2019-07-16	CREATED

/*
 -- !!!TESTING PARAMETERS!!!

DECLARE @IDENTITY_COLUMNS VARCHAR(8000) = '[TART_ID]'
DECLARE @TABLE_NAME VARCHAR(100) = 'FACT_NET_REV_TFC_EVTS'

DECLARE @IDENTITY_COLUMNS VARCHAR(8000) = '[LANE_VIOL_ID]'
DECLARE @TABLE_NAME VARCHAR(100) = 'FACT_LANE_VIOLATIONS_DETAIL'

*/

IF @Rows_in_One_Part IS NULL SET @Rows_in_One_Part = 50000000

DECLARE @START_DATE DATETIME2 (2), @LOG_MESSAGE VARCHAR(1000), @ROW_COUNT BIGINT
DECLARE @sql VARCHAR(MAX)

DECLARE @SQL_SELECT VARCHAR(MAX)
DECLARE @SQL_WHERE VARCHAR(MAX)


DECLARE @DISTRIBUTION VARCHAR(100)

DECLARE @TABLE_DISTRIBUTION VARCHAR(100) = ''
DECLARE @TABLE_INDEX VARCHAR(MAX) = ''
DECLARE @TABLE_PARTITION VARCHAR(MAX)
DECLARE @TABLE_PARTITION_COLUMN VARCHAR(100)

DECLARE @Cur_Part INT
DECLARE @Cur_Part_Text VARCHAR(3)

SET @START_DATE = GETDATE()


EXEC DBO.GET_DISRTIBUTION_STRING @TABLE_NAME, @TABLE_DISTRIBUTION OUTPUT 

EXEC DBO.GET_INDEX_STRING @TABLE_NAME, @TABLE_INDEX OUTPUT 

EXEC DBO.GET_PARTITION_STRING @TABLE_NAME, @TABLE_PARTITION OUTPUT 

SELECT @TABLE_PARTITION_COLUMN = CAST(c.name AS VARCHAR) 
FROM sys.tables AS t  
JOIN sys.indexes AS i ON t.[object_id] = i.[object_id] AND I.index_id <=1
JOIN sys.partition_schemes	AS ps ON ps.data_space_id	= i.data_space_id  
JOIN sys.index_columns		AS ic ON ic.[object_id]		= i.[object_id] AND ic.index_id = i.index_id AND ic.partition_ordinal >= 1 -- because 0 = non-partitioning column  
JOIN sys.columns			AS c  ON t.[object_id]		= c.[object_id] AND ic.column_id = c.column_id
WHERE  t.[name] = @TABLE_NAME --'FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_HIST'


SET @SQL_SELECT = ''
SET @SQL_WHERE = ''
BEGIN
	IF OBJECT_ID('tempdb..#TABLE_COLUMNS') IS NOT NULL DROP TABLE #TABLE_COLUMNS;
	SELECT      c.name AS ColumnName,
				ROW_NUMBER() OVER(ORDER BY C.column_id) AS RN
				INTO #TABLE_COLUMNS
	FROM        sys.columns c
	JOIN        sys.tables  t   ON c.object_id = t.object_id
	WHERE       t.name = @TABLE_NAME

	DECLARE @NUM_OF_COLUMNS INT
	SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #TABLE_COLUMNS
	DECLARE @INDICAT SMALLINT = 1
	DECLARE @Delimiter VARCHAR(6) = ''
	DECLARE @Delimiter_AND VARCHAR(8) = ''
	DECLARE @COLUMN_NAME VARCHAR(MAX) = ''

	WHILE (@INDICAT <= @NUM_OF_COLUMNS)
	BEGIN
		SELECT	  @COLUMN_NAME = '[' + M.ColumnName + ']'
		FROM #TABLE_COLUMNS M
		WHERE M.RN = @INDICAT
		
		IF CHARINDEX(@COLUMN_NAME, @IDENTITY_COLUMNS) > 0
		BEGIN
			SET @SQL_WHERE = @SQL_WHERE + @Delimiter_AND + @TABLE_NAME + '.' + @COLUMN_NAME + ' = NSET.' + @COLUMN_NAME
			SET	@Delimiter_AND = ' AND '
		END
		SET @SQL_SELECT = @SQL_SELECT + @Delimiter + @COLUMN_NAME

		SET	@Delimiter = ',' + CHAR(13) + CHAR(10) + CHAR(9)
		SET @INDICAT += 1
	END

END

--SELECT * FROM dbo.PARTITION_LOAD_ID_VALUES_CNT ORDER BY INDICAT

IF OBJECT_ID('dbo.PARTITION_LOAD_ID_VALUES_CNT') IS NULL 
	CREATE TABLE dbo.PARTITION_LOAD_ID_VALUES_CNT(TABLE_NAME varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,PARTITION_VALUES bigint NULL,PARTITION_NUM smallint NULL,CNT BIGINT NULL,INDICAT bigint NULL) WITH (HEAP,DISTRIBUTION = HASH(PARTITION_VALUES));

DELETE FROM dbo.PARTITION_LOAD_ID_VALUES_CNT WHERE TABLE_NAME = @TABLE_NAME 

-- Getting table with partitions, ranges and row_counts


IF OBJECT_ID('tempdb..#PARTITIONS_VALUES')  IS NOT NULL DROP TABLE #PARTITIONS_VALUES
CREATE TABLE #PARTITIONS_VALUES WITH (HEAP, DISTRIBUTION = HASH(PARTITION_VALUES))
AS
SELECT  CAST(p.partition_number AS INT) + CAST(pf.boundary_value_on_right AS INT) AS PARTITION_NUM, CAST(rv.value AS BIGINT)  AS PARTITION_VALUES
FROM      sys.schemas s
JOIN      sys.tables t                  ON t.[schema_id]      = s.[schema_id]
JOIN      sys.partitions p              ON p.[object_id]      = t.[object_id]
JOIN      sys.indexes i                 ON i.[object_id]      = p.[object_id] AND i.[index_id] = p.[index_id]
JOIN      sys.data_spaces ds            ON ds.[data_space_id] = i.[data_space_id]
LEFT JOIN sys.partition_schemes ps      ON ps.[data_space_id] = ds.[data_space_id]
LEFT JOIN sys.partition_functions pf    ON pf.[function_id]   = ps.[function_id]
LEFT JOIN sys.partition_range_values rv ON rv.[function_id]   = pf.[function_id] AND rv.[boundary_id] = p.[partition_number]
WHERE p.[index_id] <=1 AND t.[name] = @TABLE_NAME AND rv.[value] IS NOT NULL

	----EXPLAIN
SET @SQL = '
INSERT INTO dbo.PARTITION_LOAD_ID_VALUES_CNT
SELECT
	''' + @TABLE_NAME + ''' AS TABLE_NAME, FN.PARTITION_VALUES, IQ.PARTITION_NUM, FN.CNT,
	Row_Number() OVER (ORDER BY IQ.PARTITION_NUM) AS INDICAT
FROM 
(SELECT ' + @TABLE_PARTITION_COLUMN + ' AS PARTITION_VALUES, COUNT_BIG(1) AS CNT FROM dbo.' + @TABLE_NAME + '_NEW_SET	GROUP BY ' + @TABLE_PARTITION_COLUMN + ') FN
JOIN #PARTITIONS_VALUES AS IQ ON FN.PARTITION_VALUES = IQ.PARTITION_VALUES
OPTION (LABEL = ''' + @TABLE_NAME + ' LOAD: Get changed partitions query'');'

EXEC (@SQL)

--STEP #8: -- Calculate period ranges from dbo.PARTITION_LOAD_ID_VALUES_CNT to use index on DAY_ID in a query below. And create a query for each period and UNION ALL them all.
DECLARE @Temp_PER VARCHAR(MAX)
DECLARE @NUM_IND INT  = (SELECT MAX(INDICAT) FROM dbo.PARTITION_LOAD_ID_VALUES_CNT WHERE TABLE_NAME = @TABLE_NAME)
DECLARE @CUR_IND INT = 1
DECLARE @PART_ROLL INT
DECLARE @PART_CNT BIGINT
DECLARE @PARTITION_VALUES_ROLL INT
DECLARE @SQL_ALTER VARCHAR(MAX) = '' 
--DECLARE @IS_UNION_ROLL SMALLINT = -1

--DECLARE @Rows_in_One_Part BIGINT = 50000000
--SELECT @Rows_in_One_Part = ISNULL(Row_Count, 20000000) FROM dbo.Service_Monthly_Table_Count WHERE TABLE_NAME = @TABLE_NAME

DECLARE @Union_Parts VARCHAR = '';
--DECLARE @DelIns_Parts VARCHAR = '';
DECLARE @Union_Delimiter VARCHAR(1) = '';
--DECLARE @DelIns_Delimiter VARCHAR(1) = '';

-- This approach allow us merge the close periods to one subquery - should work faster for last several months then make query for each month 
WHILE (@CUR_IND <= @NUM_IND) BEGIN
	-- Initiate all roll variables
	SELECT @PART_ROLL = PD.PARTITION_NUM, @PARTITION_VALUES_ROLL = PD.PARTITION_VALUES, @PART_CNT = PD.CNT 
	FROM dbo.PARTITION_LOAD_ID_VALUES_CNT AS PD WHERE PD.INDICAT = @CUR_IND AND TABLE_NAME = @TABLE_NAME

	-- If it's more then 16 time less than full partition - better to do delete\insert instead of CREATE TABLE AS.
	--SET @IS_UNION_ROLL = CASE WHEN @PART_CNT < @Rows_in_One_Part / 16 THEN 0 ELSE 1 END 

	--IF @IS_UNION_ROLL = 1
	--BEGIN
		SET @SQL_ALTER = @SQL_ALTER + '
		ALTER TABLE dbo.' + @TABLE_NAME + ' SWITCH PARTITION ' + CAST(@PART_ROLL AS VARCHAR(10)) + ' TO dbo.' + @TABLE_NAME + '_TRUNCATE PARTITION ' + CAST(@PART_ROLL AS VARCHAR(10)) + ';
		ALTER TABLE dbo.' + @TABLE_NAME + '_STAGE SWITCH PARTITION ' + CAST(@PART_ROLL AS VARCHAR(10)) + ' TO dbo.' + @TABLE_NAME + ' PARTITION ' + CAST(@PART_ROLL AS VARCHAR(10)) + ';'

		SET @Union_Parts = @Union_Parts + @Union_Delimiter + CAST(@PARTITION_VALUES_ROLL AS VARCHAR(10))
		SET @Union_Delimiter = ','
	--END
	--ELSE
	--BEGIN
	--	SET @DelIns_Parts = @DelIns_Parts + @DelIns_Delimiter + CAST(@PARTITION_VALUES_ROLL AS VARCHAR(10))
	--	SET @DelIns_Delimiter = ','
	--END

	SET @CUR_IND += 1 -- 
END;

--IF LEN(@Union_Parts) > 0
BEGIN
	SET @sql = '
	IF OBJECT_ID(''dbo.' + @TABLE_NAME + '_STAGE'') IS NOT NULL DROP TABLE dbo.' + @TABLE_NAME + '_STAGE;

	CREATE TABLE dbo.[' + @TABLE_NAME + '_STAGE] WITH (' + @TABLE_INDEX + ', ' + @TABLE_DISTRIBUTION + @TABLE_PARTITION + ') AS
	SELECT	' + @SQL_SELECT + '
	FROM dbo.' + @TABLE_NAME + ' AS ' + @TABLE_NAME + ' 
	WHERE NOT EXISTS (SELECT 1 FROM dbo.' + @TABLE_NAME + '_NEW_SET AS NSET WHERE ' + @SQL_WHERE + ') AND PARTITION_VALUES IN ( '+ @Union_Parts + ')
	UNION ALL 
	SELECT	' + @SQL_SELECT + '
	FROM dbo.' + @TABLE_NAME + '_NEW_SET AS NSET WHERE PARTITION_VALUES IN ( '+ @Union_Parts + ')
	OPTION (LABEL = ''' + @TABLE_NAME + ' LOAD: Get all changed rows by partitions query'');'

	--EXEC dbo.PRINT_LONG_VARIABLE_VALUE @sql
	EXECUTE (@sql); 

	EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
	SET  @LOG_MESSAGE = 'Stage table created with all cganges of all periods'
	EXEC dbo.LOG_PROCESS @TABLE_NAME, @START_DATE, @LOG_MESSAGE, @ROW_COUNT

	--STEP #10: Switch all changed partitions from Stage to Fact.
	SET @sql =' 	
	IF OBJECT_ID(''dbo.' + @TABLE_NAME + '_TRUNCATE'') IS NOT NULL DROP TABLE dbo.' + @TABLE_NAME + '_TRUNCATE;

	CREATE TABLE dbo.[' + @TABLE_NAME + '_TRUNCATE] WITH (' + @TABLE_INDEX + ', ' + @TABLE_DISTRIBUTION + @TABLE_PARTITION + ') AS
	SELECT * FROM    dbo.' + @TABLE_NAME + '  	WHERE   1=2'
	EXECUTE (@sql);

	EXECUTE (@SQL_ALTER);

	SET @sql = '
	IF OBJECT_ID(''dbo.' + @TABLE_NAME + '_TRUNCATE'') IS NOT NULL DROP TABLE dbo.' + @TABLE_NAME + '_TRUNCATE;
	IF OBJECT_ID(''dbo.' + @TABLE_NAME + '_STAGE'') IS NOT NULL DROP TABLE dbo.' + @TABLE_NAME + '_STAGE'
	EXECUTE (@sql);
END

--IF LEN(@DelIns_Parts) > 0
--BEGIN

--	SET @sql = '
--	DELETE FROM dbo.' + @TABLE_NAME + '
--	WHERE EXISTS (SELECT 1 FROM dbo.' + @TABLE_NAME + '_NEW_SET AS NSET WHERE ' + @SQL_WHERE + ') AND PARTITION_VALUES IN ( '+ @DelIns_Parts + ') 
--	OPTION (LABEL = ''' + @TABLE_NAME + ' LOAD: Delete'');
	
--	INSERT INTO dbo.' + @TABLE_NAME + '
--	SELECT ' + @SQL_SELECT + '
--	FROM dbo.' + @TABLE_NAME + '_NEW_SET AS NSET WHERE PARTITION_VALUES IN ( '+ @DelIns_Parts + ') 
--	OPTION (LABEL = ''' + @TABLE_NAME + ' LOAD: Insert'');'

--	--EXEC dbo.PRINT_LONG_VARIABLE_VALUE @sql
--	EXECUTE (@sql);

--	EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
--	SET  @LOG_MESSAGE = 'Deleted old\Inserted new rows to main table'
--	EXEC dbo.LOG_PROCESS @TABLE_NAME, @START_DATE, @LOG_MESSAGE, @ROW_COUNT
--END

 ----We don't want to have this table always - if no one use it now - drop it. who need it - will create again
DELETE FROM dbo.PARTITION_LOAD_ID_VALUES_CNT WHERE TABLE_NAME = @TABLE_NAME 

