CREATE PROC [dbo].[DropStats] @TableName [varchar](255) AS
BEGIN 

-- DECLARE @TableName varchar(255) = 'ViolatorStatus'

	IF OBJECT_ID('tempdb..#TEMP')<>0
		DROP TABLE #TEMP

	CREATE TABLE #TEMP
	(
		ROWCOUNTER		int,
		[SCHEMA_NAME] varchar(255) ,
		TABLE_NAME varchar(255),
		STAT_NAME varchar(255)
	) WITH (LOCATION = USER_DB)

--	SELECT ORDINAL_POSITION, COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ViolatorStatus'  and DATA_TYPE like '%date%'  ORDER BY ORDINAL_POSITION -- 

	INSERT INTO #TEMP
	select ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS ROWCOUNTER, sc.name, so.name, ss.name
	FROM sys.stats ss
	INNER JOIN sys.objects so on ss.object_id = so.object_id
	INNER JOIN sys.schemas sc on sc.schema_id = so.schema_id
	WHERE so.name = @TableName and ss.user_created = 1
	
	DECLARE @x INT = 0
	DECLARE @Str varchar(8000) = ''

	DECLARE @xMax int = ISNULL((SELECT  MAX(ROWCOUNTER)+1 FROM #TEMP),0);

	WHILE @x < @xMax
	BEGIN
		SET @x = @x + 1

--		IF (SELECT DATA_TYPE FROM #TEMP WHERE ORDINAL_POSITION = @x) in ('date','datetime','datetime2')
			SET @Str = @Str + 
					(SELECT 'DROP STATISTICS [' + [SCHEMA_NAME] + '].[' + TABLE_NAME + '].' + STAT_NAME  FROM #TEMP WHERE ROWCOUNTER = @x)

		--PRINT @Str
		EXEC(@Str)
		SET @Str = ''

	END

END
