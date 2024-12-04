CREATE PROC [DBO].[LANE_VIOLATIONS_DEDUP_COMBINED_INIT_LOAD] AS 

/*
	Find the duplicates using the distribution key and the Primary key of the table
	This keeps the table from re-distributing 
*/

IF OBJECT_ID('LANE_VIOLATIONS_DUPS_KEY')<>0
	DROP TABLE dbo.LANE_VIOLATIONS_DUPS_KEY

CREATE TABLE dbo.LANE_VIOLATIONS_DUPS_KEY WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (LANE_VIOL_ID))
AS 
-- EXPLAIN
SELECT LANE_VIOL_ID, COUNT(*) AS RowCnt
FROM VP_OWNER.LANE_VIOLATIONS
GROUP BY LANE_VIOL_ID
HAVING COUNT(*)>1
OPTION (LABEL = 'LANE_VIOLATIONS_DEDUP_COMBINED_INIT_LOAD: LANE_VIOLATIONS_DUPS_KEY');
/*
	Get the Distinct key lookup values plus the max LAST_UPDATE_DATE from Attunity timestamp
	This will be used to ensure we get the latest row values 
	
*/

IF OBJECT_ID('LANE_VIOLATIONS_DUPS_LAST_UPDATE')<>0
	DROP TABLE dbo.LANE_VIOLATIONS_DUPS_LAST_UPDATE

CREATE TABLE dbo.LANE_VIOLATIONS_DUPS_LAST_UPDATE WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (LANE_VIOL_ID))
AS 
-- EXPLAIN
SELECT DISTINCT A.LANE_VIOL_ID, MAX(LAST_UPDATE_DATE) AS LAST_UPDATE_DATE
FROM VP_OWNER.LANE_VIOLATIONS A
INNER JOIN dbo.LANE_VIOLATIONS_DUPS_KEY B ON A.LANE_VIOL_ID = B.LANE_VIOL_ID
GROUP BY A.LANE_VIOL_ID
OPTION (LABEL = 'LANE_VIOLATIONS_DEDUP_COMBINED_INIT_LOAD: LANE_VIOLATIONS_DUPS_LAST_UPDATE');

/*
	Get the Distinct row values for the duplicate records. 
	to protect against getting 2 non distinct rows. we also want the max LAST_UPDATE_DATE from Attunity timestamp
	This ensures we not only get the distinct row values but also the latest row
*/

IF OBJECT_ID('LANE_VIOLATIONS_DUPS_DISTINCT_RECORDS')<>0
	DROP TABLE dbo.LANE_VIOLATIONS_DUPS_DISTINCT_RECORDS

CREATE TABLE dbo.LANE_VIOLATIONS_DUPS_DISTINCT_RECORDS WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (LANE_VIOL_ID))
AS 
-- EXPLAIN
SELECT DISTINCT A.LANE_VIOL_ID, A.LANE_VIOL_STATUS, A.LC_PLAZA_NBR, A.LC_LANE_NBR, A.VIOL_DATE, A.TIME_NBR, A.SEQUENCE_NBR, A.LANE_MODE, A.EMPLOYEE_ID, A.VEHICLE_CLASS, A.AXLE_COUNT, A.VIOLATION_CODE, A.UNUSUAL_CODE, A.TOLL_DUE, A.TOLL_PAID, A.AGENCY_ID, A.TAG_ID, A.TAG_STATUS, A.VEHICLE_SPEED, A.CONSEC_PREV_VIOL, A.CONSEC_FOLLOW_VIOL, A.POSS_FALSE_TRIGGER, A.DEVICE_STATUS, A.FAIL_REASON, A.LIC_PLATE_NBR, A.OCR_NBR_CONFID, A.LIC_PLATE_STATE, A.OCR_STATE_CONFID, A.IMAGE_NAME, A.ROI_IMAGE_NAME, A.IMAGE_LOC, A.IMAGE_ARCHIVE_LOC, A.OCR_CONFID_CUTOFF, A.STATE_CONFID_CUTOFF, A.REVIEWED_BY, A.PRE_AUDIT_RESULT, A.AUDIT_RESULT, A.CREATED_DATE, A.MODIFIED_DATE, A.LANE_ABBREV, A.VES_NAME, A.SEQUENCE_NBR1, A.LANE_CONTROLLER_TYPE, A.REVIEW_STATUS, A.VIOL_REJECT_TYPE, A.REVIEW_DATE, A.STATUS_DATE, A.VIOL_CREATED, A.REVIEW_USER_ID, A.LC_FACILITY_CODE, A.PLAZA_CODE, A.LANE_CODE, A.LIC_PLATE_NBR_2, A.HOST_TRANSACTION_ID, A.LANE_ID, A.OCR_PLATE_NBR, A.OCR_PLATE_STATE, A.DAC_OCR_MODIFIED_DATE, A.DAC_OCR_PLATE_CONFID, A.DAC_OCR_PLATE_NBR, A.DAC_OCR_PLATE_STATE, A.SOURCE_SERVER, A.CAMERA_LIC_PLATE_NBR, A.CAMERA_LIC_PLATE_STATE, A.CAMERA_LIC_PLATE_CONFID, A.TRANSACTION_FILE_DETAIL_ID, A.SUBSCRIBER_ID, A.LAST_UPDATE_TYPE, A.LAST_UPDATE_DATE
FROM VP_OWNER.LANE_VIOLATIONS A
INNER JOIN dbo.LANE_VIOLATIONS_DUPS_LAST_UPDATE B ON A.LANE_VIOL_ID = B.LANE_VIOL_ID  AND A.LAST_UPDATE_DATE = B.LAST_UPDATE_DATE
OPTION (LABEL = 'LANE_VIOLATIONS_DEDUP_COMBINED_INIT_LOAD: LANE_VIOLATIONS_DUPS_DISTINCT_RECORDS');

/*
	DELETE all the duplicate rows from the target
*/
DELETE FROM VP_OWNER.LANE_VIOLATIONS 
WHERE EXISTS(SELECT * FROM dbo.LANE_VIOLATIONS_DUPS_KEY B WHERE VP_OWNER.LANE_VIOLATIONS.LANE_VIOL_ID = B.LANE_VIOL_ID)
OPTION (LABEL = 'LANE_VIOLATIONS_DEDUP_COMBINED_INIT_LOAD: DELETE FROM VP_OWNER.LANE_VIOLATIONS');
/*
	Re-insert the distinct row values
*/

							
INSERT INTO VP_OWNER.LANE_VIOLATIONS( LANE_VIOL_ID, LANE_VIOL_STATUS, LC_PLAZA_NBR, LC_LANE_NBR, VIOL_DATE, TIME_NBR, SEQUENCE_NBR, LANE_MODE, EMPLOYEE_ID, VEHICLE_CLASS, AXLE_COUNT, VIOLATION_CODE, UNUSUAL_CODE, TOLL_DUE, TOLL_PAID, AGENCY_ID, TAG_ID, TAG_STATUS, VEHICLE_SPEED, CONSEC_PREV_VIOL, CONSEC_FOLLOW_VIOL, POSS_FALSE_TRIGGER, DEVICE_STATUS, FAIL_REASON, LIC_PLATE_NBR, OCR_NBR_CONFID, LIC_PLATE_STATE, OCR_STATE_CONFID, IMAGE_NAME, ROI_IMAGE_NAME, IMAGE_LOC, IMAGE_ARCHIVE_LOC, OCR_CONFID_CUTOFF, STATE_CONFID_CUTOFF, REVIEWED_BY, PRE_AUDIT_RESULT, AUDIT_RESULT, CREATED_DATE, MODIFIED_DATE, LANE_ABBREV, VES_NAME, SEQUENCE_NBR1, LANE_CONTROLLER_TYPE, REVIEW_STATUS, VIOL_REJECT_TYPE, REVIEW_DATE, STATUS_DATE, VIOL_CREATED, REVIEW_USER_ID, LC_FACILITY_CODE, PLAZA_CODE, LANE_CODE, LIC_PLATE_NBR_2, HOST_TRANSACTION_ID, LANE_ID, OCR_PLATE_NBR, OCR_PLATE_STATE, DAC_OCR_MODIFIED_DATE, DAC_OCR_PLATE_CONFID, DAC_OCR_PLATE_NBR, DAC_OCR_PLATE_STATE, SOURCE_SERVER, CAMERA_LIC_PLATE_NBR, CAMERA_LIC_PLATE_STATE, CAMERA_LIC_PLATE_CONFID, TRANSACTION_FILE_DETAIL_ID, SUBSCRIBER_ID, LAST_UPDATE_TYPE, LAST_UPDATE_DATE)
SELECT  LANE_VIOL_ID, LANE_VIOL_STATUS, LC_PLAZA_NBR, LC_LANE_NBR, VIOL_DATE, TIME_NBR, SEQUENCE_NBR, LANE_MODE, EMPLOYEE_ID, VEHICLE_CLASS, AXLE_COUNT, VIOLATION_CODE, UNUSUAL_CODE, TOLL_DUE, TOLL_PAID, AGENCY_ID, TAG_ID, TAG_STATUS, VEHICLE_SPEED, CONSEC_PREV_VIOL, CONSEC_FOLLOW_VIOL, POSS_FALSE_TRIGGER, DEVICE_STATUS, FAIL_REASON, LIC_PLATE_NBR, OCR_NBR_CONFID, LIC_PLATE_STATE, OCR_STATE_CONFID, IMAGE_NAME, ROI_IMAGE_NAME, IMAGE_LOC, IMAGE_ARCHIVE_LOC, OCR_CONFID_CUTOFF, STATE_CONFID_CUTOFF, REVIEWED_BY, PRE_AUDIT_RESULT, AUDIT_RESULT, CREATED_DATE, MODIFIED_DATE, LANE_ABBREV, VES_NAME, SEQUENCE_NBR1, LANE_CONTROLLER_TYPE, REVIEW_STATUS, VIOL_REJECT_TYPE, REVIEW_DATE, STATUS_DATE, VIOL_CREATED, REVIEW_USER_ID, LC_FACILITY_CODE, PLAZA_CODE, LANE_CODE, LIC_PLATE_NBR_2, HOST_TRANSACTION_ID, LANE_ID, OCR_PLATE_NBR, OCR_PLATE_STATE, DAC_OCR_MODIFIED_DATE, DAC_OCR_PLATE_CONFID, DAC_OCR_PLATE_NBR, DAC_OCR_PLATE_STATE, SOURCE_SERVER, CAMERA_LIC_PLATE_NBR, CAMERA_LIC_PLATE_STATE, CAMERA_LIC_PLATE_CONFID, TRANSACTION_FILE_DETAIL_ID, SUBSCRIBER_ID, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
FROM dbo.LANE_VIOLATIONS_DUPS_DISTINCT_RECORDS
OPTION (LABEL = 'LANE_VIOLATIONS_DEDUP_COMBINED_INIT_LOAD: INSERT INTO VP_OWNER.LANE_VIOLATIONS');

--SELECT COUNT(*) AS LANE_VIOLATIONS_DUPS_KEY FROM LANE_VIOLATIONS_DUPS_KEY
--SELECT COUNT(*) AS LANE_VIOLATIONS_DUPS_DISTINCT_RECORDS FROM LANE_VIOLATIONS_DUPS_DISTINCT_RECORDS
--SELECT COUNT(*) AS LANE_VIOLATIONS_DUPS_DISTINCT_RECORDS FROM LANE_VIOLATIONS_DUPS_DISTINCT_RECORDS

IF OBJECT_ID('LANE_VIOLATIONS_DUPS_KEY')<>0
	DROP TABLE dbo.LANE_VIOLATIONS_DUPS_KEY
	
IF OBJECT_ID('LANE_VIOLATIONS_DUPS_DISTINCT_RECORDS')<>0
	DROP TABLE dbo.LANE_VIOLATIONS_DUPS_DISTINCT_RECORDS

IF OBJECT_ID('LANE_VIOLATIONS_DUPS_DISTINCT_RECORDS')<>0
	DROP TABLE dbo.LANE_VIOLATIONS_DUPS_DISTINCT_RECORDS

/*
	-- -- -- -- -- -- -- -- -- -- -- -- 
	-- Check for Dups again
	-- This would be a DataMonitor
	-- top portion would be a stored proc
	-- -- -- -- -- -- -- -- -- -- -- -- 
	SELECT LANE_VIOL_ID, COUNT(*) AS RowCnt
	FROM lnd_lg_vps.VP_OWNER.LANE_VIOLATIONS
	GROUP BY LANE_VIOL_ID
	HAVING COUNT(*)>1
*/



