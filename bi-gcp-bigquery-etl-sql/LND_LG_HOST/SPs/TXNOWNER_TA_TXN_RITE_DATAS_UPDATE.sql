CREATE PROC [TXNOWNER].[TA_TXN_RITE_DATAS_UPDATE] AS
/*
	Use this proc to help write the code
		GetUpdateFields 'TXNOWNER','TA_TXN_RITE_DATAS'
		You will have to remove the Distribution key from what it generates
*/

/*
	Update Stats on CT_UPD table to help with de-dupping and update steps
*/

EXEC DropStats 'TXNOWNER','TA_TXN_RITE_DATAS_CT_UPD'
CREATE STATISTICS STATS_TA_TXN_RITE_DATAS_CT_UPD_001 ON TXNOWNER.TA_TXN_RITE_DATAS_CT_UPD (TURD_ID)
CREATE STATISTICS STATS_TA_TXN_RITE_DATAS_CT_UPD_002 ON TXNOWNER.TA_TXN_RITE_DATAS_CT_UPD (TURD_ID, INSERT_DATETIME)


/*
	Get Duplicate Records with the INSERT_DATETIME from the CDC Staging 
*/

IF OBJECT_ID('tempdb..#TA_TXN_RITE_DATAS_CT_UPD_Dups')<>0
	DROP TABLE #TA_TXN_RITE_DATAS_CT_UPD_Dups

CREATE TABLE #TA_TXN_RITE_DATAS_CT_UPD_Dups WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (TURD_ID, INSERT_DATETIME), LOCATION = USER_DB)
AS
	SELECT A.TURD_ID, A.INSERT_DATETIME
	FROM TXNOWNER.TA_TXN_RITE_DATAS_CT_UPD A
	INNER JOIN 
		(
			SELECT TURD_ID
			FROM TXNOWNER.TA_TXN_RITE_DATAS_CT_UPD
			GROUP BY TURD_ID
			HAVING COUNT(*)>1
		) Dups ON A.TURD_ID = Dups.TURD_ID

/*
	Create temp table with Last Update 
*/

IF OBJECT_ID('tempdb..#TA_TXN_RITE_DATAS_CT_UPD_DuplicateLastRowToReInsert')<>0
	DROP TABLE #TA_TXN_RITE_DATAS_CT_UPD_DuplicateLastRowToReInsert

CREATE TABLE #TA_TXN_RITE_DATAS_CT_UPD_DuplicateLastRowToReInsert WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (TURD_ID), LOCATION = USER_DB)
AS
	SELECT  A.VEH_SPEED, A.EVENT_IND, A.LOGON_TIME, A.ACTIVE_VLT_CH, A.TURD_ID, A.TART_TART_ID, A.LOGON_MEANS, A.EMPL_ID, A.VPLT_ID, A.REV_LANE_IND, A.ISF_SERIAL_NO, A.VES_SERIAL_NO, A.VES_DATE_TIME, A.STANDBY_MODE_STATUS, A.ACM_STATUS, A.AVI_STATUS, A.VEH_AVC_STATUS, A.TREADLE_AVC_STATUS, A.VES_TRIGGER_STATUS, A.VES_STATUS, A.ATT_TERM_STATUS, A.FAC_SRVR_AVI_STATUS, A.FAC_SRVR_UPLOAD_TXNS, A.UPS_STATUS, A.DIGITAL_IO_STATUS, A.NONREV_EMPL_ID, A.LN_STRADDLE_IND, A.ATT_CLASS_ENTERED, A.VIO_IMAGE_REQ, A.COIN_REJECTED, A.INSERT_DATETIME
	FROM TXNOWNER.TA_TXN_RITE_DATAS_CT_UPD A
	INNER JOIN 
		(
			SELECT TURD_ID, MAX(INSERT_DATETIME) AS LAST_INSERT_DATETIME
			FROM #TA_TXN_RITE_DATAS_CT_UPD_Dups
			GROUP BY TURD_ID
		) LastRcrd ON A.TURD_ID = LastRcrd.TURD_ID AND A.INSERT_DATETIME = LastRcrd.LAST_INSERT_DATETIME

/*
	DELETE all the duplicate rows from the target
*/

DELETE FROM TXNOWNER.TA_TXN_RITE_DATAS_CT_UPD 
WHERE EXISTS(SELECT * FROM #TA_TXN_RITE_DATAS_CT_UPD_Dups B WHERE TXNOWNER.TA_TXN_RITE_DATAS_CT_UPD.TURD_ID = B.TURD_ID);


/*
	Re-insert the LAST ROW for Duplicates
*/
INSERT INTO TXNOWNER.TA_TXN_RITE_DATAS_CT_UPD 
	( VEH_SPEED, EVENT_IND, LOGON_TIME, ACTIVE_VLT_CH, TURD_ID, TART_TART_ID, LOGON_MEANS, EMPL_ID, VPLT_ID, REV_LANE_IND, ISF_SERIAL_NO, VES_SERIAL_NO, VES_DATE_TIME, STANDBY_MODE_STATUS, ACM_STATUS, AVI_STATUS, VEH_AVC_STATUS, TREADLE_AVC_STATUS, VES_TRIGGER_STATUS, VES_STATUS, ATT_TERM_STATUS, FAC_SRVR_AVI_STATUS, FAC_SRVR_UPLOAD_TXNS, UPS_STATUS, DIGITAL_IO_STATUS, NONREV_EMPL_ID, LN_STRADDLE_IND, ATT_CLASS_ENTERED, VIO_IMAGE_REQ, COIN_REJECTED, INSERT_DATETIME)
SELECT VEH_SPEED, EVENT_IND, LOGON_TIME, ACTIVE_VLT_CH, TURD_ID, TART_TART_ID, LOGON_MEANS, EMPL_ID, VPLT_ID, REV_LANE_IND, ISF_SERIAL_NO, VES_SERIAL_NO, VES_DATE_TIME, STANDBY_MODE_STATUS, ACM_STATUS, AVI_STATUS, VEH_AVC_STATUS, TREADLE_AVC_STATUS, VES_TRIGGER_STATUS, VES_STATUS, ATT_TERM_STATUS, FAC_SRVR_AVI_STATUS, FAC_SRVR_UPLOAD_TXNS, UPS_STATUS, DIGITAL_IO_STATUS, NONREV_EMPL_ID, LN_STRADDLE_IND, ATT_CLASS_ENTERED, VIO_IMAGE_REQ, COIN_REJECTED, INSERT_DATETIME
FROM #TA_TXN_RITE_DATAS_CT_UPD_DuplicateLastRowToReInsert

/*
	UPDATE all existing rows in the target
*/

IF OBJECT_ID('tempdb..#TA_TXN_RITE_DATAS_CT_UPD_SRC')<>0
	DROP TABLE #TA_TXN_RITE_DATAS_CT_UPD_SRC

CREATE TABLE #TA_TXN_RITE_DATAS_CT_UPD_SRC WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (TURD_ID), LOCATION = USER_DB)
AS
	SELECT	*, 	 
		CASE	WHEN VES_DATE_TIME <> '1970-01-01 00:00:00' 
			THEN CASE WHEN EXISTS (SELECT 1 FROM EDW_RITE.dbo.Time_Zone_Offset TZ WHERE VES_DATE_TIME BETWEEN TZ.DST_Start_Date AND TZ.DST_End_Date)
						THEN DATEADD(HOUR, -5, VES_DATE_TIME)
						ELSE DATEADD(HOUR, -6, VES_DATE_TIME)
					END
		ELSE	VES_DATE_TIME 
		END		AS VES_DATE_TIME_LOCAL
	FROM TXNOWNER.TA_TXN_RITE_DATAS_CT_UPD


UPDATE  TXNOWNER.TA_TXN_RITE_DATAS
SET 
	TXNOWNER.TA_TXN_RITE_DATAS.VEH_SPEED = B.VEH_SPEED
	, TXNOWNER.TA_TXN_RITE_DATAS.EVENT_IND = B.EVENT_IND
	, TXNOWNER.TA_TXN_RITE_DATAS.LOGON_TIME = B.LOGON_TIME
	, TXNOWNER.TA_TXN_RITE_DATAS.ACTIVE_VLT_CH = B.ACTIVE_VLT_CH
	--, TXNOWNER.TA_TXN_RITE_DATAS.TURD_ID = B.TURD_ID
	--, TXNOWNER.TA_TXN_RITE_DATAS.TART_TART_ID = B.TART_TART_ID
	, TXNOWNER.TA_TXN_RITE_DATAS.LOGON_MEANS = B.LOGON_MEANS
	, TXNOWNER.TA_TXN_RITE_DATAS.EMPL_ID = B.EMPL_ID
	, TXNOWNER.TA_TXN_RITE_DATAS.VPLT_ID = B.VPLT_ID
	, TXNOWNER.TA_TXN_RITE_DATAS.REV_LANE_IND = B.REV_LANE_IND
	, TXNOWNER.TA_TXN_RITE_DATAS.ISF_SERIAL_NO = B.ISF_SERIAL_NO
	, TXNOWNER.TA_TXN_RITE_DATAS.VES_SERIAL_NO = B.VES_SERIAL_NO
	, TXNOWNER.TA_TXN_RITE_DATAS.VES_DATE_TIME = B.VES_DATE_TIME
	, TXNOWNER.TA_TXN_RITE_DATAS.STANDBY_MODE_STATUS = B.STANDBY_MODE_STATUS
	, TXNOWNER.TA_TXN_RITE_DATAS.ACM_STATUS = B.ACM_STATUS
	, TXNOWNER.TA_TXN_RITE_DATAS.AVI_STATUS = B.AVI_STATUS
	, TXNOWNER.TA_TXN_RITE_DATAS.VEH_AVC_STATUS = B.VEH_AVC_STATUS
	, TXNOWNER.TA_TXN_RITE_DATAS.TREADLE_AVC_STATUS = B.TREADLE_AVC_STATUS
	, TXNOWNER.TA_TXN_RITE_DATAS.VES_TRIGGER_STATUS = B.VES_TRIGGER_STATUS
	, TXNOWNER.TA_TXN_RITE_DATAS.VES_STATUS = B.VES_STATUS
	, TXNOWNER.TA_TXN_RITE_DATAS.ATT_TERM_STATUS = B.ATT_TERM_STATUS
	, TXNOWNER.TA_TXN_RITE_DATAS.FAC_SRVR_AVI_STATUS = B.FAC_SRVR_AVI_STATUS
	, TXNOWNER.TA_TXN_RITE_DATAS.FAC_SRVR_UPLOAD_TXNS = B.FAC_SRVR_UPLOAD_TXNS
	, TXNOWNER.TA_TXN_RITE_DATAS.UPS_STATUS = B.UPS_STATUS
	, TXNOWNER.TA_TXN_RITE_DATAS.DIGITAL_IO_STATUS = B.DIGITAL_IO_STATUS
	, TXNOWNER.TA_TXN_RITE_DATAS.NONREV_EMPL_ID = B.NONREV_EMPL_ID
	, TXNOWNER.TA_TXN_RITE_DATAS.LN_STRADDLE_IND = B.LN_STRADDLE_IND
	, TXNOWNER.TA_TXN_RITE_DATAS.ATT_CLASS_ENTERED = B.ATT_CLASS_ENTERED
	, TXNOWNER.TA_TXN_RITE_DATAS.VIO_IMAGE_REQ = B.VIO_IMAGE_REQ
	, TXNOWNER.TA_TXN_RITE_DATAS.COIN_REJECTED = B.COIN_REJECTED
	, TXNOWNER.TA_TXN_RITE_DATAS.LAST_UPDATE_TYPE = 'U'
	, TXNOWNER.TA_TXN_RITE_DATAS.LAST_UPDATE_DATE = B.INSERT_DATETIME
	, TXNOWNER.TA_TXN_RITE_DATAS.VES_DATE_TIME_LOCAL = B.VES_DATE_TIME_LOCAL
FROM #TA_TXN_RITE_DATAS_CT_UPD_SRC B
WHERE TXNOWNER.TA_TXN_RITE_DATAS.TURD_ID = B.TURD_ID

