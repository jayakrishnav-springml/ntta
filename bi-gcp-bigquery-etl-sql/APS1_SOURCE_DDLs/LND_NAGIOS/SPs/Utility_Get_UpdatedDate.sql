CREATE PROC [Utility].[Get_UpdatedDate] @Table_Name [VARCHAR](130),@Last_Updated_Date [DATETIME2](3) OUT AS

/*
USE EDW_NAGIOS_DEV
GO
IF OBJECT_ID ('Utility.Get_UpdatedDate', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_UpdatedDate
GO

###################################################################################################################
!!!!!!!!!  THIS PROCEDURE IS FOR EDW_TRIPS Database ONLY, NOT FOR LND_TBOS  !!!!!!!!!!!
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Last_Updated_Date DATETIME2(3), @Table_Name VARCHAR(130)  = 'Finance.BankPayments', @Column_Name VARCHAR(130)  = 'LND_UpdateDate'
EXEC Utility.Get_UpdatedDate @Table_Name, @Column_Name, @Last_Updated_Date OUTPUT 
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
CHG0038319 	Andy		2021-03-08  Changed to work based on LND_UpdateDate
###################################################################################################################
*/
BEGIN

	SET NOCOUNT ON
	DECLARE @FullName VARCHAR(130) = REPLACE(REPLACE(@Table_Name,'[',''),']','')
	DECLARE @Schema VARCHAR(100), @Table VARCHAR(200)
	DECLARE @Dot INT = CHARINDEX('.',@Table_Name)
	DECLARE @UpdateDateColumn VARCHAR(100)

	SELECT 
		@Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot),'[',''),']',''),'.','') END,
		@Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot + 1,200),'[',''),']','') END
	
	SELECT @Last_Updated_Date = LastUpdatedDate
	FROM Utility.LoadProcessControl
	WHERE TableName = @FullName

	IF @Last_Updated_Date IS NULL
	BEGIN
		SELECT TOP 1
			@UpdateDateColumn = ColumnName
		FROM (
			SELECT      c.name AS ColumnName, 1 AS OrderInt
			FROM        sys.columns c
			JOIN        sys.Tables  t   ON c.object_id = t.object_id AND t.Name = @Table
			JOIN		sys.schemas s ON t.schema_id = s.schema_id AND s.Name = @Schema
			WHERE c.name = 'LND_UpdateDate'
			UNION ALL
			SELECT      c.name AS ColumnName, 2 AS OrderInt
			FROM        sys.columns c
			JOIN        sys.Tables  t   ON c.object_id = t.object_id AND t.Name = @Table
			JOIN		sys.schemas s ON t.schema_id = s.schema_id AND s.Name = @Schema
			WHERE c.name = 'UpdatedDate'
			UNION ALL
			SELECT      c.name AS ColumnName, 3 AS OrderInt
			FROM        sys.columns c
			JOIN        sys.Tables  t   ON c.object_id = t.object_id AND t.Name = @Table
			JOIN		sys.schemas s ON t.schema_id = s.schema_id AND s.Name = @Schema
			WHERE c.name = 'EDW_UpdateDate'
			) A
		ORDER BY OrderInt Asc

		IF @UpdateDateColumn IS NOT NULL
		BEGIN
			DECLARE @ParmDefinition NVARCHAR(100) = N'@UpdatedDate DATETIME2(3) OUTPUT'
			DECLARE @Nsql NVARCHAR(400)
			SET @Nsql = 'SELECT @UpdatedDate = MAX(' + @UpdateDateColumn + ')	FROM ' + @FullName
			BEGIN TRY
				EXECUTE sp_executesql @Nsql, @ParmDefinition, @UpdatedDate = @Last_Updated_Date OUTPUT  
			END	TRY	
			BEGIN CATCH
				SET @Last_Updated_Date = '1990-01-01'
			END CATCH
		END
	END

	IF @Last_Updated_Date IS NULL
		SET @Last_Updated_Date = '1990-01-01'

END


