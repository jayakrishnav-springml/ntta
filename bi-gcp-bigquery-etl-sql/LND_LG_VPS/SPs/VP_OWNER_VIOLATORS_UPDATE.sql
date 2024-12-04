CREATE PROC [VP_OWNER].[VIOLATORS_UPDATE] AS
/*
	Use this proc to help write the code
		GetUpdateFields 'VP_OWNER','VIOLATORS'
		You will have to remove the Distribution key from what it generates
*/

/*
	Update Stats on CT_UPD table to help with de-dupping and update steps
*/

EXEC DropStats 'VP_OWNER','VIOLATORS_CT_UPD'
CREATE STATISTICS STATS_VIOLATORS_CT_UPD_001 ON VP_OWNER.VIOLATORS_CT_UPD (VIOLATOR_ID)
CREATE STATISTICS STATS_VIOLATORS_CT_UPD_002 ON VP_OWNER.VIOLATORS_CT_UPD (VIOLATOR_ID, INSERT_DATETIME)


/*
	Get Duplicate Records with the INSERT_DATETIME from the CDC Staging 
*/
/*
IF OBJECT_ID('tempdb..#VIOLATORS_CT_UPD_Dups')<>0
	DROP TABLE #VIOLATORS_CT_UPD_Dups

CREATE TABLE #VIOLATORS_CT_UPD_Dups WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (VIOLATOR_ID, INSERT_DATETIME), LOCATION = USER_DB)
AS
	SELECT A.VIOLATOR_ID, A.INSERT_DATETIME
	FROM VP_OWNER.VIOLATORS_CT_UPD A
	INNER JOIN 
		(
			SELECT VIOLATOR_ID
			FROM VP_OWNER.VIOLATORS_CT_UPD
			GROUP BY VIOLATOR_ID
			HAVING COUNT(*)>1
		) Dups ON A.VIOLATOR_ID = Dups.VIOLATOR_ID

/*
	Create temp table with Last Update 
*/

IF OBJECT_ID('tempdb..#VIOLATORS_CT_UPD_DuplicateLastRowToReInsert')<>0
	DROP TABLE #VIOLATORS_CT_UPD_DuplicateLastRowToReInsert

CREATE TABLE #VIOLATORS_CT_UPD_DuplicateLastRowToReInsert WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (VIOLATOR_ID), LOCATION = USER_DB)
AS
	SELECT  A.VIOLATOR_ID, A.VIOLATOR_FNAME, A.VIOLATOR_LNAME, A.VIOLATOR_FNAME2, A.VIOLATOR_LNAME2, A.LIC_PLATE_NBR, A.LIC_PLATE_STATE, A.PHONE_NBR, A.EMAIL_ADDR, A.DRIVER_LIC_NBR, A.DRIVER_LIC_STATE, A.SPANISH_ONLY, A.CREATED_BY, A.DATE_CREATED, A.MODIFIED_BY, A.DATE_MODIFIED, A.USAGE_BEGIN_DATE, A.USAGE_END_DATE, A.COMMENT_DATE, A.VIOLATOR_TYPE, A.RACE, A.GENDER, A.BOUNCE_COUNT, A.VIOLATION_COUNT, A.EXCUSAL_COUNT, A.NO_DL_LAST_DATE, A.NO_DL_RESUBMITS, A.DISCOUNTED_BY, A.DISCOUNTED_DATE, A.IS_DISCOUNTED, A.IS_VEA, A.VEHICLE_MAKE, A.VEHICLE_MODEL, A.VEHICLE_BODY, A.VEHICLE_YEAR, A.VEHICLE_COLOR, A.DPS_VIOLATOR_NAME, A.DOCNO, A.OWNR_ID, A.VEHI_ID, A.CONTRACT_ID, A.FLEET_FILE_ID, A.VIN, A.VIOLATOR_SOURCE, A.VLTR_CREATION_REASON, A.DMV_ID, A.BEGIN_DATE_MOD_BY, A.END_DATE_MOD_BY, A.IS_BEGIN_UPD_BY_SYS, A.IS_END_UPD_BY_SYS, A.IS_ACTIVE, A.INSERT_DATETIME
	FROM VP_OWNER.VIOLATORS_CT_UPD A
	INNER JOIN 
		(
			SELECT VIOLATOR_ID, MAX(INSERT_DATETIME) AS LAST_INSERT_DATETIME
			FROM #VIOLATORS_CT_UPD_Dups
			GROUP BY VIOLATOR_ID
		) LastRcrd ON A.VIOLATOR_ID = LastRcrd.VIOLATOR_ID AND A.INSERT_DATETIME = LastRcrd.LAST_INSERT_DATETIME

/*
	DELETE all the duplicate rows from the target
*/

DELETE FROM VP_OWNER.VIOLATORS_CT_UPD 
WHERE EXISTS(SELECT * FROM #VIOLATORS_CT_UPD_Dups B WHERE VP_OWNER.VIOLATORS_CT_UPD.VIOLATOR_ID = B.VIOLATOR_ID);


/*
	Re-insert the LAST ROW for Duplicates
*/
INSERT INTO VP_OWNER.VIOLATORS_CT_UPD 
	(VIOLATOR_ID, VIOLATOR_FNAME, VIOLATOR_LNAME, VIOLATOR_FNAME2, VIOLATOR_LNAME2, LIC_PLATE_NBR, LIC_PLATE_STATE, PHONE_NBR, EMAIL_ADDR, DRIVER_LIC_NBR, DRIVER_LIC_STATE, SPANISH_ONLY, CREATED_BY, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED, USAGE_BEGIN_DATE, USAGE_END_DATE, COMMENT_DATE, VIOLATOR_TYPE, RACE, GENDER, BOUNCE_COUNT, VIOLATION_COUNT, EXCUSAL_COUNT, NO_DL_LAST_DATE, NO_DL_RESUBMITS, DISCOUNTED_BY, DISCOUNTED_DATE, IS_DISCOUNTED, IS_VEA, VEHICLE_MAKE, VEHICLE_MODEL, VEHICLE_BODY, VEHICLE_YEAR, VEHICLE_COLOR, DPS_VIOLATOR_NAME, DOCNO, OWNR_ID, VEHI_ID, CONTRACT_ID, FLEET_FILE_ID, VIN, VIOLATOR_SOURCE, VLTR_CREATION_REASON, DMV_ID, BEGIN_DATE_MOD_BY, END_DATE_MOD_BY, IS_BEGIN_UPD_BY_SYS, IS_END_UPD_BY_SYS, IS_ACTIVE, INSERT_DATETIME)
SELECT VIOLATOR_ID, VIOLATOR_FNAME, VIOLATOR_LNAME, VIOLATOR_FNAME2, VIOLATOR_LNAME2, LIC_PLATE_NBR, LIC_PLATE_STATE, PHONE_NBR, EMAIL_ADDR, DRIVER_LIC_NBR, DRIVER_LIC_STATE, SPANISH_ONLY, CREATED_BY, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED, USAGE_BEGIN_DATE, USAGE_END_DATE, COMMENT_DATE, VIOLATOR_TYPE, RACE, GENDER, BOUNCE_COUNT, VIOLATION_COUNT, EXCUSAL_COUNT, NO_DL_LAST_DATE, NO_DL_RESUBMITS, DISCOUNTED_BY, DISCOUNTED_DATE, IS_DISCOUNTED, IS_VEA, VEHICLE_MAKE, VEHICLE_MODEL, VEHICLE_BODY, VEHICLE_YEAR, VEHICLE_COLOR, DPS_VIOLATOR_NAME, DOCNO, OWNR_ID, VEHI_ID, CONTRACT_ID, FLEET_FILE_ID, VIN, VIOLATOR_SOURCE, VLTR_CREATION_REASON, DMV_ID, BEGIN_DATE_MOD_BY, END_DATE_MOD_BY, IS_BEGIN_UPD_BY_SYS, IS_END_UPD_BY_SYS, IS_ACTIVE, INSERT_DATETIME
FROM #VIOLATORS_CT_UPD_DuplicateLastRowToReInsert

*/
	UPDATE  VP_OWNER.VIOLATORS
	SET 
    
		  VP_OWNER.VIOLATORS.VIOLATOR_FNAME = B.VIOLATOR_FNAME
		, VP_OWNER.VIOLATORS.VIOLATOR_LNAME = B.VIOLATOR_LNAME
		, VP_OWNER.VIOLATORS.VIOLATOR_FNAME2 = B.VIOLATOR_FNAME2
		, VP_OWNER.VIOLATORS.VIOLATOR_LNAME2 = B.VIOLATOR_LNAME2
		, VP_OWNER.VIOLATORS.LIC_PLATE_NBR = B.LIC_PLATE_NBR
		, VP_OWNER.VIOLATORS.LIC_PLATE_STATE = B.LIC_PLATE_STATE
		, VP_OWNER.VIOLATORS.PHONE_NBR = B.PHONE_NBR
		, VP_OWNER.VIOLATORS.EMAIL_ADDR = B.EMAIL_ADDR
		, VP_OWNER.VIOLATORS.DRIVER_LIC_NBR = B.DRIVER_LIC_NBR
		, VP_OWNER.VIOLATORS.DRIVER_LIC_STATE = B.DRIVER_LIC_STATE
		, VP_OWNER.VIOLATORS.SPANISH_ONLY = B.SPANISH_ONLY
		, VP_OWNER.VIOLATORS.CREATED_BY = B.CREATED_BY
		, VP_OWNER.VIOLATORS.DATE_CREATED = B.DATE_CREATED
		, VP_OWNER.VIOLATORS.MODIFIED_BY = B.MODIFIED_BY
		, VP_OWNER.VIOLATORS.DATE_MODIFIED = B.DATE_MODIFIED
		, VP_OWNER.VIOLATORS.USAGE_BEGIN_DATE = B.USAGE_BEGIN_DATE
		, VP_OWNER.VIOLATORS.USAGE_END_DATE = B.USAGE_END_DATE
		, VP_OWNER.VIOLATORS.COMMENT_DATE = B.COMMENT_DATE
		, VP_OWNER.VIOLATORS.VIOLATOR_TYPE = B.VIOLATOR_TYPE
		, VP_OWNER.VIOLATORS.RACE = B.RACE
		, VP_OWNER.VIOLATORS.GENDER = B.GENDER
		, VP_OWNER.VIOLATORS.BOUNCE_COUNT = B.BOUNCE_COUNT
		, VP_OWNER.VIOLATORS.VIOLATION_COUNT = B.VIOLATION_COUNT
		, VP_OWNER.VIOLATORS.EXCUSAL_COUNT = B.EXCUSAL_COUNT
		, VP_OWNER.VIOLATORS.NO_DL_LAST_DATE = B.NO_DL_LAST_DATE
		, VP_OWNER.VIOLATORS.NO_DL_RESUBMITS = B.NO_DL_RESUBMITS
		, VP_OWNER.VIOLATORS.DISCOUNTED_BY = B.DISCOUNTED_BY
		, VP_OWNER.VIOLATORS.DISCOUNTED_DATE = B.DISCOUNTED_DATE
		, VP_OWNER.VIOLATORS.IS_DISCOUNTED = B.IS_DISCOUNTED
		, VP_OWNER.VIOLATORS.IS_VEA = B.IS_VEA
		, VP_OWNER.VIOLATORS.VEHICLE_MAKE = B.VEHICLE_MAKE
		, VP_OWNER.VIOLATORS.VEHICLE_MODEL = B.VEHICLE_MODEL
		, VP_OWNER.VIOLATORS.VEHICLE_BODY = B.VEHICLE_BODY
		, VP_OWNER.VIOLATORS.VEHICLE_YEAR = B.VEHICLE_YEAR
		, VP_OWNER.VIOLATORS.VEHICLE_COLOR = B.VEHICLE_COLOR
		, VP_OWNER.VIOLATORS.DPS_VIOLATOR_NAME = B.DPS_VIOLATOR_NAME
		, VP_OWNER.VIOLATORS.DOCNO = B.DOCNO
		, VP_OWNER.VIOLATORS.OWNR_ID = B.OWNR_ID
		, VP_OWNER.VIOLATORS.VEHI_ID = B.VEHI_ID
		, VP_OWNER.VIOLATORS.CONTRACT_ID = B.CONTRACT_ID
		, VP_OWNER.VIOLATORS.FLEET_FILE_ID = B.FLEET_FILE_ID
		, VP_OWNER.VIOLATORS.VIN = B.VIN
		, VP_OWNER.VIOLATORS.VIOLATOR_SOURCE = B.VIOLATOR_SOURCE
		, VP_OWNER.VIOLATORS.VLTR_CREATION_REASON = B.VLTR_CREATION_REASON
		, VP_OWNER.VIOLATORS.DMV_ID = B.DMV_ID
		, VP_OWNER.VIOLATORS.BEGIN_DATE_MOD_BY = B.BEGIN_DATE_MOD_BY
		, VP_OWNER.VIOLATORS.END_DATE_MOD_BY = B.END_DATE_MOD_BY
		, VP_OWNER.VIOLATORS.IS_BEGIN_UPD_BY_SYS = B.IS_BEGIN_UPD_BY_SYS
		, VP_OWNER.VIOLATORS.IS_END_UPD_BY_SYS = B.IS_END_UPD_BY_SYS
		, VP_OWNER.VIOLATORS.IS_ACTIVE = B.IS_ACTIVE
		, VP_OWNER.VIOLATORS.LAST_UPDATE_TYPE = 'U'
		, VP_OWNER.VIOLATORS.LAST_UPDATE_DATE = B.INSERT_DATETIME
	FROM VP_OWNER.VIOLATORS_CT_UPD B
	WHERE VP_OWNER.VIOLATORS.VIOLATOR_ID = B.VIOLATOR_ID

