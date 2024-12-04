CREATE PROC [dbo].[Fact_PaymentPlan_Full_Load] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_PaymentPlan table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0043223    Gouthami	2023-05-08	Created
CHG0043356    Sagarika  2023-07-14  Data has Fixed to pull paymentplans created after 2021-01-01. 
CHGXXXXXX	  Shekhar	2023-07-26	Eliminated the join with Habitualviolator to pull Payment plans that does 
									have HVID present in the PaymentPlanViolator. This join is not needed
CHG0044321    Gouthami  2024-01-08  1. Changed this table from Dim to Fact
									2. Added Transaction and Invoice count for a paymentplan as per Randall's
									   request.
CHG0044527	  Gouthami	2024-02-08	1. Removed the filter to bring payment plans only after 2021
									2. We need paymentplans prior to 2021 which are Active/Defaulted/PaidInFull for
										Collections.
									2. Did not pull the data (NoOfInvoices, NoOfTransactions) for those paymentplans 
										which have some migration issues.
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_PaymentPlan_Full_Load

EXEC Utility.FromLog 'dbo.Fact_PaymentPlan', 1
SELECT TOP 100 'dbo.Fact_PaymentPlan' Table_Name, * FROM dbo.Fact_PaymentPlan ORDER BY 2
###################################################################################################################
*/


BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_PaymentPlan_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load dbo.Fact_PaymentPlan
		--=============================================================================================================
		IF OBJECT_ID('dbo.Fact_PaymentPlan_NEW') IS NOT NULL DROP TABLE dbo.Fact_PaymentPlan_NEW
		CREATE TABLE dbo.Fact_PaymentPlan_New WITH (CLUSTERED INDEX (HVID), DISTRIBUTION = REPLICATE) AS		 
		
		WITH CTE_Inv AS 
		(
			
			   SELECT PPV.ViolatorID CustomerID
					, PP.PaymentplanID
					, PPV.MbsID
					, FI.VehicleID	
					, SUM (CASE WHEN (FI.FirstpaymentDate>= CAST(PP.StartDate AS DATE) ) -- Consider invoices having first payment date on/after paymentplan start date
									 OR (FI.FirstpaymentDate>= CAST(PP.DownPaymentDate AS DATE) )  -- Consider invoices having first payment date on/after paymentplan downpayment date
									 --- There could be payments only on fees after the paymentplan is taken. Considering payments that are applied to fees after paymentplan start date
									 OR (ISNULL(FI.FirstFeepaymentDate,'1900-01-01')>= CAST(PP.StartDate AS DATE)/*MBSID 1201119196*/ OR ISNULL(FI.LastFeepaymentDate,'1900-01-01')>= CAST(PP.StartDate AS DATE)/*MBSID 1265381393*/ ) -- MBSID 1256540746
									 AND (FI.FirstpaymentDate<>'1900-01-01' OR FI.FirstpaymentDate IS NOT NULL) 
								THEN 1
								 -- Consider invoices having Last payment date on/after paymentplan start date. First payment date could be prior to paymentplan start date
								WHEN (FI.LastPaymentDate>= CAST(PP.StartDate AS DATE ) OR  (FI.LastPaymentDate>= CAST(PP.DownPaymentDate AS DATE) )) AND (FI.LastPaymentDate<>'1900-01-01' OR FI.LastPaymentDate IS NOT NULL)  THEN 1
								 -- Do not consider invoices having first/Last payment dates prior to paymentplan start date for Vtoll invoices
								WHEN (FI.FirstpaymentDate< CAST(PP.StartDate AS DATE ) OR FI.LastPaymentDate< CAST(PP.StartDate AS DATE )) 
									  AND  FI.EDW_InvoiceStatusID=99999  -- Vtoll
								THEN NULL
								-- Consider invoices that are partial paid prior to paymentplan start date. There are can be payments after the payment plan is taken for partial invoices.
								WHEN (FI.FirstpaymentDate< CAST(PP.StartDate AS DATE ) OR FI.LastPaymentDate< CAST(PP.StartDate AS DATE )) AND FI.EDW_InvoiceStatusID=515 THEN 1
								-- Consider paid invoices after payment plan start date
								WHEN FI.LastPaymentDate>= CAST(PP.StartDate AS DATE ) AND FI.EDW_InvoiceStatusID=516 THEN 1
								WHEN FI.FirstpaymentDate='1900-01-01' OR FI.FirstpaymentDate IS NULL THEN 1
								
							ELSE NULL
							END
						  ) NOOfInvoices
				    , SUM (CASE WHEN (FI.FirstpaymentDate>= CAST(PP.StartDate AS DATE) )  -- Consider invoices having first payment date on/after paymentplan start date
									OR (FI.FirstpaymentDate>= CAST(PP.DownPaymentDate AS DATE) )  -- Consider invoices having first payment date on/after paymentplan downpayment date
									 --- There could be payments only on fees after the paymentplan is taken. Considering payments that are applied to fees after paymentplan start date
									OR (FI.FirstFeepaymentDate>= CAST(PP.StartDate AS DATE) AND (FI.FirstFeepaymentDate<>'1900-01-01' OR FI.FirstpaymentDate IS NOT NULL) ) -- MBSID 1256540746
									AND (FI.FirstpaymentDate<>'1900-01-01' OR FI.FirstpaymentDate IS NOT NULL) 
							  THEN FI.TxnCnt
							  -- Consider invoices having Last payment date on/after paymentplan start date. First payment date could be prior to paymentplan start date
							  WHEN (FI.LastPaymentDate>= CAST(PP.StartDate AS DATE ) OR  (FI.LastPaymentDate>= CAST(PP.DownPaymentDate AS DATE) ))  THEN FI.TxnCnt 
							   -- Do not consider invoices having first/Last payment dates prior to paymentplan start date for Vtoll invoices
							  WHEN (FI.FirstpaymentDate< CAST(PP.StartDate AS DATE ) OR FI.LastPaymentDate< CAST(PP.StartDate AS DATE )) 
									AND FI.EDW_InvoiceStatusID=99999 -- Vtoll
							  THEN NULL -- MBSID 1216576611
							  -- Consider invoices that are partial paid prior to paymentplan start date. There are can be payments after the payment plan is taken for partial invoices.
							  WHEN (FI.FirstpaymentDate< CAST(PP.StartDate AS DATE ) OR FI.LastPaymentDate< CAST(PP.StartDate AS DATE )) AND FI.EDW_InvoiceStatusID=515 THEN FI.TxnCnt 
							  -- Consider paid invoices after payment plan start date
							  WHEN FI.LastPaymentDate>= CAST(PP.StartDate AS DATE ) AND FI.EDW_InvoiceStatusID=516 THEN FI.TxnCnt 
							  WHEN FI.FirstpaymentDate='1900-01-01' OR FI.FirstpaymentDate IS NULL THEN FI.TxnCnt
						   ELSE NULL
						   END
						 ) NOOfTransactions 
				FROM LND_TBOS.TER.PaymentPlans PP 
					JOIN LND_TBOS.TER.PaymentPlanViolator PPV ON PP.PaymentPlanID = PPV.PaymentPlanID 
					JOIN 		
					(	
					    SELECT DISTINCT
					           MbsID,
					           InvoiceNumber 
					    FROM LND_TBOS.TollPlus.MbsInvoices
					) MBSI ON PPV.MbsID = MBSI.MbsID		
					JOIN dbo.Fact_Invoice FI ON FI.InvoiceNumber = MBSI.InvoiceNumber 
					--WHERE PPV.ViolatorID=2010014516
			     GROUP BY PPV.ViolatorID,
                         PP.PaymentPlanID,
                         PPV.MbsID,FI.VehicleID
			) 

			SELECT ISNULL(pp.PaymentPlanID,-1) PaymentPlanID,
				   ISNULL(ppv.ViolatorID,-1) CustomerID,
				   ppv.HVID,
				   ISNULL(COALESCE(CTE.VehicleID,v.VehicleID),-1) VehicleID,
				   ISNULL(ppv.MbsID,-1) MbsID,
				   ISNULL(pp.CustTagID,-1) CustTagID,
				   TS.PaymentPlanStatusID,
				   CAST(LEFT(CONVERT(VARCHAR,pp.StartDate,112),8) AS INT)  AgreementActiveDayID,
				   pp.RemedyStage HVStage,
				   
				   pp.QuoteExpiryDate,
				   pp.QuoteFinalizedDate,
				   pp.QuoteSignedDate,
				   pp.DefaultedDate,
				   pp.StatusDateTime,
				   pp.DownPaymentDate,
				   pp.EndDate LastInstallmentDueDate,
				   pp.LastPaidDate,
				   pp.NextDueDate,						  
				   pp.PaidInFullDate,		   
				   
				   pp.DefaultsCount PreviousDefaultsCount,
				   PP.TotalNoOfMonths,
				   CASE WHEN pp.StartDate < '2021-01-01' AND TS.PaymentPlanStatusDescription NOT IN ('Settlement Agreement Active', 'Settlement Agreement Paid In Full', 'Settlement Agreement Defaulted') THEN NULL 
				   ELSE CTE.NoOfInvoices END NoOfInvoices, -- Not bringing data for the payment plans which are not Active/Defaulted/PaidInFull prior to 2021 as these PP's have some migration issues
				   CASE WHEN pp.StartDate < '2021-01-01' AND TS.PaymentPlanStatusDescription NOT IN ('Settlement Agreement Active', 'Settlement Agreement Paid In Full', 'Settlement Agreement Defaulted') THEN NULL 
				   ELSE CTE.NoOfTransactions END NoOfTransactions,  -- Not bringing data for the payment plans which are not Active/Defaulted/PaidInFull prior to 2021 as these PP's have some migration issues
				   pp.TotalAmountPayable MBSDue,
				   pp.CalculatedDownPayment,
				   pp.CustomDownPayment,
				   pp.MonthlyPayment,			   
				   pp.TotalReceived PaidAmount,
				   pp.BalanceDue RemainingAmount,						   
				   pp.LastPaidAmount,		   
				   pp.TotalSettlementAmount SettlementAmount,						  
				   pp.TollAmount,
				   pp.FeeAmount,						   
				   ISNULL(CAST(SYSDATETIME() AS datetime2(3)), '1900-01-01') AS EDW_UpdateDate --SELECT *
		FROM LND_TBOS.TER.PaymentPlans pp 
		JOIN LND_TBOS.TER.PaymentPlanViolator ppv
			ON pp.PaymentPlanID = ppv.PaymentPlanID
		LEFT JOIN dbo.Dim_HabitualViolator HV 
			ON HV.HVID=PPV.HVID		                                    
		LEFT JOIN EDW_TRIPS.dbo.Dim_PaymentPlanStatus TS ON TS.PaymentPlanStatusID=PP.StatusLookupCode
		LEFT JOIN CTE_Inv CTE ON CTE.CustomerID = PPV.ViolatorID AND CTE.MbsID = ppv.MbsID AND CTE.PaymentPlanID = pp.PaymentPlanID	
		LEFT JOIN dbo.Dim_Vehicle V ON V.CustomerID = PPV.ViolatorID AND CTE.VehicleID IS NULL 
		--WHERE ppv.ViolatorID=800220966 --2010014516
		--WHERE pp.StartDate >= '2021-01-01' --- This code was changed after Discussion with Shekhar to pull paymentplans created after this Date. This bug was Identified by Don and Nandini
											 --- Commented out this filter because we need paymentplans prior to 2021 which are Active/Defaulted/PaidInFull for Collections.
					
			
		OPTION (LABEL='dbo.Fact_PaymentPlan_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Fact_PaymentPlan_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Fact_PaymentPlan_01 ON dbo.Fact_PaymentPlan_NEW (CustomerID);
		CREATE STATISTICS STATS_dbo_Fact_PaymentPlan_02 ON dbo.Fact_PaymentPlan_NEW (MbsID);
		CREATE STATISTICS STATS_dbo_Fact_PaymentPlan_03 ON dbo.Fact_PaymentPlan_NEW (PaymentPlanID);
		CREATE STATISTICS STATS_dbo_Fact_PaymentPlan_04 ON dbo.Fact_PaymentPlan_NEW (CustTagID);
		CREATE STATISTICS STATS_dbo_Fact_PaymentPlan_05 ON dbo.Fact_PaymentPlan_NEW (PaymentPlanStatusID);
		CREATE STATISTICS STATS_dbo_Fact_PaymentPlan_06 ON dbo.Fact_PaymentPlan_NEW (HVStage);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Fact_PaymentPlan_NEW', 'dbo.Fact_PaymentPlan'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Fact_PaymentPlan' TableName, * FROM dbo.Fact_PaymentPlan ORDER BY 2 DESC
	
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
EXEC dbo.Fact_PaymentPlan_Load

EXEC Utility.FromLog 'dbo.Fact_PaymentPlan', 1
SELECT TOP 100 'dbo.Fact_PaymentPlan' Table_Name, * FROM dbo.Fact_PaymentPlan ORDER BY 2


select * FROM dbo.Fact_PaymentPlan ORDER BY 2
select count(*) FROM dbo.Fact_PaymentPlan --110984 
select * FROM edw_trips.dbo.Fact_PaymentPlan  where customerid = 806539432
select * FROM edw_trips_dev.dbo.Fact_PaymentPlan  where customerid = 806539432

--Old Code
(
				SELECT 
					MI.MbsID,
					COUNT(DISTINCT MI.InvoiceNumber) NoOfInvoices,
					COUNT(DISTINCT TPV.CitationID) NoOfTransactions -- select referenceinvoiceID,TPV.*
				FROM LND_TBOS.TollPlus.MbsInvoices MI 
				JOIN LND_TBOS.TollPlus.Invoice_LineItems IL ON IL.ReferenceInvoiceID=MI.InvoiceNumber 
						AND IL.LinkSourceName='Tollplus.TP_Violatedtrips' AND IL.CustTxnCategory='TOLL'
				JOIN LND_TBOS.TollPlus.TP_ViolatedTrips TPV ON TPV.CitationID=IL.LinkID AND TPV.TripStatusID=2
				WHERE MI.MbsID=1216576611
			--	WHERE TPV.ViolatorID=791924795
				--ORDER BY IL.ReferenceInvoiceID,TPV.CitationID
				GROUP BY MI.MbsID

-- Old code for Number od Invoices/transactions

				SELECT DISTINCT
				   MBSH.CustomerID,
				   MBSI.MbsID,
				   COUNT(DISTINCT IL.ReferenceInvoiceID) NoOfInvoices,
				   COUNT(DISTINCT VT.TpTripID) NoOfTransactions
				FROM LND_TBOS.TollPlus.Mbsheader MBSH
			    JOIN
			    (
			        SELECT DISTINCT
			               MbsID,
			               InvoiceNumber
			        FROM LND_TBOS.TollPlus.MbsInvoices
			    ) MBSI
			        ON MBSI.MbsID = PPV.MbsID
				JOIN LND_TBOS.TollPlus.Invoice_LineItems IL ON IL.ReferenceInvoiceID=MBSI.InvoiceNumber AND IL.LinkSourceName='Tollplus.TP_Violatedtrips'
				JOIN LND_TBOS.TollPlus.TP_ViolatedTrips VT ON VT.CitationID=IL.LinkID
			    JOIN LND_TBOS.TER.PaymentPlanViolator PPV
			        ON PPV.MbsID = MBSI.MbsID 
				JOIN LND_TBOS.TER.PaymentPlans PP
					ON PPV.PaymentPlanID=PP.PaymentPlanID
				--WHERE MBSH.CustomerID=806293553
				GROUP BY MBSI.MbsID,
			             MBSH.CustomerID			
			

====== Testing code

SELECT  lnd.*,PP.CustomerID,PP.MbsID,PP.NoOfInvoices FROM (
SELECT MbsID,COUNT(DISTINCT InvoiceNumber) NoOFInvoices
FROM LND_TBOS.TollPlus.MbsInvoices GROUP BY MbsID
) Lnd
JOIN 
dbo.Fact_PaymentPlan PP ON PP.MbsID = Lnd.MbsID AND PP.PaymentPlanStatusID IN (510,49,48)
WHERE Lnd.NoOFInvoices<>ISNULL(PP.NoOfInvoices,0)


WHERE pp.StartDate >= '2021-01-01' --- This code was changed after Discussion with Shekhar to pull paymentplans created after this Date. This bug was Identified by Don and Nandini
--AND pp.PaymentPlanID=477770--426533
--AND ViolatorID=2008262463

*/

