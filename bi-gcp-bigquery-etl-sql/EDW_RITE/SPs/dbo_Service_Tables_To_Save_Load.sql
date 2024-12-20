CREATE PROC [DBO].[Service_Tables_To_Save_Load] AS
/*
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.Service_Tables_To_Save_Load') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.Service_Tables_To_Save_Load
GO

EXEC DBO.Service_Tables_To_Save_Load

SELECT * FROM dbo.Service_Tables_To_Save
where SAVE_TABLE is null

*/

DECLARE @TABLE_NAME VARCHAR(100)
DECLARE @Schema_name VARCHAR(100)
DECLARE @LAST_UPDATE_DATE VARCHAR(100)

IF OBJECT_ID('tempdb..#TABLE_COLUMNS') IS NOT NULL DROP TABLE #TABLE_COLUMNS;
SELECT      
	S.name AS [Schema_name], t.name AS Table_Name, c.name AS LAST_UPDATE_DATE
	, ROW_NUMBER() OVER (ORDER BY t.name) RN
	INTO #TABLE_COLUMNS
FROM        sys.tables  t
JOIN		sys.schemas S	ON S.schema_id = t.schema_id
LEFT JOIN   sys.columns c  ON c.object_id = t.object_id AND c.name = 'LAST_UPDATE_DATE'
LEFT JOIN EDW_RITE.dbo.Service_Tables_To_Save AS a ON a.[SCHEMA_NAME] = S.name AND a.TABLE_NAME = t.name
WHERE       a.TABLE_NAME IS NULL


DECLARE @NUM_OF_COLUMNS INT
SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #TABLE_COLUMNS
DECLARE @INDICAT SMALLINT = 1
DECLARE @Delimiter VARCHAR(3) = ''
DECLARE @SELECT_String VARCHAR(MAX) = ''
-- If only 1 period (and 1 partition) - @PART_RANGES is empty
DECLARE @SQL_INSERT VARCHAR(MAX) = '' 
DECLARE @REFERENCES VARCHAR(10)

WHILE (@INDICAT <= @NUM_OF_COLUMNS)
BEGIN
	
	SELECT @TABLE_NAME = TABLE_NAME, @Schema_name = [Schema_name], @LAST_UPDATE_DATE = LAST_UPDATE_DATE 
	FROM #TABLE_COLUMNS WHERE RN = @INDICAT

	SELECT @REFERENCES = CAST(COUNT(1) AS VARCHAR(10))
	FROM SYS.PROCEDURES AS PR
	JOIN SYS.SQL_MODULES AS MODU ON PR.OBJECT_ID = MODU.OBJECT_ID
	WHERE UPPER(MODU.DEFINITION) LIKE '%' + @TABLE_NAME + '%' 

	SET @SQL_INSERT = '
	INSERT INTO EDW_RITE.dbo.Service_Tables_To_Save
	SELECT 
		''' + @SCHEMA_NAME + ''' AS [SCHEMA_NAME], 
		''' + @TABLE_NAME + ''' AS TABLE_NAME, 
		COUNT_BIG(1) AS Row_Count, 
		[REFERENCES] = ' + @REFERENCES + ',
		LAST_UPDATE_DATE = ' + CASE WHEN @LAST_UPDATE_DATE IS NULL THEN ' NULL ' ELSE ' MAX(LAST_UPDATE_DATE)' END + ',
		[SAVE_TABLE] = NULL,
		[MOVE_BEFORE] = NULL,
		[DONE] = NULL
	FROM EDW_RITE.[' + @SCHEMA_NAME + '].[' + @TABLE_NAME + '];'

	EXEC(@SQL_INSERT)

	SET @INDICAT += 1

END

/*
UPDATE EDW_RITE.dbo.Service_Tables_To_Sav
SET SAVE_TABLE = 0
WHERE Row_Count = 0

UPDATE EDW_RITE.dbo.Service_Tables_To_Sav
SET SAVE_TABLE = 0
WHERE SCHEMA_NAME = 'stage'

UPDATE EDW_RITE.dbo.Service_Tables_To_Sav
SET SAVE_TABLE = 0
WHERE TABLE_NAME LIKE '%_STAGE'
*/
