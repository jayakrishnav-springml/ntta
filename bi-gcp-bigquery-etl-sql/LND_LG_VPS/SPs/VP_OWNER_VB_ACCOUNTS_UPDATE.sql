CREATE PROC [VP_OWNER].[VB_ACCOUNTS_UPDATE] AS
/*
	Use this proc to help write the code
		GetUpdateFields 'VP_OWNER','VB_ACCOUNTS'
		You will have to remove the Distribution key from what it generates
*/

/*
	Update Stats on CT_UPD table to help with de-dupping and update steps
*/

EXEC DropStats 'VP_OWNER','VB_ACCOUNTS_CT_UPD'
CREATE STATISTICS STATS_VB_ACCOUNTS_CT_UPD_001 ON VP_OWNER.VB_ACCOUNTS_CT_UPD (VBA_ACCOUNT_ID)
CREATE STATISTICS STATS_VB_ACCOUNTS_CT_UPD_002 ON VP_OWNER.VB_ACCOUNTS_CT_UPD (VBA_ACCOUNT_ID, INSERT_DATETIME)


	UPDATE  VP_OWNER.VB_ACCOUNTS
	SET 
    
		  VP_OWNER.VB_ACCOUNTS.VBA_DATE = B.VBA_DATE
		, VP_OWNER.VB_ACCOUNTS.NEXT_INVOICE_DATE = B.NEXT_INVOICE_DATE
		, VP_OWNER.VB_ACCOUNTS.STATUS = B.STATUS
		, VP_OWNER.VB_ACCOUNTS.DATE_CREATED = B.DATE_CREATED
		, VP_OWNER.VB_ACCOUNTS.DATE_MODIFIED = B.DATE_MODIFIED
		, VP_OWNER.VB_ACCOUNTS.MODIFIED_BY = B.MODIFIED_BY
		, VP_OWNER.VB_ACCOUNTS.CREATED_BY = B.CREATED_BY
		, VP_OWNER.VB_ACCOUNTS.UNINVOICED_COUNT = B.UNINVOICED_COUNT
		, VP_OWNER.VB_ACCOUNTS.OLDEST_UNINVOICED = B.OLDEST_UNINVOICED
		, VP_OWNER.VB_ACCOUNTS.NEXT_GENERATION_DATE = B.NEXT_GENERATION_DATE
		, VP_OWNER.VB_ACCOUNTS.REPRINT_DATE = B.REPRINT_DATE	
		, VP_OWNER.VB_ACCOUNTS.LAST_UPDATE_TYPE = 'U'
		, VP_OWNER.VB_ACCOUNTS.LAST_UPDATE_DATE = B.INSERT_DATETIME
	FROM VP_OWNER.VB_ACCOUNTS_CT_UPD B
	WHERE VP_OWNER.VB_ACCOUNTS.VBA_ACCOUNT_ID = B.VBA_ACCOUNT_ID

