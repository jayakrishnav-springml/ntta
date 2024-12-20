CREATE PROC [Utility].[Get_CreateEmptyCopy_SQL] @Table_Name [VARCHAR](130),@New_Table_Name [VARCHAR](130),@Params_In_SQL_Out [VARCHAR](MAX) OUT AS
/*
USE LND_TBOS 
GO
IF OBJECT_ID ('Utility.Get_CreateEmptyCopy_SQL', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_CreateEmptyCopy_SQL 
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'No[]', @Table_Name VARCHAR(200)  = '[TollPlus].[TP_Customers]'
EXEC Utility.Get_CreateEmptyCopy_SQL @Table_Name, Null, @Params_In_SQL_Out OUTPUT 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning SQL statement to create empty new table as full copy of metadata from source table
New table has the same Columns, Indexes, Distribution and Partition. Statistics is not included.

@Table_Name - Table name (with Schema) is example for copy
@New_Table_Name - Table name we need to creat empty. If empty or Null new name will be Table_Name + '_Copy'
@Params_In_SQL_Out - Param to return SQL statement. Can take some secondary parameters
	can include values: 	'No[],NoPrint'
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837			Andy	01/10/2020	New!
###################################################################################################################
*/


BEGIN
	/*====================================== TESTING =======================================================================*/
	--DECLARE @Table_Name VARCHAR(4000) = '[TollPlus].[TP_Customers]', @New_Table_Name VARCHAR(200), @Params_In_SQL_Out VARCHAR(MAX) 
	/*====================================== TESTING =======================================================================*/

	DECLARE @Error VARCHAR(MAX) = ''
	DECLARE @Params VARCHAR(100) = ISNULL(@Params_In_SQL_Out,'')

	IF @Table_Name IS NULL SET @Error = @Error + 'Table name cannot be NULL'
	IF @New_Table_Name IS NULL SET @Error = @Error + 'Target Table name cannot be NULL'

	SET @Params_In_SQL_Out = '';

	IF LEN(@Error) > 0
	BEGIN
		PRINT @Error
	END
	ELSE
	BEGIN

		DECLARE @Table_DISTRIBUTION VARCHAR(100) = @Params + ',NoPrint', @Table_PARTITION VARCHAR(MAX) = @Params + ',NoPrint', @Table_INDEX VARCHAR(MAX) = @Params + ',NoPrint', @Index INT
		DECLARE @Schema VARCHAR(100), @Table VARCHAR(200), @New_Schema VARCHAR(100), @New_Table VARCHAR(200)
		DECLARE @Dot INT = CHARINDEX('.',@Table_Name)

		SELECT 
			@Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot + 1,200),'[',''),']','') END

		IF (@New_Table_Name IS NULL) OR (LEN(@New_Table_Name) = 0)
			SET @New_Table_Name = @Schema + '.' + @Table + '_Copy'

		SET @Dot = CHARINDEX('.',@New_Table_Name)
		SELECT 
			@New_Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@New_Table_Name,@Dot),'[',''),']',''),'.','') END,
			@New_Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@New_Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@New_Table_Name,@Dot + 1,200),'[',''),']','') END

		EXEC Utility.Get_Distribution_String @Table_Name, @Table_DISTRIBUTION OUTPUT 
		EXEC Utility.Get_Index_String @Table_Name, @Table_INDEX OUTPUT 
		EXEC Utility.Get_Partition_String @Table_Name, @Table_PARTITION OUTPUT 

		-- First we have to drop existing table
		SET @Params_In_SQL_Out = CHAR(13) + 'IF OBJECT_ID(''' + @New_Table_Name + ''',''U'') IS NOT NULL			DROP TABLE ' + @New_Table_Name + ';' 

		SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + 'CREATE TABLE ' + @New_Table_Name + ' WITH (' + @Table_INDEX + ', ' + @Table_DISTRIBUTION + @Table_PARTITION + ') AS' + CHAR(13) + 'SELECT *' + CHAR(13) + 'FROM ' + @Schema + '.[' + @Table + ']' + CHAR(13) + 'WHERE 1 = 2'

		IF CHARINDEX('No[]',@Params) > 0
			SET @Params_In_SQL_Out = REPLACE(REPLACE(@Params_In_SQL_Out,'[',''),']','')

		IF CHARINDEX('NoPrint',@Params) = 0
			EXEC Utility.LongPrint @Params_In_SQL_Out

	END
END
