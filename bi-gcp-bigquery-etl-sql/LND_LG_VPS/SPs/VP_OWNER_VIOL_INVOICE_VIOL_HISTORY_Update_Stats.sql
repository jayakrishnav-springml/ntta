CREATE PROC [VP_OWNER].[VIOL_INVOICE_VIOL_HISTORY_Update_Stats] AS

EXEC DropStats 'VP_OWNER','VIOL_INVOICE_VIOL_HISTORY'
CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_HISTORY_001 ON VP_OWNER.VIOL_INVOICE_VIOL_HISTORY (VIOLATION_ID,VIOL_INVOICE_ID,VIOL_INV_VIOL_SEQ_ID)
CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_HISTORY_002 ON VP_OWNER.VIOL_INVOICE_VIOL_HISTORY (VIOLATION_ID,VIOL_INVOICE_ID,VIOL_INV_VIOL_SEQ_ID, LAST_UPDATE_DATE)
CREATE STATISTICS STATS_VIOL_INVOICE_VIOL_HISTORY_003 ON VP_OWNER.VIOL_INVOICE_VIOL_HISTORY (LAST_UPDATE_DATE)
