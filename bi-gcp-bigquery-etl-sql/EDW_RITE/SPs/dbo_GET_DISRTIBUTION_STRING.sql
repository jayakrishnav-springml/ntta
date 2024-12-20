CREATE PROC [DBO].[GET_DISRTIBUTION_STRING] @TABLE [VARCHAR](100),@SQL_STRING [VARCHAR](MAX) OUT AS
/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.GET_DISRTIBUTION_STRING') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.GET_DISRTIBUTION_STRING
GO

DECLARE @SQL_STRING [VARCHAR](MAX)
EXEC EDW_RITE.DBO.GET_DISRTIBUTION_STRING 'FACT_UNIFIED_VIOLATION_SNAPSHOT', @SQL_STRING OUTPUT 
PRINT @SQL_STRING

DECLARE @SQL_STRING [VARCHAR](MAX)
EXEC EDW_RITE.DBO.GET_DISRTIBUTION_STRING 'FACT_INVOICE_ANALYSIS_DETAIL', @SQL_STRING OUTPUT 
PRINT @SQL_STRING

*/

DECLARE @TABLE_DISTRIBUTION NVARCHAR(100) --COLLATE Latin1_General_100_CI_AS_KS_WS
DECLARE @ColumnName NVARCHAR(100) --COLLATE Latin1_General_100_CI_AS_KS_WS
DECLARE @Delimiter NVARCHAR(1) = ''

SET @SQL_STRING = ''


SELECT 
	@TABLE_DISTRIBUTION = p.distribution_policy_desc,
	@ColumnName = ISNULL(c.name, '') 
FROM sys.tables as t
JOIN sys.pdw_table_distribution_properties p  ON p.[object_id] = t.[object_id]
LEFT JOIN sys.pdw_column_distribution_properties cd  ON cd.object_id = t.object_id AND cd.distribution_ordinal = 1 --AND p.column_id = cd.column_id
LEFT JOIN sys.columns c ON c.object_id = t.object_id AND c.column_id = cd.column_id
WHERE t.name = @TABLE

SET @SQL_STRING  = 'DISTRIBUTION = ' + @TABLE_DISTRIBUTION + CASE WHEN LEN(@ColumnName) > 0 THEN '([' + @ColumnName + '])' ELSE '' END




