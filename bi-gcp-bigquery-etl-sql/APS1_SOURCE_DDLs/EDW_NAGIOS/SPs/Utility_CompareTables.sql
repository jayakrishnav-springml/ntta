CREATE PROC [Utility].[CompareTables] @Table1 [VARCHAR](100),@Table2 [VARCHAR](100) AS
BEGIN
	DECLARE @SQL VARCHAR(8000)

	SET @SQL = 
	'SELECT ''' + @Table1 + ''' TABLENAME, *  
	FROM
		(SELECT * FROM '
				+ @Table1 + '
		 EXCEPT
		 SELECT * FROM ' + @Table2
				+ ') X
	UNION ALL
	SELECT ''' + @Table2
				+ ''' TABLENAME, *  
	FROM
		(SELECT * FROM ' + @Table2
				+ '
		 EXCEPT 
		 SELECT * FROM ' + @Table1
				+ ') X
	ORDER BY 2,1'

	PRINT @SQL

	EXEC(@SQL) 
END

