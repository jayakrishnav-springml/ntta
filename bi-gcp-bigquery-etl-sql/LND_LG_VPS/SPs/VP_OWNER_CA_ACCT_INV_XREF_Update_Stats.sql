CREATE PROC [VP_OWNER].[CA_ACCT_INV_XREF_Update_Stats] AS

EXEC DropStats 'VP_OWNER','CA_ACCT_INV_XREF'
CREATE STATISTICS STATS_CA_ACCT_INV_XREF_001 ON VP_OWNER.CA_ACCT_INV_XREF (CA_ACCT_ID)
CREATE STATISTICS STATS_CA_ACCT_INV_XREF_002 ON VP_OWNER.CA_ACCT_INV_XREF (CA_ACCT_ID, VIOL_INVOICE_ID)
CREATE STATISTICS STATS_CA_ACCT_INV_XREF_003 ON VP_OWNER.CA_ACCT_INV_XREF (CA_ACCT_ID, LAST_UPDATE_DATE)
CREATE STATISTICS STATS_CA_ACCT_INV_XREF_004 ON VP_OWNER.CA_ACCT_INV_XREF (LAST_UPDATE_DATE)

