CREATE PROC [Utility].[CreateStageTables] @TableList [VARCHAR](4000) AS

/*
USE LND_TBOS 
GO
IF OBJECT_ID ('Utility.CreateStageTables', 'P') IS NOT NULL DROP PROCEDURE Utility.CreateStageTables
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.CreateStageTables '' 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating epmty Stage tables for tables in the list (or for all active tables) from the table Utility.TableLoadParameters
New tables have the same Columns, Indexes, Distribution and Partition. Statistics is not included.

@TableList - List of the tables, separated by comma. Should include Schema. Could be empty or NULL (means all tables)
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
###################################################################################################################
*/
BEGIN

	DECLARE @Indicat SMALLINT = 1, @Table_DISTRIBUTION VARCHAR(100), @SQL VARCHAR(MAX) = 'NoPrint', @FullName VARCHAR(130), @StageTableName VARCHAR(130), @NunOfColumns SMALLINT

	IF @TableList IS NULL SET @TableList = ''
	SET @TableList = REPLACE(REPLACE(@TableList,'[',''),']','')

	IF OBJECT_ID('tempdb..#TableColums') IS NOT NULL DROP Table #TableColums;
	CREATE Table #TableColums WITH (HEAP, DISTRIBUTION = Replicate) AS 
	SELECT FullName,TableName, StageTableName, ROW_NUMBER() OVER(ORDER BY TableID) AS RN
	FROM Utility.TableLoadParameters
	WHERE (@TableList = '' OR @TableList LIKE '%' + FullName + '%') --AND Active = 1
	--WHERE TableName = 'Courts'

	SELECT @NunOfColumns = MAX(RN) FROM #TableColums

	WHILE (@Indicat <= @NunOfColumns)
	BEGIN

		SELECT @StageTableName = StageTableName, @FullName = FullName
		FROM #TableColums M
		WHERE M.RN = @Indicat
		
		EXEC Utility.Get_CreateEmptyCopy_SQL @FullName, @StageTableName, @SQL OUTPUT 

		/* 
		--Decided not to go with this version (stage table with no Index and Partitions):
		--SET @StageTableName = Utility.uf_TitleCase(@StageTableName)
		--SET @Table_DISTRIBUTION = 'NoPrint'
		--EXEC Utility.Get_Distribution_String @FullName, @Table_DISTRIBUTION OUTPUT 
		---- First we have to drop existing table
		--SET @SQL = CHAR(13) + 'IF OBJECT_ID(''' + @StageTableName + ''',''U'') IS NOT NULL			DROP TABLE ' + @StageTableName + ';' 
		--SET @SQL = @SQL + CHAR(13) + 'CREATE TABLE ' + @StageTableName + ' WITH (HEAP, ' + @Table_DISTRIBUTION + ') AS' + CHAR(13) + 'SELECT *' + CHAR(13) + 'FROM ' + @FullName + CHAR(13) + 'WHERE 1 = 2'
		*/

		EXEC (@SQL)

		SET @Indicat += 1
	END

END
