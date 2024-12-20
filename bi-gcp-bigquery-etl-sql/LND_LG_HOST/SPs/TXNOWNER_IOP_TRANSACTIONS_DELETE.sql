CREATE PROC [TXNOWNER].[IOP_TRANSACTIONS_DELETE] AS

EXEC DropStats 'TXNOWNER','IOP_TRANSACTIONS_CT_DEL'
CREATE STATISTICS STATS_IOP_TRANSACTIONS_CT_DEL_001 ON TXNOWNER.IOP_TRANSACTIONS_CT_DEL (TRANSACTION_ID)
CREATE STATISTICS STATS_IOP_TRANSACTIONS_CT_DEL_002 ON TXNOWNER.IOP_TRANSACTIONS_CT_DEL (TRANSACTION_ID, INSERT_DATETIME)



UPDATE TXNOWNER.IOP_TRANSACTIONS
	SET  LAST_UPDATE_TYPE = 'D'
		, LAST_UPDATE_DATE = B.INSERT_DATETIME
FROM TXNOWNER.IOP_TRANSACTIONS_CT_DEL B
WHERE TXNOWNER.IOP_TRANSACTIONS.TRANSACTION_ID = B.TRANSACTION_ID AND TXNOWNER.IOP_TRANSACTIONS.SOURCE_CODE = B.SOURCE_CODE
