CREATE PROC [Utility].[ManagePartitions_DateID] @Table_Name [VARCHAR](130),@PartitionParam [VARCHAR](100) AS 

/*
IF OBJECT_ID ('Utility.ManagePartitions_DateID', 'P') IS NOT NULL DROP PROCEDURE Utility.ManagePartitions_DateID
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.ManagePartitions_DateID 'dbo.Fact_InvoiceAgingSnapshot', 'MonthID:Month'
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc checking that it's enough partitions upfront next load and adding new if it's not
Table should have Partition column DayID or MonthID

@Table_Name - Production Partitioned Table name (with Schema) that should be checked.  
@PartitionParam - Param to define partitions on table. Looks like 'Type:Step' 
	-- can be: 	'DayID:Month' / 'MonthID:Month/Year'
	-- By default 'MonthID:Month'
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
no_clog			Andy	01/10/2020	New!
CHG0038075		Andy	02/01/2021	Fixed error @MAX_BoundaryValue ->> CAST(@MAX_BoundaryValue AS VARCHAR(8))

###################################################################################################################
*/
BEGIN

	/*====================================== TESTING =======================================================================*/
	--DECLARE @Table_Name VARCHAR(130) = 'dbo.Fact_InvoiceAgingSnapshot', @PartitionParam VARCHAR(100) = 'MonthID:Month' 
	/*====================================== TESTING =======================================================================*/


	DECLARE @LogSourse VARCHAR(200) = @Table_Name, @Error VARCHAR(MAX) = ''
	DECLARE @StartDate DATETIME2 (3) = SYSDATETIME(), @LOG_MESSAGE VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing
	DECLARE @Params VARCHAR(100) = ISNULL(NULLIF(LTRIM(RTRIM(@PartitionParam)),''),'MonthID:Month')

	IF @Table_Name IS NULL SET @Error = @Error + 'Destination (Production) Table name cannot be NULL'

	IF LEN(@Error) > 0
	BEGIN
		PRINT @Error
		EXEC Utility.FastLog @LogSourse, @Error, -3
	END
	ELSE
	BEGIN
		DECLARE @Param VARCHAR(100) = 'Alias,Type,NoPrint'
		DECLARE @Schema VARCHAR(30), @Table VARCHAR(130)
		DECLARE @sql VARCHAR(MAX), @BoundaryType VARCHAR(10), @BoundaryStep VARCHAR(20)
		DECLARE @SQL_Out VARCHAR(MAX) = @Param, @NewTable_Name VARCHAR(130)
		DECLARE @Dot INT = CHARINDEX('.',@Table_Name), @Index INT

		SELECT 
			@Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot + 1,200),'[',''),']','') END

		SET @NewTable_Name = @Schema + '.[' + @Table + 'Switch]'

		SET @Params = REPLACE(REPLACE(@Params,' ',''),'	','')
		SET @Index = CHARINDEX(':',@Params)
		IF @Index > 0 -- In this brackets only the table name can be we need to put in AS
		BEGIN
			SET @BoundaryType = LEFT(@Params,@Index - 1)
			SET @BoundaryStep = SUBSTRING(@Params,@Index + 1, 20)
		END
		ELSE -- If this happens - we assum it only Type like DayID or MonthID and the Step is Month - it's the most frequent situation
		BEGIN
			SET @BoundaryType = @Params
			SET @BoundaryStep = 'Month'
		END
		--IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql

		DECLARE @MAX_PartNumber INT, @MAX_BoundaryValue INT
		DECLARE @NewBoundaryValue INT, @MAX_BoundaryDate DATE, @NewBoundaryDate DATE, @RollBoundaryDate DATE
		
		SET	@NewBoundaryDate = CASE 
									WHEN @BoundaryStep = 'Month' THEN DATEADD(DAY,1,EOMONTH(@StartDate,1)) -- Beginning of next next Month
									WHEN @BoundaryStep = 'Year' THEN CAST(DATEPART(YEAR,@StartDate) AS VARCHAR(4)) + '0101' -- Beginning of next Year
								END
		SELECT
			@MAX_PartNumber = CAST(MAX(p.[partition_number]) AS INT)			-- AS      [partition_number]
			,@MAX_BoundaryValue = CAST(MAX(rv.[value]) AS INT)				-- AS      [partition_boundary_value]
		FROM      sys.schemas s
		JOIN      sys.Tables t                  ON t.[schema_id]      = s.[schema_id]
		JOIN      sys.partitions p              ON p.[object_id]      = t.[object_id] AND p.[index_id] <= 1
		JOIN      sys.indexes i                 ON i.[object_id]      = p.[object_id] AND i.[index_id] = p.[index_id]
		JOIN      sys.data_spaces ds            ON ds.[data_space_id] = i.[data_space_id]
		LEFT JOIN sys.partition_schemes ps      ON ps.[data_space_id] = ds.[data_space_id]
		LEFT JOIN sys.partition_functions pf    ON pf.[function_id]   = ps.[function_id]
		LEFT JOIN sys.partition_range_values rv ON rv.[function_id]   = pf.[function_id] AND rv.[boundary_id] = p.[partition_number]
		WHERE s.name = @Schema AND t.[name] = @Table

		SET @MAX_BoundaryDate = CASE	
									WHEN @BoundaryType = 'DayID' THEN CONVERT(DATE,CAST(@MAX_BoundaryValue AS VARCHAR(8)),112)
									ELSE CONVERT(DATE,CAST(@MAX_BoundaryValue AS VARCHAR(6)) + '01',112)  -- IF @BoundaryType = 'MonthID'
								END

		IF @MAX_PartNumber IS NOT NULL AND @MAX_BoundaryDate < @NewBoundaryDate 
		BEGIN

			-- First we have to have empty the last partition before spliting it
			EXEC Utility.Get_CreateEmptyCopy_SQL @Table_Name, @NewTable_Name, @SQL_Out OUTPUT 
			IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL_Out
			EXECUTE (@SQL_Out);

			SET @sql = 'ALTER TABLE ' + @Table_Name + ' SWITCH PARTITION ' + CAST(@MAX_PartNumber AS VARCHAR(3)) + ' TO ' + @NewTable_Name + ' PARTITION ' + CAST(@MAX_PartNumber AS VARCHAR(3))+';'
			IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
			EXECUTE (@sql);

			WHILE @MAX_BoundaryDate < @NewBoundaryDate
			BEGIN
				-- ADD a new row to the control table 
				SET @RollBoundaryDate = CASE 
												WHEN @BoundaryStep = 'Month' THEN DATEADD(MONTH,1,@MAX_BoundaryDate) -- Beginning of next Month
												WHEN @BoundaryStep = 'Year' THEN DATEADD(YEAR,1,@MAX_BoundaryDate)  -- Beginning of next Year
											END

				SET @MAX_BoundaryValue = CASE	
											WHEN @BoundaryType = 'DayID' THEN CAST(CONVERT(VARCHAR(8), @RollBoundaryDate,112) AS INT)
											ELSE CAST(CONVERT(VARCHAR(6), @RollBoundaryDate,112) AS INT)  -- IF @BoundaryType = 'MonthID'
										END
					
				-- And split the last partition - add new range
				SET @sql = (SELECT 'ALTER TABLE ' + @Table_Name + ' SPLIT RANGE (' + CAST(@MAX_BoundaryValue AS VARCHAR(8)) + ');');
				IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
				EXECUTE (@sql);

				SET @MAX_BoundaryDate = @RollBoundaryDate

			END -- WHILE @MAX_BoundaryDate < @NewBoundaryDate

			-- Here is the issue - if the last partition had any data, we can't just switch partition now because in a new table last partition is not last anymore and has boundary
			-- To get this data back we have to move this data to the table with the same partitions as a new table

			-- THEN we have TO know - IS there ANY data in this partition - if so, have to get it form this table
			-- Need to know - is there any data - if is - use CREATE AS to create new table with new data and all ranges then switch this partition with new table
			DECLARE @ParmDefinition NVARCHAR(100) = N'@RowCount BIGINT OUTPUT', @RowCount BIGINT, @Nsql NVARCHAR(MAX)

			SET @Nsql = 'SELECT @RowCount = COUNT_BIG(1) FROM ' + @NewTable_Name + 'Switch'
			EXECUTE sp_executesql @Nsql, @ParmDefinition, @RowCount = @RowCount OUTPUT  

			IF @Trace_Flag = 1 PRINT 'Last partition RowCount = ' + CAST(@RowCount AS VARCHAR(10))

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
			SET @sql = 'IF OBJECT_ID(''' + @NewTable_Name + ''') IS NOT NULL 	DROP TABLE ' + @NewTable_Name + ';';	
			IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
			EXECUTE (@sql);

		END -- IF @MAX_BoundaryDate < @NewBoundaryDate 
	END

END	

