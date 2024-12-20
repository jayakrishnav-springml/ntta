CREATE PROC [Utility].[Get_CreateEmptySwitchTable_SQL] @Table_Name [VARCHAR](200),@Params_In_SQL_Out [VARCHAR](MAX) OUT AS
/*
USE LND_TBOS
GO
IF OBJECT_ID ('Utility.Get_CreateEmptySwitchTable_SQL', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_CreateEmptySwitchTable_SQL
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'No[],NewSchema:New,', @Table_Name VARCHAR(200)  = 'dbo.Dim_Month'
EXEC Utility.Get_CreateEmptySwitchTable_SQL @Table_Name, @Params_In_SQL_Out OUTPUT 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning CREATE TABLE AS SELECT statement, that creating a new empty table with the same Metadata as Example

@Table_Name - Name of the table to pick column from
@Params_In_SQL_Out - Param to return string. 
	-- can be: 	'No[],NoPrint,NewTable:NewTableName,NewSchema:NewSchemaName'
	-- By default NewTable = Table + 'Switch', NewSchema = the same as Schema
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

		DECLARE @Schema VARCHAR(100), @Table VARCHAR(200), @Table_DISTRIBUTION VARCHAR(100) = @Params + ',NoPrint', @Table_PARTITION VARCHAR(MAX) = @Params + ',NoPrint', @Table_INDEX VARCHAR(MAX) = @Params + ',NoPrint'
		DECLARE @Dot INT = CHARINDEX('.',@Table_Name), @Index INT

		SELECT 
			@Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot + 1,200),'[',''),']','') END

		DECLARE @New_Table_Name VARCHAR(100), @NewTable VARCHAR(100) = @Table + 'Switch', @NewSchema VARCHAR(100) = @Schema

		SET @Params = REPLACE(REPLACE(@Params,' ',''),'	','')
		SELECT @Index = ISNULL(NULLIF(CHARINDEX('NewTable:',@Params),0),CHARINDEX('NewName:',@Params))
		IF @Index > 0 -- In this brackets only the table name can be we need to put in AS
		BEGIN
			SET @NewTable = SUBSTRING(@Params,CHARINDEX(':',@Params,@Index) + 1, ISNULL(NULLIF(CHARINDEX(',',@Params,@Index),0), LEN(@Params) + 1) - CHARINDEX(':',@Params,@Index) - 1)
			SET @Params = REPLACE(REPLACE(@Params,'NewTable:' + @NewTable,''),'NewName:' + @NewTable,'')-- If table include somehow one of the key word (like table, Type or Alias) - we have to remove it
		END
		SELECT @Index = CHARINDEX('NewSchema:',@Params)
		IF @Index > 0 -- In this brackets only the table name can be we need to put in AS
		BEGIN
			SET @NewSchema = SUBSTRING(@Params,CHARINDEX(':',@Params,@Index) + 1, ISNULL(NULLIF(CHARINDEX(',',@Params,@Index),0), LEN(@Params) + 1) - CHARINDEX(':',@Params,@Index) - 1)
			SET @Params = REPLACE(@Params,'NewSchema:' + @NewSchema,'') -- If table include somehow one of the key word (like table, Type or Alias) - we have to remove it
		END

		SET @New_Table_Name = @NewSchema + '.[' + @NewTable + ']'

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
