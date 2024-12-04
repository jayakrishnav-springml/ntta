CREATE OR REPLACE PROCEDURE EDW_TRIPS.Fact_PaymentPlan_Full_Load()
BEGIN
/*
-------------------------------------------------------------------------------------------------------------------
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_PaymentPlan table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0043223    Gouthami	2023-05-08	Created
CHG0043356    Sagarika  2023-07-14  Data has Fixed to pull paymentplans created after 2021-01-01. 
CHGXXXXXX	  Shekhar	2023-07-26	Eliminated the join with Habitualviolator to pull Payment plans that does 
									have HVID present in the PaymentPlanViolator. This join is not needed
CHG0044321    Gouthami  2024-01-08  1. Changed this table from Dim to Fact
									2. Added Transaction and Invoice count for a paymentplan as per Randall's
									   request.
CHG0044527	  Gouthami	2024-02-08	1. Removed the filter to bring payment plans only after 2021
									2. We need paymentplans prior to 2021 which are Active/Defaulted/PaidInFull for
										Collections.
									2. Did not pull the data (NoOfInvoices, NoOfTransactions) for those paymentplans 
										which have some migration issues.
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_PaymentPlan_Full_Load

EXEC Utility.FromLog 'dbo.Fact_PaymentPlan', 1
SELECT TOP 100 'dbo.Fact_PaymentPlan' Table_Name, * FROM dbo.Fact_PaymentPlan ORDER BY 2
-------------------------------------------------------------------------------------------------------------------
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_PaymentPlan_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);
      --=============================================================================================================
      -- Load EDW_TRIPS.Fact_PaymentPlan
      --=============================================================================================================
      CREATE TEMPORARY TABLE cte_inv 
      AS 
        (
          SELECT
              ppv.violatorid AS customerid,
              pp.paymentplanid,
              ppv.mbsid,
              fi.vehicleid,
              sum(
                CASE
                    WHEN fi.firstpaymentdate >= CAST( pp.startdate as DATE) -- Consider invoices having first payment date on/after paymentplan start date
                      OR fi.firstpaymentdate >= CAST( pp.downpaymentdate as DATE) -- Consider invoices having first payment date on/after paymentplan downpayment date
                      --- There could be payments only on fees after the paymentplan is taken. Considering payments that are applied to fees after paymentplan start date
                      OR (CAST(coalesce(fi.firstfeepaymentdate, '1900-01-01') as DATE) >= CAST( pp.startdate as DATE) /*MBSID 1201119196*/
                      OR CAST(coalesce(fi.lastfeepaymentdate, '1900-01-01') as DATE) >= CAST( pp.startdate as DATE)/*MBSID 1265381393*/)-- MBSID 1256540746
                      AND (fi.firstpaymentdate <> '1900-01-01'
                      OR fi.firstpaymentdate IS NOT NULL) 
                    THEN 1
                    -- Consider invoices having Last payment date on/after paymentplan start date. First payment date could be prior to paymentplan start date
                    WHEN (fi.lastpaymentdate >= CAST( pp.startdate as DATE)

                      OR fi.lastpaymentdate >= CAST( pp.downpaymentdate as DATE))
                      AND (fi.lastpaymentdate <> '1900-01-01'
                      OR fi.lastpaymentdate IS NOT NULL) 
                    THEN 1
                    -- Do not consider invoices having first/Last payment dates prior to paymentplan start date for Vtoll invoices
                    WHEN (fi.firstpaymentdate < CAST( pp.startdate as DATE)
                      OR fi.lastpaymentdate < CAST( pp.startdate as DATE))
                      AND fi.edw_invoicestatusid = 99999 
                    THEN CAST(NULL as INT64)
                      -- Consider invoices that are partial paid prior to paymentplan start date. There are can be payments after the payment plan is taken for partial invoices.
                    WHEN (fi.firstpaymentdate < CAST( pp.startdate as DATE)
                      OR fi.lastpaymentdate < CAST( pp.startdate as DATE))
                      AND fi.edw_invoicestatusid = 515 
                    THEN 1
                      -- Consider paid invoices after payment plan start date
                    WHEN fi.lastpaymentdate >= CAST( pp.startdate as DATE)
                      AND fi.edw_invoicestatusid = 516 
                    THEN 1
                    WHEN fi.firstpaymentdate = '1900-01-01'
                      OR fi.firstpaymentdate IS NULL 
                    THEN 1
                ELSE CAST(NULL as INT64)
                END
                ) AS noofinvoices,
              sum(
                CAST(
                  CASE
                    WHEN fi.firstpaymentdate >= CAST( pp.startdate as DATE)  -- Consider invoices having first payment date on/after paymentplan start date
                      OR fi.firstpaymentdate >= CAST( pp.downpaymentdate as DATE) -- Consider invoices having first payment date on/after paymentplan downpayment date
                      --- There could be payments only on fees after the paymentplan is taken. Considering payments that are applied to fees after paymentplan start date
                      OR fi.firstfeepaymentdate >= CAST( pp.startdate as DATE)
                      AND (fi.firstfeepaymentdate <> '1900-01-01'
                      OR fi.firstpaymentdate IS NOT NULL) -- MBSID 1256540746
                      AND (fi.firstpaymentdate <> '1900-01-01'
                      OR fi.firstpaymentdate IS NOT NULL) 
                    THEN fi.txncnt
                      -- Consider invoices having Last payment date on/after paymentplan start date. First payment date could be prior to paymentplan start date
                    WHEN fi.lastpaymentdate >= CAST( pp.startdate as DATE)
                      OR fi.lastpaymentdate >= CAST( pp.downpaymentdate as DATE) 
                    THEN fi.txncnt
                      -- Do not consider invoices having first/Last payment dates prior to paymentplan start date for Vtoll invoices
                    WHEN (fi.firstpaymentdate < CAST( pp.startdate as DATE)
                      OR fi.lastpaymentdate < CAST( pp.startdate as DATE))
                      AND fi.edw_invoicestatusid = 99999 -- Vtoll 
                    THEN NULL -- MBSID 1216576611
                      -- Consider invoices that are partial paid prior to paymentplan start date. There are can be payments after the payment plan is taken for partial invoices.
                    WHEN (fi.firstpaymentdate < CAST( pp.startdate as DATE)
                      OR fi.lastpaymentdate < CAST( pp.startdate as DATE))
                      AND fi.edw_invoicestatusid = 515 
                    THEN fi.txncnt
                  -- Consider paid invoices after payment plan start date
                    WHEN fi.lastpaymentdate >= CAST( pp.startdate as DATE)
                      AND fi.edw_invoicestatusid = 516 
                    THEN fi.txncnt
                    WHEN fi.firstpaymentdate = '1900-01-01'
                      OR fi.firstpaymentdate IS NULL 
                    THEN fi.txncnt
                  ELSE NULL
                  END as INT64)
                ) AS nooftransactions
          FROM
            LND_TBOS.TER_PaymentPlans AS pp
            INNER JOIN LND_TBOS.TER_PaymentPlanViolator AS ppv 
              ON pp.paymentplanid = ppv.paymentplanid
            INNER JOIN (
              SELECT DISTINCT
                  TollPlus_mbsinvoices.mbsid,
                  TollPlus_mbsinvoices.invoicenumber
                FROM
                  LND_TBOS.TollPlus_MbsInvoices
            ) AS mbsi 
              ON ppv.mbsid = mbsi.mbsid
            INNER JOIN EDW_TRIPS.Fact_Invoice AS fi 
              ON CAST(fi.invoicenumber AS STRING) = mbsi.invoicenumber
            --WHERE PPV.ViolatorID=2010014516
          GROUP BY ppv.violatorid,
                   pp.paymentplanid, 
                   ppv.mbsid, 
                   fi.vehicleid
        );

      CREATE OR REPLACE TABLE EDW_TRIPS.Fact_PaymentPlan CLUSTER BY hvid
      AS
        SELECT
            coalesce(pp.paymentplanid, -1) AS paymentplanid,
            coalesce(ppv.violatorid, -1) AS customerid,
            ppv.hvid,
            coalesce(coalesce(cte.vehicleid, v.vehicleid), -1) AS vehicleid,
            coalesce(ppv.mbsid, -1) AS mbsid,
            coalesce(pp.custtagid, CAST(-1 AS STRING)) AS custtagid,
            ts.paymentplanstatusid,
            CAST(left(CAST( pp.startdate as STRING FORMAT 'YYYYMMDD'), 8) as INT64) AS agreementactivedayid,
            pp.remedystage AS hvstage,

            pp.quoteexpirydate,
            pp.quotefinalizeddate,
            pp.quotesigneddate,
            pp.defaulteddate,
            pp.statusdatetime,
            pp.downpaymentdate,
            pp.enddate AS lastinstallmentduedate,
            pp.lastpaiddate,
            pp.nextduedate,
            pp.paidinfulldate,

            pp.defaultscount AS previousdefaultscount,
            pp.totalnoofmonths,
            CASE
              WHEN pp.startdate < '2021-01-01'
                AND ts.paymentplanstatusdescription NOT IN(
                'Settlement Agreement Active', 'Settlement Agreement Paid In Full', 'Settlement Agreement Defaulted'
                ) 
              THEN CAST(NULL as INT64)
            ELSE cte.noofinvoices
            END AS noofinvoices, -- Not bringing data for the payment plans which are not Active/Defaulted/PaidInFull prior to 2021 as these PP's have some migration issues
            CASE
              WHEN pp.startdate < '2021-01-01'
                AND ts.paymentplanstatusdescription NOT IN(
                'Settlement Agreement Active', 'Settlement Agreement Paid In Full', 'Settlement Agreement Defaulted'
              ) THEN CAST(NULL as INT64)
            ELSE cte.nooftransactions
            END AS nooftransactions,-- Not bringing data for the payment plans which are not Active/Defaulted/PaidInFull prior to 2021 as these PP's have some migration issues
            pp.totalamountpayable AS mbsdue,
            pp.calculateddownpayment,
            pp.customdownpayment,
            pp.monthlypayment,
            pp.totalreceived AS paidamount,
            pp.balancedue AS remainingamount,
            pp.lastpaidamount,
            pp.totalsettlementamount AS settlementamount,
            pp.tollamount,
            pp.feeamount,
            coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_updatedate --SELECT *
        FROM
          LND_TBOS.TER_PaymentPlans AS pp
          INNER JOIN LND_TBOS.TER_PaymentPlanViolator AS ppv 
            ON pp.paymentplanid = ppv.paymentplanid
          LEFT OUTER JOIN EDW_TRIPS.Dim_HabitualViolator AS hv 
            ON hv.hvid = ppv.hvid
          LEFT OUTER JOIN EDW_TRIPS.Dim_PaymentPlanStatus AS ts 
            ON CAST(ts.paymentplanstatusid AS STRING) = pp.statuslookupcode
          LEFT OUTER JOIN cte_inv AS cte 
            ON cte.customerid = ppv.violatorid
              AND cte.mbsid = ppv.mbsid
              AND cte.paymentplanid = pp.paymentplanid
          LEFT OUTER JOIN EDW_TRIPS.Dim_Vehicle AS v 
            ON v.customerid = ppv.violatorid
              AND cte.vehicleid IS NULL
          --WHERE ppv.ViolatorID=800220966 --2010014516
          --WHERE pp.StartDate >= '2021-01-01' --- This code was changed after Discussion with Shekhar to pull paymentplans created after this Date. This bug was Identified by Don and Nandini
                                               --- Commented out this filter because we need paymentplans prior to 2021 which are Active/Defaulted/PaidInFull for Collections.
      ;

      SET log_message = 'Loaded EDW_TRIPS.Fact_PaymentPlan';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);

      ## Show results
      IF trace_flag = 1 THEN
        SELECT log_source,log_start_date;  -- Replacement for FromLog
      END IF;

      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Fact_PaymentPlan' AS tablename,
            *
        FROM
          EDW_TRIPS.Fact_PaymentPlan
        ORDER BY 2 DESC
        LIMIT 1000
        ;
      END IF;
    
      EXCEPTION WHEN ERROR THEN
        BEGIN
          DECLARE error_message STRING DEFAULT @@error.message;
          CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);

          SELECT log_source,log_start_date; -- Replacement for FromLog
          RAISE USING MESSAGE = error_message;-- Rethrow the error!
        END;
    END;
    /*
    --===============================================================================================================
    -- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
    --===============================================================================================================
    EXEC dbo.Fact_PaymentPlan_Load

    EXEC Utility.FromLog 'dbo.Fact_PaymentPlan', 1
    SELECT TOP 100 'dbo.Fact_PaymentPlan' Table_Name, * FROM dbo.Fact_PaymentPlan ORDER BY 2


    select * FROM dbo.Fact_PaymentPlan ORDER BY 2
    select count(*) FROM dbo.Fact_PaymentPlan --110984 
    select * FROM edw_trips.dbo.Fact_PaymentPlan  where customerid = 806539432
    select * FROM edw_trips_dev.dbo.Fact_PaymentPlan  where customerid = 806539432

    --Old Code
    (
            SELECT 
              MI.MbsID,
              COUNT(DISTINCT MI.InvoiceNumber) NoOfInvoices,
              COUNT(DISTINCT TPV.CitationID) NoOfTransactions -- select referenceinvoiceID,TPV.*
            FROM LND_TBOS.TollPlus.MbsInvoices MI 
            JOIN LND_TBOS.TollPlus.Invoice_LineItems IL ON IL.ReferenceInvoiceID=MI.InvoiceNumber 
                AND IL.LinkSourceName='Tollplus.TP_Violatedtrips' AND IL.CustTxnCategory='TOLL'
            JOIN LND_TBOS.TollPlus.TP_ViolatedTrips TPV ON TPV.CitationID=IL.LinkID AND TPV.TripStatusID=2
            WHERE MI.MbsID=1216576611
          --	WHERE TPV.ViolatorID=791924795
            --ORDER BY IL.ReferenceInvoiceID,TPV.CitationID
            GROUP BY MI.MbsID

    -- Old code for Number od Invoices/transactions

            SELECT DISTINCT
              MBSH.CustomerID,
              MBSI.MbsID,
              COUNT(DISTINCT IL.ReferenceInvoiceID) NoOfInvoices,
              COUNT(DISTINCT VT.TpTripID) NoOfTransactions
            FROM LND_TBOS.TollPlus.Mbsheader MBSH
              JOIN
              (
                  SELECT DISTINCT
                        MbsID,
                        InvoiceNumber
                  FROM LND_TBOS.TollPlus.MbsInvoices
              ) MBSI
                  ON MBSI.MbsID = PPV.MbsID
            JOIN LND_TBOS.TollPlus.Invoice_LineItems IL ON IL.ReferenceInvoiceID=MBSI.InvoiceNumber AND IL.LinkSourceName='Tollplus.TP_Violatedtrips'
            JOIN LND_TBOS.TollPlus.TP_ViolatedTrips VT ON VT.CitationID=IL.LinkID
              JOIN LND_TBOS.TER.PaymentPlanViolator PPV
                  ON PPV.MbsID = MBSI.MbsID 
            JOIN LND_TBOS.TER.PaymentPlans PP
              ON PPV.PaymentPlanID=PP.PaymentPlanID
            --WHERE MBSH.CustomerID=806293553
            GROUP BY MBSI.MbsID,
                      MBSH.CustomerID			
          

    ====== Testing code

    SELECT  lnd.*,PP.CustomerID,PP.MbsID,PP.NoOfInvoices FROM (
    SELECT MbsID,COUNT(DISTINCT InvoiceNumber) NoOFInvoices
    FROM LND_TBOS.TollPlus.MbsInvoices GROUP BY MbsID
    ) Lnd
    JOIN 
    dbo.Fact_PaymentPlan PP ON PP.MbsID = Lnd.MbsID AND PP.PaymentPlanStatusID IN (510,49,48)
    WHERE Lnd.NoOFInvoices<>ISNULL(PP.NoOfInvoices,0)


    WHERE pp.StartDate >= '2021-01-01' --- This code was changed after Discussion with Shekhar to pull paymentplans created after this Date. This bug was Identified by Don and Nandini
    --AND pp.PaymentPlanID=477770--426533
    --AND ViolatorID=2008262463

    */

END;