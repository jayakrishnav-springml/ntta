CREATE PROC [VP_OWNER].[VB_INVOICES_Update_Stats] AS

EXEC DropStats 'VP_OWNER','VB_INVOICES'
CREATE STATISTICS STATS_VB_INVOICES_001 ON VP_OWNER.VB_INVOICES (VBI_INVOICE_ID)
CREATE STATISTICS STATS_VB_INVOICES_003 ON VP_OWNER.VB_INVOICES (VBI_INVOICE_ID, LAST_UPDATE_DATE)
CREATE STATISTICS STATS_VB_INVOICES_004 ON VP_OWNER.VB_INVOICES (LAST_UPDATE_DATE)
