CREATE PROC [dbo].[CreateStats] @SchemaName [varchar](255),@TableName [varchar](255) AS
BEGIN 

--	DECLARE @TableName varchar(255) = 'DIM_DATE'

	IF OBJECT_ID('tempdb..#TEMP')<>0
		DROP TABLE #TEMP

	CREATE TABLE #TEMP
	(
		ORDINAL_POSITION int ,
		COLUMN_NAME varchar(255),
		DATA_TYPE varchar(255)
	) WITH (LOCATION = USER_DB)

--	SELECT ORDINAL_POSITION, COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'ViolatorStatus'  and DATA_TYPE like '%date%'  ORDER BY ORDINAL_POSITION -- 

	INSERT INTO #TEMP
	SELECT ORDINAL_POSITION, COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
		where TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @TableName 
	--ORDER BY ORDINAL_POSITION -- and DATA_TYPE like '%date%' 


	DECLARE @x INT = 0
	DECLARE @Str varchar(8000) = ''

	DECLARE @xMax int = ISNULL((SELECT  MAX(ORDINAL_POSITION)+1 FROM #TEMP),0);

	WHILE @x < @xMax
	BEGIN
		SET @x = @x + 1

--		IF (SELECT DATA_TYPE FROM #TEMP WHERE ORDINAL_POSITION = @x) in ('date','datetime','datetime2')
			SET @Str = @Str + 
					(SELECT 'CREATE STATISTICS STATS_' + @TableName + '_' + RIGHT('000' + convert(varchar(10),ORDINAL_POSITION),3) + ' ON ' + @SchemaName+ '.' + @TableName + ' (' + COLUMN_NAME + ')' FROM #TEMP WHERE ORDINAL_POSITION = @x)
		PRINT @Str
		SET @Str = ''


	END
END

