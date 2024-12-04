CREATE PROC [TAG_OWNER].[RETAIL_TRXN_DETAILS_Update_Stats] AS

EXEC DropStats 'TAG_OWNER','RETAIL_TRXN_DETAILS'
CREATE STATISTICS STATS_RETAIL_TRXN_DETAILS_001 ON TAG_OWNER.RETAIL_TRXN_DETAILS (RETAIL_TRANS_ID,RTD_ID)
CREATE STATISTICS STATS_RETAIL_TRXN_DETAILS_002 ON TAG_OWNER.RETAIL_TRXN_DETAILS (RETAIL_TRANS_ID,RTD_ID, LAST_UPDATE_DATE)
CREATE STATISTICS STATS_RETAIL_TRXN_DETAILS_003 ON TAG_OWNER.RETAIL_TRXN_DETAILS (LAST_UPDATE_DATE)

