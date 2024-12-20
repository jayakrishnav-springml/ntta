CREATE PROC [VP_OWNER].[VB_VIOL_INVOICES_INSERT] AS

/*
	Update Stats on CT_INS table to help with de-dupping and update steps
	GetFields 'VP_OWNER','VB_VIOL_INVOICES'
*/

EXEC DropStats 'VP_OWNER','VB_VIOL_INVOICES_CT_INS'
CREATE STATISTICS STATS_VB_VIOL_INVOICES_CT_INS_001 ON VP_OWNER.VB_VIOL_INVOICES_CT_INS (VBI_VBI_INVOICE_ID, INV_VIOL_INVOICE_ID)

INSERT INTO VP_OWNER.VB_VIOL_INVOICES
	(
		   VBI_VBI_INVOICE_ID, INV_VIOL_INVOICE_ID, DATE_CREATED, DATE_MODIFIED, MODIFIED_BY, CREATED_BY
		  , LAST_UPDATE_TYPE, LAST_UPDATE_DATE

	)
SELECT 
	   A.VBI_VBI_INVOICE_ID, A.INV_VIOL_INVOICE_ID, A.DATE_CREATED, A.DATE_MODIFIED, A.MODIFIED_BY, A.CREATED_BY
	, 'I' AS LAST_UPDATE_TYPE, A.INSERT_DATETIME
FROM VP_OWNER.VB_VIOL_INVOICES_CT_INS A
LEFT JOIN VP_OWNER.VB_VIOL_INVOICES B 
	ON A.VBI_VBI_INVOICE_ID = B.VBI_VBI_INVOICE_ID 
	AND  A.INV_VIOL_INVOICE_ID = B.INV_VIOL_INVOICE_ID
WHERE B.VBI_VBI_INVOICE_ID IS NULL AND B.INV_VIOL_INVOICE_ID IS NULL


