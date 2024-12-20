CREATE PROC [dbo].[GetLoadStartDatetime] @TABLE_NAME [varchar](512),@Date_Value [datetime2](2) OUT AS

/*

DROP PROC [dbo].[GetLoadStartDatetime]

DECLARE @TABLE_NAME [varchar](512) = 'ACCOUNTS', @Date_Value [datetime2](2)
EXEC [dbo].[GetLoadStartDatetime] @TABLE_NAME, @Date_Value OUTPUT
PRINT CONVERT(VARCHAR(19), @Date_Value, 121)

*/

DECLARE @SQL varchar(1000)

	IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL DROP TABLE #TEMP

	CREATE TABLE #TEMP (Date_Value datetime2(2)) WITH (LOCATION = USER_DB)

	SET @SQL = 'INSERT INTO #TEMP SELECT ISNULL(MAX(LAST_UPDATE_DATE),''1/1/1900'') LAST_UPDATE_DATE FROM ' + @TABLE_NAME + ''

	EXEC (@SQL)

	SELECT @Date_Value = Date_Value FROM #TEMP

