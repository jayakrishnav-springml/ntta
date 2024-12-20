CREATE PROC [DBO].[PMT_TXN_TYPES_LOAD] AS 

IF OBJECT_ID('dbo.PMT_TXN_TYPES_NEW')>0
	DROP TABLE dbo.PMT_TXN_TYPES_NEW

CREATE TABLE dbo.PMT_TXN_TYPES_NEW WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (PMT_TXN_TYPE)) 
AS 
-- EXPLAIN
SELECT  PMT_TXN_TYPE, PMT_TXN_TYPE_DESCR, GETDATE() AS INSERT_DATE
FROM EDW_RITE.dbo.PMT_TXN_TYPES A
OPTION (LABEL = 'PMT_TXN_TYPES_LOAD: PMT_TXN_TYPES');

IF OBJECT_ID('dbo.PMT_TXN_TYPES')>0
	RENAME OBJECT::dbo.PMT_TXN_TYPES TO PMT_TXN_TYPES_OLD;

RENAME OBJECT::dbo.PMT_TXN_TYPES_NEW TO PMT_TXN_TYPES;

IF OBJECT_ID('dbo.PMT_TXN_TYPES_OLD')>0
	DROP TABLE dbo.PMT_TXN_TYPES_OLD

CREATE STATISTICS STATS_PMT_TXN_TYPES_001 ON DBO.PMT_TXN_TYPES (PMT_TXN_TYPE)
