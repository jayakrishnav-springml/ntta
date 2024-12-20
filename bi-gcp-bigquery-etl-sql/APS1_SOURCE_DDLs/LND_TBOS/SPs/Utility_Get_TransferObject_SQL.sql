CREATE PROC [Utility].[Get_TransferObject_SQL] @SOURCE_TABLE [VARCHAR](130),@DESTINATION_TABLE [VARCHAR](130),@Params_In_SQL_Out [VARCHAR](4000) OUT AS
/*
USE LND_TBOS
GO
IF OBJECT_ID ('Utility.Get_TransferObject_SQL', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_TransferObject_SQL
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'No[]'
EXEC Utility.Get_TransferObject_SQL 'Stage.TP_Customers', '[TollPlus].[TP_Customers]', @Params_In_SQL_Out OUTPUT 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning SQL statement to transfer and/or rename table to a New table.
If New table exists - it moves it to schema Old with the same name. If sent parameter KeepOld - this table will not be deletted in the end


@SOURCE_TABLE - Table name (with Schema) is table to move (may be with statistics). Can't be Null.
@DESTINATION_TABLE - Table name our table to have in the end. Schema and/or name can fiffer from source. Can't be Null.
@Params_In_SQL_Out - Param to return SQL statement. Can take some secondary parameters
	can include values: 	'No[],NoPrint,KeepOld'

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
###################################################################################################################
*/

BEGIN
	/*====================================== TESTING =======================================================================*/
	--DECLARE @Table_Name VARCHAR(4000) = '[TollPlus].[TP_Customers]', @New_Table_Name VARCHAR(200), @Params_In_SQL_Out VARCHAR(MAX) 
	/*====================================== TESTING =======================================================================*/

	DECLARE @Error VARCHAR(MAX) = '', @Trace_Flag BIT = 0 -- Testing
	DECLARE @Params VARCHAR(100) = ISNULL(@Params_In_SQL_Out,'')
	DECLARE @Table_Name VARCHAR(200) = @SOURCE_TABLE,	@New_Table_Name VARCHAR(100) = @DESTINATION_TABLE

	IF @Table_Name IS NULL SET @Error = @Error + 'Source Table name cannot be NULL'
	IF @New_Table_Name IS NULL SET @Error = @Error + 'Target Table name cannot be NULL'

	IF @Trace_Flag = 1 PRINT ('@Table_Name = ' + @Table_Name + '; @New_Table_Name = ' + @New_Table_Name)

	IF @Table_Name = @New_Table_Name SET @Error = @Error + 'Source and Target Tables are the same <<' + @Table_Name + '>> - no need to do anything'

	SET @Params_In_SQL_Out = '';

	IF LEN(@Error) > 0
	BEGIN
		PRINT @Error
		SET @Params_In_SQL_Out = 'Error: ' + @Error
	END
	ELSE
	BEGIN

		DECLARE @Schema VARCHAR(100), @Table VARCHAR(200), @New_Schema VARCHAR(100), @New_Table VARCHAR(200)
		DECLARE @Dot1 INT = CHARINDEX('.',@Table_Name), @Dot2 INT = CHARINDEX('.',@New_Table_Name)
		SELECT 
			@Schema = CASE WHEN @Dot1 = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot1),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot1 = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot1 + 1,200),'[',''),']','') END,
			@New_Schema = CASE WHEN @Dot2 = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@New_Table_Name,@Dot2),'[',''),']',''),'.','') END,
			@New_Table = CASE WHEN @Dot2 = 0 THEN REPLACE(REPLACE(@New_Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@New_Table_Name,@Dot2 + 1,200),'[',''),']','') END

		IF @Trace_Flag = 1 PRINT ('@Schema = ' + @Schema + '; @Table = ' + @Table + '; @New_Schema = ' + @New_Schema + '; @New_Table = ' + @New_Table)

		SET @Params_In_SQL_Out = CHAR(13) + 'IF OBJECT_ID(''' + @New_Schema + '.[' + @New_Table + '_Old]'',''U'') IS NOT NULL			DROP TABLE ' + @New_Schema + '.[' + @New_Table + '_Old];' 
								 + CHAR(13) + 'IF OBJECT_ID(''' + @New_Schema + '.[' + @New_Table + ']'',''U'') IS NOT NULL		RENAME OBJECT::' + @New_Schema + '.[' + @New_Table + '] TO [' + @New_Table + '_Old];'
		IF @New_Schema = @Schema -- We have to rename Table only
		BEGIN
			IF @Trace_Flag = 1 PRINT ('@Schema = ' + @Schema + ' is equal to @New_Schema = ' + @New_Schema + ' - use RENAME!')
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + 'IF OBJECT_ID(''' + @Schema + '.[' + @Table + ']'') IS NOT NULL		RENAME OBJECT::' + @Schema + '.[' + @Table + '] TO [' + @New_Table + '];'
		END
		ELSE -- Different schema - need to use TRANSFER
		BEGIN
			DECLARE @RanameBack VARCHAR(200) = ''
			IF @Trace_Flag = 1 PRINT ('@Schema = ' + @Schema + ' is NOT equal to @New_Schema = ' + @New_Schema + ' - use TRANSFER!')

			IF @New_Table <> @Table -- We have to rename Table first, then transfer with a New name
			BEGIN
				IF OBJECT_ID(@Schema + '.[' + @New_Table + ']') IS NOT NULL -- The Table with a New name already exists - have to temporery move it
				BEGIN
					IF @Trace_Flag = 1 PRINT ('Table ' + @Schema + '.' + @New_Table + ' is already exists - need to transfer it to temp schema and back')

					SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + '/* Table ' + @Schema + '.' + @New_Table + ' is already exists - need to transfer it to temp schema and back */'
					SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + 'IF OBJECT_ID(''Temp.[' + @New_Table + ']'',''U'') IS NOT NULL		DROP TABLE Temp.[' + @New_Table + '];' + 
						CHAR(13) + 'IF OBJECT_ID(''' + @Schema + '.[' + @New_Table + ']'',''U'') IS NOT NULL	ALTER SCHEMA Temp TRANSFER OBJECT::' + @Schema + '.[' + @New_Table + '];'
					SET @RanameBack = CHAR(13) + 'IF OBJECT_ID(''Temp.[' + @New_Table + ']'',''U'') IS NOT NULL		ALTER SCHEMA ' + @Schema + ' TRANSFER OBJECT::Temp.[' + @New_Table + '];'
				END

				IF @Trace_Flag = 1 PRINT ('@Table = ' + @Table + ' is NOT equal to @New_Table = ' + @New_Table + ' - use TRANSFER!')

				SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + 'IF OBJECT_ID(''' + @Schema + '.[' + @Table + ']'',''U'') IS NOT NULL		RENAME OBJECT::' + @Schema + '.[' + @Table + '] TO [' + @New_Table + '];'

			END
	
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + 'IF OBJECT_ID(''' + @Schema + '.[' + @New_Table + ']'',''U'') IS NOT NULL			ALTER SCHEMA ' + @New_Schema + ' TRANSFER OBJECT::' + @Schema + '.[' + @New_Table + '];' + @RanameBack
		END
		IF CHARINDEX('KeepOld',@Params) = 0
			SET @Params_In_SQL_Out = @Params_In_SQL_Out + CHAR(13) + 'IF OBJECT_ID(''' + @New_Schema + '.[' + @New_Table + '_Old]'',''U'') IS NOT NULL			DROP TABLE ' + @New_Schema + '.[' + @New_Table + '_Old];' 
		IF CHARINDEX('No[]',@Params) > 0
			SET @Params_In_SQL_Out = REPLACE(REPLACE(@Params_In_SQL_Out,'[',''),']','')

		IF CHARINDEX('NoPrint',@Params) = 0
			EXEC Utility.LongPrint @Params_In_SQL_Out

	END

END
