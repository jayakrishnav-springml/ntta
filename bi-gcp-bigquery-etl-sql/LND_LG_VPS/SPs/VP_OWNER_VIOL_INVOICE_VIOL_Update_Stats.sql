CREATE PROC [VP_OWNER].[VIOL_INVOICE_VIOL_Update_Stats] AS

EXEC DropStats 'VP_OWNER','VIOL_INVOICE_VIOL'
CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_001 ON VP_OWNER.VIOL_INVOICE_VIOL (VIOLATION_ID)
CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_002 ON VP_OWNER.VIOL_INVOICE_VIOL (VIOLATION_ID, LAST_UPDATE_DATE)
CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_003 ON VP_OWNER.VIOL_INVOICE_VIOL (VIOL_INVOICE_ID)
CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_004 ON VP_OWNER.VIOL_INVOICE_VIOL (VIOL_INVOICE_ID, LAST_UPDATE_DATE)
CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_005 ON VP_OWNER.VIOL_INVOICE_VIOL (VIOLATION_ID,VIOL_INVOICE_ID)
CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_006 ON VP_OWNER.VIOL_INVOICE_VIOL (LAST_UPDATE_DATE)

