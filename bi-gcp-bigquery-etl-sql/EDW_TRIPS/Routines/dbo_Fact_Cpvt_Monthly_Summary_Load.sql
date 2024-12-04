CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_Cpvt_Monthly_Summary_Load`()
BEGIN
/*

Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load Fact_cpvt_monthly_summary. This query was created by Bhanu, passed on to Gouthami, and is now being automated without any code changes.
-------------------------------------------------------------------------------------------------------------------
As of today, an ETL team member executes specific SQL scripts to extract raw data. This data is then formatted and aggregated before being emailed to Shayan each month. Shayan compiles these numbers into a final report for Jeff, which is subsequently sent to the board members. The CPVT amounts are recorded based on the edw_updatedate, reflecting data as of the edw_updatedate for the previous month (the job runs every 2nd of the month). If the job runs again within the same month, the data for the previous month will be updated according to the new run date. If the job runs for a new month, a new row with data will be inserted
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
SPLTSK0034729 	Dhanush	2024-09-25	New!


===================================================================================================================

*/
DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_Cpvt_Monthly_Summary_Load';
DECLARE log_start_date DATETIME; 
DECLARE log_message STRING; 
DECLARE trace_flag INT64 DEFAULT 0;
BEGIN 
DECLARE ROW_COUNT INT64;
SET log_start_date = current_datetime('America/Chicago'); 
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Fact_Cpvt_Monthly_Summary Started loading', 'I', CAST(NULL AS INT64), CAST(NULL AS STRING));

--=============================================================================================================
-- Load Fact_cpvt_monthly_summary
--=============================================================================================================


Merge Into `EDW_TRIPS.Fact_Cpvt_Monthly_Summary` l
USING ( 

---------------------------------------------------------------------------
--TOLL Payments, Toll Reversal Payments,Toll Void Payments
--Payments for tolls are selected from EDW_TRIPS.Fact_PaymentDetail.
--These payments pertain to violators from the RITE system i.e. EDW_TER.DIM_VIOLATOR
---------------------------------------------------------------------------
With cte1 as (
  SELECT CASE 
		WHEN RefPaymentID = 0
			AND P.PaymentStatusID IN (
				109
				,119
				,3182
				)
			THEN 'tollpayment'
		WHEN RefPaymentStatusID = 119
			AND P.PaymentStatusID = 109
			THEN 'tollreversalpayment'
		WHEN RefPaymentStatusID = 3182
			AND P.PaymentStatusID = 109
			THEN 'tollvoidpayment'
		ELSE 'Unknown'
		END as type
	,FORMAT_TIMESTAMP('%Y%m', TxnPaymentDate) AS monthid
	,SUM(P.AmountReceived) amount
FROM (
	SELECT DISTINCT violatorid
		,MIN(hvdate) HVDATE
	FROM `EDW_TER.Dim_Violator` -- All RITE violators. Some of them will be in TRIPS as well
	GROUP BY violatorid
	) HV
JOIN `LND_TBOS.TollPlus_TP_ViolatedTrips` T ON T.violatorid = HV.violatorid
JOIN (
	SELECT CitationID
		,RefPaymentID
		,PaymentStatusID
		,RefPaymentStatusID
		,TxnPaymentDate
		,sum(AmountReceived) AmountReceived
	FROM EDW_TRIPS.Fact_PaymentDetail
	GROUP BY CitationID
		,RefPaymentID
		,PaymentStatusID
		,TxnPaymentDate
		,RefPaymentStatusID
	) P ON P.CitationID = T.CitationID
	AND cast(TxnPaymentDate AS DATE) >= HVDATE
  WHERE CAST(TxnPaymentDate AS DATE) BETWEEN 
  DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH) AND 
  LAST_DAY(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
GROUP BY CASE 
		WHEN RefPaymentID = 0
			AND P.PaymentStatusID IN (
				109
				,119
				,3182
				)
			THEN 'tollpayment'
		WHEN RefPaymentStatusID = 119
			AND P.PaymentStatusID = 109
			THEN 'tollreversalpayment'
		WHEN RefPaymentStatusID = 3182
			AND P.PaymentStatusID = 109
			THEN 'tollvoidpayment'
		ELSE 'Unknown'
		END
		,FORMAT_TIMESTAMP('%Y%m', TxnPaymentDate)
    UNION ALL
    ---------------------------------------------------------------------------
-- Toll Payments, Toll Reversal Payments,Toll Void Payments 
-- Payments from EDW_TRIPS.Fact_PaymentDetail for Violators that are ONLY in TRIPS	
---------------------------------------------------------------------------
    SELECT CASE
           WHEN RefPaymentID = 0
                AND P.PaymentStatusID IN ( 109, 119, 3182 ) THEN
               'tollpayment'
           WHEN RefPaymentStatusID = 119
                AND P.PaymentStatusID = 109 THEN
               'tollreversalpayment'
           WHEN RefPaymentStatusID = 3182
                AND P.PaymentStatusID = 109 THEN
               'tollvoidpayment'
           ELSE
               'Unknown'
       END as type
	   ,FORMAT_TIMESTAMP('%Y%m', TxnPaymentDate) AS monthid
	   ,SUM(P.AmountReceived) amount
FROM
(SELECT ViolatorID,MIN(HVDesignationDate) HVDesignationDate FROM  LND_TBOS.TER_HabitualViolators WHERE ViolatorID NOT IN
(SELECT DISTINCT VIOLATORID FROM EDW_TER.DIM_VIOLATOR) GROUP BY ViolatorID) HV
    JOIN LND_TBOS.TollPlus_TP_ViolatedTrips T
        ON T.ViolatorID = HV.VIOLATORID
JOIN (
	SELECT CitationID
		,RefPaymentID
		,PaymentStatusID
		,RefPaymentStatusID
		,TxnPaymentDate
		,sum(AmountReceived) AmountReceived
	FROM EDW_TRIPS.Fact_PaymentDetail
	GROUP BY CitationID
		,RefPaymentID
		,PaymentStatusID
		,TxnPaymentDate
		,RefPaymentStatusID
	) P ON P.CitationID = T.CitationID
		AND cast(TxnPaymentDate as date) >= HVDesignationDate
           AND 
             CAST(TxnPaymentDate AS DATE) BETWEEN 
  DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH) AND 
  LAST_DAY(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
           
group by CASE
           WHEN RefPaymentID = 0
                AND P.PaymentStatusID IN ( 109, 119, 3182 ) THEN
               'tollpayment'
           WHEN RefPaymentStatusID = 119
                AND P.PaymentStatusID = 109 THEN
               'tollreversalpayment'
           WHEN RefPaymentStatusID = 3182
                AND P.PaymentStatusID = 109 THEN
               'tollvoidpayment'
           ELSE
               'Unknown'
       END 
	   ,FORMAT_TIMESTAMP('%Y%m', TxnPaymentDate)),


---------------------------------------------------------------------------
-- Fee Payments,Fee reversal payments,Fee void payments 
-- Payments from EDW_TRIPS.Fact_PaymentDetail for Violators that are in RITE.
-- These are in TRIPS also.
-- The above comment is by Shekhar wile working with Gouthami (2/8/2024)
----P FEES (THE Query can be very straight forward but there were duplicates Issue)-----Final Version <== This comment by Bhanu
---------------------------------------------------------------------------
cte2 as (

SELECT CASE 
		WHEN RefPaymentID = 0
			AND P.PaymentStatusID IN (
				109
				,119
				,3182
				)
			THEN 'feepayment'
		WHEN RefPaymentStatusID = 119
			AND P.PaymentStatusID = 109
			THEN 'feereversalpayment'
		WHEN RefPaymentStatusID = 3182
			AND P.PaymentStatusID = 109
			THEN 'feevoidpayment'
		ELSE 'Unknown'
		END as type
		,FORMAT_TIMESTAMP('%Y%m', TxnPaymentDate) AS monthid
		,ROUND(SUM(FeesPaid),2) as amount
FROM
(
    SELECT DISTINCT
           IL.ReferenceInvoiceID,
           HV.HVDATE
    FROM
    (
        SELECT DISTINCT
               VIOLATORID,
               MIN(HVDATE) HVDATE
        FROM EDW_TER.DIM_VIOLATOR -- RITE Violators
		GROUP BY VIOLATORID
    ) HV
        JOIN LND_TBOS.TollPlus_TP_ViolatedTrips T
            ON T.ViolatorID = HV.VIOLATORID
               --AND CAST(T.ExitTripDateTime AS DATE) >= HV.HVDATE --AND ISNULL(CAST(HV.HVTerminationDate AS DATE), '2900-01-01')
        JOIN LND_TBOS.TollPlus_Invoice_LineItems IL
            ON T.CitationID = IL.LinkID
               AND IL.LinkID > 0
               AND IL.LinkSourceName = 'TOLLPLUS.TP_ViolatedTrips'
) A
    JOIN
    (
        SELECT DISTINCT
               ReferenceInvoiceID,
               InvoiceID
        FROM LND_TBOS.TollPlus_Invoice_LineItems
        WHERE LinkSourceName = 'TollPlus.Invoice_Charges_Tracker'
    ) ILN
        ON ILN.ReferenceInvoiceID = A.ReferenceInvoiceID
JOIN (
	SELECT InvoiceNumber
		,RefPaymentID
		,PaymentStatusID
		,RefPaymentStatusID
		,TxnPaymentDate
		,ROUND(sum(FNFeesPaid+SNFeesPaid),2) FeesPaid
	FROM EDW_TRIPS.Fact_PaymentDetail
	GROUP BY InvoiceNumber
		,RefPaymentID
		,PaymentStatusID
		,TxnPaymentDate
		,RefPaymentStatusID
	) P ON Cast(P.InvoiceNumber as STRING) = A.referenceinvoiceid 
	AND cast(TxnPaymentDate as date) >= HVDATE
           AND   CAST(TxnPaymentDate AS DATE) BETWEEN 
  DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH) AND 
  LAST_DAY(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
					 Group By CASE 
		WHEN RefPaymentID = 0
			AND P.PaymentStatusID IN (
				109
				,119
				,3182
				)
			THEN 'feepayment'
		WHEN RefPaymentStatusID = 119
			AND P.PaymentStatusID = 109
			THEN 'feereversalpayment'
		WHEN RefPaymentStatusID = 3182
			AND P.PaymentStatusID = 109
			THEN 'feevoidpayment'
		ELSE 'Unknown'
		END
		,CAST(FORMAT_TIMESTAMP('%Y%m', TxnPaymentDate) AS STRING)

UNION ALL

---------------------------------------------------------------------------
-- Fee Payments,Fee reversal payment,Fee Void payment
-- Payments from EDW_TRIPS.dbo.Fact_PaymentDetail for Violators that are NOT in RITE. 
-- i.e ONLY in TRIPS
---------------------------------------------------------------------------
SELECT CASE 
		WHEN RefPaymentID = 0
			AND P.PaymentStatusID IN (
				109
				,119
				,3182
				)
			THEN 'feepayment'
		WHEN RefPaymentStatusID = 119
			AND P.PaymentStatusID = 109
			THEN 'feereversalpayment'
		WHEN RefPaymentStatusID = 3182
			AND P.PaymentStatusID = 109
			THEN 'feevoidpayment'
		ELSE 'Unknown'
		END type
		,CAST(FORMAT_TIMESTAMP('%Y%m', TxnPaymentDate) AS STRING) as monthid
		,ROUND(SUM(FeesPaid),2) amount
FROM
(
    SELECT DISTINCT
           IL.ReferenceInvoiceID,
           HV.HVDATE
    FROM
    (
SELECT ViolatorID,
       MIN(HVDesignationDate) HVDATE
FROM LND_TBOS.TER_HabitualViolators
WHERE ViolatorID NOT IN
      (
          SELECT DISTINCT VIOLATORID FROM EDW_TER.DIM_VIOLATOR
      )
GROUP BY ViolatorID    ) HV
        JOIN LND_TBOS.TollPlus_TP_ViolatedTrips T
            ON T.ViolatorID = HV.VIOLATORID
               --AND CAST(T.ExitTripDateTime AS DATE) >= HV.HVDATE --AND ISNULL(CAST(HV.HVTerminationDate AS DATE), '2900-01-01')
        JOIN LND_TBOS.TollPlus_Invoice_LineItems IL
            ON T.CitationID = IL.LinkID
               AND IL.LinkID > 0
               AND IL.LinkSourceName = 'TOLLPLUS.TP_ViolatedTrips'
) A
    JOIN
    (
        SELECT DISTINCT
               ReferenceInvoiceID,
               InvoiceID
        FROM LND_TBOS.TollPlus_Invoice_LineItems
        WHERE LinkSourceName = 'TollPlus.Invoice_Charges_Tracker'
    ) ILN
        ON ILN.ReferenceInvoiceID = A.ReferenceInvoiceID
JOIN (
	SELECT InvoiceNumber
		,RefPaymentID
		,PaymentStatusID
		,RefPaymentStatusID
		,TxnPaymentDate
		,ROUND(sum(FNFeesPaid+SNFeesPaid),2) FeesPaid
	FROM EDW_TRIPS.Fact_PaymentDetail
	GROUP BY InvoiceNumber
		,RefPaymentID
		,PaymentStatusID
		,TxnPaymentDate
		,RefPaymentStatusID
	) P ON Cast(P.InvoiceNumber as STRING) = A.ReferenceInvoiceID
		AND cast(TxnPaymentDate as date) >= HVDATE
           AND   CAST(TxnPaymentDate AS DATE) BETWEEN 
  DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH) AND 
  LAST_DAY(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
Group By CASE 
		WHEN RefPaymentID = 0
			AND P.PaymentStatusID IN (
				109
				,119
				,3182
				)
			THEN 'feepayment'
		WHEN RefPaymentStatusID = 119
			AND P.PaymentStatusID = 109
			THEN 'feereversalpayment'
		WHEN RefPaymentStatusID = 3182
			AND P.PaymentStatusID = 109
			THEN 'feevoidpayment'
		ELSE 'Unknown'
		END
	,CAST(FORMAT_TIMESTAMP('%Y%m', TxnPaymentDate) AS STRING)),
	-- V & T
	ExcludedViolators AS (
  SELECT DISTINCT HV.VIOLATORID
  FROM `EDW_TER.Fact_Ter_Ttxn_Accounts` HV
),
---------------------------------------------------------------------------
--Tolls & VTolls
-- The below SQL requires SANDBOX.dbo.FACT_TER_TTXN_ACCOUNTS. It is generated from the RITE data.
-- This table is static and named EDW_TER.Fact_Ter_Ttxn_Accounts in BQ
-- It has customers that have not been migrated to TRIPS
---------------------------------------------------------------------------
cte3 as
( Select CAST(FORMAT_TIMESTAMP('%Y-%m-%d', CURRENT_TIMESTAMP()) AS STRING) AS RunDate, PostedMonth,
CASE
           WHEN TransactionPostingType = 'Prepaid AVI' THEN
               'tolls'
           ELSE
               'vtolls'
       END CATEGORY,
       SUM(   CASE
                  WHEN AmountReceived < 0 THEN
                      AmountReceived * -1
                  ELSE
                      AmountReceived
              END
          ) AmountReceived
FROM
(
    SELECT ROW_NUMBER() OVER (PARTITION BY TC.CustTripID
                              ORDER BY ASSIGNED_DATE DESC,
                                       HVDATE DESC,
                                       VIOLATORID DESC,
                                       VIDSEQ DESC
                             ) AS RN,
           TC.customerid,
           TCT.amountreceived,
           TC.tollamount,
           TC.custtripid,
           TC.transactionpostingtype,
                                   CAST(FORMAT_TIMESTAMP('%Y%m', TC.posteddate) AS STRING) AS PostedMonth--select count(*)
    FROM EDW_TER.Fact_Ter_Ttxn_Accounts HV -- SANDBOX.dbo.FACT_TER_TTXN_ACCOUNTS HV
        JOIN LND_TBOS.TollPlus_TP_CustomerTrips TC 
            ON TC.vehiclenumber = HV.lic_plate
               AND TC.vehiclestate = HV.lic_state
               AND TC.tagrefid = HV.tag_id
        JOIN LND_TBOS.TollPlus_TP_Customer_Trip_Receipts_Tracker TCT
            ON TCT.custtripid = TC.custtripid
        JOIN  LND_TBOS.TollPlus_TP_Customer_Vehicles TCV
             ON TCV.vehicleid = TC.vehicleid --AND TCV.CustomerID = hv.ViolatorID
             AND TCT.linksourcename = 'TOLLPLUS.TP_CUSTOMERTRIPS'             
             AND  CAST(TC.posteddate AS DATE) BETWEEN 
  DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH) AND 
  LAST_DAY(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
             AND TC.transactionpostingtype NOT IN ('IOP Fleet','IOP AVI','NTTA FLEET') 
             AND TC.transactionpostingtype IS NOT NULL 
) A
WHERE A.RN = 1
GROUP BY PostedMonth,CASE
           WHEN TransactionPostingType = 'Prepaid AVI' THEN
               'tolls'
           ELSE
               'vtolls'
       END 
                   
UNION ALL
---------------------------------------------------------------------------
--Tolls & VTolls
-- The below SQL is to pull T & V numbers for Trips customers
-- (migrated from RITE as well as new in TRIPS)
---------------------------------------------------------------------------

 
SELECT
  CAST(FORMAT_TIMESTAMP('%Y-%m-%d', CURRENT_TIMESTAMP()) AS STRING) AS RunDate,
  PostedMonth,
  A.CATEGORY,
  SUM(A.AmountReceived) AS AmountReceived
FROM (
  SELECT
    CASE
      WHEN TransactionPostingType = 'Prepaid AVI' THEN 'tolls'
      ELSE 'vtolls'
    END AS CATEGORY,
    TCP.PostedDate,
    TCP.TpTripID,
    TCP.CustTripID,
    CAST(FORMAT_TIMESTAMP('%Y%m', TCP.PostedDate) AS STRING) AS PostedMonth,
    SUM(
      CASE
        WHEN AmountReceived < 0 THEN AmountReceived * -1
        ELSE AmountReceived
      END
    ) AS AmountReceived
  FROM
    `LND_TBOS.TER_HabitualViolators` HV
  JOIN
    `LND_TBOS.TollPlus_TP_Customers` TC
    ON HV.ViolatorID = TC.CustomerID
  LEFT JOIN
    ExcludedViolators EV
    ON HV.ViolatorID = EV.VIOLATORID
  JOIN
    `LND_TBOS.TollPlus_TP_CustomerTrips` TCP
    ON TCP.CustomerID = TC.RegCustRefID
  JOIN
    `LND_TBOS.TollPlus_TP_Customer_Trip_Receipts_Tracker` TCT
    ON TCT.CustTripID = TCP.CustTripID
  JOIN
    `LND_TBOS.TollPlus_TP_Customer_Vehicles` TCV
    ON TCV.VehicleID = HV.VehicleID
    AND TCV.CustomerID = HV.ViolatorID
    AND LinkSourceName = 'TOLLPLUS.TP_CUSTOMERTRIPS'
  WHERE
    EV.VIOLATORID IS NULL  -- Ensuring violators are not in the excluded list
    AND CAST(TCP.PostedDate AS DATE) BETWEEN 
  DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH) AND 
  LAST_DAY(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
    AND TCP.TransactionPostingType NOT IN ('IOP Fleet', 'IOP AVI', 'NTTA FLEET')
    AND TCP.TransactionPostingType IS NOT NULL
  GROUP BY
    CASE
      WHEN TransactionPostingType = 'Prepaid AVI' THEN 'tolls'
      ELSE 'vtolls'
    END,
    TCP.PostedDate,
    TCP.TpTripID,
    TCP.CustTripID,
    CAST(FORMAT_TIMESTAMP('%Y-%m', TCP.PostedDate) AS STRING)
  HAVING TCP.PostedDate >= MIN(HV.HVDesignationDate)
) A
GROUP BY
  A.CATEGORY,
  A.PostedMonth
),
---------------------------------------------------------------------------
--cte5 represents the union all of records type.
--cte1 represents the Toll Payment amounts
--cte2 represents the Fee Payment amounts
--cte3 represents the Vtolls & Tolls
---------------------------------------------------------------------------

cte5 as (
Select cast(monthid as INT64) as monthid,type,sum(amount) as amount from cte2 group by monthid,type
UNION All
Select cast(monthid as INT64) as monthid,type,sum(amount) as amount from cte1 group by monthid,type
UNION ALL
select cast(PostedMonth as INT64) as monthid, Category as type, sum(AmountReceived) amount
from cte3 group by  monthid,type
UNION ALL 
---------------------------------------------------------------------------
--Committments
-- We add the remainingBalance on all payment plans that were created last month
---------------------------------------------------------------------------
SELECT C.ActiveAgreementMonth as monthid,
       "commitments" as type,
       SUM(C.Committments) AS amount
FROM
(

    SELECT CAST(FORMAT_TIMESTAMP('%Y%m', TIMESTAMP(ActiveAgreementDate)) AS INT) AS ActiveAgreementMonth,
           Q.paymentplanid,
           MAX(RemainingBalance) AS Committments
    FROM
    (
        SELECT PP.paymentplanid,
               PP.startdate AS ActiveAgreementDate,
               PP.balancedue AS RemainingBalance,
               PP.totalsettlementamount,
               PP.totalreceived AS PaymentReceived
        FROM LND_TBOS.TER_PaymentPlans PP
    WHERE CAST(PP.startdate AS DATE) BETWEEN 
  DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH) AND 
  LAST_DAY(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
        --WHERE  Cast(PP.startdate as DATE) BETWEEN '2024-08-01' AND '2024-08-31'  
        --Change This data before running
    ) Q
    GROUP BY Q.paymentplanid,
             CAST(FORMAT_TIMESTAMP('%Y%m', TIMESTAMP(ActiveAgreementDate)) AS INT)
) C
GROUP BY C.ActiveAgreementMonth)

---------------------------------------------------------------------------
--Pivoting table to structure into landing table
---------------------------------------------------------------------------
Select * from cte5 PIVOT (
  Sum(amount) for type IN (
'commitments',
'feereversalpayment',
'tollreversalpayment',
'feevoidpayment',
'tollvoidpayment',
'feepayment',
'tollpayment',
'tolls',
'vtolls'

  )
) order by monthid) s
on l.monthid=s.monthid
---------------------------------------------------------------------------
--When monthid matched, update all records.
---------------------------------------------------------------------------
WHEN MATCHED THEN
UPDATE SET l.commitments=Cast(s.commitments as NUMERIC),
l.feereversalpayment=Cast(s.feereversalpayment as NUMERIC),
l.tollreversalpayment=Cast(s.tollreversalpayment as NUMERIC),
l.tollpayment=Cast(s.tollpayment as NUMERIC),
l.feevoidpayment=Cast(s.feevoidpayment as NUMERIC),
l.tollvoidpayment=Cast(s.tollvoidpayment as NUMERIC),
l.feepayment=Cast(s.feepayment AS NUMERIC),
l.tolls=Cast(s.tolls as NUMERIC),
l.vtolls=Cast(s.vtolls as NUMERIC),
l.edw_updatedate=CURRENT_DATETIME()

---------------------------------------------------------------------------
--When monthid not matched, insert all records.
---------------------------------------------------------------------------

WHEN NOT MATCHED THEN
INSERT(monthid,
commitments,
feereversalpayment,
tollreversalpayment,
feevoidpayment,
tollvoidpayment,
feepayment,
tollpayment,
tolls,
vtolls,
edw_updatedate)
VALUES (s.monthid,
Cast(s.commitments as NUMERIC),
Cast(s.feereversalpayment as NUMERIC),
Cast(s.tollreversalpayment as NUMERIC),
Cast(s.feevoidpayment as NUMERIC),
Cast(s.tollvoidpayment as NUMERIC),
Cast(s.feepayment as NUMERIC),
Cast(s.tollpayment as NUMERIC),
Cast(s.tolls as NUMERIC),
Cast(s.vtolls as NUMERIC),
CURRENT_DATETIME() );

SET log_message = 'Fact_Cpvt_Monthly_Summary_Load Complete'; 
CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL AS STRING));	



EXCEPTION WHEN ERROR THEN BEGIN DECLARE error_message STRING DEFAULT @@error.message;

     CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL AS INT64), CAST(NULL AS STRING));
     RAISE USING MESSAGE = error_message; -- ReThrow the error !

END;
END;
END;