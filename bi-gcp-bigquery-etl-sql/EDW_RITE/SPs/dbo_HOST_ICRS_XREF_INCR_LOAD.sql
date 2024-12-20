CREATE PROC [dbo].[HOST_ICRS_XREF_INCR_LOAD] AS
BEGIN

/*
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.HOST_ICRS_XREF_INCR_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.HOST_ICRS_XREF_INCR_LOAD
GO

EXEC EDW_RITE.DBO.HOST_ICRS_XREF_INCR_LOAD

SELECT COUNT_BIG(1) FROM EDW_RITE.dbo.HOST_ICRS_XREF  -- 2 003 885 112

*/

    DECLARE @SOURCE VARCHAR(50), @START_DATE DATETIME2 (2), @LOG_MESSAGE VARCHAR(1000), @ROW_COUNT BIGINT, @LOAD_CONTROL_DATE DATETIME2 (2) -- = DATEADD(day, DATEDIFF(day, 0, GETDATE()), -10), @LAST_UPDATE_DATE DATETIME2 (2)
	
	DECLARE @MIN_DATE AS DATETIME2(0)
	DECLARE @MAX_DATE AS DATETIME2(0)

	-- STEP #1: Get the next Load Control Date from the Control Table
	SELECT	@LOAD_CONTROL_DATE = DATEADD(DAY, -2, LAST_RUN_DATE) FROM dbo.LOAD_PROCESS_CONTROL WHERE TABLE_NAME = 'HOST_ICRS_XREF' -- Will check 10 days before
   
	SELECT  @SOURCE = 'HOST_ICRS_XREF_INCR_LOAD', @START_DATE = GETDATE(), @LOG_MESSAGE = '<< Started HOST_ICRS_XREF_INCR_LOAD to load updates from ' + CONVERT(VARCHAR(19),@LOAD_CONTROL_DATE,121)
    EXEC    dbo.LOG_PROCESS @SOURCE, @START_DATE, @LOG_MESSAGE,  NULL

	IF OBJECT_ID('dbo.LANE_VIOL_DATE_STAGE') IS NOT NULL DROP TABLE dbo.LANE_VIOL_DATE_STAGE	
	CREATE TABLE dbo.LANE_VIOL_DATE_STAGE WITH (HEAP, DISTRIBUTION = HASH(LANE_VIOL_ID))
	AS -- EXPLAIN
		SELECT  LANE_VIOL_ID, LANE_ID, SEQUENCE_NBR, VIOL_DATE
		-- SELECT COUNT_BIG(1) --TOP 10 *
		FROM LND_LG_ICRS.ICRS_OWNER.ICS_LANE_VIOLATIONS 
		WHERE LANE_VIOL_ID NOT IN (SELECT LANE_VIOL_ID FROM dbo.HOST_ICRS_XREF) 
			AND TRANSACTION_FILE_DETAIL_ID IS NULL 
			AND LANE_ID > -1
			AND LAST_UPDATE_DATE >= @LOAD_CONTROL_DATE

	SELECT @MIN_DATE = MIN(VIOL_DATE), @MAX_DATE = MAX(VIOL_DATE) -- To make it useful for UTC time also and not pedending on small difference
	FROM dbo.LANE_VIOL_DATE_STAGE

	--DECLARE @MAX_DATE_UTC AS DATETIME2(0) = DATEADD(HOUR,6,@MAX_DATE)

	--STEP #2: Insert new XREF ONLY in stage table
	IF OBJECT_ID('dbo.HOST_ICRS_XREF_NEW_SET') IS NOT NULL DROP TABLE dbo.HOST_ICRS_XREF_NEW_SET	
	-- EXPLAIN
	CREATE TABLE dbo.HOST_ICRS_XREF_NEW_SET WITH (HEAP, DISTRIBUTION = HASH(TART_ID))
	AS
	SELECT  TTRD.TART_ID, ILV.LANE_VIOL_ID
			, ROW_NUMBER() OVER (PARTITION BY TTRD.TART_ID ORDER BY ILV.LANE_VIOL_ID DESC) RN
	FROM	(SELECT  TART_TART_ID AS TART_ID, VES_DATE_TIME_LOCAL, VES_SERIAL_NO, LANE_LANE_ID AS LANE_ID
				FROM	EDW_RITE.dbo.TOTAL_NET_REV_TFC_EVTS
				WHERE VES_SERIAL_NO IN (SELECT SEQUENCE_NBR FROM dbo.LANE_VIOL_DATE_STAGE) AND TRANSACTION_FILE_DETAIL_ID IS NULL -- AND VES_DATE_TIME_LOCAL BETWEEN @MIN_DATE AND @MAX_DATE
				) TTRD
	JOIN	dbo.LANE_VIOL_DATE_STAGE ILV 
			ON ILV.LANE_ID = TTRD.LANE_ID 
			AND ILV.SEQUENCE_NBR = TTRD.VES_SERIAL_NO 
			AND	ILV.VIOL_DATE = TTRD.VES_DATE_TIME_LOCAL
	OPTION (LABEL = 'HOST_ICRS_XREF LOAD ');
			
	EXEC	dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
	SELECT  @LOG_MESSAGE = 'Finished load HOST_ICRS_XREF_NEW_SET: ' + CONVERT(VARCHAR,@ROW_COUNT) + ' rows'
	EXEC    dbo.LOG_PROCESS @SOURCE, @START_DATE, @LOG_MESSAGE,  @ROW_COUNT

	IF @ROW_COUNT > 0 
	BEGIN	
		--STEP #3: Insert from Stage table to XREF table
		INSERT EDW_RITE.dbo.HOST_ICRS_XREF (TART_ID, LANE_VIOL_ID)
		SELECT TART_ID, LANE_VIOL_ID FROM dbo.HOST_ICRS_XREF_NEW_SET
		WHERE RN = 1

		EXEC	dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
		SELECT  @LOG_MESSAGE = 'Inserted ' + CONVERT(VARCHAR,@ROW_COUNT) + ' rows into HOST_ICRS_XREF from HOST_ICRS_XREF_NEW_SET'
		EXEC    dbo.LOG_PROCESS @SOURCE, @START_DATE, @LOG_MESSAGE,  @ROW_COUNT

		--STEP #4: Update statistics
		UPDATE STATISTICS EDW_RITE.dbo.HOST_ICRS_XREF;
	END
	
	--STEP #5: Update Load Process Control Table
	SELECT	@LOAD_CONTROL_DATE = MAX(LAST_UPDATE_DATE) FROM LND_LG_ICRS.ICRS_OWNER.ICS_LANE_VIOLATIONS
	UPDATE	dbo.LOAD_PROCESS_CONTROL SET LAST_RUN_DATE = @LOAD_CONTROL_DATE WHERE TABLE_NAME = 'HOST_ICRS_XREF'

	EXEC    dbo.LOG_PROCESS @SOURCE, @START_DATE, '>> Completed SP execution', NULL
END



