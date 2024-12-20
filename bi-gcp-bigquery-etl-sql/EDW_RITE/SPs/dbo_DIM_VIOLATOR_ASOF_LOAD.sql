CREATE PROC [DBO].[DIM_VIOLATOR_ASOF_LOAD] AS 
/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.DIM_VIOLATOR_ASOF_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.DIM_VIOLATOR_ASOF_LOAD
GO

EXEC EDW_RITE.DBO.DIM_VIOLATOR_ASOF_LOAD



*/

/*
SELECT TOP 1000 * FROM dbo.DIM_VIOLATOR_ASOF WHERE PARTITION_DATE = '2019-01-01'

*/

DECLARE @PARTITION_DATE DATE = DATEADD(DAY,1,EOMONTH(GETDATE(),-1))--(SELECT TOP(1) [VIOL_DATE] FROM  LND_LG_VPS.[VP_OWNER].[LANE_VIOLATIONS] ORDER BY 1 DESC) ----'2017-12-01'--
--SELECT 'DIM_VIOLATOR_ASOF LOAD PARTITION: ' + CONVERT(VARCHAR(10), @PARTITION_DATE, 121)
--PRINT @PARTITION_DATE SELECT DATEADD(DAY,1,EOMONTH(GETDATE(),-1))

EXEC dbo.PARTITION_AS_OF_DATE_TABLE_UPDATE 'DIM_VIOLATOR_ASOF', @PARTITION_DATE
--PRINT @PARTITION_DATE

IF OBJECT_ID('dbo.DIM_VIOLATOR_ASOF_FINAL')>0 	DROP TABLE dbo.DIM_VIOLATOR_ASOF_FINAL;

--CREATE a NEW Partition Table 
CREATE TABLE [dbo].DIM_VIOLATOR_ASOF_FINAL WITH (CLUSTERED INDEX (VIOLATOR_ID), DISTRIBUTION = HASH(VIOLATOR_ID)) AS
-- EXPLAIN
	SELECT 
			 ISNULL(CAST(main_table.[VIOLATOR_ID] AS bigint), 0) AS [VIOLATOR_ID]
			, ISNULL(CAST(main_table.[PARTITION_DATE] AS date), '1900-01-01') AS [PARTITION_DATE]
			, ISNULL(CAST(main_table.[VIOLATOR_TYPE] AS varchar(2)), '') AS [VIOLATOR_TYPE]
			, CAST(main_table.[VIOLATOR_FNAME] AS varchar(60)) AS [VIOLATOR_FNAME]
			, CAST(main_table.[VIOLATOR_LNAME] AS varchar(60)) AS [VIOLATOR_LNAME]
			, CAST(main_table.[VIOLATOR_FNAME2] AS varchar(60)) AS [VIOLATOR_FNAME2]
			, CAST(main_table.[VIOLATOR_LNAME2] AS varchar(240)) AS [VIOLATOR_LNAME2]
			, CAST(main_table.[PHONE_NBR] AS varchar(15)) AS [PHONE_NBR]
			, CAST(main_table.[EMAIL_ADDR] AS varchar(80)) AS [EMAIL_ADDR]
			, CAST(main_table.[VIOLATOR_ADDR_SEQ] AS smallint) AS [VIOLATOR_ADDR_SEQ]
			, CAST(main_table.[ADDRESS1] AS varchar(30)) AS [ADDRESS1]
			, CAST(main_table.[ADDRESS2] AS varchar(30)) AS [ADDRESS2]
			, CAST(main_table.[CITY] AS varchar(20)) AS [CITY]
			, ISNULL(CAST(main_table.[STATE] AS varchar(3)), '') AS [STATE]
			, ISNULL(CAST(main_table.[ZIP_CODE] AS varchar(6)), '') AS [ZIP_CODE]
			, CAST(main_table.[PLUS4] AS varchar(4)) AS [PLUS4]
			, CAST(main_table.[ADDR_STATUS] AS varchar(2)) AS [ADDR_STATUS]
			, ISNULL(CAST(main_table.[LIC_PLATE_NBR] AS varchar(15)), '') AS [LIC_PLATE_NBR]
			, ISNULL(CAST(main_table.[LIC_PLATE_STATE] AS varchar(15)), '') AS [LIC_PLATE_STATE]
			, ISNULL(CAST(main_table.[VEHICLE_MAKE] AS varchar(6)), '') AS [VEHICLE_MAKE]
			, ISNULL(CAST(main_table.[VEHICLE_MODEL] AS varchar(6)), '') AS [VEHICLE_MODEL]
			, ISNULL(CAST(main_table.[VEHICLE_BODY] AS varchar(15)), '') AS [VEHICLE_BODY]
			, ISNULL(CAST(main_table.[VEHICLE_YEAR] AS varchar(6)), '') AS [VEHICLE_YEAR]
			, ISNULL(CAST(main_table.[VEHICLE_COLOR] AS varchar(20)), '') AS [VEHICLE_COLOR]
			, CAST(main_table.[VIN] AS varchar(50)) AS [VIN]
			, ISNULL(CAST(main_table.[DATE_CREATED] AS date), '1900-01-01') AS [DATE_CREATED]
			, ISNULL(CAST(main_table.[HV_FLAG] AS smallint), 0) AS [HV_FLAG]
			, ISNULL(CAST(main_table.[PAYMENT_PLAN_FLAG] AS smallint), 0) AS [PAYMENT_PLAN_FLAG]
			, ISNULL(CAST(main_table.[INSERT_DATE] AS datetime2(7)), '1900-01-01') AS [INSERT_DATE]
	FROM (
			SELECT --TOP 100
				ISNULL(A.VIOLATOR_ID, -1) VIOLATOR_ID
				, ISNULL(CAST('' + CONVERT(VARCHAR(10),@PARTITION_DATE,121) + '' AS DATE),'1/1/1900') AS PARTITION_DATE
				, A.VIOLATOR_TYPE
				, A.VIOLATOR_FNAME, A.VIOLATOR_LNAME
				, A.VIOLATOR_FNAME2, A.VIOLATOR_LNAME2
				, A.PHONE_NBR, A.EMAIL_ADDR
				, CAST(B.VIOLATOR_ADDR_SEQ AS SMALLINT) VIOLATOR_ADDR_SEQ, B.ADDRESS1, B.ADDRESS2, B.CITY,ISNULL(B.[STATE],'-1') AS [STATE], ISNULL(B.ZIP_CODE,'-1') AS ZIP_CODE, B.PLUS4, B.ADDR_STATUS
				, A.LIC_PLATE_NBR, ISNULL(CONVERT(VARCHAR(15), A.LIC_PLATE_STATE),'-1') AS LIC_PLATE_STATE
				, A.VEHICLE_MAKE, A.VEHICLE_MODEL, A.VEHICLE_BODY, A.VEHICLE_YEAR, A.VEHICLE_COLOR, A.VIN 
				, ISNULL(A.DATE_CREATED, '1/1/1900')  DATE_CREATED
				, ISNULL(A.HV_FLAG, -1) AS HV_FLAG
				, ISNULL(CAST(CASE WHEN D.ViolatorId IS NOT NULL THEN 1 ELSE 0 END AS SMALLINT), -1) AS PAYMENT_PLAN_FLAG
				, ISNULL(CAST(GETDATE() AS DATETIME2),'1/1/1900')  AS INSERT_DATE
			FROM dbo.VIOLATORS A
			LEFT JOIN dbo.VIOLATOR_ADDRESS_MAX_SEQ B ON A.VIOLATOR_ID = B.VIOLATOR_ID
			LEFT JOIN dbo.FACT_INVOICE_HV_ON_PAYMENTPLAN_STAGE D ON A.VIOLATOR_ID = D.ViolatorId

			UNION ALL

			SELECT --TOP 100
				ISNULL(CAST(A.VIOLATOR_ID AS BIGINT), -1) VIOLATOR_ID
				, ISNULL(CONVERT(VARCHAR(10),@PARTITION_DATE,121),'1/1/1900') AS PARTITION_DATE
				, '-1' AS VIOLATOR_TYPE
				, null AS VIOLATOR_FNAME, null AS VIOLATOR_LNAME
				, null AS VIOLATOR_FNAME2, null AS VIOLATOR_LNAME2
				, null AS PHONE_NBR, null AS EMAIL_ADDR
				, CAST(-1 AS SMALLINT) as VIOLATOR_ADDR_SEQ, null AS ADDRESS1, null AS ADDRESS2, null AS CITY, '-1' AS [STATE], '-1' AS ZIP_CODE, null AS PLUS4, '-1' AS ADDR_STATUS
				, '-1' AS LIC_PLATE_NBR, '-1' AS LIC_PLATE_STATE
				, '-1' AS VEHICLE_MAKE, '-1' AS VEHICLE_MODEL, '-1' AS VEHICLE_BODY, '-1' AS VEHICLE_YEAR, '-1' AS VEHICLE_COLOR, '-1' AS VIN, ISNULL('1/1/1900', '1/1/1900') AS DATE_CREATED
				, ISNULL(CAST(-1 AS SMALLINT), -1) AS HV_FLAG, ISNULL(CAST(-1 AS SMALLINT), -1) AS PAYMENT_PLAN_FLAG
				, ISNULL(CAST(GETDATE() AS DATETIME2),'1/1/1900')  AS INSERT_DATE
			FROM (SELECT DISTINCT VIOLATOR_ID FROM dbo.VIOLATIONS WHERE VIOLATOR_ID < -1) A
		)  AS main_table
	OPTION (LABEL = 'DIM_VIOLATOR_ASOF LOAD PARTITION');

	--Switch Partition 
EXEC [dbo].[PARTITION_SWITCH] @DEST_TABLE_NAME='DIM_VIOLATOR_ASOF',@SRC_TABLE_NAME='DIM_VIOLATOR_ASOF_FINAL',@AS_OF_DATE = @PARTITION_DATE

--SELECT COUNT_BIG(1) FROM dbo.DIM_VIOLATOR_ASOF_PARTITION_SWITCH  WHERE PARTITION_DATE = '2019-01-01' --33025136
--SELECT COUNT_BIG(1) FROM dbo.DIM_VIOLATOR_ASOF WHERE PARTITION_DATE = '2019-01-01'
	
IF OBJECT_ID('dbo.DIM_VIOLATOR_ASOF_FINAL')>0 	DROP TABLE dbo.DIM_VIOLATOR_ASOF_FINAL




