CREATE PROC [DBO].[FACT_INVOICE_VIOL_INVOICE_SUM_STAGE_LOAD] AS 

IF OBJECT_ID('dbo.FACT_INVOICE_VIOL_INVOICE_SUM_STAGE')>0 	DROP TABLE dbo.FACT_INVOICE_VIOL_INVOICE_SUM_STAGE

CREATE TABLE dbo.FACT_INVOICE_VIOL_INVOICE_SUM_STAGE WITH (DISTRIBUTION = HASH(VIOL_INVOICE_ID), CLUSTERED INDEX (VIOL_INVOICE_ID)) 
AS 
SELECT VI.VIOLATOR_ID, VI.VIOL_INVOICE_ID, SUM(VIV.TOLL_DUE_AMOUNT) VIOL_TOLLS_DUE, SUM(VIV.FINE_AMOUNT) AS FINE_AMOUNT, COUNT(VIV.VIOLATION_ID) VIOL_TXN_COUNT
FROM dbo.VIOL_INVOICES VI
JOIN dbo.VIOL_INVOICE_VIOL VIV ON VI.VIOL_INVOICE_ID = VIV.VIOL_INVOICE_ID
GROUP BY VI.VIOLATOR_ID, VI.VIOL_INVOICE_ID


exec DropStats 'dbo','FACT_INVOICE_VIOL_INVOICE_SUM_STAGE' 
-- exec CreateStats 'FACT_INVOICE_VIOL_INVOICE_SUM_STAGE'
CREATE STATISTICS STATS_FACT_INVOICE_VIOL_INVOICE_SUM_STAGE_001 ON DBO.FACT_INVOICE_VIOL_INVOICE_SUM_STAGE  (VIOLATOR_ID, VIOL_INVOICE_ID)


