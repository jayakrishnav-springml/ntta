CREATE PROC [VP_OWNER].[VB_ACCOUNTS_DELETE] AS


EXEC DropStats 'VP_OWNER','VB_ACCOUNTS_CT_DEL'
CREATE STATISTICS STATS_VB_ACCOUNTS_CT_DEL_001 ON VP_OWNER.VB_ACCOUNTS_CT_DEL (VBA_ACCOUNT_ID)
CREATE STATISTICS STATS_VB_ACCOUNTS_CT_DEL_002 ON VP_OWNER.VB_ACCOUNTS_CT_DEL (VBA_ACCOUNT_ID, INSERT_DATETIME)



UPDATE VP_OWNER.VB_ACCOUNTS
	SET  LAST_UPDATE_TYPE = 'D'
		, LAST_UPDATE_DATE = B.INSERT_DATETIME
FROM VP_OWNER.VB_ACCOUNTS_CT_DEL B
WHERE VP_OWNER.VB_ACCOUNTS.VBA_ACCOUNT_ID = B.VBA_ACCOUNT_ID

/*
	To Test With:

	INSERT INTO VP_OWNER.VIOLATIONS_CT_DEL
	SELECT TOP 1 * FROM VP_OWNER.VIOLATIONS_CT_DEL 

	SELECT * FROM VP_OWNER.VIOLATIONS WHERE LAST_UPDATE_TYPE = 'D'
*/

