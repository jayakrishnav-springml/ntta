CREATE PROC [Utility].[Set_UpdatedDate] @Table_Name [VARCHAR](200),@Source_Name [VARCHAR](200),@Last_Updated_Date [DATETIME2](3) AS

/*
USE LND_TBOS 
GO
IF OBJECT_ID ('Utility.Set_UpdatedDate', 'P') IS NOT NULL DROP PROCEDURE Utility.Set_UpdatedDate
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
/* If you have table from where have to get UpdatedDate  */
EXEC Utility.Set_UpdatedDate 'Dim_Customer\TP_Customer_Addresses', 'LND_TBOS.TollPlus.TP_Customer_Addresses', NULL

/* When you have date you have to set */
DECLARE @Last_Updated_Date DATETIME2(3) = GETDATE()
EXEC Utility.Set_UpdatedDate 'Stage.TP_Trips', NULL, @Last_Updated_Date 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc is setting the last update date for table in the Utility.LoadProcessControl table
Can work differently = either taking sent parameter @Last_Updated_Date (exact date) or getting the last update date from sent source table

@Table_Name - table name for wich new Updated date is setting
@Source_Name - Source table from where the last UpdatedDate it should take using MAX(UpdatedDate)
@Last_Updated_Date - Exact date to set
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
###################################################################################################################
*/
BEGIN

	SET NOCOUNT ON

	IF @Table_Name IS NULL
		SET @Table_Name = @Source_Name

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
				FROM ' + @Source_Name
				PRINT @Nsql
				EXECUTE sp_executesql @Nsql, @ParmDefinition, @UpdatedDate = @Last_Updated_Date OUTPUT  
			END

		END	TRY	
		BEGIN CATCH
			SET @Last_Updated_Date = '1990-01-01'
		END CATCH
	END

	DELETE FROM Utility.LoadProcessControl
	WHERE TableName = @Source_Name

	DECLARE @RowUpdateDate DATETIME2(3) = SYSDATETIME()

	INSERT INTO Utility.LoadProcessControl 
		(
			TableName,
			LastUpdatedDate,
			RowUpdateDate
		)
	VALUES 
		(
			@Source_Name,
			@Last_Updated_Date,
			@RowUpdateDate
		)
END

 
