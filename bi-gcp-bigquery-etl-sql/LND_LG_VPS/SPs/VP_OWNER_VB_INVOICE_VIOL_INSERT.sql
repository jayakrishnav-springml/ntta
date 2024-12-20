CREATE PROC [VP_OWNER].[VB_INVOICE_VIOL_INSERT] AS

/*
	Update Stats on CT_INS table to help with de-dupping and update steps
	GetFields 'VP_OWNER','VB_INVOICE_VIOL'
	GetInsertFields2 'VP_OWNER','VB_INVOICE_VIOL'
*/

EXEC DropStats 'VP_OWNER','VB_INVOICE_VIOL_CT_INS'
CREATE STATISTICS STATS_VB_INVOICE_VIOL_CT_INS_001 ON VP_OWNER.VB_INVOICE_VIOL_CT_INS (VBI_INVOICE_ID, VIOLATION_ID)

INSERT INTO VP_OWNER.VB_INVOICE_VIOL
	(
		 VBI_INVOICE_ID, VIOLATION_ID, TOLL_DUE, DATE_CREATED, DATE_MODIFIED, MODIFIED_BY, CREATED_BY, IMAGE_SELECTABLE, VIOL_STATUS, 
		LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	)
SELECT 
	  A.VBI_INVOICE_ID, A.VIOLATION_ID, A.TOLL_DUE, A.DATE_CREATED, A.DATE_MODIFIED, A.MODIFIED_BY, A.CREATED_BY, A.IMAGE_SELECTABLE, A.VIOL_STATUS,
	  'I' AS LAST_UPDATE_TYPE, A.INSERT_DATETIME
FROM VP_OWNER.VB_INVOICE_VIOL_CT_INS A
LEFT JOIN VP_OWNER.VB_INVOICE_VIOL B ON A.VBI_INVOICE_ID = B.VBI_INVOICE_ID AND A.VIOLATION_ID = B.VIOLATION_ID
WHERE B.VBI_INVOICE_ID IS NULL AND B.VIOLATION_ID IS NULL 


