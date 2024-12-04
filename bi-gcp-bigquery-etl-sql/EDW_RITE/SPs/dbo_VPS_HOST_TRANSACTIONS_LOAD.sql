CREATE PROC [DBO].[VPS_HOST_TRANSACTIONS_LOAD] AS

/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.VPS_HOST_TRANSACTIONS_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.VPS_HOST_TRANSACTIONS_LOAD
GO



EXEC DBO.VPS_HOST_TRANSACTIONS_LOAD

*/

/*	
SELECT TOP 100 * FROM DBO.VPS_HOST_TRANSACTIONS 
SELECT COUNT_BIG(1) FROM DBO.VPS_HOST_TRANSACTIONS --    -- 892 777 633


SELECT * FROM dbo.PROCESS_LOG 
WHERE LOG_SOURCE LIKE 'VPS_HOST_TRANSACTIONS' AND LOG_DATE > '2019-02-20 8:00:00'
ORDER BY LOG_SOURCE, LOG_DATE

*/ 


DECLARE @TABLE_NAME VARCHAR(100) = 'VPS_HOST_TRANSACTIONS', @LOG_START_DATE DATETIME2(2) = SYSDATETIME(), @LOG_MESSAGE VARCHAR(1000), @ROW_COUNT BIGINT, @LOAD_CONTROL_DATE DATETIME2(2) 

DECLARE @sql VARCHAR(MAX)
DECLARE @PART_RANGES VARCHAR(MAX) = ''
--EXEC DBO.GET_PARTITION_MONTH_RANGE_STRING @PART_RANGES OUTPUT
EXEC DBO.GET_PARTITION_DAYID_RANGE_STRING @PART_RANGES OUTPUT


IF OBJECT_ID('dbo.VPS_HOST_TRANSACTIONS_STAGE') IS NOT NULL			DROP TABLE dbo.VPS_HOST_TRANSACTIONS_STAGE

SET @sql = '
CREATE TABLE [dbo].VPS_HOST_TRANSACTIONS_STAGE WITH (CLUSTERED INDEX (TRANSACTION_ID), DISTRIBUTION = HASH(TRANSACTION_ID), PARTITION (DAY_ID RANGE RIGHT FOR VALUES (' + @PART_RANGES + '))) AS
WITH CTE AS
(
SELECT	
	CAST(CONVERT(VARCHAR(8), A.VIOL_DATE,112) AS INT) DAY_ID
	, CAST(CONVERT(VARCHAR(6), A.VIOL_DATE,112) AS INT) AS MONTH_ID
	, ISNULL(A.TRANSACTION_ID, -1) TRANSACTION_ID
	, COALESCE(A.LANE_VIOL_ID, B.LANE_VIOL_ID, (A.TRANSACTION_ID%200000)*-1) LANE_VIOL_ID
	--, ISNULL(CAST(A.VIOLATION_ID AS BIGINT), (A.TRANSACTION_ID%200000)*-1) VIOLATION_ID
	, COALESCE(CAST(A.VIOLATION_ID AS BIGINT), C.VIOLATION_ID, (A.TRANSACTION_ID%200000)*-1) AS VIOLATION_ID
	, COALESCE(B.VIOLATOR_ID, C.VIOLATOR_ID, (A.TRANSACTION_ID%200000)*-1) AS VIOLATOR_ID
	, ISNULL(CAST(A.LANE_ID AS INT), -1) LANE_ID
	, CAST(COALESCE(POSTED_CLASS,EARNED_CLASS, 0) AS SMALLINT) AS VEHICLE_CLASS
	, A.LIC_PLATE_NBR 
	, A.LIC_PLATE_STATE
	, ISNULL(lp.LICENSE_PLATE_ID, -1) LICENSE_PLATE_ID
	, VTOLL_SEND_DATE
	, CONVERT(date,A.POSTED_DATE) AS POSTED_DATE
	, CONVERT(date,A.TRANSACTION_DATE) TRANSACTION_DATE
	, CONVERT(date,A.VIOL_DATE) VIOL_DATE
	, ISNULL(DATEDIFF(SECOND,CAST(A.VIOL_DATE AS DATE), A.VIOL_DATE), -1) VIOL_TIME_ID
	, CONVERT(VARCHAR(2), A.VIOL_TYPE) VIOL_TYPE
	, CONVERT(VARCHAR(2), A.SOURCE_CODE) SOURCE_CODE
	, CONVERT(VARCHAR(2), A.REASON_CODE) REASON_CODE
	, ISNULL(CAST(AGENCY_CODE AS VARCHAR(6)),''-1'') AS AGENCY_CODE
	, A.TAG_ID
	, ATT.TT_ID
	, ISNULL(CAST(A.DISPOSITION AS VARCHAR(2)), ''-1'') DISPOSITION
	, CONVERT(VARCHAR(2), CASE WHEN A.VIOL_DATE BETWEEN VBL.VBL_START AND ISNULL(VBL.VBL_END, GETDATE())  THEN ''Z'' ELSE ''V'' END) AS VIOLATION_OR_ZIPCASH
	, ISNULL(A.EARNED_REVENUE, 0) EARNED_REVENUE
	, ISNULL(A.POSTED_REVENUE, 0) POSTED_REVENUE
	, A.LAST_UPDATE_DATE
	, ROW_NUMBER() OVER (PARTITION BY A.TRANSACTION_ID ORDER BY TRANSACTION_DATE DESC, COALESCE(CAST(A.VIOLATION_ID AS BIGINT), C.VIOLATION_ID, -1) DESC, COALESCE(A.LANE_VIOL_ID, B.LANE_VIOL_ID, -1) DESC) RN
FROM LND_LG_VPS.VP_OWNER.VPS_HOST_TRANSACTIONS A
	INNER JOIN dbo.VB_LANES VBL ON A.LANE_ID = VBL.LANE_ID
	LEFT JOIN dbo.FACT_VIOLATIONS_DETAIL B ON (A.VIOLATION_ID = B.VIOLATION_ID AND B.VIOLATION_ID > -1)
	LEFT JOIN dbo.FACT_VIOLATIONS_DETAIL C ON (A.LANE_VIOL_ID = C.LANE_VIOL_ID AND C.LANE_VIOL_ID > -1)
	LEFT JOIN dbo.DIM_LICENSE_PLATE lp ON A.LIC_PLATE_NBR = lp.LICENSE_PLATE_NBR and A.LIC_PLATE_STATE = lp.LICENSE_PLATE_STATE
	LEFT JOIN dbo.TOLL_TAGS ATT ON ATT.TAG_ID = A.TAG_ID AND ATT.AGENCY_ID = A.AGENCY_CODE
)
SELECT 
	DAY_ID
	, MONTH_ID
	, TRANSACTION_ID
	, LANE_VIOL_ID
	, VIOLATION_ID
	, VIOLATOR_ID
	, LANE_ID
	, VEHICLE_CLASS
	, LIC_PLATE_NBR 
	, LIC_PLATE_STATE
	, LICENSE_PLATE_ID
	, VTOLL_SEND_DATE
	, POSTED_DATE
	, TRANSACTION_DATE
	, VIOL_DATE
	, VIOL_TIME_ID
	, VIOL_TYPE
	, SOURCE_CODE
	, REASON_CODE
	, AGENCY_CODE
	, TAG_ID
	, TT_ID
	, DISPOSITION
	, VIOLATION_OR_ZIPCASH
	, EARNED_REVENUE
	, POSTED_REVENUE
	, LAST_UPDATE_DATE
FROM CTE
WHERE RN = 1
OPTION (LABEL = ''VPS_HOST_TRANSACTIONS FULL LOAD'');'

EXEC (@sql)
EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT

CREATE STATISTICS [STATS_VPS_HOST_TRANSACTIONS_001] ON [dbo].VPS_HOST_TRANSACTIONS_STAGE (VIOLATOR_ID,VIOLATION_OR_ZIPCASH);
CREATE STATISTICS [STATS_VPS_HOST_TRANSACTIONS_002] ON [dbo].VPS_HOST_TRANSACTIONS_STAGE (SOURCE_CODE);
CREATE STATISTICS [STATS_VPS_HOST_TRANSACTIONS_003] ON [dbo].VPS_HOST_TRANSACTIONS_STAGE (LICENSE_PLATE_ID,VIOLATOR_ID);
CREATE STATISTICS [STATS_VPS_HOST_TRANSACTIONS_004] ON [dbo].VPS_HOST_TRANSACTIONS_STAGE (VIOLATION_ID,DAY_ID);
CREATE STATISTICS [STATS_VPS_HOST_TRANSACTIONS_005] ON [dbo].VPS_HOST_TRANSACTIONS_STAGE (LAST_UPDATE_DATE);
CREATE STATISTICS [STATS_VPS_HOST_TRANSACTIONS_006] ON [dbo].VPS_HOST_TRANSACTIONS_STAGE (MONTH_ID, DAY_ID,TRANSACTION_ID);
CREATE STATISTICS [STATS_VPS_HOST_TRANSACTIONS_007] ON [dbo].VPS_HOST_TRANSACTIONS_STAGE (LANE_VIOL_ID,TRANSACTION_ID);
CREATE STATISTICS [STATS_VPS_HOST_TRANSACTIONS_008] ON [dbo].VPS_HOST_TRANSACTIONS_STAGE (DISPOSITION);
CREATE STATISTICS [STATS_VPS_HOST_TRANSACTIONS_009] ON [dbo].VPS_HOST_TRANSACTIONS_STAGE (DAY_ID,LANE_VIOL_ID);

--STEP #2: Replace OLD table with NEW
IF OBJECT_ID('dbo.VPS_HOST_TRANSACTIONS_OLD') IS NOT NULL 	DROP TABLE dbo.VPS_HOST_TRANSACTIONS_OLD;
IF OBJECT_ID('dbo.VPS_HOST_TRANSACTIONS') IS NOT NULL		RENAME OBJECT::dbo.VPS_HOST_TRANSACTIONS TO VPS_HOST_TRANSACTIONS_OLD;
RENAME OBJECT::dbo.VPS_HOST_TRANSACTIONS_STAGE TO VPS_HOST_TRANSACTIONS;
IF OBJECT_ID('dbo.VPS_HOST_TRANSACTIONS_OLD') IS NOT NULL 	DROP TABLE dbo.VPS_HOST_TRANSACTIONS_OLD;

SET  @LOG_MESSAGE = 'Complete Full load'
EXEC dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, @ROW_COUNT


