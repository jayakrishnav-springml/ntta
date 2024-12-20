CREATE PROC [DBO].[VIOLATIONS_LOAD] AS 

IF OBJECT_ID('dbo.VIOLATIONS_NEW')>0
	DROP TABLE dbo.VIOLATIONS_NEW

CREATE TABLE dbo.VIOLATIONS_NEW WITH (DISTRIBUTION = HASH(ViolatorID), CLUSTERED COLUMNSTORE INDEX) 
AS 
--- EXPLAIN
SELECT   
	  VIOLATION_ID
	, B.ViolatorID
	, B.VidSeq
	, LANE_ID
	, LICENSE_PLATE_ID
	--, LICENSE_PLATE_DMV_ID
	, VIOL_STATUS
	, VIOL_DATE
	, VIOL_TIME_ID
	, TOLL_DUE
	, TOLL_PAID
	--, TRANSACTION_FILE_DETAIL_ID
	, POST_DATE
	, POST_TIME_ID
	--, DAYS_VIOL_DATE_TO_POST_DATE
	--, SUBSCRIBER_UNIQUE_ID
	--, RECEIVED_DATE
	--, RECEIVED_TIME_ID
	--, HAS_NEVER_BEEN_INVOICED
	, ZC_INVOICE_COUNT
	--, LAST_ZC_INVOICE_ID
	--, LAST_ZC_INVOICE_DATE
	--, LAST_ZC_INVOICE_STATUS
	--, LAST_ZC_INVOICE_VIOL_STATUS
	--, DAYS_VIOL_DATE_TO_LAST_ZC_INVOICE_DATE
	--, DAYS_POST_DATE_TO_LAST_ZC_INVOICE_DATE
	, VIOL_INVOICE_COUNT
	--, LAST_VIOL_INVOICE_ID
	--, LAST_VIOL_INVOICE_DATE
	--, LAST_VIOL_INVOICE_STATUS
	--, LAST_VIOL_INVOICE_VIOL_STATUS
	--, DAYS_VIOL_DATE_TO_LAST_VIOL_INVOICE_DATE
	--, DAYS_POST_DATE_TO_LAST_VIOL_INVOICE_DATE
	--, HAS_CURRENT_ADDRESS
	--, VIOLATION_OR_ZIPCASH
	--, DAYS_VIOL_DATE_TO_CURRENT_VIOL_STATUS_DATE
	--, DAYS_POST_DATE_TO_CURRENT_VIOL_STATUS_DATE
	--, DAYS_VIOL_DATE_TO_DATE_EXCUSED
	--, DAYS_POST_DATE_TO_DATE_EXCUSED
	--, DATE_CREATED
	--, LANE_VIOL_ID
	, STATUS_DATE
	, DATE_EXCUSED
	, GETDATE() AS INSERT_DATE
FROM EDW_RITE.dbo.VIOLATIONS A
INNER JOIN Violator B ON A.VIOLATOR_ID = B.ViolatorId
WHERE B.CURRENT_IND = 1
OPTION (LABEL = 'VIOL_INVOICE_VIOL: VIOL_INVOICE_VIOL');

IF OBJECT_ID('dbo.VIOLATIONS')>0
	RENAME OBJECT::dbo.VIOLATIONS TO VIOLATIONS_OLD;

RENAME OBJECT::dbo.VIOLATIONS_NEW TO VIOLATIONS;

IF OBJECT_ID('dbo.VIOLATIONS_OLD')>0
	DROP TABLE dbo.VIOLATIONS_OLD

CREATE STATISTICS STATS_VIOLATIONS_001 ON DBO.VIOLATIONS (ViolatorId)
CREATE STATISTICS STATS_VIOLATIONS_002 ON DBO.VIOLATIONS (ViolatorId, VIOLATION_ID)
CREATE STATISTICS STATS_VIOLATIONS_003 ON DBO.VIOLATIONS (LICENSE_PLATE_ID)




