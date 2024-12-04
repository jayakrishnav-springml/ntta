CREATE PROC [DMVLD].[TITLES_INSERT] AS


EXEC DropStats 'DMVLD','TITLES_CT_INS'
CREATE STATISTICS STATS_TITLES_CT_INS_001 ON DMVLD.TITLES_CT_INS (ID)

INSERT INTO DMVLD.TITLES
	(
		       ID, DOCNO, VEHI_ID, OWNR_ID, TITLE_ISSUE_DATE, IS_CURRENT, CREATED_BY, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED, SOURCE_ID, END_SOURCE_ID,
			   SOURCE_CODE, END_SOURCE_CODE, DOCNO_ON_FILE, LAST_UPDATE_DATE, LAST_UPDATE_TYPE
	)
SELECT 

 A.ID, A.DOCNO, A.VEHI_ID, A.OWNR_ID, A.TITLE_ISSUE_DATE, A.IS_CURRENT, A.CREATED_BY, A.DATE_CREATED, A.MODIFIED_BY, A.DATE_MODIFIED, A.SOURCE_ID, A.END_SOURCE_ID,
 A.SOURCE_CODE, A.END_SOURCE_CODE, A.DOCNO_ON_FILE,A.INSERT_DATETIME, 'I' as LAST_UPDATE_TYPE

FROM DMVLD.TITLES_CT_INS A
LEFT JOIN DMVLD.TITLES B ON A.ID = B.ID
WHERE B.ID IS NULL


