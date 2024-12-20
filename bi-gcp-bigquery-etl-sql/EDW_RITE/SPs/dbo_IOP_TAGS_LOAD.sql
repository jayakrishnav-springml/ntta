CREATE PROC [DBO].[IOP_TAGS_LOAD] AS

/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.IOP_TAGS_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.IOP_TAGS_LOAD
GO

EXEC DBO.IOP_TAGS_LOAD
*/

/*	
SELECT TOP 100 *
FROM IOP_TAGS 
WHERE TT_ID = -1
SELECT COUNT_BIG(1) FROM IOP_TAGS -- 11 547 178 


SELECT * FROM edw_rite.dbo.PROCESS_LOG 
WHERE LOG_SOURCE = 'IOP_TAGS' AND LOG_DATE > '2019-09-01 8:00:00'
ORDER BY LOG_SOURCE, LOG_DATE


*/  

/*
	INSERT INTO dbo.IOP_TAGS
	(AGENCY_ID,TAG_ID,TAG_STATUS,LAST_READ_LOC,LAST_READ_DATE,TAG_TYPE_CODE,OWNER_AGENCY,POS_ID,LAST_UPDATE_TYPE,LAST_UPDATE_DATE)
	VALUES
	('-1','-1','',NULL,NULL,'','',-1,'I','2000-01-01')
*/

--STEP #1: CREATE STAGING TABLE
DECLARE @FULL_LOAD BIT  
DECLARE @LAST_UPDATE_DATE datetime2(2) = GETDATE(), @LAST_TT_ID BIGINT, @TABLE_NAME VARCHAR(200) = 'IOP_TAGS'
--EXEC dbo.GetLoadStartDatetime 'dbo.PAYMENT_LINE_ITEMS_VPS', @LAST_UPDATE_DATE OUTPUT
SELECT @FULL_LOAD = CASE WHEN OBJECT_ID('dbo.IOP_TAGS') IS NOT NULL THEN 0 ELSE 1 END

DECLARE @LOG_START_DATE DATETIME2 (2), @LOG_MESSAGE VARCHAR(1000), @ROW_COUNT BIGINT


--CASE WHEN @LAST_UPDATE_DATE IS NULL THEN 1 ELSE 0 END

IF @FULL_LOAD = 1
BEGIN

	SELECT  @LOG_MESSAGE = 'Started full load'
	EXEC    dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE,  NULL

	CREATE TABLE dbo.IOP_TAGS WITH (CLUSTERED INDEX (TT_ID), DISTRIBUTION = HASH(TAG_ID))
	AS --EXPLAIN
	WITH CTE_IOP_TAGS AS
	(
		SELECT 
			AGENCY_CODE AS [AGENCY_ID]
			, TAG_ID
			, MAX([LAST_UPDATE_DATE]) AS [LAST_UPDATE_DATE]
		FROM [LND_LG_HOST].[TXNOWNER].[IOP_TRANSACTIONS]
		GROUP BY AGENCY_CODE,TAG_ID
	)
	SELECT 
			ISNULL(CAST((ROW_NUMBER() OVER (ORDER BY AGENCY_ID, TAG_ID)) * (-1) - 66000000000000 AS BIGINT), 0) AS TT_ID
			, AGENCY_ID,TAG_ID,C.LAST_UPDATE_DATE
	FROM CTE_IOP_TAGS C
		LEFT JOIN LND_LG_IOP.[IOP_OWNER].[IOP_TAG_AUTHORITIES] TA ON TA.TAG_IDENTIFIER = C.AGENCY_ID
	WHERE (ISNUMERIC(TAG_ID) = 0 OR TAG_ID LIKE '%.%')-- AND RN = 1
	UNION ALL 
	SELECT 
			ISNULL(CAST(('66' + REPLICATE(ISNULL(CAST(TA.TA_ID AS VARCHAR(2)),'99'),2) + LTRIM(TAG_ID)) AS BIGINT), 0) AS TT_ID
			, AGENCY_ID,TAG_ID,C.LAST_UPDATE_DATE
	FROM CTE_IOP_TAGS C
		LEFT JOIN LND_LG_IOP.[IOP_OWNER].[IOP_TAG_AUTHORITIES] TA ON TA.TAG_IDENTIFIER = C.AGENCY_ID
	WHERE ISNUMERIC(TAG_ID) = 1 AND TAG_ID NOT LIKE '%.%'-- AND RN = 1
	OPTION (LABEL = 'IOP_TAGS_LOAD');

	-- Logging
	EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
	SET  @LOG_MESSAGE = 'Got all rows'
	EXEC dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, @ROW_COUNT


	INSERT INTO dbo.[IOP_TAGS]
	(TT_ID,AGENCY_ID,TAG_ID,LAST_UPDATE_DATE)
	VALUES( -1, '(Null)', '(Null)', '1900-01-01')

	CREATE STATISTICS [STATS_IOP_TAGS_001] ON dbo.[IOP_TAGS] ([TAG_ID], [AGENCY_ID]);
	CREATE STATISTICS [STATS_IOP_TAGS_002] ON dbo.[IOP_TAGS] ([AGENCY_ID]);
	--CREATE STATISTICS [STATS_IOP_TAGS_003] ON dbo.[IOP_TAGS] (NOT_IOP);

	SET  @LOG_MESSAGE = 'Finished full load'
	EXEC dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, @ROW_COUNT

END
ELSE
BEGIN

	SELECT  @LOG_MESSAGE = 'Started incr load'
	EXEC    dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE,  NULL

	SELECT @LAST_UPDATE_DATE = MAX(LAST_UPDATE_DATE) FROM dbo.IOP_TAGS

	SELECT @LAST_TT_ID = (-1) * MIN(TT_ID) FROM dbo.IOP_TAGS WHERE TT_ID < 0  -- This TT_ID is negative - that is why we take MIN and mult it to -1

	IF OBJECT_ID('dbo.IOP_TAGS_STAGE')>0 DROP TABLE dbo.IOP_TAGS_STAGE;
	--STEP #2: Create the NEW table with DISTRIBUTION = HASH([TART_ID]
	CREATE TABLE dbo.IOP_TAGS_STAGE WITH (HEAP, DISTRIBUTION = HASH(TAG_ID))
	AS --EXPLAIN
	WITH CTE_IOP_TAGS AS
	(
		SELECT 
			AGENCY_CODE AS [AGENCY_ID]
			, TAG_ID
			, MAX([LAST_UPDATE_DATE]) AS [LAST_UPDATE_DATE]
		FROM [LND_LG_HOST].[TXNOWNER].[IOP_TRANSACTIONS] I
		WHERE LAST_UPDATE_DATE >= @LAST_UPDATE_DATE AND NOT EXISTS (SELECT 1 FROM dbo.IOP_TAGS T WHERE T.TAG_ID = I.TAG_ID AND T.AGENCY_ID = I.AGENCY_CODE)
		GROUP BY AGENCY_CODE,TAG_ID
	)
	SELECT 
			ISNULL(CAST((ROW_NUMBER() OVER (ORDER BY AGENCY_ID, TAG_ID) + @LAST_TT_ID) * (-1) AS BIGINT), 0) AS TT_ID
			, AGENCY_ID,TAG_ID,C.LAST_UPDATE_DATE
	FROM CTE_IOP_TAGS C
		LEFT JOIN LND_LG_IOP.[IOP_OWNER].[IOP_TAG_AUTHORITIES] TA ON TA.TAG_IDENTIFIER = C.AGENCY_ID
	WHERE (ISNUMERIC(TAG_ID) = 0 OR TAG_ID LIKE '%.%') --AND RN = 1
	UNION ALL 
	SELECT 
			ISNULL(CAST(('66' + REPLICATE(ISNULL(CAST(TA.TA_ID AS VARCHAR(2)),'99'),2) + LTRIM(TAG_ID)) AS BIGINT), 0) AS TT_ID
			, AGENCY_ID,TAG_ID,C.LAST_UPDATE_DATE
	FROM CTE_IOP_TAGS C
		LEFT JOIN LND_LG_IOP.[IOP_OWNER].[IOP_TAG_AUTHORITIES] TA ON TA.TAG_IDENTIFIER = C.AGENCY_ID
	WHERE ISNUMERIC(TAG_ID) = 1 AND TAG_ID NOT LIKE '%.%' --AND RN = 1
	OPTION (LABEL = 'IOP_TAGS_LOAD: IOP_TAGS_STAGE');

	-- Logging
	EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
	SET  @LOG_MESSAGE = 'Got all rows:'
	EXEC dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, @ROW_COUNT

	IF OBJECT_ID('dbo.IOP_TAGS_NEW_STAGE')>0 	DROP TABLE dbo.IOP_TAGS_NEW_STAGE

	CREATE TABLE dbo.IOP_TAGS_NEW_STAGE WITH (CLUSTERED INDEX (TT_ID), DISTRIBUTION = HASH(TAG_ID)) AS    
	SELECT	
		TT_ID,AGENCY_ID,TAG_ID,LAST_UPDATE_DATE
	FROM dbo.IOP_TAGS AS F 
	WHERE NOT EXISTS (SELECT 1 FROM dbo.IOP_TAGS_STAGE AS N WHERE N.TT_ID = F.TT_ID) 
	  UNION ALL 
	SELECT	
		TT_ID,AGENCY_ID,TAG_ID,LAST_UPDATE_DATE
	FROM dbo.IOP_TAGS_STAGE AS N
	OPTION (LABEL = 'IOP_TAGS_LOAD: INSERT/UPDATE');

	-- Logging
	EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
	SET  @LOG_MESSAGE = 'Created _NEW_STAGE table'
	EXEC dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, @ROW_COUNT


	CREATE STATISTICS [STATS_IOP_TAGS_001] ON dbo.[IOP_TAGS_NEW_STAGE] ([TAG_ID], [AGENCY_ID]);
	CREATE STATISTICS [STATS_IOP_TAGS_002] ON dbo.[IOP_TAGS_NEW_STAGE] ([AGENCY_ID]);
	--CREATE STATISTICS [STATS_IOP_TAGS_003] ON dbo.[IOP_TAGS_NEW_STAGE] (NOT_IOP);


	--STEP #2: Replace OLD table with NEW
	IF OBJECT_ID('dbo.IOP_TAGS_OLD')>0 	DROP TABLE dbo.IOP_TAGS_OLD;
	IF OBJECT_ID('dbo.IOP_TAGS')>0			RENAME OBJECT::dbo.IOP_TAGS TO IOP_TAGS_OLD;
	RENAME OBJECT::dbo.IOP_TAGS_NEW_STAGE TO IOP_TAGS;
	IF OBJECT_ID('dbo.IOP_TAGS_OLD')>0 	DROP TABLE dbo.IOP_TAGS_OLD;

	IF OBJECT_ID('dbo.IOP_TAGS_STAGE')>0 	DROP TABLE dbo.IOP_TAGS_STAGE

	SET  @LOG_MESSAGE = 'Finished Incr load'
	EXEC dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, @ROW_COUNT

END
