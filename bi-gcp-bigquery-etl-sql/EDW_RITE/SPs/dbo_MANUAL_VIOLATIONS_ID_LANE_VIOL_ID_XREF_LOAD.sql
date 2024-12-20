CREATE PROC [DBO].[MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF_LOAD] AS

/*
USE EDW_TER
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF_LOAD
GO

EXEC DBO.MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF_LOAD

SELECT COUNT_BIG(1) FROM dbo.MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF  -- 45909
*/


IF  OBJECT_ID('dbo.MANUAL_VIOLATIONS_WITH_FILE') IS NOT NULL DROP TABLE dbo.MANUAL_VIOLATIONS_WITH_FILE;	

CREATE TABLE dbo.MANUAL_VIOLATIONS_WITH_FILE WITH (HEAP, DISTRIBUTION = HASH(VIOLATION_ID)) AS --EXPLAIN
SELECT V.VIOLATION_ID, V.VIOL_DATE, V.TRANSACTION_FILE_DETAIL_ID
FROM LND_LG_VPS.VP_OWNER.VIOLATIONS V --dbo.VIOLATIONS V
WHERE LANE_VIOL_ID IS NULL AND TRANSACTION_FILE_DETAIL_ID IS NOT NULL


IF OBJECT_ID('dbo.MANUAL_VIOLATIONS') IS NOT NULL DROP TABLE dbo.MANUAL_VIOLATIONS;	

CREATE TABLE dbo.MANUAL_VIOLATIONS WITH (HEAP, DISTRIBUTION = HASH(VIOLATION_ID)) AS --EXPLAIN
SELECT LIC_PLATE_STATE, LIC_PLATE_NBR, V.VIOLATION_ID, V.LANE_ID, V.VIOL_DATE, V.VEHICLE_CLASS,V.TOLL_DUE
FROM LND_LG_VPS.VP_OWNER.VIOLATIONS V --dbo.VIOLATIONS V
--JOIN dbo.DIM_LICENSE_PLATE L ON L.LICENSE_PLATE_ID = V.LICENSE_PLATE_ID
WHERE LANE_VIOL_ID IS NULL AND TRANSACTION_FILE_DETAIL_ID IS NULL


IF OBJECT_ID('dbo.MANUAL_VIOLATIONS_WITH_TRANSACTION_ID') IS NOT NULL DROP TABLE dbo.MANUAL_VIOLATIONS_WITH_TRANSACTION_ID;	

CREATE TABLE dbo.MANUAL_VIOLATIONS_WITH_TRANSACTION_ID WITH (HEAP, DISTRIBUTION = HASH(VIOLATION_ID)) AS --EXPLAIN
SELECT I.POSTED_REVENUE,I.TRANSACTION_DATE,I.TRANSACTION_ID,
	M.VIOL_DATE, M.TOLL_DUE, M.VIOLATION_ID,
	ROW_NUMBER() OVER (PARTITION BY VIOLATION_ID ORDER BY TRANSACTION_ID) AS RN
FROM LND_LG_HOST.TXNOWNER.IOP_TRANSACTIONS  I
JOIN dbo.MANUAL_VIOLATIONS M ON I.LIC_PLATE_NBR = M.LIC_PLATE_NBR AND I.LIC_PLATE_STATE = M.LIC_PLATE_STATE AND I.LANE_ID = M.LANE_ID
	AND CAST(I.TRANSACTION_DATE AS DATE) = CAST(M.VIOL_DATE AS DATE) 
	AND DATEPART(HOUR,I.TRANSACTION_DATE) = DATEPART(HOUR,M.VIOL_DATE)
	AND DATEPART(MINUTE,I.TRANSACTION_DATE) = DATEPART(MINUTE,M.VIOL_DATE)
	AND I.POSTED_CLASS = M.VEHICLE_CLASS

IF OBJECT_ID('dbo.MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF_STAGE') IS NOT NULL DROP TABLE dbo.MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF_STAGE;	

--EXPLAIN
CREATE TABLE dbo.MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF_STAGE WITH (CLUSTERED INDEX (VIOLATION_ID), DISTRIBUTION = HASH(VIOLATION_ID)) AS 
SELECT LANE_VIOL_ID, VIOLATION_ID
FROM (
SELECT L.LANE_VIOL_ID, CONVERT(BIGINT,M.VIOLATION_ID) AS VIOLATION_ID
FROM dbo.MANUAL_VIOLATIONS_WITH_FILE M
JOIN dbo.FACT_LANE_VIOLATIONS_DETAIL L ON M.TRANSACTION_FILE_DETAIL_ID = L.TRANSACTION_FILE_DETAIL_ID

UNION ALL

SELECT V.LANE_VIOL_ID, CONVERT(BIGINT,M.VIOLATION_ID) AS VIOLATION_ID  --IVX.TRANSACTION_ID, L.VIOLATION_ID,L.VEHICLE_CLASS,L.LANE_ID,L.LIC_PLATE_NBR,L.LIC_PLATE_STATE
FROM dbo.MANUAL_VIOLATIONS_WITH_TRANSACTION_ID M
JOIN dbo.FACT_VTOLLS_DETAIL V ON V.TRANSACTION_ID = M.TRANSACTION_ID 
--JOIN dbo.ICRS_VPS_XREF IVX ON IVX.TRANSACTION_ID = M.TRANSACTION_ID
--JOIN dbo.FACT_LANE_VIOLATIONS_DETAIL L ON IVX.LANE_VIOL_ID = L.LANE_VIOL_ID
) A
GROUP BY LANE_VIOL_ID, VIOLATION_ID

IF OBJECT_ID('dbo.MANUAL_VIOLATIONS_WITH_FILE') IS NOT NULL DROP TABLE dbo.MANUAL_VIOLATIONS_WITH_FILE;	
IF OBJECT_ID('dbo.MANUAL_VIOLATIONS') IS NOT NULL DROP TABLE dbo.MANUAL_VIOLATIONS;	
IF OBJECT_ID('dbo.MANUAL_VIOLATIONS_WITH_TRANSACTION_ID') IS NOT NULL DROP TABLE dbo.MANUAL_VIOLATIONS_WITH_TRANSACTION_ID;	


IF OBJECT_ID('dbo.MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF_OLD')  IS NOT NULL DROP TABLE dbo.MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF_OLD;
IF OBJECT_ID('dbo.MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF')  IS NOT NULL RENAME OBJECT::dbo.MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF TO MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF_OLD;
RENAME OBJECT::dbo.MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF_STAGE TO MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF;
IF OBJECT_ID('dbo.MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF_OLD')  IS NOT NULL DROP TABLE dbo.MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF_OLD;



--ORDER BY LICENSE_PLATE_STATE, LICENSE_PLATE_NBR DESC 

--SELECT VIOLATION_ID FROM SANDBOX.dbo.MANUAL_VIOLATIONS_WITH_TRANSACTION_ID WHERE RN > 1
--SELECT COUNT(1) FROM SANDBOX.dbo.MANUAL_VIOLATIONS_WITH_TRANSACTION_ID  -- 16223

--SELECT M.*, IVX.LANE_VIOL_ID, L.*  --IVX.TRANSACTION_ID, L.VIOLATION_ID,L.VEHICLE_CLASS,L.LANE_ID,L.LIC_PLATE_NBR,L.LIC_PLATE_STATE
--FROM SANDBOX.dbo.MANUAL_VIOLATIONS_WITH_TRANSACTION_ID M
--JOIN dbo.ICRS_VPS_XREF IVX ON IVX.TRANSACTION_ID = M.TRANSACTION_ID
--JOIN dbo.FACT_LANE_VIOLATIONS_DETAIL L ON IVX.LANE_VIOL_ID = L.LANE_VIOL_ID
--WHERE M.VIOLATION_ID IN (SELECT VIOLATION_ID FROM SANDBOX.dbo.MANUAL_VIOLATIONS_WITH_TRANSACTION_ID WHERE RN > 1)
--ORDER BY M.VIOLATION_ID, M.RN


--LICENSE_PLATE_STATE	LICENSE_PLATE_NBR	LANE_ID	VIOL_DATE	TOLL_DUE	VIOLATOR_ID	VEHICLE_CLASS	VIOLATION_ID
--TX					Y58753				20344	2018-09-24	12.72		-17974		5				1470117974
--TX					Y58753				20445	2018-09-24	2.92		-19874		5				1470119874

--LIC_PLATE_STATE	LIC_PLATE_NBR	LANE_ID	POSTED_CLASS	POSTED_REVENUE	TRANSACTION_DATE	TRANSACTION_ID
--TX				Y58753			20445	5				1.92			2018-09-24 16:27:35	2126725600
--TX				Y58753			20344	5				8.48			2018-09-24 15:50:52	2126691844

--SELECT TOP 10 * FROM LND_LG_HOST.TXNOWNER.IOP_TRANSACTIONS WHERE LIC_PLATE_NBR = 'GJY755' AND LIC_PLATE_STATE = 'TX' AND LANE_ID = 1024

--SELECT TOP 1000 LIC_PLATE_STATE, LIC_PLATE_NBR,ENTRY_LANE_ID,EXIT_LANE_ID,IOP_TXN_ID,POSTED_REVENUE,POSTED_CLASS,SOURCE_TXN_ID,ENTRY_TXN_DATE,EXIT_TXN_DATE 
--FROM LND_LG_IOP.IOP_OWNER.IOP_TXNS  I
--WHERE EXISTS (SELECT 1 FROM SANDBOX.dbo.MANUAL_VIOLATIONS M WHERE LICENSE_PLATE_STATE = 'TX' AND I.LIC_PLATE_NBR = M.LICENSE_PLATE_NBR AND I.LIC_PLATE_STATE = M.LICENSE_PLATE_STATE)
--ORDER BY LIC_PLATE_STATE, LIC_PLATE_NBR  DESC







--SELECT TOP 100 * FROM dbo.FACT_CA_PAYMENTS WHERE CA_PMT_RANK < 1
