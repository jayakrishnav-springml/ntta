CREATE PROC [DBO].[Service_Tables_To_Save_Load] AS
/*
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.Service_Tables_To_Save_Load') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.Service_Tables_To_Save_Load
GO

EXEC DBO.Service_Tables_To_Save_Load

SELECT * FROM dbo.Service_Tables_To_Save
where SAVE_TABLE is null

DELETE FROM dbo.Service_Tables_To_Save
WHERE TABLE_NAME = 'FACT_TOLL_TRANSACTIONS_MISSED_ROWS'

*/

DECLARE @TABLE_NAME VARCHAR(100)
DECLARE @Schema_name VARCHAR(100)
DECLARE @LAST_UPDATE_DATE VARCHAR(100)

IF OBJECT_ID('tempdb..#TABLE_COLUMNS') IS NOT NULL DROP TABLE #TABLE_COLUMNS;
SELECT      
	S.name AS [Schema_name], t.name AS Table_Name, c.name AS LAST_UPDATE_DATE
	, ROW_NUMBER() OVER (ORDER BY t.name) RN
	INTO #TABLE_COLUMNS
FROM        sys.tables  t
JOIN		sys.schemas S	ON S.schema_id = t.schema_id
LEFT JOIN   sys.columns c  ON c.object_id = t.object_id AND c.name = 'LAST_UPDATE_DATE'
LEFT JOIN EDW_RITE.dbo.Service_Tables_To_Save AS a ON a.[SCHEMA_NAME] = S.name AND a.TABLE_NAME = t.name
WHERE       a.TABLE_NAME IS NULL


DECLARE @NUM_OF_COLUMNS INT
SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #TABLE_COLUMNS
DECLARE @INDICAT SMALLINT = 1
DECLARE @Delimiter VARCHAR(3) = ''
DECLARE @SELECT_String VARCHAR(MAX) = ''
-- If only 1 period (and 1 partition) - @PART_RANGES is empty
DECLARE @SQL_INSERT VARCHAR(MAX) = '' 
DECLARE @REFERENCES VARCHAR(10)

WHILE (@INDICAT <= @NUM_OF_COLUMNS)
BEGIN
	
	SELECT @TABLE_NAME = TABLE_NAME, @Schema_name = [Schema_name], @LAST_UPDATE_DATE = LAST_UPDATE_DATE 
	FROM #TABLE_COLUMNS WHERE RN = @INDICAT

	SELECT @REFERENCES = CAST(COUNT(1) AS VARCHAR(10))
	FROM SYS.PROCEDURES AS PR
	JOIN SYS.SQL_MODULES AS MODU ON PR.OBJECT_ID = MODU.OBJECT_ID
	WHERE UPPER(MODU.DEFINITION) LIKE '%' + @TABLE_NAME + '%' 

	SET @SQL_INSERT = '
	INSERT INTO EDW_RITE.dbo.Service_Tables_To_Save
	SELECT 
		''' + @SCHEMA_NAME + ''' AS [SCHEMA_NAME], 
		''' + @TABLE_NAME + ''' AS TABLE_NAME, 
		COUNT_BIG(1) AS Row_Count, 
		[REFERENCES] = ' + @REFERENCES + ',
		LAST_UPDATE_DATE = ' + CASE WHEN @LAST_UPDATE_DATE IS NULL THEN ' NULL ' ELSE ' MAX(LAST_UPDATE_DATE)' END + ',
		[SAVE_TABLE] = NULL,
		[MOVE_BEFORE] = NULL,
		[DONE] = NULL
	FROM EDW_RITE.[' + @SCHEMA_NAME + '].[' + @TABLE_NAME + '];'

	EXEC(@SQL_INSERT)

	SET @INDICAT += 1

END

/*
UPDATE EDW_RITE.dbo.Service_Tables_To_Save
SET SAVE_TABLE = 0
WHERE Row_Count = 0

UPDATE EDW_RITE.dbo.Service_Tables_To_Save
SET SAVE_TABLE = 0
WHERE SCHEMA_NAME != 'dbo'

UPDATE EDW_RITE.dbo.Service_Tables_To_Save
SET SAVE_TABLE = 0
WHERE TABLE_NAME LIKE '%_STAGE%'

UPDATE EDW_RITE.dbo.Service_Tables_To_Save
SET SAVE_TABLE = 0
WHERE TABLE_NAME LIKE '%_OLD'

UPDATE EDW_RITE.dbo.Service_Tables_To_Save
SET SAVE_TABLE = 0
WHERE TABLE_NAME LIKE '%_NEW_SET'

UPDATE EDW_RITE.dbo.Service_Tables_To_Save
SET SAVE_TABLE = 0
WHERE TABLE_NAME LIKE '%TEST%'

UPDATE EDW_RITE.dbo.Service_Tables_To_Save
SET SAVE_TABLE = 0
WHERE TABLE_NAME LIKE '%TEMP%'

UPDATE EDW_RITE.dbo.Service_Tables_To_Save
SET SAVE_TABLE = 0
WHERE TABLE_NAME LIKE '%_TRUNCATE'


SELECT * FROM dbo.Service_Tables_To_Save
where SAVE_TABLE is null
ORDER BY Row_Count, [REFERENCES], [TABLE_NAME]
*/
/*
UPDATE EDW_RITE.dbo.Service_Tables_To_Save
SET SAVE_TABLE = 1, MOVE_BEFORE = 0
WHERE TABLE_NAME IN 
('FACT_INVOICE_ANALYSIS_DETAIL','TOTAL_NET_REV_TFC_EVTS','FACT_NET_REV_TFC_EVTS','TA_REV_TFC_EVTS','TA_TXN_RITE_DATAS','TA_TXN_CLASS_DATAS','TA_TXN_AVI_DATAS','FACT_TOLL_TRANSACTIONS','HOST_TGS_XREF',
'FACT_INVOICE_ANALYSIS','FACT_UNIFIED_VIOLATION_SNAPSHOT','FACT_UNIFIED_VIOLATION_PREV_FROM_2012','FACT_LANE_VIOLATIONS_DETAIL','ICRS_VPS_XREF','HOST_ICRS_XREF','FACT_BALANCE_HISTORY_TGS_NEW',
'FACT_UNIFIED_VIOLATION_HISTORY','FACT_VIOLATION_VB_VIOL_INVOICES','VIOLATIONS','FACT_UNIFIED_VIOLATION_INVOICE','FACT_VIOLATIONS_DETAIL','VB_INVOICE_VIOL','DIM_ICS_LANE_VIOL_IMAGES','VPS_HOST_TRANSACTIONS',
'FACT_VTOLLS_DETAIL','FACT_TRIP_HISTORY','VPS_TGS_XREF','DIM_VIOLATOR_ASOF','VIOL_INVOICE_VIOL','RETAIL_TRANSACTIONS','FACT_VIOLATION_PAYMENTS','FACT_TRIP_ANALYSIS','FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_HIST',
'PAYMENTS_VPS_DETAIL','TRANSACTION_FILE_DETAILS','FACT_VIOLATIONS_DMV_STATUS_DETAIL','FACT_IOP_TGS','ACCOUNT_HISTORY','PAYMENT_XREF_VPS','FACT_TOLL_TAG_PENETRATION','FACT_VIOLATIONS_SUMMARY','FACT_BUBBLE_MONTH',
'FACT_VIOLATIONS_SUMMARY_CATEGORY_LEVEL','DIM_TOLL_PLATE','AU_TXN_ADJ_DETAILS','FACT_VB_VIOL_INVOICES','FACT_VIOLATIONS_SUMMARY_PURSUED_LEVEL','VB_INVOICES','VB_INVOICE_BATCHES','FACT_VIOLATIONS_BR_DETAIL',
'DIM_LICENSE_PLATE','FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL','FACT_MISCLASS','VIOLATOR_ADDRESS','PAYMENT_LINE_ITEMS_VPS','PAYMENTS_VPS','CA_ACCT_INV_XREF','ACCOUNT_TAG_HISTORY','FACT_CA_INVOICES',
'VIOL_INVOICES','VIOLATORS','VIOLATOR_ADDRESS_MAX_SEQ','VB_VIOL_INVOICES','CA_ACCTS','ACCOUNT_TAGS','IOP_TXNS','FACT_CA_PAYMENTS','FACT_PAID_INVD','LANE_FRQCY_SUMMARY','ACCOUNTS','ACCT_BALANCE_HISTORY_TGS',
'CA_ACCT_ID_PARENT_CA_ACCT_ID_XREF','ALERT_BY_TRAN_CNT_LANE_FRQCY_SUMMARY','DIM_VEHICLE','COURT_ACTIONS','COURT_ACT_VIOL','MANUAL_VIOLATIONS_ID_LANE_VIOL_ID_XREF','FACT_CA_COLLECTED_PAYMENTS','VB_LANES',
'FACT_NOT_TRANSFERRED_TO_VPS_DETAIL','LOAD_PROCESS_CONTROL','FACT_VIOLATION_VIOLATOR_DRIVING_ON','ACCOUNT_BALANCE_HISTORY','FACT_MISCLASS_ICRS','TOLL_TAGS','FACT_VPS_EXCUSALS','RETAIL_TRXN_DETAILS')


UPDATE EDW_RITE.dbo.Service_Tables_To_Save
SET SAVE_TABLE = 1, MOVE_BEFORE = 1
WHERE TABLE_NAME IN 
('CITY_GROUPING','CSC_COMMENTS','DIM_TIME','DIM_VEHICLE_COLOR','DIM_ZIPCODE','DIM_DATE','PROCESS_LOG','DIM_DAY','DIM_LANE','PLAZA_PLAZA_XREF','DIM_WEEK','DIM_PLAZA','POS_LOCATIONS','DIM_STATE','ALERT_BY_TRAN_CNT_DIM_LANE',
'DIM_MONTH','PARTITION_DAY_ID_CONTROL','NTTA_TOLL_LOCATIONS','DIM_FACILITY','DIM_BUBBLE_CATEGORY','DIM_INVOICE_STATUS','TRANSACTION_TYPES','DIM_QUARTER','TRANSACTION_TYPES_VPS','DIM_AGENCY','DIM_CATEGORY_LEVEL_4',
'DIM_PURSUED_LEVEL_2','EXCUSAL_REASONS','DIM_CATEGORY','VIOL_STATUS','PARTITION_AS_OF_DATE_CONTROL','VIOL_INV_STATUS','Time_Zone_Offset','VIOL_REJECT_TYPES','DIM_YEAR','CA_INV_STATUS','REVIEW_STATUS','DIM_CATEGORY_LEVEL_0',
'PARTITION_AS_OF_DATE_TABLE','PMT_TXN_TYPES','LANE_VIOL_STATUS','DPS_INV_STATUS','ACCOUNT_TYPES','ACCT_TAG_STATUSES','DIM_CATEGORY_LEVEL_5','PAYMENT_SOURCE','SOURCE_CODE_TOLL','CA_COMPANIES','VIOLATOR_TYPES',
'DIM_SOURCE_TS','ADDRESS_SOURCES','DIM_CATEGORY_LEVEL_3','HOW_DELIVERED','Service_Monthly_Table_Count','HOST_AVI_TAG_STATUSES','VB_INV_STATUS','PAYMENT_FORMS','DIM_CATEGORY_LEVEL_7','DIM_INVOICE_ANALYSIS_CATEGORY',
'DIM_VEH_CLSS_TYPES','ACCOUNT_STATUSES','VEHICLE_CLASSES','CREDIT_CARD_TYPES','DIM_CATEGORY_LEVEL_2','DIM_FACILITY_GROUP','VIOL_PAY_TYPES','ADDRESS_STATUS','DIM_CATEGORY_LEVEL_6','DIM_CATEGORY_LEVEL_1','CLOSE_OUT_STATUSES',
'VIOL_TYPES','TAG_TYPES','MONTHLY_LOAD_CHECK_SOURCE_TABLES','CLOSE_OUT_TYPES','ACCOUNT_PAYMENT_TYPES','DIM_VIOLATION_OR_ZIPCASH','DIM_PURSUED_LEVEL_1','DIM_INDICATOR','DIM_INVOICE_TYPE','DIM_DISPOSITION','DIM_PURSUED_LEVEL_0')
VIOLATOR_AVI_TOLLS,FACT_BUBBLE_MONTH

UPDATE EDW_RITE.dbo.Service_Tables_To_Save
SET SAVE_TABLE = 0
WHERE TABLE_NAME IN 
('FACT_NET_REV_TFC_EVTS_SUMMARY','FACT_NET_REV_TFC_TRIPS','FACT_INVOICE_ANALYSIS_DETAIL_FINAL','FACT_BALANCE_HISTORY_TGS_COMPARE','FACT_BALANCE_HISTORY_TGS','FACT_BALANCE_HISTORY_TGS_TRANS',
'FACT_BALANCE_HISTORY_TGS_TRANS_VPS_TGS_DATES','FACT_BALANCE_HISTORY_TGS_TRANS_VPS_TGS','FACT_INVOICE_DETAIL_MISSING_VPS_HOST_TRANS','FACT_TRIP','FACT_TRIP_ICRS','VPS_HOST_TRANSACTIONS_DIST_ON_VIOLATION_ID',
'PAYMENTS_VPS_DETAIL_CHANGE','FACT_UNIFIED_VIOLATION_PAYMENT','FACT_NET_REV_TFC_TRIPS','ACCT_BALANCE_TGS_DAILY_SUMMARY_STARTING_BALANCES','FACT_VTOLLS','ACCOUNT_TAG_MAX_ACCT_TAG_SEQ','MANUAL_VIOLATIONS',
'FACT_VIOLATIONS_SUMMARY_DISPOSE','FACT_BUBBLE_MONTH','DIM_ICS_LANE_VIOL_IMAGES_NEW','FACT_BUBBLE_MONTH_HIST','ALERT_BY_TRAN_CNT_LANE_FRQCY','BAN_Report_Data','MANUAL_VIOLATIONS_WITH_FILE',
'MANUAL_VIOLATIONS_WITH_TRANSACTION_ID','FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_HIST','PARTITION_LOAD_Dates')


SELECT * FROM dbo.Service_Tables_To_Save
where SAVE_TABLE is NULL
OR TABLE_NAME IN 
('FACT_NET_REV_TFC_EVTS_SUMMARY','FACT_NET_REV_TFC_TRIPS','FACT_INVOICE_ANALYSIS_DETAIL_FINAL','FACT_BALANCE_HISTORY_TGS_COMPARE','FACT_BALANCE_HISTORY_TGS','FACT_BALANCE_HISTORY_TGS_TRANS',
'FACT_BALANCE_HISTORY_TGS_TRANS_VPS_TGS_DATES','FACT_BALANCE_HISTORY_TGS_TRANS_VPS_TGS','FACT_INVOICE_DETAIL_MISSING_VPS_HOST_TRANS','FACT_TRIP','FACT_TRIP_ICRS','VPS_HOST_TRANSACTIONS_DIST_ON_VIOLATION_ID',
'PAYMENTS_VPS_DETAIL_CHANGE','FACT_UNIFIED_VIOLATION_PAYMENT','FACT_NET_REV_TFC_TRIPS','ACCT_BALANCE_TGS_DAILY_SUMMARY_STARTING_BALANCES','FACT_VTOLLS','ACCOUNT_TAG_MAX_ACCT_TAG_SEQ','MANUAL_VIOLATIONS',
'FACT_VIOLATIONS_SUMMARY_DISPOSE','DIM_ICS_LANE_VIOL_IMAGES_NEW','FACT_BUBBLE_MONTH_HIST','ALERT_BY_TRAN_CNT_LANE_FRQCY','BAN_Report_Data','MANUAL_VIOLATIONS_WITH_FILE',
'MANUAL_VIOLATIONS_WITH_TRANSACTION_ID','FACT_NOT_TRANSFERRED_TO_VPS_DETAIL_HIST','PARTITION_LOAD_Dates')
ORDER BY Row_Count, [REFERENCES], [TABLE_NAME]



--DELETE FROM dbo.Service_Tables_To_Save
--WHERE TABLE_NAME IN 
--('VIOLATOR_ADDRESS_LAST_BAD','VIOLATOR_AVI_TOLLS','VIOLATOR_SUMMARY_NEW')

----IF OBJECT_ID('dbo.FACT_UNIFIED_VIOLATION_HISTORY_keep') IS NOT NULL DROP TABLE dbo.FACT_UNIFIED_VIOLATION_HISTORY_keep;





SELECT PR.NAME, MODU.DEFINITION 
FROM SYS.PROCEDURES AS PR
JOIN SYS.SQL_MODULES AS MODU ON PR.OBJECT_ID = MODU.OBJECT_ID
WHERE UPPER(MODU.DEFINITION) LIKE '%LOAD_CONTROL%' -- VB_STATEMENT -- LANE_VIOLATIONS
ORDER BY 1
*/


/*
???
FACT_TRANSACTION_SUMMARY
AVI_TRANSACTIONS
FACT_VIOLATIONS_SUMMARY_HIST
FACT_VIOLATIONS_SUMMARY_CATEGORY_LEVEL_HIST
VIOLATIONS_DIST_ON_VIOLATION_ID
FACT_VIOLATIONS_SUMMARY_PURSUED_LEVEL_HIST
FACT_UNIFIED_UNPAID_INVOICE
TOLL_TRANSACTIONS_ZIPCODE
FACT_UNIFIED_VB_PAYMENT
VB_STATEMENT_INVOICES
LANE_ID_VIOL_DATE_LANE_VIOL_ID
VIOLATIONS_ZIPCODE
VB_STATEMENTS
IOP_TXNS_INCR
ACCOUNT_VIOLATION_TGS_VPS
HOST_TGS_XREF_NEW
FACT_VIOLATOR_PAYMENT
SHIFTS
ICRS_VPS_XREF_NEW
FACT_TOLL_TAG_PENETRATION_VERSION_0
FACT_NET_REV_TFC_TRIPS
DIM_DATE_SAVE
DIM_LANE_SEGMENT
DIM_FACILITY_SUBSET
DIM_RETAIL_TRXN_DETAILS_TRANS_STATUS
ACCOUNT_TAGS_UNION
BAN_Report_Data
ICRS_VPS_XREF_NEW
IMAGES_LESS_THAN_3
HOST_ICRS_VPS_TGS_XREF
MISCLASS_LESS_THAN_99_5
REL_FACILITY_GROUP_TO_FACILITY
REL_PaidStatus_GROUP_TO_PaidStatus
REL_HVFlag_GROUP_TO_HVFlag
REL_ADDR_STATUS_GROUP_TO_ADDR_STATUS
VIOL_REJECT_TYPE_REVIEW_STATUS_IMAGE_QUALITY_RPT_XREF

*/
