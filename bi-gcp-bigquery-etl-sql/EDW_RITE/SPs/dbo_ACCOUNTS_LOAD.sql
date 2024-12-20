CREATE PROC [DBO].[ACCOUNTS_LOAD] AS

-- EXEC EDW_RITE.DBO.ACCOUNTS_LOAD
/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.ACCOUNTS_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.ACCOUNTS_LOAD
GO

*/

DECLARE @LAST_UPDATE_DATE datetime2(2); 

EXEC dbo.GetLoadStartDatetime 'dbo.ACCOUNTS', @LAST_UPDATE_DATE OUTPUT
-- PRINT @LAST_UPDATE_DATE

IF OBJECT_ID('dbo.ACCOUNTS_STAGE')>0 	DROP TABLE dbo.ACCOUNTS_STAGE
	
CREATE TABLE dbo.ACCOUNTS_STAGE WITH (DISTRIBUTION = HASH(ACCT_ID), CLUSTERED INDEX (ACCT_ID ))
AS 
-- EXPLAIN
SELECT 
	ACCT_ID, 
    FIRST_NAME, 
    MIDDLE_INITIAL, 
    LAST_NAME, 
    ADDRESS1, 
    ADDRESS2, 
    CITY, 
    [STATE], 
    ZIP_CODE, 
    PLUS4, 
    HOME_PHO_NBR, 
    WORK_PHO_NBR, 
    WORK_PHO_EXT, 
    DRIVER_LIC_NBR, 
    DRIVER_LIC_STATE, 
    COMPANY_NAME, 
    COMPANY_TAX_ID, 
    EMAIL_ADDRESS, 
    --MO_STMT_FLAG, 
    BAD_ADDRESS_FLAG, 
    REBILL_FAILED_FLAG, 
    REBILL_AMT, 
    REBILL_DATE, 
    DEP_AMT, 
    BALANCE_AMT, 
    LOW_BAL_LEVEL, 
    BAL_LAST_UPDATED, 
    ACCT_STATUS_CODE, 
    ACCT_TYPE_CODE, 
    PMT_TYPE_CODE, 
    ADDRESS_MODIFIED, 
    DATE_CREATED, 
    CREATED_BY, 
    DATE_APPROVED, 
    APPROVED_BY, 
    DATE_MODIFIED, 
    MODIFIED_BY, 
    SELECTED_FOR_REBILL, 
    MS_ID, 
    VEA_FLAG, 
    VEA_DATE, 
    VEA_EXPIRE_DATE, 
    COMPANY_CODE, 
    ADJUST_REBILL_AMT, 
    CLOSE_OUT_STATUS, 
    CLOSE_OUT_DATE, 
    CLOSE_OUT_TYPE, 
    LAST_UPDATE_DATE, 
    LAST_UPDATE_TYPE
FROM LND_LG_TS.TAG_OWNER.ACCOUNTS A 
WHERE 
	A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
OPTION (LABEL = 'ACCOUNTS_LOAD: ACCOUNTS_STAGE');

CREATE STATISTICS STATS_ACCOUNTS_STAGE_001 ON ACCOUNTS_STAGE (ACCT_ID)

IF OBJECT_ID('dbo.ACCOUNTS_NEW_STAGE')>0 	DROP TABLE dbo.CA_ACCTS_NEW_STAGE

CREATE TABLE dbo.ACCOUNTS_NEW_STAGE WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(ACCT_ID)) AS    
SELECT	
	ACCT_ID,FIRST_NAME,MIDDLE_INITIAL,LAST_NAME,ADDRESS1,ADDRESS2,CITY,[STATE],ZIP_CODE,PLUS4,HOME_PHO_NBR,WORK_PHO_NBR,WORK_PHO_EXT,DRIVER_LIC_NBR,DRIVER_LIC_STATE,COMPANY_NAME,COMPANY_TAX_ID,EMAIL_ADDRESS, 
    BAD_ADDRESS_FLAG,REBILL_FAILED_FLAG,REBILL_AMT,REBILL_DATE,DEP_AMT,BALANCE_AMT,LOW_BAL_LEVEL,BAL_LAST_UPDATED,ACCT_STATUS_CODE,ACCT_TYPE_CODE,PMT_TYPE_CODE,ADDRESS_MODIFIED,DATE_CREATED,CREATED_BY, 
    DATE_APPROVED,APPROVED_BY,DATE_MODIFIED,MODIFIED_BY,SELECTED_FOR_REBILL,MS_ID,VEA_FLAG,VEA_DATE,VEA_EXPIRE_DATE,COMPANY_CODE,ADJUST_REBILL_AMT,CLOSE_OUT_STATUS,CLOSE_OUT_DATE,CLOSE_OUT_TYPE, 
    LAST_UPDATE_DATE,LAST_UPDATE_TYPE
FROM dbo.ACCOUNTS AS F 
WHERE	NOT EXISTS (SELECT 1 FROM dbo.ACCOUNTS_STAGE AS NSET WHERE NSET.ACCT_ID = F.ACCT_ID) 

  UNION ALL 
  
SELECT	
	ACCT_ID,FIRST_NAME,MIDDLE_INITIAL,LAST_NAME,ADDRESS1,ADDRESS2,CITY,[STATE],ZIP_CODE,PLUS4,HOME_PHO_NBR,WORK_PHO_NBR,WORK_PHO_EXT,DRIVER_LIC_NBR,DRIVER_LIC_STATE,COMPANY_NAME,COMPANY_TAX_ID,EMAIL_ADDRESS, 
    BAD_ADDRESS_FLAG,REBILL_FAILED_FLAG,REBILL_AMT,REBILL_DATE,DEP_AMT,BALANCE_AMT,LOW_BAL_LEVEL,BAL_LAST_UPDATED,ACCT_STATUS_CODE,ACCT_TYPE_CODE,PMT_TYPE_CODE,ADDRESS_MODIFIED,DATE_CREATED,CREATED_BY, 
    DATE_APPROVED,APPROVED_BY,DATE_MODIFIED,MODIFIED_BY,SELECTED_FOR_REBILL,MS_ID,VEA_FLAG,VEA_DATE,VEA_EXPIRE_DATE,COMPANY_CODE,ADJUST_REBILL_AMT,CLOSE_OUT_STATUS,CLOSE_OUT_DATE,CLOSE_OUT_TYPE, 
    LAST_UPDATE_DATE,LAST_UPDATE_TYPE
FROM dbo.ACCOUNTS_STAGE
OPTION (LABEL = 'ACCOUNTS_LOAD: INSERT/UPDATE');


IF OBJECT_ID('dbo.ACCOUNTS_OLD') IS NOT NULL 	DROP TABLE dbo.ACCOUNTS_OLD;
IF OBJECT_ID('dbo.ACCOUNTS') IS NOT NULL		RENAME OBJECT::dbo.ACCOUNTS TO ACCOUNTS_OLD;
RENAME OBJECT::dbo.ACCOUNTS_NEW_STAGE TO ACCOUNTS;
IF OBJECT_ID('dbo.ACCOUNTS_OLD') IS NOT NULL 	DROP TABLE dbo.ACCOUNTS_OLD;

CREATE STATISTICS [STATS_ACCOUNTS_001] ON [dbo].[ACCOUNTS] ([ACCT_ID]);
CREATE STATISTICS [STATS_ACCOUNTS_002] ON [dbo].[ACCOUNTS] ([LAST_UPDATE_DATE]);

IF OBJECT_ID('dbo.ACCOUNTS_STAGE')>0 	DROP TABLE dbo.ACCOUNTS_STAGE

---- GetUpdateFields 'dbo','ACCOUNTS'
---- EXPLAIN
--UPDATE DBO.ACCOUNTS
--SET   dbo.ACCOUNTS.FIRST_NAME			= B.FIRST_NAME 	
--    , dbo.ACCOUNTS.MIDDLE_INITIAL 		= B.MIDDLE_INITIAL 
--    , dbo.ACCOUNTS.LAST_NAME 			= B.LAST_NAME 
--    , dbo.ACCOUNTS.ADDRESS1 			= B.ADDRESS1 
--    , dbo.ACCOUNTS.ADDRESS2 			= B.ADDRESS2 
--    , dbo.ACCOUNTS.CITY				= B.CITY
--    , dbo.ACCOUNTS.STATE 				= B.STATE 
--    , dbo.ACCOUNTS.ZIP_CODE 			= B.ZIP_CODE 
--    , dbo.ACCOUNTS.PLUS4 				= B.PLUS4 
--    , dbo.ACCOUNTS.HOME_PHO_NBR		= B.HOME_PHO_NBR
--    , dbo.ACCOUNTS.WORK_PHO_NBR		= B.WORK_PHO_NBR
--    , dbo.ACCOUNTS.WORK_PHO_EXT		= B.WORK_PHO_EXT
--    , dbo.ACCOUNTS.DRIVER_LIC_NBR		= B.DRIVER_LIC_NBR
--    , dbo.ACCOUNTS.DRIVER_LIC_STATE	= B.DRIVER_LIC_STATE
--    , dbo.ACCOUNTS.COMPANY_NAME		= B.COMPANY_NAME
--    , dbo.ACCOUNTS.COMPANY_TAX_ID		= B.COMPANY_TAX_ID
--    , dbo.ACCOUNTS.EMAIL_ADDRESS		= B.EMAIL_ADDRESS
--    , dbo.ACCOUNTS.MO_STMT_FLAG 		= B.MO_STMT_FLAG 
--    , dbo.ACCOUNTS.BAD_ADDRESS_FLAG	= B.BAD_ADDRESS_FLAG
--    , dbo.ACCOUNTS.REBILL_FAILED_FLAG 	= B.REBILL_FAILED_FLAG 
--    , dbo.ACCOUNTS.REBILL_AMT 			= B.REBILL_AMT 
--    , dbo.ACCOUNTS.REBILL_DATE 		= B.REBILL_DATE 
--    , dbo.ACCOUNTS.DEP_AMT 			= B.DEP_AMT 
--    , dbo.ACCOUNTS.BALANCE_AMT			= B.BALANCE_AMT
--    , dbo.ACCOUNTS.LOW_BAL_LEVEL 		= B.LOW_BAL_LEVEL 
--    , dbo.ACCOUNTS.BAL_LAST_UPDATED 	= B.BAL_LAST_UPDATED 
--    , dbo.ACCOUNTS.ACCT_STATUS_CODE	= B.ACCT_STATUS_CODE
--    , dbo.ACCOUNTS.ACCT_TYPE_CODE 		= B.ACCT_TYPE_CODE 
--    , dbo.ACCOUNTS.PMT_TYPE_CODE 		= B.PMT_TYPE_CODE 
--    , dbo.ACCOUNTS.ADDRESS_MODIFIED 	= B.ADDRESS_MODIFIED 
--    , dbo.ACCOUNTS.DATE_CREATED 		= B.DATE_CREATED 
--    , dbo.ACCOUNTS.CREATED_BY 			= B.CREATED_BY 
--    , dbo.ACCOUNTS.DATE_APPROVED		= B.DATE_APPROVED
--    , dbo.ACCOUNTS.APPROVED_BY 		= B.APPROVED_BY 
--    , dbo.ACCOUNTS.DATE_MODIFIED 		= B.DATE_MODIFIED 
--    , dbo.ACCOUNTS.MODIFIED_BY 		= B.MODIFIED_BY 
--    , dbo.ACCOUNTS.SELECTED_FOR_REBILL = B.SELECTED_FOR_REBILL 
--    , dbo.ACCOUNTS.MS_ID 				= B.MS_ID 
--    , dbo.ACCOUNTS.VEA_FLAG 			= B.VEA_FLAG 
--    , dbo.ACCOUNTS.VEA_DATE 			= B.VEA_DATE 
--    , dbo.ACCOUNTS.VEA_EXPIRE_DATE		= B.VEA_EXPIRE_DATE
--    , dbo.ACCOUNTS.COMPANY_CODE 		= B.COMPANY_CODE 
--    , dbo.ACCOUNTS.ADJUST_REBILL_AMT 	= B.ADJUST_REBILL_AMT 
--    , dbo.ACCOUNTS.CLOSE_OUT_STATUS 	= B.CLOSE_OUT_STATUS 
--    , dbo.ACCOUNTS.CLOSE_OUT_DATE 		= B.CLOSE_OUT_DATE 
--    , dbo.ACCOUNTS.CLOSE_OUT_TYPE 		= B.CLOSE_OUT_TYPE 
--    , dbo.ACCOUNTS.LAST_UPDATE_DATE	= B.LAST_UPDATE_DATE
--    , dbo.ACCOUNTS.LAST_UPDATE_TYPE	= B.LAST_UPDATE_TYPE--SELECT *
--FROM dbo.ACCOUNTS_STAGE B
--WHERE 
--		dbo.ACCOUNTS.ACCT_ID = B.ACCT_ID 
----	AND B.LAST_UPDATE_TYPE = 'U'
--OPTION (LABEL = 'ACCOUNTS_LOAD: UPDATE ACCOUNTS');		

	 
---- GetFields 'ACCOUNTS'
---- EXPLAIN 
--INSERT INTO DBO.ACCOUNTS
--(
--	ACCT_ID, 
--    FIRST_NAME, 
--    MIDDLE_INITIAL, 
--    LAST_NAME, 
--    ADDRESS1, 
--    ADDRESS2, 
--    CITY, 
--    STATE, 
--    ZIP_CODE, 
--    PLUS4, 
--    HOME_PHO_NBR, 
--    WORK_PHO_NBR, 
--    WORK_PHO_EXT, 
--    DRIVER_LIC_NBR, 
--    DRIVER_LIC_STATE, 
--    COMPANY_NAME, 
--    COMPANY_TAX_ID, 
--    EMAIL_ADDRESS, 
--    MO_STMT_FLAG, 
--    BAD_ADDRESS_FLAG, 
--    REBILL_FAILED_FLAG, 
--    REBILL_AMT, 
--    REBILL_DATE, 
--    DEP_AMT, 
--    BALANCE_AMT, 
--    LOW_BAL_LEVEL, 
--    BAL_LAST_UPDATED, 
--    ACCT_STATUS_CODE, 
--    ACCT_TYPE_CODE, 
--    PMT_TYPE_CODE, 
--    ADDRESS_MODIFIED, 
--    DATE_CREATED, 
--    CREATED_BY, 
--    DATE_APPROVED, 
--    APPROVED_BY, 
--    DATE_MODIFIED, 
--    MODIFIED_BY, 
--    SELECTED_FOR_REBILL, 
--    MS_ID, 
--    VEA_FLAG, 
--    VEA_DATE, 
--    VEA_EXPIRE_DATE, 
--    COMPANY_CODE, 
--    ADJUST_REBILL_AMT, 
--    CLOSE_OUT_STATUS, 
--    CLOSE_OUT_DATE, 
--    CLOSE_OUT_TYPE, 
--    LAST_UPDATE_DATE, 
--    LAST_UPDATE_TYPE
--)
--SELECT 
--	A.ACCT_ID, 
--    A.FIRST_NAME, 
--    A.MIDDLE_INITIAL, 
--    A.LAST_NAME, 
--    A.ADDRESS1, 
--    A.ADDRESS2, 
--    A.CITY, 
--    A.STATE, 
--    A.ZIP_CODE, 
--    A.PLUS4, 
--    A.HOME_PHO_NBR, 
--    A.WORK_PHO_NBR, 
--    A.WORK_PHO_EXT, 
--    A.DRIVER_LIC_NBR, 
--    A.DRIVER_LIC_STATE, 
--    A.COMPANY_NAME, 
--    A.COMPANY_TAX_ID, 
--    A.EMAIL_ADDRESS, 
--    A.MO_STMT_FLAG, 
--    A.BAD_ADDRESS_FLAG, 
--    A.REBILL_FAILED_FLAG, 
--    A.REBILL_AMT, 
--    A.REBILL_DATE, 
--    A.DEP_AMT, 
--    A.BALANCE_AMT, 
--    A.LOW_BAL_LEVEL, 
--    A.BAL_LAST_UPDATED, 
--    A.ACCT_STATUS_CODE, 
--    A.ACCT_TYPE_CODE, 
--    A.PMT_TYPE_CODE, 
--    A.ADDRESS_MODIFIED, 
--    A.DATE_CREATED, 
--    A.CREATED_BY, 
--    A.DATE_APPROVED, 
--    A.APPROVED_BY, 
--    A.DATE_MODIFIED, 
--    A.MODIFIED_BY, 
--    A.SELECTED_FOR_REBILL, 
--    A.MS_ID, 
--    A.VEA_FLAG, 
--    A.VEA_DATE, 
--    A.VEA_EXPIRE_DATE, 
--    A.COMPANY_CODE, 
--    A.ADJUST_REBILL_AMT, 
--    A.CLOSE_OUT_STATUS, 
--    A.CLOSE_OUT_DATE, 
--    A.CLOSE_OUT_TYPE, 
--    A.LAST_UPDATE_DATE, 
--    A.LAST_UPDATE_TYPE
--FROM dbo.ACCOUNTS_STAGE A
--LEFT JOIN dbo.ACCOUNTS B 
--	ON		A.ACCT_ID = B.ACCT_ID 
--WHERE B.ACCT_ID IS NULL 
--OPTION (LABEL = 'ACCOUNTS_LOAD: INSERT ACCOUNTS');		

		--IF OBJECT_ID('dbo.ACCOUNTS')>0		RENAME OBJECT::dbo.ACCOUNTS TO ACCOUNTS_OLD;
		--IF OBJECT_ID('dbo.ACCOUNTS_STAGE')>0		RENAME OBJECT::dbo.ACCOUNTS_STAGE TO ACCOUNTS;
		--IF OBJECT_ID('dbo.ACCOUNTS_OLD')>0		DROP TABLE dbo.ACCOUNTS_OLD;

--GO


--SELECT ACCT_ID
--FROM edw_rite.dbo.ACCOUNTS
--GROUP BY ACCT_ID
--HAVING COUNT(*)>1





