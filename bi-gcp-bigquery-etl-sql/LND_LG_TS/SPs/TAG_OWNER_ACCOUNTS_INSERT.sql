CREATE PROC [TAG_OWNER].[ACCOUNTS_INSERT] AS

/*
	Update Stats on CT_INS table to help with de-dupping and update steps
	GetFields 'TAG_OWNER','ACCOUNTS'
	GetInsertFields2 'TAG_OWNER','ACCOUNTS'
*/

EXEC DropStats 'TAG_OWNER','ACCOUNTS_CT_INS'
CREATE STATISTICS STATS_ACCOUNTS_CT_INS_001 ON TAG_OWNER.ACCOUNTS_CT_INS (ACCT_ID)

INSERT INTO TAG_OWNER.ACCOUNTS
	(
		 ACCT_ID, FIRST_NAME, MIDDLE_INITIAL, LAST_NAME, ADDRESS1, ADDRESS2, CITY, STATE, ZIP_CODE, PLUS4, HOME_PHO_NBR, WORK_PHO_NBR, WORK_PHO_EXT, DRIVER_LIC_NBR, DRIVER_LIC_STATE, COMPANY_NAME, COMPANY_TAX_ID, EMAIL_ADDRESS, MO_STMT_FLAG, BAD_ADDRESS_FLAG, REBILL_FAILED_FLAG, REBILL_AMT, REBILL_DATE, DEP_AMT, BALANCE_AMT, LOW_BAL_LEVEL, BAL_LAST_UPDATED, ACCT_STATUS_CODE, ACCT_TYPE_CODE, PMT_TYPE_CODE, ADDRESS_MODIFIED, DATE_CREATED, CREATED_BY, DATE_APPROVED, APPROVED_BY, DATE_MODIFIED, MODIFIED_BY, SELECTED_FOR_REBILL, MS_ID, VEA_FLAG, VEA_DATE, VEA_EXPIRE_DATE, COMPANY_CODE, ADJUST_REBILL_AMT, CLOSE_OUT_STATUS, CLOSE_OUT_DATE, CLOSE_OUT_TYPE, 
		 LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	)
SELECT 
	  
 A.ACCT_ID, A.FIRST_NAME, A.MIDDLE_INITIAL, A.LAST_NAME, A.ADDRESS1, A.ADDRESS2, A.CITY, A.STATE, A.ZIP_CODE, A.PLUS4, A.HOME_PHO_NBR, A.WORK_PHO_NBR, A.WORK_PHO_EXT, A.DRIVER_LIC_NBR, A.DRIVER_LIC_STATE, A.COMPANY_NAME, A.COMPANY_TAX_ID, A.EMAIL_ADDRESS, A.MO_STMT_FLAG, A.BAD_ADDRESS_FLAG, A.REBILL_FAILED_FLAG, A.REBILL_AMT, A.REBILL_DATE, A.DEP_AMT, A.BALANCE_AMT, A.LOW_BAL_LEVEL, A.BAL_LAST_UPDATED, A.ACCT_STATUS_CODE, A.ACCT_TYPE_CODE, A.PMT_TYPE_CODE, A.ADDRESS_MODIFIED, A.DATE_CREATED, A.CREATED_BY, A.DATE_APPROVED, A.APPROVED_BY, A.DATE_MODIFIED, A.MODIFIED_BY, A.SELECTED_FOR_REBILL, A.MS_ID, A.VEA_FLAG, A.VEA_DATE, A.VEA_EXPIRE_DATE, A.COMPANY_CODE, A.ADJUST_REBILL_AMT, A.CLOSE_OUT_STATUS, A.CLOSE_OUT_DATE, A.CLOSE_OUT_TYPE,
 'I' AS LAST_UPDATE_TYPE, A.INSERT_DATETIME
FROM TAG_OWNER.ACCOUNTS_CT_INS A
LEFT JOIN TAG_OWNER.ACCOUNTS B ON A.ACCT_ID = B.ACCT_ID
WHERE B.ACCT_ID IS NULL


