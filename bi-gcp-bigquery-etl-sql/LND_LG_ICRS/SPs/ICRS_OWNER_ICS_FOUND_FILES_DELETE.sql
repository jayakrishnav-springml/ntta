CREATE PROC [ICRS_OWNER].[ICS_FOUND_FILES_DELETE] AS


EXEC DropStats 'ICRS_OWNER','ICS_FOUND_FILES_CT_DEL'
CREATE STATISTICS STATS_ICS_FOUND_FILES_CT_DEL_001 ON ICRS_OWNER.ICS_FOUND_FILES_CT_DEL (FF_ID)
CREATE STATISTICS STATS_ICS_FOUND_FILES_CT_DEL_002 ON ICRS_OWNER.ICS_FOUND_FILES_CT_DEL (FF_ID, INSERT_DATETIME)



UPDATE ICRS_OWNER.ICS_FOUND_FILES
	SET  LAST_UPDATE_TYPE = 'D'
		, LAST_UPDATE_DATE = B.INSERT_DATETIME
FROM ICRS_OWNER.ICS_FOUND_FILES_CT_DEL B
WHERE ICRS_OWNER.ICS_FOUND_FILES.FF_ID = B.FF_ID

/*
	To Test With:

	INSERT INTO ICRS_OWNER.VIOLATIONS_CT_DEL
	SELECT TOP 1 * FROM ICRS_OWNER.VIOLATIONS_CT_DEL 

	SELECT * FROM ICRS_OWNER.VIOLATIONS WHERE LAST_UPDATE_TYPE = 'D'
*/

