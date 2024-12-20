CREATE PROC [DBO].[PARTITION_MANAGE_MONTHLY_LOAD] @TABLE_NAME [VARCHAR](100) AS 

/*
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.PARTITION_MANAGE_MONTHLY_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.PARTITION_MANAGE_MONTHLY_LOAD
GO
*/
--#1	Andy Filipps	2019-02-08	CREATED

-- DECLARE @TABLE_NAME  [VARCHAR](100) = 'FACT_UNIFIED_VIOLATION_SNAPSHOT'

DECLARE @NEW_PARTITION_DATE DATE = DATEADD(DAY,1,EOMONTH(GETDATE(),1)) -- Beginning of next next Month

DECLARE @sql VARCHAR(MAX)
DECLARE @MAX_PN INT
DECLARE @MAX_BVAL INT
DECLARE @NewStartDate DATE 
DECLARE @New_DAY_ID VARCHAR(8)
--DECLARE @LAST_DAY_ID INT = (SELECT MAX(DAY_ID) FROM dbo.PARTITION_DAY_ID_CONTROL WHERE TABLE_NAME = 'FACT_UNIFIED_VIOLATION')
DECLARE @LAST_DAY_ID INT = CAST(CONVERT(VARCHAR(8),@NEW_PARTITION_DATE,112) AS INT)

SELECT
	@MAX_PN = CAST(MAX(p.[partition_number]) AS INT)			-- AS      [partition_number]
	,@MAX_BVAL = CAST(MAX(rv.[value]) AS INT)				-- AS      [partition_boundary_value]
FROM      sys.tables t                    
JOIN      sys.partitions p              ON p.[object_id]      = t.[object_id] AND p.[index_id] <= 1
JOIN      sys.indexes i                 ON i.[object_id]      = p.[object_id] AND i.[index_id] = p.[index_id]
JOIN      sys.data_spaces ds            ON ds.[data_space_id] = i.[data_space_id]
LEFT JOIN sys.partition_schemes ps      ON ps.[data_space_id] = ds.[data_space_id]
LEFT JOIN sys.partition_functions pf    ON pf.[function_id]   = ps.[function_id]
LEFT JOIN sys.partition_range_values rv ON rv.[function_id]   = pf.[function_id] AND rv.[boundary_id] = p.[partition_number]
WHERE t.[name] = @TABLE_NAME --'FACT_VIOLATIONS_DETAIL'

PRINT @MAX_PN
PRINT @MAX_BVAL
PRINT @LAST_DAY_ID

IF @MAX_BVAL < @LAST_DAY_ID 
BEGIN

	SET @sql = '
	IF OBJECT_ID(''dbo.[' + @TABLE_NAME + '_LAST_PARTITION]'') IS NOT NULL 	DROP TABLE dbo.[' + @TABLE_NAME + '_LAST_PARTITION];';	
	EXECUTE (@sql);

	-- First we have to have empty the last partition before spliting it
	EXEC DBO.GET_CREATE_TRUNCATE_TABLE_SQL @TABLE_NAME, @sql OUTPUT 
	--EXEC [DBO].[PRINT_LONG_VARIABLE_VALUE] @sql
	SET @sql = REPLACE(@sql,'_TRUNCATE','_LAST_PARTITION') -- We need other name of a new table
	--EXEC [DBO].[PRINT_LONG_VARIABLE_VALUE] @sql
	EXECUTE (@sql);

	SET @sql = 'ALTER TABLE dbo.[' + @TABLE_NAME + '] SWITCH PARTITION ' + CAST(@MAX_PN AS VARCHAR(3))+' TO dbo.[' + @TABLE_NAME + '_LAST_PARTITION] PARTITION ' + CAST(@MAX_PN AS VARCHAR(3))+';'
	--PRINT @sql
	EXECUTE (@sql);

	WHILE @MAX_BVAL < @LAST_DAY_ID
	BEGIN
		-- ADD a new row to the control table 
		SET @NewStartDate = DateAdd(MONTH,1,CAST(CAST(@MAX_BVAL AS VARCHAR) AS DATE))
		SET @New_DAY_ID = CONVERT(VARCHAR(8),@NewStartDate,112)
	
		-- And split the last partition - add new range
		SET @sql = (SELECT 'ALTER TABLE dbo.' + @TABLE_NAME + ' SPLIT RANGE ('+@New_DAY_ID+');');
		EXECUTE (@sql);

		SET @MAX_BVAL = CAST(@New_DAY_ID AS INT)
	END -- WHILE @MAX_BVAL <= @LAST_DAY_ID

	-- THEN we have TO know - IS there ANY data in this partition - if so, have to get it form this table
	-- Need to know - is there any data - if is - use CREATE AS to create new table with new data and all ranges then switch this partition with new table
	DECLARE @ParmDefinition nvarchar(100) = N'@PART_CNT BIGINT OUTPUT'
	DECLARE @LAST_PART_CNT BIGINT
	DECLARE @Nsql NVARCHAR(MAX)

	SET @Nsql = '
	SELECT @PART_CNT = COUNT_BIG(1)
	FROM [' + @TABLE_NAME + '_LAST_PARTITION]'
	EXECUTE sp_executesql @Nsql, @ParmDefinition, @PART_CNT = @LAST_PART_CNT OUTPUT  

	--PRINT '@LAST_PART_CNT = ' + CAST(@LAST_PART_CNT AS VARCHAR)

	IF @LAST_PART_CNT > 0
	BEGIN
		-- DROP is exists
		SET @sql = '
		IF OBJECT_ID(''dbo.[' + @TABLE_NAME + '_LAST_PARTITION_NEW_SET]'') IS NOT NULL 	DROP TABLE dbo.[' + @TABLE_NAME + '_LAST_PARTITION_NEW_SET];';	
		--EXEC [DBO].[PRINT_LONG_VARIABLE_VALUE] @sql
		EXECUTE (@sql);

		-- If date is there - create new table with new partitions and move all data to this new table
		EXEC DBO.GET_CREATE_TABLE_AS_SQL @TABLE_NAME, @sql OUTPUT 
		SET @sql = REPLACE(@sql, '[' + @TABLE_NAME, '[' + @TABLE_NAME + '_LAST_PARTITION') -- Have to change tables names
		--EXEC [DBO].[PRINT_LONG_VARIABLE_VALUE] @sql

		EXECUTE (@sql);

		-- Then move old data to a new partition of the table, that now has more partitions
		SET @sql = 'ALTER TABLE dbo.[' + @TABLE_NAME + '_LAST_PARTITION_NEW_SET] SWITCH PARTITION ' + CAST(@MAX_PN AS VARCHAR(3))+' TO dbo.[' + @TABLE_NAME + '] PARTITION ' + CAST(@MAX_PN AS VARCHAR(3))+';'
		--EXEC [DBO].[PRINT_LONG_VARIABLE_VALUE] @sql
		EXECUTE (@sql);

		-- Now we can Drop NEW_SET temp table with the last partition - It's empty now
		SET @sql = '
		IF OBJECT_ID(''dbo.[' + @TABLE_NAME + '_LAST_PARTITION_NEW_SET]'') IS NOT NULL 	DROP TABLE dbo.[' + @TABLE_NAME + '_LAST_PARTITION_NEW_SET];';	
		EXECUTE (@sql);
	END

	-- Now we can Drop temp table with the last partition
	SET @sql = '
	IF OBJECT_ID(''dbo.[' + @TABLE_NAME + '_LAST_PARTITION]'') IS NOT NULL 	DROP TABLE dbo.[' + @TABLE_NAME + '_LAST_PARTITION];';	
	EXECUTE (@sql);

END -- IF @MAX_BVAL <= @LAST_DAY_ID 


