CREATE PROC [DBO].[FACT_TER_MONTH_LOAD] AS

IF (SELECT MAX([PARTITION_MONTH]) FROM EDW_TER.DBO.FACT_TER_MONTH) < (YEAR(getdate()) * 100 + MONTH(getdate()))
BEGIN

IF OBJECT_ID('dbo.FACT_TER_MONTH_STAGE')>0
	DROP TABLE dbo.FACT_TER_MONTH_STAGE

CREATE TABLE dbo.FACT_TER_MONTH_STAGE WITH (DISTRIBUTION = HASH([PARTITION_MONTH]), CLUSTERED COLUMNSTORE INDEX) 
AS 

SELECT   coalesce(pa11.ViolatorID, pa12.ViolatorID, pa13.ViolatorID) ViolatorID 
		,MAX(coalesce(pa11.TermDate, pa12.TermDate, pa13.TermDate)) TerminationMonth
		,coalesce(pa11.ActiveAgreementDate, pa12.ActiveAgreementDate, pa13.ActiveAgreementDate) TXN_DATE
		,coalesce(pa11.ActiveAgreementDate0, pa12.ActiveAgreementDate0, pa13.ActiveAgreementDate0) TXN_MTH
		,YEAR(getdate()) * 100 + MONTH(getdate()) AS [PARTITION_MONTH]
		,sum(pa11.WJXBFS1) InvoiceTollPaid
		,sum(pa12.WJXBFS1) PaymentAmount
		,NULL AS RemainingBalanceDue
		,sum(pa13.WJXBFS1) TransactionCount
		,sum(pa13.WJXBFS2) TransactionTollPaid
		--,getdate() AS INSERT_DATETIME

FROM (
	SELECT DISTINCT pa11.ViolatorID ViolatorID
	,TermDate
	,pa11.InvoiceExcusedDate ActiveAgreementDate
	,YEAR(pa11.InvoiceExcusedDate) * 100 + MONTH(pa11.InvoiceExcusedDate) AS ActiveAgreementDate0
	 ,sum(pa11.ViolationTollPaid) as WJXBFS1
FROM (
	SELECT a11.ViolatorID ViolatorID
		,a11.InvoiceTypeID InvoiceTypeID
		,a11.InvoiceStatusID InvoiceStatusID
		,a11.InvoiceExcusedDate InvoiceExcusedDate
		,a12.HvFlag HvFlag
		,a12.HvDate HvDate
		,a12.TermDate TermDate
		,sum(distinct a11.ViolationTollPaid) ViolationTollPaid
		,sum(distinct a11.InvoicePaidAmount) WJXBFS2
	FROM vw_FACT_VIOLATOR_INVOICE a11
	INNER JOIN vw_Violator a12 ON (
			a11.VidSeq = a12.VidSeq
			AND a11.ViolatorID = a12.ViolatorID
			)
	INNER JOIN vw_FACT_VIOLATOR_TRANSACTION a13 ON (
		a12.VidSeq = a13.VidSeq
		AND a12.ViolatorID = a13.ViolatorID
		--AND pa11.ViolatorID = a13.ViolatorID
		AND a13.TransactionPostDate = a11.InvoiceExcusedDate
		)
	AND a13.ViolationStatusID = 'T'
	AND a13.TransactionDate <= a12.HvDate
	WHERE 
	a11.InvoiceStatusID = 'TS'
	AND cast(a11.InvoiceExcusedDate as date) BETWEEN  DATEADD(DAY, 1, EOMONTH(GETDATE(), - 3)) AND EOMONTH(GETDATE(), - 2)
	AND ((a12.TermDate > = DATEADD(DAY, 1, EOMONTH(GETDATE(), - 3)) ) OR a12.TermDate = '1900-01-01')
	GROUP BY 
	     a11.ViolatorID
		,a11.InvoiceTypeID
		,a11.InvoiceStatusID
		,a11.InvoiceExcusedDate
		,a12.HvFlag
		,a12.HvDate
		,a12.TermDate
	) pa11
group by ViolatorID,InvoiceExcusedDate,TermDate
	) pa11
FULL JOIN (
	SELECT (pa11.ViolatorID) ViolatorID
		,pa11.TermDate TermDate
		,(pa11.ActiveAgreementDate) ActiveAgreementDate
		,(pa11.ActiveAgreementDate0) ActiveAgreementDate0
		,pa11.WJXBFS1 WJXBFS1
		--,pa12.WJXBFS1 WJXBFS2
	FROM (
		SELECT a11.ViolatorID ViolatorID
			,a12.TermDate
			,a11.PaymentTransactionDate ActiveAgreementDate
			,YEAR(a11.PaymentTransactionDate) * 100 + MONTH(a11.PaymentTransactionDate) ActiveAgreementDate0
			,sum(a11.PaymentTransactionAmount) WJXBFS1
		FROM vw_FACT_VIOLATOR_PAYMENT a11
		INNER JOIN vw_Violator a12 ON (
				a11.VidSeq = a12.VidSeq
				AND a11.ViolatorID = a12.ViolatorID
				)
		WHERE a11.PaymentTransactionDate >= '2014-01-01'
			--AND a11.violatorid = 750440189
			AND cast(a11.PaymentTransactionDate as date) BETWEEN DATEADD(DAY, 1, EOMONTH(GETDATE(), - 3))
				AND EOMONTH(GETDATE(), - 2)
		GROUP BY a11.ViolatorID
			,a12.TermDate
			,a11.PaymentTransactionDate
			,YEAR(a11.PaymentTransactionDate) * 100 + MONTH(a11.PaymentTransactionDate)
			--ORDER BY a11.ViolatorID
		) pa11
	) pa12 ON (
		pa11.ActiveAgreementDate = pa12.ActiveAgreementDate
		AND pa11.ViolatorID = pa12.ViolatorID
		--AND pa11.TermDate = pa12.TermDate
		)
FULL JOIN (
	SELECT a11.ViolatorID ViolatorID
		,a12.TermDate
		,a11.TransactionPostDate ActiveAgreementDate
		,YEAR(a11.TransactionPostDate) * 100 + MONTH(a11.TransactionPostDate) ActiveAgreementDate0
		,count(a11.TransactionID) WJXBFS1
		,sum(a11.ViolationTollPaid) WJXBFS2
	FROM vw_FACT_VIOLATOR_TRANSACTION a11
	INNER JOIN vw_Violator a12 ON (
			a11.VidSeq = a12.VidSeq
			AND a11.ViolatorID = a12.ViolatorID
			)
	--INNER JOIN system_day a13 ON (a12.TermDate = a13.cal_day_bgn)
	WHERE (
			a11.ViolationOrTollID IN ('T')
			AND a11.TransactionPostDate >= '2014-01-01'
			)
		--AND a11.violatorid = 753599551
		AND cast(a11.TransactionPostDate as date) BETWEEN DATEADD(DAY, 1, EOMONTH(GETDATE(), - 3)) AND EOMONTH(GETDATE(), - 2)
	GROUP BY a11.ViolatorID
		,a12.TermDate
		,a11.TransactionPostDate
		,YEAR(a11.TransactionPostDate) * 100 + MONTH(a11.TransactionPostDate)
	) pa13 ON (
		coalesce(pa11.ActiveAgreementDate, pa12.ActiveAgreementDate) = pa13.ActiveAgreementDate
		AND coalesce(pa11.ViolatorID, pa12.ViolatorID) = pa13.ViolatorID
		AND coalesce(pa11.TermDate, pa12.TermDate) = pa13.TermDate
		)
group by
         coalesce(pa11.ViolatorID, pa12.ViolatorID, pa13.ViolatorID)  
		,coalesce(pa11.ActiveAgreementDate0, pa12.ActiveAgreementDate0, pa13.ActiveAgreementDate0) 
		,coalesce(pa11.ActiveAgreementDate, pa12.ActiveAgreementDate, pa13.ActiveAgreementDate) 
union

	SELECT ViolatorID
			,'1900-01-01' AS TerminationMonth
			,ActiveAgreementDate as TXN_DATE
			,YEAR(ActiveAgreementDate) * 100 + MONTH(ActiveAgreementDate) as TXN_MTH
			,YEAR(GETDATE()) * 100 + MONTH(GETDATE()) as PARTITION_MTH
			,NULL InvoiceTollPaid
			,NULL PaymentAmount
			,sum(CAST(RemainingBalanceDue AS DECIMAL(10, 2))) RemainingBalanceDue
			,NULL TransactionCount
			,NULL TransactionTollPaid
		FROM LND_TER.dbo.PaymentPlan P
		INNER JOIN LND_TER.[dbo].[PaymentPlanViolator] PPV ON P.[PaymentPlanID] = PPV.[PaymentPlanID]
			AND [PaymentPlanViolatorSeq] = 1
		INNER JOIN LND_TER.dbo.PaymentPlanStatusLookup LS ON P.PaymentPlanStatusLookupID = LS.PaymentPlanStatusLookupID
			AND LS.Descr NOT LIKE 'Quote%'
			AND ActiveAgreementDate > '2013-12-31'
			AND P.DeletedFlag = 0
			AND cast(ActiveAgreementDate as date) BETWEEN DATEADD(DAY, 1, EOMONTH(GETDATE(), - 3)) AND EOMONTH(GETDATE(), - 2)
		GROUP BY violatorid
			,ActiveAgreementDate
			,YEAR(ActiveAgreementDate)
			,MONTH(ActiveAgreementDate) --  

-- Final insert
-- UPDATE CURRENT INDICATOR
UPDATE EDW_TER.DBO.FACT_TER_MONTH
SET CURR_IND = 0

INSERT EDW_TER.DBO.FACT_TER_MONTH
SELECT 
VIOLATORID
,cast(year([TerminationMonth]) as varchar(4)) + '-' + convert(char(3), [TerminationMonth], 0) as [Termination_Month] 
--,TXN_DATE
,case when ([TerminationMonth] = '1900-01-01' OR [TerminationMonth] is null) then 19000101 else year([TERMINATIONMONTH]) * 10000 + month([TERMINATIONMONTH]) * 100 + 1 end as TERMINATION_DAY_ID
,[TerminationMonth] AS TERMINATION_DATE
,CAST(year(TXN_DATE) AS VARCHAR(4)) + '-' + UPPER(LEFT(DATENAME(MONTH,TXN_DATE),3)) AS TXN_MTH
,year(TXN_DATE) * 10000 + month(TXN_DATE) * 100 + 1 as TXN_DAY_ID
,PARTITION_MONTH
,1 AS CURR_IND
,sum(INVOICETOLLPAID) as INVOICE_TOLL_PAID
,sum(PAYMENTAMOUNT) as PAYMENT_AMOUNT
,sum(REMAININGBALANCEDUE) as REMAINING_BALANCE_DUE
,sum(TransactionCount) as TXN_CNT
,sum(TRANSACTIONTOLLPAID) as TXN_TOLL_PAID 
from DBO.FACT_TER_MONTH_STAGE
GROUP BY
VIOLATORID
,[TerminationMonth]
,CAST(year(TXN_DATE) AS VARCHAR(4)) + '-' + UPPER(LEFT(DATENAME(MONTH,TXN_DATE),3))
,year(TXN_DATE) * 10000 + month(TXN_DATE) * 100 + 1
,PARTITION_MONTH

IF OBJECT_ID('dbo.FACT_TER_MONTH_STAGE')>0
	DROP TABLE dbo.FACT_TER_MONTH_STAGE

END

