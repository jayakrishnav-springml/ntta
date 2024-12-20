CREATE PROC [Utility].[Set_UpdatedDate] @Table_Name [VARCHAR](200),@Source_Name [VARCHAR](200),@Last_Updated_Date [DATETIME2](3) OUT AS

/*
IF OBJECT_ID ('Utility.Set_UpdatedDate', 'P') IS NOT NULL DROP PROCEDURE Utility.Set_UpdatedDate
GO

###################################################################################################################
!!!!!!!!!  THIS PROCEDURE IS FOR EDW_TRIPS Database ONLY, NOT FOR LND_TBOS  !!!!!!!!!!!
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
@Source_Name - Source table from where the last UpdatedDate it should take using MAX(LND_UpdateDate)
@Last_Updated_Date - Exact date to set
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
CHG0038319 	Andy		2021-03-08  Changed to work based on LND_UpdateDate
CHG0038458 Andy 03/30/2021 made it to clean update date if send NULL to both parameters
###################################################################################################################
*/
BEGIN

	SET NOCOUNT ON
	DECLARE @FullName VARCHAR(130) = REPLACE(REPLACE(@Table_Name,'[',''),']',''), @EDW_UpdateDate DATETIME2(3) = SYSDATETIME()

	IF @Table_Name IS NULL
		SET @Table_Name = @Source_Name

	IF @Last_Updated_Date IS NULL AND NULLIF(@Source_Name,'') IS NOT NULL
	BEGIN
		DECLARE @ParmDefinition NVARCHAR(100) = N'@UpdatedDate DATETIME2(3) OUTPUT'
		DECLARE @Nsql NVARCHAR(400)
		SET @Nsql = 'SELECT @UpdatedDate = MAX(LND_UpdateDate) FROM ' + @Source_Name
		BEGIN TRY
			EXECUTE sp_executesql @Nsql, @ParmDefinition, @UpdatedDate = @Last_Updated_Date OUTPUT  
		END	TRY	
		BEGIN CATCH
			SET @Last_Updated_Date = '1990-01-01'
		END CATCH
	END

	DELETE FROM Utility.LoadProcessControl WHERE TableName = @FullName
	-- If nothing sent (neither @Last_Updated_Date nor @Source_Name) we just removing Updated date

	IF @Last_Updated_Date IS NOT NULL
	BEGIN
		INSERT INTO Utility.LoadProcessControl 
			(
				TableName,
				LastUpdatedDate,
				EDW_UpdateDate
			)
		VALUES 
			(
				@FullName,
				@Last_Updated_Date,
				@EDW_UpdateDate
			)
	END
END


