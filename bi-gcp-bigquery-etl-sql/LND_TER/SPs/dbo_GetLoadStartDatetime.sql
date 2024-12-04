CREATE PROC [GetLoadStartDatetime] @TABLE_NAME [varchar](512) AS
DECLARE 
	  @SQL varchar(8000)
	, @Date_Value datetime2(2)

	IF OBJECT_ID('tempdb..#TEMP')<>0
		DROP TABLE #TEMP

	CREATE TABLE #TEMP
	(Date_Value datetime2(2)
	) WITH (LOCATION = USER_DB)


SET @SQL = 	
		'IF (SELECT USE_LOAD_CONTROL_DATE_IND FROM LOAD_CONTROL) = ''Y''
			BEGIN 
				INSERT INTO #TEMP SELECT LOAD_CONTROL_DATE FROM DBO.LOAD_CONTROL
			END 
		ELSE 
			BEGIN
				INSERT INTO #TEMP SELECT ISNULL((SELECT TOP 1 LAST_UPDATE_DATE FROM ' + @TABLE_NAME + ' ORDER BY LAST_UPDATE_DATE DESC),''1/1/0001'')
			END 
			'
	PRINT @SQL 

--	SELECT Date_Value FROM #TEMP

