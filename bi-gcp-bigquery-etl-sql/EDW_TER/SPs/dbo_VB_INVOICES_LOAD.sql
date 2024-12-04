CREATE PROC [DBO].[VB_INVOICES_LOAD] AS 


IF OBJECT_ID('dbo.VB_INVOICES_NEW')>0 	DROP TABLE dbo.VB_INVOICES_NEW

CREATE TABLE dbo.VB_INVOICES_NEW WITH (CLUSTERED INDEX(VBI_INVOICE_ID), DISTRIBUTION = HASH(VBI_INVOICE_ID)) 
AS 
-- EXPLAIN
SELECT 
	  B.ViolatorID, B.VidSeq
	, A.VBI_INVOICE_ID
	, A.INVOICE_DATE
	, A.INVOICE_AMOUNT
	, A.INVOICE_AMT_PAID
	, A.VBB_BATCH_ID
	, A.VBI_STATUS
	, A.DATE_EXCUSED
	, A.INVOICE_DAYS_TO_EXCUSED
	, InvDtl.TOLL_DUE
	, GETDATE() AS INSERT_DATE
FROM EDW_RITE.dbo.VB_INVOICES A
INNER JOIN dbo.Violator B ON A.VIOLATOR_ID = B.ViolatorId
INNER JOIN 
	(
		SELECT AA.VBI_INVOICE_ID, SUM(AA.TOLL_DUE) AS TOLL_DUE
		FROM EDW_RITE.dbo.VB_INVOICE_VIOL AA 
		GROUP BY AA.VBI_INVOICE_ID
	) InvDtl ON A.VBI_INVOICE_ID = InvDtl.VBI_INVOICE_ID
	--(
	--	SELECT AA.VIOLATOR_ID, AA.VBI_INVOICE_ID, SUM(AA.TOLL_DUE) AS TOLL_DUE
	--	FROM EDW_RITE.dbo.VB_INVOICE_VIOL AA 
	--	INNER JOIN Violator BB ON AA.VIOLATOR_ID = BB.ViolatorId
	--	WHERE BB.CURRENT_IND = 1
	--	GROUP BY AA.VIOLATOR_ID, AA.VBI_INVOICE_ID
	--) InvDtl ON A.VIOLATOR_ID = InvDtl.VIOLATOR_ID AND A.VBI_INVOICE_ID = InvDtl.VBI_INVOICE_ID
WHERE B.CURRENT_IND = 1

IF OBJECT_ID('dbo.VB_INVOICES')>0 	RENAME OBJECT::dbo.VB_INVOICES TO VB_INVOICES_OLD;
RENAME OBJECT::dbo.VB_INVOICES_NEW TO VB_INVOICES;

IF OBJECT_ID('dbo.VB_INVOICES_OLD')>0	DROP TABLE dbo.VB_INVOICES_OLD

--CREATE STATISTICS STATS_VB_INVOICES_001 ON dbo.VB_INVOICES (ViolatorID)
CREATE STATISTICS STATS_VB_INVOICES_001 ON dbo.VB_INVOICES (ViolatorID, VBI_INVOICE_ID)

