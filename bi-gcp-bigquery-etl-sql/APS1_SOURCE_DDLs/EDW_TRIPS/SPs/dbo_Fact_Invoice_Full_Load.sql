CREATE PROC [dbo].[Fact_Invoice_Full_Load] AS
/*
##################################################################################################################################
Proc Description: 
----------------------------------------------------------------------------------------------------------------------------------
Load [dbo].[Fact_Invoice_Full_Load] table. 
EXEC [dbo].[Fact_Invoice_Full_Load]
==================================================================================================================================
Change Log:
----------------------------------------------------------------------------------------------------------------------------------
CHG0037838	Bhanu/Gouthami		2020-11-04	New!
CHG0037897  Gouthami			2021-01-13  Added left join to the MBS tables in CTE_INV_DATE for the missing 
											Citations.
CHG0038039	Gouthami			2021-01-27	Added Delete Flag
CHG0038304	Gouthami			2021-02-24	CTE_INV_DATE - Added the case statement for LND_UpdateType in group
											by as it is causing duplicates
CHG0039382	Gouthami			2021-08-11  Added the filter as it is causing duplicate invoices starting with 
											00 and 'DCBInvoiceGeneration' which should not be part of the invoice
											header table.
CHG0040131	Gouthami			2021-12-15	a. Changed the logic for Invoice Status as Source data is nor correct.
											b. Added news columns - FeesAdjusted,TollsAdjusted. 
											c. Modified the logic for Tolls Paid as the payments are showing correct.
											d. Created logic to find out the Dismissed Vtolls.
CHG0040437 	Gouthami			2021-02-16	Added ISNULL for SNFees and FNFees in the EDW_InvoiceStatusID logic. 
											This will fix -1 status ID.			

CHG0042443  Gouthami			2023-02-09	1.Divided this Stored Procedure in to 3 loads.
												1) Ref.RiteMigratedInvoice_Full_Load (Used to bring all the migrated data)
												2) Stage.MigratedNonTerminalInvoice_Full_Load (To bring all the migrated 
																		             non terminal invoices from REF table)
												3) Stage.NonMigratedInvoice_Full_Load ( to bring all the Non migrated invoices)
										    2. This load is the Union of all above tables.
											3. Below changes are done in this stored procedure for Item 90
											a. Added below metrics 
												1. EA  (Expected Amount)
												2. AA  (Adjusted Amount)= TA+FA+SA
												3. AET (Adjusted Expected Tolls) = ET-TA (ExpectedTolls-TollsAdjusted)
												4. AEF (Adjusted Expected FnFees) = EF - FA (ExpectedFnFees-FnFeesAdjusted)
												5. AES (Adjusted Expected SnFees) = ES - SA (ExpectedSnFees-SNfeesAdjusted)
												6. AEA (Adjusted Expected Amount) = EA-AA
												4. PA  (PaidAmount) = TP+FP+SP
												5. OA  (Outstanding Amount) = AEA- PA
											b. Modified Invoice Status logic 
											c. VTOLLS - Changed the logic for Dismissed Vtolled to avoid partial Vtolls 
														and added a different logic to bring rite data for VTOLLS.
											d. Unassigned - Added a logic to identify Unassigned Invoices. This should 
															give only those invoices where all the transactions are 
															Unassigned  and avoid partial Unassigned ones.Partial Unassigned
															will either go in to Parital Paid/Open based on the payments.
											e. Toll Adjustments - Modified Toll Adjustments in order to bring all the 
																	adjustments for Unassigned transactions as well.
																	Added Union all with two queries because there were few 
																	adjustments missing as TRIPS is assigning some of the 
																	adjustments to InvoiceID=0.
																	And also, added one more to bring the adjustments from RITE
																	tables only for migrated data
											f. Tolls Paid - Modified Tolls Paid logic in order to bring all the payments for 
															Unassigned transactions as well.Added Union all with two queries 
															because there were few payments missing as TRIPS is assigning some
															of the adjustments to InvoiceID=0.
											g. Changed the column from citationID/LinkID to ABS(CitationID)/ABS(LinkID) to bring 
												all the Unassigned Txns/ Invoices as well
											h. VTOLL logic - This created based on Pat's requirements. 
															 ExpectedAmount - This is calculated based on the toll amount and the 
																			  type of Vtoll. If an invoice is VTolled at PBMTAmount
																			  then the EA is PBMTAmount, if it is VTOLLED at AVI 
																			  rate then EA is AVI.
															 AdjustmentAmount - If an invoice is VTolled at PBMTAmount then there 
																				is no adjustment. If it is VTolled at AVI rate then 
																				the Adjustment is the delta beetween Tolls and 
																				PBMTAmount.
															 PaidAmount -	This is direct column from the Tollplus.TP_CustomerTrips
																			table.
															 OA - This is direct column from the Tollplus.TP_CustomerTrips table.
											I. InvoiceStatus
												1. Open					-- Paidamount=0 and AEA>0
												2. Partial Paid			-- AEA>0 and PA>0 and OA>0
												3. Paid					-- PA=AEA and OA=0
												4. Closed/Dimissed		-- AEA=AA and PA=0 (AA>AEA)
												5. Dismissed Vtolls		-- when invnum is in stage.dismissedvtolls table
												6. Dismissed Unassigned	-- when invnum is in stage.UnassignedInvoices table
												7. Unknown			-- If an invoice is not satisfying any of the above statuses then 
																		consider those as Unknown
											J. Stage.InvoicedViolatedTripPayment - Added this logic from bubble to bring the First and 
																					last paid dates

==================================================================================================================================================
Example:
--------------------------------------------------------------------------------------------------------------------------------------------------
EXEC Utility.FromLog 'dbo.Fact_Invoice_Full_Load', 1
SELECT TOP 100 'dbo.Fact_Invoice' Table_Name, * FROM dbo.Fact_Invoice ORDER BY 2
##################################################################################################################################################
*/



BEGIN
BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_Invoice_Full_Load', @Log_Start_Date DATETIME2(3) = SYSDATETIME();
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0; -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL;

		--=================================================================================================================
		-- Load dbo.Fact_Invoice_New -- This table is being loaded by 3 tables -- Ref.RiteMigratedInvoice
																			   -- Stage.MigratedNonTerminalInvoice 
																			   -- Stage.NonMigratedInvoice 
		--=================================================================================================================

		 IF OBJECT_ID('dbo.Fact_Invoice_New') IS NOT NULL DROP TABLE dbo.Fact_Invoice_New
		 CREATE TABLE dbo.Fact_Invoice_New WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(InvoiceNumber)) 
		 AS

		 SELECT 
				I.InvoiceNumber,
                FirstInvoiceID,
                CurrentInvoiceID,
                ISNULL(CustomerID,-1) CustomerID,
				NULL TestCaseFailedFlag,
                MigratedFlag,
                CASE WHEN edw_InvoiceStatusID=99999 THEN  1 ELSE -1 END AS VTollFlag,
                -1 UnassignedFlag,
                AgeStageID,
                CollectionStatusID,
                CurrMbsID,
                ISNULL(VehicleID,-1) VehicleID,
				CASE WHEN InvoiceStatus='DismissedUnassigned' AND EDW_InvoiceStatusID IS NULL THEN 99998 ELSE EDW_InvoiceStatusID END EDW_InvoiceStatusID,
                CAST(ZipCashDate AS DATE) ZipCashDate,
                CAST(FirstNoticeDate AS DATE) FirstNoticeDate,
                CAST(SecondNoticeDate AS DATE) SecondNoticeDate,
                CAST(ThirdNoticeDate AS DATE) ThirdNoticeDate,
                CAST(LegalActionPendingDate AS DATE) LegalActionPendingDate,
                CAST(CitationDate AS DATE) CitationDate,
                CAST(DueDate AS DATE) DueDate,
                CAST(CurrMbsGeneratedDate AS DATE) CurrMbsGeneratedDate,
				CAST(I.FirstpaymentDate AS DATE) FirstpaymentDate,
				CAST(I.LastPaymentDate AS DATE) LastPaymentDate,				
				NULL FirstFeePaymentDate,
				NULL LastFeePaymentDate,
                TxnCnt,
				CAST(InvoiceAmount AS DECIMAL(19,2)) AS InvoiceAmount,
                CAST(PBMTollAmount AS DECIMAL(19,2)) AS PBMTollAmount,
                CAST(AVITollAmount AS DECIMAL(19,2)) AS AVITollAmount,
                CAST(PremiumAmount AS DECIMAL(19,2)) AS PremiumAmount,
				CAST(Tolls AS DECIMAL(19,2)) AS Tolls,
                CAST(FNFees AS DECIMAL(19,2)) AS FNFees,
                CAST(SNFees AS DECIMAL(19,2)) AS SNFees,
                CAST(ExpectedAmount AS DECIMAL(19,2)) AS ExpectedAmount,
                CAST(TollsAdjusted AS DECIMAL(19,2)) AS TollsAdjusted,
                CAST(FNFeesAdjusted AS DECIMAL(19,2)) AS FNFeesAdjusted,
                CAST(SNFeesAdjusted AS DECIMAL(19,2)) AS SNFeesAdjusted,
                CAST(AdjustedAmount AS DECIMAL(19,2)) AS AdjustedAmount,
                CAST(AdjustedExpectedTolls AS DECIMAL(19,2)) AS AdjustedExpectedTolls,
                CAST(AdjustedExpectedFNFees AS DECIMAL(19,2)) AS AdjustedExpectedFNFees,
                CAST(AdjustedExpectedSNFees AS DECIMAL(19,2)) AS AdjustedExpectedSNFees,
                CAST(AdjustedExpectedAmount AS DECIMAL(19,2)) AS AdjustedExpectedAmount,
                CAST(TollsPaid AS DECIMAL(19,2)) AS TollsPaid,
                CAST(FNFeesPaid AS DECIMAL(19,2)) AS FNFeesPaid,
                CAST(SNFeesPaid AS DECIMAL(19,2)) AS SNFeesPaid,
                CAST(PaidAmount AS DECIMAL(19,2)) AS PaidAmount,
                CAST(TollOutStandingAmount AS DECIMAL(19,2)) AS TollOutStandingAmount,
                CAST(FNFeesOutStandingAmount AS DECIMAL(19,2)) AS FNFeesOutStandingAmount,
                CAST(SNFeesOutStandingAmount AS DECIMAL(19,2)) AS SNFeesOutStandingAmount,
                CAST(OutstandingAmount AS DECIMAL(19,2)) AS OutstandingAmount,
               ISNULL(CAST(SYSDATETIME() AS DATETIME2(3)), '1900-01-01') AS EDW_Update_Date		 
		  FROM Ref.RiteMigratedInvoice I
		  WHERE CASE WHEN InvoiceStatus='DismissedUnassigned' AND EDW_InvoiceStatusID IS NULL THEN 99998 ELSE EDW_InvoiceStatusID END<>4370 --77,858,847
          AND I.ZipCashDate>='2019-01-01'
		 

		 UNION 

		 SELECT MI.InvoiceNumber,
                FirstInvoiceID,
                CurrentInvoiceID,
                ISNULL(CustomerID,-1) CustomerID,
				NULL TestCaseFailedFlag,
                MigratedFlag,
                VTollFlag,
                UnassignedFlag,
                AgeStageID,
                CollectionStatusID,
                CurrMbsID,
                ISNULL(VehicleID,-1) VehicleID,
                CASE		-- Dismissed Vtolled 
					WHEN vtollFlag=1 THEN 99999  

					-- Paid -- AEA=PA and AEA>0
					WHEN 
						AdjustedExpectedAmount=PaidAmount
						AND
                        AdjustedExpectedAmount>0
						AND 
						OutstandingAmount=0
					THEN 516

					-- PartialPaid		 --PA>0 and EA-AA>PA				
					WHEN  
						  PaidAmount > 0 AND 
						  (ExpectedAmount-AdjustedAmount)> PaidAmount
					THEN 515  
					
					
					-- Dismissed Unassigned	
					WHEN 
							UnassignedFlag=1 
							AND 
							(ExpectedAmount-AdjustedAmount)=0							
					THEN 99998  					
					
					-- Open -- PA=0 and EA-AA>0 and EA>AA
					WHEN  
						  PaidAmount = 0 		
						  AND 
						  (ExpectedAmount-AdjustedAmount)>0
						  AND 
						   ExpectedAmount>AdjustedAmount
						  THEN 4370		
						  
					-- Closed
					WHEN  InvoiceStatusID=4434  THEN	4434
					WHEN ExpectedAmount=AdjustedAmount
						 AND PaidAmount=0 THEN 4434
			   ELSE   -1 
			   END   AS  EDW_InvoiceStatusID,
                CAST(ZipCashDate AS DATE) ZipCashDate,
                CAST(FirstNoticeDate AS DATE) FirstNoticeDate,
                CAST(SecondNoticeDate AS DATE) SecondNoticeDate,
                CAST(ThirdNoticeDate AS DATE) ThirdNoticeDate,
                CAST(LegalActionPendingDate AS DATE) LegalActionPendingDate,
                CAST(CitationDate AS DATE) CitationDate,
                CAST(DueDate AS DATE) DueDate,
                CAST(CurrMbsGeneratedDate AS DATE) CurrMbsGeneratedDate,
				CASE WHEN --516
						AdjustedExpectedAmount=PaidAmount
						AND
                        AdjustedExpectedAmount>0
						AND 
						OutstandingAmount=0
					 AND (FirstPaymentDate='1900-01-01' OR FirstPaymentDate IS NULL) THEN CAST(FirstFeePaymentDate AS DATE)
					WHEN  --515
						  PaidAmount > 0 AND 
						  (ExpectedAmount-AdjustedAmount)> PaidAmount
					  AND FirstPaymentDate='1900-01-01' THEN CAST(FirstFeePaymentDate AS DATE)
					WHEN EDW_InvoiceStatusID=4434 AND TollsPaid<=0 THEN '1900-01-01' --1236078604
					WHEN MI.EDW_InvoiceStatusID=516 AND MI.TollsPaid=0 AND (MI.FNFeespaid <> 0 OR MI.SNFeesPaid<>0)
						 THEN CAST(MI.FirstFeePaymentDate AS DATE)
				ELSE FirstPaymentDate END 
				AS FirstPaymentDate,
				CASE WHEN 
						AdjustedExpectedAmount=PaidAmount
						AND
                        AdjustedExpectedAmount>0
						AND 
						OutstandingAmount=0
						AND (LastPaymentDate='1900-01-01' OR LastPaymentDate IS NULL) THEN CAST(LastFeePaymentDate AS DATE)					 
					WHEN  --515
						  PaidAmount > 0 AND 
						  (ExpectedAmount-AdjustedAmount)> PaidAmount
						   AND LastPaymentDate='1900-01-01' THEN CAST(LastFeePaymentDate AS DATE)
					WHEN EDW_InvoiceStatusID=4434 AND TollsPaid<=0 THEN '1900-01-01' --1236078604
					WHEN MI.EDW_InvoiceStatusID=516 AND MI.TollsPaid=0 AND (MI.FNFeespaid <> 0 OR MI.SNFeesPaid<>0)
						 THEN CAST(MI.LastFeePaymentDate AS DATE)
					ELSE LastPaymentDate END 
				AS LastPaymentDate,
				CAST(FirstFeePaymentDate AS DATE) FirstFeePaymentDate,
				CAST(LastFeePaymentDate AS DATE) LastFeePaymentDate,
                TxnCnt,
				CAST(InvoiceAmount AS DECIMAL(19,2)) AS InvoiceAmount,
                CAST(PBMTollAmount AS DECIMAL(19,2)) AS PBMTollAmount,
                CAST(AVITollAmount AS DECIMAL(19,2)) AS AVITollAmount,
                CAST(PremiumAmount AS DECIMAL(19,2)) AS PremiumAmount,
				CAST(Tolls AS DECIMAL(19,2)) AS Tolls,
                CAST(FNFees AS DECIMAL(19,2)) AS FNFees,
                CAST(SNFees AS DECIMAL(19,2)) AS SNFees,
                CAST(ExpectedAmount AS DECIMAL(19,2)) AS ExpectedAmount,
                CAST(TollsAdjusted AS DECIMAL(19,2)) AS TollsAdjusted,
                CAST(FNFeesAdjusted AS DECIMAL(19,2)) AS FNFeesAdjusted,
                CAST(SNFeesAdjusted AS DECIMAL(19,2)) AS SNFeesAdjusted,
                CAST(AdjustedAmount AS DECIMAL(19,2)) AS AdjustedAmount,
                CAST(AdjustedExpectedTolls AS DECIMAL(19,2)) AS AdjustedExpectedTolls,
                CAST(AdjustedExpectedFNFees AS DECIMAL(19,2)) AS AdjustedExpectedFNFees,
                CAST(AdjustedExpectedSNFees AS DECIMAL(19,2)) AS AdjustedExpectedSNFees,
                CAST(AdjustedExpectedAmount AS DECIMAL(19,2)) AS AdjustedExpectedAmount,
                CAST(TollsPaid AS DECIMAL(19,2)) AS TollsPaid,
                CAST(FNFeesPaid AS DECIMAL(19,2)) AS FNFeesPaid,
                CAST(SNFeesPaid AS DECIMAL(19,2)) AS SNFeesPaid,
                CAST(PaidAmount AS DECIMAL(19,2)) AS PaidAmount,
                CAST(TollOutStandingAmount AS DECIMAL(19,2)) AS TollOutStandingAmount,
                CAST(FNFeesOutStandingAmount AS DECIMAL(19,2)) AS FNFeesOutStandingAmount,
                CAST(SNFeesOutStandingAmount AS DECIMAL(19,2)) AS SNFeesOutStandingAmount,
                CAST(OutstandingAmount AS DECIMAL(19,2)) AS OutstandingAmount,
                EDW_Update_Date--55
		 FROM Stage.MigratedNonTerminalInvoice MI


		 UNION 


		 SELECT NMI.InvoiceNumber,
                FirstInvoiceID,
                CurrentInvoiceID,
                CustomerID,
				NULL TestCaseFailedFlag,
                MigratedFlag,
                VTollFlag,
                UnassignedFlag,
                AgeStageID,
                CollectionStatusID,
                CurrMbsID,
                VehicleID,
				CASE		-- Dismissed Vtolled 
					WHEN vtollFlag=1 THEN 99999    	
										
					-- Paid -- AEA=PA and AEA>0
					WHEN 
						AdjustedExpectedAmount=PaidAmount
						AND
                        AdjustedExpectedAmount>0
						AND 
						OutstandingAmount=0
					THEN 516

					-- PartialPaid		 --PA>0 and EA-AA>PA				
					WHEN  
						  PaidAmount > 0 AND 
						  (ExpectedAmount-AdjustedAmount)> PaidAmount
					THEN 515  
					
					
					-- Dismissed Unassigned	
					WHEN 
							UnassignedFlag=1 
							AND 
							(ExpectedAmount-AdjustedAmount)=0							
					THEN 99998  					
					
					-- Open -- PA=0 and EA-AA>0 and EA>AA
					WHEN  
						  PaidAmount = 0 		
						  AND 
						  (ExpectedAmount-AdjustedAmount)>0
						  AND 
						   ExpectedAmount>AdjustedAmount
						  THEN 4370		
						  
					-- Closed
					WHEN  InvoiceStatusID=4434  THEN	4434
					WHEN ExpectedAmount=AdjustedAmount
						 AND PaidAmount=0 THEN 4434
			   ELSE   -1 
			   END   AS  EDW_InvoiceStatusID,
                ZipCashDate,
                FirstNoticeDate,
                SecondNoticeDate,
                ThirdNoticeDate,
                LegalActionPendingDate,
                CitationDate,
                DueDate,
                CurrMbsGeneratedDate,
				CASE WHEN --516
						AdjustedExpectedAmount=PaidAmount
						AND
                        AdjustedExpectedAmount>0
						AND 
						OutstandingAmount=0
					 AND (FirstPaymentDate='1900-01-01' OR FirstPaymentDate IS NULL) THEN CAST(FirstFeePaymentDate AS DATE)
					WHEN  --515
						  PaidAmount > 0 AND 
						  (ExpectedAmount-AdjustedAmount)> PaidAmount
						 AND FirstPaymentDate='1900-01-01' THEN CAST(FirstFeePaymentDate AS DATE)
					WHEN EDW_InvoiceStatusID=4434 AND TollsPaid<=0 THEN '1900-01-01' --1236078604
					WHEN NMI.EDW_InvoiceStatusID=516 AND NMI.TollsPaid=0 AND (NMI.FNFeespaid<> 0 OR NMI.SNFeesPaid<>0)
						 THEN CAST(NMI.FirstFeePaymentDate AS DATE)
					ELSE FirstPaymentDate END FirstPaymentDate,
				CASE WHEN --516
						AdjustedExpectedAmount=PaidAmount
						AND
                        AdjustedExpectedAmount>0
						AND 
						OutstandingAmount=0
					 AND (LastPaymentDate='1900-01-01' OR LastPaymentDate IS NULL)  THEN CAST(LastFeePaymentDate  AS DATE)
					 
					WHEN  --515
						  PaidAmount > 0 AND 
						  (ExpectedAmount-AdjustedAmount)> PaidAmount
						 AND LastPaymentDate='1900-01-01' THEN CAST(LastFeePaymentDate AS DATE)
					WHEN EDW_InvoiceStatusID=4434  AND TollsPaid<=0 THEN '1900-01-01' --1236078604
					WHEN NMI.EDW_InvoiceStatusID=516 AND NMI.TollsPaid=0 AND (NMI.FNFeespaid <> 0 OR NMI.SNFeesPaid<>0)
						 THEN CAST(NMI.LastFeePaymentDate AS DATE)
				ELSE LastPaymentDate END LastPaymentDate,
				CAST(FirstFeePaymentDate AS DATE) FirstFeePaymentDate,
				CAST(LastFeePaymentDate AS DATE) LastFeePaymentDate,
                TxnCnt,           
				
				CAST(InvoiceAmount AS DECIMAL(19,2)) AS InvoiceAmount,
                CAST(PBMTollAmount AS DECIMAL(19,2)) AS PBMTollAmount,
                CAST(AVITollAmount AS DECIMAL(19,2)) AS AVITollAmount,
                CAST(PremiumAmount AS DECIMAL(19,2)) AS PremiumAmount,
				CAST(Tolls AS DECIMAL(19,2)) AS Tolls,
                CAST(FNFees AS DECIMAL(19,2)) AS FNFees,
                CAST(SNFees AS DECIMAL(19,2)) AS SNFees,
                CAST(ExpectedAmount AS DECIMAL(19,2)) AS ExpectedAmount,
                CAST(TollsAdjusted AS DECIMAL(19,2)) AS TollsAdjusted,
                CAST(FNFeesAdjusted AS DECIMAL(19,2)) AS FNFeesAdjusted,
                CAST(SNFeesAdjusted AS DECIMAL(19,2)) AS SNFeesAdjusted,
                CAST(AdjustedAmount AS DECIMAL(19,2)) AS AdjustedAmount,
                CAST(AdjustedExpectedTolls AS DECIMAL(19,2)) AS AdjustedExpectedTolls,
                CAST(AdjustedExpectedFNFees AS DECIMAL(19,2)) AS AdjustedExpectedFNFees,
                CAST(AdjustedExpectedSNFees AS DECIMAL(19,2)) AS AdjustedExpectedSNFees,
                CAST(AdjustedExpectedAmount AS DECIMAL(19,2)) AS AdjustedExpectedAmount,
                CAST(TollsPaid AS DECIMAL(19,2)) AS TollsPaid,
                CAST(FNFeesPaid AS DECIMAL(19,2)) AS FNFeesPaid,
                CAST(SNFeesPaid AS DECIMAL(19,2)) AS SNFeesPaid,
                CAST(PaidAmount AS DECIMAL(19,2)) AS PaidAmount,
                CAST(TollOutStandingAmount AS DECIMAL(19,2)) AS TollOutStandingAmount,
                CAST(FNFeesOutStandingAmount AS DECIMAL(19,2)) AS FNFeesOutStandingAmount,
                CAST(SNFeesOutStandingAmount AS DECIMAL(19,2)) AS SNFeesOutStandingAmount,
                CAST(OutstandingAmount AS DECIMAL(19,2)) AS OutstandingAmount,
                EDW_Update_Date
		FROM stage.NonMigratedInvoice NMI
		--WHERE InvoiceNumber=1223926733
		


		OPTION (LABEL = 'dbo.Fact_Invoice_New Load');

		SET @Log_Message = 'Loaded dbo.Fact_Invoice_New';
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message,'I',-1,NULL;

        -- PAID

		--- Closed invoices which has paidamount>0
		--- Updating all the invoices to Paid which are in Closed,Unknown and Unassigned statuses.
		--- Updating Unknowns to Paid - According to Pat, Marking all the Unknowns to paid which has payments and more adjustments.
		--- Updating Closed Invoices to Paid - Closed invoices are supposed to dismissed/completely closed with no payments. We see few closed invoices with payments and over adjustments. According to Pat, these invoices needs to be in Paid bucket
		--- Updating Unassigned to Paid - Eventhough these invoices are Unassigned, if there any payments to those invoices , we need to mark those as Paid
		
		UPDATE [dbo].[Fact_Invoice_New] 
		SET EDW_InvoiceStatusID=516
			,FirstPaymentDate=CASE WHEN FirstpaymentDate='1900-01-01' THEN firstfeepaymentdate ELSE FirstpaymentDate END 
			,LastPaymentDate= CASE WHEN LastPaymentDate='1900-01-01' THEN LastFeePaymentDate ELSE LastPaymentDate END 
		WHERE  EDW_InvoiceStatusID IN (4434,-1) AND --99998 add unassigned for migrated ones after talking to pat
		(PaidAmount>0 OR tollspaid>0) AND OutstandingAmount<=0
		
				
		--- UNASSIGNED

		--- Migrated closed Invoices needs to be updated to their original adjustment amount as we are not bringing the correct adjustment amount for these couple of invoices from Rite tables.
		--- The reason we are doing this as we cannot change the rite query logic only for these few invoices. 
		
		--UPDATE [dbo].[Fact_Invoice_New] 
		--SET TollsAdjusted=Tolls
		--	,AdjustedAmount=(tolls+FNFeesAdjusted+SNFeesAdjusted)
		--	,AdjustedExpectedTolls=0
		--	,AdjustedExpectedAmount=0
		--	,TollOutStandingAmount=0
		--	,OutstandingAmount=0
		--WHERE  EDW_InvoiceStatusID=99998 AND 
		--AdjustedExpectedAmount<>0
		--AND ZipCashDate>='2019-01-01'
		
		-- OPEN	

		-- There are Unknown status invoices which have -ve payments and adjustments. In this case, we are seeing nothing is paid on the invoice and need to mark those as OPEN
			
		UPDATE [dbo].[Fact_Invoice_New] 
		SET EDW_InvoiceStatusID=4370
			,FirstPaymentDate='1900-01-01'
			,LastPaymentDate='1900-01-01'
			,FirstFeePaymentDate='1900-01-01'
			,LastFeePaymentDate='1900-01-01'
		WHERE  EDW_InvoiceStatusID IN (-1) AND 
		PaidAmount<=0 AND OutstandingAmount>0 
		
		
		-- PARTIAL PAID

		-- There are can be invoices which are partially paid in Closed and Unknown Statuses. In order to find those and update it to correct status, bring those invoices which has payments and outstanding amount. 		
		
		UPDATE [dbo].[Fact_Invoice_New] 
		SET EDW_InvoiceStatusID=515
			,FirstPaymentDate=CASE WHEN FirstpaymentDate='1900-01-01' THEN firstfeepaymentdate ELSE FirstpaymentDate END 
			,LastPaymentDate= CASE WHEN LastPaymentDate='1900-01-01' THEN LastFeePaymentDate ELSE LastPaymentDate END 
		WHERE  (TollsPaid>0 OR FNFeesPaid>0 OR SNFeesPaid>0)
		AND OutstandingAmount>0 
		AND EDW_InvoiceStatusID IN (-1,4434) AND ZipCashDate>='2019-01-01'

		
		-- CLOSED

		-- Finding out the closed invoices from Unknowns. According to Pat, If nothing is paid and over adjustments are happened then mark those to closed status.
		-- These are the invoices where Adjustments are more than the Expected amount.
		
		
		UPDATE [dbo].[Fact_Invoice_New] 
		SET EDW_InvoiceStatusID=4434
			,FirstPaymentDate='1900-01-01'
			,LastPaymentDate='1900-01-01'
		WHERE AdjustedAmount>ExpectedAmount AND PaidAmount<=0
		AND EDW_InvoiceStatusID IN (-1) AND ZipCashDate>='2019-01-01'
		
		---====== PaymentDates fix ============-----------------

		UPDATE [dbo].[Fact_Invoice_New] 
		SET 
			 FirstPaymentDate='1900-01-01'
			,LastPaymentDate='1900-01-01'
			,FirstFeePaymentDate='1900-01-01'
			,LastFeePaymentDate='1900-01-01'
		WHERE  EDW_InvoiceStatusID=4370

		UPDATE [dbo].[Fact_Invoice_New] 
		SET 		 
			 FirstPaymentDate=FirstFeepaymentDate
			,LastPaymentDate=LastFeePaymentDate
		WHERE  EDW_InvoiceStatusID=516 AND TollsPaid=0
				

		------==== Downgrading fix ==== -------
		---- Fix the FN,SN,TN and otherr dates for the invoices that are downgraded.
		-- Zipcash Invoices
		UPDATE [dbo].[Fact_Invoice_New] 
		SET FirstNoticeDate='1900-01-01',
			SecondNoticeDate='1900-01-01',
			ThirdNoticeDate='1900-01-01',
			LegalActionPendingDate='1900-01-01',
			CitationDate='1900-01-01' -- select * from dbo.fact_invoice_new
		WHERE AgeStageID=1 AND  ZipCashDate>='2019-01-01'
			 AND FirstNoticeDate<>'1900-01-01'

		-- FirstNotice Invoices
		UPDATE [dbo].[Fact_Invoice_New] 
		SET 
			SecondNoticeDate='1900-01-01',
			ThirdNoticeDate='1900-01-01',
			LegalActionPendingDate='1900-01-01',
			CitationDate='1900-01-01'		-- select * from dbo.fact_invoice_new
		WHERE AgeStageID=2 AND  ZipCashDate>='2019-01-01'
			  AND SecondNoticeDate<>'1900-01-01'

		-- SecondNotice Invoices
		UPDATE [dbo].[Fact_Invoice_New] 
		SET 
			ThirdNoticeDate='1900-01-01',
			LegalActionPendingDate='1900-01-01',
			CitationDate='1900-01-01' -- select * from dbo.fact_invoice_new
		WHERE AgeStageID=3 AND  ZipCashDate>='2019-01-01'
			  AND ThirdNoticeDate<>'1900-01-01'

		-- ThirdNotice Invoices
		UPDATE [dbo].[Fact_Invoice_New] 
		SET 
			LegalActionPendingDate='1900-01-01',
			CitationDate='1900-01-01' -- select * from dbo.fact_invoice_new
		WHERE AgeStageID=4 AND  ZipCashDate>='2019-01-01'
			  AND (LegalActionPendingDate<>'1900-01-01' OR CitationDate<>'1900-01-01')


		-- LegalActionPending Invoices
		UPDATE [dbo].[Fact_Invoice_New] 
		SET 
			
			CitationDate='1900-01-01'	-- select * from dbo.fact_invoice_new
		WHERE AgeStageID=5 AND  ZipCashDate>='2019-01-01'
			  AND CitationDate<>'1900-01-01'
			  
		--------- updating LAP dates for migrated ones using TER table.
		UPDATE dbo.Fact_Invoice_New 
		SET LegalActionPendingDate= (SELECT MAX(ThirdNNPDate) ThirdNNPDate FROM  LND_TBOS.TER.ViolatorCollectionsOutbound B WHERE  B.invoicenumber=invoicenumber)
		WHERE migratedflag=1 
		AND FirstNoticeDate>LegalActionPendingDate
		AND ZipCashDate>'1900-01-01'
		AND agestageID=5
			
		-- Statistics
		CREATE STATISTICS STATS_Fact_Invoice_000 ON dbo.Fact_Invoice_New (InvoiceNumber)
		CREATE STATISTICS STATS_Fact_Invoice_001 ON dbo.Fact_Invoice_New (FirstInvoiceID)
		CREATE STATISTICS STATS_Fact_Invoice_002 ON dbo.Fact_Invoice_New  (CurrentInvoiceID)
		CREATE STATISTICS STATS_Fact_Invoice_003 ON dbo.Fact_Invoice_New  (CustomerID)
		CREATE STATISTICS STATS_Fact_Invoice_004 ON dbo.Fact_Invoice_New  (AgeStageID)
		CREATE STATISTICS STATS_Fact_Invoice_006 ON dbo.Fact_Invoice_New  (EDW_InvoiceStatusID)

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Fact_Invoice_NEW', 'dbo.Fact_Invoice';

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date,'Completed full load', 'I',NULL,NULL;

		-- Show results
		IF @Trace_Flag = 1  EXEC Utility.FromLog @Log_Source, @Log_Start_Date;
		IF @Trace_Flag = 1  SELECT TOP 1000 'dbo.Fact_Invoice' TableName, * FROM dbo.Fact_Invoice  ORDER BY 2 DESC;
	
	END	TRY
	
	BEGIN CATCH
	
		DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error!
	
	END CATCH;

END
