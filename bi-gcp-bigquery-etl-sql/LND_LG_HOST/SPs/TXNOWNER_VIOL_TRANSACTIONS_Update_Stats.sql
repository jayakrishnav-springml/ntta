CREATE PROC [TXNOWNER].[VIOL_TRANSACTIONS_Update_Stats] AS    
--EXEC DropStats 'TXNOWNER','VIOL_TRANSACTIONS'  
--CREATE STATISTICS STATS_VIOL_TRANSACTIONS_001 ON TXNOWNER.VIOL_TRANSACTIONS (TRANS_REC_ID)  
--CREATE STATISTICS STATS_VIOL_TRANSACTIONS_002 ON TXNOWNER.VIOL_TRANSACTIONS (TRANS_REC_ID, LAST_UPDATE_DATE)  
--CREATE STATISTICS STATS_VIOL_TRANSACTIONS_003 ON TXNOWNER.VIOL_TRANSACTIONS (LAST_UPDATE_DATE)
	 UPDATE STATISTICS TXNOWNER.VIOL_TRANSACTIONS

