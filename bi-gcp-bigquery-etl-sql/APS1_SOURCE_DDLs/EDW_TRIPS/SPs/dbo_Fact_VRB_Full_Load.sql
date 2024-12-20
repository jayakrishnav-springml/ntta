CREATE PROC [dbo].[Fact_VRB_Full_Load] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_VRB table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0043961		    Gouthami	2023-10-30	New!
											1. This fact table is created to pull the Vehicle registration block 
											   data for an HV. (For an HV, there are multiple VRB's)
CHG0044321		    Gouthami	2024-01-08	Pulled RITE data for VRB dates. TRIPS did not migrate the correct data
											for migrated VRB's
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_VRB_Full_Load

EXEC Utility.FromLog 'dbo.Fact_VRB', 1
SELECT TOP 100 'dbo.Fact_VRB' Table_Name, * FROM dbo.Fact_VRB ORDER BY 2
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_VRB_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL
		
		--=============================================================================================================
		-- Load dbo.Fact_VRB
		--=============================================================================================================
		IF OBJECT_ID('dbo.Fact_VRB_NEW') IS NOT NULL DROP TABLE dbo.Fact_VRB_NEW
		CREATE TABLE dbo.Fact_VRB_NEW WITH (CLUSTERED INDEX (HVID), DISTRIBUTION = REPLICATE) AS

		SELECT Main.VRBID
               ,ISNULL(Main.HVID,-1) HVID
               ,ISNULL(Main.CustomerID,-1) CustomerID
			   ,ISNULL(Main.VehicleID,-1) VehicleID
			   ,ISNULL(Main.VRBStatuslookupID,-1) VRBStatusID
               ,ISNULL(Main.VRBAgencyID,-1) VRBAgencyID
               ,ISNULL(Main.VRBRejectReasonID,-1) VRBRejectReasonID
               ,ISNULL(Main.VRBRemovalReasonID,-1) VRBRemovalReasonID
			   ,ISNULL(L.LetterDeliverStatusID,-1) VRBLetterDeliverStatusID
			   ,CAST(LEFT(CONVERT(VARCHAR,Main.VRBRequestedDate,112),8) AS INT)  VRBRequestedDayID
               ,CAST(LEFT(CONVERT(VARCHAR,Main.VRBAppliedDate,112),8) AS INT)  VRBAppliedDayID 
			   ,CAST(LEFT(CONVERT(VARCHAR,Main.VRBRemovedDate,112),8) AS INT) VRBRemovedDayID	
               ,Main.VRBActiveFlag
               ,Main.DallasScOffLaw DallasScOffLawFlag
               ,Main.VRBCreatedDate    
			   ,Main.VRBRejectionDate
			   ,L.VRBLetterMailedDate
			   ,L.VRBLetterDeliveredDate
			   ,ISNULL(CAST(SYSDATETIME() AS datetime2(3)), '1900-01-01') AS EDW_UpdateDate -- select *
		FROM
		(
		    SELECT ROW_NUMBER() OVER (PARTITION BY VRB.HVID ORDER BY VRB.VRBID DESC) RN,
		           VRB.VRBID,
		           VRB.HVID,
		           HV.CustomerID,
				   HV.VehicleID,
				   VRB.VRBAgencyLookupID VRBAgencyID,
				   VRB.VRBRejectLookupID VRBRejectReasonID,
				   VRB.VRBRemovalLookupID VRBRemovalReasonID,
		           HVS.StatusDescription VRBStatusDescription,
				   HVS.HVStatusLookupID VRBStatuslookupID,
		           AG.VRBAgencyDesc VRBAgencyName,		           
		           Rej.VRBRejectDesc VRBRejectReason,	           
		           HVS1.StatusDescription VRBRemovalReason,
				   HV.LicensePlateNumber,
				   HV.LicensePlateState,
		           VRB.IsActive VRBActiveFlag,
		           VRD.DallasScOffLaw,
		           VRB.CreatedDate VRBCreatedDate,
		           RequestedDate VRBRequestedDate,
		           CASE WHEN VRB.RemovedDate<VRB.PlacedDate AND VRB.RemovedDate IS NOT NULL THEN Ref.AppliedDate
				   ELSE COALESCE(PlacedDate,ref.AppliedDate) END VRBAppliedDate,
				   VRB.RemovedDate VRBRemovedDate,
				   VRB.RejectionDate VRBRejectionDate,
				   VRB.LND_UpdateDate --SELECT COUNT(*) -- 1155505
		    FROM LND_TBOS.TER.VehicleRegBlocks VRB
		        JOIN EDW_TRIPS.dbo.Dim_HabitualViolator HV
		            ON HV.HVID = VRB.HVID
				LEFT JOIN Ref.vw_Vrb Ref ON Ref.VrbID = VRB.VRBID
		        LEFT JOIN LND_TBOS.TER.VRBRejectLookup Rej
		            ON Rej.VRBRejectLookupID = VRB.VRBRejectLookupID
		        LEFT JOIN LND_TBOS.TER.HVStatusLookup HVS
		            ON HVS.HVStatusLookupID = VRB.StatusLookupID
		        LEFT JOIN LND_TBOS.TER.HVStatusLookup HVS1
		            ON HVS1.HVStatusLookupID = VRB.VRBRemovalLookupID
		        LEFT JOIN LND_TBOS.TER.VRBAgencyLookup AG
		            ON AG.VRBAgencyLookupID = VRB.VRBAgencyLookupID
		        LEFT JOIN
		        (
		            SELECT DISTINCT
		                   VRBID,
		                   VRD.DallasScOffLaw
		            FROM LND_TBOS.TER.VRBRequestDallas VRD
		            WHERE OffenceDate IS NOT NULL
		        ) VRD
		            ON VRD.VRBID = VRB.VRBID
		) Main
		   LEFT  JOIN
		    (
		        SELECT HV.HVID,
		               OC.CommunicationDate VRBLetterMailedDate,
					   OC.DeliveryDate VRBLetterDeliveredDate,
		               OC.Description,
		               R.LookupTypeCodeID LetterDeliverStatusID,
		               ROW_NUMBER() OVER (PARTITION BY HV.HVID ORDER BY OC.CommunicationDate DESC) RN
		        FROM LND_TBOS.TER.HabitualViolators HV
		            JOIN
		            (
		                SELECT DISTINCT
		                       LinkID,
		                       CustomerNotificationQueueID,
		                       NotifStatus
		                FROM LND_TBOS.Notifications.CustomerNotificationQueue
		                WHERE LinkSource = 'TER.HabitualViolators'

		            ) notif
		                ON HV.HVID = notif.LinkID
		            JOIN LND_TBOS.DocMgr.TP_Customer_OutboundCommunications OC
		                ON OC.QueueID = notif.CustomerNotificationQueueID
		                   AND OC.DocumentType IN ('VRBLetter','VRB')
		            JOIN LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy R
		                ON R.LookupTypeCodeID = notif.NotifStatus
		                   AND Parent_LookupTypeCodeID = 3853					

		    ) L
		        ON L.HVID = Main.HVID AND L.RN=Main.RN				 
		
	
	
		OPTION (LABEL='dbo.Fact_VRB_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Fact_VRB_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Fact_VRB_01 ON dbo.Fact_VRB_NEW (VRBID);
		CREATE STATISTICS STATS_dbo_Fact_VRB_02 ON dbo.Fact_VRB_NEW (HVID);
		CREATE STATISTICS STATS_dbo_Fact_VRB_03 ON dbo.Fact_VRB_NEW (VRBStatusID);
		CREATE STATISTICS STATS_dbo_Fact_VRB_04 ON dbo.Fact_VRB_NEW (CustomerID);
		CREATE STATISTICS STATS_dbo_Fact_VRB_05 ON dbo.Fact_VRB_NEW (VRBAppliedDayID);
		CREATE STATISTICS STATS_dbo_Fact_VRB_06 ON dbo.Fact_VRB_NEW (VRBRequestedDayID);
		CREATE STATISTICS STATS_dbo_Fact_VRB_07 ON dbo.Fact_VRB_NEW (VRBRemovedDayID);
		CREATE STATISTICS STATS_dbo_Fact_VRB_08 ON dbo.Fact_VRB_NEW (VRBLetterMailedDate);
		CREATE STATISTICS STATS_dbo_Fact_VRB_09 ON dbo.Fact_VRB_NEW (VRBLetterDeliveredDate);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Fact_VRB_NEW', 'dbo.Fact_VRB'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Fact_VRB' TableName, * FROM dbo.Fact_VRB ORDER BY 2 DESC
	
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
EXEC dbo.Fact_VRB_Load

EXEC Utility.FromLog 'dbo.Fact_VRB', 1
SELECT TOP 100 'dbo.Fact_VRB' Table_Name, * FROM dbo.Fact_VRB ORDER BY 2


select * FROM dbo.Fact_VRB ORDER BY 2
select count(*) FROM dbo.Fact_VRB --110984 
select * FROM edw_trips.dbo.Fact_VRB  where customerid = 806539432
select * FROM edw_trips_dev.dbo.Fact_VRB  where customerid = 806539432


WHERE VRB.HVID IN (185338,9,542089,542015)
--ORDER BY HVID
---------------------------------------------------OLD CODE--------------------------------------------------------
					SELECT VRB.VRBID,
						   VRB.HVID,  
						   HV.ViolatorID CustomerID,
						   VRB.StatusLookupID VRBStatusID,
						   HVS.StatusDescription VRBStatusDescription,
						   VRB.VRBAgencyLookupID VRBAgencyID,
						   AG.VRBAgencyDesc VRBAgencyName,
						   VRB.VRBRejectLookupID VRBRejectReasonID,
						   Rej.VRBRejectDesc VRBRejectReason,
						   --VRBremovalRejectionLookupID,
						   VRBRemovalLookupID VRBRemovalReasonID,
						   HVS1.StatusDescription VRBRemovalReason,	
						   VRB.IsActive VRBActiveFlag,
						   VRD.DallasScOffLaw,
						   VRB.CreatedDate VRBCreatedDate,
						   RequestedDate VRBRequestedDate,
						   PlacedDate VRBAppliedDate,
						   RemoveRequestedDate VRBRemoveRequestedDate,
						   RemovedDate VRBRemovedDate,
						   RemoveRejectionDate VRBRemoveRejectionDate,
						   RejectionDate VRBRejectionDate, 	   
						          
						   --RetryCount,
						   VRB.LND_UpdateDate,
						   ISNULL(CAST(SYSDATETIME() AS datetime2(3)), '1900-01-01') AS EDW_UpdateDate -- select count(*)
					FROM LND_TBOS.TER.VehicleRegBlocks VRB
					JOIN LND_TBOS.TER.HabitualViolators HV ON HV.HVID = VRB.HVID
					LEFT JOIN LND_TBOS.TER.VRBRejectLookup Rej ON Rej.VRBRejectLookupID = VRB.VRBRejectLookupID
					LEFT JOIN LND_TBOS.TER.HVStatusLookup HVS ON HVS.HVStatusLookupID=VRB.StatusLookupID
					LEFT JOIN LND_TBOS.TER.HVStatusLookup HVS1 ON HVS1.HVStatusLookupID = VRB.VRBRemovalLookupID
					LEFT JOIN LND_TBOS.TER.VRBAgencyLookup AG ON AG.VRBAgencyLookupID=VRB.VRBAgencyLookupID
					LEFT JOIN 
							 ( 
								 SELECT DISTINCT
								        VRBID,
								        VRD.DallasScOffLaw
								 FROM LND_TBOS.TER.VRBRequestDallas VRD
								 WHERE OffenceDate IS NOT NULL
							  ) VRD 
							 ON VRD.VRBID = VRB.VRBID

			)

-- Testing
SELECT * FROM dbo.Fact_VRB WHERE VRBAppliedDayID>VRBRemovedDayID

SELECT * FROM dbo.Fact_VRB WHERE VRBRequestedDayID>VRBRemovedDayID
			

*/


