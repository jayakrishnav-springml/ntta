CREATE PROC [VP_OWNER].[VIOLATIONS_UPDATE] AS
/*
	Use this proc to help write the code
		GetUpdateFields 'VP_OWNER','VIOLATIONS'
		You will have to remove the Distribution key from what it generates
*/

/*
	Update Stats on CT_UPD table to help with de-dupping and update steps
*/

EXEC DropStats 'VP_OWNER','VIOLATIONS_CT_UPD'
CREATE STATISTICS STATS_VIOLATIONS_CT_UPD_001 ON VP_OWNER.VIOLATIONS_CT_UPD (VIOLATION_ID)
CREATE STATISTICS STATS_VIOLATIONS_CT_UPD_002 ON VP_OWNER.VIOLATIONS_CT_UPD (VIOLATION_ID, INSERT_DATETIME)

	UPDATE  VP_OWNER.VIOLATIONS
	SET 
		  VP_OWNER.VIOLATIONS.LANE_ID = B.LANE_ID
		, VP_OWNER.VIOLATIONS.VIOL_DATE = B.VIOL_DATE
		, VP_OWNER.VIOLATIONS.VIOL_TIME = B.VIOL_TIME
		, VP_OWNER.VIOLATIONS.VIOL_TYPE = B.VIOL_TYPE
		, VP_OWNER.VIOLATIONS.TOLL_DUE = B.TOLL_DUE
		, VP_OWNER.VIOLATIONS.TOLL_PAID = B.TOLL_PAID
		, VP_OWNER.VIOLATIONS.LIC_PLATE_NBR = B.LIC_PLATE_NBR
		, VP_OWNER.VIOLATIONS.LIC_PLATE_STATE = B.LIC_PLATE_STATE
		, VP_OWNER.VIOLATIONS.VEHICLE_CLASS = B.VEHICLE_CLASS
		, VP_OWNER.VIOLATIONS.VIOL_STATUS = B.VIOL_STATUS
		, VP_OWNER.VIOLATIONS.STATUS_DATE = B.STATUS_DATE
		, VP_OWNER.VIOLATIONS.VEHICLE_MAKE = B.VEHICLE_MAKE
		, VP_OWNER.VIOLATIONS.VEHICLE_MODEL = B.VEHICLE_MODEL
		, VP_OWNER.VIOLATIONS.VEHICLE_COLOR = B.VEHICLE_COLOR
		, VP_OWNER.VIOLATIONS.VEHICLE_YEAR = B.VEHICLE_YEAR
		, VP_OWNER.VIOLATIONS.VEHICLE_BODY = B.VEHICLE_BODY
		, VP_OWNER.VIOLATIONS.OCCUPANT_DESCR = B.OCCUPANT_DESCR
		, VP_OWNER.VIOLATIONS.NO_PAY_ATTEMPT = B.NO_PAY_ATTEMPT
		, VP_OWNER.VIOLATIONS.WINDOW_UP = B.WINDOW_UP
		, VP_OWNER.VIOLATIONS.RECORDED_BY = B.RECORDED_BY
		, VP_OWNER.VIOLATIONS.RECORDER_EMP_ID = B.RECORDER_EMP_ID
		, VP_OWNER.VIOLATIONS.DRIVER_LIC_NBR = B.DRIVER_LIC_NBR
		, VP_OWNER.VIOLATIONS.DRIVER_LIC_STATE = B.DRIVER_LIC_STATE
		, VP_OWNER.VIOLATIONS.TOLLTAG_ACCT_ID = B.TOLLTAG_ACCT_ID
		, VP_OWNER.VIOLATIONS.TAG_ID = B.TAG_ID
		, VP_OWNER.VIOLATIONS.AGENCY_ID = B.AGENCY_ID
		, VP_OWNER.VIOLATIONS.CREATED_BY = B.CREATED_BY
		, VP_OWNER.VIOLATIONS.DATE_CREATED = B.DATE_CREATED
		, VP_OWNER.VIOLATIONS.MODIFIED_BY = B.MODIFIED_BY
		, VP_OWNER.VIOLATIONS.DATE_MODIFIED = B.DATE_MODIFIED
		, VP_OWNER.VIOLATIONS.EXCUSED_REASON = B.EXCUSED_REASON
		, VP_OWNER.VIOLATIONS.EXCUSED_BY = B.EXCUSED_BY
		, VP_OWNER.VIOLATIONS.DATE_EXCUSED = B.DATE_EXCUSED
		, VP_OWNER.VIOLATIONS.VIOLATOR_ID = B.VIOLATOR_ID
		, VP_OWNER.VIOLATIONS.REVIEW_STATUS = B.REVIEW_STATUS
		, VP_OWNER.VIOLATIONS.LANE_VIOL_ID = B.LANE_VIOL_ID
		, VP_OWNER.VIOLATIONS.NOTIFICATION_DATE = B.NOTIFICATION_DATE
		, VP_OWNER.VIOLATIONS.OLD_VIOLATOR_ID = B.OLD_VIOLATOR_ID
		, VP_OWNER.VIOLATIONS.TRANSACTION_ID = B.TRANSACTION_ID
		, VP_OWNER.VIOLATIONS.DISPOSITION = B.DISPOSITION
		, VP_OWNER.VIOLATIONS.COMMENT_DATE = B.COMMENT_DATE
		, VP_OWNER.VIOLATIONS.UNPAID_TOLL_DATE = B.UNPAID_TOLL_DATE
		, VP_OWNER.VIOLATIONS.HOST_TRANSACTION_ID = B.HOST_TRANSACTION_ID
		, VP_OWNER.VIOLATIONS.VIO_VIOLATION_ID = B.VIO_VIOLATION_ID
		, VP_OWNER.VIOLATIONS.ICRS_DATE_CREATED = B.ICRS_DATE_CREATED
		, VP_OWNER.VIOLATIONS.ORIGIN_TYPE = B.ORIGIN_TYPE
		, VP_OWNER.VIOLATIONS.CURRENT_TYPE = B.CURRENT_TYPE
		, VP_OWNER.VIOLATIONS.TRANSACTION_FILE_DETAIL_ID = B.TRANSACTION_FILE_DETAIL_ID
		, VP_OWNER.VIOLATIONS.POST_DATE = B.POST_DATE
		, VP_OWNER.VIOLATIONS.LAST_UPDATE_TYPE = 'U'
		, VP_OWNER.VIOLATIONS.LAST_UPDATE_DATE = B.INSERT_DATETIME
	FROM VP_OWNER.VIOLATIONS_CT_UPD B
	WHERE VP_OWNER.VIOLATIONS.VIOLATION_ID = B.VIOLATION_ID


