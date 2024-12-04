CREATE PROC [DBO].[Service_Monthly_Table_Count_Load] AS
/*
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.Service_Monthly_Table_Count_Load') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.Service_Monthly_Table_Count_Load
GO

EXEC DBO.Service_Monthly_Table_Count_Load

SELECT * FROM dbo.Service_Monthly_Table_Count

*/

DECLARE @START_DATE DATE = DATEADD(DAY,1,EOMONTH(GETDATE(),-2)) -- Beginning of prev. Month

DECLARE @START_DAY_ID INT = CAST(CONVERT(VARCHAR(8), @START_DATE,112) AS INT)--= 20150701
DECLARE @END_DAY_ID INT = CAST(CONVERT(VARCHAR(8), EOMONTH(GETDATE(),-1),112) AS INT) --= 20150731

IF OBJECT_ID('dbo.Service_Monthly_Table_Count') IS NOT NULL DROP TABLE dbo.Service_Monthly_Table_Count;

CREATE TABLE dbo.Service_Monthly_Table_Count WITH (HEAP, DISTRIBUTION = ROUND_ROBIN) AS 
SELECT 'FACT_VIOLATION_VB_VIOL_INVOICES' AS TABLE_NAME, COUNT_BIG(1) AS Row_Count, GETDATE() AS Last_Update_Date
FROM dbo.FACT_VIOLATION_VB_VIOL_INVOICES
WHERE DAY_ID BETWEEN @START_DAY_ID AND @END_DAY_ID
UNION ALL
SELECT 'FACT_VIOLATIONS_DETAIL' AS TABLE_NAME, COUNT_BIG(1) AS Row_Count, GETDATE() AS Last_Update_Date
FROM dbo.FACT_VIOLATIONS_DETAIL
WHERE DAY_ID BETWEEN @START_DAY_ID AND @END_DAY_ID
UNION ALL
SELECT 'FACT_LANE_VIOLATIONS_DETAIL' AS TABLE_NAME, COUNT_BIG(1) AS Row_Count, GETDATE() AS Last_Update_Date
FROM dbo.FACT_LANE_VIOLATIONS_DETAIL
WHERE DAY_ID BETWEEN @START_DAY_ID AND @END_DAY_ID
UNION ALL
SELECT 'FACT_NET_REV_TFC_EVTS' AS TABLE_NAME, COUNT_BIG(1) AS Row_Count, GETDATE() AS Last_Update_Date
FROM dbo.FACT_NET_REV_TFC_EVTS
WHERE DAY_ID BETWEEN @START_DAY_ID AND @END_DAY_ID
UNION ALL
SELECT 'FACT_IOP_TGS' AS TABLE_NAME, COUNT_BIG(1) AS Row_Count, GETDATE() AS Last_Update_Date
FROM dbo.FACT_IOP_TGS
WHERE DAY_ID BETWEEN @START_DAY_ID AND @END_DAY_ID
UNION ALL
SELECT 'FACT_TOLL_TRANSACTIONS' AS TABLE_NAME, COUNT_BIG(1) AS Row_Count, GETDATE() AS Last_Update_Date
FROM dbo.FACT_TOLL_TRANSACTIONS
WHERE DAY_ID BETWEEN @START_DAY_ID AND @END_DAY_ID
UNION ALL
SELECT 'FACT_VTOLLS_DETAIL' AS TABLE_NAME, COUNT_BIG(1) AS Row_Count, GETDATE() AS Last_Update_Date
FROM dbo.FACT_VTOLLS_DETAIL
WHERE DAY_ID BETWEEN @START_DAY_ID AND @END_DAY_ID
UNION ALL
SELECT 'FACT_VIOLATIONS_DMV_STATUS_DETAIL' AS TABLE_NAME, COUNT_BIG(1) AS Row_Count, GETDATE() AS Last_Update_Date
FROM dbo.FACT_VIOLATIONS_DMV_STATUS_DETAIL
WHERE DAY_ID BETWEEN @START_DAY_ID AND @END_DAY_ID
UNION ALL
SELECT 'FACT_VIOLATIONS_BR_DETAIL' AS TABLE_NAME, COUNT_BIG(1) AS Row_Count, GETDATE() AS Last_Update_Date
FROM dbo.FACT_VIOLATIONS_BR_DETAIL
WHERE DAY_ID BETWEEN @START_DAY_ID AND @END_DAY_ID


