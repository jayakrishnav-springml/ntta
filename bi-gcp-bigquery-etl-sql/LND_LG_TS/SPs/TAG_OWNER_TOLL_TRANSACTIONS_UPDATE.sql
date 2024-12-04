CREATE PROC [TAG_OWNER].[TOLL_TRANSACTIONS_UPDATE] AS

/*
	Use this proc to help write the code
		GetUpdateFields 'TAG_OWNER','TOLL_TRANSACTIONS'
		You will have to remove the Distribution key from what it generates
*/

/*
	Update Stats on CT_UPD table to help with de-dupping and update steps
*/

EXEC DropStats 'TAG_OWNER','TOLL_TRANSACTIONS_CT_UPD'
CREATE STATISTICS STATS_TOLL_TRANSACTIONS_CT_UPD_001 ON TAG_OWNER.TOLL_TRANSACTIONS_CT_UPD (TTXN_ID)
CREATE STATISTICS STATS_TOLL_TRANSACTIONS_CT_UPD_002 ON TAG_OWNER.TOLL_TRANSACTIONS_CT_UPD (TTXN_ID, INSERT_DATETIME)


/*
	Get Duplicate Records with the INSERT_DATETIME from the CDC Staging 
*/
/*
IF OBJECT_ID('tempdb..#TOLL_TRANSACTIONS_CT_UPD_Dups')<>0
	DROP TABLE #TOLL_TRANSACTIONS_CT_UPD_Dups

CREATE TABLE #TOLL_TRANSACTIONS_CT_UPD_Dups WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (TTXN_ID, INSERT_DATETIME), LOCATION = USER_DB)
AS
	SELECT A.TTXN_ID, A.INSERT_DATETIME
	FROM TAG_OWNER.TOLL_TRANSACTIONS_CT_UPD A
	INNER JOIN 
		(
			SELECT TTXN_ID
			FROM TAG_OWNER.TOLL_TRANSACTIONS_CT_UPD
			GROUP BY TTXN_ID
			HAVING COUNT(*)>1
		) Dups ON A.TTXN_ID = Dups.TTXN_ID

/*
	Create temp table with Last Update 
*/

IF OBJECT_ID('tempdb..#TOLL_TRANSACTIONS_CT_UPD_DuplicateLastRowToReInsert')<>0
	DROP TABLE #TOLL_TRANSACTIONS_CT_UPD_DuplicateLastRowToReInsert

CREATE TABLE #TOLL_TRANSACTIONS_CT_UPD_DuplicateLastRowToReInsert WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (TTXN_ID), LOCATION = USER_DB)
AS
	SELECT A.TTXN_ID, A.AMOUNT, A.TRANSACTION_DATE, A.POSTED_DATE, A.SOURCE_CODE, A.SOURCE_TRXN_ID, A.CREDITED_FLAG, A.ACCT_ID, A.AGENCY_ID, A.TAG_ID, A.LANE_ID, A.DATE_CREDITED, A.VEHICLE_CLASS_CODE, A.ENTRY_DATE, A.ENTRY_LANE_ID, A.TRANS_TYPE_ID, A.VPN_ID, A.TRANSACTION_FILE_DETAIL_ID, A.TXN_MATCH_IDENTIFIER_CODE, A.INSERT_DATETIME
	FROM TAG_OWNER.TOLL_TRANSACTIONS_CT_UPD A
	INNER JOIN 
		(
			SELECT TTXN_ID, MAX(INSERT_DATETIME) AS LAST_INSERT_DATETIME
			FROM #TOLL_TRANSACTIONS_CT_UPD_Dups
			GROUP BY TTXN_ID
		) LastRcrd ON A.TTXN_ID = LastRcrd.TTXN_ID AND A.INSERT_DATETIME = LastRcrd.LAST_INSERT_DATETIME

/*
	DELETE all the duplicate rows from the target
*/

DELETE FROM TAG_OWNER.TOLL_TRANSACTIONS_CT_UPD 
WHERE EXISTS(SELECT * FROM #TOLL_TRANSACTIONS_CT_UPD_Dups B WHERE TAG_OWNER.TOLL_TRANSACTIONS_CT_UPD.TTXN_ID = B.TTXN_ID);


/*
	Re-insert the LAST ROW for Duplicates
*/
INSERT INTO TAG_OWNER.TOLL_TRANSACTIONS_CT_UPD 
	( TTXN_ID, AMOUNT, TRANSACTION_DATE, POSTED_DATE, SOURCE_CODE, SOURCE_TRXN_ID, CREDITED_FLAG, ACCT_ID, AGENCY_ID, TAG_ID, LANE_ID, DATE_CREDITED, VEHICLE_CLASS_CODE, ENTRY_DATE, ENTRY_LANE_ID, TRANS_TYPE_ID, VPN_ID, TRANSACTION_FILE_DETAIL_ID, TXN_MATCH_IDENTIFIER_CODE, INSERT_DATETIME)
SELECT TTXN_ID, AMOUNT, TRANSACTION_DATE, POSTED_DATE, SOURCE_CODE, SOURCE_TRXN_ID, CREDITED_FLAG, ACCT_ID, AGENCY_ID, TAG_ID, LANE_ID, DATE_CREDITED, VEHICLE_CLASS_CODE, ENTRY_DATE, ENTRY_LANE_ID, TRANS_TYPE_ID, VPN_ID, TRANSACTION_FILE_DETAIL_ID, TXN_MATCH_IDENTIFIER_CODE, INSERT_DATETIME
FROM #TOLL_TRANSACTIONS_CT_UPD_DuplicateLastRowToReInsert

*/
	UPDATE  TAG_OWNER.TOLL_TRANSACTIONS
	SET 
    
		  TAG_OWNER.TOLL_TRANSACTIONS.AMOUNT = B.AMOUNT
		, TAG_OWNER.TOLL_TRANSACTIONS.TRANSACTION_DATE = B.TRANSACTION_DATE
		, TAG_OWNER.TOLL_TRANSACTIONS.POSTED_DATE = B.POSTED_DATE
		, TAG_OWNER.TOLL_TRANSACTIONS.SOURCE_CODE = B.SOURCE_CODE
		, TAG_OWNER.TOLL_TRANSACTIONS.SOURCE_TRXN_ID = B.SOURCE_TRXN_ID
		, TAG_OWNER.TOLL_TRANSACTIONS.CREDITED_FLAG = B.CREDITED_FLAG
		, TAG_OWNER.TOLL_TRANSACTIONS.ACCT_ID = B.ACCT_ID
		, TAG_OWNER.TOLL_TRANSACTIONS.AGENCY_ID = B.AGENCY_ID
		, TAG_OWNER.TOLL_TRANSACTIONS.TAG_ID = B.TAG_ID
		, TAG_OWNER.TOLL_TRANSACTIONS.LANE_ID = B.LANE_ID
		, TAG_OWNER.TOLL_TRANSACTIONS.DATE_CREDITED = B.DATE_CREDITED
		, TAG_OWNER.TOLL_TRANSACTIONS.VEHICLE_CLASS_CODE = B.VEHICLE_CLASS_CODE
		, TAG_OWNER.TOLL_TRANSACTIONS.ENTRY_DATE = B.ENTRY_DATE
		, TAG_OWNER.TOLL_TRANSACTIONS.ENTRY_LANE_ID = B.ENTRY_LANE_ID
		, TAG_OWNER.TOLL_TRANSACTIONS.TRANS_TYPE_ID = B.TRANS_TYPE_ID
		, TAG_OWNER.TOLL_TRANSACTIONS.VPN_ID = B.VPN_ID
		, TAG_OWNER.TOLL_TRANSACTIONS.TRANSACTION_FILE_DETAIL_ID = B.TRANSACTION_FILE_DETAIL_ID
		, TAG_OWNER.TOLL_TRANSACTIONS.TXN_MATCH_IDENTIFIER_CODE = B.TXN_MATCH_IDENTIFIER_CODE
		, TAG_OWNER.TOLL_TRANSACTIONS.LAST_UPDATE_TYPE = 'U'
		, TAG_OWNER.TOLL_TRANSACTIONS.LAST_UPDATE_DATE = B.INSERT_DATETIME
	FROM TAG_OWNER.TOLL_TRANSACTIONS_CT_UPD B
	WHERE TAG_OWNER.TOLL_TRANSACTIONS.TTXN_ID = B.TTXN_ID


