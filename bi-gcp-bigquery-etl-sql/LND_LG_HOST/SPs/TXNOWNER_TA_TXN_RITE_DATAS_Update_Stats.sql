CREATE PROC [TXNOWNER].[TA_TXN_RITE_DATAS_Update_Stats] AS    
--EXEC DropStats 'TXNOWNER','TA_TXN_RITE_DATAS'  
--CREATE STATISTICS STATS_TA_TXN_RITE_DATAS_001 ON TXNOWNER.TA_TXN_RITE_DATAS (TURD_ID)  
--CREATE STATISTICS STATS_TA_TXN_RITE_DATAS_002 ON TXNOWNER.TA_TXN_RITE_DATAS (TURD_ID, LAST_UPDATE_DATE)  
--CREATE STATISTICS STATS_TA_TXN_RITE_DATAS_003 ON TXNOWNER.TA_TXN_RITE_DATAS (LAST_UPDATE_DATE)
	 UPDATE STATISTICS TXNOWNER.TA_TXN_RITE_DATAS

