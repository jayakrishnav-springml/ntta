CREATE PROC [VP_OWNER].[VIOLATORS_INSERT] AS

/*
	Update Stats on CT_INS table to help with de-dupping and update steps
	GetFields 'VP_OWNER','VIOLATORS'
	GetInsertFields2 'VP_OWNER','VIOLATORS'
*/

EXEC DropStats 'VP_OWNER','VIOLATORS_CT_INS'
CREATE STATISTICS STATS_VIOLATORS_CT_INS_001 ON VP_OWNER.VIOLATORS_CT_INS (VIOLATOR_ID)

INSERT INTO VP_OWNER.VIOLATORS
	(
		VIOLATOR_ID, VIOLATOR_FNAME, VIOLATOR_LNAME, VIOLATOR_FNAME2, VIOLATOR_LNAME2, LIC_PLATE_NBR, LIC_PLATE_STATE, PHONE_NBR, EMAIL_ADDR, DRIVER_LIC_NBR, DRIVER_LIC_STATE, SPANISH_ONLY, CREATED_BY, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED, USAGE_BEGIN_DATE, USAGE_END_DATE, COMMENT_DATE, VIOLATOR_TYPE, RACE, GENDER, BOUNCE_COUNT, VIOLATION_COUNT, EXCUSAL_COUNT, NO_DL_LAST_DATE, NO_DL_RESUBMITS, DISCOUNTED_BY, DISCOUNTED_DATE, IS_DISCOUNTED, IS_VEA, VEHICLE_MAKE, VEHICLE_MODEL, VEHICLE_BODY, VEHICLE_YEAR, VEHICLE_COLOR, DPS_VIOLATOR_NAME, DOCNO, OWNR_ID, VEHI_ID, CONTRACT_ID, FLEET_FILE_ID, VIN, VIOLATOR_SOURCE, VLTR_CREATION_REASON, DMV_ID, BEGIN_DATE_MOD_BY, END_DATE_MOD_BY, IS_BEGIN_UPD_BY_SYS, IS_END_UPD_BY_SYS, IS_ACTIVE, 
		LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	)
SELECT 
	  A.VIOLATOR_ID, A.VIOLATOR_FNAME, A.VIOLATOR_LNAME, A.VIOLATOR_FNAME2, A.VIOLATOR_LNAME2, A.LIC_PLATE_NBR, A.LIC_PLATE_STATE, A.PHONE_NBR, A.EMAIL_ADDR, A.DRIVER_LIC_NBR, A.DRIVER_LIC_STATE, A.SPANISH_ONLY, A.CREATED_BY, A.DATE_CREATED, A.MODIFIED_BY, A.DATE_MODIFIED, A.USAGE_BEGIN_DATE, A.USAGE_END_DATE, A.COMMENT_DATE, A.VIOLATOR_TYPE, A.RACE, A.GENDER, A.BOUNCE_COUNT, A.VIOLATION_COUNT, A.EXCUSAL_COUNT, A.NO_DL_LAST_DATE, A.NO_DL_RESUBMITS, A.DISCOUNTED_BY, A.DISCOUNTED_DATE, A.IS_DISCOUNTED, A.IS_VEA, A.VEHICLE_MAKE, A.VEHICLE_MODEL, A.VEHICLE_BODY, A.VEHICLE_YEAR, A.VEHICLE_COLOR, A.DPS_VIOLATOR_NAME, A.DOCNO, A.OWNR_ID, A.VEHI_ID, A.CONTRACT_ID, A.FLEET_FILE_ID, A.VIN, A.VIOLATOR_SOURCE, A.VLTR_CREATION_REASON, A.DMV_ID, A.BEGIN_DATE_MOD_BY, A.END_DATE_MOD_BY, A.IS_BEGIN_UPD_BY_SYS, A.IS_END_UPD_BY_SYS, A.IS_ACTIVE,
	  'I' AS LAST_UPDATE_TYPE, A.INSERT_DATETIME
FROM VP_OWNER.VIOLATORS_CT_INS A
LEFT JOIN VP_OWNER.VIOLATORS B ON A.VIOLATOR_ID = B.VIOLATOR_ID
WHERE B.VIOLATOR_ID IS NULL


