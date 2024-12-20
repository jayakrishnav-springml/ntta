CREATE PROC [Utility].[Get_UpdatedDate] @Table_Name [VARCHAR](130),@Last_Updated_Date [DATETIME2](3) OUT AS

/*
USE LND_TBOS 
GO
IF OBJECT_ID ('Utility.Get_UpdatedDate', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_UpdatedDate
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Last_Updated_Date DATETIME2(3), @Table_Name VARCHAR(200)  = 'Finance.BankPayments'
EXEC Utility.Get_UpdatedDate @Table_Name, @Last_Updated_Date OUTPUT 
PRINT @Last_Updated_Date
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc is getting the last update date for table in the Utility.LoadProcessControl table or from table itself (if there is no in utility)

@Table_Name - table name for wich new Updated date is getting
@Last_Updated_Date - returning parameter 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
###################################################################################################################
*/
BEGIN

	SET NOCOUNT ON

	SELECT @Last_Updated_Date = LastUpdatedDate
	FROM Utility.LoadProcessControl
	WHERE TableName = @Table_Name

	IF @Last_Updated_Date IS NULL
	BEGIN
		BEGIN TRY
			
			DECLARE @FullName VARCHAR(130) = REPLACE(REPLACE(@Table_Name,'[',''),']',''), @UpdatedDateColumn VARCHAR(100)

			SELECT @UpdatedDateColumn = UpdatedDateColumn FROM Utility.TableLoadParameters
			WHERE FullName = @FullName

			IF ISNULL(@UpdatedDateColumn,'') <> ''
			BEGIN
				DECLARE @ParmDefinition NVARCHAR(100) = N'@UpdatedDate DATETIME2(3) OUTPUT'
				DECLARE @Nsql NVARCHAR(400)

				SET @Nsql = '
				SELECT @UpdatedDate = MAX(' + @UpdatedDateColumn + ')
				FROM ' + @Table_Name
				PRINT @Nsql
				EXECUTE sp_executesql @Nsql, @ParmDefinition, @UpdatedDate = @Last_Updated_Date OUTPUT  
			END

		END	TRY	
		BEGIN CATCH
			SET @Last_Updated_Date = '1990-01-01'
		END CATCH
	END

	IF @Last_Updated_Date IS NULL
	BEGIN
		SET @Last_Updated_Date = '1990-01-01'
	END

END


