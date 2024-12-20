CREATE PROC [DBO].[VPS_TGS_XREF_LOAD] AS 
BEGIN

	--STEP #1: CREATE STAGING TABLE
	IF OBJECT_ID('dbo.VPS_TGS_XREF_NEW')>0 DROP TABLE dbo.VPS_TGS_XREF_NEW;

	--STEP #2: Create the NEW table with DISTRIBUTION = HASH([TART_ID]
	CREATE TABLE dbo.[VPS_TGS_XREF_NEW] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TRANSACTION_ID))
	AS --EXPLAIN
	SELECT    CAST(TT.SOURCE_TRXN_ID AS DECIMAL(14, 0))  AS TRANSACTION_ID
			, TTXN_ID TTXN_ID
			--, TRANSACTION_FILE_DETAIL_ID	--SELECT TOP 10 *
	FROM	LND_LG_TS.TAG_OWNER.TOLL_TRANSACTIONS TT
	WHERE	TT.SOURCE_CODE IN ('M','O','V','W','X','Z')
	AND		CREDITED_FLAG =  'N'
	AND		SOURCE_TRXN_ID IS NOT NULL

	--STEP #2: Replace OLD table with NEW
	IF OBJECT_ID('dbo.VPS_TGS_XREF_OLD')>0      DROP TABLE dbo.VPS_TGS_XREF_OLD;
	IF OBJECT_ID('dbo.VPS_TGS_XREF')>0          RENAME OBJECT::dbo.VPS_TGS_XREF TO VPS_TGS_XREF_OLD;
	RENAME OBJECT::dbo.VPS_TGS_XREF_NEW TO VPS_TGS_XREF; 
	IF OBJECT_ID('dbo.VPS_TGS_XREF_OLD')>0      DROP TABLE dbo.VPS_TGS_XREF_OLD;

	--STEP #3: CREATE STATISTICS
	--CREATE STATISTICS [STATS_VPS_TGS_XREF_001] ON VPS_TGS_XREF (TRANSACTION_FILE_DETAIL_ID);
	CREATE STATISTICS [STATS_VPS_TGS_XREF_002] ON VPS_TGS_XREF (TRANSACTION_ID);
	CREATE STATISTICS [STATS_VPS_TGS_XREF_003] ON VPS_TGS_XREF (TTXN_ID);
	CREATE STATISTICS [STATS_VPS_TGS_XREF_004] ON VPS_TGS_XREF (TRANSACTION_ID, TTXN_ID);
	
	--STEP #4: Total Records
	--SELECT COUNT_BIG(1) FROM dbo.VPS_TGS_XREF; --959,509,946 6,761,367,888 6,758,929,234
	--SELECT TOP 10 * FROM VPS_TGS_XREF
END

