CREATE PROC [DBO].[GET_INDEX_STRING] @TABLE [VARCHAR](100),@SQL_STRING [VARCHAR](MAX) OUT AS
/*

USE EDW_TER
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.GET_INDEX_STRING') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.GET_INDEX_STRING
GO

DECLARE @SQL_STRING [VARCHAR](MAX)
EXEC EDW_TER.DBO.GET_INDEX_STRING 'FACT_VIOLATION_VB_VIOL_INVOICES', @SQL_STRING OUTPUT 
PRINT @SQL_STRING

EXEC EDW_TER.DBO.GET_INDEX_STRING 'FACT_VIOLATIONS_DETAIL', @SQL_STRING OUTPUT 
PRINT @SQL_STRING


DECLARE @SQL_STRING [VARCHAR](MAX)
Declare @TABLE [VARCHAR](100) = 'FACT_VIOLATION_VB_VIOL_INVOICES'

*/

DECLARE @TABLE_INDEX VARCHAR(100)

	SELECT 
		@TABLE_INDEX = I.type_desc
	FROM sys.tables as t
	JOIN sys.indexes AS I ON I.object_id = t.object_id
	WHERE t.name = @TABLE AND I.index_id <=1

	IF @TABLE_INDEX = 'CLUSTERED'
	BEGIN
		WITH CTE AS
		(
			SELECT C.column_id, u.name AS column_name, CASE WHEN C.is_descending_key = 1 THEN ' DESC' ELSE '' END AS column_Order
				, ROW_NUMBER() OVER (ORDER BY C.column_id) AS RN 
			FROM sys.tables as t
			JOIN sys.indexes AS I ON I.object_id = t.object_id
			JOIN sys.index_columns AS C ON C.object_id = t.object_id AND C.index_id = I.index_id AND C.key_ordinal = 1
			JOIN sys.columns AS u ON u.column_id = C.column_id AND u.object_id = t.object_id
			WHERE t.name = @TABLE AND I.index_id <=1
		)
		, CTE_JOINT AS 
		(
			SELECT 
				' [' + CTE1.column_name + ']' + CTE1.column_Order
				+ ISNULL(', ['+ CTE2.column_name + ']' + CTE2.column_Order, '')
				+ ISNULL(', ['+ CTE3.column_name + ']' + CTE3.column_Order, '')
				+ ISNULL(', ['+ CTE4.column_name + ']' + CTE4.column_Order, '')
				+ ISNULL(', ['+ CTE5.column_name + ']' + CTE5.column_Order, '')
				+ ISNULL(', ['+ CTE6.column_name + ']' + CTE6.column_Order, '')
				+ ISNULL(', ['+ CTE7.column_name + ']' + CTE7.column_Order, '')
				+ ISNULL(', ['+ CTE8.column_name + ']' + CTE8.column_Order, '')
				+ ISNULL(', ['+ CTE9.column_name + ']' + CTE9.column_Order, '')
				+ ISNULL(', ['+ CTE10.column_name + ']' + CTE10.column_Order, '') + ' ' AS INDEX_COULUMNS
			FROM CTE AS CTE1
			LEFT JOIN CTE AS CTE2 ON  CTE2.RN = 2
			LEFT JOIN CTE AS CTE3 ON  CTE3.RN = 3
			LEFT JOIN CTE AS CTE4 ON  CTE4.RN = 4
			LEFT JOIN CTE AS CTE5 ON  CTE5.RN = 5
			LEFT JOIN CTE AS CTE6 ON  CTE6.RN = 6
			LEFT JOIN CTE AS CTE7 ON  CTE7.RN = 7
			LEFT JOIN CTE AS CTE8 ON  CTE8.RN = 8
			LEFT JOIN CTE AS CTE9 ON  CTE9.RN = 9
			LEFT JOIN CTE AS CTE10 ON CTE10.RN = 10
			WHERE CTE1.RN = 1
		)
		SELECT TOP 1
			@SQL_STRING = @TABLE_INDEX + ' INDEX (' + INDEX_COULUMNS + ')'
		FROM CTE_JOINT
	END
	ELSE
	BEGIN
		IF @TABLE_INDEX = 'CLUSTERED COLUMNSTORE'
		BEGIN
			SET @SQL_STRING = @TABLE_INDEX + ' INDEX'
		END
		ELSE
		BEGIN
			SET @SQL_STRING = @TABLE_INDEX
		END
	END



