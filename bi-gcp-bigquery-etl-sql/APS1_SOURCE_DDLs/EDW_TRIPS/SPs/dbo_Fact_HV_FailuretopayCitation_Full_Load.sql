CREATE PROC [dbo].[Fact_HV_FailuretopayCitation_Full_Load] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_HV_FailuretopayCitation table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0043993		Gouthami		2023-11-02	New!
											1. This proc loads the data for citations that's been given to the
											    Customers (HV).
											2. DPS officer can randomly give a citation to customer on one of their 
											   violated trip. They can cite another trip for the same customer only 
											   after 60 days.
											3. Don requested to add transaction details like Tolls & payments for that 
												trip and also Invoice related information for the same.
											
CHG0044527		Gouthami		 2024-02-08	 1. Pulled all the citations (49k) from RITE which are not migrated to TRIPS
											 2. Used Old query from Citation report (from Don) and created ref tables
												to use in this proc
===================================================================================================================
Example:
exec [dbo].[Fact_HV_FailuretopayCitation_Full_Load]
--EXEC Utility.FromLog 'dbo.Fact_HV_FailuretopayCitation', 1
SELECT TOP 100 'dbo.Fact_HV_FailuretopayCitation' Table_Name, * FROM dbo.Fact_HV_FailuretopayCitation ORDER BY 2
###################################################################################################################
*/


BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_HV_FailuretopayCitation_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load dbo.Fact_HV_FailuretopayCitation
		--=============================================================================================================
		IF OBJECT_ID('dbo.Fact_HV_FailuretopayCitation_NEW') IS NOT NULL DROP TABLE dbo.Fact_HV_FailuretopayCitation_NEW
		CREATE TABLE dbo.Fact_HV_FailuretopayCitation_NEW WITH (CLUSTERED INDEX (FailureCitationID), DISTRIBUTION = REPLICATE) AS		
		
		WITH CTE_Rite_Customers AS 
		(
				SELECT DISTINCT VIOLATOR_ID
				FROM Ref.Citation
				WHERE VIOLATOR_ID NOT IN
						(
						 SELECT ViolatorID FROM LND_TBOS.TER.FailureToPayCitations
						)
		)
		
		SELECT 
				 FailureCitationID
				,ISNULL(HV.HVID,-1) HVID
				,ISNULL(FTP.ViolatorID,-1)	CustomerID
				,ISNULL(ReferenceTripID,-1) CitationID
				,ISNULL(VT.TPTripID,-1) TPTripID
				,ISNULL(FTP.CitationInvoiceID,-1) CitationInvoiceID
				,ISNULL(FI.CurrMbsID,-1) MBSID			
				,ISNULL(UT.LaneID,-1) LaneID
				,ISNULL(FTP.CourtID,-1) CourtID
				,ISNULL(FTP.JudgeID,-1) JudgeID
				,ISNULL(FTP.DPSTrooperID,-1)	DPSTrooperID		
				,ISNULL(HVS.HVStatusLookupID,-1) CitationStatusID
				,ISNULL(FTP.AgeStageID,-1) InvoiceAgeStageID

				,ISNULL(FI.InvoiceNumber,-1) CitationInvoiceNumber
				,CitationNumber
				,DPSCitationNumber		
				
				,UT.TripDayID
				,CAST(LEFT(CONVERT(VARCHAR,MailDate,112),8) AS INT) MailDayID	
				,CAST(LEFT(CONVERT(VARCHAR,DPSCitationIssuedDate,112),8) AS INT)  DPSCitationIssuedDayID
				,CAST(LEFT(CONVERT(VARCHAR,FTP.CreatedDate,112),8) AS INT)  CitationPackageCreatedDayID

				,CourtAppearanceDate
				,PrintDate
				,UT.FirstPaidDate
				,UT.LastPaidDate

				,FTP.IsActive ActiveFlag
				, 0 MigratedFlag

				, UT.TollAmount TxnTollAmount
				, UT.ActualPaidAmount TxnTollsPaid
				, FI.Tolls TollsOnInvoice
				, FI.TollsPaid TollsPaidOnInvoice
				,(FI.FNFees+FI.SNFees) FeesDueOnInvoice
				,(FI.FNFeesPaid+FI.SNFeesPaid) FeesPaidOnInvoice
				, FI.TollsAdjusted TollsAdjustedOnInvoice
				,ISNULL(CAST(SYSDATETIME() AS datetime2(3)), '1900-01-01') AS EDW_UpdateDate
				--SELECT count(*)
		FROM LND_TBOS.TER.FailureToPayCitations FTP
		LEFT JOIN 
				(	SELECT HV.ViolatorID,HV.HVID,HV.HVDesignationDate,HV.HVTerminationDate
					FROM LND_TBOS.TER.HabitualViolators HV 
				) HV				
				ON HV.ViolatorID = FTP.ViolatorID 
				   AND FTP.MailDate BETWEEN HV.HVDesignationDate AND ISNULL(HV.HVTerminationDate,'2099-01-01 00:00:00.000')
		LEFT JOIN LND_TBOS.TER.HVStatusLookup HVS ON HVS.HVStatusLookupID = FTP.HVStatusLookupID
		LEFT JOIN LND_TBOS.TollPlus.TP_ViolatedTrips VT ON FTP.ReferenceTripID=VT.CitationID		
		LEFT JOIN LND_TBOS.TollPlus.Invoice_LineItems IL ON VT.CitationID=IL.LinkID AND IL.TxnType='VTOLL'
		LEFT JOIN EDW_TRIPS.dbo.Fact_Invoice FI ON FI.InvoiceNumber = IL.ReferenceInvoiceID
		LEFT JOIN EDW_TRIPS.Stage.UnifiedTransaction UT ON UT.TPTripID=VT.TpTripID
		WHERE CAST(FTP.CreatedDate AS DATE) >='2013-01-01'
		 
		UNION ALL 		

		SELECT 
				ROW_NUMBER() OVER(ORDER BY (HV.ViolatorID)) + 9999999 AS FailureCitationID,
				 ISNULL(HV.HVID,-1) HVID
				,ISNULL(FTP.Violator_ID,-1)	CustomerID
				, -1 CitationID
				, viol.TPTripID
				, -1 CitationInvoiceID
				, -1 MBSID	
				, L.LaneID LaneID
				, Crt.CourtID CourtID
				, J.JudgeID JudgeID
				,-1 DPSTrooperID		
				,-1 CitationStatusID
				,-1 InvoiceAgeStageID

				, ISNULL(C.VBI_INVOICE_ID,-1) CitationInvoiceNumber
				, C.CITATION_NBR_LIST CitationNumber
				, Viol.DPS_CITATION_NBR DPSCitationNumber	
				, NULL TripDayID
				
				,CAST(LEFT(CONVERT(VARCHAR,daydate,112),8) AS INT) MailDayID	
				,NULL  DPSCitationIssuedDayID
				,NULL  CitationPackageCreatedDayID

				,Viol.Appearance_Date CourtAppearanceDate
				,NULL PrintDate
				,NULL FirstPaidDate
				,NULL LastPaidDate

				,NULL ActiveFlag
				,1 MigratedFlag

				, C.TOLLSDUE TxnTollAmount
				, C.TOLLSONPAID TxnTollsPaid
				, C.TOLLSDUE TollsOnInvoice
				, C.TOLLSONPAID TollsPaidOnInvoice
				, C.FEESDUE FeesDueOnInvoice
				, C.FEESPAID FeesPaidOnInvoice
				, NULL TollsAdjusted
				,ISNULL(CAST(SYSDATETIME() AS DATETIME2(3)), '1900-01-01') AS EDW_UpdateDate
		FROM CTE_Rite_Customers FTP
		JOIN  REF.Citation C ON C.VIOLATOR_ID = FTP.VIOLATOR_ID
        LEFT JOIN  (SELECT DISTINCT Viol.VIOLATOR_ID,Viol.TpTripID,
						  Viol.InvoiceNumber,Viol.APPEARANCE_DATE,
						  Viol.DPS_CITATION_NBR,Viol.LANE_ABBREV,Viol.COURT_NAME
					FROM REF.CitationViol Viol ) Viol
			 ON C.VIOLATOR_ID=FTP.VIOLATOR_ID AND C.VBI_INVOICE_ID=Viol.InvoiceNumber
		LEFT JOIN dbo.Dim_Lane L ON Viol.LANE_ABBREV=L.LaneName
		LEFT JOIN dbo.Dim_Court Crt ON Crt.CourtName = Viol.COURT_NAME
		LEFT JOIN dbo.Dim_CourtJudge J ON J.CourtID = Crt.CourtID
		LEFT JOIN 
				(	SELECT HV.ViolatorID,HV.HVID,HV.HVDesignationDate,HV.HVTerminationDate
					FROM LND_TBOS.TER.HabitualViolators HV 
				) HV				
				ON HV.ViolatorID = FTP.VIOLATOR_ID 
				   AND C.DayDate BETWEEN HV.HVDesignationDate AND ISNULL(HV.HVTerminationDate,'2099-01-01 00:00:00.000')



		OPTION (LABEL='dbo.Fact_HV_FailuretopayCitation_NEW Load');;
		
		SET  @Log_Message = 'Loaded dbo.Fact_HV_FailuretopayCitation_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Fact_HV_FailuretopayCitation_01 ON dbo.Fact_HV_FailuretopayCitation_NEW (CustomerID);
		CREATE STATISTICS STATS_dbo_Fact_HV_FailuretopayCitation_02 ON dbo.Fact_HV_FailuretopayCitation_NEW (TpTripID);
		CREATE STATISTICS STATS_dbo_Fact_HV_FailuretopayCitation_03 ON dbo.Fact_HV_FailuretopayCitation_NEW (CitationID);
		CREATE STATISTICS STATS_dbo_Fact_HV_FailuretopayCitation_04 ON dbo.Fact_HV_FailuretopayCitation_NEW (CitationInvoiceNumber);
		CREATE STATISTICS STATS_dbo_Fact_HV_FailuretopayCitation_05 ON dbo.Fact_HV_FailuretopayCitation_NEW (HVID);
		CREATE STATISTICS STATS_dbo_Fact_HV_FailuretopayCitation_06 ON dbo.Fact_HV_FailuretopayCitation_NEW (DPSCitationIssuedDayID);
		CREATE STATISTICS STATS_dbo_Fact_HV_FailuretopayCitation_07 ON dbo.Fact_HV_FailuretopayCitation_NEW (MailDayID);
		CREATE STATISTICS STATS_dbo_Fact_HV_FailuretopayCitation_08 ON dbo.Fact_HV_FailuretopayCitation_NEW (CitationPackageCreatedDayID);
		CREATE STATISTICS STATS_dbo_Fact_HV_FailuretopayCitation_09 ON dbo.Fact_HV_FailuretopayCitation_NEW (CitationStatusID);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Fact_HV_FailuretopayCitation_NEW', 'dbo.Fact_HV_FailuretopayCitation'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Fact_HV_FailuretopayCitation' TableName, * FROM dbo.Fact_HV_FailuretopayCitation ORDER BY 2 DESC
	
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
EXEC dbo.Fact_HV_FailuretopayCitation_Full_Load

EXEC Utility.FromLog 'dbo.Fact_HV_FailuretopayCitation', 1
SELECT TOP 100 'dbo.Fact_HV_FailuretopayCitation' Table_Name, * FROM dbo.Fact_HV_FailuretopayCitation ORDER BY 2


Testing:
		--AND FTP.ReferenceTripID=1963099555
		--AND FTP.ViolatorID=2011319043 --(multiple Citations example)
		--FTP.ViolatorID=2011534070
		--WHERE FTP.FailureCitationID=72204
		--AND  FTP.ViolatorID=809137054

-- old code
--LEFT JOIN 
		--		( SELECT  A.InvoiceNumber
		--				  ,MAX(A.InvoiceID) InvoiceID 
		--				  ,MAX(MBSID) MBSID
		--		   FROM (
		--		   		  SELECT 
		--		   				InvoiceNumber,
		--		   				CASE WHEN AgeStageID=6 THEN MIN(InvoiceID) END AS InvoiceID,
		--		   				CASE WHEN AgeStageID=6 THEN MAX(MbsID) END AS MBSID -- select *
		--		   		   FROM LND_TBOS.TollPlus.MbsInvoices
		--		   		 -- WHERE InvoiceNumber=1223900310 
		--				  WHERE InvoiceID=89859664
		--		   		  GROUP BY InvoiceNumber,AgeStageID
		--		   	  ) A 
		--		   GROUP BY A.InvoiceNumber
		--		 ) MBS  ON MBS.InvoiceID=FTP.CitationInvoiceID


*/


