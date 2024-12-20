CREATE PROC [dbo].[Dim_VehicleTag_Load] @IsFullLoad [BIT] AS
/*
IF OBJECT_ID ('dbo.Dim_VehicleTag_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Dim_VehicleTag_Load
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_VehicleTag_Load 1

EXEC Utility.FromLog 'dbo.Dim_VehicleTag', 1
SELECT 'LND_TBOS.TollPlus.TP_Customer_Vehicle_Tags' Table_Name, COUNT_BIG(1) Row_Count FROM LND_TBOS.TollPlus.TP_Customer_Vehicle_Tags
SELECT 'dbo.Dim_VehicleTag' Table_Name, COUNT_BIG(1) Row_Count FROM dbo.Dim_VehicleTag  
SELECT TOP 100 * FROM dbo.Dim_VehicleTag
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_VehicleTag table. 

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

	DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_VehicleTag_Load', @TableName VARCHAR(50) = 'dbo.Dim_VehicleTag', @StageTableName VARCHAR(100) = 'dbo.Dim_VehicleTag_NEW'
	DECLARE @Log_Start_Date DATETIME2(3) = SYSDATETIME(), @Log_Message VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing
	DECLARE @Last_CustomerTags_Date DATETIME2(3), @Last_Vehicle_Tags_Date DATETIME2(3), @IdentifyingColumns VARCHAR(100) = '[VehicleTagID]' 
	
	IF OBJECT_ID(@TableName) IS NULL
		SET @IsFullLoad = 1
	
	IF @IsFullLoad = 1
	BEGIN
	
		SET @Log_Message = 'Started Full load'
		IF @Trace_Flag = 1 PRINT @Log_Message
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
		
		IF OBJECT_ID('dbo.Dim_VehicleTag_NEW','U') IS NOT NULL			DROP TABLE dbo.Dim_VehicleTag_NEW;
		
		CREATE TABLE dbo.Dim_VehicleTag_NEW WITH (CLUSTERED INDEX (VehicleTagID),  DISTRIBUTION = HASH(CustomerID)) AS
		--EXPLAIN
		SELECT 
			ISNULL(CAST(TP_Customer_Vehicle_Tags.VehicleTagID AS bigint), 0) AS VehicleTagID
			, ISNULL(CAST(TP_Customer_Vehicle_Tags.CustTagID AS bigint), 0) AS CustTagID
			, ISNULL(CAST(TP_Customer_Tags.CustomerID AS bigint), -1) AS CustomerID
			, ISNULL(CAST(TP_Customer_Tags.SerialNo AS varchar(12)), '-1') AS TagID
			, ISNULL(CAST(TP_Customer_Vehicle_Tags.VehicleID AS bigint), 0) AS VehicleID
			--, ISNULL(CAST(TP_Customer_Vehicle_Tags.ChannelID AS int), 0) AS ChannelID
			, ISNULL(CAST(TP_Customer_Tags.TagType AS varchar(20)), '') AS TagType
			, ISNULL(CAST(TP_Customer_Tags.TagStatus AS varchar(20)), '') AS TagStatus
			, CAST(TP_Customer_Tags.TagAgency AS varchar(6)) AS TagAgency
			, CAST(TP_Customer_Tags.Mounting AS varchar(20)) AS TagMounting
			, CAST(TP_Customer_Tags.SpecialityTag AS varchar(30)) AS TagSpeciality
			, ISNULL(CAST(TP_Customer_Tags.TagStartDate AS date), '1900-01-01') AS TagStatusDate
			, ISNULL(CAST(TP_Customer_Vehicle_Tags.StartEffectiveDate AS date), '1900-01-01') AS TagStartDate
			, ISNULL(CAST(TP_Customer_Vehicle_Tags.EndEffectiveDate AS date), '9999-12-31') AS TagEndDate
			, CAST(TP_Customer_Tags.IsNonRevenue AS bit) AS NonRevenueFlag
			, ISNULL(CAST(TP_Customer_Vehicle_Tags.UpdatedDate AS datetime2(3)), '1900-01-01') AS UpdatedDate
			, ISNULL(CAST(TP_Customer_Vehicle_Tags.LND_UpdateDate AS datetime2(3)), '1900-01-01') AS LND_UpdateDate
			, ISNULL(@Log_Start_Date, '1900-01-01') AS EDW_UpdateDate -- SELECT * 
		FROM LND_TBOS.TollPlus.TP_Customer_Vehicle_Tags 
		LEFT JOIN LND_TBOS.TollPlus.TP_Customer_Tags ON TP_Customer_Tags.CustTagID = TP_Customer_Vehicle_Tags.CustTagID
		UNION ALL
		SELECT
			-1 AS VehicleTagID, -1 AS CustTagID, -1 AS CustomerID, '-1' AS TagID, -1 AS VehicleID, ---1 AS ChannelID,  
			'' AS TagType, '' AS TagStatus,'' AS TagAgency,'' AS TagMounting, '' AS TagSpeciality, 
			'1900-01-01' AS TagStatusDate,'1900-01-01' AS TagStartDate, '1900-01-01' AS TagEndDate, 
			0 AS NonRevenueFlag,  
			'1900-01-01' AS UpdatedDate, '1900-01-01' AS LND_UpdateDate, @Log_Start_Date AS EDW_UpdateDate
		OPTION (LABEL = 'dbo.Dim_VehicleTag_NEW');
		
		SET  @Log_Message = 'Loaded ' + @StageTableName
		EXEC Utility.FastLog @Log_Source, @Log_Message, -1

		CREATE STATISTICS Stats_dbo_Dim_VehicleTag_001 ON dbo.Dim_VehicleTag_NEW(CustomerID);
		CREATE STATISTICS STATS_dbo_Dim_VehicleTag_002 ON dbo.Dim_VehicleTag_NEW(VehicleID);
		CREATE STATISTICS STATS_dbo_Dim_VehicleTag_003 ON dbo.Dim_VehicleTag_NEW(TagID,TagAgency);
		CREATE STATISTICS STATS_dbo_Dim_VehicleTag_004 ON dbo.Dim_VehicleTag_NEW(TagAgency);
		CREATE STATISTICS STATS_dbo_Dim_VehicleTag_005 ON dbo.Dim_VehicleTag_NEW(TagType);
		CREATE STATISTICS STATS_dbo_Dim_VehicleTag_006 ON dbo.Dim_VehicleTag_NEW(TagStatus);
		CREATE STATISTICS STATS_dbo_Dim_VehicleTag_007 ON dbo.Dim_VehicleTag_NEW(TagStartDate, TagEndDate);
		CREATE STATISTICS STATS_dbo_Dim_VehicleTag_008 ON dbo.Dim_VehicleTag_NEW(CustTagID);

		-- Table swap!
		EXEC Utility.TableSwap @StageTableName, @TableName

		SET @Log_Message = 'Complited full load'

	END
	ELSE
	BEGIN
		EXEC Utility.Get_UpdatedDate @TableName, @Last_Vehicle_Tags_Date  OUTPUT 
		EXEC Utility.Get_UpdatedDate 'Dim_VehicleTag/TP_Customer_Tags', @Last_CustomerTags_Date OUTPUT 
		SET @Log_Message = 'Started Incremental load from: ' + CONVERT(VARCHAR(25),@Last_Vehicle_Tags_Date,121)

		IF @Trace_Flag = 1 PRINT @Log_Message
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

		IF OBJECT_ID('dbo.Dim_VehicleTag_NEW','U') IS NOT NULL			DROP TABLE dbo.Dim_VehicleTag_NEW;
		CREATE TABLE dbo.Dim_VehicleTag_NEW WITH (CLUSTERED INDEX (VehicleTagID),  DISTRIBUTION = HASH(CustomerID)) AS
		--EXPLAIN
		SELECT 
			ISNULL(CAST(TP_Customer_Vehicle_Tags.VehicleTagID AS bigint), 0) AS VehicleTagID
			, ISNULL(CAST(TP_Customer_Vehicle_Tags.CustTagID AS bigint), 0) AS CustTagID
			, ISNULL(CAST(TP_Customer_Tags.CustomerID AS bigint), -1) AS CustomerID
			, ISNULL(CAST(TP_Customer_Tags.SerialNo AS varchar(12)), '-1') AS TagID
			, ISNULL(CAST(TP_Customer_Vehicle_Tags.VehicleID AS bigint), 0) AS VehicleID
			--, ISNULL(CAST(TP_Customer_Vehicle_Tags.ChannelID AS int), 0) AS ChannelID
			, ISNULL(CAST(TP_Customer_Tags.TagType AS varchar(20)), '') AS TagType
			, ISNULL(CAST(TP_Customer_Tags.TagStatus AS varchar(20)), '') AS TagStatus
			, CAST(TP_Customer_Tags.TagAgency AS varchar(6)) AS TagAgency
			, CAST(TP_Customer_Tags.Mounting AS varchar(20)) AS TagMounting
			, CAST(TP_Customer_Tags.SpecialityTag AS varchar(30)) AS TagSpeciality
			, ISNULL(CAST(TP_Customer_Tags.TagStartDate AS date), '1900-01-01') AS TagStatusDate
			, ISNULL(CAST(TP_Customer_Vehicle_Tags.StartEffectiveDate AS date), '1900-01-01') AS TagStartDate
			, ISNULL(CAST(TP_Customer_Vehicle_Tags.EndEffectiveDate AS date), '9999-12-31') AS TagEndDate
			, CAST(TP_Customer_Tags.IsNonRevenue AS bit) AS NonRevenueFlag
			, ISNULL(CAST(TP_Customer_Vehicle_Tags.UpdatedDate AS datetime2(3)), '1900-01-01') AS UpdatedDate
			, ISNULL(CAST(TP_Customer_Vehicle_Tags.LND_UpdateDate AS datetime2(3)), '1900-01-01') AS LND_UpdateDate
			, ISNULL(@Log_Start_Date, '1900-01-01') AS EDW_UpdateDate
		FROM LND_TBOS.TollPlus.TP_Customer_Vehicle_Tags
		LEFT JOIN LND_TBOS.TollPlus.TP_Customer_Tags ON TP_Customer_Tags.CustTagID = TP_Customer_Vehicle_Tags.CustTagID 
		WHERE TP_Customer_Vehicle_Tags.CustTagID IN
			(
				SELECT CustTagID
				FROM LND_TBOS.TollPlus.TP_Customer_Tags WHERE LND_UpdateDate > @Last_CustomerTags_Date
				UNION
				SELECT CustTagID
				FROM LND_TBOS.TollPlus.TP_Customer_Vehicle_Tags WHERE LND_UpdateDate > @Last_Vehicle_Tags_Date
			)
		OPTION (LABEL = 'dbo.Dim_VehicleTag_NEW');

		SET  @Log_Message = 'Loaded ' + @StageTableName
		EXEC Utility.FastLog @Log_Source, @Log_Message, -1

		IF @Trace_Flag = 1 PRINT 'Calling: Utility.UpdateTableWithTable'
		EXEC Utility.UpdateTableWithTable @StageTableName, @TableName, @IdentifyingColumns, Null

		IF OBJECT_ID('dbo.Dim_VehicleTag_NEW','U') IS NOT NULL			DROP TABLE dbo.Dim_VehicleTag_NEW;
		SET @Log_Message = 'Complited Incremental load from: ' + CONVERT(VARCHAR(25),@Last_Vehicle_Tags_Date,121)
	END

	EXEC Utility.Set_UpdatedDate 'Dim_VehicleTag/TP_Customer_Tags', 'LND_TBOS.TollPlus.TP_Customer_Tags', NULL

	IF @Trace_Flag = 1 PRINT @Log_Message
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL


END

/*
-- DEVELOPMENT ARIA --

List of columns were deleted. Save for situation we need to bring them again:

--, ISNULL(CAST(TP_Customer_Vehicle_Tags.ICNID AS int), 0) AS ICNID
--, CAST(TP_Customer_Tags.TagAlias AS varchar(20)) AS TagAlias
--, CAST(TP_Customer_Tags.HexTagID AS varchar(20)) AS HexTagID
--, CAST(TP_Customer_Tags.ItemCode AS varchar(20)) AS TagItemCode
--, ISNULL(CAST(TP_Customer_Vehicle_Tags.IsBlockListed AS bit), 0) AS IsBlockListed
--, ISNULL(CAST(TP_Customer_Tags.IsDFWBlocked AS bit), 0) AS IsDFWBlocked
--, ISNULL(CAST(TP_Customer_Tags.IsDALBlocked AS bit), 0) AS IsDALBlocked
--, CAST(TP_Customer_Tags.IsGroundTransportation AS bit) AS IsGroundTransportation




*/
