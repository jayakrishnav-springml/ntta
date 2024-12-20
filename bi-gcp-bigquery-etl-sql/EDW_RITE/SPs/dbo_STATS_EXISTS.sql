CREATE PROC [dbo].[STATS_EXISTS] @TABLE_SCHEMA [varchar](255),@TABLE_NAME [varchar](255),@STATS_NAME [varchar](255),@STATS_EXISTS [bit] OUT AS
BEGIN 
	IF EXISTS
		(
			SELECT  sc.name, so.name, ss.name 
			FROM sys.stats ss 
			INNER JOIN sys.objects so on ss.object_id = so.object_id 
			INNER JOIN sys.schemas sc on sc.schema_id = so.schema_id
			WHERE sc.name = @TABLE_SCHEMA and so.name = @TABLE_NAME and ss.name = @STATS_NAME and ss.user_created = 1
		) 
			BEGIN 
				SET @STATS_EXISTS = 1
			END 
		ELSE
			BEGIN 
				SET @STATS_EXISTS = 0
			END 

END


