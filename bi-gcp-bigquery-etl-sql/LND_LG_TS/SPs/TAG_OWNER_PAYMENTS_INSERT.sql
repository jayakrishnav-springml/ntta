CREATE PROC [TAG_OWNER].[PAYMENTS_INSERT] AS

/*
	Update Stats on CT_INS table to help with de-dupping and update steps
	GetFields 'TAG_OWNER','PAYMENTS'
	GetInsertFields2 'TAG_OWNER','PAYMENTS'
*/

EXEC DropStats 'TAG_OWNER','PAYMENTS_CT_INS'
CREATE STATISTICS STATS_PAYMENTS_CT_INS_001 ON TAG_OWNER.PAYMENTS_CT_INS (RETAIL_TRANS_ID,PMT_ID)

INSERT INTO TAG_OWNER.PAYMENTS
	(
		  RETAIL_TRANS_ID, PMT_ID, PT_TYPE_ID, NAME, PMT_AMOUNT, PMT_DATE, PMT_STATUS, CREDIT_SOURCE, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, CHECK_NUMBER, CREDITED_FLAG, ZIP, SESSION_DATA, DATA2, ADDRESS1, ADDRESS2, SUPERVISOR_AP_USER_ID, PMT_REV_RETAIL_TRANS_ID, PMT_REV_PT_TYPE_ID, REVERSED_BY, 
		 LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	)
SELECT 
	  
  A.RETAIL_TRANS_ID, A.PMT_ID, A.PT_TYPE_ID, A.NAME, A.PMT_AMOUNT, A.PMT_DATE, A.PMT_STATUS, A.CREDIT_SOURCE, A.DATE_CREATED, A.CREATED_BY, A.DATE_MODIFIED, A.MODIFIED_BY, A.CHECK_NUMBER, A.CREDITED_FLAG, A.ZIP, A.SESSION_DATA, A.DATA2, A.ADDRESS1, A.ADDRESS2, A.SUPERVISOR_AP_USER_ID, A.PMT_REV_RETAIL_TRANS_ID, A.PMT_REV_PT_TYPE_ID, A.REVERSED_BY,
 'I' AS LAST_UPDATE_TYPE, A.INSERT_DATETIME
FROM TAG_OWNER.PAYMENTS_CT_INS A
LEFT JOIN TAG_OWNER.PAYMENTS B ON A.RETAIL_TRANS_ID = B.RETAIL_TRANS_ID AND  A.PMT_ID = B.PMT_ID
WHERE B.RETAIL_TRANS_ID IS NULL AND B.PMT_ID IS NULL


