CREATE PROC [VP_OWNER].[VB_INVOICE_VIOL_UPDATE] AS
/*
	Use this proc to help write the code
		GetUpdateFields 'VP_OWNER','VB_INVOICE_VIOL'
		You will have to remove the Distribution key from what it generates
*/

/*
	Update Stats on CT_UPD table to help with de-dupping and update steps
*/

EXEC DropStats 'VP_OWNER','VB_INVOICE_VIOL_CT_UPD'
CREATE STATISTICS STATS_VB_INVOICE_VIOL_CT_UPD_001 ON VP_OWNER.VB_INVOICE_VIOL_CT_UPD (VBI_INVOICE_ID, VIOLATION_ID)
CREATE STATISTICS STATS_VB_INVOICE_VIOL_CT_UPD_002 ON VP_OWNER.VB_INVOICE_VIOL_CT_UPD (VBI_INVOICE_ID, VIOLATION_ID, INSERT_DATETIME)
CREATE STATISTICS STATS_VB_INVOICE_VIOL_CT_UPD_004 ON VP_OWNER.VB_INVOICE_VIOL_CT_UPD (INSERT_DATETIME)

	UPDATE  VP_OWNER.VB_INVOICE_VIOL
	SET 
    
		  VP_OWNER.VB_INVOICE_VIOL.TOLL_DUE = B.TOLL_DUE
		, VP_OWNER.VB_INVOICE_VIOL.DATE_CREATED = B.DATE_CREATED
		, VP_OWNER.VB_INVOICE_VIOL.DATE_MODIFIED = B.DATE_MODIFIED
		, VP_OWNER.VB_INVOICE_VIOL.MODIFIED_BY = B.MODIFIED_BY
		, VP_OWNER.VB_INVOICE_VIOL.CREATED_BY = B.CREATED_BY
		, VP_OWNER.VB_INVOICE_VIOL.IMAGE_SELECTABLE = B.IMAGE_SELECTABLE
		, VP_OWNER.VB_INVOICE_VIOL.VIOL_STATUS = B.VIOL_STATUS
		, VP_OWNER.VB_INVOICE_VIOL.LAST_UPDATE_TYPE = 'U'
		, VP_OWNER.VB_INVOICE_VIOL.LAST_UPDATE_DATE = B.INSERT_DATETIME
	FROM VP_OWNER.VB_INVOICE_VIOL_CT_UPD B
	WHERE VP_OWNER.VB_INVOICE_VIOL.VBI_INVOICE_ID = B.VBI_INVOICE_ID AND VP_OWNER.VB_INVOICE_VIOL.VIOLATION_ID = B.VIOLATION_ID

