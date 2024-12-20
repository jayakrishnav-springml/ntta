CREATE PROC [DBO].[VIOL_INV_STATUS_LOAD] AS 

IF OBJECT_ID('dbo.VIOL_INV_STATUS_NEW')>0
	DROP TABLE dbo.VIOL_INV_STATUS_NEW

CREATE TABLE dbo.VIOL_INV_STATUS_NEW WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (VIOL_INV_STATUS)) 
AS 
-- EXPLAIN
SELECT  VIOL_INV_STATUS, VIOL_INV_STATUS_DESCR, GETDATE() AS INSERT_DATE
FROM EDW_RITE.dbo.VIOL_INV_STATUS A
OPTION (LABEL = 'VIOL_INV_STATUS_LOAD: VIOL_INV_STATUS');

IF OBJECT_ID('dbo.VIOL_INV_STATUS')>0
	RENAME OBJECT::dbo.VIOL_INV_STATUS TO VIOL_INV_STATUS_OLD;

RENAME OBJECT::dbo.VIOL_INV_STATUS_NEW TO VIOL_INV_STATUS;

IF OBJECT_ID('dbo.VIOL_INV_STATUS_OLD')>0
	DROP TABLE dbo.VIOL_INV_STATUS_OLD

CREATE STATISTICS STATS_VIOL_INV_STATUS_001 ON DBO.VIOL_INV_STATUS (VIOL_INV_STATUS)
