CREATE PROC [TAG_OWNER].[ACCOUNT_HISTORY_Update_Stats] AS

EXEC DropStats 'TAG_OWNER','ACCOUNT_HISTORY'
CREATE STATISTICS STATS_ACCOUNT_HISTORY_001 ON TAG_OWNER.ACCOUNT_HISTORY (ACCT_ID,ACCT_HIST_SEQ)
CREATE STATISTICS STATS_ACCOUNT_HISTORY_002 ON TAG_OWNER.ACCOUNT_HISTORY (ACCT_ID,ACCT_HIST_SEQ, LAST_UPDATE_DATE)
CREATE STATISTICS STATS_ACCOUNT_HISTORY_003 ON TAG_OWNER.ACCOUNT_HISTORY (LAST_UPDATE_DATE)


