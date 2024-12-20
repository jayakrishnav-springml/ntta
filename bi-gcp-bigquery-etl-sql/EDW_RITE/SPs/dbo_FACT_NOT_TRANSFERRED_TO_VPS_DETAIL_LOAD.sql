CREATE PROC [dbo].[FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_LOAD] AS --DROP PROC dbo.[FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_LOAD]

/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_LOAD
GO

EXEC dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_LOAD

SELECT TOP 100 * FROM FACT_NOT_TRANSFERRED_TO_VPS_DETAIL  
SELECT COUNT_BIG(1) FROM FACT_NOT_TRANSFERRED_TO_VPS_DETAIL  

*/

--STEP #0: INITIATE VARIABLES

DECLARE @TABLE_NAME VARCHAR(50) = 'FACT_NOT_TRANSFERRED_TO_VPS_DETAIL', @START_DATE DATETIME2(2) = SYSDATETIME(), @LOG_MESSAGE VARCHAR(1000) = 'Started full load', @ROW_COUNT BIGINT --, @LOAD_CONTROL_DATE DATETIME2(2) 

--SELECT  @TABLE_NAME = 'FACT_NOT_TRANSFERRED_TO_VPS_DETAIL', @START_DATE = GETDATE(), @LOG_MESSAGE = 'Started full load'
EXEC    dbo.LOG_PROCESS @TABLE_NAME, @START_DATE, @LOG_MESSAGE,  NULL


DECLARE @FULL_RELOAD BIT  
SELECT @FULL_RELOAD = CASE WHEN C.column_id IS NULL THEN 1 ELSE 0 END FROM sys.tables t LEFT JOIN sys.columns c ON c.object_id = t.object_id AND c.name = 'TT_ID' WHERE t.name = @TABLE_NAME

IF @FULL_RELOAD = 1 
BEGIN

	--DECLARE @PART_RANGES VARCHAR(MAX) = ''
	DECLARE @sql VARCHAR(MAX) = ''
	--EXEC DBO.GET_PARTITION_MONTH_RANGE_STRING @PART_RANGES OUTPUT
	--PRINT @PART_RANGES

	CREATE TABLE dbo.[FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_NEW_SET] WITH (CLUSTERED INDEX ( [LANE_VIOL_ID] ), DISTRIBUTION = HASH([LANE_VIOL_ID]))
	AS 
	SELECT 
			 CAST(main_table.[DAY_ID] AS int) AS [DAY_ID]
			, main_table.[DAY_ID] / 100 AS MONTH_ID
			, ISNULL(CAST(main_table.[LANE_ID] AS Int), 0) AS [LANE_ID]
			, ISNULL(CAST(main_table.[LANE_ABBREV] AS varchar(15)), '') AS [LANE_ABBREV]
			, ISNULL(CAST(main_table.[LANE_VIOL_ID] AS decimal(12,0)), 0) AS [LANE_VIOL_ID]
			, ISNULL(CAST(main_table.[VIOL_DATE] AS datetime2(0)), '1900-01-01') AS [VIOL_DATE]
			, ISNULL(CAST(main_table.[VCLY_ID] AS SMALLINT), 0) AS [VCLY_ID]
			, CAST(main_table.[VEHICLE_CLASS] AS SMALLINT) AS [VEHICLE_CLASS]
			, CAST(main_table.[AXLE_COUNT] AS SMALLINT) AS [AXLE_COUNT]
			, CAST(main_table.[LANE_VIOL_STATUS] AS varchar(1)) AS [LANE_VIOL_STATUS]
			, CAST(main_table.[LANE_VIOL_STATUS_DESCR] AS varchar(40)) AS [LANE_VIOL_STATUS_DESCR]
			, CAST(main_table.[REVIEW_STATUS] AS varchar(1)) AS [REVIEW_STATUS]
			, ISNULL(CAST(main_table.[REVIEW_STATUS_ABBREV] AS varchar(7)), '') AS [REVIEW_STATUS_ABBREV]
			, CAST(main_table.[STATUS_DESCR] AS varchar(55)) AS [STATUS_DESCR]
			, CAST(main_table.[REV_STATUS_DESCR] AS varchar(40)) AS [REV_STATUS_DESCR]
			, ISNULL(CAST(main_table.[BUSINESS_TYPE] AS varchar(1)), '') AS [BUSINESS_TYPE]
			, CAST(main_table.[VIOL_REJECT_TYPE] AS varchar(2)) AS [VIOL_REJECT_TYPE]
			, CAST(main_table.[VIOL_REJECT_TYPE_DESCR] AS varchar(40)) AS [VIOL_REJECT_TYPE_DESCR]
			, CAST(main_table.[VIOL_CREATED] AS varchar(1)) AS [VIOL_CREATED]
			, CAST(main_table.[AGENCY_ID] AS decimal(2,0)) AS [AGENCY_ID]
			, CAST(main_table.[TAG_ID] AS varchar(12)) AS [TAG_ID]
			, ATT.[TT_ID] AS [TT_ID]
			, CAST(main_table.[TAG_STATUS] AS decimal(6,0)) AS [TAG_STATUS]
			, CAST(main_table.[VEHICLE_SPEED] AS decimal(3,0)) AS [VEHICLE_SPEED]
			, LP.LICENSE_PLATE_ID
			, CAST(main_table.[LIC_PLATE_NBR] AS varchar(25)) AS [LIC_PLATE_NBR]
			, CAST(main_table.[LIC_PLATE_STATE] AS varchar(3)) AS [LIC_PLATE_STATE]
			, CAST(main_table.[REVIEW_DATE] AS datetime2(0)) AS [REVIEW_DATE]
			, CAST(main_table.[TOLL_DUE] AS decimal(6,2)) AS [TOLL_DUE]
			, CAST(main_table.[TOLL_PAID] AS decimal(6,2)) AS [TOLL_PAID]
	FROM dbo.[FACT_NOT_TRANSFERRED_TO_VPS_DETAIL] AS main_table
	LEFT JOIN dbo.TOLL_TAGS ATT ON ATT.TAG_ID = main_table.TAG_ID
	LEFT JOIN dbo.DIM_LICENSE_PLATE LP ON  LP.LICENSE_PLATE_NBR = main_table.LIC_PLATE_NBR AND LP.LICENSE_PLATE_STATE = main_table.LIC_PLATE_STATE
	OPTION (LABEL = 'FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_NEW_SET LOAD');

	EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT

	CREATE STATISTICS STATS_FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_001 ON dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_NEW_SET (DAY_ID,LANE_ID)
	CREATE STATISTICS STATS_FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_002 ON dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_NEW_SET (REVIEW_STATUS)
	CREATE STATISTICS STATS_FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_003 ON dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_NEW_SET (LANE_VIOL_STATUS)
	CREATE STATISTICS STATS_FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_004 ON dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_NEW_SET (LANE_ID)
	CREATE STATISTICS STATS_FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_005 ON dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_NEW_SET (MONTH_ID,DAY_ID, [LANE_VIOL_ID])
	
	--DECLARE @sql VARCHAR(MAX) = '', @TABLE_NAME VARCHAR(50) = 'FACT_NOT_TRANSFERRED_TO_VPS_DETAIL'
	SET @sql = '
	IF OBJECT_ID(''dbo.[' + @TABLE_NAME + '_PREV]'') IS NOT NULL		DROP TABLE dbo.[' + @TABLE_NAME + '_PREV];
	IF OBJECT_ID(''dbo.[' + @TABLE_NAME + ']'') IS NOT NULL			RENAME OBJECT::dbo.[' + @TABLE_NAME + '] TO [' + @TABLE_NAME + '_PREV];
	IF OBJECT_ID(''dbo.[' + @TABLE_NAME + '_NEW_SET]'') IS NOT NULL	RENAME OBJECT::dbo.[' + @TABLE_NAME + '_NEW_SET] TO [' + @TABLE_NAME + '];'
	EXEC (@sql)

	SET  @LOG_MESSAGE = 'Complete Full reload of the Table with a new column <<TT_ID>>'
	EXEC dbo.LOG_PROCESS @TABLE_NAME, @START_DATE, @LOG_MESSAGE, @ROW_COUNT

END


IF OBJECT_ID('dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_STAGE') IS NOT NULL DROP TABLE dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_STAGE


CREATE TABLE dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_STAGE 
WITH (CLUSTERED INDEX (LANE_VIOL_ID), DISTRIBUTION = HASH(LANE_VIOL_ID)) AS 
	WITH IFF AS
	(
		SELECT FF_ID  
		FROM LND_LG_ICRS.ICRS_OWNER.ICS_FOUND_FILES 
		WHERE [STATUS] <> 'POSTED'
	)
	SELECT  
		CAST(CONVERT(VARCHAR(8), LV.VIOL_DATE,112) AS INT) DAY_ID,
		CAST(CONVERT(VARCHAR(6), LV.VIOL_DATE,112) AS INT) MONTH_ID,
 		CAST(LANE_ID AS INT) LANE_ID,
		LANE_ABBREV,
		LANE_VIOL_ID,
		LV.VIOL_DATE,
		ISNULL(CAST(CT.VCLY_ID AS SMALLINT),-1) AS VCLY_ID,
		CAST(VEHICLE_CLASS AS SMALLINT) AS VEHICLE_CLASS,
		CAST(AXLE_COUNT AS SMALLINT) AS AXLE_COUNT,
		LV.LANE_VIOL_STATUS,
		CASE	WHEN LV.LANE_VIOL_STATUS = 'E' THEN 'Excused Lane Violations' 
				ELSE LANE_VIOL_STATUS_DESCR 
		END LANE_VIOL_STATUS_DESCR,  
		LV.REVIEW_STATUS,
		'ICRS-NP' REVIEW_STATUS_ABBREV,
		[DIM_CATEGORY].NAME STATUS_DESCR,
		REV_STATUS_DESCR,
		CASE WHEN LANE_ID IS NULL THEN 'V' ELSE 'Z' END BUSINESS_TYPE, 
		LV.VIOL_REJECT_TYPE,
		VIOL_REJECT_TYPE_DESCR,
		VIOL_CREATED,
		LV.AGENCY_ID,
		LV.TAG_ID,
		ATT.TT_ID AS TT_ID,
		LV.TAG_STATUS,
		VEHICLE_SPEED,
		LP.LICENSE_PLATE_ID  AS LICENSE_PLATE_ID,
		LIC_PLATE_NBR,
		LIC_PLATE_STATE,
		REVIEW_DATE,
		TOLL_DUE,
		TOLL_PAID
FROM LND_LG_ICRS.ICRS_OWNER.ICS_LANE_VIOLATIONS LV
LEFT JOIN dbo.DIM_VEH_CLSS_TYPES CT  ON LV.VEHICLE_CLASS = CT.AXLES
LEFT JOIN dbo.LANE_VIOL_STATUS  ON LV.LANE_VIOL_STATUS = LANE_VIOL_STATUS.LANE_VIOL_STATUS
LEFT JOIN LND_LG_ICRS.ICRS_OWNER.REVIEW_STATUS  ON LV.REVIEW_STATUS = REVIEW_STATUS.REVIEW_STATUS
LEFT JOIN dbo.VIOL_REJECT_TYPES  ON LV.VIOL_REJECT_TYPE = VIOL_REJECT_TYPES.VIOL_REJECT_TYPE
LEFT JOIN dbo.DIM_CATEGORY  ON 'ICRS-NP' = DIM_CATEGORY.ABBREV
LEFT JOIN dbo.TOLL_TAGS ATT ON ATT.TAG_ID = LV.TAG_ID
LEFT JOIN dbo.DIM_LICENSE_PLATE LP ON  LP.LICENSE_PLATE_NBR = LV.LIC_PLATE_NBR AND LP.LICENSE_PLATE_STATE = LV.LIC_PLATE_STATE
WHERE LV.FF_ID IN (SELECT FF_ID  FROM IFF)  AND LV.REVIEW_STATUS IN ('O', 'R', 'E')
OPTION (LABEL = 'FACT_NOT_TRANSFERRED_TO_VPS_DETAIL LOAD');

EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
SET  @LOG_MESSAGE = 'Finished full load to stage'
EXEC dbo.LOG_PROCESS @TABLE_NAME, @START_DATE, @LOG_MESSAGE, @ROW_COUNT


	--STEP #2: Replace OLD table with NEW
CREATE STATISTICS STATS_FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_001 ON dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_STAGE (DAY_ID,LANE_ID)
CREATE STATISTICS STATS_FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_002 ON dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_STAGE (REVIEW_STATUS)
CREATE STATISTICS STATS_FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_003 ON dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_STAGE (REVIEW_STATUS_ABBREV)
CREATE STATISTICS STATS_FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_004 ON dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_STAGE (LANE_VIOL_STATUS)
CREATE STATISTICS STATS_FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_005 ON dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_STAGE (LANE_VIOL_STATUS_DESCR)
CREATE STATISTICS STATS_FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_006 ON dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_STAGE (LANE_ID)
CREATE STATISTICS STATS_FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_007 ON dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_STAGE (MONTH_ID,DAY_ID)


IF OBJECT_ID('dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_OLD') IS NOT NULL 	DROP TABLE dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_OLD;
IF OBJECT_ID('dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL') IS NOT NULL		RENAME OBJECT::dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL TO FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_OLD;
RENAME OBJECT::dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_STAGE				TO FACT_NOT_TRANSFERRED_TO_VPS_DETAIL;

--EXEC dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
SET  @LOG_MESSAGE = 'Finished full load'
EXEC dbo.LOG_PROCESS @TABLE_NAME, @START_DATE, @LOG_MESSAGE, NULL

--IF OBJECT_ID('dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_OLD') IS NOT NULL 	DROP TABLE dbo.FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_OLD;


