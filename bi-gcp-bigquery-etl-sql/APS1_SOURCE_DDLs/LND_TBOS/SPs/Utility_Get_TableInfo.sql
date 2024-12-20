CREATE PROC [Utility].[Get_TableInfo] @Table_Name [VARCHAR](200),@Proc_Name [VARCHAR](200),@Params_In_SQL_Out [VARCHAR](MAX) OUT AS
/*
USE LND_TBOS 
GO
IF OBJECT_ID ('Utility.Get_TableInfo', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_TableInfo
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'Types,Alias,No[],NewTable:_NewTable'
EXEC Utility.Get_TableInfo 'dbo.Dim_Month', 'CreateTableAs,CreateStatistics,RenameTable', @Params_In_SQL_Out OUTPUT

DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'Types,Alias:Short,No[],NewSchema:Stage'
EXEC Utility.Get_TableInfo 'dbo.Dim_Month', 'Select,CreateTruncateTable', @Params_In_SQL_Out OUTPUT
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc give you possibility to kick off several GET SQL procs from one call.

@Table_Name - Table name (with Schema) - table name for all actions you want to apply
@Proc_Name - List of the procs you want to use for the table you sent
@Params_In_SQL_Out - Param to return SQL statement. Can take some secondary parameters
	can include values: 	'Types,Alias:Short or Long or YourAlias,TitleCase,No[],NewTable:NewTableName,NewSchema:NewSchemaName,NoPrint'
	If NewTable or NewSchema is not chosen, it will be Schema.Table + '_New' by default
	If NewTable starts from '_' - it thinks it is a suffics to add to the table name
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
###################################################################################################################
*/


BEGIN

	/*====================================== TESTING =======================================================================*/
	-- DECLARE @Table_Name = 'dbo.Dim_Month', @Proc_Name VARCHAR(100)  = 'Get_Select_String', @Params_In_SQL_Out VARCHAR(MAX) = 'Types,Alias:Short,No[],NewSchema:Stage'
	/*====================================== TESTING =======================================================================*/
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
		IF @Proc_Name IS NULL SET @Proc_Name = ''

		DECLARE @SQL VARCHAR(MAX), @Schema VARCHAR(100), @Table VARCHAR(200), @Dot1 INT = CHARINDEX('.',@Table_Name), @Index INT

		SELECT 
			@Schema = CASE WHEN @Dot1 = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot1),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot1 = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot1 + 1,200),'[',''),']','') END

		DECLARE @New_Table_Name VARCHAR(100), @NewTable VARCHAR(100) = @Table+'_New', @NewSchema VARCHAR(100) = @Schema

		SET @Params_In_SQL_Out = '-- Was called Get_TableInfo for Table ' + @Table_NAME + CHAR(13) + CHAR(10)

		SET @Params = REPLACE(REPLACE(@Params,' ',''),'	','')
		SELECT @Index = ISNULL(NULLIF(CHARINDEX('NewTable:',@Params),0),CHARINDEX('NewName:',@Params))
		IF @Index > 0 -- In this brackets only the table name can be we need to put in AS
		BEGIN
			SET @NewTable = SUBSTRING(@Params,CHARINDEX(':',@Params,@Index) + 1, ISNULL(NULLIF(CHARINDEX(',',@Params,@Index),0), LEN(@Params) + 1) - CHARINDEX(':',@Params,@Index) - 1)
			SET @Params = REPLACE(REPLACE(@Params,'NewTable:' + @NewTable,''),'NewName:' + @NewTable,'')-- If table include somehow one of the key word (like table, Type or Alias) - we have to remove it
			IF LEFT(@NewTable,1) = '_'
				SET @NewTable = @Table + @NewTable
		END
		SELECT @Index = CHARINDEX('NewSchema:',@Params)
		IF @Index > 0 -- In this brackets only the table name can be we need to put in AS
		BEGIN
			SET @NewSchema = SUBSTRING(@Params,CHARINDEX(':',@Params,@Index) + 1, ISNULL(NULLIF(CHARINDEX(',',@Params,@Index),0), LEN(@Params) + 1) - CHARINDEX(':',@Params,@Index) - 1)
			SET @Params = REPLACE(@Params,'NewSchema:' + @NewSchema,'') -- If table include somehow one of the key word (like table, Type or Alias) - we have to remove it
		END

		SET @New_Table_Name = @NewSchema + '.' + @NewTable

		IF @Proc_Name LIKE '%Distibution%'
		BEGIN
			SET @SQL = @Params+ ',NoPrint'
			EXEC Utility.Get_Distribution_String @Table_Name, @SQL OUTPUT 
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + '--Distibution:' + CHAR(13) + CHAR(10) + @SQL  + CHAR(13) + CHAR(10)
		END
		IF @Proc_Name LIKE '%Index%'
		BEGIN
			SET @SQL = @Params+ ',NoPrint'
			EXEC Utility.Get_Index_String @Table_Name, @SQL OUTPUT 
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + '--Index:' + CHAR(13) + CHAR(10) + @SQL  + CHAR(13) + CHAR(10)
		END
		IF @Proc_Name LIKE '%Partition%'
		BEGIN
			SET @SQL = @Params+ ',NoPrint'
			EXEC Utility.Get_Partition_String @Table_Name, @SQL OUTPUT 
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + '--Partition:' + CHAR(13) + CHAR(10) + @SQL  + CHAR(13) + CHAR(10)
		END
		ELSE IF @Proc_Name LIKE '%Select%'
		BEGIN
			SET @SQL = @Params+ ',NoPrint'
			EXEC Utility.Get_Select_String @Table_Name, @SQL OUTPUT 
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + '--Select:' + CHAR(13) + CHAR(10) + @SQL  + CHAR(13) + CHAR(10)
		END
		IF @Proc_Name LIKE '%CreateEmptySwitchTable%'
		BEGIN
			SET @SQL = @Params+ ',NoPrint'
			EXEC Utility.Get_CreateEmptySwitchTable_SQL @Table_Name, @SQL OUTPUT 
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + '--Create Epmty Switch Table:' + CHAR(13) + CHAR(10) + @SQL  + CHAR(13) + CHAR(10)
		END
		IF @Proc_Name LIKE '%CreateTableAs%'
		BEGIN
			SET @SQL = @Params+ ',NoPrint'
			EXEC Utility.Get_CreateTableAs_SQL @Table_Name, @New_Table_Name, @SQL OUTPUT 
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + '--Create Table As:' + CHAR(13) + CHAR(10) + @SQL  + CHAR(13) + CHAR(10)
		END
		IF @Proc_Name LIKE '%DropStatistics%'
		BEGIN
			SET @SQL = @Params+ ',NoPrint'
			EXEC Utility.Get_DropStatistics_SQL @Table_Name, @SQL OUTPUT 
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + '--DropStatistics:' + CHAR(13) + CHAR(10) + @SQL  + CHAR(13) + CHAR(10)
		END
		IF @Proc_Name LIKE '%CreateStatistics%'
		BEGIN
			SET @SQL = @Params+ ',NoPrint'
			EXEC Utility.Get_CreateStatistics_SQL @Table_Name, @New_Table_Name, @SQL  OUTPUT
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + '--Create Statistics:' + CHAR(13) + CHAR(10) + @SQL  + CHAR(13) + CHAR(10)
		END
		IF @Proc_Name LIKE '%RenameTable%'
		BEGIN
			SET @SQL = @Params+ ',NoPrint'
			EXEC Utility.Get_TransferObject_SQL @New_Table_Name, @Table_Name, @SQL OUTPUT 
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + '--Rename Table:' + CHAR(13) + CHAR(10) + @SQL  + CHAR(13) + CHAR(10)
		END

		IF	(@Proc_Name NOT LIKE '%Distibution%' AND 
			 @Proc_Name NOT LIKE '%Index%' AND
			 @Proc_Name NOT LIKE '%Partition%' AND
			 @Proc_Name NOT LIKE '%Select%' AND
			 @Proc_Name NOT LIKE '%CreateEmptySwitchTable%' AND
			 @Proc_Name NOT LIKE '%CreateTableAs%' AND
			 @Proc_Name NOT LIKE '%DropStatistics%' AND
			 @Proc_Name NOT LIKE '%CreateStatistics%' AND
			 @Proc_Name NOT LIKE '%RenameTable%')

		BEGIN
			SET @Params_In_SQL_Out = 'Procedure named "' + ISNULL(@Proc_Name,'NULL') + '" was not found. Check proc names below:'
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + 'Distibution				(returning Table DISRTIBUTION String for using in CREATE Table statement)'
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + 'Index						(returning Table INDEX String for using in CREATE Table statement)'
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + 'Partition					(returning Table PARTITION String for using in CREATE Table statement)'
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + 'Select						(returning the String with the list of fields delimited with comma for using in SELECT statement)'
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + 'CreateEmptySwitchTable		(returning CREATE EMPTY Table with "Switch" suffix for ALTER TABLE SWITCH query)'
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + 'CreateTableAs				(returning CREATE Table WITH(..) AS SELECT.. query)'
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + 'DropStatistics				(returning DROP STATISTICS .. queries)'
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + 'CreateStatistics			(returning CREATE STATISTICS .. queries)'
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + 'RenameTable				(returning RENAME Table query. Renaming from TableName_NEW_SET to TableName)'
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + CHAR(10) + 'It is possible to call several procs at once, separate them with comma like <<DropStatistics, CreateStatistics>>'

		END
		IF CHARINDEX('NoPrint',@Params) = 0
			EXEC Utility.LongPrint @Params_In_SQL_Out
	END
END


