CREATE PROC [DBO].[FACT_TER_PAYMENT_LOAD] AS

/*
USE EDW_TER
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.FACT_TER_PAYMENT_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.FACT_TER_PAYMENT_LOAD
GO

EXEC EDW_TER.DBO.FACT_TER_PAYMENT_LOAD


SELECT TOP 1000 F.VIOL_INVOICE_ID, F.PAYMENT_DATE	
,F.PAYMENTPLANID	
,F.POS_ID	
,F.SPLIT_AMOUNT	
,F.DownPayment, P.DownPaymentReceived FROM DBO.FACT_TER_PAYMENT F
JOIN dbo.DIM_PAYMENTPLAN P ON P.PaymentPlanID = F.PAYMENTPLANID
WHERE F.PAYMENTPLANID > 1
ORDER BY F.PAYMENTPLANID DESC,F.PAYMENT_DATE DESC


SELECT F.PAYMENTPLANID, SUM(F.DownPayment) AS DownPayment, MAX(P.DownPaymentReceived) AS DownPaymentReceived
FROM DBO.FACT_TER_PAYMENT F
JOIN dbo.DIM_PAYMENTPLAN P ON P.PaymentPlanID = F.PAYMENTPLANID
GROUP BY F.PAYMENTPLANID

*/

DECLARE @TABLE_NAME VARCHAR(50), @LOG_START_DATE DATETIME2 (2), @PROCEDURE_NAME VARCHAR(1000), @LOG_MESSAGE VARCHAR(3000), @ROW_COUNT BIGINT

SELECT  @TABLE_NAME = 'FACT_TER_PAYMENT', @LOG_START_DATE = SYSDATETIME(), @PROCEDURE_NAME = 'FACT_TER_PAYMENT_LOAD'

SET @LOG_MESSAGE = 'Full load started'
EXEC EDW_RITE.dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, NULL

IF OBJECT_ID('EDW_TER.dbo.CTE_TER_INVOICES') IS NOT NULL DROP TABLE EDW_TER.dbo.CTE_TER_INVOICES
--EXPLAIN
CREATE TABLE EDW_TER.dbo.CTE_TER_INVOICES WITH (HEAP, DISTRIBUTION = HASH (LAST_INVOICE_ID)) AS
	SELECT --TOP 1000
		 I.PAYMENTPLANID 
		,I.VIOLATOR_ID
		,I.VIDSEQ
		,CAST(I.DATE_EXCUSED AS DATE ) AS DATE_EXCUSED
		,I.LAST_INVOICE_ID
		,I.VBI_INVOICE_ID
		,I.VIOL_INVOICE_ID
		,I.INVOICE_DATE
		,CAST(P.DefaultedDate 		 AS DATE ) AS DefaultedDate 
		,CAST(P.PaidInFullDate		 AS DATE ) AS PaidInFullDate
		,CAST(P.BankruptcyDate		 AS DATE ) AS BankruptcyDate
		,CAST(P.FirstPaymentDate	 AS DATE ) AS FirstPaymentDate
		,P.DownPaymentReceived
		,CASE WHEN I.CURRENT_STATUS = 'TS' AND I.DATE_EXCUSED <> '1900-01-01' THEN ISNULL(I.TOLLS_DUE,0) ELSE 0 END AS EXCUSED_AMOUNT
		,CAST(CASE WHEN I.PAYMENTPLANID = -1 THEN I.HVDATE ELSE DATEADD(DAY,-1, CASE WHEN I.PAYMENTPLAN_DATE < I.PLANSTART_DATE THEN I.PAYMENTPLAN_DATE ELSE I.PLANSTART_DATE END) END AS DATE) AS START_PAY_DATE
		,ISNULL(CAST(P.PLANSTARTDATE AS DATE), '2200-01-01') AS PLAN_START_DATE
		,CAST(CASE WHEN I.PAYMENTPLANID = -1 
			THEN I.TERMDATE 
			ELSE 
				CASE WHEN P.DEFAULTEDDATE IS NOT NULL 
					THEN P.DEFAULTEDDATE 
					ELSE P.LASTPAYMENTDATE 
				END 
		END AS DATE) AS END_PAY_DATE
	FROM EDW_TER.DBO.FACT_TER_INVOICE AS I
	LEFT JOIN EDW_TER.DBO.DIM_PAYMENTPLAN AS P ON P.PAYMENTPLANID = I.PAYMENTPLANID AND P.DELETEDFLAG = 0 AND P.PAYMENTPLANSTATUSLOOKUPID > 4
OPTION (LABEL = 'FACT_TER_PAYMENT LOAD: CTE_TER_INVOICES');

IF OBJECT_ID('EDW_TER.dbo.CTE_PMNTS_SUMMARY') IS NOT NULL DROP TABLE EDW_TER.dbo.CTE_PMNTS_SUMMARY
CREATE TABLE EDW_TER.dbo.CTE_PMNTS_SUMMARY WITH (HEAP, DISTRIBUTION = HASH (LAST_INVOICE_ID)) AS
	SELECT 
		LAST_INVOICE_ID
		,VBI_INVOICE_ID
		,VIOLATOR_ID
		,PAYMENT_DATE
		,POS_ID
		,SUM(PAID_AMOUNT) SPLIT_AMOUNT
		,SUM(VTOLL_AMOUNT) VTOLL_AMOUNT
	FROM edw_rite.dbo.FACT_INVOICE_PAYMENTS --FACT_VIOLATION_PAYMENTS P
	WHERE LAST_INVOICE_ID IN (SELECT LAST_INVOICE_ID FROM CTE_TER_INVOICES)
	GROUP BY LAST_INVOICE_ID,VBI_INVOICE_ID,VIOLATOR_ID,PAYMENT_DATE,POS_ID
OPTION (LABEL = 'FACT_TER_PAYMENT LOAD: CTE_PMNTS_SUMMARY');

IF OBJECT_ID('EDW_TER.dbo.FOUND_PAYMENTS') IS NOT NULL DROP TABLE EDW_TER.dbo.FOUND_PAYMENTS
CREATE TABLE EDW_TER.dbo.FOUND_PAYMENTS WITH (HEAP, DISTRIBUTION = HASH (LAST_INVOICE_ID)) AS
	SELECT --TOP 1000
		 V.PAYMENTPLANID 
		,V.VIOLATOR_ID
		,V.VIDSEQ
		,V.LAST_INVOICE_ID
		,V.VBI_INVOICE_ID
		,V.VIOL_INVOICE_ID
		,V.DATE_EXCUSED
		,P.PAYMENT_DATE
		,V.START_PAY_DATE
		,V.DefaultedDate
		,V.PaidInFullDate
		,V.BankruptcyDate
		,V.DownPaymentReceived
		,V.FirstPaymentDate
		,P.SPLIT_AMOUNT
		,P.VTOLL_AMOUNT
		,P.POS_ID
		,CAST(CASE WHEN P.PAYMENT_DATE > V.END_PAY_DATE THEN 1 ELSE 0 END AS BIT) AS LATE_PAYMENT_FLAG
		,CASE WHEN P.PAYMENT_DATE < ISNULL(V.DefaultedDate,  '2200-01-01') THEN 'Y' ELSE 'N' END AS PMNT_BEFORE_Defaulted
		,CASE WHEN P.PAYMENT_DATE < ISNULL(V.PaidInFullDate, '2200-01-01') THEN 'Y' ELSE 'N' END AS PMNT_BEFORE_PaidInFull
		,CASE WHEN P.PAYMENT_DATE < ISNULL(V.BankruptcyDate, '2200-01-01') THEN 'Y' ELSE 'N' END AS PMNT_BEFORE_Bankruptcy
	FROM CTE_TER_INVOICES V
	JOIN CTE_PMNTS_SUMMARY P  
		ON V.VIOLATOR_ID = P.VIOLATOR_ID AND V.LAST_INVOICE_ID = P.LAST_INVOICE_ID-- AND V.VBI_INVOICE_ID = P.VBI_INVOICE_ID
			AND P.PAYMENT_DATE >= V.START_PAY_DATE 
OPTION (LABEL = 'FACT_TER_PAYMENT LOAD: FOUND_PAYMENTS');

IF OBJECT_ID('EDW_TER.dbo.CTE_EXCUSED') IS NOT NULL DROP TABLE EDW_TER.dbo.CTE_EXCUSED
CREATE TABLE EDW_TER.dbo.CTE_EXCUSED WITH (HEAP, DISTRIBUTION = HASH (LAST_INVOICE_ID)) AS
	SELECT 
		 V.PAYMENTPLANID 
		,V.VIOLATOR_ID
		,V.VIDSEQ
		,V.LAST_INVOICE_ID
		,V.VBI_INVOICE_ID
		,V.VIOL_INVOICE_ID
		,V.DATE_EXCUSED
		,V.DATE_EXCUSED AS PAYMENT_DATE
		,V.START_PAY_DATE
		,V.DefaultedDate
		,V.PaidInFullDate
		,V.BankruptcyDate
		,V.DownPaymentReceived
		,V.FirstPaymentDate
		,0 AS SPLIT_AMOUNT 
		,0 AS VTOLL_AMOUNT --(V.EXCUSED_AMOUNT - ISNULL(P.SPLIT_AMOUNT, 0)) * 0.6 AS VTOLL_AMOUNT
		,-1 AS POS_ID
		,CAST(CASE WHEN V.DATE_EXCUSED > V.END_PAY_DATE THEN 1 ELSE 0 END AS TINYINT) AS LATE_PAYMENT_FLAG
		,CASE WHEN V.DATE_EXCUSED < ISNULL(V.DefaultedDate,  '2200-01-01') THEN 'Y' ELSE 'N' END AS PMNT_BEFORE_Defaulted
		,CASE WHEN V.DATE_EXCUSED < ISNULL(V.PaidInFullDate, '2200-01-01') THEN 'Y' ELSE 'N' END AS PMNT_BEFORE_PaidInFull
		,CASE WHEN V.DATE_EXCUSED < ISNULL(V.BankruptcyDate, '2200-01-01') THEN 'Y' ELSE 'N' END AS PMNT_BEFORE_Bankruptcy
	FROM CTE_TER_INVOICES V
	LEFT JOIN (
					SELECT 	LAST_INVOICE_ID,SUM(SPLIT_AMOUNT) SPLIT_AMOUNT, SUM(VTOLL_AMOUNT) VTOLL_AMOUNT
					FROM CTE_PMNTS_SUMMARY GROUP BY LAST_INVOICE_ID
				) P ON V.LAST_INVOICE_ID = P.LAST_INVOICE_ID 
	WHERE ISNULL(P.VTOLL_AMOUNT,0) = 0 AND V.EXCUSED_AMOUNT > 0
OPTION (LABEL = 'FACT_TER_PAYMENT LOAD: CTE_EXCUSED');

IF OBJECT_ID('EDW_TER.dbo.ALL_PAYMENTS') IS NOT NULL DROP TABLE EDW_TER.dbo.ALL_PAYMENTS
CREATE TABLE EDW_TER.dbo.ALL_PAYMENTS WITH (HEAP, DISTRIBUTION = HASH (LAST_INVOICE_ID)) AS
	SELECT 
		PAYMENTPLANID,VIOLATOR_ID,VIDSEQ,LAST_INVOICE_ID,VBI_INVOICE_ID,VIOL_INVOICE_ID,PAYMENT_DATE,START_PAY_DATE, DefaultedDate, PaidInFullDate, BankruptcyDate, POS_ID, SPLIT_AMOUNT, VTOLL_AMOUNT, LATE_PAYMENT_FLAG, PMNT_BEFORE_Defaulted, PMNT_BEFORE_PaidInFull, PMNT_BEFORE_Bankruptcy,DownPaymentReceived,FirstPaymentDate
	FROM FOUND_PAYMENTS
	UNION ALL
	SELECT 
		PAYMENTPLANID,VIOLATOR_ID,VIDSEQ,LAST_INVOICE_ID,VBI_INVOICE_ID,VIOL_INVOICE_ID,PAYMENT_DATE,START_PAY_DATE, DefaultedDate, PaidInFullDate, BankruptcyDate, POS_ID, SPLIT_AMOUNT, VTOLL_AMOUNT, LATE_PAYMENT_FLAG, PMNT_BEFORE_Defaulted, PMNT_BEFORE_PaidInFull, PMNT_BEFORE_Bankruptcy,DownPaymentReceived,FirstPaymentDate
	FROM CTE_EXCUSED
OPTION (LABEL = 'FACT_TER_PAYMENT LOAD: ALL_PAYMENTS');

---- Combine payments for viol_invoice and violation and replace the viol_invoice_id in violation payments
IF OBJECT_ID('EDW_TER.dbo.Collected_PAYMENTS') IS NOT NULL DROP TABLE EDW_TER.dbo.Collected_PAYMENTS
CREATE TABLE EDW_TER.dbo.Collected_PAYMENTS WITH (HEAP, DISTRIBUTION = HASH (LAST_INVOICE_ID)) AS
	SELECT 
		PAYMENTPLANID,VIOLATOR_ID,VIDSEQ,LAST_INVOICE_ID,VBI_INVOICE_ID,VIOL_INVOICE_ID,PAYMENT_DATE,START_PAY_DATE, DefaultedDate, PaidInFullDate, BankruptcyDate, POS_ID, SPLIT_AMOUNT, VTOLL_AMOUNT, LATE_PAYMENT_FLAG, PMNT_BEFORE_Defaulted, PMNT_BEFORE_PaidInFull, PMNT_BEFORE_Bankruptcy, 
		DownPaymentReceived, FirstPaymentDate, SUM(SPLIT_AMOUNT) OVER (PARTITION BY PAYMENTPLANID ORDER BY PAYMENT_DATE, VIOL_INVOICE_ID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) PMNTS_Collected
	FROM ALL_PAYMENTS
OPTION (LABEL = 'FACT_TER_PAYMENT LOAD: Collected_PAYMENTS');

IF OBJECT_ID('EDW_TER.dbo.JOINT_PAYMENTS') IS NOT NULL DROP TABLE EDW_TER.dbo.JOINT_PAYMENTS
CREATE TABLE EDW_TER.dbo.JOINT_PAYMENTS WITH (HEAP, DISTRIBUTION = HASH (LAST_INVOICE_ID)) AS
	SELECT 
		PAYMENTPLANID,VIOLATOR_ID,VIDSEQ,LAST_INVOICE_ID,VBI_INVOICE_ID,VIOL_INVOICE_ID,PAYMENT_DATE,START_PAY_DATE, DefaultedDate, PaidInFullDate, BankruptcyDate, POS_ID, SPLIT_AMOUNT, VTOLL_AMOUNT, LATE_PAYMENT_FLAG, PMNT_BEFORE_Defaulted, PMNT_BEFORE_PaidInFull, PMNT_BEFORE_Bankruptcy,FirstPaymentDate,
		CASE
			WHEN SPLIT_AMOUNT < 0 THEN 0
			WHEN PAYMENT_DATE >= FirstPaymentDate THEN 0
			WHEN PMNTS_Collected <= DownPaymentReceived THEN SPLIT_AMOUNT 
			WHEN SPLIT_AMOUNT + DownPaymentReceived > PMNTS_Collected THEN SPLIT_AMOUNT + DownPaymentReceived - PMNTS_Collected 
			ELSE 0
		END AS DownPayment
	FROM Collected_PAYMENTS
OPTION (LABEL = 'FACT_TER_PAYMENT LOAD: JOINT_PAYMENTS');

IF OBJECT_ID('EDW_TER.dbo.INVOICE_PAYMENTS') IS NOT NULL DROP TABLE EDW_TER.dbo.INVOICE_PAYMENTS
CREATE TABLE EDW_TER.dbo.INVOICE_PAYMENTS WITH (HEAP, DISTRIBUTION = HASH (LAST_INVOICE_ID)) AS
	SELECT
		 P.PAYMENTPLANID 
		,P.VIOLATOR_ID
		,P.VIDSEQ
		,P.LAST_INVOICE_ID
		,P.VBI_INVOICE_ID
		,P.VIOL_INVOICE_ID
		,P.PAYMENT_DATE
		,CAST(CONVERT(VARCHAR(6), P.PAYMENT_DATE, 112) AS INT) AS PAYMENT_MTH
		,P.DefaultedDate
		,P.PaidInFullDate
		,P.BankruptcyDate
		,P.FirstPaymentDate
		,P.POS_ID
		,P.SPLIT_AMOUNT
		,P.VTOLL_AMOUNT
		,P.DownPayment
		,P.LATE_PAYMENT_FLAG
		,P.PMNT_BEFORE_Defaulted
		,P.PMNT_BEFORE_PaidInFull
		,P.PMNT_BEFORE_Bankruptcy
		,ROW_NUMBER() OVER (PARTITION BY P.VIOLATOR_ID,P.PAYMENT_DATE,P.VBI_INVOICE_ID,P.VIOL_INVOICE_ID,P.SPLIT_AMOUNT  ORDER BY P.LATE_PAYMENT_FLAG ASC, P.PAYMENTPLANID DESC, P.START_PAY_DATE DESC) RN
	FROM JOINT_PAYMENTS P
OPTION (LABEL = 'FACT_TER_PAYMENT LOAD: INVOICE_PAYMENTS');

IF OBJECT_ID('EDW_TER.dbo.FACT_TER_PAYMENT_STAGE') IS NOT NULL DROP TABLE EDW_TER.dbo.FACT_TER_PAYMENT_STAGE
--EXPLAIN
CREATE TABLE EDW_TER.dbo.FACT_TER_PAYMENT_STAGE WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH (LAST_INVOICE_ID)) AS
SELECT 
	 PAYMENTPLANID 									AS PAYMENTPLANID 
	,VIOLATOR_ID									AS VIOLATOR_ID
	,VIDSEQ											AS VIDSEQ
	,ISNULL(LAST_INVOICE_ID		, -1)				AS LAST_INVOICE_ID
	,ISNULL(VBI_INVOICE_ID		, -1)				AS VBI_INVOICE_ID
	,ISNULL(VIOL_INVOICE_ID		, -1)				AS VIOL_INVOICE_ID
	,ISNULL(PAYMENT_DATE,'1900-01-01')				AS PAYMENT_DATE
	,ISNULL(PAYMENT_MTH	, 190001)					AS PAYMENT_MTH
	,ISNULL(DefaultedDate,'1900-01-01')				AS DefaultedDate
	,ISNULL(PaidInFullDate,'1900-01-01')			AS PaidInFullDate
	,ISNULL(BankruptcyDate,'1900-01-01')			AS BankruptcyDate
	,ISNULL(FirstPaymentDate,'1900-01-01')			AS FirstPaymentDate
	,ISNULL(LATE_PAYMENT_FLAG	, 0)				AS LATE_PAYMENT_FLAG
	,ISNULL(PMNT_BEFORE_Defaulted,	'-1')			AS PMNT_BEFORE_Defaulted
	,ISNULL(PMNT_BEFORE_PaidInFull,	'-1')			AS PMNT_BEFORE_PaidInFull
	,ISNULL(PMNT_BEFORE_Bankruptcy,	'-1')			AS PMNT_BEFORE_Bankruptcy
	,ISNULL(POS_ID,	-1)								AS POS_ID
	,ISNULL(CAST(SPLIT_AMOUNT AS DECIMAL(10,2)), 0)	AS SPLIT_AMOUNT
	,ISNULL(CAST(VTOLL_AMOUNT AS DECIMAL(10,2)), 0)	AS VTOLL_AMOUNT
	,ISNULL(CAST(DownPayment AS DECIMAL(10,2)), 0)	AS DownPayment
FROM INVOICE_PAYMENTS
WHERE RN = 1
OPTION (LABEL = 'FACT_TER_PAYMENT LOAD');


--SELECT * FROM [dbo].FACT_TER_PAYMENT_STAGE

EXEC	EDW_RITE.dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT

CREATE STATISTICS STATS_FACT_TER_PAYMENT_000 ON [dbo].FACT_TER_PAYMENT_STAGE (LAST_INVOICE_ID)
CREATE STATISTICS STATS_FACT_TER_PAYMENT_001 ON [dbo].FACT_TER_PAYMENT_STAGE (VIOLATOR_ID,VIDSEQ)
CREATE STATISTICS STATS_FACT_TER_PAYMENT_002 ON [dbo].FACT_TER_PAYMENT_STAGE (PAYMENTPLANID)
CREATE STATISTICS STATS_FACT_TER_PAYMENT_003 ON [dbo].FACT_TER_PAYMENT_STAGE (VBI_INVOICE_ID)
CREATE STATISTICS STATS_FACT_TER_PAYMENT_004 ON [dbo].FACT_TER_PAYMENT_STAGE (VIOL_INVOICE_ID)
CREATE STATISTICS STATS_FACT_TER_PAYMENT_005 ON [dbo].FACT_TER_PAYMENT_STAGE (PAYMENT_MTH,PAYMENT_DATE)
CREATE STATISTICS STATS_FACT_TER_PAYMENT_006 ON [dbo].FACT_TER_PAYMENT_STAGE (LATE_PAYMENT_FLAG)
CREATE STATISTICS STATS_FACT_TER_PAYMENT_007 ON [dbo].FACT_TER_PAYMENT_STAGE (PMNT_BEFORE_Defaulted)
CREATE STATISTICS STATS_FACT_TER_PAYMENT_008 ON [dbo].FACT_TER_PAYMENT_STAGE (PMNT_BEFORE_PaidInFull)
CREATE STATISTICS STATS_FACT_TER_PAYMENT_009 ON [dbo].FACT_TER_PAYMENT_STAGE (PMNT_BEFORE_Bankruptcy)


IF OBJECT_ID('dbo.FACT_TER_PAYMENT_OLD')  IS NOT NULL DROP TABLE dbo.FACT_TER_PAYMENT_OLD;
IF OBJECT_ID('dbo.FACT_TER_PAYMENT')  IS NOT NULL RENAME OBJECT::dbo.FACT_TER_PAYMENT TO FACT_TER_PAYMENT_OLD;
RENAME OBJECT::dbo.FACT_TER_PAYMENT_STAGE TO FACT_TER_PAYMENT;
--IF OBJECT_ID('dbo.FACT_TER_PAYMENT_NEW')  IS NOT NULL DROP TABLE dbo.FACT_TER_PAYMENT_NEW;
--RENAME OBJECT::dbo.FACT_TER_PAYMENT_STAGE TO FACT_TER_PAYMENT_NEW;


SET @LOG_MESSAGE = 'Full load finished'
EXEC EDW_RITE.dbo.LOG_PROCESS @TABLE_NAME, @LOG_START_DATE, @LOG_MESSAGE, @ROW_COUNT

IF OBJECT_ID('EDW_TER.dbo.CTE_TER_INVOICES') IS NOT NULL DROP TABLE EDW_TER.dbo.CTE_TER_INVOICES
IF OBJECT_ID('EDW_TER.dbo.CTE_PMNTS_SUMMARY') IS NOT NULL DROP TABLE EDW_TER.dbo.CTE_PMNTS_SUMMARY
IF OBJECT_ID('EDW_TER.dbo.FOUND_PAYMENTS') IS NOT NULL DROP TABLE EDW_TER.dbo.FOUND_PAYMENTS
IF OBJECT_ID('EDW_TER.dbo.CTE_EXCUSED') IS NOT NULL DROP TABLE EDW_TER.dbo.CTE_EXCUSED
IF OBJECT_ID('EDW_TER.dbo.ALL_PAYMENTS') IS NOT NULL DROP TABLE EDW_TER.dbo.ALL_PAYMENTS
IF OBJECT_ID('EDW_TER.dbo.Collected_PAYMENTS') IS NOT NULL DROP TABLE EDW_TER.dbo.Collected_PAYMENTS
IF OBJECT_ID('EDW_TER.dbo.JOINT_PAYMENTS') IS NOT NULL DROP TABLE EDW_TER.dbo.JOINT_PAYMENTS
IF OBJECT_ID('EDW_TER.dbo.INVOICE_PAYMENTS') IS NOT NULL DROP TABLE EDW_TER.dbo.INVOICE_PAYMENTS

/**/


/*
SELECT COUNT_BIG(1) FROM edw_ter.dbo.FACT_TER_PAYMENT  ---2 498 826
SELECT COUNT_BIG(1) FROM edw_ter.dbo.FACT_TER_PAYMENT  ---2 307 725
SELECT
	I.VIOL_INVOICE_ID
	,SUM(P.SPLIT_AMOUNT) PAYMENT_PAID 
	,SUM(U.SPLIT_AMOUNT) UNIF_PIAD 
	,SUM(V.VIOL_INVOICE_AMT_PAID) VIOL_INVOICE_AMT_PAID
FROM (SELECT VIOL_INVOICE_ID FROM edw_ter.dbo.FACT_TER_INVOICE WHERE VIOL_INVOICE_ID > -1 AND INVOICE_STATUS = 'TS')  I
LEFT JOIN edw_ter.dbo.FACT_TER_PAYMENT/**/ P ON P.VIOL_INVOICE_ID = I.VIOL_INVOICE_ID 
LEFT JOIN edw_rite.dbo.FACT_UNIFIED_VIOLATION_INVOICE U ON U.VIOL_INVOICE_ID = I.VIOL_INVOICE_ID
LEFT JOIN EDW_RITE.dbo.FACT_VB_VIOL_INVOICES V ON V.VIOL_INVOICE_ID = I.VIOL_INVOICE_ID  
WHERE V.VIOL_INVOICE_AMT_PAID > 0 OR P.SPLIT_AMOUNT > 0 
GROUP BY I.VIOL_INVOICE_ID

SELECT
	I.VBI_INVOICE_ID
	,SUM(P.SPLIT_AMOUNT) PAYMENT_PAID 
	,SUM(U.SPLIT_AMOUNT) UNIF_PIAD 
	,SUM(V.VB_INVOICE_AMT_PAID) VB_INVOICE_AMT_PAID
FROM (SELECT VBI_INVOICE_ID FROM edw_ter.dbo.FACT_TER_INVOICE WHERE VBI_INVOICE_ID > -1 AND INVOICE_STATUS = 'TS')  I
LEFT JOIN edw_ter.dbo.FACT_TER_PAYMENT/**/ P ON P.VBI_INVOICE_ID = I.VBI_INVOICE_ID 
LEFT JOIN edw_rite.dbo.FACT_UNIFIED_VIOLATION_INVOICE U ON U.VBI_INVOICE_ID = I.VBI_INVOICE_ID
LEFT JOIN EDW_RITE.dbo.FACT_VB_VIOL_INVOICES V ON V.VBI_INVOICE_ID = I.VBI_INVOICE_ID  --AND V.VB_INVOICE_AMT_PAID > 0
WHERE V.VB_INVOICE_AMT_PAID > 0 OR P.SPLIT_AMOUNT > 0 
GROUP BY I.VBI_INVOICE_ID


SELECT * --P.VIOLATOR_ID, I.VIOLATOR_ID,P.VIDSEQ , I.VIDSEQ,P.VIOL_INVOICE_ID , I.VIOL_INVOICE_ID,P.VBI_INVOICE_ID , I.VBI_INVOICE_ID,P.PAYMENTPLANID , I.PAYMENTPLANID
FROM EDW_TER.dbo.FACT_TER_PAYMENT P 
FULL JOIN EDW_TER.dbo.FACT_TER_INVOICE I 
ON     P.VIOLATOR_ID = I.VIOLATOR_ID AND P.VIDSEQ = I.VIDSEQ AND P.VIOL_INVOICE_ID = I.VIOL_INVOICE_ID AND P.VBI_INVOICE_ID = I.VBI_INVOICE_ID AND P.PAYMENTPLANID = I.PAYMENTPLANID 
WHERE I.VIOLATOR_ID IS NULL

*/

