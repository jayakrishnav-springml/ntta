CREATE PROC [Utility].[Get_Distribution_String] @Table_Name [VARCHAR](200),@Params_In_SQL_Out [VARCHAR](MAX) OUT AS
/*
USE LND_TBOS
GO
IF OBJECT_ID ('Utility.Get_Distribution_String', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_Distribution_String
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'No[]'
EXEC Utility.Get_Distribution_String 'dbo.Dim_Month', @Params_In_SQL_Out OUTPUT 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning DISTRIBUTION string for Create table statement, looks like 'DISTRIBUTION = HASH(Column1)'

@Table_Name - Name of the table to pick column from
@Params_In_SQL_Out - Param to return string. 
	-- can be: 	'No[],NoPrint'
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837			Andy	01/10/2020	New!
###################################################################################################################
*/

BEGIN

	DECLARE @Error VARCHAR(MAX) = ''
	DECLARE @Params VARCHAR(100) = ISNULL(@Params_In_SQL_Out,'')

	IF @Table_Name IS NULL SET @Error = @Error + 'Table name cannot be NULL'

	SET @Params_In_SQL_Out = '';

	IF LEN(@Error) > 0
	BEGIN
		PRINT @Error
	END
	ELSE
	BEGIN

		DECLARE @Schema VARCHAR(100), @Table VARCHAR(200), @Table_DISTRIBUTION VARCHAR(100), @ColumnName VARCHAR(100)
		DECLARE @Dot INT = CHARINDEX('.',@Table_Name)

		SELECT 
			@Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot + 1,200),'[',''),']','') END

		SELECT 
			@Table_DISTRIBUTION = p.distribution_policy_desc,
			@ColumnName = ISNULL(c.name, '') 
		FROM sys.Tables as t
		JOIN sys.schemas s ON t.schema_id = s.schema_id AND s.name = @Schema
		JOIN sys.pdw_Table_distribution_properties p  ON p.[object_id] = t.[object_id]
		LEFT JOIN sys.pdw_column_distribution_properties cd  ON cd.object_id = t.object_id AND cd.distribution_ordinal = 1 --AND p.column_id = cd.column_id
		LEFT JOIN sys.columns c ON c.object_id = t.object_id AND c.column_id = cd.column_id
		WHERE t.name = @Table

		SET @Params_In_SQL_Out  = 'DISTRIBUTION = ' + @Table_DISTRIBUTION + CASE WHEN LEN(@ColumnName) > 0 THEN '([' + @ColumnName + '])' ELSE '' END

		IF CHARINDEX('No[]',@Params) > 0
			SET @Params_In_SQL_Out = REPLACE(REPLACE(@Params_In_SQL_Out,'[',''),']','')

		IF CHARINDEX('NoPrint',@Params) = 0
			EXEC Utility.LongPrint @Params_In_SQL_Out

	END
END

