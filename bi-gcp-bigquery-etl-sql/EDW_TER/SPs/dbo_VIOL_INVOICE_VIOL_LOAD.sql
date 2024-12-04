CREATE PROC [DBO].[VIOL_INVOICE_VIOL_LOAD] AS 

IF OBJECT_ID('dbo.VIOL_INVOICE_VIOL_NEW')>0
	DROP TABLE dbo.VIOL_INVOICE_VIOL_NEW

CREATE TABLE dbo.VIOL_INVOICE_VIOL_NEW WITH (DISTRIBUTION = HASH(ViolatorID), CLUSTERED COLUMNSTORE INDEX) 
AS 
-- EXPLAIN
SELECT B.ViolatorID, B.VidSeq,  A.VIOL_INVOICE_ID, A.VIOLATION_ID, A.TOLL_DUE_AMOUNT, A.FINE_AMOUNT, GETDATE() AS INSERT_DATE
FROM EDW_RITE.dbo.VIOL_INVOICE_VIOL A
INNER JOIN dbo.VIOL_INVOICES B ON A.VIOLATOR_ID = B.ViolatorID AND A.VIOL_INVOICE_ID = B.VIOL_INVOICE_ID
-- OPTION (LABEL = 'VIOL_INVOICE_VIOL: VIOL_INVOICE_VIOL');

IF OBJECT_ID('dbo.VIOL_INVOICES')>0
	RENAME OBJECT::dbo.VIOL_INVOICE_VIOL TO VIOL_INVOICE_VIOL_OLD;


RENAME OBJECT::dbo.VIOL_INVOICE_VIOL_NEW TO VIOL_INVOICE_VIOL;

IF OBJECT_ID('dbo.VIOL_INVOICE_VIOL_OLD')>0
	DROP TABLE dbo.VIOL_INVOICE_VIOL_OLD

CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_001 ON DBO.VIOL_INVOICE_VIOL (ViolatorID)
CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_002 ON DBO.VIOL_INVOICE_VIOL (ViolatorID, VIOL_INVOICE_ID)
CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_003 ON DBO.VIOL_INVOICE_VIOL (ViolatorID, VIOLATION_ID)

