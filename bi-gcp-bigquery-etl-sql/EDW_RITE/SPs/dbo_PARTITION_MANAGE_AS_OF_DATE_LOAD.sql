CREATE PROC [DBO].[PARTITION_MANAGE_AS_OF_DATE_LOAD] @TABLE_NAME [varchar](255) AS

/*

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.PARTITION_MANAGE_AS_OF_DATE_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.PARTITION_MANAGE_AS_OF_DATE_LOAD
GO

EXEC DBO.PARTITION_MANAGE_AS_OF_DATE_LOAD 'FACT_INVOICE_ANALYSIS'
*/

	DECLARE @NEW_PARTITION_DATE DATE = DATEADD(DAY,1,EOMONTH(GETDATE())) -- Beginning of next Month
	PRINT @NEW_PARTITION_DATE
	--DECLARE @TABLE_NAME [varchar](255) = 'DIM_VIOLATOR_ASOF' 

	--DECLARE @NEW_PARTITION_DATE DATE = (SELECT CONVERT(VARCHAR(6), DATEADD(MONTH,3,GETDATE()), 112) + '01')

	DECLARE @MAX_BVAL DATE
	DECLARE @MAX_PN INT
	DECLARE @SQL NVARCHAR(MAX)
	--DECLARE @value_on_right INT

	SELECT
		-- MAX(rv.[value])	MAX_BVAL						-- AS      [partition_boundary_value]
		--, MAX(p.[partition_number])	MAX_PN			-- AS      [partition_number]
		@MAX_BVAL = CAST(MAX(rv.[value]) AS DATE)							-- AS      [partition_boundary_value]
		,@MAX_PN = CAST(MAX(p.[partition_number]) AS INT)				-- AS      [partition_number]
		--,@value_on_right = pf.boundary_value_on_right		-- AS boundary_value_on_right
	FROM        sys.tables t
	JOIN        sys.partitions p                ON      p.[object_id]         = t.[object_id] AND p.[index_id] <= 1
	JOIN        sys.indexes i                   ON      i.[object_id]         = p.[object_id] AND i.[index_id] = p.[index_id]
	JOIN        sys.data_spaces ds              ON      ds.[data_space_id]    = i.[data_space_id]
	LEFT JOIN   sys.partition_schemes ps        ON      ps.[data_space_id]    = ds.[data_space_id]
	LEFT JOIN   sys.partition_functions pf      ON      pf.[function_id]      = ps.[function_id]
	LEFT JOIN   sys.partition_range_values rv   ON      rv.[function_id]      = pf.[function_id] AND rv.[boundary_id] = p.[partition_number]
	--WHERE t.[name] = 'DIM_VIOLATOR_ASOF'  --'FACT_VIOLATIONS_DETAIL'
	WHERE t.[name] = @TABLE_NAME --'FACT_VIOLATIONS_DETAIL'
	--WHERE rv.[value] IS NOT NULL AND t.[name] = @TABLE_NAME --'FACT_VIOLATIONS_DETAIL'

	PRINT (@MAX_BVAL)
	PRINT (@MAX_PN)

	IF @MAX_BVAL < @NEW_PARTITION_DATE 
	BEGIN
		SET @sql = '
		IF OBJECT_ID(''dbo.[' + @TABLE_NAME + '_LAST_PARTITION]'') IS NOT NULL 	DROP TABLE dbo.[' + @TABLE_NAME + '_LAST_PARTITION];';	
		EXECUTE (@sql);

		-- First we have to have empty the last partition before spliting it

		EXEC DBO.GET_CREATE_TABLE_AS_SQL @TABLE_NAME, @sql OUTPUT 
		--EXEC [DBO].[PRINT_LONG_VARIABLE_VALUE] @sql

		SET @sql = REPLACE(@sql,'_NEW_SET','_LAST_PARTITION') -- We need other name of a new table
		SET @sql = REPLACE(@sql,'WHERE 1 = 1','WHERE 1 = 2') -- We need empty table
		--EXEC [DBO].[PRINT_LONG_VARIABLE_VALUE] @sql
		EXECUTE (@sql);

		SET @sql = 'ALTER TABLE dbo.[' + @TABLE_NAME + '] SWITCH PARTITION ' + CAST(@MAX_PN AS VARCHAR(3))+' TO dbo.[' + @TABLE_NAME + '_LAST_PARTITION] PARTITION ' + CAST(@MAX_PN AS VARCHAR(3))+';'
		--PRINT @sql
		EXECUTE (@sql);
		-- Now last partition of the table is empty even if there was some data

		WHILE @MAX_BVAL < @NEW_PARTITION_DATE
		BEGIN
			-- ADD a new row to the control table 
			SET @MAX_BVAL = DateAdd(MONTH,1,@MAX_BVAL)
	
			-- And split the last partition - add new range
			SET @sql = 'ALTER TABLE dbo.[' + @TABLE_NAME + '] SPLIT RANGE ('+CHAR(39) + CONVERT(VARCHAR(8), @MAX_BVAL, 112) + CHAR(39) + ');'
			--EXEC [DBO].[PRINT_LONG_VARIABLE_VALUE] @sql
			EXECUTE (@sql);
		END -- WHILE @MAX_BVAL <= @NEW_PARTITION_DATE

		-- THEN we have TO know - IS there ANY data in this partition - if so, have to get it form this table
		-- Need to know - is there any data - if is - use CREATE AS to create new table with new data and all ranges then switch this partition with new table
		DECLARE @ParmDefinition nvarchar(100) = N'@PART_CNT BIGINT OUTPUT'
		DECLARE @LAST_PART_CNT BIGINT
		SET @sql = '
		SELECT @PART_CNT = COUNT_BIG(1)
		FROM [' + @TABLE_NAME + '_LAST_PARTITION]'
		EXECUTE sp_executesql @sql, @ParmDefinition, @PART_CNT = @LAST_PART_CNT OUTPUT  

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
	END -- IF @MAX_BVAL <= @NEW_PARTITION_DATE 

/*
-- How to get Partition column name and type
; WITH CTE AS
(
	SELECT  
		CAST(c.name AS NVARCHAR) COLLATE DATABASE_DEFAULT AS ColumnName
		, CAST(pf.boundary_value_on_right AS INT) AS boundary_value_on_right
		, TYPE_NAME(c.system_type_id) AS ColumnType, c.max_length, c.PRECISION, c.scale, C.is_nullable
FROM sys.tables AS t  
JOIN sys.indexes AS i ON t.[object_id] = i.[object_id] AND I.index_id <=1
JOIN sys.partition_schemes	AS ps ON ps.data_space_id	= i.data_space_id  
JOIN sys.index_columns		AS ic ON ic.[object_id]		= i.[object_id] AND ic.index_id = i.index_id AND ic.partition_ordinal >= 1 -- because 0 = non-partitioning column  
JOIN sys.columns			AS c  ON t.[object_id]		= c.[object_id] AND ic.column_id = c.column_id
JOIN sys.partition_functions   pf ON pf.[function_id]   = ps.[function_id]
WHERE  t.[name] = @TABLE
)
SELECT  
    @ColumnName =  '[' + ColumnName + '] RANGE ' + CASE WHEN boundary_value_on_right = 1 THEN 'RIGHT' ELSE 'LEFT' END
	, @ColumnType = M.ColumnType +
			CASE 
				WHEN M.ColumnType = 'DATETIME2' THEN '(' + CAST(m.scale AS VARCHAR) +')'
				WHEN M.ColumnType IN ('BINARY','VARBINARY') THEN '(' + CAST(m.max_length AS VARCHAR) +')'
				WHEN M.ColumnType IN ('DECIMAL','NUMERIC') THEN '(' + CAST(m.PRECISION AS VARCHAR) + ',' + CAST(m.scale AS VARCHAR) +')'
				WHEN M.ColumnType LIKE '%CHAR' THEN '(' + CAST(m.max_length AS VARCHAR) +')'
				ELSE ''
			END
FROM CTE AS M
*/
