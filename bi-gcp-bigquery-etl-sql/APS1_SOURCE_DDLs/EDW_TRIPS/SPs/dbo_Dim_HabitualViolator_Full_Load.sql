CREATE PROC [dbo].[Dim_HabitualViolator_Full_Load] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_HabitualViolator table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
			Gouthami		2023-05-08	Created
			Shekhar			2023-07-18  Fixed bug identified in internal audit (EarliestHVTerminationLetterDeliveredDate)
			Shekhar			2023-07-24  Fixed AdminHearingStatus Bug
			Shekhar			2023-07-25  Fixed AdminHearingCounty Bug  (Worked with Sagarika)
			Shekhar			2023-07-25  Modified  in ('VehicleBanLetter', 'VEHBAN') & in('VRBLetter', 'VRB') for DocumentType
			Shekhar			2023-05-25  Added New columns and removed old columns for VRB and VB
CHG0043993	Gouthami		2023-11-02	Fixed duplicate issue caused by Admin hearing status. 
CHG0044527	Gouthami		2024-02-08	Added Earliest & Latest Citation dates for an HV/Customer
===================================================================================================================
Example:
EXEC [dbo].[Dim_HabitualViolator_Full_Load]
--EXEC Utility.FromLog 'dbo.Dim_HabitualViolator', 1
SELECT TOP 100 'dbo.Dim_HabitualViolator' Table_Name, * FROM dbo.Dim_HabitualViolator ORDER BY 2
###################################################################################################################
*/



BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_HabitualViolator_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load dbo.Dim_HabitualViolator
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_HabitualViolator_NEW') IS NOT NULL DROP TABLE dbo.Dim_HabitualViolator_NEW
		CREATE TABLE dbo.Dim_HabitualViolator_NEW WITH (CLUSTERED INDEX (HVID), DISTRIBUTION = REPLICATE) AS
		
		
				
		WITH CTE_LetterDates
		AS
		(

		SELECT B.HVID,
		       MAX(B.LatestHVDeterminationCommunicationDate) LatestHVDeterminationCommunicationDate,
		       MAX(B.LatestVRBCommunicationDate) LatestVRBCommunicationDate,
		       MAX(B.LatestHVTerminationCommunicationDate) LatestHVTerminationCommunicationDate,
		       MAX(B.LatestVehicleBanCommunicationDate) LatestVehicleBanCommunicationDate,
		
		       MAX(B.EarliestHVDeterminationCommunicationDate) EarliestHVDeterminationCommunicationDate,
		       MAX(B.EarliestVRBCommunicationDate) EarliestVRBCommunicationDate,
		       MAX(B.EarliestHVTerminationCommunicationDate) EarliestHVTerminationCommunicationDate,
		       MAX(B.EarliestVehicleBanCommunicationDate) EarliestVehicleBanCommunicationDate,
		
		       MAX(B.LatestHVDeterminationDeliveryDate) LatestHVDeterminationDeliveryDate,
		       MAX(B.LatestVRBDeliveryDate) LatestVRBDeliveryDate,
		       MAX(B.LatestHVTerminationDeliveryDate) LatestHVTerminationDeliveryDate,
		       MAX(B.LatestVehicleBanDeliveryDate) LatestVehicleBanDeliveryDate,
		
		       MAX(B.EarliestHVDeterminationDeliveryDate) EarliestHVDeterminationDeliveryDate,
		       MAX(B.EarliestVRBDeliveryDate) EarliestVRBDeliveryDate,
		       MAX(B.EarliestHVTerminationDeliveryDate) EarliestHVTerminationDeliveryDate,
		       MAX(B.EarliestVehicleBanDeliveryDate) EarliestVehicleBanDeliveryDate 
		FROM 
		(			
					SELECT HVID,
					  --- Latest Communication Dates
					  CASE WHEN documentType='HVDeterminationLetter'
						   THEN latestCommunicationDate
						   END LatestHVDeterminationCommunicationDate,
					  CASE WHEN documentType in('VRBLetter', 'VRB')
						   THEN latestCommunicationDate
						   END LatestVRBCommunicationDate,
					 CASE WHEN documentType='HVTerminationLetter'
						   THEN latestCommunicationDate
						   END LatestHVTerminationCommunicationDate,
					 CASE WHEN documentType in ('VehicleBanLetter', 'VEHBAN')
						   THEN latestCommunicationDate
						   END LatestVehicleBanCommunicationDate,

				      -- Earliest Communication Dates
					  CASE WHEN documentType='HVDeterminationLetter'
						   THEN A.EarliestCommunicationDate
						   END EarliestHVDeterminationCommunicationDate,
					  CASE WHEN documentType in('VRBLetter', 'VRB')
						   THEN A.EarliestCommunicationDate
						   END EarliestVRBCommunicationDate,
					 CASE WHEN documentType='HVTerminationLetter'
						   THEN A.EarliestCommunicationDate
						   END EarliestHVTerminationCommunicationDate,
					 CASE WHEN documentType in ('VehicleBanLetter', 'VEHBAN')
						   THEN A.EarliestCommunicationDate
						   END EarliestVehicleBanCommunicationDate,
					
					--- Latest Delivery Dates
					 CASE WHEN documentType='HVDeterminationLetter'
						   THEN A.LatestDeliveryDate
						   END LatestHVDeterminationDeliveryDate,
					 CASE WHEN documentType in('VRBLetter', 'VRB')
						   THEN A.LatestDeliveryDate
						   END LatestVRBDeliveryDate,
					 CASE WHEN documentType='HVTerminationLetter'
						   THEN A.LatestDeliveryDate
						   END LatestHVTerminationDeliveryDate,
					 CASE WHEN documentType in ('VehicleBanLetter', 'VEHBAN')
						   THEN A.LatestDeliveryDate
						   END LatestVehicleBanDeliveryDate,
				
					 --- Earliest Delivery Dates
					 CASE WHEN documentType='HVDeterminationLetter'
						   THEN A.EarliestDeliveryDate
						   END EarliestHVDeterminationDeliveryDate,
					  CASE WHEN documentType in('VRBLetter', 'VRB')
						   THEN A.EarliestDeliveryDate
						   END EarliestVRBDeliveryDate,
					 CASE WHEN documentType='HVTerminationLetter'
						   THEN A.EarliestDeliveryDate
						   END EarliestHVTerminationDeliveryDate,
					 CASE WHEN documentType in ('VehicleBanLetter', 'VEHBAN')
						   THEN A.EarliestDeliveryDate
						   END EarliestVehicleBanDeliveryDate
				
					FROM (
							SELECT notif.LinkID HVID,
								   OC.DocumentType,
								   MAX(OC.CommunicationDate) LatestCommunicationDate,
								   MIN(OC.CommunicationDate) EarliestCommunicationDate,
								   MAX(OC.DeliveryDate) LatestDeliveryDate,
								   MIN(OC.DeliveryDate) EarliestDeliveryDate
							
							FROM lnd_tbos.ter.HabitualViolators HV 
							JOIN ( SELECT DISTINCT linkid,CustomerNotificationQueueID
									FROM LND_TBOS.Notifications.CustomerNotificationQueue
									WHERE LinkSource='TER.HabitualViolators'
								 ) notif on HV.HvId=notif.LinkId
							JOIN LND_TBOS.DocMgr.TP_Customer_OutboundCommunications OC
									 ON OC.QueueID = notif.CustomerNotificationQueueID
							--WHERE notif.LinkID=862444
							GROUP BY notif.LinkID,
                                     OC.DocumentType
						 ) A 
			) B GROUP BY B.HVID	
		
		),

		-------------------------------------------------------------
		-- Added by Shekhar
		-- VRB Dates and Status from nd_tbos.TER.VehicleRegBlocks
		------------------------------------------------------------
		CTE_EarliestVRBDates as
		(
			SELECT * FROM (
						SELECT	VRB.HVID, 
								ROW_NUMBER() OVER (PARTITION BY VRB.HVID ORDER BY VRB.RequestedDate ASC) RN,
								StatusLookupID EarliestVRBStatusID,VRB.VRBRemovalLookupID EarliestVRBRemovalLookupID,RequestedDate EarliestVRBRequestedDate,
								PlacedDate EarliestVRBPlacedDate,RemovedDate EarliestVRBRemovedDate
						FROM  LND_TBOS.TER.VehicleRegBlocks VRB
						--WHERE HVID = 230019
						GROUP BY VRB.HVID,VRB.StatusLookupID,VRB.VRBRemovalLookupID,
						         VRB.RequestedDate,VRB.PlacedDate,VRB.RemovedDate
					  ) A WHERE RN=1
		),
		CTE_LatestDates AS 
		(
			SELECT * FROM (
						SELECT	VRB.HVID, 
								ROW_NUMBER() OVER (PARTITION BY VRB.HVID ORDER BY VRB.RequestedDate desc) RN,
								StatusLookupID LatestVRBStatusID,VRB.VRBRemovalLookupID LatestVRBRemovalLookupID,RequestedDate LatestVRBRequestedDate,
								PlacedDate LatestVRBPlacedDate,RemovedDate LatestVRBRemovedDate

						FROM  LND_TBOS.TER.VehicleRegBlocks VRB
						--WHERE HVID = 230019
						GROUP BY VRB.HVID,VRB.StatusLookupID,VRB.VRBRemovalLookupID,
						         VRB.RequestedDate,VRB.PlacedDate,VRB.RemovedDate
					  ) A WHERE RN=1
			),
			CTE_VRBDates AS 
			(
			SELECT E.HVID,
                   E.EarliestVRBStatusID,HVS.StatusDescription EarliestVRBStatusDescription,
				   E.EarliestVRBRemovalLookupID,HVSR.StatusDescription EarliestVRBRemovallookupDescription,
				   E.EarliestVRBRequestedDate,E.EarliestVRBPlacedDate,E.EarliestVRBRemovedDate,
				   L.LatestVRBStatusID,HVS1.StatusDescription LatestVRBStatusDescription,
				   L.LatestVRBRemovalLookupID,HVSR1.StatusDescription LatestVRBRemovallookupDescription,
				   L.LatestVRBRequestedDate,L.LatestVRBPlacedDate,L.LatestVRBRemovedDate 
			FROM CTE_EarliestVRBDates E
			JOIN CTE_LatestDates L ON L.HVID = E.HVID
			JOIN LND_TBOS.TER.HVStatusLookup HVS ON E.EarliestVRBStatusID=HVS.HVStatusLookupID 
			JOIN LND_TBOS.TER.HVStatusLookup HVS1 ON  L.LatestVRBStatusID=HVS1.HVStatusLookupID
			LEFT JOIN LND_TBOS.TER.HVStatusLookup HVSR ON HVSR.HVStatusLookupID = E.EarliestVRBRemovalLookupID
			LEFT JOIN LND_TBOS.TER.HVStatusLookup HVSR1 ON HVSR1.HVStatusLookupID = L.LatestVRBRemovalLookupID

			),
		
		-------------------------------------------------------------
		-- Added by Shekhar
		-- VB Dates and Status from nd_tbos.TER.VehicleBan
		------------------------------------------------------------
		CTE_VBRemovalDate as 
		(
		select  VB.hvid, VB.ActionDate  as VBRemovedDate , VB.RemovalLookupID   as RemovalReasonID , HVS.StatusCode RemovalReasonCode
		from    lnd_tbos.TER.VehicleBan VB
				join LND_TBOS.TER.HVStatusLookup HVS on HVS.HVStatusLookupID = VB.RemovalLookupID
		where   VB.ActionDate >= '2021-01-01' and VB.VBLookupID = 28  -- Ban Removed
		),
		CTE_VBAppliedDate as
		(
		select  VB.hvid, VB.ActionDate  as VBAppliedDate
		from    lnd_tbos.TER.VehicleBan VB
		where   VB.ActionDate >= '2021-01-01' and VB.VBLookupID = 26  -- Ban Applied
		),
	    CTE_BanDates as
	    (
		select  isnull(CTE_VBRemovalDate.HVID, CTE_VBAppliedDate.HVID) HVID, VBRemovedDate, RemovalReasonID, RemovalReasonCode, CTE_VBAppliedDate.VBAppliedDate
		from        CTE_VBAppliedDate full outer join CTE_VBRemovalDate on CTE_VBRemovalDate.HVID = CTE_VBAppliedDate.HVID
	   ),

		
		CTE_Main AS 
		(
						SELECT hv.HVID,
						       hv.ViolatorID CustomerID,
						       hv.VehicleID,
						       V.LicensePlateState,
						       V.LicensePlateNumber,
						       HvSts.HVStatusLookupID,
						       hv.CurrentStatusCode HVCurrentStatus,							  
						      -- Modified the following 3 lines by Shekhar on 7/25/2023
							  -- CASE WHEN AH.AdminHearingCounty=TC3.CountyName THEN TC3.CountyNo ELSE -1 END AS AdminHearingCountyID,
							   AH.CountyID AS AdminHearingCountyID,  
						       TC3.CountyName AS AdminHearingCountyName,
						       AH.HVStatusLookupID AdminHearingStatusID, -- Modified By Shekhar on 7/24/2023 after noticing the inaccurate AdminHearding status 
						       HvSts1.StatusCode AdminHeaderingStatus, -- Modified By Shekhar on 7/24/2023 after noticing the inaccurate AdminHearding status 
						       AH.HearingReason AdminHearingReason,
						       AH.RequestedDate AdminHearingRequestedDate,						    
						       hv.VehicleRegistrationCounty VehicleRegistrationCountyID,
						       TC1.CountyName VehicleRegistrationCountyName,						    
						       hv.RovAddressCounty RovAddressCountyID,
						       TC2.CountyName RovAddressCountyName,
						       hv.HVFirstQualifiedTranDate,
						       hv.HVLastQualifiedTranDate,
						       hv.HVDesignationDate HVDeterminationDate,						    				           
					           hv.HVTerminationDate,
							   AH.HearingDate Scheduledhearingdate,
							   FTP.EarliestCitationDate,
							   FTP.LatestCitationDate,
						       hv.HVTerminationReason,							   
						       hv.HVQualifiedTranCount HVTransactionCount,	
						       hv.TotalTranCount,
						       hv.TotalCitationCount,
						       hv.HVQualifiedTollsDue HVTollsDue,
						       hv.HVQualifiedFeesDue HVFeesDue,
						       hv.HVQualifiedAmountDue HVCurrentDue,
							   MBS.TotalAmount AS MBSCurrentDue,
							   HV.LND_UpdateDate -- select *
						 FROM    	
						     LND_TBOS.TER.HabitualViolators hv
							 LEFT JOIN LND_TBOS.TER.HVStatusLookup HvSts ON hv.CurrentStatusCode=HvSts.StatusCode AND HvSts.ParentStatusID IN (23,43,13,0)
							
						     LEFT JOIN LND_TBOS.TollPlus.TexasCounties TC1 
						    	ON HV.VehicleRegistrationCounty = TC1.CountyNo
						     LEFT JOIN LND_TBOS.TollPlus.TexasCounties TC2 
						    	ON HV.RovAddressCounty = TC2.CountyNo
						     LEFT JOIN 
									(	SELECT * FROM (
														SELECT AdminHearingID,
															   HVID, 
															   JudgeID,
															   HVStatusLookupID,
															   HearingDate,
															   CountyID,
															   RequestedDate,
															   HearingReason,
															   Comments,
															   ROW_NUMBER() OVER(PARTITION BY HVID ORDER BY RequestedDate ASC) RN
															   FROM LND_TBOS.court.AdminHearing 
														) A
											 WHERE RN=1
									 ) AH
								ON AH.HVID = hv.HVID
							 LEFT JOIN LND_TBOS.TollPlus.TexasCounties TC3
						    	ON AH.CountyID = TC3.CountyID 
						     LEFT JOIN EDW_TRIPS.dbo.Dim_Vehicle V
						    		ON V.VehicleID = HV.VehicleID
						     
							  LEFT JOIN LND_TBOS.TER.HVStatusLookup HvSts1 ON AH.HVStatusLookupID=HvSts1.HVStatusLookupID -- Added By Shekhar on 7/24/2023 after noticing the inaccurate AdminHearding status 
							 LEFT JOIN ( SELECT CustomerID,Totalamount FROM LND_TBOS.tollplus.MbsHeader WHERE IsPresentMbs = 1) MBS ON MBS.CustomerID=HV.ViolatorID
							 LEFT JOIN 
									   ( SELECT ViolatorID,MIN(MailDate) EarliestCitationDate, MAX(MailDate) LatestCitationDate -- A customer can be issued multiple citations (not in a month). 
										 FROM LND_TBOS.TER.FailureToPayCitations 
										 WHERE DPSCitationIssuedDate IS NOT NULL --- when DPS officer issue any citation to customer, then it is a valid citation
										 GROUP BY ViolatorID
									   )FTP ON FTP.ViolatorID = hv.ViolatorID
						    --WHERE hv.hvid=20602 -- mbs due not same as GUI
			) 
					SELECT A.HVID,
                           A.CustomerID,
                           A.VehicleID,
						   A.LicensePlateState,
						   A.LicensePlateNumber,
                           A.HVStatusLookupID,
                           A.HVCurrentStatus,
						   A.HVTerminationReason,
                           A.HVTransactionCount,						   
                           A.AdminHearingCountyID,
                           A.AdminHearingCountyName,
                           A.AdminHearingStatusID,
                           A.AdminHeaderingStatus,
                           A.AdminHearingReason,
                           A.AdminHearingRequestedDate,

                           A.VehicleRegistrationCountyID,
                           A.VehicleRegistrationCountyName,

                           A.RovAddressCountyID,
                           A.RovAddressCountyName,

                           A.HVFirstQualifiedTranDate,
                           A.HVLastQualifiedTranDate,

                           A.HVDeterminationDate,
                           LD.LatestHVDeterminationCommunicationDate LatestHVDeterminationLetterMailedDate,
						   LD.LatestHVDeterminationDeliveryDate LatestHVDeterminationLetterDeliveredDate, --(deliverydate FROM outboundcommunications TABLE)
						   LD.EarliestHVDeterminationCommunicationDate EarliestHVDeterminationLetterMailedDate,
						   LD.EarliestHVDeterminationDeliveryDate EarliestHVDeterminationLetterDeliveredDate, 

                           A.HVTerminationDate HVTerminationDate,
                           LD.LatestHVTerminationCommunicationDate LatestHVTerminationLetterMailedDate,
						   LD.LatestHVTerminationDeliveryDate LatestHVTerminationLetterDeliveryDate,
						   LD.EarliestHVTerminationCommunicationDate EarliestHVTerminationLetterMailedDate,
						   LD.EarliestHVTerminationDeliveryDate EarliestHVTerminationLetterDeliveredDate, -- Modified by Shekhar on 7/18/2023. Copy paste bug (typo) in the previous program. Identified in TER audit

						   -- VRB related Info & Dates
						   VRB.EarliestVRBStatusID,VRB.EarliestVRBStatusDescription,VRB.EarliestVRBRemovalLookupID,VRB.EarliestVRBRemovallookupDescription,
						   VRB.EarliestVRBRequestedDate, VRB.EarliestVRBPlacedDate,VRB.EarliestVRBRemovedDate,
						   VRB.LatestVRBStatusID,VRB.LatestVRBStatusDescription,VRB.LatestVRBRemovalLookupID,VRB.LatestVRBRemovallookupDescription,
						   VRB.LatestVRBRequestedDate,VRB.LatestVRBPlacedDate,VRB.LatestVRBRemovedDate,
						   --HVS.LatestVRBPlacedDate LatestVRBDate,
                           --HVS.EarliestVRBPlacedDate EarliestVRBDate,
						   LD.LatestVRBCommunicationDate LatestVRBLetterMailedDate,
						   LD.LatestVRBDeliveryDate LatestVRBLetterDeliveredDate,
                           LD.EarliestVRBCommunicationDate EarliestVRBLetterMailedDate,
						   LD.EarliestVRBDeliveryDate EarliestVRBLetterDeliveredDate,

						   -- Ban related Dates
						   VB.VBRemovedDate, 
						   VB.RemovalReasonID, 
						   VB.RemovalReasonCode, 
						   VB.VBAppliedDate,
						    -- HVS.LatestVehicleBanPlacedDate LatestVehicleBanDate,
                           -- HVS.EarliestVehicleBanPlacedDate EarliestVehicleBanDate,
						   LD.LatestVehicleBanCommunicationDate LatestVehicleBanLetterMailedDate,
						   LD.LatestVehicleBanDeliveryDate  LatestVehicleBanLetterDeliveredDate,  
                           LD.EarliestVehicleBanCommunicationDate EarliestVehicleBanLetterMailedDate,
						   LD.EarliestVehicleBanDeliveryDate  EarliestVehicleBanLetterDeliveredDate,   
						   
						   A.Scheduledhearingdate,
						   A.EarliestCitationDate,
						   A.LatestCitationDate,
                           
                           A.HVTollsDue,
                           A.HVFeesDue,
						   A.HVCurrentDue,
						   A.MBSCurrentDue,					   
						   
						   ISNULL(CAST(SYSDATETIME() AS datetime2(3)), '1900-01-01') AS EDW_UpdateDate
						    --need to add
							   --NULL HVAddressStatus,  
							   --NULL FailuretoPayCitationIssued

					FROM CTE_Main A
					left JOIN CTE_LetterDates LD ON A.HVID=LD.HVID
					--LEFT JOIN CTE_StatustrackerDates HVS ON A.HVID=HVS.HVID
					LEFT JOIN CTE_BanDates VB ON A.HVID=VB.HVID
					LEFT JOIN CTE_VRBDates VRB ON A.HVID=VRB.HVID

		
		OPTION (LABEL='dbo.Dim_HabitualViolator_NEW Load');;
		
		SET  @Log_Message = 'Loaded dbo.Dim_HabitualViolator_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_HabitualViolator_01 ON dbo.Dim_HabitualViolator_NEW (CustomerID);
		CREATE STATISTICS STATS_dbo_Dim_HabitualViolator_02 ON dbo.Dim_HabitualViolator_NEW (VehicleID);
		CREATE STATISTICS STATS_dbo_Dim_HabitualViolator_03 ON dbo.Dim_HabitualViolator_NEW (HVCurrentStatus);
		CREATE STATISTICS STATS_dbo_Dim_HabitualViolator_04 ON dbo.Dim_HabitualViolator_NEW (LicensePlateState);
		CREATE STATISTICS STATS_dbo_Dim_HabitualViolator_05 ON dbo.Dim_HabitualViolator_NEW (HVDeterminationDate);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_HabitualViolator_NEW', 'dbo.Dim_HabitualViolator'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Dim_HabitualViolator' TableName, * FROM dbo.Dim_HabitualViolator ORDER BY 2 DESC
	
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
EXEC dbo.Dim_HabitualViolator_Load

EXEC Utility.FromLog 'dbo.Dim_HabitualViolator', 1
SELECT TOP 100 'dbo.Dim_HabitualViolator' Table_Name, * FROM dbo.Dim_HabitualViolator ORDER BY 2

Old Code 


		--CTE_StatustrackerDates AS 
		--(
		--		SELECT HVID,
		--			   MAX(S.LatestVRBPlaced) LatestVRBPlacedDate,
		--			   MAX(EarliestVRBPlaced) EarliestVRBPlacedDate,
		--			   MAX(LatestVehicleBanPlaced) LatestVehicleBanPlacedDate,
		--			   MAX(EarliestVehicleBanPlaced) EarliestVehicleBanPlacedDate
		--		FROM (
		--					SELECT HVS.HVID,
		--						   HVS.SubStatus,
		--						   CASE 
		--					         WHEN HVS.SubStatus = 'VRBPlaced' THEN
		--						                                        Max(HVS.StatusStartDate)
		--						   END LatestVRBPlaced,
		--						   CASE 
		--					         WHEN HVS.SubStatus = 'VRBPlaced' THEN
		--						                                        MIN(HVS.StatusStartDate)
		--						   END EarliestVRBPlaced,		
								   
		--						   CASE  WHEN HVS.SubStatus = 'VehicleBanPlaced' THEN
		--						                                        Max(HVS.StatusStartDate)
		--						   END AS LatestVehicleBanPlaced,
		--					       CASE WHEN HVS.SubStatus = 'VehicleBanPlaced' THEN
		--						                                        MIN(HVS.StatusStartDate)
		--					       END AS EarliestVehicleBanPlaced

		--					FROM LND_TBOS.TER.Habitualviolatorstatustracker HVS	WHERE HVS.HVID=342741 --862444
		--					GROUP BY HVS.HVID,
  --                                   HVS.SubStatus
		--					--OC.CustomerID = 799264020--799264020 
		--				) S	GROUP BY S.HVID		
		--),
*/


