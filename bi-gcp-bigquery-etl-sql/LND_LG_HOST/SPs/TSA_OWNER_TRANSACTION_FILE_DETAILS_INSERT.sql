CREATE PROC [TSA_OWNER].[TRANSACTION_FILE_DETAILS_INSERT] AS


EXEC DropStats 'TSA_OWNER','TRANSACTION_FILE_DETAILS_CT_INS'
CREATE STATISTICS STATS_TRANSACTION_FILE_DETAILS_CT_INS_001 ON TSA_OWNER.TRANSACTION_FILE_DETAILS_CT_INS (TRANSACTION_FILE_DETAIL_ID)

INSERT INTO TSA_OWNER.TRANSACTION_FILE_DETAILS
	( TRANSACTION_FILE_DETAIL_ID, SUBS_TRANS_TYPE_CODE, TRANSACTION_FILE_HEADER_ID, TRANSACTION_SEQUENCE, RECORD_TYPE, SUBSCRIBER_UNIQUE_ID, REVENUE_DATE, RECEIVED_DATE, RESUBMITTAL_REASON, RESUBMITTAL_COUNT, TRANSACTION_STATUS, AUTHORITY_ID, LOCATION_TYPE, FACILITY, SUBSCRIBER_ID, ENTRY_PLAZA, ENTRY_LANE, ENTRY_LANE_MODE, ENTRY_TRANSACTION_DATE, ENTRY_TRANSACTION_TIME, ENTRY_TRANSPONDER_ID, ENTRY_TRANSPONDER_STATUS, ENTRY_TVL_FILE_NAME, ENTRY_LVL_FILE_NAME, ENTRY_VEHICLE_CLASS, ENTRY_AXLES_EXPECTED, ENTRY_AXLES_COUNTED, ENTRY_SPEED, ENTRY_HOV_DESIGNATION, EXIT_PLAZA, EXIT_LANE, EXIT_LANE_MODE, EXIT_TRANSACTION_DATE, EXIT_TRANSACTION_TIME, EXIT_TRANSPONDER_ID, EXIT_TRANSPONDER_STATUS, EXIT_TVL_FILE_NAME, EXIT_LVL_FILE_NAME, EXIT_VEHICLE_CLASS, EXIT_AXLES_EXPECTED, EXIT_AXLES_COUNTED, EXIT_SPEED, EXIT_HOV_DESIGNATION, COLLECTOR_ID, VAULT_ID, TOLL_DETERMINATION_CLASS, TRANSPONDER_TOLL_AMT, TRANSPONDER_DISCOUNT_TYPE, DISC_TRANSPONDER_TOLL_AMT, VIDEO_TOLL_AMT_WO_PREM, VIDEO_TOLL_AMT_W_PREM, VIDEO_DISCOUNT_TYPE, DISC_VIDEO_TOLL_AMT_WO_PREM, DISC_VIDEO_TOLL_AMT_W_PREM, CASH_TOLL_AMOUNT, CASH_DISCOUNT_TYPE, DISC_CASH_TOLL_AMOUNT, UNUSUAL_OCCURRENCE_CODE, NUMBER_OF_IMAGES, AMOUNT_PAID, IMAGE_REQUEST_SEND_DATE, IMAGE_RESPONSE_RECEIVED_DATE, IMAGE_REQUEST_STATUS_CODE, CREATED_BY, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED, SUBSCRIBER_LIST_ID, PROCESSED_YN, LOCKED_TIMESTAMP, EXIT_TAG_ID, LAST_UPDATE_TYPE, LAST_UPDATE_DATE 
	)
SELECT 
     A.TRANSACTION_FILE_DETAIL_ID, A.SUBS_TRANS_TYPE_CODE, A.TRANSACTION_FILE_HEADER_ID, A.TRANSACTION_SEQUENCE, A.RECORD_TYPE, A.SUBSCRIBER_UNIQUE_ID, A.REVENUE_DATE, A.RECEIVED_DATE, A.RESUBMITTAL_REASON, A.RESUBMITTAL_COUNT, A.TRANSACTION_STATUS, A.AUTHORITY_ID, A.LOCATION_TYPE, A.FACILITY, A.SUBSCRIBER_ID, A.ENTRY_PLAZA, A.ENTRY_LANE, A.ENTRY_LANE_MODE, A.ENTRY_TRANSACTION_DATE, A.ENTRY_TRANSACTION_TIME, A.ENTRY_TRANSPONDER_ID, A.ENTRY_TRANSPONDER_STATUS, A.ENTRY_TVL_FILE_NAME, A.ENTRY_LVL_FILE_NAME, A.ENTRY_VEHICLE_CLASS, A.ENTRY_AXLES_EXPECTED, A.ENTRY_AXLES_COUNTED, A.ENTRY_SPEED, A.ENTRY_HOV_DESIGNATION, A.EXIT_PLAZA, A.EXIT_LANE, A.EXIT_LANE_MODE, A.EXIT_TRANSACTION_DATE, A.EXIT_TRANSACTION_TIME, A.EXIT_TRANSPONDER_ID, A.EXIT_TRANSPONDER_STATUS, A.EXIT_TVL_FILE_NAME, A.EXIT_LVL_FILE_NAME, A.EXIT_VEHICLE_CLASS, A.EXIT_AXLES_EXPECTED, A.EXIT_AXLES_COUNTED, A.EXIT_SPEED, A.EXIT_HOV_DESIGNATION, A.COLLECTOR_ID, A.VAULT_ID, A.TOLL_DETERMINATION_CLASS, A.TRANSPONDER_TOLL_AMT, A.TRANSPONDER_DISCOUNT_TYPE, A.DISC_TRANSPONDER_TOLL_AMT, A.VIDEO_TOLL_AMT_WO_PREM, A.VIDEO_TOLL_AMT_W_PREM, A.VIDEO_DISCOUNT_TYPE, A.DISC_VIDEO_TOLL_AMT_WO_PREM, A.DISC_VIDEO_TOLL_AMT_W_PREM, A.CASH_TOLL_AMOUNT, A.CASH_DISCOUNT_TYPE, A.DISC_CASH_TOLL_AMOUNT, A.UNUSUAL_OCCURRENCE_CODE, A.NUMBER_OF_IMAGES, A.AMOUNT_PAID, A.IMAGE_REQUEST_SEND_DATE, A.IMAGE_RESPONSE_RECEIVED_DATE, A.IMAGE_REQUEST_STATUS_CODE, A.CREATED_BY, A.DATE_CREATED, A.MODIFIED_BY, A.DATE_MODIFIED, A.SUBSCRIBER_LIST_ID, A.PROCESSED_YN, A.LOCKED_TIMESTAMP, A.EXIT_TAG_ID
    ,'I' as [LAST_UPDATE_TYPE] 
    ,A.INSERT_DATETIME 

FROM TSA_OWNER.TRANSACTION_FILE_DETAILS_CT_INS A
LEFT JOIN TSA_OWNER.TRANSACTION_FILE_DETAILS B ON A.TRANSACTION_FILE_DETAIL_ID = B.TRANSACTION_FILE_DETAIL_ID
WHERE B.TRANSACTION_FILE_DETAIL_ID IS NULL


