CREATE PROC [VP_OWNER].[VIOL_INVOICE_VIOL_DELETE] AS


EXEC DropStats 'VP_OWNER','VIOL_INVOICE_VIOL_CT_DEL'
CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_CT_DEL_001 ON VP_OWNER.VIOL_INVOICE_VIOL_CT_DEL (VIOLATION_ID)
CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_CT_DEL_002 ON VP_OWNER.VIOL_INVOICE_VIOL_CT_DEL (VIOLATION_ID, INSERT_DATETIME)
CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_CT_DEL_003 ON VP_OWNER.VIOL_INVOICE_VIOL_CT_DEL (VIOL_INVOICE_ID)
CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_CT_DEL_004 ON VP_OWNER.VIOL_INVOICE_VIOL_CT_DEL (VIOL_INVOICE_ID, INSERT_DATETIME)
CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_CT_DEL_005 ON VP_OWNER.VIOL_INVOICE_VIOL_CT_DEL (VIOLATION_ID,VIOL_INVOICE_ID)


UPDATE VP_OWNER.VIOL_INVOICE_VIOL
	SET  LAST_UPDATE_TYPE = 'D'
		, LAST_UPDATE_DATE = B.INSERT_DATETIME
FROM VP_OWNER.VIOL_INVOICE_VIOL_CT_DEL B
WHERE VP_OWNER.VIOL_INVOICE_VIOL.VIOLATION_ID = B.VIOLATION_ID AND VP_OWNER.VIOL_INVOICE_VIOL.VIOL_INVOICE_ID = B.VIOL_INVOICE_ID

/*
	To Test With:

	INSERT INTO VP_OWNER.VIOLATIONS_CT_DEL
	SELECT TOP 1 * FROM VP_OWNER.VIOLATIONS_CT_DEL 

	SELECT * FROM VP_OWNER.VIOLATIONS WHERE LAST_UPDATE_TYPE = 'D'
*/
