CREATE PROC [DBO].[FACT_VIOLATIONS_DMV_INTEGRATED_LOAD] AS 

/*
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.FACT_VIOLATIONS_DMV_INTEGRATED_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.FACT_VIOLATIONS_DMV_INTEGRATED_LOAD
GO

EXEC DBO.FACT_VIOLATIONS_DMV_INTEGRATED_LOAD

SELECT COUNT_BIG(1) FROM dbo.FACT_VIOLATIONS_DMV_STATUS_DETAIL  -- 367603398

SELECT TOP 100 * FROM FACT_VIOLATIONS_DMV_STATUS_DETAIL; 

SELECT  TOP 100
	VIOLATION_ID,DAY_ID,MONTH_ID,LANE_ID,VCLY_ID,VEHICLE_CLASS,DMV_STS,BUSINESS_TYPE,LICENSE_PLATE_ID,LIC_PLATE_NBR,LIC_PLATE_STATE,TOLL_DUE,TOLL_PAID
FROM dbo.FACT_VIOLATIONS_DMV_STATUS_DETAIL

SELECT * FROM edw_rite.dbo.PROCESS_LOG 
WHERE LOG_SOURCE = 'FACT_VIOLATIONS_DMV_STATUS_DETAIL' AND LOG_DATE > '2019-09-01 8:00:00'
ORDER BY LOG_SOURCE, LOG_DATE

*/


--#1	Shankar Metla	2018-09-08	CREATED
--#2	Andy Filipps	2018-10-02	Full rewrite for a new approach to avoid full month load

DECLARE @LOG_START_DATE DATETIME2(2) = GETDATE(), @LOG_MESSAGE VARCHAR(1000), @ROW_COUNT BIGINT 
DECLARE @sql VARCHAR(MAX)
DECLARE @TABLE_NAME VARCHAR(100) = 'FACT_VIOLATIONS_DMV_STATUS_DETAIL'



---- !!!!!!!!!!!!!!!!!!!!! TESTING ONLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--SET @LOAD_CONTROL_DATE = CAST('2018-09-01 00:00:00.00' AS DATETIME2(2)) 
---- !!!!!!!!!!!!!!!!!!!!! TESTING ONLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

--PRINT @LOAD_CONTROL_DATE

-- STEP 2: Initiate LOG
SELECT  @LOG_MESSAGE = 'Started FULL load'
EXEC    dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE,  NULL

--IF OBJECT_ID('dbo.VP_OWNER_VIOLATIONS_DMV') IS NOT NULL DROP TABLE dbo.VP_OWNER_VIOLATIONS_DMV
--BEGIN
--	-- First create a table with only changes of LND_LG_VPS.VP_OWNER.VIOLATIONS - use this table in 3 procs!
--	CREATE TABLE dbo.VP_OWNER_VIOLATIONS_DMV WITH (HEAP, DISTRIBUTION = HASH(VIOLATION_ID)) AS
--	-- EXPLAIN
--	SELECT 
--		CAST(CONVERT(VARCHAR(8), V.VIOL_DATE,112) AS INT) DAY_ID 
--		,ISNULL(CAST(V.VIOLATION_ID AS BIGINT),-1) AS VIOLATION_ID
--		,ISNULL(CAST(V.LANE_ID AS INT), -1) LANE_ID
--		,VIOL_DATE,VIOL_TIME,VIOL_TYPE,TOLL_DUE,TOLL_PAID,LIC_PLATE_NBR,LIC_PLATE_STATE
--		,ISNULL(CAST(V.VEHICLE_CLASS AS SMALLINT), -1) VEHICLE_CLASS
--		,ISNULL(V.VIOL_STATUS,'-1') VIOL_STATUS
--		,STATUS_DATE
--		,VEHICLE_MAKE,VEHICLE_MODEL,VEHICLE_COLOR,VEHICLE_YEAR,VEHICLE_BODY,OCCUPANT_DESCR,NO_PAY_ATTEMPT,WINDOW_UP,RECORDED_BY,RECORDER_EMP_ID,DRIVER_LIC_NBR,DRIVER_LIC_STATE,TOLLTAG_ACCT_ID
--		,ISNULL(TAG_ID,'-1') TAG_ID
--		,ISNULL(AGENCY_ID,'-1') AGENCY_ID
--		,CREATED_BY,DATE_CREATED,MODIFIED_BY,DATE_MODIFIED,EXCUSED_REASON,EXCUSED_BY,DATE_EXCUSED
--		,ISNULL(V.VIOLATOR_ID, 		-1)		AS 	VIOLATOR_ID
--		,REVIEW_STATUS
--		,ISNULL(COALESCE(V.LANE_VIOL_ID, X.LANE_VIOL_ID), -1)	AS LANE_VIOL_ID
--		,NOTIFICATION_DATE,OLD_VIOLATOR_ID
--		,ISNULL(TRANSACTION_ID, 		-1)		AS TRANSACTION_ID
--		,DISPOSITION,COMMENT_DATE,UNPAID_TOLL_DATE,HOST_TRANSACTION_ID,VIO_VIOLATION_ID,ICRS_DATE_CREATED,ORIGIN_TYPE,CURRENT_TYPE
--		,ISNULL(TRANSACTION_FILE_DETAIL_ID, 		-1)		AS TRANSACTION_FILE_DETAIL_ID
--		,POST_DATE,LAST_UPDATE_TYPE,LAST_UPDATE_DATE
--	FROM LND_LG_VPS.VP_OWNER.VIOLATIONS V 
--	LEFT JOIN dbo.MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF X ON X.VIOLATION_ID = V.VIOLATION_ID
--	OPTION (LABEL ='VP_OWNER_VIOLATIONS DMV LOAD');

--END

--STEP #7: -- Getting all changes to a new table
IF OBJECT_ID('dbo.FACT_VIOLATIONS_DMV_STATUS_DETAIL_STAGE') IS NOT NULL DROP TABLE dbo.FACT_VIOLATIONS_DMV_STATUS_DETAIL_STAGE
BEGIN
	CREATE TABLE dbo.FACT_VIOLATIONS_DMV_STATUS_DETAIL_STAGE WITH (CLUSTERED INDEX (VIOLATION_ID), DISTRIBUTION = HASH(VIOLATION_ID)) AS
	WITH VT AS
	(
		SELECT DISTINCT 
			V.VIOLATION_ID
			,V.DAY_ID
			,V.VIOL_DATE
			,V.LANE_ID
			,ISNULL(CT.VCLY_ID, -1) VCLY_ID
			,V.VEHICLE_CLASS
			,V.TOLL_DUE
			,V.TOLL_PAID
			,ISNULL(LP.LICENSE_PLATE_ID,-1)  AS LICENSE_PLATE_ID
			,V.LIC_PLATE_NBR
			,V.LIC_PLATE_STATE
			,V.VIOL_STATUS
			,V.VIOLATOR_ID
			,ISNULL(CASE 
				WHEN V.ORIGIN_TYPE = 'F'
					THEN 'Z'
				ELSE V.ORIGIN_TYPE
				END, - 1) BUSINESS_TYPE
			,MIN(CASE 
					WHEN P.LIC_PLATE_NBR IS NULL
						THEN 'NDMV'
					WHEN P.START_DATE IS NOT NULL AND (V.VIOL_DATE BETWEEN P.START_DATE AND COALESCE(P.END_DATE, GETDATE()))
						THEN 'IN-DMV'
					ELSE 'NV-TIME'
					END) OVER (PARTITION BY V.VIOLATION_ID) DMV_STS --SELECT COUNT(1) 
		FROM dbo.VP_OWNER_VIOLATIONS V --LND_LG_VPS.VP_OWNER.VIOLATIONS V  
		LEFT JOIN dbo.DIM_VEH_CLSS_TYPES CT ON V.VEHICLE_CLASS = CT.[AXLES]
		LEFT JOIN LND_LG_DMV.DMVLD.PLATES P ON V.LIC_PLATE_NBR = P.LIC_PLATE_NBR
			AND V.LIC_PLATE_STATE = P.LIC_PLATE_STATE  
		LEFT JOIN dbo.DIM_LICENSE_PLATE LP ON  LP.LICENSE_PLATE_NBR = V.LIC_PLATE_NBR AND LP.LICENSE_PLATE_STATE = V.LIC_PLATE_STATE
		WHERE V.VIOL_STATUS IN ('T','I','ZI','ZH','WJ','A') --AND V.LAST_UPDATE_DATE >= @LOAD_CONTROL_DATE
	)
	SELECT VIOLATION_ID
		,DAY_ID
		,DAY_ID / 100 AS MONTH_ID
		,LANE_ID
		,VCLY_ID
		,VEHICLE_CLASS
		,'LP-' + (
			CASE 
				WHEN DMV_STS IN ('NDMV','NV-TIME')
					THEN DMV_STS
				WHEN EXISTS (SELECT COUNT(1)
						FROM LND_LG_VPS.VP_OWNER.VIOLATORS VR
						WHERE VR.LIC_PLATE_NBR = VT.LIC_PLATE_NBR AND VR.LIC_PLATE_STATE = VT.LIC_PLATE_STATE AND (VT.VIOL_DATE BETWEEN VR.USAGE_BEGIN_DATE AND COALESCE(VR.USAGE_END_DATE, GETDATE()))
						HAVING COUNT(1) > 1)
					THEN 'M-VLTR'
				ELSE 'OTHER'
				END
			) DMV_STS
		,BUSINESS_TYPE
		,LICENSE_PLATE_ID
		,LIC_PLATE_NBR
		,LIC_PLATE_STATE
		,TOLL_DUE
		,TOLL_PAID
	FROM VT
	WHERE VT.VIOL_STATUS IN ('ZH','WJ','A') AND VT.VIOLATOR_ID = -1 AND VT.LIC_PLATE_STATE = 'TX'

	UNION ALL

	SELECT VIOLATION_ID
		,DAY_ID
		,DAY_ID / 100 AS MONTH_ID
		,LANE_ID
		,VCLY_ID
		,VEHICLE_CLASS
		,ISNULL('VIOL-' + CASE 
				WHEN VIOL_STATUS = 'T'
					THEN 'VTOLL'
				WHEN VIOL_STATUS = 'I'
					THEN 'VI'
				WHEN VIOL_STATUS = 'ZI'
					THEN 'INV'
				ELSE  
					CASE 
						WHEN VIOLATOR_ID = -1
							THEN CASE 
									WHEN LIC_PLATE_STATE = 'TX'
										THEN LIC_PLATE_STATE
									ELSE 'NTX'
									END
						ELSE 'M-DMV'
						END  
				END, - 1) DMV_STS
		,BUSINESS_TYPE
		,LICENSE_PLATE_ID
		,LIC_PLATE_NBR
		,LIC_PLATE_STATE
		,TOLL_DUE
		,TOLL_PAID --SELECT TOP (100) *
	FROM VT
	OPTION (LABEL = 'FACT_VIOLATIONS_DMV_STATUS_DETAIL LOAD');

	-- Logging
	EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
	SET  @LOG_MESSAGE = 'Got all rows:'
	EXEC dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, @ROW_COUNT

END 

DECLARE @PART_RANGES VARCHAR(MAX) = ''
--EXEC DBO.GET_PARTITION_MONTH_RANGE_STRING @PART_RANGES OUTPUT
EXEC DBO.GET_PARTITION_DAYID_RANGE_STRING @PART_RANGES OUTPUT
--PRINT @PART_RANGES

SET @sql = '
CREATE TABLE dbo.[FACT_VIOLATIONS_DMV_STATUS_DETAIL_NEW_SET] WITH (CLUSTERED INDEX ( [VIOLATION_ID] ), DISTRIBUTION = HASH([VIOLATION_ID]), PARTITION (DAY_ID RANGE RIGHT FOR VALUES (' + @PART_RANGES + '))) AS
SELECT 
		ISNULL(main_table.[VIOLATION_ID], 0) AS [VIOLATION_ID]
		, CAST(main_table.[DAY_ID] AS int) AS [DAY_ID]
		, main_table.MONTH_ID AS MONTH_ID
		, ISNULL(CAST(main_table.[LANE_ID] AS decimal(14,0)), 0) AS [LANE_ID]
		, ISNULL(CAST(main_table.[VCLY_ID] AS decimal(14,0)), 0) AS [VCLY_ID]
		, ISNULL(CAST(main_table.[VEHICLE_CLASS] AS numeric(2,0)), 0) AS [VEHICLE_CLASS]
		, CAST(main_table.[DMV_STS] AS varchar(10)) AS [DMV_STS]
		, ISNULL(CAST(main_table.[BUSINESS_TYPE] AS varchar(1)), '''') AS [BUSINESS_TYPE]
		, ISNULL(main_table.LICENSE_PLATE_ID,-1)  AS LICENSE_PLATE_ID
		, ISNULL(CAST(main_table.[LIC_PLATE_NBR] AS varchar(15)), '''') AS [LIC_PLATE_NBR]
		, ISNULL(CAST(main_table.[LIC_PLATE_STATE] AS varchar(3)), '''') AS [LIC_PLATE_STATE]
		, ISNULL(CAST(main_table.[TOLL_DUE] AS decimal(9,2)), 0) AS [TOLL_DUE]
		, ISNULL(CAST(main_table.[TOLL_PAID] AS decimal(9,2)), 0) AS [TOLL_PAID]
FROM dbo.[FACT_VIOLATIONS_DMV_STATUS_DETAIL_STAGE] AS main_table
OPTION (LABEL = ''FACT_VIOLATIONS_DMV_STATUS_DETAIL_NEW_SET LOAD'');'


EXEC (@sql)
EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT

CREATE STATISTICS [STATS_FACT_VIOLATIONS_DMV_STATUS_DETAIL_001] ON dbo.[FACT_VIOLATIONS_DMV_STATUS_DETAIL_NEW_SET] ([DAY_ID]);
CREATE STATISTICS [STATS_FACT_VIOLATIONS_DMV_STATUS_DETAIL_002] ON dbo.[FACT_VIOLATIONS_DMV_STATUS_DETAIL_NEW_SET] ([LANE_ID],[DAY_ID]);
CREATE STATISTICS [STATS_FACT_VIOLATIONS_DMV_STATUS_DETAIL_003] ON dbo.[FACT_VIOLATIONS_DMV_STATUS_DETAIL_NEW_SET] ([DMV_STS]);
CREATE STATISTICS [STATS_FACT_VIOLATIONS_DMV_STATUS_DETAIL_004] ON dbo.[FACT_VIOLATIONS_DMV_STATUS_DETAIL_NEW_SET] ([BUSINESS_TYPE]);
CREATE STATISTICS [STATS_FACT_VIOLATIONS_DMV_STATUS_DETAIL_005] ON dbo.[FACT_VIOLATIONS_DMV_STATUS_DETAIL_NEW_SET] ([VEHICLE_CLASS]);
CREATE STATISTICS [STATS_FACT_VIOLATIONS_DMV_STATUS_DETAIL_006] ON dbo.[FACT_VIOLATIONS_DMV_STATUS_DETAIL_NEW_SET] (MONTH_ID,DAY_ID,VIOLATION_ID);

SET @sql = '
IF OBJECT_ID(''dbo.[' + @TABLE_NAME + '_OLD]'') IS NOT NULL		DROP TABLE dbo.[' + @TABLE_NAME + '_OLD];
IF OBJECT_ID(''dbo.[' + @TABLE_NAME + ']'') IS NOT NULL			RENAME OBJECT::dbo.[' + @TABLE_NAME + '] TO [' + @TABLE_NAME + '_OLD];
IF OBJECT_ID(''dbo.[' + @TABLE_NAME + '_NEW_SET]'') IS NOT NULL	RENAME OBJECT::dbo.[' + @TABLE_NAME + '_NEW_SET] TO [' + @TABLE_NAME + '];
IF OBJECT_ID(''dbo.[' + @TABLE_NAME + '_OLD]'') IS NOT NULL		DROP TABLE dbo.[' + @TABLE_NAME + '_OLD];'
EXEC (@sql)

SET  @LOG_MESSAGE = 'Complete Full load'
EXEC dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, @ROW_COUNT



IF OBJECT_ID('dbo.FACT_VIOLATIONS_DMV_STATUS_DETAIL_STAGE') IS NOT NULL DROP TABLE dbo.FACT_VIOLATIONS_DMV_STATUS_DETAIL_STAGE

--IF OBJECT_ID('dbo.VP_OWNER_VIOLATIONS_DMV') IS NOT NULL DROP TABLE dbo.VP_OWNER_VIOLATIONS_DMV

