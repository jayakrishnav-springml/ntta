CREATE PROC [VP_OWNER].[FA_FLEET_TRANSACTIONS_DELETE] AS


EXEC DropStats 'VP_OWNER','FA_FLEET_TRANSACTIONS_CT_DEL'
CREATE STATISTICS STATS_FA_FLEET_TRANSACTIONS_CT_DEL_001 ON VP_OWNER.FA_FLEET_TRANSACTIONS_CT_DEL (FLEET_TXN_ID)
CREATE STATISTICS STATS_FA_FLEET_TRANSACTIONS_CT_DEL_002 ON VP_OWNER.FA_FLEET_TRANSACTIONS_CT_DEL (FLEET_TXN_ID, INSERT_DATETIME)



UPDATE VP_OWNER.FA_FLEET_TRANSACTIONS
	SET  LAST_UPDATE_TYPE = 'D'
		, LAST_UPDATE_DATE = B.INSERT_DATETIME
FROM VP_OWNER.FA_FLEET_TRANSACTIONS_CT_DEL B
WHERE VP_OWNER.FA_FLEET_TRANSACTIONS.FLEET_TXN_ID = B.FLEET_TXN_ID

/*
	To Test With:

	INSERT INTO VP_OWNER.VIOLATIONS_CT_DEL
	SELECT TOP 1 * FROM VP_OWNER.VIOLATIONS_CT_DEL 

	SELECT * FROM VP_OWNER.VIOLATIONS WHERE LAST_UPDATE_TYPE = 'D'
*/

