CREATE PROC [dbo].[Dim_Ref_LookupTypeCodes_Hierarchy_Full_Load] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load all Lookup Dim Tables coming from Ref_LookupTypeCodes_Hierarchy table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Ranjith, Shankar		2020-08-28	New!
CHG0038319	Shankar					2021-02-24	Added Dim_VehicleStatus and Dim_ContractualType
CHG0040056  Shankar					2021-11-30	Added Dim_AutoReplenishment (Cash or CC backed TollTag Account?)\
CHG0040131	Gouthami				2021-12-16	Added a new Invoice Status(Dismissed Vtolled) to Dim_InvoiceStatus table.
CHG0042443	Gouthami				2023-02-09	Added a new Invoice Status(Dismissed Unassigned) to Dim_InvoiceStatus table.
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_Ref_LookupTypeCodes_Hierarchy_Full_Load

EXEC Utility.FromLog 'dbo.Dim_Ref_LookupTypeCodes_Hierarchy_Full_Load', 1

SELECT 'Stage.Ref_LookupTypeCodes_Hierarchy' TableName, * FROM Stage.Ref_LookupTypeCodes_Hierarchy ORDER BY 2
###################################################################################################################
*/



BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_Ref_LookupTypeCodes_Hierarchy_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load Stage.Ref_LookupTypeCodes_Hierarchy
		--=============================================================================================================
		IF OBJECT_ID('Stage.Ref_LookupTypeCodes_Hierarchy') IS NOT NULL DROP TABLE Stage.Ref_LookupTypeCodes_Hierarchy
		CREATE TABLE Stage.Ref_LookupTypeCodes_Hierarchy
		WITH (CLUSTERED INDEX ( LookupTypeCodeID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT  
				COALESCE(L4.LookupTypeCodeID,L3.LookupTypeCodeID,L2.LookupTypeCodeID) LookupTypeCodeID,
				L1.LookupTypeCodeID L1_LookupTypeCodeID, CONVERT(VARCHAR(50),L1.LookupTypeCode) L1_LookupTypeCode, CONVERT(VARCHAR(100),L1.LookupTypeCodeDesc) L1_LookupTypeCodeDesc,
				L2.LookupTypeCodeID L2_LookupTypeCodeID, CONVERT(VARCHAR(50),L2.LookupTypeCode) L2_LookupTypeCode, CONVERT(VARCHAR(100),L2.LookupTypeCodeDesc) L2_LookupTypeCodeDesc,
				L3.LookupTypeCodeID L3_LookupTypeCodeID, CONVERT(VARCHAR(50),L3.LookupTypeCode) L3_LookupTypeCode, CONVERT(VARCHAR(100),L3.LookupTypeCodeDesc) L3_LookupTypeCodeDesc,
				L4.LookupTypeCodeID L4_LookupTypeCodeID, CONVERT(VARCHAR(50),L4.LookupTypeCode) L4_LookupTypeCode, CONVERT(VARCHAR(100),L4.LookupTypeCodeDesc) L4_LookupTypeCodeDesc,
				CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		FROM	LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy L1(NOLOCK)
				JOIN LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy L2(NOLOCK) ON L1.LookupTypeCodeID = L2.Parent_LookupTypeCodeID AND L1.Parent_LookupTypeCodeID = 0  
				LEFT JOIN LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy L3 (NOLOCK) ON L2.LookupTypeCodeID = L3.Parent_LookupTypeCodeID   
				LEFT JOIN LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy L4 (NOLOCK) ON L3.LookupTypeCodeID = L4.Parent_LookupTypeCodeID  
		OPTION (LABEL = 'Stage.Ref_LookupTypeCodes_Hierarchy');
		
		SET  @Log_Message = 'Stage.Ref_LookupTypeCodes_Hierarchy' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--=============================================================================================================
		-- Load dbo.Dim_CollectionStatus
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_CollectionStatus_NEW') IS NOT NULL DROP TABLE dbo.Dim_CollectionStatus_NEW
		CREATE TABLE dbo.Dim_CollectionStatus_NEW
		WITH (CLUSTERED INDEX ( CollectionStatusID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	DISTINCT LookupTypeCodeID AS CollectionStatusID, CONVERT(VARCHAR(50),LookupTypeCode) AS CollectionStatusCode, CONVERT(VARCHAR(100),LookupTypeCodeDesc) AS CollectionStatusDesc, CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM   LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy 
		WHERE  Parent_LookupTypeCodeID = 3647	-- CollectionStatus
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', SYSDATETIME()
		OPTION	(LABEL = 'dbo.Dim_CollectionStatus_NEW Full Load')

		SET  @Log_Message = 'Loaded dbo.Dim_CollectionStatus_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_CollectionStatus_01 ON dbo.Dim_CollectionStatus_NEW (CollectionStatusCode);
		CREATE STATISTICS STATS_CollectionStatus_02 ON dbo.Dim_CollectionStatus_NEW (CollectionStatusDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_CollectionStatus_NEW', 'dbo.Dim_CollectionStatus'

		--=============================================================================================================
		-- Load dbo.Dim_AccountType
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_AccountType_NEW') IS NOT NULL DROP TABLE dbo.Dim_AccountType_NEW
		CREATE TABLE dbo.Dim_AccountType_NEW
		WITH (CLUSTERED INDEX ( AccountTypeID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	DISTINCT LookupTypeCodeID AS AccountTypeID, CONVERT(VARCHAR(50),LookupTypeCode) AS AccountTypeCode, CONVERT(VARCHAR(100),LookupTypeCodeDesc) AS AccountTypeDesc, CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM   LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy 
		WHERE  Parent_LookupTypeCodeID = 1 -- User_Types
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', SYSDATETIME()
		OPTION	(LABEL = 'dbo.Dim_AccountType_NEW Full Load')

		SET  @Log_Message = 'Loaded dbo.Dim_AccountType_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_AccountType_01 ON dbo.Dim_AccountType_NEW (AccountTypeCode);
		CREATE STATISTICS STATS_AccountType_02 ON dbo.Dim_AccountType_NEW (AccountTypeDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_AccountType_NEW', 'dbo.Dim_AccountType'

		--=============================================================================================================
		-- Load dbo.Dim_AccountStatus
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_AccountStatus_NEW') IS NOT NULL DROP TABLE dbo.Dim_AccountStatus_NEW
		CREATE TABLE dbo.Dim_AccountStatus_NEW
		WITH (CLUSTERED INDEX ( AccountStatusID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	DISTINCT LookupTypeCodeID AS AccountStatusID, CONVERT(VARCHAR(50),LookupTypeCode) AS AccountStatusCode, CONVERT(VARCHAR(100),LookupTypeCodeDesc) AS AccountStatusDesc, CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM   LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy 
		WHERE  Parent_LookupTypeCodeID = 15 -- AccountStatus
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', SYSDATETIME()
		OPTION	(LABEL = 'dbo.Dim_AccountStatus_NEW Full Load')

		SET  @Log_Message = 'Loaded dbo.Dim_AccountStatus_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_AccountStatus_01 ON dbo.Dim_AccountStatus_NEW (AccountStatusCode);
		CREATE STATISTICS STATS_AccountStatus_02 ON dbo.Dim_AccountStatus_NEW (AccountStatusDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_AccountStatus_NEW', 'dbo.Dim_AccountStatus'
	
		--=============================================================================================================
		-- Load dbo.Dim_CustomerStatus
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_CustomerStatus_NEW') IS NOT NULL DROP TABLE dbo.Dim_CustomerStatus_NEW
		CREATE TABLE dbo.Dim_CustomerStatus_NEW
		WITH (CLUSTERED INDEX ( CustomerStatusID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	DISTINCT LookupTypeCodeID AS CustomerStatusID, CONVERT(VARCHAR(50),LookupTypeCode) AS CustomerStatusCode, CONVERT(VARCHAR(100),LookupTypeCodeDesc) AS CustomerStatusDesc, CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM   LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy 
		WHERE  Parent_LookupTypeCodeID = 12 -- CustomerStatus
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', SYSDATETIME()
		OPTION	(LABEL = 'dbo.Dim_CustomerStatus_NEW Full Load')

		SET  @Log_Message = 'Loaded dbo.Dim_CustomerStatus_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_CustomerStatus_01 ON dbo.Dim_CustomerStatus_NEW (CustomerStatusCode);
		CREATE STATISTICS STATS_CustomerStatus_02 ON dbo.Dim_CustomerStatus_NEW (CustomerStatusDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_CustomerStatus_NEW', 'dbo.Dim_CustomerStatus'

		--=============================================================================================================
		-- Load dbo.Dim_AutoReplenishment
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_AutoReplenishment_NEW') IS NOT NULL DROP TABLE dbo.Dim_AutoReplenishment_NEW
		CREATE TABLE dbo.Dim_AutoReplenishment_NEW
		WITH (CLUSTERED INDEX ( AutoReplenishmentID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	DISTINCT LookupTypeCodeID AS AutoReplenishmentID, CONVERT(VARCHAR(50),LookupTypeCode) AS AutoReplenishmentCode, CONVERT(VARCHAR(100),LookupTypeCodeDesc) AS AutoReplenishmentDesc, CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM   LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy 
		WHERE  Parent_LookupTypeCodeID = 77 -- AutoReplenishment
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', SYSDATETIME()
		OPTION	(LABEL = 'dbo.Dim_AutoReplenishment_NEW Full Load')

		SET  @Log_Message = 'Loaded dbo.Dim_AutoReplenishment_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_AutoReplenishment_01 ON dbo.Dim_AutoReplenishment_NEW (AutoReplenishmentCode);
		CREATE STATISTICS STATS_AutoReplenishment_02 ON dbo.Dim_AutoReplenishment_NEW (AutoReplenishmentDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_AutoReplenishment_NEW', 'dbo.Dim_AutoReplenishment'

		--=============================================================================================================
		-- Load dbo.Dim_VehicleStatus
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_VehicleStatus_NEW') IS NOT NULL DROP TABLE dbo.Dim_VehicleStatus_NEW
		CREATE TABLE dbo.Dim_VehicleStatus_NEW
		WITH (CLUSTERED INDEX ( VehicleStatusID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	DISTINCT LookupTypeCodeID AS VehicleStatusID, CONVERT(VARCHAR(50),LookupTypeCode) AS VehicleStatusCode, CONVERT(VARCHAR(100),LookupTypeCodeDesc) AS VehicleStatusDesc, CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM   LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy 
		WHERE  Parent_LookupTypeCodeID = 204 -- VehicleStatus
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', SYSDATETIME()
		OPTION	(LABEL = 'dbo.Dim_VehicleStatus_NEW Full Load')

		SET  @Log_Message = 'Loaded dbo.Dim_VehicleStatus_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_VehicleStatus_01 ON dbo.Dim_VehicleStatus_NEW (VehicleStatusCode);
		CREATE STATISTICS STATS_VehicleStatus_02 ON dbo.Dim_VehicleStatus_NEW (VehicleStatusDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_VehicleStatus_NEW', 'dbo.Dim_VehicleStatus'

		--=============================================================================================================
		-- Load dbo.Dim_InvoiceStatus
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_InvoiceStatus_NEW') IS NOT NULL DROP TABLE dbo.Dim_InvoiceStatus_NEW
		CREATE TABLE dbo.Dim_InvoiceStatus_NEW
		WITH (CLUSTERED INDEX ( InvoiceStatusID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	DISTINCT LookupTypeCodeID AS InvoiceStatusID, CONVERT(VARCHAR(50),LookupTypeCode) AS InvoiceStatusCode, CONVERT(VARCHAR(100),LookupTypeCodeDesc) AS InvoiceStatusDesc, CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM   LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy 
		WHERE  Parent_LookupTypeCodeID = 508	-- InvoiceStatus
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', SYSDATETIME()
		UNION ALL 
		SELECT	99999, 'Vtolled', 'DismissedVtolled', SYSDATETIME()
		UNION ALL
		SELECT	99998, 'Unassigned', 'DismissedUnassigned', SYSDATETIME()
		OPTION	(LABEL = 'dbo.Dim_InvoiceStatus_NEW Full Load')
		
		SET  @Log_Message = 'Loaded dbo.Dim_InvoiceStatus_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_InvoiceStatus_01 ON dbo.Dim_InvoiceStatus_NEW (InvoiceStatusCode);
		CREATE STATISTICS STATS_InvoiceStatus_02 ON dbo.Dim_InvoiceStatus_NEW (InvoiceStatusDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_InvoiceStatus_NEW', 'dbo.Dim_InvoiceStatus'

		--=============================================================================================================
		-- Load dbo.Dim_PaymentChannel
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_PaymentChannel_NEW') IS NOT NULL DROP TABLE dbo.Dim_PaymentChannel_NEW
		CREATE TABLE dbo.Dim_PaymentChannel_NEW
		WITH (CLUSTERED INDEX ( PaymentChannelID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	DISTINCT LookupTypeCodeID AS PaymentChannelID, CONVERT(VARCHAR(50),LookupTypeCode) AS PaymentChannelCode, CONVERT(VARCHAR(100),LookupTypeCodeDesc) AS PaymentChannelDesc, CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM   LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy 
		WHERE  Parent_LookupTypeCodeID = 94 -- PaymentChannel
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', SYSDATETIME()
		OPTION	(LABEL = 'dbo.Dim_PaymentChannel_NEW Full Load')

		SET  @Log_Message = 'Loaded dbo.Dim_PaymentChannel_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_PaymentChannel_01 ON dbo.Dim_PaymentChannel_NEW (PaymentChannelCode);
		CREATE STATISTICS STATS_PaymentChannel_02 ON dbo.Dim_PaymentChannel_NEW (PaymentChannelDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_PaymentChannel_NEW', 'dbo.Dim_PaymentChannel'

		--=============================================================================================================
		-- Load dbo.Dim_PaymentStatus
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_PaymentStatus_NEW') IS NOT NULL DROP TABLE dbo.Dim_PaymentStatus_NEW
		CREATE TABLE dbo.Dim_PaymentStatus_NEW
		WITH (CLUSTERED INDEX ( PaymentStatusID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	DISTINCT LookupTypeCodeID AS PaymentStatusID, CONVERT(VARCHAR(50),LookupTypeCode) AS PaymentStatusCode, CONVERT(VARCHAR(100),LookupTypeCodeDesc) AS PaymentStatusDesc, CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM   LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy 
		WHERE  Parent_LookupTypeCodeID = 107	-- PaymentStatus
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', SYSDATETIME()
		OPTION	(LABEL = 'dbo.Dim_PaymentStatus_NEW Full Load')

		SET  @Log_Message = 'Loaded dbo.Dim_PaymentStatus_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_PaymentStatus_01 ON dbo.Dim_PaymentStatus_NEW (PaymentStatusCode);
		CREATE STATISTICS STATS_PaymentStatus_02 ON dbo.Dim_PaymentStatus_NEW (PaymentStatusDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_PaymentStatus_NEW', 'dbo.Dim_PaymentStatus'

		--=============================================================================================================
		-- Load dbo.Dim_AdjApprovalStatus
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_AdjApprovalStatus_NEW') IS NOT NULL DROP TABLE dbo.Dim_AdjApprovalStatus_NEW
		CREATE TABLE dbo.Dim_AdjApprovalStatus_NEW
		WITH (CLUSTERED INDEX ( AdjApprovalStatusID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	DISTINCT LookupTypeCodeID AS AdjApprovalStatusID, CONVERT(VARCHAR(50),LookupTypeCode) AS AdjApprovalStatusCode, CONVERT(VARCHAR(100),LookupTypeCodeDesc) AS AdjApprovalStatusDesc, CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM   LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy 
		WHERE  Parent_LookupTypeCodeID = 465	-- AdjApproval_Status
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', SYSDATETIME()
		OPTION	(LABEL = 'dbo.Dim_AdjApprovalStatus_NEW Full Load')

		SET  @Log_Message = 'Loaded dbo.Dim_AdjApprovalStatus_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_AdjApprovalStatus_01 ON dbo.Dim_AdjApprovalStatus_NEW (AdjApprovalStatusCode);
		CREATE STATISTICS STATS_AdjApprovalStatus_02 ON dbo.Dim_AdjApprovalStatus_NEW (AdjApprovalStatusDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_AdjApprovalStatus_NEW', 'dbo.Dim_AdjApprovalStatus'

		--=============================================================================================================
		-- Load dbo.Dim_TransactionTypeCategory
		--=============================================================================================================

		IF OBJECT_ID('dbo.Dim_TransactionTypeCategory_NEW') IS NOT NULL DROP TABLE dbo.Dim_TransactionTypeCategory_NEW
		CREATE TABLE dbo.Dim_TransactionTypeCategory_NEW
		WITH (CLUSTERED INDEX ( TransactionTypeCategoryID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	DISTINCT LookupTypeCodeID AS TransactionTypeCategoryID, CONVERT(VARCHAR(50),LookupTypeCode) AS TransactionTypeCategoryCode, CONVERT(VARCHAR(100),LookupTypeCodeDesc) AS TransactionTypeCategoryDesc, CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM   LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy 
		WHERE  Parent_LookupTypeCodeID = 153 -- TxnType_Categories
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', SYSDATETIME()
		OPTION (LABEL = 'dbo.Dim_TransactionTypeCategory_NEW Full Load')

		SET  @Log_Message = 'Loaded dbo.Dim_TransactionTypeCategory_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_TransactionTypeCategory_01 ON dbo.Dim_TransactionTypeCategory_NEW (TransactionTypeCategoryCode);
		CREATE STATISTICS STATS_TransactionTypeCategory_02 ON dbo.Dim_TransactionTypeCategory_NEW (TransactionTypeCategoryDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_TransactionTypeCategory_NEW', 'dbo.Dim_TransactionTypeCategory'
		
		--=============================================================================================================
		-- Load dbo.Dim_TripPaymentStatus
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_TripPaymentStatus_NEW') IS NOT NULL DROP TABLE dbo.Dim_TripPaymentStatus_NEW
		CREATE TABLE dbo.Dim_TripPaymentStatus_NEW
		WITH (CLUSTERED INDEX ( TripPaymentStatusID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	DISTINCT LookupTypeCodeID AS TripPaymentStatusID, CONVERT(VARCHAR(50),LookupTypeCode) AS TripPaymentStatusCode, CONVERT(VARCHAR(100),LookupTypeCodeDesc) AS TripPaymentStatusDesc, CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM   LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy 
		WHERE  Parent_LookupTypeCodeID = 455 -- TripPaymentStatus
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', SYSDATETIME()
		OPTION (LABEL = 'dbo.Dim_TripPaymentStatus_NEW Full Load')

		SET  @Log_Message = 'Loaded dbo.Dim_TripPaymentStatus_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_TripPaymentStatus_01 ON dbo.Dim_TripPaymentStatus_NEW (TripPaymentStatusCode);
		CREATE STATISTICS STATS_TripPaymentStatus_02 ON dbo.Dim_TripPaymentStatus_NEW (TripPaymentStatusDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_TripPaymentStatus_NEW', 'dbo.Dim_TripPaymentStatus'

		--**************** Russian Dolls Hierarchy Dim Modeling for PaymentMode and PaymentModeGroup ******************
		--=============================================================================================================
		-- Load dbo.Dim_PaymentModeGroup
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_PaymentModeGroup_NEW') IS NOT NULL DROP TABLE dbo.Dim_PaymentModeGroup_NEW
		CREATE TABLE dbo.Dim_PaymentModeGroup_NEW
		WITH (CLUSTERED INDEX ( PaymentModeGroupID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	DISTINCT L2_LookupTypeCodeID AS PaymentModeGroupID, L2_LookupTypeCode AS PaymentModeGroupCode, L2_LookupTypeCodeDesc AS PaymentModeGroupDesc,
				CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM	Stage.Ref_LookupTypeCodes_Hierarchy 
		WHERE	L1_LookupTypeCodeID = 125 -- AllPMTModes
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', SYSDATETIME()
		OPTION	(LABEL = 'dbo.Dim_PaymentModeGroup_NEW Full Load')

		SET  @Log_Message = 'Loaded dbo.Dim_PaymentModeGroup_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_PaymentModeGroup_01 ON dbo.Dim_PaymentModeGroup_NEW (PaymentModeGroupCode);
		CREATE STATISTICS STATS_PaymentModeGroup_02 ON dbo.Dim_PaymentModeGroup_NEW (PaymentModeGroupDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_PaymentModeGroup_NEW', 'dbo.Dim_PaymentModeGroup'
 
		--=============================================================================================================
		-- Load dbo.Dim_PaymentMode
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_PaymentMode_NEW') IS NOT NULL DROP TABLE dbo.Dim_PaymentMode_NEW
		CREATE TABLE dbo.Dim_PaymentMode_NEW
		WITH (CLUSTERED INDEX ( PaymentModeID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	L3_LookupTypeCodeID AS PaymentModeID, L3_LookupTypeCode AS PaymentModeCode, L3_LookupTypeCodeDesc AS PaymentModeDesc, 
				L2_LookupTypeCodeID AS PaymentModeGroupID, L2_LookupTypeCode AS PaymentModeGroupCode, L2_LookupTypeCodeDesc AS PaymentModeGroupDesc,
				CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM	Stage.Ref_LookupTypeCodes_Hierarchy 
		WHERE	L1_LookupTypeCodeID = 125 -- AllPMTModes
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', -1, 'Unknown', 'Unknown', SYSDATETIME()
		OPTION	(LABEL = 'dbo.Dim_PaymentMode_NEW Full Load')

		SET  @Log_Message = 'Loaded dbo.Dim_PaymentMode_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_PaymentMode_01 ON dbo.Dim_PaymentMode_NEW (PaymentModeCode);
		CREATE STATISTICS STATS_PaymentMode_02 ON dbo.Dim_PaymentMode_NEW (PaymentModeDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_PaymentMode_NEW', 'dbo.Dim_PaymentMode'
 
		--**************** Russian Dolls Hierarchy Dim Modeling for RevenueType and RevenueCategory ******************
		--=============================================================================================================
		-- Load dbo.Dim_RevenueCategory
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_RevenueCategory_NEW') IS NOT NULL DROP TABLE dbo.Dim_RevenueCategory_NEW
		CREATE TABLE dbo.Dim_RevenueCategory_NEW
		WITH (CLUSTERED INDEX ( RevenueCategoryID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	DISTINCT L2_LookupTypeCodeID AS RevenueCategoryID, L2_LookupTypeCode AS RevenueCategoryCode, L2_LookupTypeCodeDesc AS RevenueCategoryDesc,
				CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM	Stage.Ref_LookupTypeCodes_Hierarchy 
		WHERE	L1_LookupTypeCodeID = 74 -- RevenueCategory
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', SYSDATETIME()
		OPTION	(LABEL = 'dbo.Dim_RevenueCategory_NEW Full Load')

		SET  @Log_Message = 'Loaded dbo.Dim_RevenueCategory_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_RevenueCategory_01 ON dbo.Dim_RevenueCategory_NEW (RevenueCategoryCode);
		CREATE STATISTICS STATS_RevenueCategory_02 ON dbo.Dim_RevenueCategory_NEW (RevenueCategoryDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_RevenueCategory_NEW', 'dbo.Dim_RevenueCategory'
 
		--=============================================================================================================
		-- Load dbo.Dim_RevenueType
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_RevenueType_NEW') IS NOT NULL DROP TABLE dbo.Dim_RevenueType_NEW
		CREATE TABLE dbo.Dim_RevenueType_NEW
		WITH (CLUSTERED INDEX ( RevenueTypeID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	ISNULL(L3_LookupTypeCodeID,L2_LookupTypeCodeID) AS RevenueTypeID, CAST(ISNULL(REPLACE(REPLACE(L3_LookupTypeCode,'FirstResponder','FirstResponder'),'Employee','Employee'),L2_LookupTypeCode) AS VARCHAR(50)) AS RevenueTypeCode, ISNULL(L3_LookupTypeCodeDesc,L2_LookupTypeCodeDesc) AS RevenueTypeDesc, 
				L2_LookupTypeCodeID AS RevenueCategoryID, L2_LookupTypeCode AS RevenueCategoryCode, L2_LookupTypeCodeDesc AS RevenueCategoryDesc,
				CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM	Stage.Ref_LookupTypeCodes_Hierarchy 
		WHERE	L1_LookupTypeCodeID = 74 -- RevenueCategory
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', -1, 'Unknown', 'Unknown', SYSDATETIME()
		OPTION	(LABEL = 'dbo.Dim_RevenueType_NEW Full Load')

		SET  @Log_Message = 'Loaded dbo.Dim_RevenueType_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_RevenueType_01 ON dbo.Dim_RevenueType_NEW (RevenueTypeCode);
		CREATE STATISTICS STATS_RevenueType_02 ON dbo.Dim_RevenueType_NEW (RevenueTypeDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_RevenueType_NEW', 'dbo.Dim_RevenueType'

		--=============================================================================================================
		-- Load dbo.Dim_VehicleStatus
		--=============================================================================================================
	
		IF OBJECT_ID('dbo.Dim_VehicleStatus_NEW') IS NOT NULL DROP TABLE dbo.Dim_VehicleStatus_NEW
		CREATE TABLE dbo.Dim_VehicleStatus_NEW
		WITH (CLUSTERED INDEX ( VehicleStatusID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	DISTINCT LookupTypeCodeID AS VehicleStatusID, CONVERT(VARCHAR(15),LookupTypeCode) AS VehicleStatusCode, CONVERT(VARCHAR(50),LookupTypeCodeDesc) AS VehicleStatusDesc, CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM   LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy 
		WHERE  Parent_LookupTypeCodeID = 204 -- VehicleStatus
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', SYSDATETIME()
		OPTION (LABEL = 'dbo.Dim_VehicleStatus_NEW Full Load')

		SET  @Log_Message = 'Loaded dbo.Dim_VehicleStatus_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_VehicleStatus_01 ON dbo.Dim_VehicleStatus_NEW (VehicleStatusCode);
		CREATE STATISTICS STATS_VehicleStatus_02 ON dbo.Dim_VehicleStatus_NEW (VehicleStatusDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_VehicleStatus_NEW', 'dbo.Dim_VehicleStatus'

		--=============================================================================================================
		-- Load dbo.Dim_ContractualType
		--=============================================================================================================
	
		IF OBJECT_ID('dbo.Dim_ContractualType_NEW') IS NOT NULL DROP TABLE dbo.Dim_ContractualType_NEW
		CREATE TABLE dbo.Dim_ContractualType_NEW
		WITH (CLUSTERED INDEX ( ContractualTypeID ASC ), DISTRIBUTION = REPLICATE)
		AS
		SELECT	DISTINCT LookupTypeCodeID AS ContractualTypeID, CONVERT(VARCHAR(15),LookupTypeCode) AS ContractualTypeCode, CONVERT(VARCHAR(15),LookupTypeCodeDesc) AS ContractualTypeDesc, CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate  
		FROM   LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy 
		WHERE  Parent_LookupTypeCodeID = 2817 -- VEHICLECONTRACTUALTYPE
		UNION ALL 
		SELECT	-1, 'Unknown', 'Unknown', SYSDATETIME()
		OPTION (LABEL = 'dbo.Dim_ContractualType_NEW Full Load')

		SET  @Log_Message = 'Loaded dbo.Dim_ContractualType_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
		-- Create statistics
		CREATE STATISTICS STATS_ContractualType_01 ON dbo.Dim_ContractualType_NEW (ContractualTypeCode);
		CREATE STATISTICS STATS_ContractualType_02 ON dbo.Dim_ContractualType_NEW (ContractualTypeDesc);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_ContractualType_NEW', 'dbo.Dim_ContractualType'



		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 
		BEGIN
		    SELECT TOP 100 'Stage.Ref_LookupTypeCodes_Hierarchy' TableName, * FROM Stage.Ref_LookupTypeCodes_Hierarchy ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_CollectionStatus' TableName, * FROM dbo.Dim_CollectionStatus ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_AccountStatus' TableName, * FROM dbo.Dim_AccountStatus ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_CustomerStatus' TableName, * FROM dbo.Dim_CustomerStatus ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_AutoReplenishment' TableName, * FROM dbo.Dim_AutoReplenishment ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_InvoiceStatus' TableName, * FROM dbo.Dim_InvoiceStatus ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_PaymentChannel' TableName, * FROM dbo.Dim_PaymentChannel ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_PaymentStatus' TableName, * FROM dbo.Dim_PaymentStatus ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_TransactionTypeCategory' TableName, * FROM dbo.Dim_TransactionTypeCategory ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_TripPaymentStatus' TableName, * FROM dbo.Dim_TripPaymentStatus ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_AccountType' TableName, * FROM dbo.Dim_AccountType ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_PaymentModeGroup' TableName, * FROM dbo.Dim_PaymentModeGroup ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_PaymentMode' TableName, * FROM dbo.Dim_PaymentMode ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_RevenueCategory' TableName, * FROM dbo.Dim_RevenueCategory ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_RevenueType' TableName, * FROM dbo.Dim_RevenueType ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_VehicleStatus' TableName, * FROM dbo.Dim_VehicleStatus ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_ContractualType' TableName, * FROM dbo.Dim_ContractualType ORDER BY 2
		END
	
	END	TRY
	
	BEGIN CATCH
		
		DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error!
	
	END CATCH

END

/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_Ref_LookupTypeCodes_Hierarchy_Full_Load
EXEC Utility.FromLog 'dbo.Dim_Ref_LookupTypeCodes_Hierarchy_Full_Load', 1

DELETE Utility.ProcessLog WHERE LogSource LIKE '%Dim_Ref_LookupTypeCodes_Hierarchy_Full_Load%'

SELECT * FROM Stage.Ref_LookupTypeCodes_Hierarchy WHERE L1_LookupTypeCodeID = 1
SELECT * FROM Stage.Ref_LookupTypeCodes_Hierarchy WHERE L1_LookupTypeCodeDESC LIKE '%TXN%TYPE%'

SELECT 'Stage.Ref_LookupTypeCodes_Hierarchy' TableName, * FROM Stage.Ref_LookupTypeCodes_Hierarchy WHERE L1_LookupTypeCodeID IN (1, 3548) ORDER BY 3

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================

SELECT	C.Parent_LookupTypeCodeID,
		P.LookupTypeCode AS Lookup_Dim,
		COUNT(1) Row_Count,
		MIN(LEN(C.LookupTypeCode)) AS LookupTypeCode_MinLen, MAX(LEN(C.LookupTypeCode)) AS LookupTypeCode_MaxLen, 
		MIN(LEN(C.LookupTypeCodeDesc)) AS LookupTypeCodeDesc_MinLen, MAX(LEN(C.LookupTypeCodeDesc)) AS LookupTypeCodeDesc_MaxLen
FROM	LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy C
		JOIN (SELECT DISTINCT LookupTypeCodeID, LookupTypeCode FROM LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy) P 
		ON C.Parent_LookupTypeCodeID = P.LookupTypeCodeID
WHERE  Parent_LookupTypeCodeID IN (
		1 		-- User_Types
		,15 	-- AccountStatus
		,12 	-- CustomerStatus
		,94 	-- PaymentChannel
		,107	-- PaymentStatus
		,153 	-- TxnType
		,204 	-- VehicleStatus
		,455 	-- TripPaymentStatus
		,465	-- AdjApproval_Status
		,508	-- InvoiceStatus
		,3647	-- CollectionStatus
)
GROUP BY C.Parent_LookupTypeCodeID, P.LookupTypeCode
ORDER BY 1
*/



