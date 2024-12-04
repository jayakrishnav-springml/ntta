CREATE PROC [DBO].[ICRS_VPS_XREF_LOAD] AS 
BEGIN

	--STEP #1: CREATE STAGING TABLE
	IF OBJECT_ID('DBO.ICRS_VPS_XREF_NEW') IS NOT NULL DROP TABLE DBO.ICRS_VPS_XREF_NEW;

	--STEP #2: CREATE THE NEW TABLE WITH DISTRIBUTION = HASH([TART_ID]

	-- STATUS_FLAG = 0 -> TRANSACTION_ID and VIOLATION_ID = NULL
	-- STATUS_FLAG = 1 -> TRANSACTION_ID = NULL, VIOLATION_ID <> NULL
	-- STATUS_FLAG = 2 -> TRANSACTION_ID <> NULL, VIOLATION_ID = NULL
	-- STATUS_FLAG = 3 -> TRANSACTION_ID and VIOLATION_ID <> NULL
	-- PARTITIONS with 2 & 3 - the biggest and we INSERT to them and never update or switch
	-- PARTITIONS with 0 & 1 - always to renew with switching 

	CREATE TABLE DBO.[ICRS_VPS_XREF_NEW] 
	WITH (PARTITION   ([STATUS_FLAG] RANGE RIGHT FOR VALUES (1, 2, 3))  
	     ,CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([LANE_VIOL_ID])) 
	AS --EXPLAIN
	WITH ICRS_VPS_XREF_STAGE_1 AS
	(SELECT	LV.LANE_VIOL_ID, V.VIOLATION_ID 
	FROM		[LND_LG_VPS].[VP_OWNER].[LANE_VIOLATIONS] LV 
	LEFT JOIN	[LND_LG_VPS].[VP_OWNER].[VIOLATIONS] V ON V.LANE_VIOL_ID = LV.LANE_VIOL_ID
	)
	,ICRS_VPS_XREF_STAGE_2 AS
	(SELECT	TRANSACTION_ID
			,LANE_VIOL_ID
	FROM	[LND_LG_VPS].[VP_OWNER].[VPS_HOST_TRANSACTIONS] 
	WHERE	LANE_VIOL_ID IS NOT NULL
	)
	,ICRS_VPS_XREF_STAGE_3 AS 
	(SELECT	TRANSACTION_ID
			,VIOLATION_ID 
	FROM	[LND_LG_VPS].[VP_OWNER].[VPS_HOST_TRANSACTIONS] 
	WHERE	VIOLATION_ID IS NOT NULL
	)
	SELECT	ISNULL(STAGE_1.LANE_VIOL_ID, STAGE_2.LANE_VIOL_ID) AS LANE_VIOL_ID 
			, ISNULL(STAGE_1.VIOLATION_ID, STAGE_3.VIOLATION_ID) AS VIOLATION_ID 
			, ISNULL(STAGE_2.TRANSACTION_ID, STAGE_3.TRANSACTION_ID) AS TRANSACTION_ID
			, CAST(CASE 
				WHEN ISNULL(STAGE_2.TRANSACTION_ID, STAGE_3.TRANSACTION_ID) IS NULL AND ISNULL(STAGE_1.VIOLATION_ID, STAGE_3.VIOLATION_ID) IS NULL THEN 0
				WHEN ISNULL(STAGE_2.TRANSACTION_ID, STAGE_3.TRANSACTION_ID) IS NULL AND ISNULL(STAGE_1.VIOLATION_ID, STAGE_3.VIOLATION_ID) IS NOT NULL THEN 1
				WHEN ISNULL(STAGE_2.TRANSACTION_ID, STAGE_3.TRANSACTION_ID) IS NOT NULL AND ISNULL(STAGE_1.VIOLATION_ID, STAGE_3.VIOLATION_ID) IS NULL THEN 2
				ELSE 3
			END AS TINYINT) AS STATUS_FLAG 
			--CAST(2 * CAST(ISNULL(STAGE_2.TRANSACTION_ID, 0) AS BIT)
			--+ CAST(ISNULL(COALESCE(STAGE_1.VIOLATION_ID, STAGE_3.VIOLATION_ID), 0) AS BIT) AS TINYINT) AS STATUS_FLAG 
	FROM	ICRS_VPS_XREF_STAGE_1  STAGE_1
	LEFT JOIN ICRS_VPS_XREF_STAGE_2 STAGE_2 
		ON STAGE_1.LANE_VIOL_ID = STAGE_2.LANE_VIOL_ID
	LEFT JOIN ICRS_VPS_XREF_STAGE_3 STAGE_3 
		ON STAGE_1.VIOLATION_ID = STAGE_3.VIOLATION_ID
	OPTION (LABEL = 'ICRS_VPS_XREF LOAD');



	--STEP #3: REPLACE OLD TABLE WITH NEW
	IF OBJECT_ID('DBO.ICRS_VPS_XREF_OLD') IS NOT NULL      DROP TABLE DBO.ICRS_VPS_XREF_OLD;
	IF OBJECT_ID('DBO.ICRS_VPS_XREF') IS NOT NULL          RENAME OBJECT::DBO.ICRS_VPS_XREF TO ICRS_VPS_XREF_OLD;
	RENAME OBJECT::DBO.ICRS_VPS_XREF_NEW TO ICRS_VPS_XREF; 
	IF OBJECT_ID('DBO.ICRS_VPS_XREF_OLD') IS NOT NULL      DROP TABLE DBO.ICRS_VPS_XREF_OLD;

	--STEP #3: CREATE STATISTICS
	CREATE STATISTICS [STATS_ICRS_VPS_XREF_001] ON ICRS_VPS_XREF (LANE_VIOL_ID);
	CREATE STATISTICS [STATS_ICRS_VPS_XREF_002] ON ICRS_VPS_XREF (VIOLATION_ID);
	CREATE STATISTICS [STATS_ICRS_VPS_XREF_003] ON ICRS_VPS_XREF (TRANSACTION_ID);
	CREATE STATISTICS [STATS_ICRS_VPS_XREF_005] ON ICRS_VPS_XREF (LANE_VIOL_ID, VIOLATION_ID, TRANSACTION_ID);
	

END

