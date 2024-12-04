CREATE PROC [VP_OWNER].[VIOLATIONS_INSERT] AS

/*
	Update Stats on CT_INS table to help with de-dupping and update steps
*/

EXEC DropStats 'VP_OWNER','VIOLATIONS_CT_INS'
CREATE STATISTICS STATS_VIOLATIONS_CT_INS_001 ON VP_OWNER.VIOLATIONS_CT_INS (VIOLATION_ID)

INSERT INTO VP_OWNER.VIOLATIONS
	(
		VIOLATION_ID, LANE_ID, VIOL_DATE, VIOL_TIME, VIOL_TYPE, TOLL_DUE, TOLL_PAID, LIC_PLATE_NBR, LIC_PLATE_STATE, VEHICLE_CLASS, VIOL_STATUS, STATUS_DATE, VEHICLE_MAKE, VEHICLE_MODEL, VEHICLE_COLOR, VEHICLE_YEAR, VEHICLE_BODY, OCCUPANT_DESCR, NO_PAY_ATTEMPT, WINDOW_UP, RECORDED_BY, RECORDER_EMP_ID, DRIVER_LIC_NBR, DRIVER_LIC_STATE, TOLLTAG_ACCT_ID, TAG_ID, AGENCY_ID, CREATED_BY, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED, EXCUSED_REASON, EXCUSED_BY, DATE_EXCUSED, VIOLATOR_ID, REVIEW_STATUS, LANE_VIOL_ID, NOTIFICATION_DATE, OLD_VIOLATOR_ID, TRANSACTION_ID, DISPOSITION, COMMENT_DATE, UNPAID_TOLL_DATE, HOST_TRANSACTION_ID, VIO_VIOLATION_ID, ICRS_DATE_CREATED, ORIGIN_TYPE, CURRENT_TYPE, TRANSACTION_FILE_DETAIL_ID, POST_DATE
		, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	)
SELECT 
	  A.VIOLATION_ID, A.LANE_ID, A.VIOL_DATE, A.VIOL_TIME, A.VIOL_TYPE, A.TOLL_DUE, A.TOLL_PAID, A.LIC_PLATE_NBR, A.LIC_PLATE_STATE, A.VEHICLE_CLASS, A.VIOL_STATUS, A.STATUS_DATE, A.VEHICLE_MAKE, A.VEHICLE_MODEL, A.VEHICLE_COLOR, A.VEHICLE_YEAR, A.VEHICLE_BODY, A.OCCUPANT_DESCR, A.NO_PAY_ATTEMPT, A.WINDOW_UP, A.RECORDED_BY, A.RECORDER_EMP_ID, A.DRIVER_LIC_NBR, A.DRIVER_LIC_STATE, A.TOLLTAG_ACCT_ID, A.TAG_ID, A.AGENCY_ID, A.CREATED_BY, A.DATE_CREATED, A.MODIFIED_BY, A.DATE_MODIFIED, A.EXCUSED_REASON, A.EXCUSED_BY, A.DATE_EXCUSED, A.VIOLATOR_ID, A.REVIEW_STATUS, A.LANE_VIOL_ID, A.NOTIFICATION_DATE, A.OLD_VIOLATOR_ID, A.TRANSACTION_ID, A.DISPOSITION, A.COMMENT_DATE, A.UNPAID_TOLL_DATE, A.HOST_TRANSACTION_ID, A.VIO_VIOLATION_ID, A.ICRS_DATE_CREATED, A.ORIGIN_TYPE, A.CURRENT_TYPE, A.TRANSACTION_FILE_DETAIL_ID, A.POST_DATE
	, 'I' AS LAST_UPDATE_TYPE, A.INSERT_DATETIME
FROM VP_OWNER.VIOLATIONS_CT_INS A
LEFT JOIN VP_OWNER.VIOLATIONS B ON A.VIOLATION_ID = B.VIOLATION_ID
WHERE B.VIOLATION_ID IS NULL

