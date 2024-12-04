CREATE PROC [DBO].[VIOLATIONS_COMBINE_INIT_LOAD] AS 

TRUNCATE TABLE VP_OWNER.VIOLATIONS

INSERT INTO VP_OWNER.VIOLATIONS
(VIOLATION_ID, LANE_ID, VIOL_DATE, VIOL_TIME, VIOL_MICRO_TIME, VIOL_TYPE, TOLL_DUE, TOLL_PAID, LIC_PLATE_NBR, LIC_PLATE_STATE
	, VEHICLE_CLASS, VIOL_STATUS, STATUS_DATE, VEHICLE_MAKE, VEHICLE_MODEL, VEHICLE_COLOR, VEHICLE_YEAR, VEHICLE_BODY, NO_PAY_ATTEMPT
	, WINDOW_UP, RECORDED_BY, RECORDER_EMP_ID, DRIVER_LIC_NBR, DRIVER_LIC_STATE, TOLLTAG_ACCT_ID, TAG_ID, AGENCY_ID, CREATED_BY
	, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED, EXCUSED_REASON, EXCUSED_BY, DATE_EXCUSED
	, VIOLATOR_ID, REVIEW_STATUS, LANE_VIOL_ID, NOTIFICATION_DATE
	, OLD_VIOLATOR_ID, TRANSACTION_ID, DISPOSITION, COMMENT_DATE, UNPAID_TOLL_DATE, HOST_TRANSACTION_ID, VIO_VIOLATION_ID, ICRS_DATE_CREATED, ORIGIN_TYPE, CURRENT_TYPE, TRANSACTION_FILE_DETAIL_ID, POST_DATE, LAST_UPDATE_DATE, LAST_UPDATE_TYPE )
SELECT VIOLATION_ID, LANE_ID, VIOL_DATE, VIOL_TIME, VIOL_MICRO_TIME, VIOL_TYPE, TOLL_DUE, TOLL_PAID, LIC_PLATE_NBR, LIC_PLATE_STATE
	, VEHICLE_CLASS, VIOL_STATUS, STATUS_DATE, VEHICLE_MAKE, VEHICLE_MODEL, VEHICLE_COLOR, VEHICLE_YEAR, VEHICLE_BODY, NO_PAY_ATTEMPT
	, WINDOW_UP, RECORDED_BY, RECORDER_EMP_ID, DRIVER_LIC_NBR, DRIVER_LIC_STATE, TOLLTAG_ACCT_ID, TAG_ID, AGENCY_ID, CREATED_BY
	, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED, EXCUSED_REASON, EXCUSED_BY, DATE_EXCUSED
	, ISNULL(VIOLATOR_ID,(VIOLATION_ID%100000)*-1) AS VIOLATOR_ID, REVIEW_STATUS, LANE_VIOL_ID, NOTIFICATION_DATE
	, OLD_VIOLATOR_ID, TRANSACTION_ID, DISPOSITION, COMMENT_DATE, UNPAID_TOLL_DATE, HOST_TRANSACTION_ID, VIO_VIOLATION_ID, ICRS_DATE_CREATED, ORIGIN_TYPE, CURRENT_TYPE, TRANSACTION_FILE_DETAIL_ID, POST_DATE, LAST_UPDATE_DATE, LAST_UPDATE_TYPE 
FROM 
(
	SELECT VIOLATION_ID, LANE_ID, VIOL_DATE, VIOL_TIME, VIOL_MICRO_TIME, VIOL_TYPE, TOLL_DUE, TOLL_PAID, LIC_PLATE_NBR, LIC_PLATE_STATE, VEHICLE_CLASS, VIOL_STATUS, STATUS_DATE, VEHICLE_MAKE, VEHICLE_MODEL, VEHICLE_COLOR, VEHICLE_YEAR, VEHICLE_BODY, NO_PAY_ATTEMPT, WINDOW_UP, RECORDED_BY, RECORDER_EMP_ID, DRIVER_LIC_NBR, DRIVER_LIC_STATE, TOLLTAG_ACCT_ID, TAG_ID, AGENCY_ID, CREATED_BY, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED, EXCUSED_REASON, EXCUSED_BY, DATE_EXCUSED, VIOLATOR_ID, REVIEW_STATUS, LANE_VIOL_ID, NOTIFICATION_DATE, OLD_VIOLATOR_ID, TRANSACTION_ID, DISPOSITION, COMMENT_DATE, UNPAID_TOLL_DATE, HOST_TRANSACTION_ID, VIO_VIOLATION_ID, ICRS_DATE_CREATED, ORIGIN_TYPE, CURRENT_TYPE, TRANSACTION_FILE_DETAIL_ID, POST_DATE, LAST_UPDATE_DATE, LAST_UPDATE_TYPE 
	FROM VP_OWNER.VIOLATIONS_2010
	UNION ALL
	SELECT VIOLATION_ID, LANE_ID, VIOL_DATE, VIOL_TIME, VIOL_MICRO_TIME, VIOL_TYPE, TOLL_DUE, TOLL_PAID, LIC_PLATE_NBR, LIC_PLATE_STATE, VEHICLE_CLASS, VIOL_STATUS, STATUS_DATE, VEHICLE_MAKE, VEHICLE_MODEL, VEHICLE_COLOR, VEHICLE_YEAR, VEHICLE_BODY, NO_PAY_ATTEMPT, WINDOW_UP, RECORDED_BY, RECORDER_EMP_ID, DRIVER_LIC_NBR, DRIVER_LIC_STATE, TOLLTAG_ACCT_ID, TAG_ID, AGENCY_ID, CREATED_BY, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED, EXCUSED_REASON, EXCUSED_BY, DATE_EXCUSED, VIOLATOR_ID, REVIEW_STATUS, LANE_VIOL_ID, NOTIFICATION_DATE, OLD_VIOLATOR_ID, TRANSACTION_ID, DISPOSITION, COMMENT_DATE, UNPAID_TOLL_DATE, HOST_TRANSACTION_ID, VIO_VIOLATION_ID, ICRS_DATE_CREATED, ORIGIN_TYPE, CURRENT_TYPE, TRANSACTION_FILE_DETAIL_ID, POST_DATE, LAST_UPDATE_DATE, LAST_UPDATE_TYPE 
	FROM VP_OWNER.VIOLATIONS_2011
	UNION ALL
	SELECT VIOLATION_ID, LANE_ID, VIOL_DATE, VIOL_TIME, VIOL_MICRO_TIME, VIOL_TYPE, TOLL_DUE, TOLL_PAID, LIC_PLATE_NBR, LIC_PLATE_STATE, VEHICLE_CLASS, VIOL_STATUS, STATUS_DATE, VEHICLE_MAKE, VEHICLE_MODEL, VEHICLE_COLOR, VEHICLE_YEAR, VEHICLE_BODY, NO_PAY_ATTEMPT, WINDOW_UP, RECORDED_BY, RECORDER_EMP_ID, DRIVER_LIC_NBR, DRIVER_LIC_STATE, TOLLTAG_ACCT_ID, TAG_ID, AGENCY_ID, CREATED_BY, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED, EXCUSED_REASON, EXCUSED_BY, DATE_EXCUSED, VIOLATOR_ID, REVIEW_STATUS, LANE_VIOL_ID, NOTIFICATION_DATE, OLD_VIOLATOR_ID, TRANSACTION_ID, DISPOSITION, COMMENT_DATE, UNPAID_TOLL_DATE, HOST_TRANSACTION_ID, VIO_VIOLATION_ID, ICRS_DATE_CREATED, ORIGIN_TYPE, CURRENT_TYPE, TRANSACTION_FILE_DETAIL_ID, POST_DATE, LAST_UPDATE_DATE, LAST_UPDATE_TYPE 
	FROM VP_OWNER.VIOLATIONS_2012
	UNION ALL
	SELECT VIOLATION_ID, LANE_ID, VIOL_DATE, VIOL_TIME, VIOL_MICRO_TIME, VIOL_TYPE, TOLL_DUE, TOLL_PAID, LIC_PLATE_NBR, LIC_PLATE_STATE, VEHICLE_CLASS, VIOL_STATUS, STATUS_DATE, VEHICLE_MAKE, VEHICLE_MODEL, VEHICLE_COLOR, VEHICLE_YEAR, VEHICLE_BODY, NO_PAY_ATTEMPT, WINDOW_UP, RECORDED_BY, RECORDER_EMP_ID, DRIVER_LIC_NBR, DRIVER_LIC_STATE, TOLLTAG_ACCT_ID, TAG_ID, AGENCY_ID, CREATED_BY, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED, EXCUSED_REASON, EXCUSED_BY, DATE_EXCUSED, VIOLATOR_ID, REVIEW_STATUS, LANE_VIOL_ID, NOTIFICATION_DATE, OLD_VIOLATOR_ID, TRANSACTION_ID, DISPOSITION, COMMENT_DATE, UNPAID_TOLL_DATE, HOST_TRANSACTION_ID, VIO_VIOLATION_ID, ICRS_DATE_CREATED, ORIGIN_TYPE, CURRENT_TYPE, TRANSACTION_FILE_DETAIL_ID, POST_DATE, LAST_UPDATE_DATE, LAST_UPDATE_TYPE 
	FROM VP_OWNER.VIOLATIONS_2013
	UNION ALL
	SELECT VIOLATION_ID, LANE_ID, VIOL_DATE, VIOL_TIME, VIOL_MICRO_TIME, VIOL_TYPE, TOLL_DUE, TOLL_PAID, LIC_PLATE_NBR, LIC_PLATE_STATE, VEHICLE_CLASS, VIOL_STATUS, STATUS_DATE, VEHICLE_MAKE, VEHICLE_MODEL, VEHICLE_COLOR, VEHICLE_YEAR, VEHICLE_BODY, NO_PAY_ATTEMPT, WINDOW_UP, RECORDED_BY, RECORDER_EMP_ID, DRIVER_LIC_NBR, DRIVER_LIC_STATE, TOLLTAG_ACCT_ID, TAG_ID, AGENCY_ID, CREATED_BY, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED, EXCUSED_REASON, EXCUSED_BY, DATE_EXCUSED, VIOLATOR_ID, REVIEW_STATUS, LANE_VIOL_ID, NOTIFICATION_DATE, OLD_VIOLATOR_ID, TRANSACTION_ID, DISPOSITION, COMMENT_DATE, UNPAID_TOLL_DATE, HOST_TRANSACTION_ID, VIO_VIOLATION_ID, ICRS_DATE_CREATED, ORIGIN_TYPE, CURRENT_TYPE, TRANSACTION_FILE_DETAIL_ID, POST_DATE, LAST_UPDATE_DATE, LAST_UPDATE_TYPE 
	FROM VP_OWNER.VIOLATIONS_2014
	UNION ALL
	SELECT VIOLATION_ID, LANE_ID, VIOL_DATE, VIOL_TIME, VIOL_MICRO_TIME, VIOL_TYPE, TOLL_DUE, TOLL_PAID, LIC_PLATE_NBR, LIC_PLATE_STATE, VEHICLE_CLASS, VIOL_STATUS, STATUS_DATE, VEHICLE_MAKE, VEHICLE_MODEL, VEHICLE_COLOR, VEHICLE_YEAR, VEHICLE_BODY, NO_PAY_ATTEMPT, WINDOW_UP, RECORDED_BY, RECORDER_EMP_ID, DRIVER_LIC_NBR, DRIVER_LIC_STATE, TOLLTAG_ACCT_ID, TAG_ID, AGENCY_ID, CREATED_BY, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED, EXCUSED_REASON, EXCUSED_BY, DATE_EXCUSED, VIOLATOR_ID, REVIEW_STATUS, LANE_VIOL_ID, NOTIFICATION_DATE, OLD_VIOLATOR_ID, TRANSACTION_ID, DISPOSITION, COMMENT_DATE, UNPAID_TOLL_DATE, HOST_TRANSACTION_ID, VIO_VIOLATION_ID, ICRS_DATE_CREATED, ORIGIN_TYPE, CURRENT_TYPE, TRANSACTION_FILE_DETAIL_ID, POST_DATE, LAST_UPDATE_DATE, LAST_UPDATE_TYPE 
	FROM VP_OWNER.VIOLATIONS_2015
	UNION ALL
	SELECT VIOLATION_ID, LANE_ID, VIOL_DATE, VIOL_TIME, VIOL_MICRO_TIME, VIOL_TYPE, TOLL_DUE, TOLL_PAID, LIC_PLATE_NBR, LIC_PLATE_STATE, VEHICLE_CLASS, VIOL_STATUS, STATUS_DATE, VEHICLE_MAKE, VEHICLE_MODEL, VEHICLE_COLOR, VEHICLE_YEAR, VEHICLE_BODY, NO_PAY_ATTEMPT, WINDOW_UP, RECORDED_BY, RECORDER_EMP_ID, DRIVER_LIC_NBR, DRIVER_LIC_STATE, TOLLTAG_ACCT_ID, TAG_ID, AGENCY_ID, CREATED_BY, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED, EXCUSED_REASON, EXCUSED_BY, DATE_EXCUSED, VIOLATOR_ID, REVIEW_STATUS, LANE_VIOL_ID, NOTIFICATION_DATE, OLD_VIOLATOR_ID, TRANSACTION_ID, DISPOSITION, COMMENT_DATE, UNPAID_TOLL_DATE, HOST_TRANSACTION_ID, VIO_VIOLATION_ID, ICRS_DATE_CREATED, ORIGIN_TYPE, CURRENT_TYPE, TRANSACTION_FILE_DETAIL_ID, POST_DATE, LAST_UPDATE_DATE, LAST_UPDATE_TYPE 
	FROM VP_OWNER.VIOLATIONS_PRE_2010
) SUBQuery
OPTION (LABEL = 'VIOLATIONS_COMBINE_INIT_LOAD: VP_OWNER.VIOLATIONS');







