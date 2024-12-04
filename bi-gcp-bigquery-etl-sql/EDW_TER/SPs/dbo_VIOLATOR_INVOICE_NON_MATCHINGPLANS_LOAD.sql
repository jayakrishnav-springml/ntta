CREATE PROC [DBO].[VIOLATOR_INVOICE_NON_MATCHINGPLANS_LOAD] AS

-- Created by Arun on 09-26-2019
-- This proc used to generate a file with paymentplans(excluding court agreements) created from previous day and having remaining balance <> Total Invoice Amount (Tolls_Due + 35$) 
-- Added FirstPaymentDate -- By Arun on 11-20-2019
-- Updated FirstPaymentDate to remove timestamp
-- 11/23 - CHG0035570

    SELECT 	
   INSTANCENBR as [NTTAPlan_ID], ALT_VIOLATOR_ID, CA_ACCT_ID, PRIMARYVIOLATORLNAME, PRIMARYVIOLATORFNAME,SECONDARYVIOLATORLNAME,SECONDARYVIOLATORFNAME, H.PHONENBR, LICPLATENBR, H.ADDRESS1, H.ADDRESS2, H.CITY, [STATE], H.ZIPCODE, 
   H.EMAIL, REMAININGBALANCE, MONTHLYPAYMENTAMOUNT, H.VIOL_INVOICE_ID, TOTAL_FEE_DUE as [TOTAL DUE],I.INVOICE_BALANCE AS [INVOICE_BALANCE]--,STARTDATE
   ,DUEDATE, H.ACTIVEAGREEMENTDATE, LASTINVOICENBR1,CONVERT(VARCHAR, FIRSTPAYMENTDATE, 101) AS  FIRSTPAYMENTDATE
   FROM EDW_TER.dbo.VIOLATOR_INVOICE_HIST H 
   INNER JOIN EDW_TER.DBO.DIM_PAYMENTPLAN PL ON H.INSTANCENBR = PL.[PaymentPlanID]
   LEFT JOIN EDW_TER.dbo.FACT_TER_INVOICE I ON H.INSTANCENBR = I.PAYMENTPLANID AND H.ALT_VIOLATOR_ID = I.VIOLATOR_ID AND H.VIOL_INVOICE_ID = I.VIOL_INVOICE_ID 

   WHERE GENERATION_DATE = CAST(GETDATE() AS DATE) AND INSTANCENBR IN
	(
		SELECT PL.PaymentPlanID
		FROM 
		EDW_TER.dbo.DIM_PAYMENTPLAN PL JOIN EDW_TER.dbo.VIOLATOR_INVOICE_HIST H ON PL.PaymentPlanID = H.INSTANCENBR
		WHERE GENERATION_DATE = CAST(GETDATE() AS DATE) AND PL.PaymentPlanStatusLookupID = 5 AND DeletedFlag = 0 
		GROUP BY PL.PaymentPlanID,CAST(PL.ActiveAgreementDate AS DATE)
		HAVING MAX(PL.RemainingBalanceDue) <> SUM(ISNULL(H.TOTAL_FEE_DUE,0))
		EXCEPT  
		SELECT 
		PL.PaymentPlanID
		FROM EDW_TER.dbo.DIM_PAYMENTPLAN PL 
		JOIN (SELECT DISTINCT H.INSTANCENBR,GENERATION_DATE FROM EDW_TER.dbo.VIOLATOR_INVOICE_HIST H WHERE H.GENERATION_DATE = CAST(GETDATE() AS DATE)) H ON PL.PaymentPlanID = H.INSTANCENBR
		JOIN EDW_TER.dbo.FACT_TER_INVOICE I ON PL.PaymentPlanID = I.PaymentPlanID
		WHERE PL.PaymentPlanStatusLookupID = 5 AND DeletedFlag = 0
		GROUP BY PL.PaymentPlanID,CAST(PL.ActiveAgreementDate AS DATE) 
		HAVING MAX(PL.RemainingBalanceDue) = SUM(ISNULL(I.INVOICE_BALANCE,0))
		
	)
   AND (CASE WHEN AGREEMENTTYPE = 'COURT' AND REMAININGBALANCE = [SETTLEMENT AMOUNT] THEN 1 ELSE 0 END) = 0
   ORDER BY  INSTANCENBR, ALT_VIOLATOR_ID DESC, H.VIOL_INVOICE_ID


