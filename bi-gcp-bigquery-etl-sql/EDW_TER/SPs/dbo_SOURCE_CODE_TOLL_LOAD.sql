CREATE PROC [DBO].[SOURCE_CODE_TOLL_LOAD] AS 

IF OBJECT_ID('dbo.SOURCE_CODE_TOLL_NEW') IS NOT NULL 	DROP TABLE dbo.SOURCE_CODE_TOLL_NEW

CREATE TABLE dbo.SOURCE_CODE_TOLL_NEW WITH (HEAP, DISTRIBUTION = REPLICATE) 
AS 
-- EXPLAIN
SELECT  SOURCE_CODE, SC_DESCR, SOURCE_CODE_GROUP, GETDATE() AS INSERT_DATE
FROM EDW_RITE.dbo.SOURCE_CODE_TOLL A
OPTION (LABEL = 'SOURCE_CODE_TOLL_LOAD: SOURCE_CODE_TOLL');

--INSERT INTO dbo.SOURCE_CODE_TOLL_NEW 
--		(SOURCE_CODE, SC_DESCR, SOURCE_CODE_GROUP, INSERT_DATE)
--VALUES	('-1','NULL','NULL','1900-01-01')

CREATE STATISTICS STATS_SOURCE_CODE_TOLL_001 ON DBO.SOURCE_CODE_TOLL_NEW (SOURCE_CODE)

IF OBJECT_ID('dbo.SOURCE_CODE_TOLL') IS NOT NULL	RENAME OBJECT::dbo.SOURCE_CODE_TOLL TO SOURCE_CODE_TOLL_OLD;
RENAME OBJECT::dbo.SOURCE_CODE_TOLL_NEW TO SOURCE_CODE_TOLL;
IF OBJECT_ID('dbo.SOURCE_CODE_TOLL_OLD') IS NOT NULL DROP TABLE dbo.SOURCE_CODE_TOLL_OLD

--INSERT INTO dbo.SOURCE_CODE_TOLL 
--		(SOURCE_CODE, SC_DESCR, SOURCE_CODE_GROUP, INSERT_DATE)
--VALUES	('-1','NULL','NULL','1900-01-01')

