CREATE PROC [Utility].[CompareTablesInSource] @DataBases [VARCHAR](100) AS
/*
USE LND_TBOS
GO
IF OBJECT_ID ('Utility.CompareTablesInSource', 'P') IS NOT NULL DROP PROCEDURE Utility.CompareTablesInSource
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.CompareTablesInSource 'TBOS,IPS,DMV'
SELECT * FROM Utility.TBOS_TableMetadata ORDER BY 1 DESC
-------------------------------------------------------------------------------------------------------------------
Purpose: Comparing Data on Soucre for any changes and shows them. 
-------------------------------------------------------------------------------------------------------------------
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837	Andy 		2020-08-20	New!
###################################################################################################################
*/

BEGIN

	/* RUN ON APS from Data Manager */
	IF OBJECT_ID('Tempdb..#DatabasesChanges') IS NOT NULL DROP TABLE #DatabasesChanges;
	CREATE TABLE #DatabasesChanges
	WITH (HEAP,DISTRIBUTION=REPLICATE) AS
	WITH CTE_LIST AS
	(
		SELECT 
			ISNULL(S.FullName,T.FullName) AS FullName,
			ISNULL(S.ColumnName,T.ColumnName) AS ColumnName,
			ISNULL(S.ColumnID,T.ColumnID) AS ColumnID,
			ISNULL(S.FullName,'') AS S_FullName,
			ISNULL('[' + REPLACE(S.ColumnName,'ReplaceErrorCode','ErrorCode') + ']','') AS S_ColumnName,
			ISNULL(S.IndexColumns,'') S_IndexColumns,
			ISNULL(S.ColumnType,'') S_ColumnType,
			CASE ISNULL(S.ColumnNullable, -1) WHEN -1 THEN 'non' WHEN 1 THEN 'NULL' ELSE 'NOT NULL' END S_ColumnNullable,
			ISNULL(T.FullName,'') AS T_FullName,
			ISNULL('[' + REPLACE(T.ColumnName,'ReplaceErrorCode','ErrorCode') + ']','') AS T_ColumnName,
			--ISNULL(S.ColumnID,0) AS S_ColumnID,
			--ISNULL(T.ColumnID,0) AS T_ColumnID,
			ISNULL(T.IndexColumns,'') T_IndexColumns,
			ISNULL(T.ColumnType,'') AS T_ColumnType,
			CASE WHEN ISNULL(T.ColumnNullable,S.ColumnNullable) = 1 THEN 'NULL' ELSE 'NOT NULL' END T_ColumnNullable
		FROM (SELECT * FROM Utility.TBOS_TableMetadata_Source WHERE DataBaseName IN ('IPS','DMV','TBOS') AND ColumnName NOT IN ('LND_UpdateDate','LND_UpdateType')) S -- This is database to compare with
		FULL OUTER JOIN (SELECT * FROM Utility.TBOS_TableMetadata WHERE DataBaseName IN ('IPS','DMV','TBOS') AND ColumnName NOT IN ('LND_UpdateDate','LND_UpdateType')) T -- This is my TBOS temp database
			ON T.FullName = S.FullName AND T.ColumnName = S.ColumnName AND T.DataBaseName = S.DataBaseName
	)
	, CTE_TABLE AS
	(
		SELECT
			ISNULL(S.FullName,T.FullName) AS FullName,
			'' AS ColumnName,
			0 AS ColumnID,
			CASE 
				WHEN T_FullName IS NULL THEN 'New table' 
				WHEN S_FullName IS NULL THEN 'Deleted Table' 
				WHEN T_IndexColumns <> S_IndexColumns AND T_IndexColumns = '' THEN 'New Index: (' + S_IndexColumns + ')'
				WHEN T_IndexColumns <> S_IndexColumns AND S_IndexColumns = '' THEN 'Index Deleted: (' + T_IndexColumns + ')'
				WHEN T_IndexColumns <> S_IndexColumns THEN 'Index changed: (' + T_IndexColumns + ') --> (' + S_IndexColumns + ')'
				ELSE NULL 
			END AS TableChanges
		FROM (SELECT FullName, S_FullName, S_IndexColumns FROM  CTE_LIST WHERE S_FullName <> '' GROUP BY FullName, S_FullName, S_IndexColumns) S
		FULL OUTER JOIN (SELECT FullName, T_FullName, T_IndexColumns FROM  CTE_LIST WHERE T_FullName <> '' GROUP BY FullName, T_FullName, T_IndexColumns) T ON T.FullName = S.FullName
	)
	, CTE_COLUMNS AS
	(
		SELECT
			FullName,
			ColumnName,
			ColumnID,
			CASE 
				WHEN T_ColumnType = '' THEN 'New Column: ' + S_ColumnName + ' ' + S_ColumnType + ' ' + S_ColumnNullable
				WHEN S_ColumnName = '' THEN 'Deleted column: ' + T_ColumnName + '' + T_ColumnType + ' ' + T_ColumnNullable
				WHEN S_ColumnType <> T_ColumnType AND S_ColumnNullable = T_ColumnNullable THEN 'Column ' + S_ColumnName + ' Type changed: ' + T_ColumnType + ' --> ' + S_ColumnType
				WHEN S_ColumnType = T_ColumnType AND S_ColumnNullable <> T_ColumnNullable THEN 'Column ' + S_ColumnName + ' Null changed: ' + T_ColumnNullable + ' --> ' + S_ColumnNullable
				ELSE 'Column ' + S_ColumnName + ' changed: ' + T_ColumnType + ' ' + T_ColumnNullable + ' --> ' + S_ColumnType + ' ' + S_ColumnNullable 
			END AS TableChanges
		FROM CTE_LIST
		WHERE S_ColumnType <> T_ColumnType OR S_ColumnNullable <> T_ColumnNullable
	)
	SELECT
		FullName,
		ColumnName,
		ColumnID,
		TableChanges
	FROM CTE_TABLE WHERE TableChanges IS NOT NULL
	UNION ALL
	SELECT
		FullName,
		ColumnName,
		ColumnID,
		TableChanges
	FROM CTE_COLUMNS
	WHERE FullName NOT IN (SELECT FullName FROM CTE_TABLE WHERE TableChanges IN ('New table','Deleted Table'))
	--ORDER BY FullName,ColumnID


END



--DELETE FROM Utility.TBOS_TableMetadata
--WHERE DataBaseName IN ('TBOS')

