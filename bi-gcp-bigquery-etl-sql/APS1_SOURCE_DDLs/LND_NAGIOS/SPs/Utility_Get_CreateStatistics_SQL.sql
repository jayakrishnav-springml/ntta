CREATE PROC [Utility].[Get_CreateStatistics_SQL] @Example_Name [VARCHAR](130),@CreateStatsOn_Name [VARCHAR](130),@Params_In_SQL_Out [VARCHAR](MAX) OUT AS
/*
USE LND_NAGIOS 
GO
IF OBJECT_ID ('Utility.Get_CreateStatistics_SQL', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_CreateStatistics_SQL
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'No[]'
EXEC Utility.Get_CreateStatistics_SQL '[FINANCE].[ADJUSTMENT_LINEITEMS]', '[New].[ADJUSTMENT_LINEITEMS]', @Params_In_SQL_Out  OUTPUT

===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning SQL statement to create Statistics for a table taking the example from another table.
Not checking for existing columns - all columns? presented on Statistics on Example table should be presented on the table

@Example_Name - Name of the Example table. Can't be Null.
@CreateStatsOn_Name - Table name (with Schema) is table to create ctatistics on. Can't be Null.
@Params_In_SQL_Out - Param to return SQL statement. Can take some secondary parameters
	can include values: 	'No[],NoPrint'
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
###################################################################################################################
*/

BEGIN

	DECLARE @Error VARCHAR(MAX) = ''
	DECLARE @Params VARCHAR(100) = ISNULL(@Params_In_SQL_Out,'')

	IF @Example_Name IS NULL SET @Error = @Error + 'Table name cannot be NULL'
	SET @Params_In_SQL_Out = '';

	IF LEN(@Error) > 0
	BEGIN
		PRINT @Error
	END
	ELSE
	BEGIN
		
		DECLARE @ColumnsCnt INT, @THIS_stats_String VARCHAR(MAX) = '', @Indicat SMALLINT = 1
		DECLARE @Schema VARCHAR(100), @Table VARCHAR(200), @New_Schema VARCHAR(100), @New_Table VARCHAR(200)
		DECLARE @Dot1 INT = CHARINDEX('.',@Example_Name), @Dot2 INT = CHARINDEX('.',@CreateStatsOn_Name)

		SELECT 
			@Schema = CASE WHEN @Dot1 = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Example_Name,@Dot1),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot1 = 0 THEN REPLACE(REPLACE(@Example_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Example_Name,@Dot1 + 1,200),'[',''),']','') END,
			@New_Schema = CASE WHEN @Dot2 = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@CreateStatsOn_Name,@Dot2),'[',''),']',''),'.','') END,
			@New_Table = CASE WHEN @Dot2 = 0 THEN REPLACE(REPLACE(@CreateStatsOn_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@CreateStatsOn_Name,@Dot2 + 1,200),'[',''),']','') END

		IF OBJECT_ID('TempDB..#Table_STATS') IS NOT NULL DROP Table #Table_STATS;
		WITH CTE AS
		(
			SELECT
				s.[name] AS schemaName
				,t.[name] AS [Table_name]
				,ss.[name] AS [stats_name]
				,c.name AS [column_name]
				, ROW_NUMBER() OVER (PARTITION BY ss.[name] ORDER BY C.column_id) AS RN 
			FROM sys.Tables t
			JOIN sys.schemas s ON t.schema_id = s.schema_id AND s.name = @Schema
			JOIN sys.stats ss ON ss.[object_id] = t.[object_id] AND ss.user_created = 1
			JOIN sys.stats_columns sc ON sc.[object_id] = t.[object_id] AND ss.stats_id = sc.stats_id
			JOIN sys.columns c ON t.[object_id]  = c.[object_id] AND sc.column_id  = c.column_id
			WHERE  t.[name] = @Table
		)
		, CTE_JOINT AS 
		(
			SELECT 
				CTE1.stats_name
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
				CTE_JOINT.stats_name
				,'CREATE STATISTICS [' + stats_name + '] ON ' + @NEW_Schema + '.[' + @NEW_Table + '] (' + stats_COULUMNS + ');' AS stats_String
				, ROW_NUMBER() OVER(ORDER BY stats_name) AS RN
			INTO #Table_STATS
		FROM CTE_JOINT


		SELECT @ColumnsCnt = MAX(RN) FROM #Table_STATS
		SET @Indicat = 1
		-- If only 1 period (and 1 partition) - @PART_RANGES is empty
		WHILE (@Indicat <= @ColumnsCnt)
		BEGIN
		
			SELECT @THIS_stats_String = stats_String FROM #Table_STATS WHERE RN = @Indicat --ORDER BY stats_name

			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + @THIS_stats_String

			SET @Indicat += 1

		END

		IF CHARINDEX('No[]',@Params) > 0
			SET @Params_In_SQL_Out = REPLACE(REPLACE(@Params_In_SQL_Out,'[',''),']','')

		IF CHARINDEX('NoPrint',@Params) = 0
			EXEC Utility.LongPrint @Params_In_SQL_Out

	END
END

