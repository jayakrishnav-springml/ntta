CREATE PROC [DBO].[AVI_TAG_STATUSES_LOAD] AS 

	IF OBJECT_ID('dbo.AVI_TAG_STATUSES_NEW')>0        DROP TABLE dbo.AVI_TAG_STATUSES_NEW;

	CREATE TABLE dbo.AVI_TAG_STATUSES_NEW WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX ([AVI_TAG_STATUS])) 
	AS 
	-- EXPLAIN
	SELECT [AVI_TAG_STATUS], [AVTS_DESC] [AVI_TAG_STATUS_DESCR], GETDATE() AS INSERT_DATE
	FROM LND_LG_HOST.TXNOWNER.AVI_TAG_STATUSES A
	OPTION (LABEL = 'AVI_TAG_STATUSES_LOAD: AVI_TAG_STATUSES');

	IF OBJECT_ID('dbo.AVI_TAG_STATUSES')>0 		   RENAME OBJECT::dbo.AVI_TAG_STATUSES TO AVI_TAG_STATUSES_OLD;
	RENAME OBJECT::dbo.AVI_TAG_STATUSES_NEW TO AVI_TAG_STATUSES;
	IF OBJECT_ID('dbo.AVI_TAG_STATUSES_OLD')>0	   DROP TABLE dbo.AVI_TAG_STATUSES_OLD

	CREATE STATISTICS STATS_AVI_TAG_STATUSES_001 ON DBO.AVI_TAG_STATUSES ([AVI_TAG_STATUS])


	INSERT INTO dbo.AVI_TAG_STATUSES 
	SELECT '-1', '(Null)', GETDATE() AS INSERT_DATE
	WHERE NOT EXISTS(SELECT * FROM LND_LG_HOST.TXNOWNER.AVI_TAG_STATUSES where [AVI_TAG_STATUS] = '-1')


