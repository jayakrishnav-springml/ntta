CREATE PROC [dbo].[RebuildCCI] @SchemaName [varchar](255),@TableName [varchar](255) AS
BEGIN 

--DECLARE @SchemaName [varchar](255) ='dbo' , @TableName varchar(255) = 'DIM_LICENSE_PLATE'

	IF OBJECT_ID('tempdb..#TEMP')<>0
		DROP TABLE #TEMP

	CREATE TABLE #TEMP
	(
		ROWCOUNTER		int,
		[SchemaName] varchar(255) ,
		[TableName] varchar(255),
		[IndexName] varchar(500)
	) WITH (LOCATION = USER_DB)

	INSERT INTO #TEMP
	SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS ROWCOUNTER, *
	FROM	(	SELECT DISTINCT SCHEMA_NAME(SCHEMA_ID) [SchemaName], tbl.name AS [TableName], i.name AS [IndexName]
				FROM	sys.tables AS tbl
				JOIN sys.indexes AS i	ON (i.index_id > 0 and i.is_hypothetical = 0)	AND (i.object_id=tbl.object_id)
				JOIN sys.index_columns AS ic	ON (ic.column_id > 0 and (ic.key_ordinal > 0	OR ic.partition_ordinal = 0	OR ic.is_included_column != 0))
						AND (ic.index_id=CAST(i.index_id AS int)	AND ic.object_id=i.object_id)
				JOIN sys.columns AS clmns	ON clmns.object_id = ic.object_id	AND clmns.column_id = ic.column_id
				JOIN sys.systypes AS styps	ON clmns.system_type_id=styps.type
				WHERE SCHEMA_NAME(SCHEMA_ID) = @SchemaName and tbl.name = @TableName 
				AND i.type_desc = 'CLUSTERED COLUMNSTORE'
			) A
	--SELECT * FROM #TEMP
	DECLARE @x INT = 0
	DECLARE @Str varchar(8000) = ''

	DECLARE @xMax int = ISNULL((SELECT  MAX(ROWCOUNTER)+1 FROM #TEMP),0);

	WHILE @x < @xMax
	BEGIN
		SET @x = @x + 1

--		IF (SELECT DATA_TYPE FROM #TEMP WHERE ORDINAL_POSITION = @x) in ('date','datetime','datetime2')
			SET @Str = @Str + 
					(SELECT 'CREATE CLUSTERED COLUMNSTORE INDEX ' + [IndexName] + ' ON ' + [TableName] + ' WITH ( DROP_EXISTING = ON );	
								--OPTION (LABEL = ''CCI_REBUILD: ' + [TableName] + ''')'
					 FROM #TEMP WHERE ROWCOUNTER = @x)

		PRINT @Str
		EXEC(@Str)
		SET @Str = ''

	END

END


