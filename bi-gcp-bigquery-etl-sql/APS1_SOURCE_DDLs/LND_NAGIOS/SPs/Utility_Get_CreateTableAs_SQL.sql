CREATE PROC [Utility].[Get_CreateTableAs_SQL] @Table_Name [VARCHAR](200),@New_Table_Name [VARCHAR](200),@Params_In_SQL_Out [VARCHAR](MAX) OUT AS
/*
USE LND_NAGIOS 
GO
IF OBJECT_ID ('Utility.Get_CreateTableAs_SQL', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_CreateTableAs_SQL
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @CreateTableAs VARCHAR(MAX) = 'Types,Alias,No[]',
		@CreateStatistics VARCHAR(MAX) = 'Types,Alias,No[]',
		@TransferObject VARCHAR(MAX) = 'Types,Alias,No[]',
		@Table_Name VARCHAR(200) = 'Utility.TableLoadParameters',
		@New_Table_Name VARCHAR(100) = 'New.TableLoadParameters'

EXEC Utility.Get_CreateTableAs_SQL @Table_Name, @New_Table_Name, @CreateTableAs OUTPUT 
EXEC Utility.Get_CreateStatistics_SQL @Table_Name, @New_Table_Name, @CreateStatistics OUTPUT 
EXEC Utility.Get_TransferObject_SQL @New_Table_Name, @Table_Name, @TransferObject OUTPUT 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning CREATE TABLE AS SELECT statement for table from another table.
If the new table already exists - it's dropping it before creating

@Table_Name - Name of the table to get all data and Metadata from
@New_Table_Name - Table name we need to creat from the table. All metatadata and data will be the same.
@Params_In_SQL_Out - Param to return string. 
	-- can be: 	'Types,Alias:Short or Long or YourAlias,TitleCase,No[],NoPrint'
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
		
		DECLARE @Table_DISTRIBUTION VARCHAR(100) = @Params + ',NoPrint', @Table_PARTITION VARCHAR(MAX) = @Params + ',NoPrint', @Table_INDEX VARCHAR(MAX) = @Params + ',NoPrint', @SELECT_String VARCHAR(MAX) = @Params + ',NoPrint'
		DECLARE @Schema VARCHAR(100), @Table VARCHAR(200), @New_Schema VARCHAR(100), @New_Table VARCHAR(200)
		DECLARE @Types BIT = 0, @Alias BIT = 0, @TitleCase BIT = 0, @NoBrackets BIT = 0, @TableAlias VARCHAR(40), @Index INT
		DECLARE @Dot INT = CHARINDEX('.',@Table_Name)

		SELECT 
			@Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot + 1,200),'[',''),']','') END

		IF (@New_Table_Name IS NULL) OR (LEN(@New_Table_Name) = 0)
			SET @New_Table_Name = 'New.' + @Table

		SET @Dot = CHARINDEX('.',@New_Table_Name)

		SELECT 
			@New_Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@New_Table_Name,@Dot),'[',''),']',''),'.','') END,
			@New_Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@New_Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@New_Table_Name,@Dot + 1,200),'[',''),']','') END

		SET @TableAlias = @Table
		SET @Params = REPLACE(REPLACE(@Params,' ',''),'	','')
		SELECT @Index = ISNULL(NULLIF(CHARINDEX('Alias:',@Params),0),CHARINDEX('Table:',@Params))
		IF @Index > 0 -- In this brackets only the table name can be we need to put in AS
		BEGIN
			SET @TableAlias = SUBSTRING(@Params,CHARINDEX(':',@Params,@Index) + 1, ISNULL(NULLIF(CHARINDEX(',',@Params,@Index),0), LEN(@Params) + 1) - CHARINDEX(':',@Params,@Index) - 1)

			SET @Params = REPLACE(REPLACE(@Params,'Table:' + @TableAlias,'Alias'),'Alias:' + @TableAlias,'Alias')-- If table include somehow one of the key word (like table, Type or Alias) - we have to remove it

			IF @TableAlias = 'Short'
				SELECT @TableAlias = AliasShort FROM Utility.TableAlias WHERE TableName = @Schema + '.' + @Table;
			IF @TableAlias = 'Long'
				SELECT @TableAlias = AliasLong FROM Utility.TableAlias WHERE TableName = @Schema + '.' + @Table;
		END
		IF CHARINDEX('Alias',@Params) > 0
			SET @Alias = 1
		IF CHARINDEX('Title',@Params) > 0
			SET @TitleCase = 1

		EXEC Utility.Get_Index_String @Table_Name, @Table_INDEX OUTPUT 
		EXEC Utility.Get_Distribution_String @Table_Name, @Table_DISTRIBUTION OUTPUT 
		EXEC Utility.Get_Partition_String @Table_Name, @Table_PARTITION OUTPUT 
		EXEC Utility.Get_Select_String @Table_Name, @SELECT_String OUTPUT 

		IF @TitleCase = 1
		BEGIN
			SET @Schema = Utility.uf_TitleCase(@Schema) 
			SET @Table = Utility.uf_TitleCase(@Table) 
			SET @NEW_Schema = Utility.uf_TitleCase(@NEW_Schema) 
			SET @NEW_Table = Utility.uf_TitleCase(@NEW_Table) 
			SET @TableAlias = Utility.uf_TitleCase(@TableAlias) 
		END	

		-- First we have to drop existing table
		SET @Params_In_SQL_Out = CHAR(13) + 'IF OBJECT_ID(''' + @New_Table_Name + ''',''U'') IS NOT NULL			DROP TABLE ' + @New_Table_Name + ';' 
		SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + 'CREATE TABLE ' + @NEW_Schema + '.[' + @NEW_Table + '] WITH (' + @Table_INDEX + ', ' + @Table_DISTRIBUTION + @Table_PARTITION + ') AS' + 
								CHAR(13) + 'SELECT' + @SELECT_String + CHAR(13) + 'FROM ' + @Schema + '.[' + @Table + '] AS [' + @TableAlias + ']' + CHAR(13) + 'WHERE 1 = 1' + 
								CHAR(13) + 'OPTION (LABEL = ''' + @New_Schema + '.' + @New_Table + ' Load'');'
		-- WHERE 1 = 1 - we need this for automated adding filter using SUBSTRING 

		IF CHARINDEX('No[]',@Params) > 0
			SET @Params_In_SQL_Out = REPLACE(REPLACE(@Params_In_SQL_Out,'[',''),']','')

		IF CHARINDEX('NoPrint',@Params) = 0
			EXEC Utility.LongPrint @Params_In_SQL_Out

	END
END
