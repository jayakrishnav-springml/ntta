CREATE PROC [IOP_OWNER].[HUB_TVL_BATCH_DETAILS_UPDATE] AS
/*
	Use this proc to help write the code
		GetUpdateFields 'IOP_OWNER','HUB_TVL_BATCH_DETAILS'
		You will have to remove the Distribution key from what it generates
*/

/*
	Update Stats on CT_UPD table to help with de-dupping and update steps
*/

EXEC DropStats 'IOP_OWNER','HUB_TVL_BATCH_DETAILS_CT_UPD'
CREATE STATISTICS STATS_HUB_TVL_BATCH_DETAILS_CT_UPD_001 ON IOP_OWNER.HUB_TVL_BATCH_DETAILS_CT_UPD (HUB_TVL_BATCH_DETAIL_ID)
CREATE STATISTICS STATS_HUB_TVL_BATCH_DETAILS_CT_UPD_002 ON IOP_OWNER.HUB_TVL_BATCH_DETAILS_CT_UPD (HUB_TVL_BATCH_DETAIL_ID, INSERT_DATETIME)

	UPDATE  IOP_OWNER.HUB_TVL_BATCH_DETAILS
	SET 
    
		 IOP_OWNER.HUB_TVL_BATCH_DETAILS.RAW_DR_IOP_HOME_AGENCY_ID = B.RAW_DR_IOP_HOME_AGENCY_ID
		, IOP_OWNER.HUB_TVL_BATCH_DETAILS.RAW_DR_TAG_AGENCY_ID = B.RAW_DR_TAG_AGENCY_ID
		, IOP_OWNER.HUB_TVL_BATCH_DETAILS.RAW_DR_TAG_SERIAL_NUMBER = B.RAW_DR_TAG_SERIAL_NUMBER
		, IOP_OWNER.HUB_TVL_BATCH_DETAILS.RAW_DR_TAG_STATUS = B.RAW_DR_TAG_STATUS
		, IOP_OWNER.HUB_TVL_BATCH_DETAILS.RAW_DR_DISCOUNT_PLANS = B.RAW_DR_DISCOUNT_PLANS
		, IOP_OWNER.HUB_TVL_BATCH_DETAILS.RAW_DR_TAG_TYPE = B.RAW_DR_TAG_TYPE
		, IOP_OWNER.HUB_TVL_BATCH_DETAILS.RAW_DR_TAG_CLASS = B.RAW_DR_TAG_CLASS
		, IOP_OWNER.HUB_TVL_BATCH_DETAILS.RAW_DR_ACCOUNT_NUMBER = B.RAW_DR_ACCOUNT_NUMBER
		, IOP_OWNER.HUB_TVL_BATCH_DETAILS.RAW_DR_FLEET_INDICATOR = B.RAW_DR_FLEET_INDICATOR
		, IOP_OWNER.HUB_TVL_BATCH_DETAILS.CREATED_BY = B.CREATED_BY
		, IOP_OWNER.HUB_TVL_BATCH_DETAILS.DATE_CREATED = B.DATE_CREATED
		, IOP_OWNER.HUB_TVL_BATCH_DETAILS.MODIFIED_BY = B.MODIFIED_BY
		, IOP_OWNER.HUB_TVL_BATCH_DETAILS.DATE_MODIFIED = B.DATE_MODIFIED
		, IOP_OWNER.HUB_TVL_BATCH_DETAILS.DATE_CREATED_MONTH = B.DATE_CREATED_MONTH
		, IOP_OWNER.HUB_TVL_BATCH_DETAILS.LAST_UPDATE_TYPE = 'U'
		, IOP_OWNER.HUB_TVL_BATCH_DETAILS.LAST_UPDATE_DATE = B.INSERT_DATETIME
		, IOP_OWNER.HUB_TVL_BATCH_DETAILS.UNIQUE_BKT_ID = B.UNIQUE_BKT_ID
		, IOP_OWNER.HUB_TVL_BATCH_DETAILS.BUCKET_SEQ_NUMBER = B.BUCKET_SEQ_NUMBER
	FROM 
		IOP_OWNER.HUB_TVL_BATCH_DETAILS_CT_UPD B
	WHERE 
		IOP_OWNER.HUB_TVL_BATCH_DETAILS.HUB_TVL_BATCH_DETAIL_ID = B.HUB_TVL_BATCH_DETAIL_ID

