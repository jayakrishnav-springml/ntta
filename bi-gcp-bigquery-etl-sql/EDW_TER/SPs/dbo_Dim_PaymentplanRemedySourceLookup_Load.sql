CREATE PROC [dbo].[Dim_PaymentplanRemedySourceLookup_Load] AS 

IF OBJECT_ID('dbo.Dim_PaymentplanRemedySourceLookup_STAGE')>0
	DROP TABLE dbo.Dim_PaymentplanRemedySourceLookup_STAGE

CREATE TABLE dbo.Dim_PaymentplanRemedySourceLookup_STAGE WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (PaymentplanRemedySourceLookupID)) 
AS 
SELECT 
[PaymentPlanRemedySourceLookupID] , 
	[Descr] ,
    [ActiveFlag],
    [CreatedDate],
    [CreatedBy],
    [UpdatedDate],
    [UpdatedBy]
FROM
LND_TER.[dbo].PaymentplanRemedySourceLookup

OPTION (LABEL = 'Dim_PaymentplanRemedySourceLookup_Load: PaymentplanRemedySourceLookup');

--STEP #2: Replace OLD table with NEW
IF OBJECT_ID('dbo.Dim_PaymentplanRemedySourceLookup_OLD') > 0
	DROP TABLE dbo.Dim_PaymentplanRemedySourceLookup_OLD;

IF OBJECT_ID('dbo.Dim_PaymentplanRemedySourceLookup') > 0 RENAME OBJECT::dbo.Dim_PaymentplanRemedySourceLookup TO Dim_PaymentplanRemedySourceLookup_OLD;
	RENAME OBJECT::dbo.Dim_PaymentplanRemedySourceLookup_STAGE TO Dim_PaymentplanRemedySourceLookup;

IF OBJECT_ID('dbo.Dim_PaymentplanRemedySourceLookup_OLD') > 0
	DROP TABLE dbo.Dim_PaymentplanRemedySourceLookup_OLD;

--STEP #3: Create Statistics 
CREATE STATISTICS STATSDim_PaymentplanRemedySourceLookup_Load_001 ON EDW_TER.dbo.Dim_PaymentplanRemedySourceLookup (PaymentplanRemedySourceLookupID)


