CREATE PROC [TAG_OWNER].[RETAIL_TRANSACTIONS_Update_Stats] AS

EXEC DropStats 'TAG_OWNER','RETAIL_TRANSACTIONS'
CREATE STATISTICS STATS_RETAIL_TRANSACTIONS_001 ON TAG_OWNER.RETAIL_TRANSACTIONS (RETAIL_TRANS_ID)
CREATE STATISTICS STATS_RETAIL_TRANSACTIONS_002 ON TAG_OWNER.RETAIL_TRANSACTIONS (RETAIL_TRANS_ID, LAST_UPDATE_DATE)
CREATE STATISTICS STATS_RETAIL_TRANSACTIONS_003 ON TAG_OWNER.RETAIL_TRANSACTIONS (LAST_UPDATE_DATE)


