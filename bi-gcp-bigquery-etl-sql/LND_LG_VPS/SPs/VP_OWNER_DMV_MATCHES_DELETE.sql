CREATE PROC [VP_OWNER].[DMV_MATCHES_DELETE] AS


EXEC DropStats 'VP_OWNER','DMV_MATCHES_CT_DEL'
CREATE STATISTICS STATS_DMV_MATCHES_CT_DEL_001 ON VP_OWNER.DMV_MATCHES_CT_DEL (ID)
CREATE STATISTICS STATS_DMV_MATCHES_CT_DEL_002 ON VP_OWNER.DMV_MATCHES_CT_DEL (ID, INSERT_DATETIME)



UPDATE VP_OWNER.DMV_MATCHES
	SET  LAST_UPDATE_TYPE = 'D'
		, LAST_UPDATE_DATE = B.INSERT_DATETIME
FROM VP_OWNER.DMV_MATCHES_CT_DEL B
WHERE VP_OWNER.DMV_MATCHES.ID = B.ID

/*
	To Test With:

	INSERT INTO VP_OWNER.VIOLATIONS_CT_DEL
	SELECT TOP 1 * FROM VP_OWNER.VIOLATIONS_CT_DEL 

	SELECT * FROM VP_OWNER.VIOLATIONS WHERE LAST_UPDATE_TYPE = 'D'
*/

