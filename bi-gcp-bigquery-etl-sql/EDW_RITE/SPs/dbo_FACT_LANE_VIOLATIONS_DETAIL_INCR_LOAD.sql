CREATE PROC [DBO].[FACT_LANE_VIOLATIONS_DETAIL_INCR_LOAD] AS 

/*
USE EDW_RITE
GO
USE EDW_RITE_DEV

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.FACT_LANE_VIOLATIONS_DETAIL_INCR_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.FACT_LANE_VIOLATIONS_DETAIL_INCR_LOAD
GO

EXEC DBO.FACT_LANE_VIOLATIONS_DETAIL_INCR_LOAD

SELECT COUNT_BIG(1) FROM dbo.FACT_LANE_VIOLATIONS_DETAIL  -- 2463388528


SELECT  TOP 100
	DAY_ID,MONTH_ID,LANE_ID,LANE_VIOL_ID,VIOLATION_ID,VIOL_DATE,VEHICLE_CLASS,VCLY_ID,AXLE_COUNT,LANE_VIOL_STATUS,REVIEW_STATUS,REVIEW_STATUS_ABBREV,BUSINESS_TYPE,VIOL_REJECT_TYPE,VIOL_CREATED,AGENCY_ID,
	TT_ID,TAG_STATUS,VEHICLE_SPEED,LIC_PLATE_STATE,LICENSE_PLATE_ID,REVIEW_DATE,TOLL_DUE,TOLL_PAID,VIOLATION_CODE,REVIEWED_USER_ID,TRANSACTION_FILE_DETAIL_ID,LAST_UPDATE_TYPE,LAST_UPDATE_DATE
FROM dbo.FACT_LANE_VIOLATIONS_DETAIL

SELECT * FROM edw_rite.dbo.PROCESS_LOG 
WHERE LOG_SOURCE = 'FACT_LANE_VIOLATIONS_DETAIL' AND LOG_DATE > '2019-09-01 8:00:00'
ORDER BY LOG_SOURCE, LOG_DATE

*/

/*	SELECT TOP 100 * FROM FACT_LANE_VIOLATIONS_DETAIL; SELECT COUNT(1) FROM FACT_LANE_VIOLATIONS_DETAIL */  
--#1	Shankar Metla	2018-09-08	CREATED
--#2	Andy Filipps	2018-10-02	Full rewrite for a new approach to avoid full month load

DECLARE @TABLE_NAME VARCHAR(100) = 'FACT_LANE_VIOLATIONS_DETAIL', @LOG_START_DATE DATETIME2 (2), @LOG_MESSAGE VARCHAR(1000), @ROW_COUNT BIGINT, @LOAD_CONTROL_DATE DATETIME2(2), @VPS_CONTROL_DATE DATETIME2(2), @ICS_CONTROL_DATE DATETIME2(2)
DECLARE @sql VARCHAR(MAX)

--DECLARE @Cur_Part INT
--DECLARE @Cur_Part_Text VARCHAR(3)

DECLARE @FULL_RELOAD BIT  
SELECT @FULL_RELOAD = CASE WHEN C.column_id IS NULL THEN 1 ELSE 0 END FROM sys.tables t LEFT JOIN sys.columns c ON c.object_id = t.object_id AND c.name = 'TT_ID' WHERE t.name = @TABLE_NAME

IF @FULL_RELOAD = 1 
BEGIN

	DECLARE @PART_RANGES VARCHAR(MAX) = ''
	--EXEC DBO.GET_PARTITION_MONTH_RANGE_STRING @PART_RANGES OUTPUT
	EXEC DBO.GET_PARTITION_DAYID_RANGE_STRING @PART_RANGES OUTPUT
	--PRINT @PART_RANGES

	SET @sql = '
	CREATE TABLE dbo.[FACT_LANE_VIOLATIONS_DETAIL_NEW_SET] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([LANE_VIOL_ID]), PARTITION (DAY_ID RANGE RIGHT FOR VALUES (' + @PART_RANGES + '))) AS
	SELECT 
			 CAST(main_table.[DAY_ID] AS int) AS [DAY_ID]
			, main_table.[DAY_ID] / 100 AS MONTH_ID
			, CAST(main_table.[LANE_ID] AS INT) AS [LANE_ID]
			--, CAST(main_table.[LANE_ABBREV] AS varchar(15)) AS [LANE_ABBREV]
			, ISNULL(CAST(main_table.[LANE_VIOL_ID] AS decimal(12,0)), 0) AS [LANE_VIOL_ID]
			--, ISNULL(CAST(main_table.[VIOLATION_ID] AS bigint), 0) AS [VIOLATION_ID]
			, CAST(main_table.[VIOL_DATE] AS datetime2(3)) AS [VIOL_DATE]
			, CAST(main_table.[VEHICLE_CLASS] AS smallint) AS [VEHICLE_CLASS]
			, ISNULL(CAST(main_table.[VCLY_ID] AS smallint), 0) AS [VCLY_ID]
			, CAST(main_table.[AXLE_COUNT] AS smallint) AS [AXLE_COUNT]
			, ISNULL(CAST(main_table.[LANE_VIOL_STATUS] AS varchar(2)), '''') AS [LANE_VIOL_STATUS]
			--, CAST(main_table.[LANE_VIOL_STATUS_DESCR] AS varchar(40)) AS [LANE_VIOL_STATUS_DESCR]
			, ISNULL(CAST(main_table.[REVIEW_STATUS] AS varchar(2)), '''') AS [REVIEW_STATUS]
			, CAST(main_table.[REVIEW_STATUS_ABBREV] AS varchar(6)) AS [REVIEW_STATUS_ABBREV]
			--, CAST(main_table.[STATUS_DESCR] AS varchar(55)) AS [STATUS_DESCR]
			--, CAST(main_table.[REV_STATUS_DESCR] AS varchar(40)) AS [REV_STATUS_DESCR]
			, ISNULL(CAST(main_table.[BUSINESS_TYPE] AS varchar(1)), '''') AS [BUSINESS_TYPE]
			, CAST(main_table.[VIOL_REJECT_TYPE] AS varchar(2)) AS [VIOL_REJECT_TYPE]
			--, CAST(main_table.[VIOL_REJECT_TYPE_DESCR] AS varchar(40)) AS [VIOL_REJECT_TYPE_DESCR]
			, CAST(main_table.[VIOL_CREATED] AS varchar(1)) AS [VIOL_CREATED]
			, CAST(main_table.[AGENCY_ID] AS VARCHAR(6)) AS [AGENCY_ID]
			, CAST(main_table.[TAG_ID] AS varchar(12)) AS [TAG_ID]
			, ATT.TT_ID
			, CAST(main_table.[TAG_STATUS] AS int) AS [TAG_STATUS]
			, CAST(main_table.[VEHICLE_SPEED] AS smallint) AS [VEHICLE_SPEED]
			, CAST(main_table.[LIC_PLATE_STATE] AS varchar(3)) AS [LIC_PLATE_STATE]
			, CAST(main_table.[LIC_PLATE_NBR] AS varchar(15)) AS [LIC_PLATE_NBR]
			, CAST(main_table.[LICENSE_PLATE_ID] AS int) AS [LICENSE_PLATE_ID]
			, CAST(main_table.[REVIEW_DATE] AS datetime2(3)) AS [REVIEW_DATE]
			, CAST(main_table.[TOLL_DUE] AS decimal(6,2)) AS [TOLL_DUE]
			, CAST(main_table.[TOLL_PAID] AS decimal(9,2)) AS [TOLL_PAID]
			, CAST(main_table.[VIOLATION_CODE] AS smallint) AS [VIOLATION_CODE]
			, CAST(main_table.[REVIEWED_BY] AS varchar(30)) AS [REVIEWED_BY]
			--, U.USERID AS REVIEWED_USER_ID
			, CAST(main_table.[TRANSACTION_FILE_DETAIL_ID] AS decimal(14,0)) AS [TRANSACTION_FILE_DETAIL_ID]
			, COALESCE(LV.SEQUENCE_NBR,ILV.SEQUENCE_NBR) AS VES_SERIAL_NO
			, CAST(main_table.[LAST_UPDATE_TYPE] AS varchar(1)) AS [LAST_UPDATE_TYPE]
			, CAST(main_table.[LAST_UPDATE_DATE] AS datetime2(3)) AS [LAST_UPDATE_DATE]
	FROM dbo.[FACT_LANE_VIOLATIONS_DETAIL] AS main_table
	LEFT JOIN dbo.TOLL_TAGS ATT ON ATT.TAG_ID = main_table.TAG_ID AND ATT.AGENCY_ID = CAST(main_table.AGENCY_ID AS VARCHAR(6))
	--LEFT JOIN dbo.DIM_USERS AS U ON U.USERNAME = main_table.[REVIEWED_BY]
	LEFT JOIN LND_LG_ICRS.ICRS_OWNER.ICS_LANE_VIOLATIONS AS ILV ON ILV.LANE_VIOL_ID = main_table.[LANE_VIOL_ID]
	LEFT JOIN LND_LG_VPS.VP_OWNER.LANE_VIOLATIONS AS LV ON LV.LANE_VIOL_ID = main_table.[LANE_VIOL_ID]
	OPTION (LABEL = ''FACT_LANE_VIOLATIONS_DETAIL_NEW_SET LOAD'');'

	EXEC (@sql)
	EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT

	CREATE STATISTICS [STATS_FACT_LANE_VIOLATIONS_DETAIL_001] ON dbo.[FACT_LANE_VIOLATIONS_DETAIL_NEW_SET] ([DAY_ID]);
	CREATE STATISTICS [STATS_FACT_LANE_VIOLATIONS_DETAIL_002] ON dbo.[FACT_LANE_VIOLATIONS_DETAIL_NEW_SET] ([LANE_ID],VES_SERIAL_NO);
	CREATE STATISTICS [STATS_FACT_LANE_VIOLATIONS_DETAIL_003] ON dbo.[FACT_LANE_VIOLATIONS_DETAIL_NEW_SET] ([REVIEW_STATUS]);
	CREATE STATISTICS [STATS_FACT_LANE_VIOLATIONS_DETAIL_004] ON dbo.[FACT_LANE_VIOLATIONS_DETAIL_NEW_SET] ([LANE_VIOL_STATUS]);
	CREATE STATISTICS [STATS_FACT_LANE_VIOLATIONS_DETAIL_005] ON dbo.[FACT_LANE_VIOLATIONS_DETAIL_NEW_SET] ([LANE_VIOL_ID],[MONTH_ID],[DAY_ID]);
	CREATE STATISTICS [STATS_FACT_LANE_VIOLATIONS_DETAIL_006] ON dbo.[FACT_LANE_VIOLATIONS_DETAIL_NEW_SET] ([VIOLATION_CODE]);
	CREATE STATISTICS [STATS_FACT_LANE_VIOLATIONS_DETAIL_007] ON dbo.[FACT_LANE_VIOLATIONS_DETAIL_NEW_SET] ([REVIEW_STATUS_ABBREV]);
	CREATE STATISTICS [STATS_FACT_LANE_VIOLATIONS_DETAIL_008] ON dbo.[FACT_LANE_VIOLATIONS_DETAIL_NEW_SET] ([TRANSACTION_FILE_DETAIL_ID]);
	CREATE STATISTICS [STATS_FACT_LANE_VIOLATIONS_DETAIL_009] ON dbo.[FACT_LANE_VIOLATIONS_DETAIL_NEW_SET] (MONTH_ID,[DAY_ID],[LANE_ID]);

	SET @sql = '
	IF OBJECT_ID(''dbo.[' + @TABLE_NAME + '_PREV]'') IS NOT NULL	DROP TABLE dbo.[' + @TABLE_NAME + '_PREV];
	IF OBJECT_ID(''dbo.[' + @TABLE_NAME + ']'') IS NOT NULL			RENAME OBJECT::dbo.[' + @TABLE_NAME + '] TO [' + @TABLE_NAME + '_PREV];
	IF OBJECT_ID(''dbo.[' + @TABLE_NAME + '_NEW_SET]'') IS NOT NULL	RENAME OBJECT::dbo.[' + @TABLE_NAME + '_NEW_SET] TO [' + @TABLE_NAME + '];'
	EXEC (@sql)

	SET  @LOG_MESSAGE = 'Complete Full reload of the Table with a new column <<TT_ID>>'
	EXEC dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, @ROW_COUNT

END

-- STEP 1: Get the next Load Control Date from the Control Table
SET @LOG_START_DATE = GETDATE()

SELECT	@VPS_CONTROL_DATE = LAST_RUN_DATE FROM	dbo.LOAD_PROCESS_CONTROL WHERE	TABLE_NAME = 'FACT_LANE_VIOLATIONS_DETAIL&LANE_VIOLATIONS'
IF @VPS_CONTROL_DATE IS NULL 
BEGIN
	SELECT	@VPS_CONTROL_DATE = ISNULL(MAX(LAST_UPDATE_DATE), '1990-01-01') FROM	dbo.FACT_LANE_VIOLATIONS_DETAIL
END

SELECT	@ICS_CONTROL_DATE = LAST_RUN_DATE FROM	dbo.LOAD_PROCESS_CONTROL WHERE	TABLE_NAME = 'FACT_LANE_VIOLATIONS_DETAIL&ICS_LANE_VIOLATIONS'
IF @ICS_CONTROL_DATE IS NULL 
BEGIN
	SELECT	@ICS_CONTROL_DATE = ISNULL(MAX(LAST_UPDATE_DATE), '1990-01-01') FROM	dbo.FACT_LANE_VIOLATIONS_DETAIL
END

SELECT @LOAD_CONTROL_DATE = CASE WHEN @VPS_CONTROL_DATE > @ICS_CONTROL_DATE THEN @ICS_CONTROL_DATE ELSE @VPS_CONTROL_DATE END

---- !!!!!!!!!!!!!!!!!!!!! TESTING ONLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--SET @LOAD_CONTROL_DATE = CAST('2018-09-01 00:00:00.00' AS DATETIME2(2)) 
---- !!!!!!!!!!!!!!!!!!!!! TESTING ONLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

--PRINT @LOAD_CONTROL_DATE

-- STEP 2: Initiate LOG
SELECT  @LOG_MESSAGE = 'Started to load updates from ' + CONVERT(VARCHAR(19),@LOAD_CONTROL_DATE,121)
EXEC    dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE,  NULL

-- STEP 3: Get maximum Partition and it's baundry value
--EXEC DBO.PARTITION_MANAGE_MONTHLY_LOAD @TABLE_NAME

IF OBJECT_ID('dbo.FACT_LANE_VIOLATIONS_DETAIL_NEW_SET') IS NOT NULL DROP TABLE dbo.FACT_LANE_VIOLATIONS_DETAIL_NEW_SET

--STEP #7: -- Getting all changes to a new table
CREATE TABLE dbo.FACT_LANE_VIOLATIONS_DETAIL_NEW_SET WITH (CLUSTERED INDEX (LANE_VIOL_ID), DISTRIBUTION = HASH(LANE_VIOL_ID)) AS
WITH VPS_CTE AS
(
SELECT  CAST(CONVERT(VARCHAR(8), LV.VIOL_DATE,112) AS INT) DAY_ID,
 		LV.LANE_ID,
		--LV.LANE_ABBREV,
		LV.LANE_VIOL_ID,
		LV.VIOL_DATE,
		CAST(LV.VEHICLE_CLASS AS SMALLINT) AS VEHICLE_CLASS,
		CAST(LV.AXLE_COUNT AS SMALLINT) AS AXLE_COUNT,
		LV.LANE_VIOL_STATUS,
		LV.REVIEW_STATUS,
		CASE WHEN LV.LANE_ID IS NULL THEN 'V' ELSE 'Z' END BUSINESS_TYPE,  
		LV.VIOL_REJECT_TYPE,
		LV.VIOL_CREATED,
		CAST(LV.AGENCY_ID AS VARCHAR(6)) AS AGENCY_ID,
		LV.TAG_ID,
		CAST(LV.TAG_STATUS AS INT) AS TAG_STATUS,
		CAST(LV.VEHICLE_SPEED AS SMALLINT) AS VEHICLE_SPEED,
		COALESCE(LV.CAMERA_LIC_PLATE_NBR, LV.LIC_PLATE_NBR) LIC_PLATE_NBR,
		COALESCE(LV.CAMERA_LIC_PLATE_STATE, LV.LIC_PLATE_STATE) LIC_PLATE_STATE,
		LV.REVIEW_DATE,
		LV.TOLL_DUE,
		LV.TOLL_PAID,
		CAST(LV.VIOLATION_CODE AS SMALLINT) AS VIOLATION_CODE,
		LV.REVIEWED_BY,
		LV.TRANSACTION_FILE_DETAIL_ID, 
		LV.SEQUENCE_NBR,
		LV.LAST_UPDATE_TYPE,
		LV.LAST_UPDATE_DATE --SELECT COUNT_BIG(*) -- SELECT TOP 2 * 
FROM LND_LG_VPS.VP_OWNER.LANE_VIOLATIONS LV
WHERE LV.LAST_UPDATE_DATE >= @VPS_CONTROL_DATE
),
ICS_CTE AS 
(
SELECT  CAST(CONVERT(VARCHAR(8), LV.VIOL_DATE,112) AS INT) DAY_ID,
 		LV.LANE_ID,
		--LV.LANE_ABBREV,
		LV.LANE_VIOL_ID,
		LV.VIOL_DATE,
		CAST(LV.VEHICLE_CLASS AS SMALLINT) AS VEHICLE_CLASS,
		CAST(LV.AXLE_COUNT AS SMALLINT) AS AXLE_COUNT,
		LV.LANE_VIOL_STATUS,
		LV.REVIEW_STATUS,
		CASE WHEN LV.LANE_ID IS NULL THEN 'V' ELSE 'Z' END BUSINESS_TYPE,  
		LV.VIOL_REJECT_TYPE,
		LV.VIOL_CREATED,
		CAST(LV.AGENCY_ID AS VARCHAR(6)) AS AGENCY_ID,
		LV.TAG_ID,
		CAST(LV.TAG_STATUS AS INT) AS TAG_STATUS,
		CAST(LV.VEHICLE_SPEED AS SMALLINT) AS VEHICLE_SPEED,
		COALESCE(LV.CAMERA_LIC_PLATE_NBR, LV.LIC_PLATE_NBR) LIC_PLATE_NBR,
		COALESCE(LV.CAMERA_LIC_PLATE_STATE, LV.LIC_PLATE_STATE) LIC_PLATE_STATE,
		LV.REVIEW_DATE,
		LV.TOLL_DUE,
		LV.TOLL_PAID,
		CAST(LV.VIOLATION_CODE AS SMALLINT) AS VIOLATION_CODE,
		LV.REVIEWED_BY,
		LV.TRANSACTION_FILE_DETAIL_ID, 
		LV.SEQUENCE_NBR,
		LV.LAST_UPDATE_TYPE,
		LV.LAST_UPDATE_DATE --SELECT COUNT_BIG(*) -- SELECT TOP 2 *
FROM LND_LG_ICRS.ICRS_OWNER.ICS_LANE_VIOLATIONS LV 
WHERE   LV.REVIEW_STATUS IN ('N','D')
	AND	LV.LANE_VIOL_ID  NOT IN (SELECT LANE_VIOL_ID FROM VPS_CTE) 	--V.LANE_VIOL_ID IS NULL
	AND LV.LAST_UPDATE_DATE >= @ICS_CONTROL_DATE
	),
CCCP_CTE AS
(
SELECT * FROM VPS_CTE
UNION ALL
SELECT * FROM ICS_CTE
)
SELECT  LV.DAY_ID,
		LV.DAY_ID / 100 AS MONTH_ID,
 		CAST(LV.LANE_ID AS INT) AS LANE_ID,
		--LV.LANE_ABBREV,
		ISNULL(LV.LANE_VIOL_ID,-1) AS LANE_VIOL_ID,
		--ISNULL(CAST(V.VIOLATION_ID AS BigInt), -1) VIOLATION_ID, 
		LV.VIOL_DATE,
		LV.VEHICLE_CLASS,
		ISNULL(CAST(CT.VCLY_ID AS SMALLINT),-1) AS VCLY_ID,
		LV.AXLE_COUNT,
		ISNULL(CAST(LV.LANE_VIOL_STATUS AS VARCHAR(2)),'-1') LANE_VIOL_STATUS,
		--CASE	WHEN LV.LANE_VIOL_STATUS = 'E' THEN 'Excused Lane Violations' 
		--		ELSE LVS.LANE_VIOL_STATUS_DESCR 
		--END LANE_VIOL_STATUS_DESCR,  
		ISNULL(CAST(LV.REVIEW_STATUS AS VARCHAR(2)),'-1') REVIEW_STATUS,
		'ICRS-' + CASE WHEN LV.REVIEW_STATUS = 'E' THEN 'R' ELSE LV.REVIEW_STATUS END REVIEW_STATUS_ABBREV,
		--DC.NAME STATUS_DESCR,
		--RS.REV_STATUS_DESCR,
		LV.BUSINESS_TYPE,  
		ISNULL(LV.VIOL_REJECT_TYPE,'-1') VIOL_REJECT_TYPE,
		--VRT.VIOL_REJECT_TYPE_DESCR,
		LV.VIOL_CREATED,
		LV.AGENCY_ID,
		LV.TAG_ID,
		ATT.TT_ID,
		LV.TAG_STATUS,
		LV.VEHICLE_SPEED,
		LV.LIC_PLATE_STATE,
		CAST(LV.LIC_PLATE_NBR AS varchar(15)) AS LIC_PLATE_NBR,
		LP.LICENSE_PLATE_ID,
		LV.REVIEW_DATE,
		LV.TOLL_DUE,
		--CASE	WHEN ISNULL(V.VIOL_STATUS,'') = 'P' AND ISNULL(V.TOLL_PAID,0) = 0 THEN ISNULL(V.TOLL_DUE,0) 
		--		WHEN LV.LANE_VIOL_STATUS IN ('C') THEN ISNULL(V.TOLL_PAID,0) 
		--	ELSE LV.TOLL_PAID  END TOLL_PAID,
		LV.TOLL_PAID  AS TOLL_PAID,
		LV.VIOLATION_CODE,
		LV.REVIEWED_BY,
		--U.USERID AS REVIEWED_USER_ID,
		ISNULL(LV.TRANSACTION_FILE_DETAIL_ID,-1) AS TRANSACTION_FILE_DETAIL_ID, 
		LV.SEQUENCE_NBR AS VES_SERIAL_NO,
		LV.LAST_UPDATE_TYPE,
		CAST(LV.LAST_UPDATE_DATE AS datetime2(3)) AS LAST_UPDATE_DATE --SELECT COUNT_BIG(*) -- SELECT TOP 2 * 
FROM CCCP_CTE AS LV
LEFT JOIN dbo.TOLL_TAGS ATT ON ATT.TAG_ID = LV.TAG_ID AND ATT.AGENCY_ID = LV.AGENCY_ID
--LEFT JOIN dbo.DIM_USERS AS U ON U.USERNAME = LV.REVIEWED_BY
LEFT JOIN dbo.DIM_VEH_CLSS_TYPES CT  ON LV.VEHICLE_CLASS = CT.AXLES
--LEFT JOIN dbo.FACT_VIOLATIONS_DETAIL V ON V.LANE_VIOL_ID = LV.LANE_VIOL_ID
--LEFT JOIN dbo.LANE_VIOL_STATUS LVS ON LV.LANE_VIOL_STATUS = LVS.LANE_VIOL_STATUS
--LEFT JOIN LND_LG_ICRS.ICRS_OWNER.REVIEW_STATUS RS ON LV.REVIEW_STATUS = RS.REVIEW_STATUS
--LEFT JOIN dbo.VIOL_REJECT_TYPES VRT ON LV.VIOL_REJECT_TYPE = VRT.VIOL_REJECT_TYPE
--LEFT JOIN dbo.DIM_CATEGORY DC ON 'ICRS-' + CASE WHEN LV.REVIEW_STATUS = 'E' THEN 'R' ELSE LV.REVIEW_STATUS END = DC.ABBREV
LEFT JOIN dbo.DIM_LICENSE_PLATE AS LP ON LV.LIC_PLATE_NBR = LP.LICENSE_PLATE_NBR AND LV.LIC_PLATE_STATE = LP.LICENSE_PLATE_STATE
OPTION (LABEL = 'FACT_LANE_VIOLATIONS_DETAIL LOAD');

-- Logging
EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
SET  @LOG_MESSAGE = 'The Main query Stage table loaded. N changed rows: '
EXEC dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, @ROW_COUNT


DECLARE @IDENTITY_COLUMNS VARCHAR(8000) = '[LANE_VIOL_ID]'

EXEC DBO.PARTITION_SWITCH_MONTHLY_LOAD @TABLE_NAME,	@IDENTITY_COLUMNS
--EXEC DBO.PARTITION_SWITCH_NUMBER_BASED_LOAD @TABLE_NAME,	@IDENTITY_COLUMNS


--STEP #12: -- Set a new update date to LOAD_PROCESS_CONTROL table for the next load
SELECT @VPS_CONTROL_DATE = MAX(LAST_UPDATE_DATE) FROM  LND_LG_VPS.VP_OWNER.LANE_VIOLATIONS
UPDATE dbo.LOAD_PROCESS_CONTROL SET LAST_RUN_DATE = @VPS_CONTROL_DATE WHERE TABLE_NAME = 'FACT_LANE_VIOLATIONS_DETAIL&LANE_VIOLATIONS'

SELECT @ICS_CONTROL_DATE = MAX(LAST_UPDATE_DATE) FROM  LND_LG_ICRS.ICRS_OWNER.ICS_LANE_VIOLATIONS
UPDATE dbo.LOAD_PROCESS_CONTROL SET LAST_RUN_DATE = @ICS_CONTROL_DATE WHERE TABLE_NAME = 'FACT_LANE_VIOLATIONS_DETAIL&ICS_LANE_VIOLATIONS'

--STEP #13: UPDATE STATISTICS and delete temp tables
UPDATE STATISTICS dbo.FACT_LANE_VIOLATIONS_DETAIL  

IF OBJECT_ID('dbo.FACT_LANE_VIOLATIONS_DETAIL_NEW_SET') IS NOT NULL DROP TABLE dbo.FACT_LANE_VIOLATIONS_DETAIL_NEW_SET

SET  @LOG_MESSAGE = 'FACT table updated. Load finished.'
EXEC dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, NULL

