CREATE PROC [Utility].[Get_PartitionColumn] @Table_Name [VARCHAR](200),@Table_PartitionColumn [VARCHAR](100) OUT AS

/*

USE LND_TBOS
GO
IF OBJECT_ID ('Utility.Get_PartitionColumn', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_PartitionColumn
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @SQL_String VARCHAR(MAX)
EXEC Utility.Get_PartitionColumn 'Dim_Month', @SQL_String OUTPUT 
EXEC Utility.LongPrint @SQL_String
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning string with the name of partition column for Partitioned table. If table is not Partitioned - returnin empty string

@Table_Name - Name of the table to pick column from
@Table_PartitionColumn - Param to return string. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837			Andy	01/10/2020	New!
###################################################################################################################
*/

BEGIN
	/*====================================== TESTING =======================================================================*/
	--DECLARE @Table_Name VARCHAR(200) = 'Dim_Month', @Table_PartitionColumn VARCHAR(100)
	/*====================================== TESTING =======================================================================*/

	DECLARE @Error VARCHAR(MAX) = ''

	IF @Table_Name IS NULL SET @Error = @Error + 'Table name cannot be NULL'

	SET @Table_PartitionColumn = '';

	IF LEN(@Error) > 0
	BEGIN
		PRINT @Error
	END
	ELSE
	BEGIN

		DECLARE @Schema VARCHAR(100), @Table VARCHAR(200)
		DECLARE @Dot INT = CHARINDEX('.',@Table_Name)

		SELECT 
			@Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot + 1,200),'[',''),']','') END

		SELECT @Table_PartitionColumn = '[' +CAST(c.name AS VARCHAR(100)) + ']' 
		FROM sys.Tables AS t  
		JOIN sys.schemas s ON t.[schema_id] = s.[schema_id] AND s.name = @Schema
		JOIN sys.indexes AS i ON t.[object_id] = i.[object_id] AND I.index_id <=1
		JOIN sys.partition_schemes	AS ps ON ps.data_space_id	= i.data_space_id  
		JOIN sys.index_columns		AS ic ON ic.[object_id]		= i.[object_id] AND ic.index_id = i.index_id AND ic.partition_ordinal >= 1 -- because 0 = non-partitioning column  
		JOIN sys.columns			AS c  ON t.[object_id]		= c.[object_id] AND ic.column_id = c.column_id
		WHERE  t.[name] = @Table

	END
END

