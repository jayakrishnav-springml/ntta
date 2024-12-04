CREATE PROC [DBO].[TOLL_TRANSACTIONS_COMBINE_INIT_LOAD] AS 

TRUNCATE TABLE TAG_OWNER.TOLL_TRANSACTIONS
-- GetFields 'TOLL_TRANSACTIONS'

INSERT INTO TAG_OWNER.TOLL_TRANSACTIONS
( TTXN_ID, AMOUNT, TRANSACTION_DATE, POSTED_DATE, SOURCE_CODE, SOURCE_TRXN_ID, CREDITED_FLAG, ACCT_ID, AGENCY_ID
	, TAG_ID, LANE_ID, DATE_CREDITED, VEHICLE_CLASS_CODE, ENTRY_DATE, ENTRY_LANE_ID, TRANS_TYPE_ID, VPN_ID, TRANSACTION_FILE_DETAIL_ID, TXN_MATCH_IDENTIFIER_CODE, LAST_UPDATE_TYPE, LAST_UPDATE_DATE)
SELECT  TTXN_ID, AMOUNT, TRANSACTION_DATE, POSTED_DATE, SOURCE_CODE, SOURCE_TRXN_ID, CREDITED_FLAG, ACCT_ID, AGENCY_ID
	, ISNULL(TAG_ID,(TTXN_ID%100000)*-1) AS TAG_ID, LANE_ID, DATE_CREDITED, VEHICLE_CLASS_CODE, ENTRY_DATE, ENTRY_LANE_ID, TRANS_TYPE_ID, VPN_ID, TRANSACTION_FILE_DETAIL_ID, TXN_MATCH_IDENTIFIER_CODE, LAST_UPDATE_TYPE, LAST_UPDATE_DATE 
FROM 
(
	--SELECT  TTXN_ID, AMOUNT, TRANSACTION_DATE, POSTED_DATE, SOURCE_CODE, SOURCE_TRXN_ID, CREDITED_FLAG, ACCT_ID, AGENCY_ID, TAG_ID, LANE_ID, DATE_CREDITED, VEHICLE_CLASS_CODE, ENTRY_DATE, ENTRY_LANE_ID, TRANS_TYPE_ID, VPN_ID, TRANSACTION_FILE_DETAIL_ID, TXN_MATCH_IDENTIFIER_CODE, LAST_UPDATE_TYPE, LAST_UPDATE_DATE 
	--FROM TAG_OWNER.TOLL_TRANSACTIONS_2007
	--UNION ALL
	--SELECT  TTXN_ID, AMOUNT, TRANSACTION_DATE, POSTED_DATE, SOURCE_CODE, SOURCE_TRXN_ID, CREDITED_FLAG, ACCT_ID, AGENCY_ID, TAG_ID, LANE_ID, DATE_CREDITED, VEHICLE_CLASS_CODE, ENTRY_DATE, ENTRY_LANE_ID, TRANS_TYPE_ID, VPN_ID, TRANSACTION_FILE_DETAIL_ID, TXN_MATCH_IDENTIFIER_CODE, LAST_UPDATE_TYPE, LAST_UPDATE_DATE 
	--FROM TAG_OWNER.TOLL_TRANSACTIONS_2008
	--UNION ALL
	--SELECT  TTXN_ID, AMOUNT, TRANSACTION_DATE, POSTED_DATE, SOURCE_CODE, SOURCE_TRXN_ID, CREDITED_FLAG, ACCT_ID, AGENCY_ID, TAG_ID, LANE_ID, DATE_CREDITED, VEHICLE_CLASS_CODE, ENTRY_DATE, ENTRY_LANE_ID, TRANS_TYPE_ID, VPN_ID, TRANSACTION_FILE_DETAIL_ID, TXN_MATCH_IDENTIFIER_CODE, LAST_UPDATE_TYPE, LAST_UPDATE_DATE 
	--FROM TAG_OWNER.TOLL_TRANSACTIONS_2009
	--UNION ALL
	--SELECT  TTXN_ID, AMOUNT, TRANSACTION_DATE, POSTED_DATE, SOURCE_CODE, SOURCE_TRXN_ID, CREDITED_FLAG, ACCT_ID, AGENCY_ID, TAG_ID, LANE_ID, DATE_CREDITED, VEHICLE_CLASS_CODE, ENTRY_DATE, ENTRY_LANE_ID, TRANS_TYPE_ID, VPN_ID, TRANSACTION_FILE_DETAIL_ID, TXN_MATCH_IDENTIFIER_CODE, LAST_UPDATE_TYPE, LAST_UPDATE_DATE 
	--FROM TAG_OWNER.TOLL_TRANSACTIONS_2010
	--UNION ALL
	SELECT  TTXN_ID, AMOUNT, TRANSACTION_DATE, POSTED_DATE, SOURCE_CODE, SOURCE_TRXN_ID, CREDITED_FLAG, ACCT_ID, AGENCY_ID, TAG_ID, LANE_ID, DATE_CREDITED, VEHICLE_CLASS_CODE, ENTRY_DATE, ENTRY_LANE_ID, TRANS_TYPE_ID, VPN_ID, TRANSACTION_FILE_DETAIL_ID, TXN_MATCH_IDENTIFIER_CODE, LAST_UPDATE_TYPE, LAST_UPDATE_DATE 
	FROM TAG_OWNER.TOLL_TRANSACTIONS_2011
	UNION ALL
	SELECT  TTXN_ID, AMOUNT, TRANSACTION_DATE, POSTED_DATE, SOURCE_CODE, SOURCE_TRXN_ID, CREDITED_FLAG, ACCT_ID, AGENCY_ID, TAG_ID, LANE_ID, DATE_CREDITED, VEHICLE_CLASS_CODE, ENTRY_DATE, ENTRY_LANE_ID, TRANS_TYPE_ID, VPN_ID, TRANSACTION_FILE_DETAIL_ID, TXN_MATCH_IDENTIFIER_CODE, LAST_UPDATE_TYPE, LAST_UPDATE_DATE 
	FROM TAG_OWNER.TOLL_TRANSACTIONS_2012
	UNION ALL
	SELECT  TTXN_ID, AMOUNT, TRANSACTION_DATE, POSTED_DATE, SOURCE_CODE, SOURCE_TRXN_ID, CREDITED_FLAG, ACCT_ID, AGENCY_ID, TAG_ID, LANE_ID, DATE_CREDITED, VEHICLE_CLASS_CODE, ENTRY_DATE, ENTRY_LANE_ID, TRANS_TYPE_ID, VPN_ID, TRANSACTION_FILE_DETAIL_ID, TXN_MATCH_IDENTIFIER_CODE, LAST_UPDATE_TYPE, LAST_UPDATE_DATE 
	FROM TAG_OWNER.TOLL_TRANSACTIONS_2013
	UNION ALL
	SELECT  TTXN_ID, AMOUNT, TRANSACTION_DATE, POSTED_DATE, SOURCE_CODE, SOURCE_TRXN_ID, CREDITED_FLAG, ACCT_ID, AGENCY_ID, TAG_ID, LANE_ID, DATE_CREDITED, VEHICLE_CLASS_CODE, ENTRY_DATE, ENTRY_LANE_ID, TRANS_TYPE_ID, VPN_ID, TRANSACTION_FILE_DETAIL_ID, TXN_MATCH_IDENTIFIER_CODE, LAST_UPDATE_TYPE, LAST_UPDATE_DATE 
	FROM TAG_OWNER.TOLL_TRANSACTIONS_2014
	UNION ALL
	SELECT  TTXN_ID, AMOUNT, TRANSACTION_DATE, POSTED_DATE, SOURCE_CODE, SOURCE_TRXN_ID, CREDITED_FLAG, ACCT_ID, AGENCY_ID, TAG_ID, LANE_ID, DATE_CREDITED, VEHICLE_CLASS_CODE, ENTRY_DATE, ENTRY_LANE_ID, TRANS_TYPE_ID, VPN_ID, TRANSACTION_FILE_DETAIL_ID, TXN_MATCH_IDENTIFIER_CODE, LAST_UPDATE_TYPE, LAST_UPDATE_DATE 
	FROM TAG_OWNER.TOLL_TRANSACTIONS_2015
	--UNION ALL
	--SELECT  TTXN_ID, AMOUNT, TRANSACTION_DATE, POSTED_DATE, SOURCE_CODE, SOURCE_TRXN_ID, CREDITED_FLAG, ACCT_ID, AGENCY_ID, TAG_ID, LANE_ID, DATE_CREDITED, VEHICLE_CLASS_CODE, ENTRY_DATE, ENTRY_LANE_ID, TRANS_TYPE_ID, VPN_ID, TRANSACTION_FILE_DETAIL_ID, TXN_MATCH_IDENTIFIER_CODE, LAST_UPDATE_TYPE, LAST_UPDATE_DATE 
	--FROM TAG_OWNER.TOLL_TRANSACTIONS_PRE_2007
) SUBQuery
OPTION (LABEL = 'TOLL_TRANSACTIONS_COMBINE_INIT_LOAD: AG_OWNER.TOLL_TRANSACTIONS');



