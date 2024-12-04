CREATE PROC [TSA_OWNER].[TRANSACTION_FILE_DETAILS_DELETE] AS


EXEC DropStats 'TSA_OWNER','TRANSACTION_FILE_DETAILS_CT_DEL'
CREATE STATISTICS STATS_TRANSACTION_FILE_DETAILS_CT_DEL_001 ON TSA_OWNER.TRANSACTION_FILE_DETAILS_CT_DEL (TRANSACTION_FILE_DETAIL_ID)
CREATE STATISTICS STATS_TRANSACTION_FILE_DETAILS_CT_DEL_002 ON TSA_OWNER.TRANSACTION_FILE_DETAILS_CT_DEL (TRANSACTION_FILE_DETAIL_ID, INSERT_DATETIME)



UPDATE TSA_OWNER.TRANSACTION_FILE_DETAILS
	SET  LAST_UPDATE_TYPE = 'D'
		, LAST_UPDATE_DATE = B.INSERT_DATETIME
FROM TSA_OWNER.TRANSACTION_FILE_DETAILS_CT_DEL B
WHERE TSA_OWNER.TRANSACTION_FILE_DETAILS.TRANSACTION_FILE_DETAIL_ID = B.TRANSACTION_FILE_DETAIL_ID
