CREATE PROC [dbo].[TRUNCATE_TABLE] @TABLE_SCHEMA [varchar](255),@TABLE_NAME [varchar](255) AS
BEGIN 


	DECLARE @SQL varchar(8000) = 'TRUNCATE TABLE [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + ']'
	PRINT @SQL 
	EXEC (@SQL)



END


