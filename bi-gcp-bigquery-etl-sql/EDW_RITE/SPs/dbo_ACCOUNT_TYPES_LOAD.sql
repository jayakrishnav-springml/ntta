CREATE PROC [dbo].[ACCOUNT_TYPES_LOAD] AS

IF OBJECT_ID('dbo.ACCOUNT_TYPES_STAGE')<>0
	DROP TABLE dbo.ACCOUNT_TYPES_STAGE

CREATE TABLE dbo.ACCOUNT_TYPES_STAGE WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ACCT_TYPE_CODE)) 
AS 
SELECT ACCT_TYPE_CODE,ACCT_TYPE_DESCR, LAST_UPDATE_DATE
FROM [LND_LG_TS].[TAG_OWNER].[ACCOUNT_TYPES]
OPTION (LABEL = 'ACCOUNT_TYPES_LOAD: CTAS ACCOUNT_TYPES_STAGE');



UPDATE dbo.ACCOUNT_TYPES
SET ACCT_TYPE_DESCR = B.ACCT_TYPE_DESCR
	,LAST_UPDATE_DATE = B.LAST_UPDATE_DATE
FROM dbo.ACCOUNT_TYPES_STAGE B
WHERE 
	dbo.ACCOUNT_TYPES.ACCT_TYPE_CODE = B.ACCT_TYPE_CODE
	AND 
	dbo.ACCOUNT_TYPES.ACCT_TYPE_DESCR <> B.ACCT_TYPE_DESCR
OPTION (LABEL = 'ACCOUNT_TYPES_LOAD: UPDATE ACCOUNT_TYPES');

INSERT INTO dbo.ACCOUNT_TYPES (ACCT_TYPE_CODE, ACCT_TYPE_DESCR, INSERT_DATE, LAST_UPDATE_DATE)
SELECT A.ACCT_TYPE_CODE, A.ACCT_TYPE_DESCR, A.LAST_UPDATE_DATE, A.LAST_UPDATE_DATE
FROM dbo.ACCOUNT_TYPES_STAGE A
LEFT JOIN dbo.ACCOUNT_TYPES B ON A.ACCT_TYPE_CODE = B.ACCT_TYPE_CODE
WHERE B.ACCT_TYPE_CODE IS NULL
OPTION (LABEL = 'ACCOUNT_TYPES_LOAD: INSERT ACCOUNT_TYPES');



