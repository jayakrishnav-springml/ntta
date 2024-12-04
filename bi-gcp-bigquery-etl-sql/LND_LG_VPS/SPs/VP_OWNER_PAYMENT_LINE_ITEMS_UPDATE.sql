CREATE PROC [VP_OWNER].[PAYMENT_LINE_ITEMS_UPDATE] AS
/*
	Use this proc to help write the code
		GetUpdateFields 'VP_OWNER','PAYMENT_LINE_ITEMS'
		You will have to remove the Distribution key from what it generates
*/

/*
	Update Stats on CT_UPD table to help with de-dupping and update steps
*/

EXEC DropStats 'VP_OWNER','PAYMENT_LINE_ITEMS_CT_UPD'
CREATE STATISTICS STATS_PAYMENT_LINE_ITEMS_CT_UPD_001 ON VP_OWNER.PAYMENT_LINE_ITEMS_CT_UPD (PAYMENT_LINE_ITEM_ID)
CREATE STATISTICS STATS_PAYMENT_LINE_ITEMS_CT_UPD_002 ON VP_OWNER.PAYMENT_LINE_ITEMS_CT_UPD (PAYMENT_LINE_ITEM_ID, INSERT_DATETIME)


	UPDATE  VP_OWNER.PAYMENT_LINE_ITEMS
	SET 
    
		  VP_OWNER.PAYMENT_LINE_ITEMS.PAYMENT_LINE_ITEM_DATE = B.PAYMENT_LINE_ITEM_DATE
		, VP_OWNER.PAYMENT_LINE_ITEMS.PMT_TXN_TYPE = B.PMT_TXN_TYPE
		, VP_OWNER.PAYMENT_LINE_ITEMS.PAYMENT_LINE_ITEM_AMOUNT = B.PAYMENT_LINE_ITEM_AMOUNT
		, VP_OWNER.PAYMENT_LINE_ITEMS.PAYMENT_FORM = B.PAYMENT_FORM
		, VP_OWNER.PAYMENT_LINE_ITEMS.CHECK_MO_DATE = B.CHECK_MO_DATE
		, VP_OWNER.PAYMENT_LINE_ITEMS.NAME_ON_PAYMENT = B.NAME_ON_PAYMENT
		, VP_OWNER.PAYMENT_LINE_ITEMS.CREDIT_CARD_TYPE = B.CREDIT_CARD_TYPE
		, VP_OWNER.PAYMENT_LINE_ITEMS.DRIVER_LIC_NBR = B.DRIVER_LIC_NBR
		, VP_OWNER.PAYMENT_LINE_ITEMS.DRIVER_LIC_STATE = B.DRIVER_LIC_STATE
		, VP_OWNER.PAYMENT_LINE_ITEMS.ADDRESS = B.ADDRESS
		, VP_OWNER.PAYMENT_LINE_ITEMS.CITY = B.CITY
		, VP_OWNER.PAYMENT_LINE_ITEMS.STATE = B.STATE
		, VP_OWNER.PAYMENT_LINE_ITEMS.ZIP_CODE = B.ZIP_CODE
		, VP_OWNER.PAYMENT_LINE_ITEMS.EMAIL_ADDRESS = B.EMAIL_ADDRESS
		, VP_OWNER.PAYMENT_LINE_ITEMS.PAYMENT_STATUS = B.PAYMENT_STATUS
		, VP_OWNER.PAYMENT_LINE_ITEMS.REF_LINE_ITEM_ID = B.REF_LINE_ITEM_ID
		, VP_OWNER.PAYMENT_LINE_ITEMS.ONLINE_EVS_TRANS_ID = B.ONLINE_EVS_TRANS_ID
		, VP_OWNER.PAYMENT_LINE_ITEMS.DATE_CREATED = B.DATE_CREATED
		, VP_OWNER.PAYMENT_LINE_ITEMS.CREATED_BY = B.CREATED_BY
		, VP_OWNER.PAYMENT_LINE_ITEMS.DATE_MODIFIED = B.DATE_MODIFIED
		, VP_OWNER.PAYMENT_LINE_ITEMS.MODIFIED_BY = B.MODIFIED_BY		
		, VP_OWNER.PAYMENT_LINE_ITEMS.LAST_UPDATE_TYPE = 'U'
		, VP_OWNER.PAYMENT_LINE_ITEMS.LAST_UPDATE_DATE = B.INSERT_DATETIME
	FROM VP_OWNER.PAYMENT_LINE_ITEMS_CT_UPD B
	WHERE VP_OWNER.PAYMENT_LINE_ITEMS.PAYMENT_LINE_ITEM_ID = B.PAYMENT_LINE_ITEM_ID

