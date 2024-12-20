CREATE PROC [dbo].[Dim_PaymentPlanStatusLookup_Load] AS 

IF OBJECT_ID('dbo.Dim_PaymentPlanStatusLookup_STAGE')>0
	DROP TABLE dbo.Dim_PaymentPlanStatusLookup_STAGE

CREATE TABLE dbo.Dim_PaymentPlanStatusLookup_STAGE WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (PaymentPlanStatusLookupID)) 
AS 
SELECT 
[PaymentPlanStatusLookupID], 
[Descr], 
[ActiveFlag], 
[CreatedDate], 
[CreatedBy]
FROM
LND_TER.[dbo].PaymentPlanStatusLookup

OPTION (LABEL = 'Dim_PaymentPlanStatusLookup_Load: PaymentPlanStatusLookup');

--STEP #2: Replace OLD table with NEW
IF OBJECT_ID('dbo.Dim_PaymentPlanStatusLookup_OLD') > 0
	DROP TABLE dbo.Dim_PaymentPlanStatusLookup_OLD;

IF OBJECT_ID('dbo.Dim_PaymentPlanStatusLookup') > 0 RENAME OBJECT::dbo.Dim_PaymentPlanStatusLookup TO Dim_PaymentPlanStatusLookup_OLD;
	RENAME OBJECT::dbo.Dim_PaymentPlanStatusLookup_STAGE TO Dim_PaymentPlanStatusLookup;

IF OBJECT_ID('dbo.Dim_PaymentPlanStatusLookup_OLD') > 0
	DROP TABLE dbo.Dim_PaymentPlanStatusLookup_OLD;

--STEP #3: Create Statistics 
CREATE STATISTICS STATSDim_PaymentPlanStatusLookup_Load_001 ON EDW_TER.dbo.Dim_PaymentPlanStatusLookup (PaymentPlanStatusLookupID)









