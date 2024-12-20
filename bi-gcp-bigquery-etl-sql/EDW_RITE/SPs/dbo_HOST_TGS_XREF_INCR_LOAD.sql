CREATE PROC [dbo].[HOST_TGS_XREF_INCR_LOAD] AS
BEGIN

	/*
	DROP PROC [dbo].[HOST_TGS_XREF_INCR_LOAD]
	
	*/

    DECLARE @SOURCE VARCHAR(50), @START_DATE DATETIME2 (2), @LOG_MESSAGE VARCHAR(1000), @ROW_COUNT BIGINT, @LOAD_CONTROL_DATE DATETIME2 (2) = DATEADD(day, DATEDIFF(day, 0, GETDATE()), -10), @LAST_UPDATE_DATE DATETIME2 (2)
	
	-- STEP 1: Get the next Load Control Date from the Control Table

	SELECT	@LOAD_CONTROL_DATE = DATEADD(DAY, -10, LAST_RUN_DATE) FROM dbo.LOAD_PROCESS_CONTROL WHERE TABLE_NAME = 'HOST_TGS_XREF' -- Will check 10 days before
 	SELECT	@LAST_UPDATE_DATE = MAX(LAST_UPDATE_DATE) FROM LND_LG_TS.TAG_OWNER.TOLL_TRANSACTIONS WHERE SOURCE_CODE = 'H' AND CREDITED_FLAG =  'N'
    
	SELECT  @SOURCE = 'HOST_TGS_XREF_INCR_LOAD', @START_DATE = GETDATE(), @LOG_MESSAGE = '<< Started HOST_TGS_XREF_INCR_LOAD to load updates from ' + CONVERT(VARCHAR(19),@LOAD_CONTROL_DATE,121) + ' to ' + CONVERT(VARCHAR(19),@LAST_UPDATE_DATE,121)
    EXEC    dbo.LOG_PROCESS @SOURCE, @START_DATE, @LOG_MESSAGE,  NULL

	----STEP 2: Insert new XREF ONLY in stage table
	--IF OBJECT_ID('dbo.HOST_TGS_XREF_NEW') IS NOT NULL DROP TABLE dbo.HOST_TGS_XREF_NEW
	--CREATE TABLE dbo.HOST_TGS_XREF_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TART_ID))
	--AS 
	--SELECT	SOURCE_TRXN_ID AS TART_ID, TTXN_ID 
	--FROM	LND_LG_TS.TAG_OWNER.TOLL_TRANSACTIONS
	--WHERE	SOURCE_CODE = 'H' 
	--AND		CREDITED_FLAG =  'N'
	--AND		LAST_UPDATE_DATE >= @LOAD_CONTROL_DATE
	--EXCEPT	
	--SELECT	TART_ID, TTXN_ID FROM EDW_RITE.dbo.HOST_TGS_XREF

	DECLARE  @MAX_TTXN_ID BIGINT

	SELECT @MAX_TTXN_ID = MAX(TTXN_ID) FROM LND_LG_TS.TAG_OWNER.TOLL_TRANSACTIONS WHERE TOLL_TRANSACTIONS.LAST_UPDATE_DATE < @LOAD_CONTROL_DATE			-- 7893593990

	IF OBJECT_ID('dbo.HOST_TGS_XREF_NEW') IS NOT NULL DROP TABLE dbo.HOST_TGS_XREF_NEW
	CREATE TABLE dbo.HOST_TGS_XREF_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TART_ID))
	AS 
	SELECT	SOURCE_TRXN_ID AS TART_ID, TTXN_ID
			, ROW_NUMBER() OVER (PARTITION BY SOURCE_TRXN_ID ORDER BY TTXN_ID DESC) RN
	FROM	LND_LG_TS.TAG_OWNER.TOLL_TRANSACTIONS T
	WHERE	SOURCE_CODE = 'H' AND CREDITED_FLAG =  'N' AND LAST_UPDATE_DATE >= @LOAD_CONTROL_DATE
			AND	NOT EXISTS (SELECT 1 FROM EDW_RITE.dbo.HOST_TGS_XREF X WHERE X.TART_ID = T.SOURCE_TRXN_ID AND X.TTXN_ID = T.TTXN_ID AND X.TTXN_ID > @MAX_TTXN_ID)

--) B WHERE HOST_TGS_XREF < TOLL_TRANSACTIONS

	EXEC	dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
	SELECT  @LOG_MESSAGE = 'Incremental refresh. Loaded HOST_TGS_XREF_NEW with ' + CONVERT(VARCHAR,@ROW_COUNT) + ' rows'
	EXEC    dbo.LOG_PROCESS @SOURCE, @START_DATE, @LOG_MESSAGE,  @ROW_COUNT

	IF @ROW_COUNT > 0 
	BEGIN	
		--STEP 3: Insert from Stage table to XREF table
		INSERT EDW_RITE.dbo.HOST_TGS_XREF (TART_ID, TTXN_ID)
		SELECT TART_ID, TTXN_ID FROM dbo.HOST_TGS_XREF_NEW
		WHERE RN = 1

		EXEC	dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
		SELECT  @LOG_MESSAGE = 'Inserted ' + CONVERT(VARCHAR,@ROW_COUNT) + ' rows into HOST_TGS_XREF from HOST_TGS_XREF_NEW'
		EXEC    dbo.LOG_PROCESS @SOURCE, @START_DATE, @LOG_MESSAGE,  @ROW_COUNT

		--STEP 4: Update statistics
		UPDATE STATISTICS EDW_RITE.dbo.HOST_TGS_XREF;
		SELECT  @LOG_MESSAGE = 'Updated STATISTICS on dbo.HOST_TGS_XREF'
		EXEC    dbo.LOG_PROCESS @SOURCE, @START_DATE, @LOG_MESSAGE,  NULL
	END
	
	--STEP #5: Update Load Process Control Table
	UPDATE	dbo.LOAD_PROCESS_CONTROL SET LAST_RUN_DATE = @LAST_UPDATE_DATE WHERE TABLE_NAME = 'HOST_TGS_XREF'
	EXEC	dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
	SELECT  @LOG_MESSAGE = 'Updated dbo.LOAD_PROCESS_CONTROL for the next run. Last LOAD_CONTROL_DATE: ' + ISNULL(CONVERT(VARCHAR(19),@LOAD_CONTROL_DATE,121),'NULL') + '. Next LOAD_CONTROL_DATE: ' + ISNULL(CONVERT(VARCHAR(19),@LAST_UPDATE_DATE,121),'NULL')
	EXEC    dbo.LOG_PROCESS @SOURCE, @START_DATE, @LOG_MESSAGE, @ROW_COUNT
	EXEC    dbo.LOG_PROCESS @SOURCE, @START_DATE, '>> Completed SP execution', NULL
END

/*
--:: Process Log
SELECT * FROM dbo.PROCESS_LOG (nolock) WHERE LOG_SOURCE = 'HOST_TGS_XREF_INCR_LOAD' ORDER BY LOG_DATE DESC

SELECT* FROM dbo.LOAD_PROCESS_CONTROL WHERE TABLE_NAME = 'HOST_TGS_XREF'
UPDATE	dbo.LOAD_PROCESS_CONTROL SET LAST_RUN_DATE = '9/30/2018' WHERE TABLE_NAME = 'HOST_TGS_XREF' -- 2018-10-19 04:25:36.00

CREATE TABLE dbo.HOST_TGS_XREF_NEW_INCR WITH (DISTRIBUTION = HASH(TART_ID), HEAP)
AS
SELECT * FROM dbo.HOST_TGS_XREF_NEW

DELETE EDW_RITE.dbo.HOST_TGS_XREF WHERE TART_ID IN (SELECT TART_ID FROM HOST_TGS_XREF_NEW_INCR)
UPDATE STATISTICS EDW_RITE.dbo.HOST_TGS_XREF;

*/


 
