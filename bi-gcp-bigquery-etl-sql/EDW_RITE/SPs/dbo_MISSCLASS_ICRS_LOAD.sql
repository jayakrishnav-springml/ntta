CREATE PROC [DBO].[MISSCLASS_ICRS_LOAD] AS 

DECLARE @FROM_DATE AS DATE = '09/01/2016'

--Step #1: Find all ACCT_ID/TAG_IDs with multiple Class
IF OBJECT_ID('SandBox.dbo.MISSCLASS_ICRS_STAGE00')>0 DROP TABLE SandBox.dbo.MISSCLASS_ICRS_STAGE00;
CREATE TABLE SandBox.dbo.MISSCLASS_ICRS_STAGE00 WITH (DISTRIBUTION = HASH(LIC_PLATE_NBR)) --[TTXN_ID]
ASEXPLAIN
SELECT	COALESCE(CAMERA_LIC_PLATE_NBR, LIC_PLATE_NBR) LIC_PLATE_NBR, COALESCE(CAMERA_LIC_PLATE_STATE, LIC_PLATE_STATE) LIC_PLATE_STATE, 
		CONVERT(VARCHAR, VIOL_DATE, 112) YYYYMMDD, CONVERT(VARCHAR(2),VIOL_DATE, 114) AS HH, COUNT(DISTINCT VEHICLE_CLASS) VEHICLE_CLASS_CODE_CNT
		--SELECT TOP(100) *--SELECT COUNT(1)
FROM	LND_LG_ICRS.ICRS_OWNER.ICS_LANE_VIOLATIONS --41,843,490
WHERE	--SOURCE_CODE NOT IN ('I', 'B') AND
		VIOL_DATE >= @FROM_DATE
AND		TRANSACTION_FILE_DETAIL_ID IS NULL
AND		COALESCE(CAMERA_LIC_PLATE_NBR, LIC_PLATE_NBR) != '~'
--AND		VIOL_CREATED = 'Y'
GROUP BY COALESCE(CAMERA_LIC_PLATE_NBR, LIC_PLATE_NBR), COALESCE(CAMERA_LIC_PLATE_STATE, LIC_PLATE_STATE), CONVERT(VARCHAR, VIOL_DATE, 112), CONVERT(VARCHAR(2),VIOL_DATE, 114)
HAVING	COUNT(DISTINCT VEHICLE_CLASS) > 1;
--SELECT	* FROM	SandBox.dbo.MISSCLASS_ICRS_STAGE00 WHERE LIC_PLATE_NBR ='~'

--Step #2: Find all the transaction for the above with multiple Class
IF OBJECT_ID('SandBox.dbo.MISSCLASS_ICRS_STAGE01')>0 DROP TABLE SandBox.dbo.MISSCLASS_ICRS_STAGE01;
CREATE TABLE SandBox.dbo.MISSCLASS_ICRS_STAGE01 WITH (DISTRIBUTION = HASH(LIC_PLATE_NBR)) --[TTXN_ID]
AS --EXPLAIN
SELECT	LANE_VIOL_ID, COALESCE(LV.CAMERA_LIC_PLATE_NBR, LV.LIC_PLATE_NBR) LIC_PLATE_NBR ,COALESCE(LV.CAMERA_LIC_PLATE_STATE, LV.LIC_PLATE_STATE) LIC_PLATE_STATE,VIOL_DATE,
		CONVERT(VARCHAR, VIOL_DATE, 112) AS YYYYMMDD, 
		CONVERT(VARCHAR(2),VIOL_DATE, 114) AS HH, 
		TOLL_DUE,AGENCY_ID,LANE_ID,LV.VEHICLE_CLASS
		--SELECT TOP(100) *
FROM	LND_LG_ICRS.ICRS_OWNER.ICS_LANE_VIOLATIONS LV
JOIN	SandBox.dbo.MISSCLASS_ICRS_STAGE00 ON COALESCE(LV.CAMERA_LIC_PLATE_NBR, LV.LIC_PLATE_NBR) = MISSCLASS_ICRS_STAGE00.LIC_PLATE_NBR 
	AND COALESCE(LV.CAMERA_LIC_PLATE_STATE, LV.LIC_PLATE_STATE)  = MISSCLASS_ICRS_STAGE00.LIC_PLATE_STATE 
AND		CONVERT(VARCHAR, VIOL_DATE, 112) = YYYYMMDD AND	CONVERT(VARCHAR(2),VIOL_DATE, 114) = HH
AND	VIOL_DATE >= @FROM_DATE
AND		TRANSACTION_FILE_DETAIL_ID IS NULL

--SELECT	* FROM	SandBox.dbo.MISSCLASS_ICRS_STAGE01 WHERE LIC_PLATE_NBR ='~'

--Step #3: Find the MODE for the above LIC NBR with multiple Class
IF OBJECT_ID('SandBox.dbo.MISSCLASS_ICRS_STAGE02')>0 DROP TABLE SandBox.dbo.MISSCLASS_ICRS_STAGE02;
CREATE TABLE SandBox.dbo.MISSCLASS_ICRS_STAGE02 WITH (DISTRIBUTION = HASH(LIC_PLATE_NBR)) --[TTXN_ID]
AS --EXPLAIN
SELECT	DISTINCT MISSCLASS_ICRS_STAGE01.*, AVG_CLASS.VEHICLE_CLASS_CODE NORMAL_VEHICLE_CLASS_CODE--SELECT COUNT(1)--214,182
FROM	SandBox.dbo.MISSCLASS_ICRS_STAGE01 
JOIN	(SELECT  LIC_PLATE_NBR, LIC_PLATE_STATE, YYYYMMDD, HH, VEHICLE_CLASS_CODE
		 FROM	(SELECT LIC_PLATE_NBR, LIC_PLATE_STATE, YYYYMMDD, HH, CAST(VEHICLE_CLASS AS INT) VEHICLE_CLASS_CODE--, cnt   = COUNT(1)
				 ,rid   = ROW_NUMBER() OVER (PARTITION BY LIC_PLATE_NBR, LIC_PLATE_STATE, YYYYMMDD, HH ORDER BY COUNT(1) DESC)--SELECT *
				FROM SandBox.dbo.MISSCLASS_ICRS_STAGE01 	--WHERE ACCT_ID = 134124 AND TAG_ID = 10647927 AND YYYYMMDD = 20170901 AND HH = 01
				GROUP BY LIC_PLATE_NBR, LIC_PLATE_STATE, YYYYMMDD, HH, VEHICLE_CLASS ) A WHERE rid = 1)  AVG_CLASS
	ON MISSCLASS_ICRS_STAGE01.LIC_PLATE_NBR = AVG_CLASS.LIC_PLATE_NBR 
	AND MISSCLASS_ICRS_STAGE01.LIC_PLATE_STATE = AVG_CLASS.LIC_PLATE_STATE 
	AND MISSCLASS_ICRS_STAGE01.YYYYMMDD = AVG_CLASS.YYYYMMDD 
	AND MISSCLASS_ICRS_STAGE01.VEHICLE_CLASS != AVG_CLASS.VEHICLE_CLASS_CODE
	--WHERE MISSCLASS_ICRS_STAGE01.ACCT_ID = 134124 AND MISSCLASS_ICRS_STAGE01.TAG_ID = 10647927 AND MISSCLASS_ICRS_STAGE01.YYYYMMDD = 20170901 AND MISSCLASS_ICRS_STAGE01.HH = 01

--SELECT	TOP(100) * FROM	SandBox.dbo.MISSCLASS_ICRS_STAGE02 

----Step #4: Group by Lane
--IF OBJECT_ID('SandBox.dbo.MISSCLASS_ICRS_STAGE03')>0 DROP TABLE SandBox.dbo.MISSCLASS_ICRS_STAGE03;
--CREATE TABLE SandBox.dbo.MISSCLASS_ICRS_STAGE03 WITH (DISTRIBUTION = HASH(LANE_ID)) --[LANE_ID]
--AS --EXPLAIN
--SELECT MISSCLASS_ICRS_STAGE02.YYYYMMDD, MISSCLASS_ICRS_STAGE02.LANE_ID, MISSCLASS_ICRS_STAGE02.VEHICLE_CLASS, NORMAL_VEHICLE_CLASS_CODE, COUNT(1) CNT
--FROM SandBox.dbo.MISSCLASS_ICRS_STAGE02 
--GROUP BY MISSCLASS_ICRS_STAGE02.YYYYMMDD, MISSCLASS_ICRS_STAGE02.LANE_ID, VEHICLE_CLASS, MISSCLASS_ICRS_STAGE02.NORMAL_VEHICLE_CLASS_CODE--ORDER BY 5 DESC

----SELECT	TOP(100) * FROM	SandBox.dbo.MISSCLASS_ICRS_STAGE03 

----Step #5: Group by Tags
--IF OBJECT_ID('SandBox.dbo.MISSCLASS_ICRS_STAGE04')>0 DROP TABLE SandBox.dbo.MISSCLASS_ICRS_STAGE03;
--CREATE TABLE SandBox.dbo.MISSCLASS_ICRS_STAGE04 WITH (DISTRIBUTION = HASH(TAG_ID)) --[LANE_ID]
--AS --EXPLAIN
--SELECT LIC_PLATE_NBR, LIC_PLATE_STATE, --VEHICLE_CLASS, 
--		COUNT(1) CNT
--FROM SandBox.dbo.MISSCLASS_ICRS_STAGE02 
----WHERE [ACCT_TAG_STATUS] = 'A'
--GROUP BY LIC_PLATE_NBR, LIC_PLATE_STATE--, VEHICLE_CLASS
--ORDER BY 3 DESC

--SELECT	TOP(100) MISSCLASS_ICRS_STAGE03.*,-- FIRST_NAME,LAST_NAME,COMPANY_NAME, 
--LANE_ABBREV,LANE_NAME,LANE_DIRECTION,PLAZA_ABBREV--, LIC_PLATE,LIC_STATE,LIC_PLATE_TAG,VEHICLE_DESCR
--FROM	SandBox.dbo.MISSCLASS_ICRS_STAGE03
--JOIN EDW_RITE.dbo.DIM_LANE ON DIM_LANE.LANE_ID = MISSCLASS_ICRS_STAGE03.LANE_ID




