CREATE PROC [Utility].[Get_DropStatistics_SQL] @Table_Name [VARCHAR](200),@Params_In_SQL_Out [VARCHAR](MAX) OUT AS
/*
USE LND_TBOS
GO
IF OBJECT_ID ('Utility.Get_DropStatistics_SQL', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_DropStatistics_SQL
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'No[]'
EXEC Utility.Get_DropStatistics_SQL '[TollPlus].[TP_Customers]', @Params_In_SQL_Out  
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning DROP STATISTICS SQL statement for table. It's dropping all User defined statictics on the table.

@Table_Name - Name of the table to drop statistics on
@Params_In_SQL_Out - Param to return string. 
	-- can be: 	'No[],NoPrint'
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837			Andy	01/10/2020	New!
###################################################################################################################
*/

BEGIN

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

		DECLARE @Schema VARCHAR(100), @Table VARCHAR(200), @ColumnsCnt INT, @This_SQL_String VARCHAR(MAX) = '', @Indicat SMALLINT = 1
		DECLARE @Dot INT = CHARINDEX('.',@Table_Name)

		SELECT 
			@Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot + 1,200),'[',''),']','') END

		IF OBJECT_ID('TempDB..#Table_STATS') IS NOT NULL DROP Table #Table_STATS;
		WITH CTE_STATS AS
		(
			SELECT DISTINCT
				s.[name] AS schemaName
				,t.[name] AS [Table_name]
				,ss.[name] AS [stats_name]
			FROM        sys.Tables t
			JOIN		sys.schemas s ON t.schema_id = s.schema_id AND s.name = @Schema
			JOIN		sys.stats ss					ON		ss.[object_id] = t.[object_id] AND ss.user_created = 1
			JOIN		sys.stats_columns sc			ON		sc.[object_id] = t.[object_id] AND ss.stats_id = sc.stats_id
			JOIN        sys.columns c                   ON      t.[object_id]  = c.[object_id] AND sc.column_id  = c.column_id
			WHERE  t.[name] = @Table 
		)
		SELECT 
			schemaName
			,Table_name
			,stats_name
			,'DROP STATISTICS ' + schemaName + '.[' + Table_name + '].[' + stats_name + '];' AS SQL_String
			, ROW_NUMBER() OVER(ORDER BY stats_name) AS RN
		INTO #Table_STATS
		FROM CTE_STATS

		SET @Params_In_SQL_Out  = ''

		SELECT @ColumnsCnt = MAX(RN) FROM #Table_STATS
		WHILE (@Indicat <= @ColumnsCnt)
		BEGIN
			SELECT @This_SQL_String = SQL_String FROM #Table_STATS WHERE RN = @Indicat --ORDER BY stats_name
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + @This_SQL_String
			SET @Indicat += 1
		END

		IF CHARINDEX('No[]',@Params) > 0
			SET @Params_In_SQL_Out = REPLACE(REPLACE(@Params_In_SQL_Out,'[',''),']','')

		IF CHARINDEX('NoPrint',@Params) = 0
			EXEC Utility.LongPrint @Params_In_SQL_Out

	END
END


