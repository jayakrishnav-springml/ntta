CREATE PROC [DBO].[DIM_PLAZA_LOAD] AS 

IF OBJECT_ID('dbo.DIM_PLAZA_NEW')>0
	DROP TABLE dbo.DIM_PLAZA_NEW

CREATE TABLE dbo.DIM_PLAZA_NEW WITH (DISTRIBUTION = REPLICATE, CLUSTERED COLUMNSTORE INDEX) 
AS 
-- EXPLAIN
SELECT     
	 PLAZA_ID
	,PLAZA_ABBREV
	,PLAZA_NAME
	,PLAZA_LATITUDE
	,PLAZA_LONGITUDE
	,FACILITY_ID
	,FACILITY_ABBREV
	,FACILITY_NAME
	,AGENCY_ID
    ,AGENCY_ABBREV
    ,AGENCY_NAME
    ,AGENCY_IS_IOP
    ,GETDATE() AS INSERT_DATE
FROM EDW_RITE.dbo.DIM_PLAZA A
OPTION (LABEL = 'PLAZA_LOAD: DIM_PLAZA');

IF OBJECT_ID('dbo.DIM_PLAZA')>0
	RENAME OBJECT::dbo.DIM_PLAZA TO DIM_PLAZA_OLD;

RENAME OBJECT::dbo.DIM_PLAZA_NEW TO DIM_PLAZA;

IF OBJECT_ID('dbo.DIM_PLAZA_OLD')>0
	DROP TABLE dbo.DIM_PLAZA_OLD

CREATE STATISTICS STATS_DIM_PLAZA_001 ON DBO.DIM_PLAZA (PLAZA_ID)


