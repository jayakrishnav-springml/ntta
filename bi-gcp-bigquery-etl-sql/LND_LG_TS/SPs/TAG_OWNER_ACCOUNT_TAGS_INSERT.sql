CREATE PROC [TAG_OWNER].[ACCOUNT_TAGS_INSERT] AS


/*
	Use this proc to help write the code
		GetUpdateFields 'TAG_OWNER','ACCOUNT_TAGS'
		You will have to remove the Distribution key from what it generates
*/

EXEC DropStats 'TAG_OWNER','ACCOUNT_TAGS_CT_INS'
CREATE STATISTICS STATS_ACCOUNT_TAGS_CT_INS_001 ON TAG_OWNER.ACCOUNT_TAGS_CT_INS (ACCT_ID, ACCT_TAG_SEQ)
CREATE STATISTICS STATS_ACCOUNT_TAGS_CT_INS_002 ON TAG_OWNER.ACCOUNT_TAGS_CT_INS (ACCT_ID, ACCT_TAG_SEQ, INSERT_DATETIME)


INSERT INTO TAG_OWNER.ACCOUNT_TAGS
	(
		    ACCT_TAG_SEQ, ACCT_ID, AGENCY_ID, TAG_ID, ACCT_TAG_STATUS, LIC_PLATE, LIC_STATE, LIC_PLATE_TAG, VEHICLE_DESCR, VEHICLE_MAKE, VEHICLE_MODEL, VEHICLE_YEAR, VEHICLE_COLOR, VEHICLE_CLASS_CODE, ASSIGNED_DATE, EXPIR_DATE, TAG_READ_CT, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, VPN_ID, UNIT_ID, TEMP_PLATE_FLAG, PLATE_EXPIR_DATE, DUP_LP_DATE_SEND
		  , LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	)
SELECT A.ACCT_TAG_SEQ, A.ACCT_ID, A.AGENCY_ID, A.TAG_ID, A.ACCT_TAG_STATUS, A.LIC_PLATE, A.LIC_STATE, A.LIC_PLATE_TAG, A.VEHICLE_DESCR, A.VEHICLE_MAKE, A.VEHICLE_MODEL, A.VEHICLE_YEAR, A.VEHICLE_COLOR, A.VEHICLE_CLASS_CODE, A.ASSIGNED_DATE, A.EXPIR_DATE, A.TAG_READ_CT, A.DATE_CREATED, A.CREATED_BY, A.DATE_MODIFIED, A.MODIFIED_BY, A.VPN_ID, A.UNIT_ID, A.TEMP_PLATE_FLAG, A.PLATE_EXPIR_DATE, A.DUP_LP_DATE_SEND,
  'I' AS LAST_UPDATE_TYPE, A.INSERT_DATETIME
FROM TAG_OWNER.ACCOUNT_TAGS_CT_INS A
LEFT JOIN TAG_OWNER.ACCOUNT_TAGS B 
	ON A.ACCT_ID = B.ACCT_ID AND  A.ACCT_TAG_SEQ = B.ACCT_TAG_SEQ
WHERE B.ACCT_ID IS NULL AND B.ACCT_TAG_SEQ IS NULL



