CREATE PROC [VP_OWNER].[VIOL_INVOICES_INSERT] AS

/*
	Update Stats on CT_INS table to help with de-dupping and update steps
	GetFields 'VP_OWNER','VIOL_INVOICES'
	GetInsertFields2 'VP_OWNER','VIOL_INVOICES'
*/

EXEC DropStats 'VP_OWNER','VIOL_INVOICES_CT_INS'
CREATE STATISTICS STATS_VIOL_INVOICES_CT_INS_001 ON VP_OWNER.VIOL_INVOICES_CT_INS (VIOL_INVOICE_ID)

INSERT INTO VP_OWNER.VIOL_INVOICES
	(
		  VIOL_INVOICE_ID, INVOICE_DATE, INVOICE_AMOUNT, INVOICE_AMT_PAID, VIOL_INV_BATCH_ID, VIOL_INV_STATUS, VIOLATOR_ADDR_SEQ, VIOLATOR_ID, CURR_DUE_DATE, MAIL_RETURN_DATE, INV_CLOSED_DATE, MODIFIED_BY, DATE_MODIFIED, CONTESTED, EXCUSED_BY, DATE_EXCUSED, INV_EXCUSED_REASON, STATUS_DATE, COMMENT_DATE, DPS_DATE, DPS_REJECT_DATE, DATE_CREATED, CREATED_BY, GL_STATUS, REMAILED, CACCTINVXR_VIOL_INVOICE_ID, INVOICE_AMT_DISC, CA_INV_STATUS, IS_VTOLL, DPS_INV_STATUS, IS_VEA, DET_LINK_ID, VIP_HOLD, SOURCE_CODE, INV_ADMIN_FEE, CLOSE_OUT_ELIGIBILITY_DATE, CLOSE_OUT_STATUS, CLOSE_OUT_DATE, CLOSE_OUT_TYPE, INV_ADMIN_FEE2, INV_ADMIN_FEE_POST_DATE, INV_ADMIN_FEE_2_POST_DATE, 
		 LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	)
SELECT 
	  A.VIOL_INVOICE_ID, A.INVOICE_DATE, A.INVOICE_AMOUNT, A.INVOICE_AMT_PAID, A.VIOL_INV_BATCH_ID, A.VIOL_INV_STATUS, A.VIOLATOR_ADDR_SEQ, A.VIOLATOR_ID, A.CURR_DUE_DATE, A.MAIL_RETURN_DATE, A.INV_CLOSED_DATE, A.MODIFIED_BY, A.DATE_MODIFIED, A.CONTESTED, A.EXCUSED_BY, A.DATE_EXCUSED, A.INV_EXCUSED_REASON, A.STATUS_DATE, A.COMMENT_DATE, A.DPS_DATE, A.DPS_REJECT_DATE, A.DATE_CREATED, A.CREATED_BY, A.GL_STATUS, A.REMAILED, A.CACCTINVXR_VIOL_INVOICE_ID, A.INVOICE_AMT_DISC, A.CA_INV_STATUS, A.IS_VTOLL, A.DPS_INV_STATUS, A.IS_VEA, A.DET_LINK_ID, A.VIP_HOLD, A.SOURCE_CODE, A.INV_ADMIN_FEE, A.CLOSE_OUT_ELIGIBILITY_DATE, A.CLOSE_OUT_STATUS, A.CLOSE_OUT_DATE, A.CLOSE_OUT_TYPE, A.INV_ADMIN_FEE2, A.INV_ADMIN_FEE_POST_DATE, A.INV_ADMIN_FEE_2_POST_DATE, 
	  'I' AS LAST_UPDATE_TYPE, A.INSERT_DATETIME
FROM VP_OWNER.VIOL_INVOICES_CT_INS A
LEFT JOIN VP_OWNER.VIOL_INVOICES B ON A.VIOL_INVOICE_ID = B.VIOL_INVOICE_ID
WHERE B.VIOL_INVOICE_ID IS NULL


