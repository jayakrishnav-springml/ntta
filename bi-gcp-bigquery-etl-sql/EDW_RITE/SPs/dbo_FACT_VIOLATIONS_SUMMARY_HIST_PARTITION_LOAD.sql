CREATE PROC [dbo].[FACT_VIOLATIONS_SUMMARY_HIST_PARTITION_LOAD] AS 

DECLARE @PARTITION_DATE DATE = (SELECT CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0) AS DATE))
PRINT   @PARTITION_DATE

--Step#1: Create a stage table
IF OBJECT_ID('dbo.FACT_VIOLATIONS_SUMMARY_HIST_STAGE')>0 DROP TABLE dbo.FACT_VIOLATIONS_SUMMARY_HIST_STAGE

CREATE TABLE [dbo].FACT_VIOLATIONS_SUMMARY_HIST_STAGE WITH (DISTRIBUTION = HASH(DAY_ID)) AS
-- EXPLAIN--SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME IN ('FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_HIST_STAGE','FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_HIST') ORDER BY ORDINAL_POSITION, COLUMN_NAME, TABLE_NAME
SELECT @PARTITION_DATE PARTITION_DATE, * -- SELECT TOP 100 *--SELECT Partition_date,COUNT(1) from FACT_VIOLATIONS_SUMMARY_HIST group by Partition_date
FROM FACT_VIOLATIONS_SUMMARY -- 39,751,257
OPTION (LABEL = 'FACT_BOM_TXN_HIST_LOAD: FACT_VIOLATIONS_SUMMARY_HIST_STAGE');

       
IF NOT EXISTS (SELECT 1 FROM FACT_VIOLATIONS_SUMMARY_HIST WHERE PARTITION_DATE = @PARTITION_DATE)
BEGIN
--Partition Info
EXEC dbo.PARTITION_AS_OF_DATE_TABLE_UPDATE 'FACT_VIOLATIONS_SUMMARY_HIST', @PARTITION_DATE
--Switch Partition 
EXEC [dbo].[PARTITION_SWITCH] @DEST_TABLE_NAME='FACT_VIOLATIONS_SUMMARY_HIST',@SRC_TABLE_NAME='FACT_VIOLATIONS_SUMMARY_HIST_STAGE',@AS_OF_DATE = @PARTITION_DATE
END
ELSE
PRINT CAST(@PARTITION_DATE AS VARCHAR) + ' Partition exists.'





--UPDATE STATISTICS 
UPDATE STATISTICS dbo.FACT_VIOLATIONS_SUMMARY_HIST

