CREATE PROC [Utility].[Get_Partition_String] @Table_Name [VARCHAR](200),@Params_In_SQL_Out [VARCHAR](MAX) OUT AS
/*
USE LND_TBOS
GO
IF OBJECT_ID ('Utility.Get_Partition_String', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_Partition_String
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'No[]'
EXEC Utility.Get_Partition_String '[TollPlus].[TP_Customers]', @Params_In_SQL_Out OUTPUT 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning Partition string for Create table statement, looks like ', PARTITION (PartitionColumn FOR VALUES (value1,value2,...))' for Partitioned table. If table is not Partitioned - returning empty string

@Table_Name - Name of the table to pick column from
@Params_In_SQL_Out - Param to return string. 
	-- can be: 	'No[],NoPrint'
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837			Andy	01/10/2020	New!
###################################################################################################################
*/

BEGIN
	/*====================================== TESTING =======================================================================*/
	--DECLARE @Table_Name VARCHAR(200) = '[TollPlus].[TP_Customers]', @Params_In_SQL_Out VARCHAR(MAX)
	/*====================================== TESTING =======================================================================*/


	DECLARE @Error VARCHAR(MAX) = ''
	DECLARE @Params VARCHAR(100) = ISNULL(@Params_In_SQL_Out,'')

	IF @Table_Name IS NULL SET @Error = @Error + 'Table name cannot be NULL'

	SET @Params_In_SQL_Out = '';

	IF LEN(@Error) > 0
	BEGIN
		PRINT @Error
	END
	ELSE
	BEGIN

		DECLARE @Schema VARCHAR(100), @Table VARCHAR(200)
		DECLARE @ColumnName NVARCHAR(100), @ColumnType NVARCHAR(100), @Delimiter NVARCHAR(1) = ''
		DECLARE @Dot INT = CHARINDEX('.',@Table_Name)

		SELECT 
			@Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot + 1,200),'[',''),']','') END

		SELECT  
			@ColumnName =  '[' + CAST(c.name AS NVARCHAR) COLLATE DATABASE_DEFAULT + '] RANGE ' + CASE WHEN pf.boundary_value_on_right = 1 THEN 'RIGHT' ELSE 'LEFT' END
			, @ColumnType = TYPE_NAME(c.system_type_id)
		FROM sys.Tables AS t  
		JOIN sys.schemas s ON t.[schema_id] = s.[schema_id] AND s.name = @Schema
		JOIN sys.indexes AS i ON t.[object_id] = i.[object_id] AND I.index_id <=1
		JOIN sys.partition_schemes	AS ps ON ps.data_space_id	= i.data_space_id  
		JOIN sys.index_columns		AS ic ON ic.[object_id]		= i.[object_id] AND ic.index_id = i.index_id AND ic.partition_ordinal >= 1 -- because 0 = non-partitioning column  
		JOIN sys.columns			AS c  ON t.[object_id]		= c.[object_id] AND ic.column_id = c.column_id
		JOIN sys.partition_functions   pf ON pf.[function_id]   = ps.[function_id]
		WHERE  t.[name] = @Table 

		IF @ColumnName IS NOT NULL
		BEGIN
			IF OBJECT_ID('TempDB..#Table_valueS') IS NOT NULL DROP Table #Table_valueS;
			SELECT  
				CASE
					WHEN @ColumnType = 'TIME' THEN CHAR(39) + CONVERT(NVARCHAR, rv.value, 114) + CHAR(39)
					WHEN @ColumnType = 'DATE' THEN CHAR(39) + CONVERT(NVARCHAR, rv.value, 112) + CHAR(39)
					WHEN @ColumnType LIKE '%DATE%' THEN CHAR(39) + CONVERT(NVARCHAR, rv.value, 121) + CHAR(39)
					WHEN @ColumnType LIKE '%CHAR' THEN NCHAR(39) + CAST(rv.value AS NVARCHAR) + NCHAR(39)  --CONVERT(NVARCHAR, rv.value) + CHAR(39) COLLATE Latin1_General_CI_AS_KS_WS 
					ELSE CONVERT(NVARCHAR, rv.value)
				END AS RangeValue
				, ROW_NUMBER() OVER (ORDER BY rv.value) AS RN 
			INTO #Table_valueS
			FROM   sys.Tables t
			JOIN   sys.schemas s ON t.schema_id = s.schema_id AND s.name = @Schema
			JOIN   sys.partitions p              ON p.[object_id]      = t.[object_id] AND p.[index_id] <=1
			JOIN   sys.indexes i                 ON i.[object_id]      = p.[object_id] AND i.[index_id] = p.[index_id]
			JOIN   sys.data_spaces ds            ON ds.[data_space_id] = i.[data_space_id]
			JOIN   sys.partition_schemes ps      ON ps.[data_space_id] = ds.[data_space_id]
			JOIN   sys.partition_functions pf    ON pf.[function_id]   = ps.[function_id]
			JOIN   sys.partition_range_values rv ON rv.[function_id]   = pf.[function_id] AND rv.[boundary_id] = p.[partition_number]
			WHERE t.[name] = @Table AND rv.value IS NOT NULL 

			DECLARE @ColumnsCnt INT
			DECLARE @THIS_RangeValue NVARCHAR(MAX) = ''
			DECLARE @Indicat SMALLINT = 1
			DECLARE @RangeValue NVARCHAR(MAX) = ''

			SELECT @ColumnsCnt = MAX(RN) FROM #Table_valueS
			-- If only 1 period (and 1 partition) - @PART_RANGES is empty
			WHILE (@Indicat <= @ColumnsCnt)
			BEGIN
				SELECT @THIS_RangeValue = RangeValue FROM #Table_valueS WHERE RN = @Indicat --ORDER BY stats_name
				SET @RangeValue = @RangeValue + @Delimiter + @THIS_RangeValue
				SET @Indicat += 1
				SET @Delimiter = ', '
			END

			SET @Params_In_SQL_Out  = ', PARTITION (' + @ColumnName + ' FOR VALUES (' + @RangeValue + '))' 

			IF CHARINDEX('No[]',@Params) > 0
				SET @Params_In_SQL_Out = REPLACE(REPLACE(@Params_In_SQL_Out,'[',''),']','')

			IF CHARINDEX('NoPrint',@Params) = 0
				EXEC Utility.LongPrint @Params_In_SQL_Out


		END

	END
END


