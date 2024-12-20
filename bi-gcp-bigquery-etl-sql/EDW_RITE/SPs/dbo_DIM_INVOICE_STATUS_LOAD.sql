CREATE PROC [DBO].[DIM_INVOICE_STATUS_LOAD] AS 


/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.DIM_INVOICE_STATUS_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.DIM_INVOICE_STATUS_LOAD
GO

EXEC EDW_RITE.DBO.DIM_INVOICE_STATUS_LOAD



*/



PRINT 'Proc wrong - do not run!'

/*
INSERT INTO DIM_INVOICE_STATUS
SELECT 
	 A.ZI_STAGE_ID, A.VBI_STATUS, A.VIOL_INV_STATUS, '(Null)', '(Null)',GETDATE(),GETDATE()
FROM dbo.FACT_INVOICE_ANALYSIS A
LEFT JOIN dbo.DIM_INVOICE_STATUS B 
	ON A.ZI_STAGE_ID = B.ZI_STAGE_ID AND A.VBI_STATUS = B.VBI_STATUS AND A.VIOL_INV_STATUS = B.VIOL_INV_STATUS 
WHERE B.ZI_STAGE_ID IS NULL AND B.VBI_STATUS IS NULL AND B.VIOL_INV_STATUS IS NULL 
AND PARTITION_DATE = (SELECT TOP 1 PARTITION_DATE FROM PARTITION_AS_OF_DATE_CONTROL ORDER BY PARTITION_DATE DESC)
GROUP BY  A.ZI_STAGE_ID, A.VBI_STATUS, A.VIOL_INV_STATUS


IF OBJECT_ID ('DIM_INVOICE_STATUS_STAGE')<>0 DROP TABLE DIM_INVOICE_STATUS_STAGE

CREATE TABLE dbo.DIM_INVOICE_STATUS_STAGE WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ZI_STAGE_ID, VBI_STATUS, VIOL_INV_STATUS)) 
AS 
SELECT AA.ZI_STAGE_ID, AA.VBI_STATUS, AA.VIOL_INV_STATUS
	, AA.ZI_STAGE_NAME, AA.VBI_STATUS_DESC, AA.VIOL_INV_STATUS_DESCR, AA.LatestStatus AS INVOICE_STATUS_DESCR
	, ISNULL(CASE WHEN AA.LatestStatus='Closed:Reassigned' THEN 'ReAsgn_UnAsgn' 
		WHEN AA.LatestStatus='Closed:Unassigned' THEN 'ReAsgn_UnAsgn'
		WHEN AA.LatestStatus='Closed; Reassigned' THEN 'ReAsgn_UnAsgn'
		WHEN AA.LatestStatus='Closed;Unassigned' THEN 'ReAsgn_UnAsgn'
		WHEN AA.LatestStatus='Excused' THEN 'Closed'
		WHEN AA.LatestStatus='VPS - Excused' THEN 'Closed'
		WHEN AA.LatestStatus='CA; VPS Excused' THEN 'Closed'
		WHEN AA.LatestStatus='Excused - VTOLL Posted' THEN 'Paid-VToll'
		WHEN AA.LatestStatus='Fully Paid' THEN 'Paid'
		WHEN AA.LatestStatus='Excused Fee with Toll Paid' THEN 'Paid'
		WHEN AA.LatestStatus='CA; VPS Excused Fee with toll paid' THEN 'Paid'
		WHEN AA.LatestStatus='CA; VPS Fully Paid' THEN 'Paid'
		WHEN AA.LatestStatus='CA; VPS Vtolled' THEN 'Paid'
		WHEN AA.LatestStatus='Citation Issued' THEN 'Open'
		WHEN AA.LatestStatus='Citation Printed' THEN 'Open'
		WHEN AA.LatestStatus='Chargeback Payment' THEN 'Open'
		WHEN AA.LatestStatus='Open' THEN 'Open'
		WHEN AA.LatestStatus='Returned with Bad Address' THEN 'Open'
		WHEN AA.LatestStatus='DPS Hold; Company' THEN 'Open'
		WHEN AA.LatestStatus='Sent to Collections Agency' THEN 'Open'
		WHEN AA.LatestStatus='Bounced Payment' THEN 'Open'
		WHEN AA.LatestStatus='Closed (unpaid)' THEN 'Closed'
		WHEN AA.LatestStatus='DPS Hold;No DL Match Yet Found' THEN 'Open'
		WHEN AA.LatestStatus='VPS; Returned with Bad Address' THEN 'Open'
		WHEN AA.LatestStatus='Awaiting DPS Action' THEN 'Open'
		WHEN AA.LatestStatus='Closed; Aged' THEN 'Closed'
		WHEN AA.LatestStatus='Converted to Violation Invoice' THEN 'Open'
		WHEN AA.LatestStatus='DPS Citation Issued' THEN 'Open'
		WHEN AA.LatestStatus='Uncollectable' THEN 'Closed'
		WHEN AA.LatestStatus='Aged out of CA' THEN 'Open'
		WHEN AA.LatestStatus='DPS - Excused' THEN 'Closed'
		WHEN AA.LatestStatus='DPS - Excused' THEN 'Open'
		WHEN AA.LatestStatus='Uninvoiced' THEN 'Uninvoiced'
		WHEN AA.LatestStatus='Resent to DPS' THEN 'Open'
		WHEN AA.LatestStatus='Excused with toll paid.' THEN 'Paid'
		WHEN AA.LatestStatus='JP Court Action underway' THEN 'Open'
		WHEN AA.LatestStatus='Work In Progress, not printed' THEN 'Open'

	END,'(Null)') AS INVOICE_STATUS_DESCR_SUM_GROUP
FROM 

(
	SELECT A.ZI_STAGE_ID, A.VBI_STATUS, A.VIOL_INV_STATUS
		, B.ZI_STAGE_NAME
		, C.DESCRIPTION as VBI_STATUS_DESC
		, D.VIOL_INV_STATUS_DESCR
		, ISNULL(CASE	
				WHEN B.ZI_STAGE_NAME = 'Original' 
				THEN 
					CASE 
						WHEN ((C.DESCRIPTION ='Converted to Violation Invoice' OR A.VBI_STATUS = '-1') AND (D.VIOL_INV_STATUS_DESCR <> '(Null)' AND D.VIOL_INV_STATUS_DESCR <> 'Not Converted'))
							THEN D.VIOL_INV_STATUS_DESCR
						ELSE C.DESCRIPTION
					END 
				WHEN B.ZI_STAGE_NAME = '1NNP' 
				THEN 
					CASE 
						WHEN (C.DESCRIPTION <> 'Converted to Violation Invoice' AND C.DESCRIPTION <> '(Null)') OR (C.DESCRIPTION ='Converted to Violation Invoice' AND D.VIOL_INV_STATUS_DESCR = 'Not Converted')
							THEN C.DESCRIPTION
						ELSE D.VIOL_INV_STATUS_DESCR
					END 
				WHEN B.ZI_STAGE_NAME = '(Null)' AND  C.DESCRIPTION = '(Null)' 
				THEN D.VIOL_INV_STATUS_DESCR
				WHEN B.ZI_STAGE_NAME = '(Null)' AND A.VBI_STATUS = '-1' AND A.VIOL_INV_STATUS = '-1'
				THEN 'Uninvoiced'

			END,'(Null)') AS LatestStatus
	FROM DIM_INVOICE_STATUS A
	INNER JOIN DIM_ZI_STG B ON A.ZI_STAGE_ID = B.ZI_STAGE_ID
	INNER JOIN VB_INV_STATUS C ON A.VBI_STATUS = C.STATUS
	INNER JOIN VIOL_INV_STATUS D ON A.VIOL_INV_STATUS = D.VIOL_INV_STATUS

) AA

UPDATE DIM_INVOICE_STATUS
SET   INVOICE_STATUS_DESCR = B.INVOICE_STATUS_DESCR
	, INVOICE_STATUS_DESCR_SUM_GROUP = B.INVOICE_STATUS_DESCR_SUM_GROUP
FROM DIM_INVOICE_STATUS_STAGE B
WHERE 
			DIM_INVOICE_STATUS.ZI_STAGE_ID = B.ZI_STAGE_ID 
		AND DIM_INVOICE_STATUS.VBI_STATUS = B.VBI_STATUS 
		AND DIM_INVOICE_STATUS.VIOL_INV_STATUS = B.VIOL_INV_STATUS 
		AND 
			(
				DIM_INVOICE_STATUS.INVOICE_STATUS_DESCR <> B.INVOICE_STATUS_DESCR
				OR 
				DIM_INVOICE_STATUS.INVOICE_STATUS_DESCR_SUM_GROUP <> B.INVOICE_STATUS_DESCR_SUM_GROUP
			)

IF OBJECT_ID ('DIM_INVOICE_STATUS_STAGE')<>0 DROP TABLE DIM_INVOICE_STATUS_STAGE

UPDATE STATISTICS dbo.DIM_INVOICE_STATUS

*/
