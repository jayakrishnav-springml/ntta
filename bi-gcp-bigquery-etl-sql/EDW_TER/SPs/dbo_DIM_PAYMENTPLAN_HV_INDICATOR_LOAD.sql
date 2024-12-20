CREATE PROC [DBO].[DIM_PAYMENTPLAN_HV_INDICATOR_LOAD] AS 

IF OBJECT_ID('dbo.DIM_PAYMENTPLAN_HV_INDICATOR_NEW')>0
	DROP TABLE dbo.DIM_PAYMENTPLAN_HV_INDICATOR_NEW

CREATE TABLE dbo.DIM_PAYMENTPLAN_HV_INDICATOR_NEW WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (INDICATOR_ID)) 
AS 
-- EXPLAIN
SELECT 0 AS INDICATOR_ID,'Payment Plan Invoice' AS	PP_HV_FLAG
UNION
SELECT 1 AS INDICATOR_ID,'HV Invoice' AS	PP_HV_FLAG

OPTION (LABEL = 'DIM_PAYMENTPLAN_HV_INDICATOR_LOAD: DIM_PAYMENTPLAN_HV_INDICATOR');

IF OBJECT_ID('dbo.DIM_PAYMENTPLAN_HV_INDICATOR')>0
	RENAME OBJECT::dbo.DIM_PAYMENTPLAN_HV_INDICATOR TO DIM_PAYMENTPLAN_HV_INDICATOR_OLD;

RENAME OBJECT::dbo.DIM_PAYMENTPLAN_HV_INDICATOR_NEW TO DIM_PAYMENTPLAN_HV_INDICATOR;

IF OBJECT_ID('dbo.DIM_PAYMENTPLAN_HV_INDICATOR_OLD')>0
	DROP TABLE dbo.DIM_PAYMENTPLAN_HV_INDICATOR_OLD

CREATE STATISTICS STATS_DIM_PAYMENTPLAN_HV_INDICATOR_001 ON DBO.DIM_PAYMENTPLAN_HV_INDICATOR (INDICATOR_ID)

