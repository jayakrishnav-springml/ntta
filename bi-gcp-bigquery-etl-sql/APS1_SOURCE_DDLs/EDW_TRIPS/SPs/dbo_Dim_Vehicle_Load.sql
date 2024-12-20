CREATE PROC [dbo].[Dim_Vehicle_Load] @IsFullLoad [BIT] AS
/*
IF OBJECT_ID ('dbo.Dim_Vehicle_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Dim_Vehicle_Load
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_Vehicle_Load 1

EXEC Utility.FromLog 'dbo.Dim_Vehicle', 1
SELECT 'LND_TBOS.TollPlus.TP_Customer_Vehicles' Table_Name, COUNT_BIG(1) Row_Count FROM LND_TBOS.TollPlus.TP_Customer_Vehicles
SELECT 'dbo.Dim_Vehicle' Table_Name, COUNT_BIG(1) Row_Count FROM dbo.Dim_Vehicle  
SELECT TOP 100 * FROM dbo.Dim_Vehicle
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_Vehicle table. 

@IsFullLoad - 1 means forced Full load, 0 or NULL - incremental load. I the main table is not exists - it goes with full load.

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0038319 	Andy		2021-03-08	New!

###################################################################################################################
*/

BEGIN

	/*====================================== TESTING =======================================================================*/
	--DECLARE @IsFullLoad BIT = 1 
	/*====================================== TESTING =======================================================================*/

	DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_Vehicle_Load', @TableName VARCHAR(50) = 'dbo.Dim_Vehicle', @StageTableName VARCHAR(100) = 'dbo.Dim_Vehicle_NEW'
	DECLARE @Log_Start_Date DATETIME2(3) = SYSDATETIME(), @Log_Message VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing
	DECLARE @Last_UpdatedDate DATETIME2(3), @IdentifyingColumns VARCHAR(100) = '[VehicleID]' 
	DECLARE @sql VARCHAR(MAX), @WhereSql VARCHAR(8000) = ''

	IF OBJECT_ID(@TableName) IS NULL
		SET @IsFullLoad = 1

	IF @IsFullLoad = 1
	BEGIN
		SET @Log_Message = 'Started Full load'
		IF @Trace_Flag = 1 PRINT @Log_Message
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

		IF OBJECT_ID('dbo.Dim_Vehicle_NEW','U') IS NOT NULL			DROP TABLE dbo.Dim_Vehicle_NEW;
		CREATE TABLE dbo.Dim_Vehicle_NEW WITH (CLUSTERED INDEX (VehicleID),  DISTRIBUTION = HASH(CustomerID)) AS
		--EXPLAIN
		SELECT 
			ISNULL(CAST(TP_Customer_Vehicles.VehicleID AS bigint), -1) AS VehicleID
			, ISNULL(CAST(TP_Customer_Vehicles.CustomerID AS bigint), -1) AS CustomerID
			, CAST(TP_Customer_Vehicles.VehicleNumber AS varchar(20)) AS LicensePlateNumber
			, ISNULL(CAST(TP_Customer_Vehicles.VehicleState AS varchar(2)), '') AS LicensePlateState
			, ISNULL(CAST(TP_Customer_Vehicles.VehicleCountry AS varchar(5)), '') AS LicensePlateCountry
			, CAST(TP_Customer_Vehicles.[Year] AS smallint) AS VehicleYear
			, CAST(TP_Customer_Vehicles.Make AS varchar(50)) AS VehicleMake
			, CAST(TP_Customer_Vehicles.Model AS varchar(50)) AS VehicleModel
			, CAST(TP_Customer_Vehicles.Color AS varchar(50)) AS VehicleColor
			, ISNULL(CAST(TP_Customer_Vehicles.StartEffectiveDate AS datetime2(3)), '1900-01-01') AS VehicleStartDate
			, ISNULL(CAST(TP_Customer_Vehicles.EndEffectiveDate AS datetime2(3)), '9999-12-31') AS VehicleEndDate
			, ISNULL(CAST(TP_Customer_Vehicles.VehicleStatusID AS int), -1) AS VehicleStatusID
			, ISNULL(CAST(VehicleStatus.VehicleStatusCode AS VARCHAR(15)), 'Unknown') AS VehicleStatusCode
			, ISNULL(CAST(VehicleStatus.VehicleStatusDesc AS VARCHAR(50)), 'Unknown') AS VehicleStatusDesc
			, ISNULL(CAST(TP_Customer_Vehicles.VehicleClassCode AS SMALLINT), -1) AS VehicleClassID
			--, ISNULL(CAST(TP_Customer_Vehicles.VehicleClassCode AS varchar(2)), '-1') AS VehicleClass
			, CAST(TP_Customer_Vehicles.DocNo AS varchar(17)) AS DocNo
			, ISNULL(CAST(TP_Customer_Vehicles.TagID AS varchar(12)), '-1') AS TagID
			, CAST(TP_Customer_Vehicles.County AS varchar(20)) AS County
			, CAST(TP_Customer_Vehicles.VIN AS varchar(50)) AS VIN
			, ISNULL(CAST(TP_Customer_Vehicles.ContractualTypeID AS int), -1) AS ContractualTypeID
			, ISNULL(CAST(ContractualType.ContractualTypeCode AS VARCHAR(15)), 'Unknown') AS ContractualTypeCode
			, ISNULL(CAST(ContractualType.ContractualTypeDesc AS VARCHAR(100)), 'Unknown') AS ContractualTypeDesc
			--, ISNULL(CAST(Dim_PlateType.PlateTypeID AS INT), -1) AS PlateTypeID
			--, CAST(TP_Customer_Vehicles.IsProtected AS bit) AS IsProtected
			, ISNULL(CAST(TP_Customer_Vehicles.IsExempted AS bit), 0) AS ExemptedFlag
			--, CAST(TP_Customer_Vehicles.IsTempNumber AS bit) AS IsTempNumber
			, ISNULL(CAST(TP_Customer_Vehicles.IsInHV AS bit), 0) AS HVFlag
			--, ISNULL(CAST(TP_Customer_Vehicles.IsVRH AS bit), 0) AS IsVRH -- Vehicle Registration Block flag
			, ISNULL(CAST(TP_Customer_Vehicles.UpdatedDate AS datetime2(3)), '1900-01-01') AS UpdatedDate
			, ISNULL(CAST(TP_Customer_Vehicles.LND_UpdateDate AS datetime2(3)), '1900-01-01') AS LND_UpdateDate
			, ISNULL(@Log_Start_Date, '1900-01-01') AS EDW_UpdateDate -- SELECT * 
			--SELECT *
		FROM LND_TBOS.TollPlus.TP_Customer_Vehicles AS TP_Customer_Vehicles
		LEFT JOIN  dbo.Dim_ContractualType AS ContractualType ON ContractualType.ContractualTypeID = TP_Customer_Vehicles.ContractualTypeID
		LEFT JOIN  dbo.Dim_VehicleStatus AS VehicleStatus ON VehicleStatus.VehicleStatusID = TP_Customer_Vehicles.VehicleStatusID
		--LEFT JOIN  dbo.Dim_PlateType AS Dim_PlateType ON Dim_PlateType.PlateType = TP_Customer_Vehicles.PlateType
		--LEFT JOIN LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy AS VehicleStatus ON TP_Customer_Vehicles.VehicleStatusID = VehicleStatus.LookupTypeCodeID AND VehicleStatus.Parent_LookupTypeCodeID = 204
		UNION ALL
		SELECT
			-1 AS VehicleID
			, -1 AS CustomerID
			, '' AS LicensePlateNumber
			, '' AS LicensePlateState
			, '' AS LicensePlateCountry
			, 0 AS VehicleYear
			, '' AS VehicleMake
			, '' AS VehicleModel
			, '' AS VehicleColor
			, '1900-01-01' AS VehicleStartDate
			, '9999-12-31' AS VehicleEndDate
			, -1 AS VehicleStatusID
			, 'Unknown' AS VehicleStatusCode
			, 'Unknown' AS VehicleStatusDesc
			, -1 AS VehicleClassID
			, '' AS DocNo
			, '-1' AS TagID
			, '' AS County
			, '' AS VIN
			, -1 AS ContractualTypeID
			, 'Unknown' AS ContractualTypeCode
			, 'Unknown' AS ContractualTypeDesc
			--, -1 AS PlateTypeID
			--, 0 AS IsProtected
			, 0 AS ExemptedFlag
			--, 0 AS IsTempNumber
			, 0 AS HVFlag
			--, 0 AS IsVRH
			, '1900-01-01' AS UpdatedDate
			, '1900-01-01' AS LND_UpdateDate
			, @Log_Start_Date AS EDW_UpdateDate
		OPTION (LABEL = 'dbo.Dim_Vehicle_NEW');

		SET  @Log_Message = 'Loaded ' + @StageTableName
		EXEC Utility.FastLog @Log_Source, @Log_Message, -1

		CREATE STATISTICS Stats_dbo_Dim_Vehicle_001 ON dbo.Dim_Vehicle_NEW (CustomerID);
		CREATE STATISTICS STATS_dbo_Dim_Vehicle_002 ON dbo.Dim_Vehicle_NEW (LicensePlateNumber);
		CREATE STATISTICS STATS_dbo_Dim_Vehicle_003 ON dbo.Dim_Vehicle_NEW (TagID);
		CREATE STATISTICS STATS_dbo_Dim_Vehicle_005 ON dbo.Dim_Vehicle_NEW (VehicleStatusCode);
		CREATE STATISTICS STATS_dbo_Dim_Vehicle_006 ON dbo.Dim_Vehicle_NEW (VehicleClassID);
		CREATE STATISTICS STATS_dbo_Dim_Vehicle_007 ON dbo.Dim_Vehicle_NEW (HVFlag);

		-- Table swap!
		EXEC Utility.TableSwap @StageTableName, @TableName

		SET @Log_Message = 'Complited full load'

	END
	ELSE
	BEGIN
		EXEC Utility.Get_UpdatedDate @TableName, @Last_UpdatedDate  OUTPUT 
		SET @Log_Message = 'Started Incremental load from: ' + CONVERT(VARCHAR(25),@Last_UpdatedDate,121)

		IF @Trace_Flag = 1 PRINT @Log_Message
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

		IF OBJECT_ID('dbo.Dim_Vehicle_NEW','U') IS NOT NULL			DROP TABLE dbo.Dim_Vehicle_NEW;
		CREATE TABLE dbo.Dim_Vehicle_NEW WITH (CLUSTERED INDEX (VehicleID),  DISTRIBUTION = HASH(CustomerID)) AS
		--EXPLAIN
		SELECT 
			ISNULL(CAST(TP_Customer_Vehicles.VehicleID AS bigint), -1) AS VehicleID
			, ISNULL(CAST(TP_Customer_Vehicles.CustomerID AS bigint), -1) AS CustomerID
			, CAST(TP_Customer_Vehicles.VehicleNumber AS varchar(20)) AS LicensePlateNumber
			, ISNULL(CAST(TP_Customer_Vehicles.VehicleState AS varchar(2)), '') AS LicensePlateState
			, ISNULL(CAST(TP_Customer_Vehicles.VehicleCountry AS varchar(5)), '') AS LicensePlateCountry
			, CAST(TP_Customer_Vehicles.[Year] AS smallint) AS VehicleYear
			, CAST(TP_Customer_Vehicles.Make AS varchar(50)) AS VehicleMake
			, CAST(TP_Customer_Vehicles.Model AS varchar(50)) AS VehicleModel
			, CAST(TP_Customer_Vehicles.Color AS varchar(50)) AS VehicleColor
			, ISNULL(CAST(TP_Customer_Vehicles.StartEffectiveDate AS datetime2(3)), '1900-01-01') AS VehicleStartDate
			, ISNULL(CAST(TP_Customer_Vehicles.EndEffectiveDate AS datetime2(3)), '9999-12-31') AS VehicleEndDate
			, ISNULL(CAST(TP_Customer_Vehicles.VehicleStatusID AS int), -1) AS VehicleStatusID
			, ISNULL(CAST(VehicleStatus.VehicleStatusCode AS VARCHAR(15)), 'Unknown') AS VehicleStatusCode
			, ISNULL(CAST(VehicleStatus.VehicleStatusDesc AS VARCHAR(50)), 'Unknown') AS VehicleStatusDesc
			, ISNULL(CAST(TP_Customer_Vehicles.VehicleClassCode AS SMALLINT), -1) AS VehicleClassID
			--, ISNULL(CAST(TP_Customer_Vehicles.VehicleClassCode AS varchar(2)), '-1') AS VehicleClass
			, CAST(TP_Customer_Vehicles.DocNo AS varchar(17)) AS DocNo
			, ISNULL(CAST(TP_Customer_Vehicles.TagID AS varchar(12)), '-1') AS TagID
			, CAST(TP_Customer_Vehicles.County AS varchar(20)) AS County
			, CAST(TP_Customer_Vehicles.VIN AS varchar(50)) AS VIN
			, ISNULL(CAST(TP_Customer_Vehicles.ContractualTypeID AS int), -1) AS ContractualTypeID
			, ISNULL(CAST(ContractualType.ContractualTypeCode AS VARCHAR(15)), 'Unknown') AS ContractualTypeCode
			, ISNULL(CAST(ContractualType.ContractualTypeDesc AS VARCHAR(100)), 'Unknown') AS ContractualTypeDesc
			--, ISNULL(CAST(Dim_PlateType.PlateTypeID AS INT), -1) AS PlateTypeID
			--, CAST(TP_Customer_Vehicles.IsProtected AS bit) AS IsProtected
			, ISNULL(CAST(TP_Customer_Vehicles.IsExempted AS bit), 0) AS ExemptedFlag
			--, CAST(TP_Customer_Vehicles.IsTempNumber AS bit) AS IsTempNumber
			, ISNULL(CAST(TP_Customer_Vehicles.IsInHV AS bit), 0) AS HVFlag
			--, ISNULL(CAST(TP_Customer_Vehicles.IsVRH AS bit), 0) AS IsVRH -- Vehicle Registration Block flag
			, ISNULL(CAST(TP_Customer_Vehicles.UpdatedDate AS datetime2(3)), '1900-01-01') AS UpdatedDate
			, ISNULL(CAST(TP_Customer_Vehicles.LND_UpdateDate AS datetime2(3)), '1900-01-01') AS LND_UpdateDate
			, ISNULL(@Log_Start_Date, '1900-01-01') AS EDW_UpdateDate 
			--SELECT *
		FROM LND_TBOS.TollPlus.TP_Customer_Vehicles AS TP_Customer_Vehicles
		LEFT JOIN  dbo.Dim_ContractualType AS ContractualType ON ContractualType.ContractualTypeID = TP_Customer_Vehicles.ContractualTypeID
		LEFT JOIN  dbo.Dim_VehicleStatus AS VehicleStatus ON VehicleStatus.VehicleStatusID = TP_Customer_Vehicles.VehicleStatusID
		WHERE TP_Customer_Vehicles.LND_UpdateDate > @Last_UpdatedDate
		OPTION (LABEL = 'dbo.Dim_Vehicle_NEW');

		SET  @Log_Message = 'Loaded ' + @StageTableName
		EXEC Utility.FastLog @Log_Source, @Log_Message, -1

		IF @Trace_Flag = 1 PRINT 'Calling: Utility.UpdateTableWithTable'
		EXEC Utility.UpdateTableWithTable @StageTableName, @TableName, @IdentifyingColumns, Null

		IF OBJECT_ID('dbo.Dim_Vehicle_NEW','U') IS NOT NULL			DROP TABLE dbo.Dim_Vehicle_NEW;

		SET @Log_Message = 'Complited Incremental load from: ' + CONVERT(VARCHAR(25),@Last_UpdatedDate,121)
	END

	IF @Trace_Flag = 1 PRINT @Log_Message
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL


END
