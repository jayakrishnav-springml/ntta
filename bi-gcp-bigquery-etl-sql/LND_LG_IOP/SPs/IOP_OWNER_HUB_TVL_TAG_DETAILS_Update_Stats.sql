CREATE PROC [IOP_OWNER].[HUB_TVL_TAG_DETAILS_Update_Stats] AS

EXEC DropStats 'IOP_OWNER','HUB_TVL_TAG_DETAILS'
CREATE STATISTICS STATS_HUB_TVL_TAG_DETAILS_001 ON IOP_OWNER.HUB_TVL_TAG_DETAILS (HUB_TVL_TAG_DETAIL_ID)
CREATE STATISTICS STATS_HUB_TVL_TAG_DETAILS_003 ON IOP_OWNER.HUB_TVL_TAG_DETAILS (HUB_TVL_TAG_DETAIL_ID, LAST_UPDATE_DATE)
CREATE STATISTICS STATS_HUB_TVL_TAG_DETAILS_004 ON IOP_OWNER.HUB_TVL_TAG_DETAILS (LAST_UPDATE_DATE)

