CREATE PROC [dbo].[DIM_PAYMENTPLAN_Load] AS 

IF OBJECT_ID('dbo.DIM_PAYMENTPLAN_STAGE')>0
	DROP TABLE dbo.DIM_PAYMENTPLAN_STAGE

CREATE TABLE dbo.DIM_PAYMENTPLAN_STAGE WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (PaymentplanId)) 
AS 
SELECT 
[PaymentPlanID], 
[PaymentPlanStatusLookupID], 
[ActiveAgreementFlag], 
[ActiveAgreementDate], 
[DefaultedFlag], 
[DefaultedDate], 
[PaidInFullFlag], 
[PaidInFullDate], 
[BankruptcyFlag], 
[BankruptcyDate], 
[ViolationAmt], 
[ZipCashAmt], 
[SettlementAmt], 
[AdminFeeCount], 
[AdminFeeTotal], 
[CitationCount], 
[CitationFeeTotal], 
[CollectionsReceived], 
[CustomDownPaymentReceivedFlag], 
[DownPaymentReceived], 
[TotalReceived], 
[RemainingBalanceDue], 
[MonthlyPayment], 
[LastPayment], 
[CustomNoOfMonthsFlag], 
[TotalNoOfMonths], 
[FirstNoOfMonths], 
[PlanStartDate], 
[FirstPaymentDate], 
[LastPaymentDate], 
[PaymentPlanRemedySourceLookupID], 
[PaymentPlanContactSourceLookupID], 
[SpanishFlag], 
[LastName], 
[FirstName], 
[LastName2nd], 
[FirstName2nd], 
[Address1], 
[Address2],
[City], 
[StateLookupID], 
[ZipCode], 
[Plus4], 
[PhoneNbr], 
[OtherPhoneNbr], 
[Email], 
CASE WHEN ISNUMERIC([TollTagNbr]) = 0 OR [TollTagNbr] IS NULL THEN '-1' ELSE [TollTagNbr] END  AS [TollTagNbr] , 
[TotalPaymentsAmt], 
[BalanceDue], 
[TotalNoOfPayments], 
[DeletedFlag], 
[CreatedDate], 
[CreatedBy], 
[UpdatedDate], 
[UpdatedBy], 
[LAST_UPDATE_TYPE], 
[LAST_UPDATE_DATE]
FROM
LND_TER.[dbo].[PaymentPlan]
UNION
--- Added Paymentplanid(-1) to identify HV Violators invoices
SELECT 
-1 as PaymentPlanID	
,0 as PaymentPlanStatusLookupID	
,-1 as ActiveAgreementFlag	
,'1900-01-01' as ActiveAgreementDate	
,-1 as DefaultedFlag	
,'1900-01-01' as DefaultedDate	
,-1 as PaidInFullFlag	
,-1 as PaidInFullDate	
,-1 as BankruptcyFlag	
,'1900-01-01' as BankruptcyDate	
,-1 as ViolationAmt	
,-1 as ZipCashAmt	
,-1 as SettlementAmt	
,-1 as AdminFeeCount	
,-1 as AdminFeeTotal	
,-1 as CitationCount	
,-1 as CitationFeeTotal	
,-1 as CollectionsReceived	
,-1 as CustomDownPaymentReceivedFlag	
,-1 as DownPaymentReceived	
,-1 as TotalReceived	
,-1 as RemainingBalanceDue	
,-1 as MonthlyPayment	
,-1 as LastPayment	
,-1 as CustomNoOfMonthsFlag	
,-1 as TotalNoOfMonths	
,-1 as FirstNoOfMonths	
,'1900-01-01' as PlanStartDate	
,'1900-01-01' as FirstPaymentDate	
,'1900-01-01' as LastPaymentDate	
,-1 as PaymentPlanRemedySourceLookupID	
,-1 as PaymentPlanContactSourceLookupID	
,-1 as SpanishFlag	
,'' as LastName	
,'' as FirstName	
,'' as LastName2nd	
,'' as FirstName2nd	
,'' as Address1	
,'' as Address2	
,'' as City	
,-1 as StateLookupID	
,'' as ZipCode	
,'' as Plus4	
,'' as PhoneNbr	
,'' as OtherPhoneNbr	
,'' as Email	
,'' as TollTagNbr	
,-1 as TotalPaymentsAmt	
,-1 as BalanceDue	
,-1 as TotalNoOfPayments	
,-1 as DeletedFlag	
,'1900-01-01' as CreatedDate	
,'' as CreatedBy	
,'1900-01-01' as UpdatedDate	
,'' as UpdatedBy	
,'' as LAST_UPDATE_TYPE	
,'1900-01-01' as LAST_UPDATE_DATE


OPTION (LABEL = 'DIM_PAYMENTPLAN_Load: DIM_PAYMENTPLAN');

--STEP #2: Replace OLD table with NEW
IF OBJECT_ID('dbo.DIM_PAYMENTPLAN_OLD') > 0
	DROP TABLE dbo.DIM_PAYMENTPLAN_OLD;

IF OBJECT_ID('dbo.DIM_PAYMENTPLAN') > 0 RENAME OBJECT::dbo.DIM_PAYMENTPLAN TO DIM_PAYMENTPLAN_OLD;
	RENAME OBJECT::dbo.DIM_PAYMENTPLAN_STAGE TO DIM_PAYMENTPLAN;

IF OBJECT_ID('dbo.DIM_PAYMENTPLAN_OLD') > 0
	DROP TABLE dbo.DIM_PAYMENTPLAN_OLD;

--STEP #3: Create Statistics --[dbo].[CreateStats] 'dbo', 'FACT_TER_SUMMARY'
CREATE STATISTICS STATSDIM_PAYMENTPLAN_Load_001 ON EDW_TER.dbo.DIM_PAYMENTPLAN (PaymentplanId)




