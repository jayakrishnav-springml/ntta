CREATE PROC [DBO].[HOST_ICRS_VPS_TGS_XREF_LOAD] AS 
BEGIN

	--STEP #1: CREATE STAGING TABLE
	IF OBJECT_ID('dbo.[HOST_ICRS_TGS_XREF_NEW]')>0 DROP TABLE dbo.[HOST_ICRS_TGS_XREF_NEW];

	--STEP #2: Create the NEW table with DISTRIBUTION = HASH([TART_ID] HOST_ICRS & HOST_TGS
	--CREATE TABLE dbo.[[HOST_ICRS_TGS_XREF_NEW]] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TART_ID))
	CREATE TABLE dbo.[HOST_ICRS_TGS_XREF_NEW] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(LANE_VIOL_ID))
	AS --EXPLAIN
	SELECT  COALESCE(HOST.TART_ID, TGS.TART_ID) TART_ID, 
			HOST.LANE_VIOL_ID, --COALESCE(HOST.LANE_VIOL_ID, VPS.LANE_VIOL_ID) LANE_VIOL_ID,
			--VPS.VIOLATION_ID,
			--COALESCE(TGS_VTOLL.TRANSACTION_ID, VPS.TRANSACTION_ID) TRANSACTION_ID,
			TGS.TTXN_ID,--COALESCE(TGS.TTXN_ID, TGS_VTOLL.TTXN_ID) TTXN_ID,
			COALESCE(HOST.TRANSACTION_FILE_DETAIL_ID,TGS.TRANSACTION_FILE_DETAIL_ID) TRANSACTION_FILE_DETAIL_ID --,VPS.TRANSACTION_FILE_DETAIL_ID,TGS_VTOLL.TRANSACTION_FILE_DETAIL_ID
			--EXPLAIN SELECT TOP(100) *
	FROM	dbo.HOST_ICRS_XREF HOST --HOST
	FULL OUTER JOIN dbo.HOST_TGS_XREF TGS ON TGS.TART_ID = HOST.TART_ID  --AND HOST.TART_ID IS NOT NULL
	--SELECT COUNT_BIG(1) FROM dbo.[HOST_ICRS_TGS_XREF_NEW]; --6,643,624,365

	--STEP #3: Create the NEW table with DISTRIBUTION = HASH([TART_ID] ICRS_VPS & VPS_TGS
	IF OBJECT_ID('dbo.ICRS_VPS_TGS_XREF_STAGE')>0 DROP TABLE dbo.ICRS_VPS_TGS_XREF_STAGE;
	CREATE TABLE dbo.ICRS_VPS_TGS_XREF_STAGE WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(LANE_VIOL_ID))
	AS --EXPLAIN
	SELECT  ICRS.LANE_VIOL_ID, VIOLATION_ID, 
			COALESCE(ICRS.TRANSACTION_ID, VPS.TRANSACTION_ID) TRANSACTION_ID,
			VPS.TTXN_ID,
			COALESCE(ICRS.TRANSACTION_FILE_DETAIL_ID,VPS.TRANSACTION_FILE_DETAIL_ID) TRANSACTION_FILE_DETAIL_ID --TGS_VTOLL.TRANSACTION_FILE_DETAIL_ID
			--EXPLAIN SELECT TOP(100) * --from dbo.VPS_TGS_XREF
	FROM	[ICRS_VPS_XREF] ICRS-- where TRANSACTION_ID is not null 
	LEFT JOIN	dbo.VPS_TGS_XREF VPS ON VPS.TRANSACTION_ID = ICRS.TRANSACTION_ID  --AND ICRS.LANE_VIOL_ID IS NOT NULL
	--SELECT COUNT_BIG(1) FROM dbo.[ICRS_VPS_TGS_XREF_STAGE]; --2,030,657,233

	--STEP #4: Create the NEW table with DISTRIBUTION = HASH([TART_ID] [HOST_ICRS_TGS_XREF_NEW] & ICRS_VPS_TGS_XREF_STAGE
	IF OBJECT_ID('dbo.HOST_ICRS_VPS_TGS_XREF_FINAL')>0 DROP TABLE dbo.HOST_ICRS_VPS_TGS_XREF_FINAL;
	CREATE TABLE dbo.HOST_ICRS_VPS_TGS_XREF_FINAL WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TART_ID))
	AS --EXPLAIN
	SELECT  HOST.TART_ID, 
			COALESCE(HOST.LANE_VIOL_ID, TGS_VTOLL.LANE_VIOL_ID) LANE_VIOL_ID, --COALESCE(HOST.LANE_VIOL_ID, VPS.LANE_VIOL_ID) LANE_VIOL_ID,
			TGS_VTOLL.VIOLATION_ID VIOLATION_ID,
			TGS_VTOLL.TRANSACTION_ID,
			COALESCE(HOST.TTXN_ID, TGS_VTOLL.TTXN_ID) TTXN_ID,
			COALESCE(HOST.TRANSACTION_FILE_DETAIL_ID,TGS_VTOLL.TRANSACTION_FILE_DETAIL_ID) TRANSACTION_FILE_DETAIL_ID
			--EXPLAIN SELECT TOP(100) *
	FROM	HOST_ICRS_TGS_XREF_NEW HOST
	FULL OUTER JOIN	dbo.ICRS_VPS_TGS_XREF_STAGE TGS_VTOLL ON TGS_VTOLL.LANE_VIOL_ID = HOST.LANE_VIOL_ID -- AND TGS_VTOLL.TRANSACTION_ID IS NOT NULL
	--SELECT COUNT_BIG(1) FROM dbo.[HOST_ICRS_VPS_TGS_XREF_FINAL]; --8390660443

	----STEP #3: Create the NEW table with DISTRIBUTION = HASH([TART_ID]
	--IF OBJECT_ID('dbo.HOST_ICRS_VPS_TGS_XREF_STAGE')>0 DROP TABLE dbo.HOST_ICRS_VPS_TGS_XREF_STAGE;
	--CREATE TABLE dbo.[HOST_ICRS_VPS_TGS_XREF_STAGE] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TRANSACTION_ID))
	--AS --EXPLAIN
	--SELECT  DISTINCT HOST.TART_ID, HOST.TTXN_ID,
	--		COALESCE(HOST.LANE_VIOL_ID, VPS.LANE_VIOL_ID) LANE_VIOL_ID,
	--		VPS.VIOLATION_ID,
	--		VPS.TRANSACTION_ID,--COALESCE(TGS_VTOLL.TRANSACTION_ID, VPS.TRANSACTION_ID) TRANSACTION_ID,
	--		COALESCE(HOST.TRANSACTION_FILE_DETAIL_ID,VPS.TRANSACTION_FILE_DETAIL_ID) TRANSACTION_FILE_DETAIL_ID --TGS_VTOLL.TRANSACTION_FILE_DETAIL_ID
	--		--EXPLAIN SELECT TOP(100) *
	--FROM	[HOST_ICRS_TGS_XREF_NEW] HOST
	--LEFT JOIN	dbo.ICRS_VPS_XREF VPS ON VPS.LANE_VIOL_ID = HOST.LANE_VIOL_ID  --AND HOST.LANE_VIOL_ID IS NOT NULL
	----SELECT COUNT_BIG(1) FROM dbo.[HOST_ICRS_VPS_TGS_XREF_STAGE]; --8,287,533,513 

	----STEP #4: Create the NEW table with DISTRIBUTION = HASH([TART_ID]
	--IF OBJECT_ID('dbo.HOST_ICRS_VPS_TGS_XREF_FINAL')>0 DROP TABLE dbo.HOST_ICRS_VPS_TGS_XREF_FINAL;
	--CREATE TABLE dbo.HOST_ICRS_VPS_TGS_XREF_FINAL WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TART_ID))
	--AS --EXPLAIN
	--SELECT  DISTINCT HOST.TART_ID, 
	--		COALESCE(HOST.LANE_VIOL_ID, -1) LANE_VIOL_ID, --COALESCE(HOST.LANE_VIOL_ID, VPS.LANE_VIOL_ID) LANE_VIOL_ID,
	--		COALESCE(HOST.VIOLATION_ID, -1) VIOLATION_ID,
	--		COALESCE(TGS_VTOLL.TRANSACTION_ID, HOST.TRANSACTION_ID, -1) TRANSACTION_ID,
	--		COALESCE(HOST.TTXN_ID, TGS_VTOLL.TTXN_ID, -1) TTXN_ID,
	--		COALESCE(HOST.TRANSACTION_FILE_DETAIL_ID,TGS_VTOLL.TRANSACTION_FILE_DETAIL_ID, -1) TRANSACTION_FILE_DETAIL_ID
	--		--EXPLAIN SELECT TOP(100) *
	--FROM	[HOST_ICRS_VPS_TGS_XREF_STAGE] HOST
	--LEFT JOIN	dbo.VPS_TGS_XREF TGS_VTOLL ON TGS_VTOLL.TRANSACTION_ID = HOST.TRANSACTION_ID -- AND TGS_VTOLL.TRANSACTION_ID IS NOT NULL

	--STEP #2: Replace OLD table with NEW
	IF OBJECT_ID('dbo.HOST_ICRS_VPS_TGS_XREF_OLD')>0      DROP TABLE dbo.HOST_ICRS_VPS_TGS_XREF_OLD;
	IF OBJECT_ID('dbo.HOST_ICRS_VPS_TGS_XREF')>0          RENAME OBJECT::dbo.HOST_ICRS_VPS_TGS_XREF TO HOST_ICRS_VPS_TGS_XREF_OLD;
	RENAME OBJECT::dbo.HOST_ICRS_VPS_TGS_XREF_FINAL TO HOST_ICRS_VPS_TGS_XREF; 
	--IF OBJECT_ID('dbo.HOST_ICRS_VPS_TGS_XREF_OLD')>0      DROP TABLE dbo.HOST_ICRS_VPS_TGS_XREF_OLD;

	--STEP #3: CREATE STATISTICS
	CREATE STATISTICS [STATS_HOST_ICRS_VPS_TGS_XREF_001] ON HOST_ICRS_VPS_TGS_XREF (TART_ID);
	CREATE STATISTICS [STATS_HOST_ICRS_VPS_TGS_XREF_002] ON HOST_ICRS_VPS_TGS_XREF (LANE_VIOL_ID);
	CREATE STATISTICS [STATS_HOST_ICRS_VPS_TGS_XREF_003] ON HOST_ICRS_VPS_TGS_XREF (TRANSACTION_ID);
	CREATE STATISTICS [STATS_HOST_ICRS_VPS_TGS_XREF_004] ON HOST_ICRS_VPS_TGS_XREF (TART_ID, LANE_VIOL_ID, TRANSACTION_ID);
		
	--STEP #4: Total Records
	SELECT COUNT_BIG(1) FROM dbo.HOST_ICRS_VPS_TGS_XREF; --8,287,533,513
END

