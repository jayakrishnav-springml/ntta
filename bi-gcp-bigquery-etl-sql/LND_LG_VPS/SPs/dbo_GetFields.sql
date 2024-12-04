CREATE PROC [dbo].[GetFields] @SchemaName [varchar](255),@TableName [varchar](255) AS
BEGIN 

	IF OBJECT_ID('tempdb..#TEMP')<>0
		DROP TABLE #TEMP

	CREATE TABLE #TEMP
	(
		ORDINAL_POSITION int ,
		COLUMN_NAME varchar(255)
	) WITH (LOCATION = USER_DB)



	INSERT INTO #TEMP
	SELECT ORDINAL_POSITION, COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @TableName -- ORDER BY ORDINAL_POSITION

	DECLARE @x INT = 1
	DECLARE @Str varchar(8000) = ''

	DECLARE @xMax int = ISNULL((SELECT  MAX(ORDINAL_POSITION)+1 FROM #TEMP),0);

	WHILE @x < @xMax
	BEGIN
		SET @Str = @Str + (SELECT ', ' + COLUMN_NAME FROM #TEMP WHERE ORDINAL_POSITION = @x)
		SET @x = @x + 1
	END

	SELECT RIGHT(@Str, LEN(@Str)-1)

END;


