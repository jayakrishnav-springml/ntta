CREATE PROC [DBO].[FACT_TRANSACTION_SUMMARY_LOAD] AS 
 
 /*
 
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id(N'DBO.FACT_TRANSACTION_SUMMARY_LOAD') 
                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )
DROP PROCEDURE DBO.FACT_TRANSACTION_SUMMARY_LOAD
GO
 
 
 */



IF OBJECT_ID('dbo.ACCOUNT_TAG_MAX_ACCT_TAG_SEQ_NEW')>0
       DROP TABLE dbo.ACCOUNT_TAG_MAX_ACCT_TAG_SEQ_NEW

CREATE TABLE dbo.ACCOUNT_TAG_MAX_ACCT_TAG_SEQ_NEW WITH (DISTRIBUTION = HASH(ACCT_ID), CLUSTERED INDEX (ACCT_ID, TAG_ID)) 
AS 

SELECT A.ACCT_ID, A.TAG_ID, C.ZIP_CODE, E.ZIPCODE_LATITUDE, E.ZIPCODE_LONGITUDE, E.COUNTY, E.COUNTY_GROUP, C.ACCT_TYPE_CODE, D.ACCT_STATUS_DESCR, F.ACCT_TAG_STATUS_DESCR
FROM dbo.ACCOUNT_TAGS A
INNER JOIN 
(
       SELECT ACCT_ID, MAX(ACCT_TAG_SEQ) AS ACCT_TAG_SEQ, TAG_ID
       FROM dbo.ACCOUNT_TAGS
       GROUP BY ACCT_ID, TAG_ID
) B ON A.ACCT_ID = B.ACCT_ID AND A.ACCT_TAG_SEQ = B.ACCT_TAG_SEQ AND A.TAG_ID = B.TAG_ID
INNER JOIN dbo.ACCOUNTS C ON A.ACCT_ID = C.ACCT_ID
LEFT JOIN dbo.ACCOUNT_STATUSES D ON C.ACCT_STATUS_CODE = D.ACCT_STATUS_CODE
LEFT JOIN dbo.DIM_ZIPCODE E ON C.ZIP_CODE = E.ZIPCODE
LEFT JOIN LND_LG_TS.[TAG_OWNER].[ACCT_TAG_STATUSES] F ON A.ACCT_TAG_STATUS = F.ACCT_TAG_STATUS

	IF OBJECT_ID('dbo.ACCOUNT_TAG_MAX_ACCT_TAG_SEQ')>0
		RENAME OBJECT::dbo.ACCOUNT_TAG_MAX_ACCT_TAG_SEQ TO ACCOUNT_TAG_MAX_ACCT_TAG_SEQ_OLD;

	RENAME OBJECT::dbo.ACCOUNT_TAG_MAX_ACCT_TAG_SEQ_NEW TO ACCOUNT_TAG_MAX_ACCT_TAG_SEQ;

	IF OBJECT_ID('dbo.ACCOUNT_TAG_MAX_ACCT_TAG_SEQ_OLD')>0
		DROP TABLE dbo.ACCOUNT_TAG_MAX_ACCT_TAG_SEQ_OLD


exec DropStats 'dbo','ACCOUNT_TAG_MAX_ACCT_TAG_SEQ' 
-- exec CreateStats 'ACCOUNT_TAG_MAX_ACCT_TAG_SEQ'

CREATE STATISTICS STATS_ACCOUNT_TAG_MAX_ACCT_TAG_SEQ_00001 ON [dbo].ACCOUNT_TAG_MAX_ACCT_TAG_SEQ (ACCT_ID, TAG_ID)
CREATE STATISTICS STATS_ACCOUNT_TAG_MAX_ACCT_TAG_SEQ_00002 ON [dbo].ACCOUNT_TAG_MAX_ACCT_TAG_SEQ (ACCT_ID, TAG_ID, ACCT_TYPE_CODE)
 

 IF OBJECT_ID('dbo.FACT_TRANSACTION_SUMMARY_NEW')<>0
	DROP TABLE dbo.FACT_TRANSACTION_SUMMARY_NEW

CREATE TABLE dbo.FACT_TRANSACTION_SUMMARY_NEW WITH (DISTRIBUTION = HASH(ZC_TT_ACCT_ID), CLUSTERED COLUMNSTORE INDEX ) -- HASH(TRANSACTION_DATE_YEAR_MONTH)
AS 


--EXPLAIN
SELECT 
	  A.ACCT_ID AS ZC_TT_ACCT_ID
	--, A.TAG_ID
	, COUNT(*) TOLL_TAG_TRANS_COUNT
	, 0 AS ZC_TRANS_COUNT
	, 'TollTag' as TransactionType
	, transaction_date AS TRANSACTION_DATE
	, TRANSACTION_TIME_ID as TRANSACTION_TIME_ID 
	--, [DATE_YEAR_MONTH] AS TRANSACTION_DATE_YEAR_MONTH
	--, [DATE_YEAR] AS TRANSACTION_DATE_YEAR
	, B.ZIP_CODE
	, B.ZIPCODE_LATITUDE
	, B.ZIPCODE_LONGITUDE
	, B.COUNTY
	, B.COUNTY_GROUP
	, B.ACCT_STATUS_DESCR, B.ACCT_TAG_STATUS_DESCR
	, A.LANE_ID
	, '-1' AS VIOL_STATUS
	--E.LANE_ABBREV, PLAZA_ABBREV, PLAZA_NAME, PLAZA_LATITUDE, PLAZA_LONGITUDE, SUB_FACILITY_ABBREV, FACILITY_ABBREV, SUB_AGENCY_ABBREV, AGENCY_ABBREV
FROM DBO.FACT_TOLL_TRANSACTIONS A 
INNER JOIN dbo.ACCOUNT_TAG_MAX_ACCT_TAG_SEQ B
        ON A.ACCT_ID = B.ACCT_ID AND A.TAG_ID = B.TAG_ID 
INNER JOIN dbo.DIM_LANE E 
        ON A.LANE_ID = E.LANE_ID 
WHERE 
		transaction_date >= '2011-01-01' and 
        (A.ACCT_ID <> 666 AND --NTTA VEHICLES
        A.ACCT_ID <> 668) AND --NTTA VEHICLES
        B.ACCT_TYPE_CODE <> 'E' --EMPLOYEES
GROUP BY 	
	  A.ACCT_ID
	--, A.TAG_ID
	, transaction_date 
	, TRANSACTION_TIME_ID
	, B.ZIP_CODE
	, B.ZIPCODE_LATITUDE
	, B.ZIPCODE_LONGITUDE
	, B.COUNTY
	, B.COUNTY_GROUP
	, B.ACCT_STATUS_DESCR, B.ACCT_TAG_STATUS_DESCR
	, A.LANE_ID


UNION ALL

SELECT 	  
	  A.VIOLATOR_ID AS ZC_TT_ACCT_ID
	--, 0 AS TAG_ID
	, 0 AS TOLL_TAG_TRANS_COUNT
	, COUNT(*)  AS ZC_TRANS_COUNT
	, 'ZipCash' as TransactionType
	, VIOL_DATE AS TRANSACTION_DATE
	, [VIOL_TIME_ID] as TRANSACTION_TIME_ID 
	, ISNULL(B.ZIP_CODE,'(Null)')  AS ZIP_CODE
	, ISNULL(B.ZIPCODE_LATITUDE,33.015926000000) AS ZIPCODE_LATITUDE
	, ISNULL(B.ZIPCODE_LONGITUDE,-96.823378000000) AS ZIPCODE_LONGITUDE
	, ISNULL(B.COUNTY,'(Null)') AS COUNTY
	, ISNULL(B.COUNTY_GROUP, '(Null)') AS COUNTY_GROUP
	, '(Null)' AS ACCT_STATUS_DESCR, '(Null)' AS ACCT_TAG_STATUS_DESCR
	, A.LANE_ID
	, A.VIOL_STATUS

FROM edw_rite.dbo.Violations A
LEFT JOIN 
	(
		SELECT 
			  AA.VIOLATOR_ID
			, AA.ZIP_CODE
			, BB.ZIPCODE_LATITUDE
			, BB.ZIPCODE_LONGITUDE
			, BB.COUNTY
			, BB.COUNTY_GROUP
		FROM VIOLATOR_ADDRESS_MAX_SEQ AA
		LEFT JOIN DIM_ZIPCODE BB ON AA.ZIP_CODE = BB.ZIPCODE
	) B ON A.VIOLATOR_ID = B.VIOLATOR_ID
WHERE 
	VIOL_DATE >= '2011-01-01' 
GROUP BY 
	  A.VIOLATOR_ID
	, VIOL_DATE
	, [VIOL_TIME_ID]
	, B.ZIP_CODE
	, B.ZIPCODE_LATITUDE
	, B.ZIPCODE_LONGITUDE
	, B.COUNTY
	, B.COUNTY_GROUP
	, A.LANE_ID
	, A.VIOL_STATUS

	IF OBJECT_ID('dbo.FACT_TRANSACTION_SUMMARY')>0
		RENAME OBJECT::dbo.FACT_TRANSACTION_SUMMARY TO FACT_TRANSACTION_SUMMARY_OLD;

	RENAME OBJECT::dbo.FACT_TRANSACTION_SUMMARY_NEW TO FACT_TRANSACTION_SUMMARY;

	IF OBJECT_ID('dbo.FACT_TRANSACTION_SUMMARY_OLD')>0
		DROP TABLE dbo.FACT_TRANSACTION_SUMMARY_OLD


exec DropStats 'dbo','FACT_TRANSACTION_SUMMARY' 
-- exec CreateStats 'FACT_TRANSACTION_SUMMARY'

CREATE STATISTICS STATS_FACT_TRANSACTION_SUMMARY_001 ON [dbo].FACT_TRANSACTION_SUMMARY (ZC_TT_ACCT_ID)
CREATE STATISTICS STATS_FACT_TRANSACTION_SUMMARY_002 ON [dbo].FACT_TRANSACTION_SUMMARY (TOLL_TAG_TRANS_COUNT)
CREATE STATISTICS STATS_FACT_TRANSACTION_SUMMARY_003 ON [dbo].FACT_TRANSACTION_SUMMARY (ZC_TRANS_COUNT)
CREATE STATISTICS STATS_FACT_TRANSACTION_SUMMARY_004 ON [dbo].FACT_TRANSACTION_SUMMARY (TransactionType)
CREATE STATISTICS STATS_FACT_TRANSACTION_SUMMARY_005 ON [dbo].FACT_TRANSACTION_SUMMARY (TRANSACTION_DATE)
CREATE STATISTICS STATS_FACT_TRANSACTION_SUMMARY_006 ON [dbo].FACT_TRANSACTION_SUMMARY (TRANSACTION_TIME_ID)
CREATE STATISTICS STATS_FACT_TRANSACTION_SUMMARY_007 ON [dbo].FACT_TRANSACTION_SUMMARY (ZIP_CODE)
CREATE STATISTICS STATS_FACT_TRANSACTION_SUMMARY_008 ON [dbo].FACT_TRANSACTION_SUMMARY (ZIP_CODE, ZIPCODE_LATITUDE, ZIPCODE_LONGITUDE)
CREATE STATISTICS STATS_FACT_TRANSACTION_SUMMARY_010 ON [dbo].FACT_TRANSACTION_SUMMARY (COUNTY)
CREATE STATISTICS STATS_FACT_TRANSACTION_SUMMARY_011 ON [dbo].FACT_TRANSACTION_SUMMARY (COUNTY_GROUP)
CREATE STATISTICS STATS_FACT_TRANSACTION_SUMMARY_012 ON [dbo].FACT_TRANSACTION_SUMMARY (ACCT_STATUS_DESCR)
CREATE STATISTICS STATS_FACT_TRANSACTION_SUMMARY_013 ON [dbo].FACT_TRANSACTION_SUMMARY (ACCT_TAG_STATUS_DESCR)
CREATE STATISTICS STATS_FACT_TRANSACTION_SUMMARY_014 ON [dbo].FACT_TRANSACTION_SUMMARY (LANE_ID)



 




