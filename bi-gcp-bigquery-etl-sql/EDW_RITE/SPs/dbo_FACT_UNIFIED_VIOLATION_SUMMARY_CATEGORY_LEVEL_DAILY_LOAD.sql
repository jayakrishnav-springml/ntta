CREATE PROC [DBO].[FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_DAILY_LOAD] AS 

/*
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_DAILY_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_DAILY_LOAD
GO

EXEC EDW_RITE.DBO.FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_DAILY_LOAD
*/


/*	
SELECT TOP 100 * FROM FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL 

SELECT MAX(DAY_ID) FROM FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL

SELECT COUNT_BIG(1) FROM FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL 

DBCC PDW_SHOWSPACEUSED('dbo.FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL');



*/  


	DECLARE @PARTITION_DATE INT = (SELECT CAST((CONVERT(VARCHAR(6), GETDATE(), 112) + '01') AS INT))

	DECLARE @START_DAY_ID INT = CAST(CONVERT(VARCHAR(8), DATEADD(DAY,1,EOMONTH(GETDATE(),-1)),112) AS INT)--= 20150701

	-- This dates should be the same, but will keep them separately - my be we'll use them in diff way.

	--STEP #1: SUMMARY
	IF OBJECT_ID('DBO.FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_STAGE') IS NOT NULL DROP TABLE DBO.FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_STAGE

	--EXPLAIN
	CREATE TABLE DBO.FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_STAGE WITH (HEAP, DISTRIBUTION = HASH(LANE_ID)) AS  --ROUND_ROBIN --DROP TABLE FACT_LANE_ANALYSIS
	SELECT    DAY_ID
			, U.LANE_ID
			, ISNULL(CAST(VCLY_ID AS INT), -1) VCLY_ID
			, LEVEL_0
			, LEVEL_1
			, LEVEL_2
			, LEVEL_3
			, LEVEL_4
			, LEVEL_5
			, LEVEL_6
			, LEVEL_7
			, LEVEL_8
			, LEVEL_9
			, LEVEL_10
			, ISNULL(COALESCE(NULLIF(LEVEL_10 ,'-1'),NULLIF(LEVEL_9 ,'-1'),NULLIF(LEVEL_8 ,'-1'),NULLIF(LEVEL_7 ,'-1'),NULLIF(LEVEL_6 ,'-1'),NULLIF(LEVEL_5 ,'-1'),NULLIF(LEVEL_4 ,'-1'),NULLIF(LEVEL_3 ,'-1'),NULLIF(LEVEL_2 ,'-1'),NULLIF(LEVEL_1 ,'-1'),LEVEL_0),'') AS END_LEVEL
			, U.LVL_TVL
			, SOURCE_CODE
			, VIOL_STATUS
			, MANUAL_VIOL_FLAG --, U.VIOL_TYPE
			, U.OUT_OF_STATE_IND
			, U.DELETED
			, U.NOT_TRANS_REVIEW_STATUS_ABBREV
			, U.INVOICE_STAGE_ID
			, U.IOP_FLAG
			, U.FLEET_FLAG
			, U.UnPursuable_FLAG
			, U.BAD_ADDRESS_FLAG
			, ISNULL(SUM(U.AMOUNT)		, 0)	AMOUNT
			, ISNULL(COUNT_BIG(1)		, 0)	TXN_CNT 
			, ISNULL(SUM(POS_REV)		, 0)	POS_REV
			, ISNULL(SUM(EAR_REV)		, 0)	EAR_REV
			, ISNULL(SUM(U.TOLL_PAID)	, 0)	TOLL_PAID
			, ISNULL(SUM(U.SPLIT_AMOUNT), 0)	SPLIT_AMOUNT
			, ISNULL(SUM(U.AMT_PAID)	, 0)	AMT_PAID
			, ISNULL(SUM(U.FEES_PAID)	, 0)	FEES_PAID
			, ISNULL(SUM(U.ADJ_REV)		, 0)	ADJ_REV
			, ISNULL(SUM(U.POSTED_REV)	, 0)	POSTED_REV
			--SELECT TOP 100 * 
	FROM dbo.FACT_UNIFIED_VIOLATION_SNAPSHOT U --WHERE DAY_ID BETWEEN 20161231 AND 20161231 --WHERE LANE_ID < 0
	WHERE DAY_ID >= @START_DAY_ID
	GROUP BY DAY_ID, LANE_ID, VCLY_ID, LEVEL_0, LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_4, LEVEL_5, LEVEL_6, LEVEL_7, LEVEL_8, LEVEL_9, LEVEL_10,SOURCE_CODE,LVL_TVL, 
				VIOL_STATUS, MANUAL_VIOL_FLAG, OUT_OF_STATE_IND, DELETED, NOT_TRANS_REVIEW_STATUS_ABBREV, INVOICE_STAGE_ID,IOP_FLAG,FLEET_FLAG,UnPursuable_FLAG,BAD_ADDRESS_FLAG
	OPTION (LABEL = 'FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL');
	-- SELECT MAX(DAY_ID) FROM dbo.FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL
	--STEP #2: Replace OLD table with NEW

	DELETE FROM dbo.FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL
	WHERE DAY_ID >= @START_DAY_ID

	INSERT INTO dbo.FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL
	SELECT * FROM dbo.FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_STAGE

	UPDATE STATISTICS [dbo].FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL
	
	--SELECT MAX(DAY_ID) FROM dbo.FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL

	DELETE FROM dbo.FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_HIST
	WHERE PARTITION_DATE = @PARTITION_DATE AND DAY_ID >= @START_DAY_ID

	--DECLARE @PARTITION_DATE INT = (SELECT CAST((CONVERT(VARCHAR(6), GETDATE(), 112) + '01') AS INT))
	INSERT INTO dbo.FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_HIST
	SELECT @PARTITION_DATE AS PARTITION_DATE, FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_STAGE.* FROM dbo.FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_STAGE

	UPDATE STATISTICS [dbo].FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_HIST


	




