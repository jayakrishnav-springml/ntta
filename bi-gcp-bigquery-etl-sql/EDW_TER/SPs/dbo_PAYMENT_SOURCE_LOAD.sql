CREATE PROC [DBO].[PAYMENT_SOURCE_LOAD] AS 

IF OBJECT_ID('dbo.PAYMENT_SOURCE_NEW')>0
	DROP TABLE dbo.PAYMENT_SOURCE_NEW

CREATE TABLE dbo.PAYMENT_SOURCE_NEW WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (PAYMENT_SOURCE_CODE)) 
AS 
-- EXPLAIN
SELECT  PAYMENT_SOURCE_CODE, PAYMENT_SOURCE_CODE_DESCR, GETDATE() AS INSERT_DATE
FROM EDW_RITE.dbo.PAYMENT_SOURCE A
OPTION (LABEL = 'PAYMENT_SOURCE_LOAD: PAYMENT_SOURCE');

IF OBJECT_ID('dbo.PAYMENT_SOURCE')>0
	RENAME OBJECT::dbo.PAYMENT_SOURCE TO PAYMENT_SOURCE_OLD;

RENAME OBJECT::dbo.PAYMENT_SOURCE_NEW TO PAYMENT_SOURCE;

IF OBJECT_ID('dbo.PAYMENT_SOURCE_OLD')>0
	DROP TABLE dbo.PAYMENT_SOURCE_OLD

CREATE STATISTICS STATS_PAYMENT_SOURCE_001 ON DBO.PAYMENT_SOURCE (PAYMENT_SOURCE_CODE)
