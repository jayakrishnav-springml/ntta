CREATE PROC [TAG_OWNER].[ACCOUNT_HISTORY_UPDATE] AS

/*
	Use this proc to help write the code
		GetUpdateFields 'TAG_OWNER','ACCOUNT_HISTORY'
		You will have to remove the Distribution key from what it generates
*/

/*
	Update Stats on CT_UPD table to help with de-dupping and update steps
*/

EXEC DropStats 'TAG_OWNER','ACCOUNT_HISTORY_CT_UPD'
CREATE STATISTICS STATS_ACCOUNT_HISTORY_CT_UPD_001 ON TAG_OWNER.ACCOUNT_HISTORY_CT_UPD (ACCT_ID,ACCT_HIST_SEQ)
CREATE STATISTICS STATS_ACCOUNT_HISTORY_CT_UPD_002 ON TAG_OWNER.ACCOUNT_HISTORY_CT_UPD (ACCT_ID,ACCT_HIST_SEQ, INSERT_DATETIME)


/*
	Get Duplicate Records with the INSERT_DATETIME from the CDC Staging 
*/

IF OBJECT_ID('tempdb..#ACCOUNT_HISTORY_CT_UPD_Dups')<>0
	DROP TABLE #ACCOUNT_HISTORY_CT_UPD_Dups

CREATE TABLE #ACCOUNT_HISTORY_CT_UPD_Dups WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ACCT_ID,ACCT_HIST_SEQ, INSERT_DATETIME), LOCATION = USER_DB)
AS
	SELECT A.ACCT_ID, A.ACCT_HIST_SEQ, A.INSERT_DATETIME
	FROM TAG_OWNER.ACCOUNT_HISTORY_CT_UPD A
	INNER JOIN 
		(
			SELECT ACCT_ID,ACCT_HIST_SEQ
			FROM TAG_OWNER.ACCOUNT_HISTORY_CT_UPD
			GROUP BY ACCT_ID,ACCT_HIST_SEQ
			HAVING COUNT(*)>1
		) Dups ON A.ACCT_ID = Dups.ACCT_ID AND A.ACCT_HIST_SEQ = Dups.ACCT_HIST_SEQ

/*
	Create temp table with Last Update 
*/

IF OBJECT_ID('tempdb..#ACCOUNT_HISTORY_CT_UPD_DuplicateLastRowToReInsert')<>0
	DROP TABLE #ACCOUNT_HISTORY_CT_UPD_DuplicateLastRowToReInsert

CREATE TABLE #ACCOUNT_HISTORY_CT_UPD_DuplicateLastRowToReInsert WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ACCT_ID,ACCT_HIST_SEQ), LOCATION = USER_DB)
AS
	SELECT A.ACCT_ID, A.ACCT_HIST_SEQ, A.ASSIGNED_DATE, A.EXPIRED_DATE, A.FIRST_NAME, A.MIDDLE_INITIAL, A.LAST_NAME, A.ADDRESS1, A.ADDRESS2, A.CITY, A.STATE, A.ZIP_CODE, A.PLUS4, A.HOME_PHO_NBR, A.WORK_PHO_NBR, A.WORK_PHO_EXT, A.DRIVER_LIC_NBR, A.DRIVER_LIC_STATE, A.COMPANY_NAME, A.COMPANY_TAX_ID, A.EMAIL_ADDRESS, A.MO_STMT_FLAG, A.BAD_ADDRESS_FLAG, A.REBILL_FAILED_FLAG, A.REBILL_AMT, A.REBILL_DATE, A.DEP_AMT, A.BALANCE_AMT, A.LOW_BAL_LEVEL, A.BAL_LAST_UPDATED, A.ACCT_STATUS_CODE, A.ACCT_TYPE_CODE, A.PMT_TYPE_CODE, A.ADDRESS_MODIFIED, A.DATE_CREATED, A.CREATED_BY, A.DATE_APPROVED, A.APPROVED_BY, A.DATE_MODIFIED, A.MODIFIED_BY, A.MS_ID, A.SELECTED_FOR_REBILL, A.VEA_FLAG, A.VEA_DATE, A.VEA_EXPIRE_DATE, A.COMPANY_CODE, A.ADJUST_REBILL_AMT, A.INSERT_DATETIME
	FROM TAG_OWNER.ACCOUNT_HISTORY_CT_UPD A
	INNER JOIN 
		(
			SELECT ACCT_ID, ACCT_HIST_SEQ, MAX(INSERT_DATETIME) AS LAST_INSERT_DATETIME
			FROM #ACCOUNT_HISTORY_CT_UPD_Dups
			GROUP BY ACCT_ID, ACCT_HIST_SEQ
		) LastRcrd ON A.ACCT_ID = LastRcrd.ACCT_ID AND A.ACCT_HIST_SEQ = LastRcrd.ACCT_HIST_SEQ AND A.INSERT_DATETIME = LastRcrd.LAST_INSERT_DATETIME

/*
	DELETE all the duplicate rows from the target
*/

DELETE FROM TAG_OWNER.ACCOUNT_HISTORY_CT_UPD 
WHERE EXISTS(SELECT * FROM #ACCOUNT_HISTORY_CT_UPD_Dups B WHERE TAG_OWNER.ACCOUNT_HISTORY_CT_UPD.ACCT_ID = B.ACCT_ID AND TAG_OWNER.ACCOUNT_HISTORY_CT_UPD.ACCT_HIST_SEQ = B.ACCT_HIST_SEQ);


/*
	Re-insert the LAST ROW for Duplicates
*/
INSERT INTO TAG_OWNER.ACCOUNT_HISTORY_CT_UPD 
	( ACCT_ID, ACCT_HIST_SEQ, ASSIGNED_DATE, EXPIRED_DATE, FIRST_NAME, MIDDLE_INITIAL, LAST_NAME, ADDRESS1, ADDRESS2, CITY, STATE, ZIP_CODE, PLUS4, HOME_PHO_NBR, WORK_PHO_NBR, WORK_PHO_EXT, DRIVER_LIC_NBR, DRIVER_LIC_STATE, COMPANY_NAME, COMPANY_TAX_ID, EMAIL_ADDRESS, MO_STMT_FLAG, BAD_ADDRESS_FLAG, REBILL_FAILED_FLAG, REBILL_AMT, REBILL_DATE, DEP_AMT, BALANCE_AMT, LOW_BAL_LEVEL, BAL_LAST_UPDATED, ACCT_STATUS_CODE, ACCT_TYPE_CODE, PMT_TYPE_CODE, ADDRESS_MODIFIED, DATE_CREATED, CREATED_BY, DATE_APPROVED, APPROVED_BY, DATE_MODIFIED, MODIFIED_BY, MS_ID, SELECTED_FOR_REBILL, VEA_FLAG, VEA_DATE, VEA_EXPIRE_DATE, COMPANY_CODE, ADJUST_REBILL_AMT, INSERT_DATETIME)
SELECT ACCT_ID, ACCT_HIST_SEQ, ASSIGNED_DATE, EXPIRED_DATE, FIRST_NAME, MIDDLE_INITIAL, LAST_NAME, ADDRESS1, ADDRESS2, CITY, STATE, ZIP_CODE, PLUS4, HOME_PHO_NBR, WORK_PHO_NBR, WORK_PHO_EXT, DRIVER_LIC_NBR, DRIVER_LIC_STATE, COMPANY_NAME, COMPANY_TAX_ID, EMAIL_ADDRESS, MO_STMT_FLAG, BAD_ADDRESS_FLAG, REBILL_FAILED_FLAG, REBILL_AMT, REBILL_DATE, DEP_AMT, BALANCE_AMT, LOW_BAL_LEVEL, BAL_LAST_UPDATED, ACCT_STATUS_CODE, ACCT_TYPE_CODE, PMT_TYPE_CODE, ADDRESS_MODIFIED, DATE_CREATED, CREATED_BY, DATE_APPROVED, APPROVED_BY, DATE_MODIFIED, MODIFIED_BY, MS_ID, SELECTED_FOR_REBILL, VEA_FLAG, VEA_DATE, VEA_EXPIRE_DATE, COMPANY_CODE, ADJUST_REBILL_AMT, INSERT_DATETIME
FROM #ACCOUNT_HISTORY_CT_UPD_DuplicateLastRowToReInsert


	UPDATE  TAG_OWNER.ACCOUNT_HISTORY
	SET 
    
		  TAG_OWNER.ACCOUNT_HISTORY.ASSIGNED_DATE = B.ASSIGNED_DATE
		, TAG_OWNER.ACCOUNT_HISTORY.EXPIRED_DATE = B.EXPIRED_DATE
		, TAG_OWNER.ACCOUNT_HISTORY.FIRST_NAME = B.FIRST_NAME
		, TAG_OWNER.ACCOUNT_HISTORY.MIDDLE_INITIAL = B.MIDDLE_INITIAL
		, TAG_OWNER.ACCOUNT_HISTORY.LAST_NAME = B.LAST_NAME
		, TAG_OWNER.ACCOUNT_HISTORY.ADDRESS1 = B.ADDRESS1
		, TAG_OWNER.ACCOUNT_HISTORY.ADDRESS2 = B.ADDRESS2
		, TAG_OWNER.ACCOUNT_HISTORY.CITY = B.CITY
		, TAG_OWNER.ACCOUNT_HISTORY.STATE = B.STATE
		, TAG_OWNER.ACCOUNT_HISTORY.ZIP_CODE = B.ZIP_CODE
		, TAG_OWNER.ACCOUNT_HISTORY.PLUS4 = B.PLUS4
		, TAG_OWNER.ACCOUNT_HISTORY.HOME_PHO_NBR = B.HOME_PHO_NBR
		, TAG_OWNER.ACCOUNT_HISTORY.WORK_PHO_NBR = B.WORK_PHO_NBR
		, TAG_OWNER.ACCOUNT_HISTORY.WORK_PHO_EXT = B.WORK_PHO_EXT
		, TAG_OWNER.ACCOUNT_HISTORY.DRIVER_LIC_NBR = B.DRIVER_LIC_NBR
		, TAG_OWNER.ACCOUNT_HISTORY.DRIVER_LIC_STATE = B.DRIVER_LIC_STATE
		, TAG_OWNER.ACCOUNT_HISTORY.COMPANY_NAME = B.COMPANY_NAME
		, TAG_OWNER.ACCOUNT_HISTORY.COMPANY_TAX_ID = B.COMPANY_TAX_ID
		, TAG_OWNER.ACCOUNT_HISTORY.EMAIL_ADDRESS = B.EMAIL_ADDRESS
		, TAG_OWNER.ACCOUNT_HISTORY.MO_STMT_FLAG = B.MO_STMT_FLAG
		, TAG_OWNER.ACCOUNT_HISTORY.BAD_ADDRESS_FLAG = B.BAD_ADDRESS_FLAG
		, TAG_OWNER.ACCOUNT_HISTORY.REBILL_FAILED_FLAG = B.REBILL_FAILED_FLAG
		, TAG_OWNER.ACCOUNT_HISTORY.REBILL_AMT = B.REBILL_AMT
		, TAG_OWNER.ACCOUNT_HISTORY.REBILL_DATE = B.REBILL_DATE
		, TAG_OWNER.ACCOUNT_HISTORY.DEP_AMT = B.DEP_AMT
		, TAG_OWNER.ACCOUNT_HISTORY.BALANCE_AMT = B.BALANCE_AMT
		, TAG_OWNER.ACCOUNT_HISTORY.LOW_BAL_LEVEL = B.LOW_BAL_LEVEL
		, TAG_OWNER.ACCOUNT_HISTORY.BAL_LAST_UPDATED = B.BAL_LAST_UPDATED
		, TAG_OWNER.ACCOUNT_HISTORY.ACCT_STATUS_CODE = B.ACCT_STATUS_CODE
		, TAG_OWNER.ACCOUNT_HISTORY.ACCT_TYPE_CODE = B.ACCT_TYPE_CODE
		, TAG_OWNER.ACCOUNT_HISTORY.PMT_TYPE_CODE = B.PMT_TYPE_CODE
		, TAG_OWNER.ACCOUNT_HISTORY.ADDRESS_MODIFIED = B.ADDRESS_MODIFIED
		, TAG_OWNER.ACCOUNT_HISTORY.DATE_CREATED = B.DATE_CREATED
		, TAG_OWNER.ACCOUNT_HISTORY.CREATED_BY = B.CREATED_BY
		, TAG_OWNER.ACCOUNT_HISTORY.DATE_APPROVED = B.DATE_APPROVED
		, TAG_OWNER.ACCOUNT_HISTORY.APPROVED_BY = B.APPROVED_BY
		, TAG_OWNER.ACCOUNT_HISTORY.DATE_MODIFIED = B.DATE_MODIFIED
		, TAG_OWNER.ACCOUNT_HISTORY.MODIFIED_BY = B.MODIFIED_BY
		, TAG_OWNER.ACCOUNT_HISTORY.MS_ID = B.MS_ID
		, TAG_OWNER.ACCOUNT_HISTORY.SELECTED_FOR_REBILL = B.SELECTED_FOR_REBILL
		, TAG_OWNER.ACCOUNT_HISTORY.VEA_FLAG = B.VEA_FLAG
		, TAG_OWNER.ACCOUNT_HISTORY.VEA_DATE = B.VEA_DATE
		, TAG_OWNER.ACCOUNT_HISTORY.VEA_EXPIRE_DATE = B.VEA_EXPIRE_DATE
		, TAG_OWNER.ACCOUNT_HISTORY.COMPANY_CODE = B.COMPANY_CODE
		, TAG_OWNER.ACCOUNT_HISTORY.ADJUST_REBILL_AMT = B.ADJUST_REBILL_AMT
		, TAG_OWNER.ACCOUNT_HISTORY.LAST_UPDATE_TYPE = 'U'
		, TAG_OWNER.ACCOUNT_HISTORY.LAST_UPDATE_DATE = B.INSERT_DATETIME
	FROM TAG_OWNER.ACCOUNT_HISTORY_CT_UPD B
	WHERE TAG_OWNER.ACCOUNT_HISTORY.ACCT_ID = B.ACCT_ID AND TAG_OWNER.ACCOUNT_HISTORY.ACCT_HIST_SEQ = B.ACCT_HIST_SEQ



