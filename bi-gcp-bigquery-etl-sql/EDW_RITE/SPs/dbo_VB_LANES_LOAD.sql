CREATE PROC [DBO].[VB_LANES_LOAD] AS 

--DECLARE @LAST_UPDATE_DATE datetime2(2) 
--exec dbo.GetLoadStartDatetime 'dbo.VB_LANES', @LAST_UPDATE_DATE OUTPUT

IF OBJECT_ID('dbo.VB_LANES_STAGE')<>0
	DROP TABLE dbo.VB_LANES_STAGE

CREATE TABLE dbo.VB_LANES_STAGE WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (VBL_ID)) 
AS 
-- EXPLAIN
SELECT VBL_ID, LANE_ID, VBL_START, VBL_END, A.LAST_UPDATE_DATE
FROM LND_LG_VPS.[VP_OWNER].[VB_LANES] A
OPTION (LABEL = 'VB_LANES_LOAD: VB_LANES_STAGE');

CREATE STATISTICS STATS_VB_LANES_STAGE_001 ON VB_LANES_STAGE (VBL_ID)


UPDATE dbo.VB_LANES
SET  LANE_ID = B.LANE_ID	
	, VBL_START = B.VBL_START
	, VBL_END = B.VBL_END
	, LAST_UPDATE_DATE = B.LAST_UPDATE_DATE
FROM dbo.VB_LANES_STAGE B
WHERE 
	dbo.VB_LANES.VBL_ID = B.VBL_ID
	AND 
		(
				dbo.VB_LANES.LANE_ID <> B.LANE_ID
			OR dbo.VB_LANES.VBL_START <> B.VBL_START
			OR dbo.VB_LANES.VBL_END <> B.VBL_END
		)

INSERT INTO dbo.VB_LANES ( VBL_ID, LANE_ID, VBL_START, VBL_END, INSERT_DATE, LAST_UPDATE_DATE)
SELECT  A.VBL_ID, A.LANE_ID, A.VBL_START, A.VBL_END, A.LAST_UPDATE_DATE, A.LAST_UPDATE_DATE
FROM dbo.VB_LANES_STAGE A
LEFT JOIN dbo.VB_LANES B ON A.VBL_ID = B.VBL_ID
WHERE B.VBL_ID IS NULL



