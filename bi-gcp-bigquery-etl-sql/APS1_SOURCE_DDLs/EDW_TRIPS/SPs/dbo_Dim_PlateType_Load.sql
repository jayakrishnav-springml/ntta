CREATE PROC [dbo].[Dim_PlateType_Load] @IsFullLoad [BIT] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_PlateType table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Andy		YYYY-MM-DD	New!
===================================================================================================================

Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_PlateType_Load @IsFullLoad = 1

EXEC Utility.FromLog 'dbo.Dim_PlateType', 1
SELECT 'dbo.Dim_PlateType' Table_Name, * FROM dbo.Dim_PlateType ORDER BY 2 
###################################################################################################################
*/
BEGIN

	DECLARE @TableName VARCHAR(100) = 'dbo.Dim_PlateType', @StageTableName VARCHAR(100) = 'dbo.Dim_PlateType_new', @ColumnName VARCHAR(100) = 'PlateType'
	DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_PlateType_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME(), @MAX_ID INT = 0
	DECLARE @Log_Message VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing
	DECLARE @Last_Updated_Date DATETIME2(3), @sql VARCHAR(MAX)

	IF OBJECT_ID(@TableName) IS NULL
		SET @IsFullLoad = 1

	IF @IsFullLoad = 1
	BEGIN

		SET @Log_Message = 'Started Full load'
		IF @Trace_Flag = 1 PRINT @Log_Message
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		IF OBJECT_ID('dbo.Dim_PlateType_new','U') IS NOT NULL			DROP TABLE dbo.Dim_PlateType_new;
		CREATE TABLE dbo.Dim_PlateType_new WITH (HEAP, DISTRIBUTION = REPLICATE) AS
		SELECT ROW_NUMBER() OVER (ORDER BY PlateType) AS PlateTypeID, PlateType
		FROM (
					SELECT
						RTRIM(LTRIM(PlateType)) AS PlateType 
					FROM LND_TBOS.TOLLPLUS.TP_TRIPS
					WHERE PlateType IS NOT NULL
					GROUP BY RTRIM(LTRIM(PlateType))
				) A
		UNION ALL
		SELECT -1 AS PlateTypeID, 'Unknown' AS PlateType
		OPTION (LABEL = 'dbo.Dim_PlateType_new');

		SET  @Log_Message = 'Loaded ' + @StageTableName
		EXEC Utility.FastLog @Log_Source, @Log_Message, -1

		EXEC Utility.Get_TransferObject_SQL @StageTableName, @TableName, @SQL OUTPUT 
		IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
		EXEC (@sql)

		SET @Log_Message = 'Finished full load'

	END
	ELSE
	BEGIN
		SELECT @MAX_ID = MAX(PlateTypeID) FROM dbo.Dim_PlateType
		EXEC Utility.Get_UpdatedDate 'Dim_PlateType/TOLLPLUS.TP_TRIPS', @Last_Updated_Date OUTPUT 
		SET @Log_Message = 'Started Incremental load from: ' + CONVERT(VARCHAR(25),@Last_Updated_Date,121)
		IF @Trace_Flag = 1 PRINT @Log_Message
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		IF OBJECT_ID('dbo.Dim_PlateType_new','U') IS NOT NULL			DROP TABLE dbo.Dim_PlateType_new;
		CREATE TABLE dbo.Dim_PlateType_new WITH (HEAP, DISTRIBUTION = REPLICATE) AS
		SELECT @MAX_ID + ROW_NUMBER() OVER (ORDER BY PlateType) AS PlateTypeID, PlateType
		FROM (
					SELECT
						RTRIM(LTRIM(PlateType)) AS PlateType 
					FROM LND_TBOS.TOLLPLUS.TP_TRIPS
					WHERE PlateType IS NOT NULL AND UpdatedDate >= @Last_Updated_Date
					GROUP BY RTRIM(LTRIM(PlateType))
				) A
		WHERE PlateType NOT IN (SELECT PlateType FROM dbo.Dim_PlateType)
		OPTION (LABEL = 'dbo.Dim_PlateType_new');

		SET  @Log_Message = 'Loaded ' + @StageTableName
		EXEC Utility.FastLog @Log_Source, @Log_Message, -1

		IF @Trace_Flag = 1 EXEC Utility.LongPrint 'INSERT INTO dbo.Dim_PlateType SELECT * FROM dbo.Dim_PlateType_new'
		INSERT INTO dbo.Dim_PlateType SELECT * FROM dbo.Dim_PlateType_new

		SET @Log_Message = 'Finished Incremental load from: ' + CONVERT(VARCHAR(25),@Last_Updated_Date,121)

	END

	EXEC Utility.Set_UpdatedDate 'Dim_PlateType/TOLLPLUS.TP_TRIPS', 'LND_TBOS.TOLLPLUS.TP_TRIPS', NULL 

	IF @Trace_Flag = 1 PRINT @Log_Message
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

END


/*
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_PlateType_Load @IsFullLoad = 1

EXEC Utility.FromLog 'dbo.Dim_PlateType', 1
SELECT count(*) 'dbo.Dim_PlateType' Table_Name, * FROM dbo.Dim_PlateType ORDER BY 2 


*/
