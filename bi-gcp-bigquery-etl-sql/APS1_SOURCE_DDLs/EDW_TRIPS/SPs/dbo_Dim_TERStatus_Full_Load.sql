CREATE PROC [dbo].[Dim_TERStatus_Full_Load] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_TERStatus table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0043961		Gouthami		2023-10-30 	New!
											1. Created this to populate TER statuses into multiple dimension tables
											2. This dimension load includes all TER statuses pulled into a stage 
											   table and created multiple dim status tables using stage.
											3. Created below tables
												Stage.Dim_TERStatus
												dbo.Dim_HVStatus
												dbo.Dim_PaymentPlanStatus
												dbo.Dim_VRBStatus
												dbo.Dim_VBStatus
												dbo.Dim_VRBRemovalReason
												dbo.Dim_VBRemovalReason
												dbo.Dim_VRBRejectReason
												dbo.Dim_VRBAgency
												dbo.Dim_TER_LetterDeliverStatus
												dbo.Dim_Court
												dbo.Dim_CourtJudge
												dbo.Dim_DPSTrooper
CHG0044527		Gouthami		 2024-02-08 	Added Dim_Citationstatus

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_TERStatus_Full_Load

EXEC Utility.FromLog 'dbo.Dim_TERStatus_Full_Load', 1
SELECT TOP 100 'dbo.Dim_TERStatus' Table_Name, * FROM  dbo.Dim_TERStatus ORDER BY 2
###################################################################################################################
*/
BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_TERStatus_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load Stage.Dim_TERStatus
		--=============================================================================================================
		 IF OBJECT_ID('Stage.Dim_TERStatus') IS NOT NULL DROP TABLE Stage.Dim_TERStatus
		 CREATE TABLE Stage.Dim_TERStatus WITH (CLUSTERED INDEX (StatusID), DISTRIBUTION = REPLICATE) AS
		 SELECT	  HVStatusLookupID StatusID,
                  StatusCode,
                  StatusDescription,
                  ParentStatusID,
                  IsActive ActiveFlag,
                  DetailedDesc,
                  CreatedDate,
                  LND_UpdateDate,
                  CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		 FROM LND_TBOS.TER.HVStatusLookup
		 UNION ALL 
		 SELECT -1, 'Unknown', 'Unknown', -1, 0,'Unknown',SYSDATETIME(),SYSDATETIME(), CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		 OPTION (LABEL = 'Stage.Dim_TERStatus Load');
		
		SET  @Log_Message = 'Loaded Stage.Dim_TERStatus' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_Stage_Dim_TERStatus_01 ON Stage.Dim_TERStatus (StatusCode);
		
		--=============================================================================================================
		-- Load dbo.Dim_PaymentPlanStatus
		--=============================================================================================================

		 IF OBJECT_ID('dbo.Dim_PaymentPlanStatus_NEW') IS NOT NULL DROP TABLE dbo.Dim_PaymentPlanStatus_NEW
		 CREATE TABLE dbo.Dim_PaymentPlanStatus_NEW WITH (CLUSTERED INDEX (PaymentPlanStatusID), DISTRIBUTION = REPLICATE) AS
		 SELECT	   StatusID PaymentPlanStatusID,
                   StatusCode PaymentPlanStatusCode,
                   StatusDescription PaymentPlanStatusDescription,
                   ParentStatusID,
                   ActiveFlag,
                   DetailedDesc,
                   CreatedDate,
                   LND_UpdateDate,
                   CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		 FROM stage.Dim_TERStatus
		 WHERE ParentStatusID=43
		 UNION ALL 
		 SELECT -1, 'Unknown', 'Unknown', -1, 0,'Unknown',SYSDATETIME(),SYSDATETIME(),CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 

		 OPTION (LABEL = 'dbo.Dim_PaymentPlanStatus_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Dim_PaymentPlanStatus_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_PaymentPlanStatus_01 ON dbo.Dim_PaymentPlanStatus_NEW (PaymentPlanStatusCode);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_PaymentPlanStatus_NEW', 'dbo.Dim_PaymentPlanStatus'

		--=============================================================================================================
		-- Load dbo.Dim_HVStatus
		--=============================================================================================================

		 IF OBJECT_ID('dbo.Dim_HVStatus_NEW') IS NOT NULL DROP TABLE dbo.Dim_HVStatus_NEW
		 CREATE TABLE dbo.Dim_HVStatus_NEW WITH (CLUSTERED INDEX (HVStatusID), DISTRIBUTION = REPLICATE) AS
		 SELECT	   StatusID HVStatusID,
                   StatusCode HVStatusCode,
                   StatusDescription HVStatusDescription,
                   ParentStatusID,
                   ActiveFlag,
                   DetailedDesc,
                   CreatedDate,
                   LND_UpdateDate,
                   CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		 FROM stage.Dim_TERStatus
		 WHERE ParentStatusID IN (0,13,23,43) 
		 UNION ALL 
		 SELECT -1, 'Unknown', 'Unknown', -1, 0,'Unknown',SYSDATETIME(),SYSDATETIME(),CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 

		 OPTION (LABEL = 'dbo.Dim_HVStatus_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Dim_HVStatus_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_HVStatus_01 ON dbo.Dim_HVStatus_NEW (HVStatusCode);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_HVStatus_NEW', 'dbo.Dim_HVStatus'

		--=============================================================================================================
		-- Load dbo.Dim_VRBStatus
		--=============================================================================================================

		 IF OBJECT_ID('dbo.Dim_VRBStatus_NEW') IS NOT NULL DROP TABLE dbo.Dim_VRBStatus_NEW
		 CREATE TABLE dbo.Dim_VRBStatus_NEW WITH (CLUSTERED INDEX (VRBStatusID), DISTRIBUTION = REPLICATE) AS
		 SELECT	   StatusID VRBStatusID,
                   StatusCode VRBStatuscode,
                   StatusDescription VRBStatusDescription,
                   ParentStatusID,
                   ActiveFlag,
                   DetailedDesc,
                   CreatedDate,
                   LND_UpdateDate,
                   CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		 FROM stage.Dim_TERStatus
		 WHERE ParentStatusID=13 
		 UNION ALL 
		 SELECT -1, 'Unknown', 'Unknown', -1, 0,'Unknown',SYSDATETIME(),SYSDATETIME(),CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 

		 OPTION (LABEL = 'dbo.Dim_VRBStatus_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Dim_VRBStatus_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_VRBStatus_01 ON dbo.Dim_VRBStatus_NEW (VRBStatuscode);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_VRBStatus_NEW', 'dbo.Dim_VRBStatus'


		--=============================================================================================================
		-- Load dbo.Dim_VRBRemovalReason
		--=============================================================================================================
		 IF OBJECT_ID('dbo.Dim_VRBRemovalReason_NEW') IS NOT NULL DROP TABLE dbo.Dim_VRBRemovalReason_NEW
		 CREATE TABLE dbo.Dim_VRBRemovalReason_NEW WITH (CLUSTERED INDEX (VRBRemovalReasonID), DISTRIBUTION = REPLICATE) AS
		 SELECT	   StatusID VRBRemovalReasonID,
                   StatusCode VRBRemovalReasonCode,
                   StatusDescription VRBRemovalReasonDescription,
                   ParentStatusID,
                   ActiveFlag,
                   DetailedDesc,
                   CreatedDate,
                   LND_UpdateDate,
                   CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		 FROM stage.Dim_TERStatus
		 WHERE ParentStatusID IN (21,3) 
		 UNION ALL 
		 SELECT -1, 'Unknown', 'Unknown', -1, 0,'Unknown',SYSDATETIME(),SYSDATETIME(),CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 

		 OPTION (LABEL = 'dbo.Dim_VRBRemovalReason_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Dim_VRBRemovalReason_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_VRBRemovalReason_01 ON dbo.Dim_VRBRemovalReason_NEW (VRBRemovalReasonCode);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_VRBRemovalReason_NEW', 'dbo.Dim_VRBRemovalReason'


		--=============================================================================================================
		-- Load dbo.Dim_VRBRejectReason
		--=============================================================================================================

		 IF OBJECT_ID('dbo.Dim_VRBRejectReason_NEW') IS NOT NULL DROP TABLE dbo.Dim_VRBRejectReason_NEW
		 CREATE TABLE dbo.Dim_VRBRejectReason_NEW WITH (CLUSTERED INDEX (VRBRejectReasonID), DISTRIBUTION = REPLICATE) AS
		 SELECT	   VRBRejectLookupID VRBRejectReasonID,
                    VRBRejectCode VRBRejectReasonCode,
                    VRBRejectDesc VRBRejectReasonDescription,
                    IsActive ActiveFlag,
                    CreatedDate,
                    LND_UpdateDate,
					CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		 FROM LND_TBOS.TER.VRBRejectLookup
		 UNION ALL 
		 SELECT -1, 'Unknown', 'Unknown', 0, SYSDATETIME(),SYSDATETIME(),CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		 OPTION (LABEL = 'dbo.Dim_VRBRejectReason_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Dim_VRBRejectReason_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_VRBRejectReason_01 ON dbo.Dim_VRBRejectReason_NEW (VRBRejectReasonCode);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_VRBRejectReason_NEW', 'dbo.Dim_VRBRejectReason'


		--=============================================================================================================
		-- Load dbo.Dim_VRBAgency
		--=============================================================================================================
		 IF OBJECT_ID('dbo.Dim_VRBAgency_NEW') IS NOT NULL DROP TABLE dbo.Dim_VRBAgency_NEW
		 CREATE TABLE dbo.Dim_VRBAgency_NEW WITH (CLUSTERED INDEX (VRBAgencyID), DISTRIBUTION = REPLICATE) AS
		 SELECT	   VRBAgencyLookupID VRBAgencyID,
                     VRBAgencyCode VRBAgencyCode,
                     VRBAgencyDesc VRBAgencyDescription,
                     IsActive ActiveFlag,
                     CreatedDate,
                     LND_UpdateDate,
					 CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		FROM LND_TBOS.TER.VRBAgencyLookup		 
		 UNION ALL 
		 SELECT -1, 'Unknown', 'Unknown', 0, SYSDATETIME(),SYSDATETIME(),CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		 OPTION (LABEL = 'dbo.Dim_VRBAgency_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Dim_VRBAgency_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_VRBAgency_01 ON dbo.Dim_VRBAgency_NEW (VRBAgencyCode);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_VRBAgency_NEW', 'dbo.Dim_VRBAgency'

		--=============================================================================================================
		-- Load dbo.Dim_VBStatus
		--=============================================================================================================
	
		 IF OBJECT_ID('dbo.Dim_VBStatus_NEW') IS NOT NULL DROP TABLE dbo.Dim_VBStatus_NEW
		 CREATE TABLE dbo.Dim_VBStatus_NEW WITH (CLUSTERED INDEX (VBStatusID), DISTRIBUTION = REPLICATE) AS
		 SELECT	   StatusID VBStatusID,
                   StatusCode VBStatusCode,
                   StatusDescription VBStatusDescription,
                   ParentStatusID,
                   ActiveFlag,
                   DetailedDesc,
                   CreatedDate,
                   LND_UpdateDate,
                   CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		 FROM stage.Dim_TERStatus
		 WHERE ParentStatusID=23 
		 UNION ALL 
		 SELECT -1, 'Unknown', 'Unknown', -1, 0,'Unknown',SYSDATETIME(),SYSDATETIME(),CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 

		 OPTION (LABEL = 'dbo.Dim_VBStatus_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.dim_VBStatus_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_VBStatus_01 ON dbo.Dim_VBStatus_NEW (VBStatusCode);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_VBStatus_NEW', 'dbo.Dim_VBStatus'

		--=============================================================================================================
		-- Load dbo.Dim_VBRemovalReason
		--=============================================================================================================
		
		 IF OBJECT_ID('dbo.Dim_VBRemovalReason_NEW') IS NOT NULL DROP TABLE dbo.Dim_VBRemovalReason_NEW
		 CREATE TABLE dbo.Dim_VBRemovalReason_NEW WITH (CLUSTERED INDEX (VBRemovalReasonID), DISTRIBUTION = REPLICATE) AS
		 SELECT	   StatusID VBRemovalReasonID,
                   StatusCode VBRemovalReasonCode,
                   StatusDescription VBRemovalReasonDescription,
                   ParentStatusID,
                   ActiveFlag,
                   DetailedDesc,
                   CreatedDate,
                   LND_UpdateDate,
                   CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		 FROM stage.Dim_TERStatus
		 WHERE ParentStatusID IN (3,27) 
		 UNION ALL 
		 SELECT -1, 'Unknown', 'Unknown', -1, 0,'Unknown',SYSDATETIME(),SYSDATETIME(),CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 

		 OPTION (LABEL = 'dbo.Dim_VBRemovalReason_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Dim_VBRemovalReason_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_VBRemovalReason_01 ON dbo.Dim_VBRemovalReason_NEW (VBRemovalReasonCode);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_VBRemovalReason_NEW', 'dbo.Dim_VBRemovalReason'

		--=============================================================================================================
		-- Load dbo.Dim_TERLetterDeliverStatus
		--=============================================================================================================
		
		 IF OBJECT_ID('dbo.Dim_TER_LetterDeliverStatus_NEW') IS NOT NULL DROP TABLE dbo.Dim_TER_LetterDeliverStatus_NEW
		 CREATE TABLE dbo.Dim_TER_LetterDeliverStatus_NEW WITH (CLUSTERED INDEX (LetterDeliverStatusID), DISTRIBUTION = REPLICATE) AS
		 SELECT L2_LookupTypeCodeID LetterDeliverStatusID,
                L2_LookupTypeCode LetterDeliverStatusCode,
                L2_LookupTypeCodeDesc LetterDeliverStatusDesc,
                L1_LookupTypeCodeID,
                L1_LookupTypeCode,
                L1_LookupTypeCodeDesc,
                EDW_UpdateDate
		 FROM stage.Ref_LookupTypeCodes_Hierarchy WHERE L1_LookupTypeCodeID=3853
		 UNION ALL 
		 SELECT -1, 'Unknown', 'Unknown', -1,'Unknown','Unknown',CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		 
		 OPTION (LABEL = 'dbo.Dim_TER_LetterDeliverStatus_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Dim_TER_LetterDeliverStatus_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_TER_LetterDeliverStatus_01 ON dbo.Dim_TER_LetterDeliverStatus_NEW (LetterDeliverStatuscode);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_TER_LetterDeliverStatus_NEW', 'dbo.Dim_TER_LetterDeliverStatus'

		--=============================================================================================================
		-- Load dbo.Dim_CitationStatus
		--=============================================================================================================
		
		 IF OBJECT_ID('dbo.Dim_CitationStatus_NEW') IS NOT NULL DROP TABLE dbo.Dim_CitationStatus_NEW
		 CREATE TABLE dbo.Dim_CitationStatus_NEW WITH (CLUSTERED INDEX (CitationStatusID), DISTRIBUTION = REPLICATE) AS
		 SELECT	   StatusID CitationStatusID,
                   StatusCode CitationStatusCode,
                   StatusDescription CitationStatusDescription,
                   ParentStatusID,
                   ActiveFlag,
                   DetailedDesc,
                   CreatedDate,
                   LND_UpdateDate,
                   CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		 FROM stage.Dim_TERStatus
		 WHERE ParentStatusID IN (117,69,118)
		 UNION ALL 
		 SELECT -1, 'Unknown', 'Unknown', -1, 0,'Unknown',SYSDATETIME(),SYSDATETIME(),CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 

		 OPTION (LABEL = 'dbo.Dim_CitationStatus_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Dim_CitationStatus_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_CitationStatus_01 ON dbo.Dim_CitationStatus_NEW (CitationStatusCode);
		CREATE STATISTICS STATS_dbo_Dim_CitationStatus_02 ON dbo.Dim_CitationStatus_NEW (CitationStatusDescription);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_CitationStatus_NEW', 'dbo.Dim_CitationStatus'


		--=============================================================================================================
		-- Load dbo.Dim_Court
		--=============================================================================================================
		
		 IF OBJECT_ID('dbo.Dim_Court_NEW') IS NOT NULL DROP TABLE dbo.Dim_Court_NEW
		 CREATE TABLE dbo.Dim_Court_NEW WITH (CLUSTERED INDEX (CourtID), DISTRIBUTION = REPLICATE) AS
		 SELECT	  CourtID,
                  CountyID,
                  CourtName,
                  AddressLine1,
                  AddressLine2,
                  City,
                  State,
                  Zip1,
                  Zip2,
                  StartEffectiveDate,
                  EndEffectiveDate,
                  PrecinctNumber,
                  PlaceNumber,
                  TelephoneNumber,
                  LND_UpdateDate,
                  CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		FROM LND_TBOS.Court.Courts
		 UNION ALL 
		 SELECT -1, -1, 'Unknown','Unknown','Unknown','Unknown','Unknown', -1, -1,SYSDATETIME(),SYSDATETIME(),'Unknown','Unknown','Unknown',SYSDATETIME(),CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 

		 OPTION (LABEL = 'dbo.Dim_Court_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Dim_Court_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_Court_01 ON dbo.Dim_Court_NEW (CourtName);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_Court_NEW', 'dbo.Dim_Court'
		
		--=============================================================================================================
		-- Load dbo.Dim_CourtJudge
		--=============================================================================================================
		
		 IF OBJECT_ID('dbo.Dim_CourtJudge_NEW') IS NOT NULL DROP TABLE dbo.Dim_CourtJudge_NEW
		 CREATE TABLE dbo.Dim_CourtJudge_NEW WITH (CLUSTERED INDEX (JudgeID), DISTRIBUTION = REPLICATE) AS
		 SELECT	    JudgeID,
                    CourtID,
                    LastName,
                    FirstName,
                    StartEffectiveDate,
                    EndEffectiveDate,
                    CreatedDate,
                    LND_UpdateDate,
                    CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		 FROM LND_TBOS.Court.Courtjudges
		 UNION ALL 
		 SELECT -1, -1,'Unknown', 'Unknown', SYSDATETIME(),SYSDATETIME(),SYSDATETIME(),SYSDATETIME(),CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 

		 OPTION (LABEL = 'dbo.Dim_CourtJudge_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Dim_CourtJudge_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_CourtJudge_01 ON dbo.Dim_CourtJudge_NEW (CourtID);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_CourtJudge_NEW', 'dbo.Dim_CourtJudge'

		--=============================================================================================================
		-- Load dbo.Dim_DPSTrooper
		--=============================================================================================================
		
		 IF OBJECT_ID('dbo.Dim_DPSTrooper_NEW') IS NOT NULL DROP TABLE dbo.Dim_DPSTrooper_NEW
		 CREATE TABLE dbo.Dim_DPSTrooper_NEW WITH (CLUSTERED INDEX (DPSTrooperID), DISTRIBUTION = REPLICATE) AS
		 SELECT   DPSTrooperID,
                  FirstName,
                  LastName,
                  Area,
                  District,
                  IDNumber,
                  Region,
                  ChannelID,
                  ICNID,
                  TrooperSignatureImage,
                  IsActive,
                  FilePathConfigurationID,
                  CreatedDate,
                  LND_UpdateDate,
				  CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 
		 FROM LND_TBOS.TER.DPSTrooper
		 UNION ALL 
		 SELECT -1, 'Unknown','Unknown','Unknown','Unknown',-1,'Unknown',-1,-1, 'Unknown', -1,-1,SYSDATETIME(),SYSDATETIME(),CAST (SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate 

		 OPTION (LABEL = 'dbo.Dim_DPSTrooper_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Dim_DPSTrooper_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_DPSTrooper_01 ON dbo.Dim_DPSTrooper_NEW (FirstName);
		CREATE STATISTICS STATS_dbo_Dim_DPSTrooper_02 ON dbo.Dim_DPSTrooper_NEW (LastName);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_DPSTrooper_NEW', 'dbo.Dim_DPSTrooper'


		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 
		BEGIN
		    SELECT TOP 100 'Stage.Dim_TERStatus' TableName, * FROM Stage.Dim_TERStatus ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_HVStatus' TableName, * FROM dbo.Dim_HVStatus ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_PaymentPlanStatus' TableName, * FROM dbo.Dim_PaymentPlanStatus ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_VRBStatus' TableName, * FROM dbo.Dim_VRBStatus ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_VBStatus' TableName, * FROM dbo.Dim_VBStatus ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_VRBRemovalReason' TableName, * FROM dbo.Dim_VRBRemovalReason ORDER BY 2
		    SELECT TOP 100 'dbo.Dim_VBRemovalReason' TableName, * FROM dbo.Dim_VBRemovalReason ORDER BY 2
			SELECT TOP 100 'dbo.Dim_VRBRejectReason' TableName, * FROM dbo.Dim_VRBRejectReason ORDER BY 2
			SELECT TOP 100 'dbo.Dim_VRBAgency' TableName, * FROM dbo.Dim_VRBAgency ORDER BY 2	
			SELECT TOP 100 'dbo.Dim_TER_LetterDeliverStatus' TableName, * FROM dbo.Dim_TER_LetterDeliverStatus ORDER BY 2	
			SELECT TOP 100 'dbo.Dim_Court' TableName, * FROM dbo.Dim_Court ORDER BY 2
			SELECT TOP 100 'dbo.Dim_CourtJudge' TableName, * FROM dbo.Dim_CourtJudge ORDER BY 2
			SELECT TOP 100 'dbo.Dim_DPSTrooper' TableName, * FROM dbo.Dim_DPSTrooper ORDER BY 2
			SELECT TOP 100 'dbo.Dim_CitationStatus' TableName, * FROM dbo.Dim_CitationStatus ORDER BY 2
		
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
EXEC dbo.Dim_TERStatus_Load

EXEC Utility.FromLog 'dbo.Dim_TERStatus', 1
SELECT TOP 100 'dbo.Dim_TERStatus' Table_Name, * FROM dbo.Dim_TERStatus ORDER BY 2

SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_TERStatus%' ORDER BY logdate desc


--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================


*/


