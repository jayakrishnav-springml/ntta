CREATE PROC [TAG_OWNER].[ACCOUNT_DEVICES_UPDATE] AS

/*
	Use this proc to help write the code
		GetUpdateFields 'TAG_OWNER','ACCOUNT_DEVICES'
		You will have to remove the Distribution key from what it generates
*/

/*
	Update Stats on CT_UPD table to help with de-dupping and update steps
*/

EXEC DropStats 'TAG_OWNER','ACCOUNT_DEVICES_CT_UPD'
CREATE STATISTICS STATS_ACCOUNT_DEVICES_CT_UPD_001 ON TAG_OWNER.ACCOUNT_DEVICES_CT_UPD (ACCT_DEVICE_ID)
CREATE STATISTICS STATS_ACCOUNT_DEVICES_CT_UPD_002 ON TAG_OWNER.ACCOUNT_DEVICES_CT_UPD (ACCT_DEVICE_ID, INSERT_DATETIME)


/*
	Get Duplicate Records with the INSERT_DATETIME from the CDC Staging 
*/

IF OBJECT_ID('tempdb..#ACCOUNT_DEVICES_CT_UPD_Dups')<>0
	DROP TABLE #ACCOUNT_DEVICES_CT_UPD_Dups

CREATE TABLE #ACCOUNT_DEVICES_CT_UPD_Dups WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ACCT_DEVICE_ID, INSERT_DATETIME), LOCATION = USER_DB)
AS
	SELECT A.ACCT_DEVICE_ID, A.INSERT_DATETIME
	FROM TAG_OWNER.ACCOUNT_DEVICES_CT_UPD A
	INNER JOIN 
		(
			SELECT ACCT_DEVICE_ID
			FROM TAG_OWNER.ACCOUNT_DEVICES_CT_UPD
			GROUP BY ACCT_DEVICE_ID
			HAVING COUNT(*)>1
		) Dups ON A.ACCT_DEVICE_ID = Dups.ACCT_DEVICE_ID

/*
	Create temp table with Last Update 
*/

IF OBJECT_ID('tempdb..#ACCOUNT_DEVICES_CT_UPD_DuplicateLastRowToReInsert')<>0
	DROP TABLE #ACCOUNT_DEVICES_CT_UPD_DuplicateLastRowToReInsert

CREATE TABLE #ACCOUNT_DEVICES_CT_UPD_DuplicateLastRowToReInsert WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ACCT_DEVICE_ID), LOCATION = USER_DB)
AS
	SELECT A.ACCT_DEVICE_ID, A.DEVICE_TYPE, A.ACCT_ID, A.DEVICE_VALUE, A.PRECEDENCE_LEVEL, A.IS_ACTIVE, A.DATE_CREATED, A.CREATED_BY, A.DATE_MODIFIED, A.MODIFIED_BY, A.INSERT_DATETIME
	FROM TAG_OWNER.ACCOUNT_DEVICES_CT_UPD A
	INNER JOIN 
		(
			SELECT ACCT_DEVICE_ID, MAX(INSERT_DATETIME) AS LAST_INSERT_DATETIME
			FROM #ACCOUNT_DEVICES_CT_UPD_Dups
			GROUP BY ACCT_DEVICE_ID
		) LastRcrd ON A.ACCT_DEVICE_ID = LastRcrd.ACCT_DEVICE_ID AND A.INSERT_DATETIME = LastRcrd.LAST_INSERT_DATETIME

/*
	DELETE all the duplicate rows from the target
*/

DELETE FROM TAG_OWNER.ACCOUNT_DEVICES_CT_UPD 
WHERE EXISTS(SELECT * FROM #ACCOUNT_DEVICES_CT_UPD_Dups B WHERE TAG_OWNER.ACCOUNT_DEVICES_CT_UPD.ACCT_DEVICE_ID = B.ACCT_DEVICE_ID);


/*
	Re-insert the LAST ROW for Duplicates
*/
INSERT INTO TAG_OWNER.ACCOUNT_DEVICES_CT_UPD 
	( ACCT_DEVICE_ID, DEVICE_TYPE, ACCT_ID, DEVICE_VALUE, PRECEDENCE_LEVEL, IS_ACTIVE, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, INSERT_DATETIME)
SELECT ACCT_DEVICE_ID, DEVICE_TYPE, ACCT_ID, DEVICE_VALUE, PRECEDENCE_LEVEL, IS_ACTIVE, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, INSERT_DATETIME
FROM #ACCOUNT_DEVICES_CT_UPD_DuplicateLastRowToReInsert


	UPDATE  TAG_OWNER.ACCOUNT_DEVICES
	SET 
    
		  TAG_OWNER.ACCOUNT_DEVICES.DEVICE_TYPE = B.DEVICE_TYPE
		, TAG_OWNER.ACCOUNT_DEVICES.ACCT_ID = B.ACCT_ID
		, TAG_OWNER.ACCOUNT_DEVICES.DEVICE_VALUE = B.DEVICE_VALUE
		, TAG_OWNER.ACCOUNT_DEVICES.PRECEDENCE_LEVEL = B.PRECEDENCE_LEVEL
		, TAG_OWNER.ACCOUNT_DEVICES.IS_ACTIVE = B.IS_ACTIVE
		, TAG_OWNER.ACCOUNT_DEVICES.DATE_CREATED = B.DATE_CREATED
		, TAG_OWNER.ACCOUNT_DEVICES.CREATED_BY = B.CREATED_BY
		, TAG_OWNER.ACCOUNT_DEVICES.DATE_MODIFIED = B.DATE_MODIFIED
		, TAG_OWNER.ACCOUNT_DEVICES.MODIFIED_BY = B.MODIFIED_BY
		, TAG_OWNER.ACCOUNT_DEVICES.LAST_UPDATE_TYPE = 'U'
		, TAG_OWNER.ACCOUNT_DEVICES.LAST_UPDATE_DATE = B.INSERT_DATETIME
	FROM TAG_OWNER.ACCOUNT_DEVICES_CT_UPD B
	WHERE TAG_OWNER.ACCOUNT_DEVICES.ACCT_DEVICE_ID = B.ACCT_DEVICE_ID



