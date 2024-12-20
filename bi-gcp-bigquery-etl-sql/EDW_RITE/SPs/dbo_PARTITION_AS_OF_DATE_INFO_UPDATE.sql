CREATE PROC [dbo].[PARTITION_AS_OF_DATE_INFO_UPDATE] @TABLE_NAME [varchar](255) AS
BEGIN 


	IF OBJECT_ID('tempdb..#PARTITIONS')<>0
		DROP TABLE #PARTITIONS

	CREATE TABLE #PARTITIONS WITH (LOCATION = USER_DB, DISTRIBUTION=REPLICATE) 
	AS 
	SELECT 
		  t.name as TABLE_NAME
		, p.partition_number AS PARTITION_NBR
		, cast(coalesce(lag(r.value,1) over (order by p.partition_number),'1/1/1900') as date) AS RANGE_FROM_EXCLUDING
		, cast(coalesce(r.value,'12/31/9999') as date) AS RANGE_TO_INCLUDING
		, GETDATE() AS INSERT_DATE
	FROM sys.tables AS t 
	INNER JOIN sys.indexes AS i ON t.object_id = i.object_id 
	INNER JOIN sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id 
	INNER JOIN  sys.partition_schemes AS s ON i.data_space_id = s.data_space_id 
	INNER JOIN sys.partition_functions AS f ON s.function_id = f.function_id 
	LEFT JOIN sys.partition_range_values AS r ON f.function_id = r.function_id and r.boundary_id = p.partition_number 
	WHERE 
		--i.type <= 1
		(i.type <= 1  OR i.type = 5)
		and 
		t.name=@TABLE_NAME
		--and 
		--t.name='FACT_VIOLATION'

	DELETE FROM dbo.PARTITION_AS_OF_DATE_INFO WHERE TABLE_NAME = @TABLE_NAME

	INSERT INTO dbo.PARTITION_AS_OF_DATE_INFO
		(
			  TABLE_NAME
			, PARTITION_NBR
			, RANGE_FROM_EXCLUDING
			, RANGE_TO_INCLUDING
			, INSERT_DATE
		)
	SELECT 
			  TABLE_NAME
			, PARTITION_NBR
			, RANGE_FROM_EXCLUDING
			, RANGE_TO_INCLUDING
			, INSERT_DATE
	FROM #PARTITIONS


/*	
	EXEC DropStats 'PARTITION_AS_OF_DATE_INFO'
	CREATE STATISTICS STATS_PARTITION_AS_OF_DATE_INFO_001 ON [dbo].PARTITION_AS_OF_DATE_INFO (TABLE_NAME)
	CREATE STATISTICS STATS_PARTITION_AS_OF_DATE_INFO_002 ON [dbo].PARTITION_AS_OF_DATE_INFO (TABLE_NAME, PARTITION_NBR)

	SELECT * FROM PARTITION_AS_OF_DATE_INFO WHERE TABLE_NAME = @TABLE_NAME ORDER BY 1,2
	SELECT AS_OF_DATE, COUNT(*) FROM FACT_VIOLATION GROUP BY AS_OF_DATE order by 1
*/

END 


