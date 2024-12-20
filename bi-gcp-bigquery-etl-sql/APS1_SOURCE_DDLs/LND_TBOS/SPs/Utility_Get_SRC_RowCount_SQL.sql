CREATE PROC [Utility].[Get_SRC_RowCount_SQL] @DatabaseName [VARCHAR](50) AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Return SQL script to get Daily Row Count from Source tables
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0038211		Shankar		2021-01-18	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.Get_SRC_RowCount_SQL @DatabaseName = 'TBOS'

SELECT 'Stage.SRC_DailyRowCount' TableName, * FROM Stage.SRC_DailyRowCount ORDER BY 2,3,4 DESC
###################################################################################################################
*/

BEGIN

	--:: Debug
	--DECLARE @DatabaseName VARCHAR(50) = 'TBOS' 

	DECLARE @Counter SMALLINT = 1, @SRC_RowCount_SQL VARCHAR(MAX) = '', @SRC_RowCount_SQL_Line VARCHAR(1000), @TablesCount SMALLINT, @SRC_SQL VARCHAR(MAX)
		
	--::==================================================================================================
	--:: Daily RowCount script: Compare Daily row counts by CreatedDate for each CDC table 
	--::==================================================================================================

	IF OBJECT_ID('tempdb..#RowCounts_SQL') IS NOT NULL DROP Table #RowCounts_SQL;
	CREATE Table #RowCounts_SQL WITH (HEAP, DISTRIBUTION = Replicate) AS 
	SELECT	ROW_NUMBER() OVER (ORDER BY DataBaseName,FullName) RN, 
			'SELECT ''' + DataBaseName + ''' DataBaseName,''' + FullName + ''' TableName, ' + 
			CASE WHEN FullName <> 'EIP.Results_Log' THEN 'CAST(CreatedDate AS DATE)'   
			ELSE 'CAST(ISNULL(EIPReceivedDate,EIPCompletedDate) AS DATE)' END + ' AS CreatedDate, ' + 
			'COUNT_BIG(1) SourceRowCount, CAST(SYSDATETIME() AS DATETIME2(3)) AS LND_UpdateDate' + CHAR(10) + 
			'FROM	' + DataBaseName + '.' + FullName + ' (NOLOCK)' + CHAR(10) +  
			'GROUP BY ' + CASE WHEN FullName <> 'EIP.Results_Log' THEN 'CAST(CreatedDate AS DATE)'	ELSE 'CAST(ISNULL(EIPReceivedDate,EIPCompletedDate) AS DATE)' END +  CHAR(10) + 
			'UNION ALL' + CHAR(10) AS SQL_Line    
	FROM Utility.TableLoadParameters
	WHERE Active = 1 AND CDCFlag = 1
	AND DatabaseName= @DatabaseName

	SELECT @TablesCount = MAX(RN) FROM #RowCounts_SQL
	SET @SRC_RowCount_SQL = ''

	WHILE (@Counter <= @TablesCount)
	BEGIN

		SELECT @SRC_RowCount_SQL_Line = SQL_Line 
		FROM #RowCounts_SQL M
		WHERE M.RN = @Counter

		SET @SRC_RowCount_SQL = @SRC_RowCount_SQL + CASE WHEN @Counter = @TablesCount THEN REPLACE(@SRC_RowCount_SQL_Line,'UNION ALL','') ELSE @SRC_RowCount_SQL_Line END

		SET @Counter += 1
	END

	EXEC Utility.LongPrint @SRC_RowCount_SQL

END

/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
DECLARE @SRC_RowCount_SQL VARCHAR(MAX)
EXEC Utility.Get_SRC_RowCount_SQL @DatabaseName = 'TBOS'

SELECT TOP 1000 'Stage.SRC_DailyRowCount' TableName, * FROM Stage.SRC_DailyRowCount ORDER BY 2,3,4 DESC
*/


