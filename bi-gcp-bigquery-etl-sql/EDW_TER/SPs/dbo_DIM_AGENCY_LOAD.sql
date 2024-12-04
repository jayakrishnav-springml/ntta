CREATE PROC [DBO].[DIM_AGENCY_LOAD] AS 

IF OBJECT_ID('dbo.DIM_AGENCY_NEW')>0
	DROP TABLE dbo.DIM_AGENCY_NEW

CREATE TABLE dbo.DIM_AGENCY_NEW WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (AGENCY_ID)) 
AS 
-- EXPLAIN
SELECT     
	 AGENCY_ID
    ,AGENCY_ABBREV
    ,AGENCY_NAME
    ,AGENCY_IS_IOP
    ,GETDATE() AS INSERT_DATE
FROM EDW_RITE.dbo.DIM_AGENCY A
OPTION (LABEL = 'DIM_AGENCY_LOAD: DIM_AGENCY');

IF OBJECT_ID('dbo.DIM_AGENCY')>0
	RENAME OBJECT::dbo.DIM_AGENCY TO DIM_AGENCY_OLD;

RENAME OBJECT::dbo.DIM_AGENCY_NEW TO DIM_AGENCY;

IF OBJECT_ID('dbo.DIM_AGENCY_OLD')>0
	DROP TABLE dbo.DIM_AGENCY_OLD

CREATE STATISTICS STATS_DIM_AGENCY_001 ON DBO.DIM_AGENCY (AGENCY_ID)


