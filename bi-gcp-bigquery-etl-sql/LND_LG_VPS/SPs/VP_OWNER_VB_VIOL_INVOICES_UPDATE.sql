CREATE PROC [VP_OWNER].[VB_VIOL_INVOICES_UPDATE] AS
/*
	Use this proc to help write the code
		GetUpdateFields 'VP_OWNER','VB_VIOL_INVOICES'
		You will have to remove the Distribution key from what it generates
*/

/*
	Update Stats on CT_UPD table to help with de-dupping and update steps
*/

EXEC DropStats 'VP_OWNER','VB_VIOL_INVOICES_CT_UPD'
CREATE STATISTICS STATS_VB_VIOL_INVOICES_CT_UPD_001 ON VP_OWNER.VB_VIOL_INVOICES_CT_UPD (VBI_VBI_INVOICE_ID, INV_VIOL_INVOICE_ID)
CREATE STATISTICS STATS_VB_VIOL_INVOICES_CT_UPD_002 ON VP_OWNER.VB_VIOL_INVOICES_CT_UPD (VBI_VBI_INVOICE_ID, INV_VIOL_INVOICE_ID, INSERT_DATETIME)
CREATE STATISTICS STATS_VB_VIOL_INVOICES_CT_UPD_004 ON VP_OWNER.VB_VIOL_INVOICES_CT_UPD (INSERT_DATETIME)


	UPDATE  VP_OWNER.VB_VIOL_INVOICES
	SET 
		   VP_OWNER.VB_VIOL_INVOICES.DATE_CREATED = B.DATE_CREATED
		, VP_OWNER.VB_VIOL_INVOICES.DATE_MODIFIED = B.DATE_MODIFIED
		, VP_OWNER.VB_VIOL_INVOICES.MODIFIED_BY = B.MODIFIED_BY
		, VP_OWNER.VB_VIOL_INVOICES.CREATED_BY = B.CREATED_BY
		, VP_OWNER.VB_VIOL_INVOICES.LAST_UPDATE_TYPE = 'U'
		, VP_OWNER.VB_VIOL_INVOICES.LAST_UPDATE_DATE = B.INSERT_DATETIME
	FROM VP_OWNER.VB_VIOL_INVOICES_CT_UPD B
	WHERE VP_OWNER.VB_VIOL_INVOICES.VBI_VBI_INVOICE_ID = B.VBI_VBI_INVOICE_ID 
	AND VP_OWNER.VB_VIOL_INVOICES.INV_VIOL_INVOICE_ID = B.INV_VIOL_INVOICE_ID


