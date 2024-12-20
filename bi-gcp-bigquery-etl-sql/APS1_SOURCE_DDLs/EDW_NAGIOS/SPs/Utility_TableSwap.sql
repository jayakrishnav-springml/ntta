CREATE PROC [Utility].[TableSwap] @Source_Table_Name [VARCHAR](100),@Target_Table_Name [VARCHAR](100) AS
/*
###################################################################################################################
Purpose: Change New Table to Main Table. Source Table becomes Target Table!
Note   : Source and Target tables should have same table names but different schema names for schema transfer to work
-------------------------------------------------------------------------------------------------------------------
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0000000	Shankar	2020-08-12	New!
-------------------------------------------------------------------------------------------------------------------
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.TableSwap 'dbo.Dim_CollectionStatus_NEW', 'dbo.Dim_CollectionStatus'
###################################################################################################################
*/

BEGIN

	BEGIN TRY
		-- DEBUG
		-- DECLARE @Source_Table_Name VARCHAR(100) = 'New.Dim_CollectionStatus', @Target_Table_Name VARCHAR(100) = 'dbo.Dim_CollectionStatus'
		
		DECLARE @Log_Source VARCHAR(100) = COALESCE(@Target_Table_Name, @Source_Table_Name, 'NULL'), @Log_Start_Date DATETIME2 (3) = SYSDATETIME(); 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 1; -- For testing
		
		--:: Early input parameter screening
		IF @Source_Table_Name IS NULL SET @Log_Message = '@Source_Table_Name param is NULL'
		IF @Target_Table_Name IS NULL SET @Log_Message = ISNULL(@Log_Message + ', ','') + '@Target_Table_Name param is NULL';
		IF @Source_Table_Name = @Target_Table_Name SET @Log_Message = 'Source table and target table names are identical! Transfer ' + REPLACE(REPLACE(@Source_Table_Name,'[',''),']','') + ' to ' + REPLACE(REPLACE(@Target_Table_Name,'[',''),']','') + '?'
		IF @Source_Table_Name IS NULL OR @Target_Table_Name IS NULL OR @Source_Table_Name = @Target_Table_Name
			THROW 51000, @Log_Message,1;

		DECLARE @Source_Table VARCHAR(100) = '', @Source_Schema VARCHAR(50) = '', @Target_Table VARCHAR(100) = '', @Target_Schema VARCHAR(50) = '', @SQL VARCHAR(2000);
		DECLARE @dot1 INT = CHARINDEX('.',@Source_Table_Name), @dot2 INT = CHARINDEX('.',@Target_Table_Name);

		IF @dot1 = 0
			SELECT @Source_Schema = 'dbo', @Source_Table = REPLACE(REPLACE(@Source_Table_Name,'[',''),']','');
		ELSE
			SELECT @Source_Schema = LEFT(@Source_Table_Name, @dot1 - 1), @Source_Table = REPLACE(REPLACE(SUBSTRING(@Source_Table_Name,@dot1 + 1,100),'[',''),']','');

		IF @dot2 = 0
			SELECT @Target_Schema = 'dbo', @Target_Table = REPLACE(REPLACE(@Target_Table_Name,'[',''),']','');
		ELSE
			SELECT @Target_Schema = LEFT(@Target_Table_Name ,@dot2 - 1), @Target_Table = REPLACE(REPLACE(SUBSTRING(@Target_Table_Name,@dot2 + 1,100),'[',''),']','');
		
		--PRINT '@Source_Schema: ' + @Source_Schema + ', @Source_Table: ' + @Source_Table + ', @Target_Schema: ' + @Target_Schema + ', @Target_Table: ' + @Target_Table

		--:: Schema Transfer
		IF @Source_Schema <> @Target_Schema AND @Source_Table = @Target_Table
		BEGIN
			SET @SQL =	CHAR(9) + CHAR(9) + 'IF OBJECT_ID(''Old.' + @Target_Table + ''',''U'') IS NOT NULL		DROP TABLE Old.' + @Target_Table + CHAR(13) + CHAR(10) +
						CHAR(9) + CHAR(9) + 'IF OBJECT_ID(''' + @Target_Table_Name + ''',''U'') IS NOT NULL		ALTER SCHEMA Old TRANSFER OBJECT::' + @Target_Table_Name + ' -- Move existing table to Old schema' + CHAR(13) + CHAR(10) +
						CHAR(9) + CHAR(9) + 'IF OBJECT_ID(''' + @Source_Table_Name + ''',''U'') IS NOT NULL		ALTER SCHEMA ' + @Target_Schema + ' TRANSFER OBJECT::' + @Source_Table_Name + '-- Transfer schema ' + CHAR(13) + CHAR(10) + 
						CHAR(9) + CHAR(9) + 'IF OBJECT_ID(''Old.' + @Target_Table + ''',''U'') IS NOT NULL		DROP TABLE Old.' + @Target_Table

			IF @Trace_Flag = 1 PRINT @SQL;
			EXEC (@SQL);
		END
        ELSE
		IF @Source_Schema = @Target_Schema AND @Source_Table <> @Target_Table
		BEGIN
			SET @SQL =	CHAR(9) + CHAR(9) + 'IF OBJECT_ID(''' + @Source_Schema + '.' + @Target_Table + '_OLD'',''U'') IS NOT NULL		DROP TABLE ' + @Source_Schema + '.' + @Target_Table + '_OLD' + CHAR(13) + CHAR(10) +
						CHAR(9) + CHAR(9) + 'IF OBJECT_ID(''' + @Source_Schema + '.' + @Target_Table + ''',''U'') IS NOT NULL		RENAME OBJECT::' + @Source_Schema + '.' + @Target_Table + ' TO ' + @Target_Table + '_OLD -- Rename existing table to _OLD' + CHAR(13) + CHAR(10) +
						CHAR(9) + CHAR(9) + 'IF OBJECT_ID(''' + @Source_Table_Name + ''',''U'') IS NOT NULL		RENAME OBJECT::' + @Source_Table_Name + ' TO ' + @Target_Table + ' -- Rename table' + CHAR(13) + CHAR(10) +
						CHAR(9) + CHAR(9) + 'IF OBJECT_ID(''Old.' + @Target_Table + ''',''U'') IS NOT NULL		DROP TABLE ' + @Source_Schema + '.' + @Target_Table + '_OLD'

			IF @Trace_Flag = 1 PRINT @SQL;
			EXEC (@SQL);
		END
        ELSE
		IF @Source_Schema <> @Target_Schema AND @Source_Table <> @Target_Table
		BEGIN
			SET @SQL =	CHAR(9) + CHAR(9) + 'IF OBJECT_ID(''Old.' + @Target_Table + ''',''U'') IS NOT NULL		DROP TABLE Old.' + @Target_Table + CHAR(13) + CHAR(10) +
						CHAR(9) + CHAR(9) + 'IF OBJECT_ID(''' + @Target_Table_Name + ''',''U'') IS NOT NULL		ALTER SCHEMA Old TRANSFER OBJECT::' + @Target_Table_Name + ' -- Move existing table to Old schema' + CHAR(13) + CHAR(10) +
						CHAR(9) + CHAR(9) + 'IF OBJECT_ID(''' + @Source_Schema + '.' + @Target_Table + ''',''U'') IS NOT NULL		DROP TABLE ' + @Source_Schema + '.' + @Target_Table + ' -- Clear the way for rename before schema transfer' + CHAR(13) + CHAR(10) + 
						CHAR(9) + CHAR(9) + 'IF OBJECT_ID(''' + @Source_Table_Name + ''',''U'') IS NOT NULL		RENAME OBJECT::' + @Source_Table_Name + ' TO ' + @Target_Table + ' -- Rename. Same table names, different schema names in the end' + CHAR(13) + CHAR(10) + 
						CHAR(9) + CHAR(9) + 'IF OBJECT_ID(''' + @Source_Schema + '.' + @Target_Table + ''',''U'') IS NOT NULL		ALTER SCHEMA ' + @Target_Schema + ' TRANSFER OBJECT::' + @Source_Schema + '.' + @Target_Table + ' -- Transfer schema' + CHAR(13) + CHAR(10) +
						CHAR(9) + CHAR(9) + 'IF OBJECT_ID(''Old.' + @Target_Table + ''',''U'') IS NOT NULL		DROP TABLE Old.' + @Target_Table

			IF @Trace_Flag = 1 PRINT @SQL;
			EXEC (@SQL);
		END
		ELSE
		BEGIN
			SET @Log_Message = 'Cannot swap table ' + REPLACE(REPLACE(@Source_Table_Name,'[',''),']','') + ' to ' + REPLACE(REPLACE(@Target_Table_Name,'[',''),']','');  
			THROW 51000, @Log_Message,1;
		END

		SET  @Log_Message = 'Completed ' + @Target_Schema + '.' + @Target_Table + ' table swap'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

	END	TRY
	
	BEGIN CATCH
		
		DECLARE @Error_Message VARCHAR(MAX) = 'Utility.TableSwap Error: ' + ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		THROW;  -- Rethrow the error!
	
	END CATCH
END

/*
-- Developer Testing Zone 

EXEC Utility.TableSwap 'New.Dim_CollectionStatus', 'dbo.Dim_CollectionStatus'
EXEC Utility.TableSwap null, 'dbo.Dim_CollectionStatus'
EXEC Utility.TableSwap 'New.Dim_CollectionStatus', null
EXEC Utility.TableSwap null, null
EXEC Utility.TableSwap 'New.Dim_CollectionStatus', 'New.Dim_CollectionStatus'

EXEC Utility.FromLog 'Dim_CollectionStatus', 1;
*/


