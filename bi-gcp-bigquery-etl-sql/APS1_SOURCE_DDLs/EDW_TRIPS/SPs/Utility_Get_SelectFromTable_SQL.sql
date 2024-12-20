CREATE PROC [Utility].[Get_SelectFromTable_SQL] @Table_Name [VARCHAR](200),@Params_In_SQL_Out [VARCHAR](MAX) OUT AS
/*
USE EDW_TRIPS 
GO
IF OBJECT_ID ('Utility.Get_SelectFromTable_SQL', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_SelectFromTable_SQL
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Params_In_SQL_Out [VARCHAR](MAX) = 'Types,Alias,No[]',@Table_Name [VARCHAR](100)  = '[TollPlus].[TP_Customers]' 
EXEC Utility.Get_SelectFromTable_SQL @Table_Name, @Params_In_SQL_Out OUTPUT 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning SQL SELECT statement for all table columns 
Depends on Parameters it can be just list of names devided by comma, or use cast, ISNULL and allias. See example.

@Table_Name - Table name (with Schema) - table for get columns from
@Params_In_SQL_Out - Param to return SQL statement. Can take some secondary parameters
	can include values: 	'Types,Alias:Short or Long or YourAlias,TitleCase,No[],NoPrint'
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
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

		DECLARE @Schema VARCHAR(100), @Table VARCHAR(200), @SELECT_String VARCHAR(MAX) = @Params + ',NoPrint'
		DECLARE @TableAlias VARCHAR(40), @Index INT
		DECLARE @Dot INT = CHARINDEX('.',@Table_Name)
		SELECT 
			@Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot + 1,200),'[',''),']','') END

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
		
		IF CHARINDEX('Title',@Params) > 0
		BEGIN
			SET @Schema = Utility.uf_TitleCase(@Schema) 
			SET @Table = Utility.uf_TitleCase(@Table) 
			SET @TableAlias = Utility.uf_TitleCase(@TableAlias) 
		END	

		EXEC Utility.Get_Select_String @Table_Name, @SELECT_String OUTPUT 
	
		SET @Params_In_SQL_Out = 'SELECT ' + @SELECT_String +  + CHAR(13) + 'FROM [' + @Schema + '].[' + @Table + '] AS [' + @TableAlias + ']' +  CHAR(13) + 'WHERE 1 = 1'

		IF OBJECT_ID('tempdb..#TableColums') IS NOT NULL DROP Table #TableColums;

		IF CHARINDEX('No[]',@Params) > 0
			SET @Params_In_SQL_Out = REPLACE(REPLACE(@Params_In_SQL_Out,'[',''),']','')

		IF CHARINDEX('NoPrint',@Params) = 0
			EXEC Utility.LongPrint @Params_In_SQL_Out

	END

END
















