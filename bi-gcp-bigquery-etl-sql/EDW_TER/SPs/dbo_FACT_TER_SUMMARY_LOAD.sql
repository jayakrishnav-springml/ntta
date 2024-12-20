CREATE PROC [DBO].[FACT_TER_SUMMARY_LOAD] AS -- EXEC [FACT_TER_SUMMARY_LOAD]

--2018-11-07 Ranjith Nair	Added (In/Out), TO DISTINGUISH THE HEIRARCHY
--2018-11-07 Arun   Updated Viol_invoice_Status column to Invoice_status
--2018-12-12 Arun   Updated the Dim_Violator join condition violator_paymentplan_xref table
--2019-02-26 Andy	Fully rewrote proc with CTE and 2 new fields TermLetter and HV_Removal

	/*
	USE EDW_TER
	GO

	IF EXISTS (SELECT * 
				FROM   sysobjects 
				WHERE  id = object_id('DBO.FACT_TER_SUMMARY_LOAD') 
					   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
	DROP PROCEDURE DBO.FACT_TER_SUMMARY_LOAD
	GO

	EXEC EDW_TER.dbo.FACT_TER_SUMMARY_LOAD

	SELECT TOP 10 * FROM EDW_TER.dbo.FACT_TER_SUMMARY
	SELECT COUNT_BIG(1) FROM EDW_TER.dbo.FACT_TER_SUMMARY

	*/

DECLARE @SOURCE VARCHAR(50), @START_DATE DATETIME2 (2), @LOG_MESSAGE VARCHAR(1000), @ROW_COUNT BIGINT, @LOAD_CONTROL_DATE DATETIME2(2) 

SELECT  @SOURCE = 'FACT_TER_SUMMARY', @START_DATE = GETDATE(), @LOG_MESSAGE = 'Started full load'
EXEC    EDW_RITE.dbo.LOG_PROCESS @SOURCE, @START_DATE, @LOG_MESSAGE,  NULL

IF OBJECT_ID('EDW_TER.dbo.FACT_TER_SUMMARY_STAGE') > 0	DROP TABLE EDW_TER.dbo.FACT_TER_SUMMARY_STAGE

CREATE TABLE dbo.FACT_TER_SUMMARY_STAGE	WITH (CLUSTERED COLUMNSTORE INDEX,DISTRIBUTION = HASH (violatorid)) AS
-- EXPLAIN
WITH CTE_BALANCE AS
(
	SELECT 
		violatorid
		,Vidseq
		,PaymentplanStatus
		,A.PMT_TYPE_CODE AS TT_PMT_TYPE
		,A.BALANCE_AMT AS BALANCE_AMT
	FROM (
			SELECT 
				violatorid
				,Vidseq
				,CASE WHEN MAX(TollTagNbr) > Max(ACCT_ID) THEN MAX(TollTagNbr) ELSE Max(ACCT_ID) END AS ACCT_ID
				,CASE 
					WHEN MAX(PaymentplanSumID) = 16
						THEN 'Paid in Full'
					WHEN MAX(PaymentplanSumID) = 8
						THEN 'Payment Plan'
					WHEN MAX(PaymentplanSumID) = 4
						THEN 'Default in Payment'
					WHEN MAX(PaymentplanSumID) = 2
						THEN 'Quote'
					ELSE 'Bankruptcy'
				END AS PaymentplanStatus
			FROM (
					SELECT 
						DV.violatorid
						,DV.Vidseq
						,LTRIM(RTRIM(REPLACE(LEFT(SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(PL.TollTagNbr, '(', ''), ')', ''), '-', ''), ' ', ''), ',', ''), PATINDEX('%[0-9.-]%', REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(PL.TollTagNbr, '(', ''), ')', ''), '-', ''), ' ', ''), ',', '')), 8000), PATINDEX('%[^0-9.-]%', SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(PL.TollTagNbr, '(', ''), ')', ''), '-', ''), ' ', ''), ',', ''), PATINDEX('%[0-9.-]%', REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(PL.TollTagNbr, '(', ''), ')', ''), '-', ''), ' ', ''), ',', '')), 8000) + 'X') - 1), '.', ''))) TollTagNbr
						--,CASE WHEN ISNUMERIC(PL.TollTagNbr) = 1 THEN CAST(CAST(REPLACE(LTRIM(PL.TollTagNbr),CHAR(9),'') AS VARCHAR(12)) AS BIGINT) ELSE -1 END AS TollTagNbr
						,ISNULL(DV.ACCT_ID, -1) AS ACCT_ID
						,CASE 
							WHEN ps.descr IN ('Paid in Full','Paid in Full - Confirmed')
								THEN 16
							WHEN ps.descr IN ('Payment Plan') 
								THEN 8
							WHEN ps.descr IN ('Default in Payment','Default in Payment - Confirmed')
								THEN 4
							WHEN ps.descr IN ('Quote','Quote - Approval Needed','Quote - Approved','Quote - Denied')
								THEN 2
							ELSE 1
						END AS PaymentplanSumID
					FROM EDW_TER.dbo.DIM_VIOLATOR DV
					INNER JOIN VIOLATOR_PAYMENTPLAN_XREF XRF ON DV.violatorid = XRF.violatorid AND DV.VidSeq = XRF.VidSeq AND XRF.PAYMENTPLANID > -1
					INNER JOIN DIM_PAYMENTPLAN PL ON XRF.PAYMENTPLANID = PL.PAYMENTPLANID AND PL.deletedflag = 0
					INNER JOIN dbo.Dim_PaymentPlanStatusLookup PS ON PL.PaymentPlanStatusLookupID = PS.PaymentPlanStatusLookupID
				) F 
			GROUP BY violatorid,Vidseq

		) DistinctViol
	LEFT JOIN LND_LG_TS.TAG_OWNER.ACCOUNTS A ON A.ACCT_ID = DistinctViol.ACCT_ID 
)
, CTE_TER_INVOICES AS
(
	SELECT I.VIOLATOR_ID, I.VidSeq,I.VIOL_INVOICE_ID,I.VBI_INVOICE_ID --ISNULL(F1.VIOL_INV_STATUS, F2.VBI_STATUS) AS 
			,MAX(I.Invoice_Amount) AS Invoice_Amount
			,MAX(I.Invoice_Amount_Disc) AS Invoice_Amount_Disc
			,MAX(I.Tolls_Due) AS Tolls_Due
			,MAX(I.Fees_Due) AS Fees_Due
	FROM EDW_TER.dbo.FACT_TER_INVOICE I
	GROUP BY I.VIOLATOR_ID, I.VidSeq,I.VIOL_INVOICE_ID,I.VBI_INVOICE_ID --ISNULL(F1.VIOL_INV_STATUS, F2.VBI_STATUS)
)
, CTE_VB_VIOL_INVOICES AS
(
SELECT
	F.VIOL_INVOICE_ID,
	T.VBI_INVOICE_ID AS VBI_INVOICE_ID,
	CASE WHEN F.VIOL_INVOICE_ID > -1 THEN F.VIOL_INV_STATUS ELSE F.VBI_STATUS END AS Invoice_status
FROM EDW_RITE.dbo.FACT_VB_VIOL_INVOICES F
JOIN CTE_TER_INVOICES T ON F.VIOL_INVOICE_ID = T.VIOL_INVOICE_ID  AND CASE WHEN F.VIOL_INVOICE_ID > -1 THEN -1 ELSE F.VBI_INVOICE_ID END = T.VBI_INVOICE_ID
--WHERE VIOLATOR_ID IN (SELECT ViolatorID FROM EDW_TER.dbo.DIM_VIOLATOR)
)
, CTE_TER_INVOICE AS
(
	SELECT 
		I.VIOLATOR_ID
		,I.VidSeq
		,ISNULL(SUM(I.Invoice_Amount	), 0) AS Invoice_Amount
		,ISNULL(SUM(I.Invoice_Amount_Disc), 0) AS Invoice_Amount_Disc
		,ISNULL(SUM(I.Tolls_Due			), 0) AS Tolls_Due
		,ISNULL(SUM(I.Fees_Due			), 0) AS Fees_Due
		,ISNULL(SUM(P.AMT_PAID			), 0) AS AMT_PAID
		,ISNULL(SUM(CASE 
						WHEN VIS.IS_CLOSED = 'N'
							THEN Invoice_Amount
						ELSE 0
					END), 0) AS Bal_Amt
	FROM CTE_TER_INVOICES I
		JOIN CTE_VB_VIOL_INVOICES F ON I.VIOL_INVOICE_ID = F.VIOL_INVOICE_ID AND I.VBI_INVOICE_ID = F.VBI_INVOICE_ID
	
		--(
		--	SELECT I.VIOLATOR_ID, I.VidSeq,I.VIOL_INVOICE_ID,I.VBI_INVOICE_ID,F.Invoice_status --ISNULL(F1.VIOL_INV_STATUS, F2.VBI_STATUS) AS 
		--			,MAX(I.Invoice_Amount) AS Invoice_Amount
		--			,MAX(I.Invoice_Amount_Disc) AS Invoice_Amount_Disc
		--			,MAX(I.Tolls_Due) AS Tolls_Due
		--			,MAX(I.Fees_Due) AS Fees_Due
		--	FROM EDW_TER.dbo.FACT_TER_INVOICE I
		--	JOIN CTE_VB_VIOL_INVOICES F ON I.VIOL_INVOICE_ID = F.VIOL_INVOICE_ID AND I.VBI_INVOICE_ID = F.VBI_INVOICE_ID
		--	--LEFT JOIN EDW_RITE.dbo.FACT_VB_VIOL_INVOICES F2 ON I.VBI_INVOICE_ID = F2.VBI_INVOICE_ID AND F2.VBI_INVOICE_ID > -1
		--	GROUP BY I.VIOLATOR_ID, I.VidSeq,I.VIOL_INVOICE_ID,I.VBI_INVOICE_ID,F.Invoice_status --ISNULL(F1.VIOL_INV_STATUS, F2.VBI_STATUS)
		--) I
		LEFT JOIN EDW_RITE.DBO.VIOL_INV_STATUS VIS ON F.Invoice_status = VIS.Viol_Inv_Status --ON I.Invoice_status = VIS.Viol_Inv_Status
		LEFT JOIN (
					SELECT VIOLATOR_ID, VidSeq, VIOL_INVOICE_ID,VBI_INVOICE_ID, MAX(SPLIT_AMOUNT) AS AMT_PAID 
					FROM (
							SELECT VIOLATOR_ID, VidSeq, VIOL_INVOICE_ID,VBI_INVOICE_ID,PAYMENTPLANID, SUM(SPLIT_AMOUNT) AS SPLIT_AMOUNT 
							FROM EDW_TER.dbo.FACT_TER_PAYMENT 
							GROUP BY VIOLATOR_ID, VidSeq, VIOL_INVOICE_ID,VBI_INVOICE_ID,PAYMENTPLANID
						)	P 
					GROUP BY VIOLATOR_ID, VidSeq, VIOL_INVOICE_ID,VBI_INVOICE_ID,PAYMENTPLANID
				) P ON I.VIOLATOR_ID = P.VIOLATOR_ID AND I.VidSeq = P.VidSeq AND I.VIOL_INVOICE_ID = P.VIOL_INVOICE_ID AND I.VBI_INVOICE_ID = P.VBI_INVOICE_ID
	GROUP BY I.VIOLATOR_ID, I.VidSeq
),
CTE_VRB AS (
SELECT DISTINCT a1.violatorid,a1.vidseq,SUM(a1.VrbCount)VRB_CNT

FROM dbo.vw_Vrb a1
JOIN dim_violator a2
ON a1.violatorid=a2.violatorid
AND a1.VidSeq=a2.vidseq
GROUP BY a1.violatorid,a1.vidseq
)

SELECT 
	ISNULL(DV.ViolatorID, -1) AS ViolatorID
	,ISNULL(DV.VidSeq, 0) AS VidSeq
	,ISNULL(B.PaymentplanStatus,'WO payment plan')	AS PaymentPlan
	,ISNULL(VCL.ViolatorCallLog,'WO Dispute')		AS Disputed
	,CASE 
		WHEN B.TT_PMT_TYPE = 'C' 						THEN 'Credit'
		WHEN B.TT_PMT_TYPE = 'M'						THEN 'Cash'
		ELSE 'Unknown'
	END AS TT_Pmt_Type
	,CASE 
		WHEN B.BALANCE_AMT < 0							THEN 'Negative'
		WHEN B.BALANCE_AMT BETWEEN 0 AND 10				THEN 'Low Balance'
		WHEN B.BALANCE_AMT > 10							THEN 'Positive'
		ELSE 'Unknown'
	END AS TT_Acct_Bal
	,CASE 
         WHEN DV.TERMLETTERDATE > '1900-01-01'			THEN 'W Term Ltr' 
         ELSE 'WO Term Ltr' 
    END AS TermLetter
	,CASE 
        WHEN DV.TERMDATE > '1900-01-01'					THEN 'W Removal' 
        ELSE 'WO Removal' 
    END AS HV_Removal
	,CASE 
		WHEN DV.LICPLATESTATELOOKUPID = 56				THEN 'In State'
		ELSE 'Out Of State'
	END AS [State]
	,CASE 
		WHEN DV.determinationletterdate > '1900-01-01'	THEN 'W Deter Ltr'
		ELSE 'WO Deter Ltr'
	END AS [DeterminationLetter]
	,CASE 
		WHEN DV.Banletterdate > '1900-01-01'			THEN 'W Ban Ltr.'
		ELSE 'WO Ban Ltr'
	END AS [BanLetter]
	,CASE 
		WHEN DV.BanDate > '1900-01-01'					THEN 'W Ban'
		ELSE 'WO Ban'
	END [Ban]
	,CASE 
		WHEN DV.VRBLetterDate > '1900-01-01'			THEN 'W VRB Ltr'
		ELSE 'WO VRB Ltr'
	END AS [VRBLetter]
	,CASE 
              WHEN V.Vrb_Cnt>0                               THEN 'W VRB'
              ELSE 'WO VRB' 
       END AS VRB
	,CASE 
		WHEN I.Bal_Amt = 0								THEN 'No Balance'
		ELSE 'Outstanding Balance'
	END AS Out_Bal
	,ISNULL(CAST(I.Bal_Amt AS DECIMAL(10,2))				, 0) AS Bal_Amt
	,ISNULL(CAST(I.Invoice_Amount AS DECIMAL(10,2))			, 0) AS InvoiceAmount
	,ISNULL(CAST(I.Invoice_Amount_Disc AS DECIMAL(10,2))	, 0) AS InvoiceAmountDisc
	,ISNULL(CAST(I.Tolls_Due AS DECIMAL(10,2))				, 0) AS TollsDue
	,ISNULL(CAST(I.Fees_Due AS DECIMAL(10,2))				, 0) AS FeesDue
	,ISNULL(CAST(I.AMT_PAID AS DECIMAL(10,2))				, 0) AS AmountPaid
FROM EDW_TER.dbo.DIM_VIOLATOR DV
LEFT JOIN CTE_BALANCE B ON DV.Violatorid = B.VIOLATORID AND DV.VIDSEQ = B.VIDSEQ
LEFT JOIN CTE_TER_INVOICE I ON DV.VIOLATORID = I.VIOLATOR_ID AND DV.VIDSEQ = I.VIDSEQ
LEFT JOIN (
			SELECT DISTINCT 
				VIOLATORID, VIDSEQ, 'W Dispute' AS ViolatorCallLog
			FROM lnd_ter.dbo.ViolatorCallLog
			WHERE ViolatorCallLogLookupID = 12
		) VCL ON DV.VIOLATORID = VCL.VIOLATORID AND DV.VIDSEQ = VCL.VIDSEQ
LEFT JOIN CTE_VRB V
ON dv.violatorid=v.violatorid
AND dv.vidseq=v.vidseq


OPTION (LABEL = 'FACT_TER_SUMMARY LOAD');

EXEC EDW_RITE.dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT

CREATE STATISTICS STATS_FACT_TER_SUMMARY_001 ON [dbo].FACT_TER_SUMMARY_STAGE(ViolatorId,VidSeq)

IF OBJECT_ID('dbo.FACT_TER_SUMMARY_OLD') > 0	DROP TABLE dbo.FACT_TER_SUMMARY_OLD;
IF OBJECT_ID('dbo.FACT_TER_SUMMARY') > 0		RENAME OBJECT::dbo.FACT_TER_SUMMARY TO FACT_TER_SUMMARY_OLD;
IF OBJECT_ID('dbo.FACT_TER_SUMMARY_STAGE') > 0	RENAME OBJECT::dbo.FACT_TER_SUMMARY_STAGE TO FACT_TER_SUMMARY;
--IF OBJECT_ID('dbo.FACT_TER_SUMMARY_OLD') > 0	DROP TABLE dbo.FACT_TER_SUMMARY_OLD;

SET  @LOG_MESSAGE = 'Finished full load'
EXEC EDW_RITE.dbo.LOG_PROCESS @SOURCE, @START_DATE, @LOG_MESSAGE, @ROW_COUNT
--STEP #3: Create Statistics --[dbo].[CreateStats] 'dbo', 'FACT_TER_SUMMARY'


