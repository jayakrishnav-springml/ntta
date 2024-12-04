CREATE PROC [ICRS_OWNER].[ICS_LANE_VIOL_IMAGES_Update_Stats] AS

EXEC DropStats 'ICRS_OWNER','ICS_LANE_VIOL_IMAGES'
CREATE STATISTICS STATS_ICS_LANE_VIOL_IMAGES_001 ON ICRS_OWNER.ICS_LANE_VIOL_IMAGES (LANE_VIOL_ID)
CREATE STATISTICS STATS_ICS_LANE_VIOL_IMAGES_002 ON ICRS_OWNER.ICS_LANE_VIOL_IMAGES (LANE_VIOL_ID,VIOL_IMAGE_SEQ)
CREATE STATISTICS STATS_ICS_LANE_VIOL_IMAGES_003 ON ICRS_OWNER.ICS_LANE_VIOL_IMAGES (LANE_VIOL_ID, LAST_UPDATE_DATE)
CREATE STATISTICS STATS_ICS_LANE_VIOL_IMAGES_004 ON ICRS_OWNER.ICS_LANE_VIOL_IMAGES (LAST_UPDATE_DATE)
