CREATE PROC [VP_OWNER].[VB_INVOICE_BATCHES_INSERT] AS

/*
	Update Stats on CT_INS table to help with de-dupping and update steps
	GetFields 'VP_OWNER','VB_INVOICE_BATCHES'
	GetInsertFields2 'VP_OWNER','VB_INVOICE_BATCHES'
*/

EXEC DropStats 'VP_OWNER','VB_INVOICE_BATCHES_CT_INS'
CREATE STATISTICS STATS_VB_INVOICE_BATCHES_CT_INS_001 ON VP_OWNER.VB_INVOICE_BATCHES_CT_INS (VBB_BATCH_ID)

INSERT INTO VP_OWNER.VB_INVOICE_BATCHES
	(
		 VBB_BATCH_ID, DATE_PRODUCED, VB_INVOICE_COUNT, DATE_PRINTED, DATE_MAILED, DATE_CREATED, DATE_MODIFIED, MODIFIED_BY, CREATED_BY, DUE_DATE, VB_INV_BATCH_TYPE_CODE, VB_LN_COUNT, 
		LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	)
SELECT 
	  A.VBB_BATCH_ID, A.DATE_PRODUCED, A.VB_INVOICE_COUNT, A.DATE_PRINTED, A.DATE_MAILED, A.DATE_CREATED, A.DATE_MODIFIED, A.MODIFIED_BY, A.CREATED_BY, A.DUE_DATE, A.VB_INV_BATCH_TYPE_CODE, A.VB_LN_COUNT, 
	  'I' AS LAST_UPDATE_TYPE, A.INSERT_DATETIME
FROM VP_OWNER.VB_INVOICE_BATCHES_CT_INS A
LEFT JOIN VP_OWNER.VB_INVOICE_BATCHES B ON A.VBB_BATCH_ID = B.VBB_BATCH_ID
WHERE B.VBB_BATCH_ID IS NULL


