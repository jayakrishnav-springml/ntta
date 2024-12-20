CREATE PROC [dbo].[VEHICLE_CLASSES_LOAD] AS

IF OBJECT_ID('dbo.VEHICLE_CLASSES_STAGE')<>0
	DROP TABLE dbo.VEHICLE_CLASSES_STAGE

CREATE TABLE dbo.VEHICLE_CLASSES_STAGE WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (VEHICLE_CLASS_CODE)) 
AS 
SELECT VEHICLE_CLASS_CODE,[VEHICLE_CLASS_DESCR], LAST_UPDATE_DATE
FROM [LND_LG_TS].[TAG_OWNER].[VEHICLE_CLASSES]
OPTION (LABEL = 'VEHICLE_CLASSES_LOAD: CTAS VEHICLE_CLASSES_STAGE');

UPDATE dbo.VEHICLE_CLASSES
SET VEHICLE_CLASS_DESCR = B.VEHICLE_CLASS_DESCR
	,LAST_UPDATE_DATE = B.LAST_UPDATE_DATE
FROM dbo.VEHICLE_CLASSES_STAGE B
WHERE 
	dbo.VEHICLE_CLASSES.VEHICLE_CLASS_CODE = B.VEHICLE_CLASS_CODE
	AND 
	dbo.VEHICLE_CLASSES.VEHICLE_CLASS_DESCR <> B.VEHICLE_CLASS_DESCR
OPTION (LABEL = 'VEHICLE_CLASSES_LOAD: UPDATE VEHICLE_CLASSES');

INSERT INTO dbo.VEHICLE_CLASSES (VEHICLE_CLASS_CODE, VEHICLE_CLASS_DESCR, INSERT_DATE, LAST_UPDATE_DATE)
SELECT A.VEHICLE_CLASS_CODE, A.VEHICLE_CLASS_DESCR, A.LAST_UPDATE_DATE, A.LAST_UPDATE_DATE
FROM dbo.VEHICLE_CLASSES_STAGE A
LEFT JOIN dbo.VEHICLE_CLASSES B ON A.VEHICLE_CLASS_CODE = B.VEHICLE_CLASS_CODE
WHERE B.VEHICLE_CLASS_CODE IS NULL
OPTION (LABEL = 'VEHICLE_CLASSES_LOAD: INSERT VEHICLE_CLASSES');



