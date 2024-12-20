CREATE PROC [Utility].[Get_DropTablesByFilter_SQL] @Filter_In_SQL_Out [VARCHAR](MAX) OUT AS
/*
IF OBJECT_ID ('Utility.Get_DropTablesByFilter_SQL', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_DropTablesByFilter_SQL
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Filter_In_SQL_Out VARCHAR(MAX) = 'Schema:(tollPlus,TER);Table:%_OLD;No[]'
EXEC Utility.Get_DropTablesByFilter_SQL @Filter_In_SQL_Out OUTPUT 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning SQL statement for droping tables by filter

@Filter_In_SQL_Out - Param to return SQL statement. Can take some secondary parameters
	can include values: 	'Schema:List of schemas in () comma separeted or LIKE string;Table:List of tables comma separeted or LIKE string;No[];NoPrint'
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0038319 	Andy		2021-03-08	New!
###################################################################################################################
*/


BEGIN
	/*====================================== TESTING =======================================================================*/
	--DECLARE @Filter_In_SQL_Out VARCHAR(MAX) = 'Table:%_OLD'
	/*====================================== TESTING =======================================================================*/

	SET NOCOUNT ON
	DECLARE @Error VARCHAR(MAX) = ''
	DECLARE @Filter VARCHAR(100) = ISNULL(@Filter_In_SQL_Out,'')
	SET @Filter_In_SQL_Out = '';
	IF @Filter IS NULL SET @Error = @Error + 'Table filter cannot be empty'
	IF LEN(@Error) > 0
		PRINT @Error
	ELSE
	BEGIN

		DECLARE @SchemaFilterAll VARCHAR(1000) = '', @SchemaFilterIn VARCHAR(1000) = '', @SchemaFilterLike VARCHAR(1000) = ''
		DECLARE @TableFilterAll VARCHAR(1000) = '', @TableFilterIn VARCHAR(1000) = '', @TableFilterLike VARCHAR(1000) = ''
		DECLARE @NunOfColumns INT, @Index INT
		SET @Filter = REPLACE(REPLACE(@Filter,' ',''),'	','')
		SELECT @Index = ISNULL(CHARINDEX('Schema:',@Filter),0)
		IF @Index > 0 -- In this brackets only the table name can be we need to put in AS
		BEGIN
			SET @SchemaFilterAll = SUBSTRING(@Filter,CHARINDEX(':',@Filter,@Index) + 1, ISNULL(NULLIF(CHARINDEX(';',@Filter,@Index),0), LEN(@Filter) + 1) - CHARINDEX(':',@Filter,@Index) - 1)
			--SET @Filter = REPLACE(@Filter,'Schema:' + @SchemaFilterAll,'')  -- If table include somehow one of the key word (like table) - we have to remove it
			IF CHARINDEX('(',@SchemaFilterAll) > 0 -- Than it's a list - we take it all 
				SET @SchemaFilterIn = REPLACE(REPLACE(@SchemaFilterAll,'''',''),',',')(');
			ELSE
				SET @SchemaFilterLike = REPLACE(@SchemaFilterAll,'''','')
		END

		SELECT @Index = ISNULL(CHARINDEX('Table:',@Filter),0)
		IF @Index > 0 -- In this brackets only the table name can be we need to put in AS
		BEGIN
			SET @TableFilterAll = SUBSTRING(@Filter,CHARINDEX(':',@Filter,@Index) + 1, ISNULL(NULLIF(CHARINDEX(';',@Filter,@Index),0), LEN(@Filter) + 1) - CHARINDEX(':',@Filter,@Index) - 1)
			--SET @Filter = REPLACE(@Filter,'Table:' + @TableFilterAll,'')  -- If table include somehow one of the key word (like table) - we have to remove it

			IF CHARINDEX('(',@TableFilterAll) > 0 -- Than it's a list - we take it all 
				SET @TableFilterIn = REPLACE(REPLACE(@TableFilterAll,'''',''),',',')(');
			ELSE
				SET @TableFilterLike = REPLACE(@TableFilterAll,'''','')
		END

		IF OBJECT_ID('tempdb..#TableList') IS NOT NULL DROP Table #TableList;
		CREATE TABLE #TableList WITH (HEAP, DISTRIBUTION = Replicate) AS 
		WITH CTE AS
		(
			SELECT      s.name AS SchemaName, t.name AS TableName 
			FROM        sys.Tables  t
			JOIN		sys.schemas s ON t.schema_id = s.schema_id
		)
		SELECT SchemaName, TableName, ROW_NUMBER() OVER(ORDER BY SchemaName, TableName) AS RN
		FROM CTE 
		WHERE	(@SchemaFilterIn LIKE '%(' + SchemaName + ')%' OR @SchemaFilterIn = '')
			AND	(SchemaName LIKE @SchemaFilterLike OR @SchemaFilterLike = '')
			AND	(@TableFilterIn LIKE '%(' + TableName + ')%' OR @TableFilterIn = '')
			AND	(TableName LIKE @TableFilterLike OR @TableFilterLike = '')
		
		SELECT @NunOfColumns = MAX(RN) FROM #TableList

		DECLARE @Indicat SMALLINT = 1
		DECLARE @SELECT_String VARCHAR(MAX) = ''

		WHILE (@Indicat <= @NunOfColumns)
		BEGIN
			SELECT @SELECT_String = 'IF OBJECT_ID(''[' + M.SchemaName + '].[' + M.TableName + ']'') IS NOT NULL DROP Table [' + M.SchemaName + '].[' + M.TableName + ']'
			FROM #TableList M
			WHERE M.RN = @Indicat

			SET @Filter_In_SQL_Out = @Filter_In_SQL_Out + CHAR(13) + CHAR(10) + CHAR(9) + @SELECT_String
			SET @Indicat += 1
		END

		IF CHARINDEX('No[]',@Filter) > 0
			SET @Filter_In_SQL_Out = REPLACE(REPLACE(@Filter_In_SQL_Out,'[',''),']','')

		IF CHARINDEX('NoPrint',@Filter) = 0
			EXEC Utility.LongPrint @Filter_In_SQL_Out
	END
END





