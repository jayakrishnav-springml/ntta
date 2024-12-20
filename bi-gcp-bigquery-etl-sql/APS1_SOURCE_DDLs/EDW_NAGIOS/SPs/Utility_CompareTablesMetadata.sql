CREATE PROC [Utility].[CompareTablesMetadata] @New_Table_Name [VARCHAR](130),@Main_Table_Name [VARCHAR](130),@ComparisonResult [VARCHAR](MAX) OUT AS

/*
IF OBJECT_ID ('Utility.CompareTablesMetadata', 'P') IS NOT NULL DROP PROCEDURE Utility.CompareTablesMetadata
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @ComparisonResult VARCHAR(MAX) = 'ByName'
EXEC Utility.CompareTablesMetadata 'dbo.Fact_TollTransaction', 'dbo.Fact_TollTransaction_metadata', @ComparisonResult OUTPUT 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc comparing 2 tables and returning result of comparison to the string. If tables identical (but not one table) - returning empty string

@New_Table_Name - Name of the one table (not Null)
@Main_Table_Name - Name of the enother table (not Null)
@ComparisonResult - Text description of diferencies found. If no Differencies returns empty String.	
		-	It can also be input parameter. Parameters can be NoPrint, No[] or ByName - it means comparison will be based on names, not Order
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837			Andy	01/10/2020	New!
###################################################################################################################
*/

BEGIN
	/*====================================== TESTING =======================================================================*/
	--DECLARE @New_Table_Name VARCHAR(200) = 'dbo.Fact_Violation', @Main_Table_Name VARCHAR(130) = 'dbo.Fact_TartSnapshot', @ComparisonResult VARCHAR(MAX) = 'ByName'
	/*====================================== TESTING =======================================================================*/

	DECLARE @Error VARCHAR(MAX) = '', @Params VARCHAR(100) = ISNULL(@ComparisonResult,'')  --, @LOG_SOURCE VARCHAR(200) = @Main_Table_Name, 
	--DECLARE @START_DATE DATETIME2 (3) = SYSDATETIME(), @LOG_MESSAGE VARCHAR(1000), @Trace_Flag BIT = 1 -- Testing

	SET @ComparisonResult = ''

	IF @Main_Table_Name IS NULL SET @Error = @Error + 'Main Table name cannot be NULL!' + CHAR(13)
	IF @New_Table_Name IS NULL SET @Error = @Error + 'New Table name cannot be NULL!' + CHAR(13)
	IF @Main_Table_Name = @New_Table_Name SET @Error = @Error + 'Don not compare the table with itself!'

	IF LEN(@Error) > 0
	BEGIN
		PRINT @Error
		SET @ComparisonResult = @Error
	END
	ELSE
	BEGIN
		DECLARE @Main_Schema VARCHAR(100), @Main_Table VARCHAR(200), @New_Schema VARCHAR(100), @New_Table VARCHAR(200)
		DECLARE @sql VARCHAR(MAX), @ByNames BIT = 0
		DECLARE @Dot INT = CHARINDEX('.',@Main_Table_Name)

		SELECT 
			@Main_Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Main_Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Main_Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Main_Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Main_Table_Name,@Dot + 1,200),'[',''),']','') END

		IF (@New_Table_Name IS NULL) OR (LEN(@New_Table_Name) = 0)
			SET @New_Table_Name = 'New.' + @Main_Table

		SET @Dot = CHARINDEX('.',@New_Table_Name)

		SELECT 
			@New_Schema = CASE WHEN @Dot = 0 THEN 'New' ELSE REPLACE(REPLACE(REPLACE(LEFT(@New_Table_Name,@Dot),'[',''),']',''),'.','') END,
			@New_Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@New_Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@New_Table_Name,@Dot + 1,200),'[',''),']','') END

		IF CHARINDEX('ByName',@Params) > 0
			SET @ByNames = 1


		;WITH CTE_New AS
		(
			SELECT 
				CAST(I.type_desc AS VARCHAR(22)) COLLATE Latin1_General_100_CI_AS_KS_WS AS IndexType
				, CAST(ISNULL(u.name,'-1') AS VARCHAR(100)) AS IndexColName
				, CAST(CASE WHEN C.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END AS VARCHAR(5)) AS IndexColOrder
				, CAST(pu.name AS VARCHAR(100)) AS PartitionColumn
				, CAST(p.distribution_policy_desc + CASE WHEN ISNULL(Dc.name, '') != '' THEN '(' + Dc.name + ')' ELSE '' END AS VARCHAR(100)) AS TableDistribution
				, ROW_NUMBER() OVER (ORDER BY C.key_ordinal) AS RN 
			FROM sys.Tables as t
			JOIN sys.schemas s ON t.schema_id = s.schema_id
			JOIN sys.indexes AS I ON I.object_id = t.object_id AND I.index_id <= 1
			LEFT JOIN sys.index_columns AS C ON C.object_id = t.object_id AND C.index_id = I.index_id AND C.key_ordinal > 0
			LEFT JOIN sys.columns AS u ON u.column_id = C.column_id AND u.object_id = t.object_id
			LEFT JOIN sys.partition_schemes	AS ps ON ps.data_space_id	= i.data_space_id  
			LEFT JOIN sys.index_columns		AS pc ON pc.[object_id]		= i.[object_id] AND pc.index_id = i.index_id AND pc.partition_ordinal >= 1 -- because 0 = non-partitioning column  
			LEFT JOIN sys.columns			AS pu  ON t.[object_id]		= pu.[object_id] AND pc.column_id = pu.column_id
			LEFT JOIN sys.pdw_Table_distribution_properties p  ON p.[object_id] = t.[object_id]
			LEFT JOIN sys.pdw_column_distribution_properties cd  ON cd.object_id = t.object_id AND cd.distribution_ordinal = 1 --AND p.column_id = cd.column_id
			LEFT JOIN sys.columns Dc ON Dc.object_id = t.object_id AND Dc.column_id = cd.column_id
			WHERE s.name = @New_Schema AND t.name = @New_Table
		)
		, CTE_NewParam AS
		(
			SELECT 
				CTE1.PartitionColumn, CTE1.TableDistribution, 
				CTE1.IndexType + 
					CASE WHEN CTE1.IndexType IN ('CLUSTERED COLUMNSTORE','NONCLUSTERED COLUMNSTORE','HEAP') 
						THEN '' 
						ELSE '(' + CTE1.IndexColName + CTE1.IndexColOrder
							+ ISNULL(','+ CTE2.IndexColName + CTE2.IndexColOrder, '')
							+ ISNULL(','+ CTE3.IndexColName + CTE3.IndexColOrder, '')
							+ ISNULL(','+ CTE4.IndexColName + CTE4.IndexColOrder, '')
							+ ISNULL(','+ CTE5.IndexColName + CTE5.IndexColOrder, '')
							+ ISNULL(','+ CTE6.IndexColName + CTE6.IndexColOrder, '')
							+ ISNULL(','+ CTE7.IndexColName + CTE7.IndexColOrder, '')
							+ ISNULL(','+ CTE8.IndexColName + CTE8.IndexColOrder, '')
							+ ISNULL(','+ CTE9.IndexColName + CTE9.IndexColOrder, '')
							+ ISNULL(','+ CTE10.IndexColName +CTE10.IndexColOrder, '') + ')' 
					END AS TableIndex
			FROM CTE_New AS CTE1
			LEFT JOIN CTE_New AS CTE2 ON  CTE2.RN = 2
			LEFT JOIN CTE_New AS CTE3 ON  CTE3.RN = 3
			LEFT JOIN CTE_New AS CTE4 ON  CTE4.RN = 4
			LEFT JOIN CTE_New AS CTE5 ON  CTE5.RN = 5
			LEFT JOIN CTE_New AS CTE6 ON  CTE6.RN = 6
			LEFT JOIN CTE_New AS CTE7 ON  CTE7.RN = 7
			LEFT JOIN CTE_New AS CTE8 ON  CTE8.RN = 8
			LEFT JOIN CTE_New AS CTE9 ON  CTE9.RN = 9
			LEFT JOIN CTE_New AS CTE10 ON CTE10.RN = 10
			WHERE CTE1.RN = 1
		)
		, CTE_Main AS
		(
			SELECT 
				CAST(I.type_desc AS VARCHAR(22)) COLLATE Latin1_General_100_CI_AS_KS_WS   AS IndexType
				, CAST(ISNULL(u.name,'-1') AS VARCHAR(100)) AS IndexColName
				, CAST(CASE WHEN C.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END AS VARCHAR(5)) AS IndexColOrder
				, CAST(pu.name AS VARCHAR(100)) AS PartitionColumn
				, CAST(p.distribution_policy_desc + CASE WHEN ISNULL(Dc.name, '') != '' THEN '(' + Dc.name + ')' ELSE '' END AS VARCHAR(100)) AS TableDistribution
				, ROW_NUMBER() OVER (ORDER BY C.key_ordinal) AS RN 
			FROM sys.Tables as t
			JOIN sys.schemas s ON t.schema_id = s.schema_id
			JOIN sys.indexes AS I ON I.object_id = t.object_id AND I.index_id <= 1
			LEFT JOIN sys.index_columns AS C ON C.object_id = t.object_id AND C.index_id = I.index_id AND C.key_ordinal > 0
			LEFT JOIN sys.columns AS u ON u.column_id = C.column_id AND u.object_id = t.object_id
			LEFT JOIN sys.partition_schemes	AS ps ON ps.data_space_id	= i.data_space_id  
			LEFT JOIN sys.index_columns		AS pc ON pc.[object_id]		= i.[object_id] AND pc.index_id = i.index_id AND pc.partition_ordinal >= 1 -- because 0 = non-partitioning column  
			LEFT JOIN sys.columns			AS pu  ON t.[object_id]		= pu.[object_id] AND pc.column_id = pu.column_id
			LEFT JOIN sys.pdw_Table_distribution_properties p  ON p.[object_id] = t.[object_id]
			LEFT JOIN sys.pdw_column_distribution_properties cd  ON cd.object_id = t.object_id AND cd.distribution_ordinal = 1 --AND p.column_id = cd.column_id
			LEFT JOIN sys.columns Dc ON Dc.object_id = t.object_id AND Dc.column_id = cd.column_id
			WHERE s.name = @Main_Schema AND t.name = @Main_Table  --t.name = 'Fact_TartAsOfDate' AND s.name = 'dbo'
		)
		, CTE_MainParam AS
		(
			SELECT 
				CTE1.PartitionColumn, CTE1.TableDistribution, 
				CTE1.IndexType + 
					CASE WHEN CTE1.IndexType IN ('CLUSTERED COLUMNSTORE','NONCLUSTERED COLUMNSTORE','HEAP') 
						THEN '' 
						ELSE '(' + CTE1.IndexColName + CTE1.IndexColOrder
							+ ISNULL(','+ CTE2.IndexColName + CTE2.IndexColOrder, '')
							+ ISNULL(','+ CTE3.IndexColName + CTE3.IndexColOrder, '')
							+ ISNULL(','+ CTE4.IndexColName + CTE4.IndexColOrder, '')
							+ ISNULL(','+ CTE5.IndexColName + CTE5.IndexColOrder, '')
							+ ISNULL(','+ CTE6.IndexColName + CTE6.IndexColOrder, '')
							+ ISNULL(','+ CTE7.IndexColName + CTE7.IndexColOrder, '')
							+ ISNULL(','+ CTE8.IndexColName + CTE8.IndexColOrder, '')
							+ ISNULL(','+ CTE9.IndexColName + CTE9.IndexColOrder, '')
							+ ISNULL(','+ CTE10.IndexColName +CTE10.IndexColOrder, '') + ')' 
					END AS TableIndex
			FROM CTE_Main AS CTE1
			LEFT JOIN CTE_Main AS CTE2 ON  CTE2.RN = 2
			LEFT JOIN CTE_Main AS CTE3 ON  CTE3.RN = 3
			LEFT JOIN CTE_Main AS CTE4 ON  CTE4.RN = 4
			LEFT JOIN CTE_Main AS CTE5 ON  CTE5.RN = 5
			LEFT JOIN CTE_Main AS CTE6 ON  CTE6.RN = 6
			LEFT JOIN CTE_Main AS CTE7 ON  CTE7.RN = 7
			LEFT JOIN CTE_Main AS CTE8 ON  CTE8.RN = 8
			LEFT JOIN CTE_Main AS CTE9 ON  CTE9.RN = 9
			LEFT JOIN CTE_Main AS CTE10 ON CTE10.RN = 10
			WHERE CTE1.RN = 1
		)
		SELECT
			@ComparisonResult = CASE WHEN M.PartitionColumn <> N.PartitionColumn THEN 'Partition: ' + M.PartitionColumn + ' <> ' + N.PartitionColumn + '; ' + CHAR(13) ELSE '' END
			+ CASE WHEN M.TableDistribution <> N.TableDistribution THEN 'Distribution: ' + M.TableDistribution + ' <> ' + N.TableDistribution + '; ' + CHAR(13) ELSE '' END
			+ CASE WHEN M.TableIndex <> N.TableIndex THEN 'Index: ' + M.TableIndex + ' <> ' + N.TableIndex + ';' + CHAR(13) ELSE '' END 
		FROM CTE_MainParam M
		JOIN CTE_NewParam N ON NOT (N.PartitionColumn = M.PartitionColumn AND N.TableDistribution = M.TableDistribution AND N.TableIndex = M.TableIndex)

		IF OBJECT_ID('tempdb..#TableColums') IS NOT NULL DROP Table #TableColums;
		CREATE Table #TableColums WITH (HEAP, DISTRIBUTION = Replicate) AS 
		WITH CTE_New AS
		(
			SELECT      c.name AS ColumnName, C.column_id, TYPE_NAME(c.system_type_id) AS ColumnType, c.max_length, c.PRECISION,c.scale, C.is_nullable,collation_name, 
						ROW_NUMBER() OVER(ORDER BY C.column_id) AS Column_Number
						-- SELECT *
			FROM        sys.columns c
			JOIN        sys.Tables  t   ON c.object_id = t.object_id
			JOIN		sys.schemas s ON t.schema_id = s.schema_id
			WHERE s.name = @New_Schema AND t.name = @New_Table
			--WHERE t.name = 'Fact_TartAsOfDate' AND s.name = 'dbo'
		)
		, CTE_ColumnNew AS
		(
			SELECT 
				--Column_Number,
				CASE WHEN @ByNames = 1 THEN ColumnName ELSE CAST(Column_Number AS VARCHAR(3)) END AS Identifier,
				CASE WHEN @ByNames = 1 THEN '' ELSE '[' + ColumnName + '] ' END + ColumnType + -- When we compare by name - name as alredy there and we don't need to add it to Description
					CASE 
						WHEN ColumnType = 'DATETIME2' THEN '(' + CAST(scale AS VARCHAR(1)) +')'
						WHEN ColumnType IN ('BINARY','VARBINARY') THEN '(' + ISNULL(NULLIF(CAST(max_length AS VARCHAR(4)),'-1'),'MAX') +')'
						WHEN ColumnType IN ('DECIMAL','NUMERIC') THEN '(' + CAST(PRECISION AS VARCHAR(2)) + ', ' + CAST(scale AS VARCHAR(2)) +')'
						WHEN ColumnType LIKE '%CHAR' AND LEFT(ColumnType,1) = 'N' THEN '(' + ISNULL(CAST(NULLIF(max_length, -1) / 2 AS VARCHAR(4)),'MAX') +') COLLATE ' + collation_name
						WHEN ColumnType LIKE '%CHAR' AND LEFT(ColumnType,1) != 'N' THEN '(' + ISNULL(NULLIF(CAST(max_length AS VARCHAR(4)),'-1'),'MAX') +') COLLATE ' + collation_name
						ELSE ''
					END +
					CASE
						WHEN is_nullable = 1 THEN ' NULL'
						ELSE ' NOT NULL'
					END AS ColumnDesc
			FROM CTE_New M
		)
		, CTE_Main AS
		(
			SELECT      c.name AS ColumnName, C.column_id, TYPE_NAME(c.system_type_id) AS ColumnType, c.max_length, c.PRECISION ,c.scale, C.is_nullable,collation_name, 
						ROW_NUMBER() OVER(ORDER BY C.column_id) AS Column_Number
			FROM        sys.columns c
			JOIN        sys.Tables  t   ON c.object_id = t.object_id
			JOIN		sys.schemas s ON t.schema_id = s.schema_id
			WHERE s.name = @Main_Schema AND t.name = @Main_Table  
		)
		, CTE_ColumnMain AS
		(
			SELECT 
				--Column_Number,
				CASE WHEN @ByNames = 1 THEN ColumnName ELSE CAST(Column_Number AS VARCHAR(3)) END AS Identifier,
				CASE WHEN @ByNames = 1 THEN '' ELSE '[' + ColumnName + '] ' END + ColumnType + 
					CASE 
						WHEN ColumnType = 'DATETIME2' THEN '(' + CAST(scale AS VARCHAR(1)) +')'
						WHEN ColumnType IN ('BINARY','VARBINARY') THEN '(' + ISNULL(NULLIF(CAST(max_length AS VARCHAR(4)),'-1'),'MAX') +')'
						WHEN ColumnType IN ('DECIMAL','NUMERIC') THEN '(' + CAST(PRECISION AS VARCHAR(2)) + ', ' + CAST(scale AS VARCHAR(2)) +')'
						WHEN ColumnType LIKE '%CHAR' AND LEFT(ColumnType,1) = 'N' THEN '(' + ISNULL(CAST(NULLIF(max_length, -1) / 2 AS VARCHAR(4)),'MAX') +') COLLATE ' + collation_name
						WHEN ColumnType LIKE '%CHAR' AND LEFT(ColumnType,1) != 'N' THEN '(' + ISNULL(NULLIF(CAST(max_length AS VARCHAR(4)),'-1'),'MAX') +') COLLATE ' + collation_name
						ELSE ''
					END +
					CASE
						WHEN is_nullable = 1 THEN ' NULL'
						ELSE ' NOT NULL'
					END AS ColumnDesc
			FROM CTE_Main M
		)
		, CTE_Difference AS
		(
			SELECT 
				--ISNULL(M.Column_Number,N.Column_Number) AS Column_Number, 
				ISNULL(M.Identifier,N.Identifier) AS Identifier, 
				ISNULL(N.ColumnDesc,'') AS NewDesc, 
				ISNULL(M.ColumnDesc,'') AS MainDesc, 
				CASE WHEN N.ColumnDesc = M.ColumnDesc THEN 1 ELSE 0 END AS EqualFlag
			FROM CTE_ColumnMain AS M
			FULL OUTER JOIN CTE_ColumnNew AS N ON M.Identifier = N.Identifier 
		)
		SELECT 
			Identifier,
			MainDesc AS OldType,
			NewDesc AS NewType,
			CASE 
				WHEN NewDesc = '' THEN 'Deleted'
				WHEN MainDesc = '' THEN 'Added'
				ELSE 'Changed' 
			END AS [Action],
			'Column ' + Identifier + ': ' + 
			CASE 
				WHEN NewDesc = '' THEN MainDesc + ' DELETED;' + CHAR(13)
				WHEN MainDesc = '' THEN NewDesc + ' ADDED;' + CHAR(13)
				ELSE MainDesc + ' -=> ' + NewDesc + ';' + CHAR(13) 
			END AS ColumnDiff
			, ROW_NUMBER() OVER(ORDER BY Identifier) AS RN
		FROM CTE_Difference
		WHERE EqualFlag = 0

		SELECT Identifier,OldType,NewType,[Action] FROM #TableColums-- this needed for Developer to copy to Excel
		ORDER BY RN

		DECLARE @Indicat SMALLINT = 1, @ColumnDiff VARCHAR(200) = '', @NunOfColumns INT
		SELECT @NunOfColumns = MAX(RN) FROM #TableColums

		WHILE (@Indicat <= @NunOfColumns)
		BEGIN
			SELECT @ColumnDiff = ColumnDiff
			FROM #TableColums M
			WHERE M.RN = @Indicat

			SET @ComparisonResult = @ComparisonResult + @ColumnDiff
			SET @Indicat += 1
		END

		IF CHARINDEX('No[]',@Params) > 0
			SET @ComparisonResult = REPLACE(REPLACE(@ComparisonResult,'[',''),']','')

		IF CHARINDEX('NoPrint',@Params) = 0
		BEGIN
			IF @ComparisonResult = ''
				PRINT 'Tables identical'
			ELSE
				EXEC Utility.LongPrint @ComparisonResult
		END
	END
END

