CREATE PROC [Utility].[ManagePartitions_Number] @Table_Name [VARCHAR](130),@BoundaryStep [BIGINT] AS 

/*
USE EDW_TRIPS 
GO
IF OBJECT_ID ('Utility.ManagePartitions_Number', 'P') IS NOT NULL DROP PROCEDURE Utility.ManagePartitions_Number
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.ManagePartitions_Number 'dbo.Fact_InvoiceAgingHist', 1000000
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc checking that it's enough partitions upfront next load and adding new if it's not
Table should have Partition column DayID or MonthID

@Table_Name - Production Partitioned Table name (with Schema) that should be checked.  
@BoundaryStep - Param to define partition step on table. 
	-- By default '10000000'
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
no_clog			Andy	01/10/2020	New!
###################################################################################################################
*/
BEGIN

	/*====================================== TESTING =======================================================================*/
	--DECLARE @Table_Name VARCHAR(130) = 'dbo.Fact_InvoiceAgingHist', @BoundaryStep BIGINT 
	/*====================================== TESTING =======================================================================*/


	DECLARE @LogSourse VARCHAR(200) = @Table_Name, @Error VARCHAR(MAX) = ''
	DECLARE @StartDate DATETIME2 (3) = SYSDATETIME(), @LOG_MESSAGE VARCHAR(1000), @Trace_Flag BIT = 1 -- Testing

	IF @Table_Name IS NULL SET @Error = @Error + 'Destination (Production) Table name cannot be NULL'
	IF @BoundaryStep IS NULL SET @BoundaryStep = 10000000

	IF LEN(@Error) > 0
	BEGIN
		PRINT @Error
		EXEC Utility.FastLog @LogSourse, @Error, -3
	END
	ELSE
	BEGIN
		DECLARE @Param VARCHAR(100) = 'Alias,Type,NoPrint'
		DECLARE @Schema VARCHAR(30), @Table VARCHAR(130)
		DECLARE @sql VARCHAR(MAX)
		DECLARE @Dot INT = CHARINDEX('.',@Table_Name)

		SELECT 
			@Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot + 1,200),'[',''),']','') END

		DECLARE @MAX_PartNumber INT, @MAX_BoundaryValue BIGINT
		DECLARE @NewBoundaryValue BIGINT
		
		SELECT TOP 1
			@MAX_PartNumber = CAST(MAX(p.[partition_number]) AS INT)			-- AS      [partition_number]
			,@MAX_BoundaryValue = CAST(MAX(rv.[value]) AS BIGINT)				-- AS      [partition_boundary_value]
		FROM      sys.schemas s
		JOIN      sys.Tables t                  ON t.[schema_id]      = s.[schema_id] AND t.[name] = @Table
		JOIN      sys.partitions p              ON p.[object_id]      = t.[object_id] AND p.[index_id] <= 1
		JOIN      sys.indexes i                 ON i.[object_id]      = p.[object_id] AND i.[index_id] = p.[index_id]
		JOIN      sys.data_spaces ds            ON ds.[data_space_id] = i.[data_space_id]
		LEFT JOIN sys.partition_schemes ps      ON ps.[data_space_id] = ds.[data_space_id]
		LEFT JOIN sys.partition_functions pf    ON pf.[function_id]   = ps.[function_id]
		LEFT JOIN sys.partition_range_values rv ON rv.[function_id]   = pf.[function_id] AND rv.[boundary_id] = p.[partition_number]
		WHERE s.name = @Schema

		IF @MAX_PartNumber IS NOT NULL
		BEGIN
			DECLARE @Table_PartitionColumn VARCHAR(100) = @Param
			EXEC Utility.Get_PartitionColumn		@Table_Name, @Table_PartitionColumn OUTPUT

			DECLARE @ParmDefinition nvarchar(100) = N'@MAX_Value BIGINT OUTPUT'
			DECLARE @MAX_Value BIGINT
			DECLARE @Nsql NVARCHAR(MAX)

			SET @Nsql = '
			SELECT @MAX_Value = MAX(' + @Table_PartitionColumn + ')
			FROM ' + @Table_Name + ''
			EXECUTE sp_executesql @Nsql, @ParmDefinition, @MAX_Value = @MAX_Value OUTPUT  

			SET @NewBoundaryValue = @MAX_Value - @MAX_Value % @BoundaryStep + @BoundaryStep * 4

			IF @MAX_BoundaryValue < @NewBoundaryValue 
			BEGIN

				-- First we have to have empty the last partition before spliting it
				DECLARE @SQL_Out VARCHAR(MAX) = @Param
				EXEC Utility.Get_CreateEmptySwitchTable_SQL @Table_Name, @SQL_Out OUTPUT 
				IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL_Out
				EXECUTE (@SQL_Out);

				SET @sql = 'ALTER TABLE ' + @Schema + '.[' + @Table + '] SWITCH PARTITION ' + CAST(@MAX_PartNumber AS VARCHAR(3))+' TO ' + @Schema + '.[' + @Table + 'Switch] PARTITION ' + CAST(@MAX_PartNumber AS VARCHAR(3))+';'
				IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
				EXECUTE (@sql);

				WHILE @MAX_BoundaryValue < @NewBoundaryValue
				BEGIN
					-- ADD a new row to the control table 
					SET @MAX_BoundaryValue = @MAX_BoundaryValue + @BoundaryStep

					-- And split the last partition - add new range
					SET @sql = (SELECT 'ALTER TABLE ' + @Schema + '.[' + @Table + '] SPLIT RANGE ('+@MAX_BoundaryValue+');');
					IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
					EXECUTE (@sql);

				END -- @MAX_BoundaryValue < @NewBoundaryValue

				-- Here is the issue - if the last partition had any data, we can't just switch partition now because in a new table last partition is not last anymore and has boundary
				-- To get this data back we have to move this data to the table with the same partitions as a new table

				-- THEN we have TO know - IS there ANY data in this partition - if so, have to get it form this table
				-- Need to know - is there any data - if is - use CREATE AS to create new table with new data and all ranges then switch this partition with new table
				DECLARE @RowCount BIGINT

				SET @ParmDefinition = N'@RowCount BIGINT OUTPUT'
				SET @Nsql = '
				SELECT @RowCount = COUNT_BIG(1)
				FROM [' + @Schema + '].[' + @Table + 'Switch]'
				EXECUTE sp_executesql @Nsql, @ParmDefinition, @RowCount = @RowCount OUTPUT  

				IF @Trace_Flag = 1 PRINT 'Last partition is not empty, @RowCount = ' + CAST(@RowCount AS VARCHAR(10))

				IF @RowCount > 0
				BEGIN
					-- DROP is exists
					DECLARE @CreateTableAs VARCHAR(MAX) = 'NoPrint', @NewSwitchTable VARCHAR(100) = '[' + @Schema + '].[' + @Table + 'SwitchNew]'

					EXEC Utility.Get_CreateTableAs_SQL @Table_Name, @NewSwitchTable, @CreateTableAs OUTPUT 
					-- This will return us statement with new partitions, but source table should be 'Switch' - have to change this in SQL statement
					SET @CreateTableAs = REPLACE(@CreateTableAs, '[' + @Schema + '].[' + @Table + ']', '[' + @Schema + '].[' + @Table + 'Switch]') -- Have to change tables names
					IF @Trace_Flag = 1 EXEC Utility.LongPrint @CreateTableAs
					EXECUTE (@CreateTableAs);

					-- Then move old data to a new partition of the table, that now has more partitions
					SET @sql = 'ALTER TABLE ' + @Schema + '.[' + @Table + 'SwitchNew] SWITCH PARTITION ' + CAST(@MAX_PartNumber AS VARCHAR(3))+' TO ' + @Schema + '.[' + @Table + '] PARTITION ' + CAST(@MAX_PartNumber AS VARCHAR(3))+';'
					IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
					EXECUTE (@sql);

					-- Now we can Drop NEW_SET temp table with the last partition - It's empty now
					SET @sql = 'IF OBJECT_ID(''' + @Schema + '.[' + @Table + 'SwitchNew]'') IS NOT NULL 	DROP TABLE ' + @Schema + '.[' + @Table + 'SwitchNew];';	
					IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
					EXECUTE (@sql);
				END

				-- Now we can Drop temp table with the last partition
				SET @sql = '
				IF OBJECT_ID(''' + @Schema + '.[' + @Table + 'Switch]'') IS NOT NULL 	DROP TABLE ' + @Schema + '.[' + @Table + 'Switch];';	
				IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
				EXECUTE (@sql);

			END -- IF @MAX_BoundaryDate < @NewBoundaryDate 
		END
	END
END	

