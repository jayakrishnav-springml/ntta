CREATE OR REPLACE PROCEDURE `EDW_TRIPS.CollectionsScript`()
BEGIN
/*
####################################################################################################
Proc Description: 
----------------------------------------------------------------------------------------------------
 1. Prepare all Tables of Collections Export 
  This Sp is 1st Step of Collection Export ,
   After this Collection_FileCreation is Executed to Load Export Tables 


================================================================================================
Change Log:
--------------------------------------------------------------------------------------------
********    EGen        07-29-2024     New!
================================================================================================
Example:   
--------------------------------------------------------------------------------------------------

#######################################################################################
*/
 
    DECLARE log_source STRING DEFAULT 'Collections Script';
    DECLARE log_start_date DATETIME;
      
    BEGIN

      SET log_start_date = current_datetime('America/Chicago');

      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started Collections Script Execution', 'I', CAST(NULL as INT64), CAST(NULL as STRING));

      DROP TABLE IF EXISTS SANDBOX.dbo_VcoInvoices;
      CREATE TABLE SANDBOX.dbo_VcoInvoices AS
      SELECT
        vco.invoicenumber,
        mbs.mbsid,
        mbh.ispresentmbs,
        ftp.fileid,
        ftp.destination,
        COUNT(DISTINCT ftp.filegenerateddate) AS numberoftimessent,
        MAX(ftp.filegenerateddate) AS latestfilegendate
      FROM
        LND_TBOS.TER_ViolatorCollectionsOutbound AS vco
      INNER JOIN
        LND_TBOS.TollPlus_TpFileTracker AS ftp
      ON
        vco.fileid = ftp.fileid
      INNER JOIN
        LND_TBOS.TollPlus_MbsInvoices AS mbs
      ON
        mbs.invoicenumber = vco.invoicenumber
      INNER JOIN
        LND_TBOS.TollPlus_Mbsheader AS mbh
      ON
        mbh.mbsid = mbs.mbsid
      WHERE
        ftp.destination IN( 'CMI',
          'CPA',
          'LES',
          'SWC' )
      GROUP BY
        vco.invoicenumber,
        mbs.mbsid,
        mbh.ispresentmbs,
        ftp.fileid,
        ftp.destination;

      DROP TABLE IF EXISTS SANDBOX.dbo_CollectionInvoicePre;
      CREATE TABLE SANDBOX.dbo_CollectionInvoicePre AS
      SELECT
        vcoinvoices.invoicenumber,
        CASE WHEN vcoinvoices.destination = 'CMI' THEN MAX(vcoinvoices.fileid) END AS cmifileid,
        CASE WHEN vcoinvoices.destination = 'CPA' THEN MAX(vcoinvoices.fileid) END AS cpafileid,
        CASE WHEN vcoinvoices.destination = 'LES' THEN MAX(vcoinvoices.fileid) END AS lesfileid,
        CASE WHEN vcoinvoices.destination = 'SWC' THEN MAX(vcoinvoices.fileid) END AS swcfileid,
        CASE WHEN vcoinvoices.destination = 'CMI' THEN MAX(vcoinvoices.latestfilegendate) END AS cmilatestfilegendate,
        CASE WHEN vcoinvoices.destination = 'CPA' THEN MAX(vcoinvoices.latestfilegendate) END AS cpalatestfilegendate,
        CASE
          WHEN vcoinvoices.destination = 'LES' THEN MAX(vcoinvoices.latestfilegendate)
      END
        AS leslatestfilegendate,
        CASE
          WHEN vcoinvoices.destination = 'SWC' THEN MAX(vcoinvoices.latestfilegendate)
      END
        AS swclatestfilegendate,
        CASE
          WHEN vcoinvoices.destination = 'CMI' THEN MAX(vcoinvoices.numberoftimessent)
      END
        AS cminumberoftimessent,
        CASE
          WHEN vcoinvoices.destination = 'CPA' THEN MAX(vcoinvoices.numberoftimessent)
      END
        AS cpanumberoftimessent,
        CASE
          WHEN vcoinvoices.destination = 'LES' THEN MAX(vcoinvoices.numberoftimessent)
      END
        AS lesnumberoftimessent,
        CASE
          WHEN vcoinvoices.destination = 'SWC' THEN MAX(vcoinvoices.numberoftimessent)
      END
        AS swcnumberoftimessent
      FROM
        SANDBOX.dbo_VcoInvoices AS vcoinvoices
      GROUP BY
        vcoinvoices.invoicenumber,
        vcoinvoices.destination ;

      DROP TABLE IF EXISTS SANDBOX.dbo_CollectionInvoice;
      CREATE TABLE SANDBOX.dbo_CollectionInvoice AS
      SELECT
        collectioninvoicepre.invoicenumber,
        MAX(collectioninvoicepre.cmifileid) AS cmifileid,
        MAX(collectioninvoicepre.cpafileid) AS cpafileid,
        MAX(collectioninvoicepre.lesfileid) AS lesfileid,
        MAX(collectioninvoicepre.swcfileid) AS swcfileid,
        MAX(collectioninvoicepre.cmilatestfilegendate) AS cmilatestfilegendate,
        MAX(collectioninvoicepre.cpalatestfilegendate) AS cpalatestfilegendate,
        MAX(collectioninvoicepre.leslatestfilegendate) AS leslatestfilegendate,
        MAX(collectioninvoicepre.swclatestfilegendate) AS swclatestfilegendate,
        MAX(collectioninvoicepre.cminumberoftimessent) AS cminumberoftimessent,
        MAX(collectioninvoicepre.cpanumberoftimessent) AS cpanumberoftimessent,
        MAX(collectioninvoicepre.lesnumberoftimessent) AS lesnumberoftimessent,
        MAX(collectioninvoicepre.swcnumberoftimessent) AS swcnumberoftimessent
      FROM
        SANDBOX.dbo_CollectionInvoicePre AS collectioninvoicepre
      GROUP BY
         collectioninvoicepre.invoicenumber ;       

      DROP TABLE IF EXISTS SANDBOX.dbo_CollectionInvoiceDetails_Fi;
      CREATE TABLE SANDBOX.dbo_CollectionInvoiceDetails_Fi AS
      SELECT
        ci.invoicenumber,
        fi.customerid AS violatorid,
        ci.cmifileid,
        ci.cpafileid,
        ci.lesfileid,
        ci.swcfileid,
        ci.cmilatestfilegendate,
        ci.cpalatestfilegendate,
        ci.leslatestfilegendate,
        ci.swclatestfilegendate,
        ci.cminumberoftimessent,
        ci.cpanumberoftimessent,
        ci.lesnumberoftimessent,
        ci.swcnumberoftimessent,
        fi.zipcashdate AS zcinvoicedate,
        fi.tolls + fi.fnfees + fi.snfees AS invoiceamount,
        fi.tolls,
        fi.fnfees + fi.snfees AS fees,
        fi.adjustedexpectedtolls,
        fi.adjustedexpectedfnfees,
        fi.adjustedexpectedsnfees,
        fi.adjustedexpectedamount,
        di.invoicestatusdesc AS currentinvoicestatus
      FROM
        SANDBOX.dbo_CollectionInvoice AS ci
      INNER JOIN
        EDW_TRIPS.Fact_Invoice AS fi
      ON
        CAST(fi.invoicenumber AS STRING)= ci.invoicenumber
      LEFT OUTER JOIN
        EDW_TRIPS.Dim_InvoiceStatus AS di
      ON
        fi.edw_invoicestatusid = di.invoicestatusid ;

      DROP TABLE IF EXISTS SANDBOX.dbo_CollectionInvoiceDetails_Rmi; 
      --1294512
      CREATE TABLE SANDBOX.dbo_CollectionInvoiceDetails_Rmi AS
      ---v9 1,294,512 
      SELECT
        ci.invoicenumber,
        rmi.customerid AS violatorid,
        ci.cmifileid,
        ci.cpafileid,
        ci.lesfileid,
        ci.swcfileid,
        ci.cmilatestfilegendate,
        ci.cpalatestfilegendate,
        ci.leslatestfilegendate,
        ci.swclatestfilegendate,
        ci.cminumberoftimessent,
        ci.cpanumberoftimessent,
        ci.lesnumberoftimessent,
        ci.swcnumberoftimessent,
        rmi.zipcashdate AS zcinvoicedate,
        rmi.tolls + rmi.fnfees + rmi.snfees AS invoiceamount,
        rmi.tolls,
        rmi.fnfees + rmi.snfees AS fees,
        rmi.adjustedexpectedtolls,
        rmi.adjustedexpectedfnfees,
        rmi.adjustedexpectedsnfees,
        rmi.adjustedexpectedamount,
        di.invoicestatusdesc AS currentinvoicestatus
      FROM (
        SELECT
          ci_2.invoicenumber,
          ci_2.cmifileid,
          ci_2.cpafileid,
          ci_2.lesfileid,
          ci_2.swcfileid,
          ci_2.cmilatestfilegendate,
          ci_2.cpalatestfilegendate,
          ci_2.leslatestfilegendate,
          ci_2.swclatestfilegendate,
          ci_2.cminumberoftimessent,
          ci_2.cpanumberoftimessent,
          ci_2.lesnumberoftimessent,
          ci_2.swcnumberoftimessent
        FROM
          SANDBOX.dbo_CollectionInvoice AS ci_2
        LEFT OUTER JOIN
          EDW_TRIPS.Fact_Invoice AS fi
        ON
        CAST(fi.invoicenumber AS STRING)= ci_2.invoicenumber
        WHERE
          fi.invoicenumber IS NULL ) AS ci
      INNER JOIN
        EDW_TRIPS_SUPPORT.RiteMigratedInvoice AS rmi
      ON
        CAST(rmi.invoicenumber AS STRING) = ci.invoicenumber
      LEFT OUTER JOIN
        EDW_TRIPS.Dim_InvoiceStatus AS di
      ON
        rmi.edw_invoicestatusid = di.invoicestatusid ;
      
      DROP TABLE IF EXISTS SANDBOX.dbo_CollectionInvoiceDetails;
      CREATE TABLE SANDBOX.dbo_CollectionInvoiceDetails AS
      --28802458
      SELECT
        collectioninvoicedetails_fi.*
      FROM
        SANDBOX.dbo_CollectionInvoiceDetails_Fi AS collectioninvoicedetails_fi
      UNION DISTINCT
      SELECT
        collectioninvoicedetails_rmi.*
      FROM
        SANDBOX.dbo_CollectionInvoiceDetails_Rmi AS collectioninvoicedetails_rmi;
      
      DROP TABLE IF EXISTS SANDBOX.dbo_MbsInvoices;
      CREATE TABLE SANDBOX.dbo_MbsInvoices AS
      SELECT
        DISTINCT mbsi.invoicenumber,
        mbsi.mbsid
      FROM
        LND_TBOS.TollPlus_Mbsheader AS mbsh
      INNER JOIN (
        SELECT
          DISTINCT mbsinvoices.mbsid,
          mbsinvoices.invoicenumber
        FROM
          LND_TBOS.TollPlus_MbsInvoices AS mbsinvoices) AS mbsi
      ON
        mbsi.mbsid = mbsh.mbsid
      INNER JOIN
        LND_TBOS.TER_PaymentPlanViolator AS ppvt
      ON
        ppvt.mbsid = mbsi.mbsid
      INNER JOIN
        EDW_TRIPS.Fact_PaymentDetail AS f
      ON
        CAST(f.invoicenumber AS STRING)= mbsi.invoicenumber   -- Only bring paymentPlans for invoices where there are payment records
        AND f.customerid = mbsh.customerid ; 
        ---------------------------- ******************* NonVTolls **********************************************---------------------------
      DROP TABLE IF EXISTS SANDBOX.dbo_Dim_PaymentPlan_Combined;
      CREATE TABLE SANDBOX.dbo_Dim_PaymentPlan_Combined CLUSTER BY HVID AS
      SELECT
        paymentplanid,
        customerid,
        hvid,
        vehicleid,
        mbsid,
        custtagid,
        pp.paymentplanstatusid AS StatusLookupCode,
        pd.paymentplanstatusdescription AS StatusDescription,
        CAST(PARSE_DATETIME("%Y%m%d",CAST(agreementactivedayid AS STRING)) AS DATE) AS AgreementActiveDate,
        hvstage,
        quoteexpirydate,
        quotefinalizeddate,
        quotesigneddate,
        defaulteddate,
        statusdatetime,
        downpaymentdate,
        lastinstallmentduedate,
        lastpaiddate,
        nextduedate,
        paidinfulldate,
        previousdefaultscount,
        totalnoofmonths,
        noofinvoices,
        nooftransactions,
        mbsdue,
        calculateddownpayment,
        customdownpayment,
        monthlypayment,
        paidamount,
        remainingamount,
        lastpaidamount,
        settlementamount,
        tollamount,
        feeamount,
        pp.edw_updatedate
      FROM
        EDW_TRIPS.Fact_PaymentPlan AS pp
      INNER JOIN
        EDW_TRIPS.Dim_PaymentPlanStatus AS pd
      ON
        pd.paymentplanstatusid = pp.paymentplanstatusid ;
      
      DROP TABLE IF EXISTS SANDBOX.dbo_PaymentPlanPayments;
      CREATE TABLE SANDBOX.dbo_PaymentPlanPayments CLUSTER BY CitationID AS
      SELECT
        pdf.invoicenumber,
        pdf.citationid,
        pdf.paymentdayid,
        pdf.paymentid,
        pdf.paymentid * CAST(10000000000000 AS BIGNUMERIC) + pdf.citationid AS upid,
        pdf.channelid,
        pdf.posid,
        pp.paymentplanid,
        CAST( pp.agreementactivedate AS DATE) AS startdate,
        CAST( pp.lastinstallmentduedate AS DATE) AS enddate,
        CAST( pp.statusdatetime AS DATE) AS statusdate,
        lastpaiddate,
        hvs.statuscode,
        pp.downpaymentdate,
        pp.quotefinalizeddate,
        pp.quotesigneddate,
        hvs.statusdescription,
        SUM(pdf.amountreceived) AS amountreceived,
        SUM(pdf.fnfeespaid) AS fnfeespaid,
        SUM(pdf.snfeespaid) AS snfeespaid
      FROM
        EDW_TRIPS.Fact_PaymentDetail AS pdf
      INNER JOIN
        SANDBOX.dbo_MbsInvoices AS mbs
      ON
        CAST(pdf.invoicenumber AS STRING)= mbs.invoicenumber
      INNER JOIN
        SANDBOX.dbo_Dim_PaymentPlan_Combined AS pp
      ON
        pp.mbsid = mbs.mbsid
      INNER JOIN
        LND_TBOS.TER_HVStatusLookup AS hvs
      ON
        hvs.hvstatuslookupid = pp.statuslookupcode
        AND
        CASE
          WHEN pp.lastpaiddate IS NULL THEN 0 --- ignore where Last Payment/paid  date is null 
          WHEN CAST( pp.statusdatetime AS DATE) = pp.agreementactivedate ---- ignore if  "PaymentStatusDate" is same as PaymentStartDate and HVStatus code is in below
        AND pp.statusdescription IN( 'Settlement Agreement Cancelled',
          'Settlement Agreement Defaulted',
          'Settlement Agreement Default Initiated',
          'Settlement Agreement Quote - Denied',
          'Settlement Agreement Quote Expired' ) THEN 0
          WHEN CAST(CAST(pp.statusdatetime as STRING FORMAT 'YYYYMMDD') AS INT64) = pdf.paymentdayid ---- ignore if "PaymentStatusDate"  is same as PaymentMadeDateID and HVStatus code is changed to below
          AND pp.statusdescription IN( 'Settlement Agreement Cancelled', 'Settlement Agreement Defaulted', 'Settlement Agreement Default Initiated', 'Settlement Agreement Quote - Denied', 'Settlement Agreement Quote Expired' ) THEN 0
          WHEN pdf.paymentdayid NOT 
            ---- ignore if "PaymentDayID"  is BETWEEN "PaymentStartDate" and "StatusDateTime" HVStatus code is changed to below
            ---- HV status code can change to any of these statuses between paymentStartDate and recent paymentStatusDate and we dont need them
          BETWEEN CAST(CAST( pp.agreementactivedate as STRING FORMAT 'YYYYMMDD') AS INT64)
        AND CAST(SUBSTR(CAST( pp.statusdatetime as STRING FORMAT 'YYYYMMDD'), 1, 30) AS INT64)
        AND pp.statusdescription IN( 'Settlement Agreement Cancelled',
          'Settlement Agreement Defaulted',
          'Settlement Agreement Default Initiated',
          'Settlement Agreement Quote - Denied',
          'Settlement Agreement Quote Expired' ) THEN 0
          WHEN pdf.paymentdayid >= CAST(CAST( pp.agreementactivedate as STRING FORMAT 'YYYYMMDD') AS INT64) AND pdf.paymentdayid <= COALESCE(CAST(CAST( pp.lastinstallmentduedate as STRING FORMAT 'YYYYMMDD') AS INT64), 19000101)   ---PaymentDate is between PaymentPlanStartDate and PaymentPlanEndDate
          OR pdf.paymentdayid >= CAST(CAST(pp.downpaymentdate as STRING FORMAT 'YYYYMMDD') AS INT64) AND pdf.paymentdayid <= COALESCE(CAST(CAST( pp.lastinstallmentduedate as STRING FORMAT 'YYYYMMDD') AS INT64), 19000101) 
          ---PaymentDate is between DownPaymentDate and PaymentPlanEndDate
          --- Note : DownPaymentDate is always earlier than PaymentPlan StartDate
          OR pdf.paymentdayid >= CAST(CAST(pp.quotefinalizeddate as STRING FORMAT 'YYYYMMDD') AS INT64) AND pdf.paymentdayid <= COALESCE(CAST(CAST( pp.lastinstallmentduedate as STRING FORMAT 'YYYYMMDD') AS INT64), 19000101) THEN 1
          ---PaymentDate is between QuoteFinalizedDate and PaymentPlanEndDate
          --- QuoteFinalizedDate is always less than or same as DownPaymentDate

          ELSE 0
      END
        = 1
      GROUP BY
        pdf.invoicenumber,
        pdf.citationid,
        pdf.paymentdayid,
        pdf.paymentid,
        upid,
        pdf.channelid,
        pdf.posid,
        pp.paymentplanid,
        startdate, --paymentplan startdate
        enddate,   --paymentplan enddate
        statusdate,
        lastpaiddate,
        hvs.statuscode,
        pp.downpaymentdate,
        pp.quotefinalizeddate,
        pp.quotesigneddate,
        hvs.statusdescription;
        
      
      DROP TABLE IF EXISTS SANDBOX.dbo_AllPayments;
      CREATE TABLE SANDBOX.dbo_AllPayments CLUSTER BY CitationID AS
      SELECT
        pdf.invoicenumber,
        pdf.citationid,
        pdf.paymentdayid,
        pdf.paymentid,
        pdf.paymentid * CAST(10000000000000 AS BIGNUMERIC)  + pdf.citationid AS pdf_upid,
        pdf.channelid,
        pdf.posid,
        NULL AS paymentplanid,
        NULL AS startdate,
        NULL AS enddate,
        NULL AS statusdate,
        NULL AS lastpaiddate,
        NULL AS statuscode,
        NULL AS downpaymentdate,
        NULL AS quotefinalizeddate,
        NULL AS quotesigneddate,
        NULL AS statusdescription,
        pdf.amountreceived AS amountreceived,
        pdf.fnfeespaid AS fnfeespaid,
        pdf.snfeespaid AS snfeespaid
      FROM
        EDW_TRIPS.Fact_PaymentDetail AS pdf ;
      
      DROP TABLE IF EXISTS SANDBOX.dbo_Temp;
      CREATE TABLE SANDBOX.dbo_Temp CLUSTER BY CitationID AS
      SELECT
        pdf.invoicenumber,
        pdf.citationid,
        pdf.paymentdayid,
        pdf.paymentid,
        pdf.channelid,
        pdf.posid,
        NULL AS paymentplanid,
        NULL AS startdate,
        NULL AS enddate,
        NULL AS statusdate,
        NULL AS lastpaiddate,
        NULL AS statuscode,
        NULL AS downpaymentdate,
        NULL AS quotefinalizeddate,
        NULL AS quotesigneddate,
        NULL AS statusdescription,
        pdf.amountreceived,
        pdf.fnfeespaid,
        pdf.snfeespaid
      FROM
        SANDBOX.dbo_AllPayments AS pdf
      LEFT OUTER JOIN
        SANDBOX.dbo_PaymentPlanPayments AS ppp
      ON
        pdf.pdf_upid = ppp.upid
      WHERE
        ppp.upid IS NULL ;
      
      DROP TABLE IF EXISTS SANDBOX.dbo_NonPPPayments;
      CREATE TABLE SANDBOX.dbo_NonPPPayments CLUSTER BY CitationID AS
      SELECT
        *
      FROM
        SANDBOX.dbo_Temp ;
      
      DROP TABLE IF EXISTS SANDBOX.dbo_InvoicePayments;
      CREATE TABLE SANDBOX.dbo_InvoicePayments CLUSTER BY InvoiceNumber AS
      SELECT
        paymentplanpayments.invoicenumber,
        paymentplanpayments.paymentdayid,
        paymentplanpayments.channelid,
        paymentplanpayments.posid,
        paymentplanpayments.paymentplanid,
        paymentplanpayments.startdate,
        paymentplanpayments.enddate,
        paymentplanpayments.statusdate,
        paymentplanpayments.lastpaiddate,
        paymentplanpayments.statuscode,
        CAST( paymentplanpayments.downpaymentdate AS DATE) AS downpaymentdate,
        CAST( paymentplanpayments.quotefinalizeddate AS DATE) AS quotefinalizeddate,
        CAST( paymentplanpayments.quotesigneddate AS DATE) AS quotesigneddate,
        paymentplanpayments.statusdescription,
        SUM(paymentplanpayments.amountreceived) AS amountreceived,
        SUM(paymentplanpayments.fnfeespaid) AS fnfeespaid,
        SUM(paymentplanpayments.snfeespaid) AS snfeespaid
      FROM
        SANDBOX.dbo_PaymentPlanPayments AS paymentplanpayments
      GROUP BY
        paymentplanpayments.invoicenumber,
        paymentplanpayments.paymentdayid,
        paymentplanpayments.channelid,
        paymentplanpayments.posid,
        paymentplanpayments.paymentplanid,
        paymentplanpayments.startdate,
        paymentplanpayments.enddate,
        paymentplanpayments.statusdate,
        paymentplanpayments.lastpaiddate,
        paymentplanpayments.statuscode,
        downpaymentdate,
        quotefinalizeddate,
        quotesigneddate,
        paymentplanpayments.statusdescription
        
      UNION ALL
      SELECT
        nonpppayments.invoicenumber,
        nonpppayments.paymentdayid,
        nonpppayments.channelid,
        nonpppayments.posid,
        -1 AS paymentplanid,
        DATE '2999-01-01' AS startdate,
        DATE '2999-01-01' AS enddate,
        DATE '2999-01-01' AS statusdate,
        DATE '2999-01-01' AS lastpaiddate,
        CAST(NULL AS STRING) AS statuscode,
        DATE '2999-01-01' AS downpaymentdate,
        DATE '2999-01-01' AS quotefinalizeddate,
        DATE '2999-01-01' AS quotesigneddate,
        CAST(NULL AS STRING) AS statusdescription,
        SUM(nonpppayments.amountreceived) AS amountreceived,
        SUM(nonpppayments.fnfeespaid) AS fnfeespaid,
        SUM(nonpppayments.snfeespaid) AS snfeespaid
      FROM
        SANDBOX.dbo_NonPPPayments AS nonpppayments
      GROUP BY
        InvoiceNumber,
         PaymentDayID,
         ChannelID,
         POSID,
         StatusCode,
         StatusDescription; 
      
      DROP TABLE IF EXISTS SANDBOX.dbo_CollectionInvoiceNonVtollPaymentsBeforeGroupBy;
      CREATE TABLE SANDBOX.dbo_CollectionInvoiceNonVtollPaymentsBeforeGroupBy AS
      SELECT
        NULL AS AdjustmentAmount,
        chd.channelname,
        COALESCE(cid.cpalatestfilegendate, cid.leslatestfilegendate) AS Created_at_Primary_Collection_agency,
        COALESCE(cid.swclatestfilegendate, cid.cmilatestfilegendate) AS Created_at_Secondary_Collection_agency,
        cid.currentinvoicestatus,
        p.fnfeespaid + p.snfeespaid AS FeePaid,
        cid.fees,
        cid.invoiceamount,
        cid.invoicenumber,
        p.amountreceived + p.fnfeespaid + p.snfeespaid AS InvoicePaid,
        pos.posname AS Locationname,
        COALESCE(cid.cpanumberoftimessent, cid.lesnumberoftimessent, 0) AS No_of_Times_Sent_to_Primary,
        COALESCE(cid.swcnumberoftimessent, cid.cminumberoftimessent, 0) AS No_of_Times_Sent_to_Secondary,
        p.paymentplanid,
        p.paymentdayid AS PaymentDate,
        CASE
          WHEN cpafileid IS NOT NULL THEN 'Credit Protected Assoc. (CPA)'
          WHEN lesfileid IS NOT NULL THEN 'Duncan Solutions (LES/PAM)'
          ELSE NULL
      END
        AS Primary_Collection_Agency,
        CASE
          WHEN swcfileid IS NOT NULL THEN 'Southwest Credit Systems (SWC)'
          WHEN cmifileid IS NOT NULL THEN 'Credit Management Group (CMI)'
          ELSE NULL
      END
        AS Seconday_Collection_Agency,
        p.amountreceived AS TollPaid,
        cid.tolls,
        NULL AS Vtollamount,
        cid.violatorid,
        CAST(NULL AS DATE) AS VtollPostedDate,
        CAST( cid.zcinvoicedate AS DATE) AS zcinvoicedate
      FROM
        SANDBOX.dbo_CollectionInvoiceDetails AS cid
      LEFT OUTER JOIN
        SANDBOX.dbo_InvoicePayments AS p
      ON
        CAST(p.invoicenumber AS STRING) = cid.invoicenumber
        AND
        CASE
          WHEN 
          (p.paymentdayid BETWEEN CAST(CAST(cid.leslatestfilegendate as STRING FORMAT 'YYYYMMDD') AS INT64) AND  --LES -> CMI 
          COALESCE(CAST(CAST(cid.cmilatestfilegendate as STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)) 
          )     
          OR 
          (p.paymentdayid BETWEEN CAST(CAST(cid.leslatestfilegendate as STRING FORMAT 'YYYYMMDD') AS INT64) AND  --LES -> SWC
          COALESCE(CAST(CAST(cid.swclatestfilegendate as STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          )
          OR 
          (p.paymentdayid BETWEEN CAST(CAST(cid.cpalatestfilegendate as STRING FORMAT 'YYYYMMDD') AS INT64) AND  --CPA -> CMI
          COALESCE(CAST(CAST(cid.cmilatestfilegendate as STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)) 
          )
          OR 
          (p.paymentdayid BETWEEN CAST(CAST(cid.cpalatestfilegendate as STRING FORMAT 'YYYYMMDD') AS INT64) AND --CPA -> SWC
          COALESCE(CAST(CAST(cid.swclatestfilegendate as STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          ) 
          OR 
          (p.paymentdayid BETWEEN COALESCE(CAST(CAST(cid.cmilatestfilegendate as STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)) AND  --CMI - GetDate()
          CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64) 
          )
          OR 
          (p.paymentdayid BETWEEN COALESCE(CAST(CAST(cid.swclatestfilegendate as STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)) AND   --SWC - GetDate() 
          CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)
          ) 
          THEN 1
          ELSE 0
      END
        = 1
      LEFT OUTER JOIN
        EDW_TRIPS.Dim_PosLocation AS pos
      ON
        pos.posid = p.posid
      LEFT OUTER JOIN
        EDW_TRIPS.Dim_Channel AS chd
      ON
        p.channelid = chd.channelid ;

      DROP TABLE IF EXISTS EDW_TRIPS.CollectionInvoiceNonVtollPayments;
      CREATE TABLE EDW_TRIPS.CollectionInvoiceNonVtollPayments AS
      SELECT
        violatorid,
        invoicenumber,
        zcinvoicedate,
        currentinvoicestatus,
        tolls,
        fees,
        invoiceamount,
        primary_collection_agency,
        created_at_primary_collection_agency,
        no_of_times_sent_to_primary,
        seconday_collection_agency,
        created_at_secondary_collection_agency,
        no_of_times_sent_to_secondary,
        paymentplanid,
        locationname,
        channelname,
        paymentdate,
        SUM(invoicepaid) AS invoicepaid,
        SUM(tollpaid) AS tollpaid,
        SUM(feepaid) AS feepaid,
        adjustmentamount,
        vtollamount,
        vtollposteddate
      FROM
        SANDBOX.dbo_CollectionInvoiceNonVtollPaymentsBeforeGroupBy
      GROUP BY
        violatorid
        ,invoicenumber
        ,zcinvoicedate
        ,currentinvoicestatus
        ,tolls
        ,fees
        ,invoiceamount
        ,primary_collection_agency
        ,no_of_times_sent_to_primary
        ,created_at_primary_collection_agency
        ,seconday_collection_agency
        ,no_of_times_sent_to_secondary
        ,created_at_secondary_collection_agency
        ,paymentplanid
        ,locationname
        ,channelname
        ,paymentdate
        ,adjustmentamount
        ,vtollamount   
        , vtollposteddate ;

    ---------------------------- ******************* VTolls **********************************************---------------------------

      DROP TABLE IF EXISTS SANDBOX.dbo_VtollCollectionInvoices;
      CREATE TABLE SANDBOX.dbo_VtollCollectionInvoices AS
      SELECT
        DISTINCT ci.invoicenumber,
        tc.tptripid,
        tc.tollamount,
        tc.posteddate,
        ci.cmilatestfilegendate,
        ci.leslatestfilegendate,
        ci.cpalatestfilegendate,
        ci.swclatestfilegendate
      FROM
        SANDBOX.dbo_CollectionInvoiceDetails AS ci
      INNER JOIN
        LND_TBOS.TollPlus_Invoice_Header AS ih
      ON
        ci.invoicenumber = ih.invoicenumber
      INNER JOIN
        LND_TBOS.TollPlus_Invoice_LineItems AS l
      ON
        l.invoiceid = ih.invoiceid
      INNER JOIN
        LND_TBOS.TollPlus_TP_ViolatedTrips AS vt
      ON
        l.linkid = vt.citationid
        AND l.linksourcename = 'TOLLPLUS.TP_VIOLATEDTRIPS'
      INNER JOIN
        LND_TBOS.TollPlus_TP_CustomerTrips AS tc
      ON
        tc.tptripid = vt.tptripid
        AND tc.paymentstatusid IN( 456,
          457 ) 
          --Fully Paid and Partially Paid
        AND tc.tripstatusid <> 5
        --- Trip is no more a  "VIOLATION -Transaction identified to ZipCash "
        AND tc.transactionpostingtype NOT IN( 'PREPAID AVI',
          'NTTA FLEET' ) 
        --AND TC.OutstandingAmount = 0  ??
        ; 
        
      CREATE TEMPORARY TABLE _SESSION.vtolls AS
      SELECT
        DISTINCT pdf.invoicenumber,  --- CHANGED  CODE TO 'DISTINCT' as left jon to paymentplan and mbsinvoices is multiplying by as many times invoice shows in multiple MBS
        CAST( pdf.posteddate AS DATE) AS posteddate,
        CASE
          WHEN pp.lastpaiddate IS NULL THEN NULL
          WHEN CAST( pp.statusdatetime AS DATE) = pp.agreementactivedate
        AND pp.statusdescription IN( 'Settlement Agreement Cancelled',
          'Settlement Agreement Defaulted',
          'Settlement Agreement Default Initiated',
          'Settlement Agreement Quote - Denied',
          'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN pdf.posteddate NOT BETWEEN pp.agreementactivedate AND CAST( pp.statusdatetime AS DATE) AND pp.statusdescription IN( 'Settlement Agreement Cancelled', 'Settlement Agreement Defaulted', 'Settlement Agreement Default Initiated', 'Settlement Agreement Quote - Denied', 'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST( pp.agreementactivedate AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.downpaymentdate as STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.quotefinalizeddate as STRING FORMAT 'YYYYMMDD') AS INT64)
        AND (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          --CMI - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          --SWC - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)) THEN pp.paymentplanid
          ELSE NULL
      END
        AS paymentplanid,
        CASE
          WHEN pp.lastpaiddate IS NULL THEN NULL
          WHEN CAST( pp.statusdatetime AS DATE) = pp.agreementactivedate
        AND pp.statusdescription IN( 'Settlement Agreement Cancelled',
          'Settlement Agreement Defaulted',
          'Settlement Agreement Default Initiated',
          'Settlement Agreement Quote - Denied',
          'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN pdf.posteddate BETWEEN pp.agreementactivedate AND CAST( pp.statusdatetime AS DATE) AND pp.statusdescription IN( 'Settlement Agreement Cancelled', 'Settlement Agreement Defaulted', 'Settlement Agreement Default Initiated', 'Settlement Agreement Quote - Denied', 'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST( pp.agreementactivedate AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.downpaymentdate as STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.quotefinalizeddate as STRING FORMAT 'YYYYMMDD') AS INT64)
        AND (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          --CMI - GetDate()     
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          --SWC - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)) THEN CAST( pp.statusdatetime AS DATE)
          ELSE NULL
      END
        AS statusdate,
        CASE
          WHEN pp.lastpaiddate IS NULL THEN NULL
          WHEN CAST( pp.statusdatetime AS DATE) = pp.agreementactivedate
        AND pp.statusdescription IN( 'Settlement Agreement Cancelled',
          'Settlement Agreement Defaulted',
          'Settlement Agreement Default Initiated',
          'Settlement Agreement Quote - Denied',
          'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN pdf.posteddate BETWEEN pp.agreementactivedate AND CAST( pp.statusdatetime AS DATE) AND pp.statusdescription IN( 'Settlement Agreement Cancelled', 'Settlement Agreement Defaulted', 'Settlement Agreement Default Initiated', 'Settlement Agreement Quote - Denied', 'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST( pp.agreementactivedate AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.downpaymentdate as STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.quotefinalizeddate as STRING FORMAT 'YYYYMMDD') AS INT64)
        AND (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
            --CMI - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          --SWC - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)) THEN CAST( pp.agreementactivedate AS DATE)
          ELSE NULL
      END
        AS startdate,
        CASE
          WHEN pp.lastpaiddate IS NULL THEN NULL
          WHEN CAST( pp.statusdatetime AS DATE) = pp.agreementactivedate
        AND pp.statusdescription IN( 'Settlement Agreement Cancelled',
          'Settlement Agreement Defaulted',
          'Settlement Agreement Default Initiated',
          'Settlement Agreement Quote - Denied',
          'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN pdf.posteddate BETWEEN pp.agreementactivedate AND CAST( pp.statusdatetime AS DATE) AND pp.statusdescription IN( 'Settlement Agreement Cancelled', 'Settlement Agreement Defaulted', 'Settlement Agreement Default Initiated', 'Settlement Agreement Quote - Denied', 'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST( pp.agreementactivedate AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.downpaymentdate as STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.quotefinalizeddate as STRING FORMAT 'YYYYMMDD') AS INT64)
        AND (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
            --LES -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
            --CMI - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          --SWC - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)) THEN CAST( pp.lastinstallmentduedate AS DATE)
          ELSE NULL
      END
        AS enddate,
        CASE
          WHEN pp.lastpaiddate IS NULL THEN NULL
          WHEN CAST( pp.statusdatetime AS DATE) = pp.agreementactivedate
        AND pp.statusdescription IN( 'Settlement Agreement Cancelled',
          'Settlement Agreement Defaulted',
          'Settlement Agreement Default Initiated',
          'Settlement Agreement Quote - Denied',
          'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN pdf.posteddate BETWEEN pp.agreementactivedate AND CAST( pp.statusdatetime AS DATE) AND pp.statusdescription IN( 'Settlement Agreement Cancelled', 'Settlement Agreement Defaulted', 'Settlement Agreement Default Initiated', 'Settlement Agreement Quote - Denied', 'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST( pp.agreementactivedate AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.downpaymentdate as STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.quotefinalizeddate as STRING FORMAT 'YYYYMMDD') AS INT64)
        AND (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
            --CMI - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          --SWC - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)) THEN CAST( pp.downpaymentdate AS DATE)
          ELSE NULL
      END
        AS downpaymentdate,
        CASE
          WHEN pp.lastpaiddate IS NULL THEN NULL
          WHEN CAST( pp.statusdatetime AS DATE) = pp.agreementactivedate
        AND pp.statusdescription IN( 'Settlement Agreement Cancelled',
          'Settlement Agreement Defaulted',
          'Settlement Agreement Default Initiated',
          'Settlement Agreement Quote - Denied',
          'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN pdf.posteddate BETWEEN pp.agreementactivedate AND CAST( pp.statusdatetime AS DATE) AND pp.statusdescription IN( 'Settlement Agreement Cancelled', 'Settlement Agreement Defaulted', 'Settlement Agreement Default Initiated', 'Settlement Agreement Quote - Denied', 'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST( pp.agreementactivedate AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.downpaymentdate as STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.quotefinalizeddate as STRING FORMAT 'YYYYMMDD') AS INT64)
        AND (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
            --LES -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          --CMI - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          --SWC - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)) THEN CAST( pp.lastpaiddate AS DATE)
          ELSE NULL
      END
        AS lastpaiddate,
        CASE
          WHEN pp.lastpaiddate IS NULL THEN NULL
          WHEN CAST( pp.statusdatetime AS DATE) = pp.agreementactivedate
        AND pp.statusdescription IN( 'Settlement Agreement Cancelled',
          'Settlement Agreement Defaulted',
          'Settlement Agreement Default Initiated',
          'Settlement Agreement Quote - Denied',
          'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN pdf.posteddate BETWEEN pp.agreementactivedate AND CAST( pp.statusdatetime AS DATE) AND pp.statusdescription IN( 'Settlement Agreement Cancelled', 'Settlement Agreement Defaulted', 'Settlement Agreement Default Initiated', 'Settlement Agreement Quote - Denied', 'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST( pp.agreementactivedate AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.downpaymentdate as STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.quotefinalizeddate as STRING FORMAT 'YYYYMMDD') AS INT64)
        AND (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
            --CMI - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          --SWC - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)) THEN pp.statuslookupcode
          ELSE NULL
      END
        AS statuscode,
        CASE
          WHEN pp.lastpaiddate IS NULL THEN NULL
          WHEN CAST( pp.statusdatetime AS DATE) = pp.agreementactivedate
        AND pp.statusdescription IN( 'Settlement Agreement Cancelled',
          'Settlement Agreement Defaulted',
          'Settlement Agreement Default Initiated',
          'Settlement Agreement Quote - Denied',
          'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN pdf.posteddate BETWEEN pp.agreementactivedate AND CAST( pp.statusdatetime AS DATE) AND pp.statusdescription IN( 'Settlement Agreement Cancelled', 'Settlement Agreement Defaulted', 'Settlement Agreement Default Initiated', 'Settlement Agreement Quote - Denied', 'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST( pp.agreementactivedate AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.downpaymentdate as STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.quotefinalizeddate as STRING FORMAT 'YYYYMMDD') AS INT64)
        AND (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
            --CMI - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          --SWC - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)) THEN pp.statusdescription
          ELSE NULL
      END
        AS statusdescription,
        CASE
          WHEN pp.lastpaiddate IS NULL THEN NULL
          WHEN CAST( pp.statusdatetime AS DATE) = pp.agreementactivedate
        AND pp.statusdescription IN( 'Settlement Agreement Cancelled',
          'Settlement Agreement Defaulted',
          'Settlement Agreement Default Initiated',
          'Settlement Agreement Quote - Denied',
          'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN pdf.posteddate BETWEEN pp.agreementactivedate AND CAST( pp.statusdatetime AS DATE) AND pp.statusdescription IN( 'Settlement Agreement Cancelled', 'Settlement Agreement Defaulted', 'Settlement Agreement Default Initiated', 'Settlement Agreement Quote - Denied', 'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST( pp.agreementactivedate AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.downpaymentdate as STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.quotefinalizeddate as STRING FORMAT 'YYYYMMDD') AS INT64)
        AND (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
            --CMI - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          --SWC - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)) THEN pp.quotesigneddate
          ELSE NULL
      END
        AS quotesigneddate,
        CASE
          WHEN pp.lastpaiddate IS NULL THEN NULL
          WHEN CAST( pp.statusdatetime AS DATE) = pp.agreementactivedate
        AND pp.statusdescription IN( 'Settlement Agreement Cancelled',
          'Settlement Agreement Defaulted',
          'Settlement Agreement Default Initiated',
          'Settlement Agreement Quote - Denied',
          'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN pdf.posteddate BETWEEN pp.agreementactivedate AND CAST( pp.statusdatetime AS DATE) AND pp.statusdescription IN( 'Settlement Agreement Cancelled', 'Settlement Agreement Defaulted', 'Settlement Agreement Default Initiated', 'Settlement Agreement Quote - Denied', 'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST( pp.agreementactivedate AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.downpaymentdate as STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.quotefinalizeddate as STRING FORMAT 'YYYYMMDD') AS INT64)
        AND (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
            --CMI - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          --SWC - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)) THEN pp.quotefinalizeddate
          ELSE NULL
      END
        AS quotefinalizeddate,
        pdf.tollamount,
        CASE
          WHEN pp.lastpaiddate IS NULL THEN NULL
          WHEN CAST( pp.statusdatetime AS DATE) = pp.agreementactivedate
        AND pp.statusdescription IN( 'Settlement Agreement Cancelled',
          'Settlement Agreement Defaulted',
          'Settlement Agreement Default Initiated',
          'Settlement Agreement Quote - Denied',
          'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN pdf.posteddate BETWEEN pp.agreementactivedate AND CAST( pp.statusdatetime AS DATE) AND pp.statusdescription IN( 'Settlement Agreement Cancelled', 'Settlement Agreement Defaulted', 'Settlement Agreement Default Initiated', 'Settlement Agreement Quote - Denied', 'Settlement Agreement Quote Expired' ) THEN NULL
          WHEN (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST( pp.agreementactivedate AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.downpaymentdate as STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) >= CAST(CAST(pp.quotefinalizeddate as STRING FORMAT 'YYYYMMDD') AS INT64)
        AND (CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.leslatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --LES -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> CMI
          AND COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN CAST(CAST( pdf.cpalatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64)
          --CPA -> SWC
          AND COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.cmilatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
            --CMI - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)
          OR CAST(CAST( pdf.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) BETWEEN COALESCE(CAST(CAST( pdf.swclatestfilegendate AS STRING FORMAT 'YYYYMMDD') AS INT64),CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64))
          --SWC - GetDate() 
          AND CAST(CAST(CURRENT_DATETIME() AS STRING FORMAT 'YYYYMMDD') AS INT64)) THEN pdf.tollamount
          ELSE NULL
      END
        AS ppvtoll,
        pdf.TpTripID
      FROM
        SANDBOX.dbo_VtollCollectionInvoices AS pdf
      LEFT OUTER JOIN
        SANDBOX.dbo_MbsInvoices AS mbs
      ON
        pdf.invoicenumber = mbs.invoicenumber
      LEFT OUTER JOIN
        SANDBOX.dbo_Dim_PaymentPlan_Combined AS pp
      ON
        pp.mbsid = mbs.mbsid ;
       
      CREATE TEMPORARY TABLE _SESSION.vtolls1 AS
          SELECT
            *,
            vtolls.tollamount - COALESCE(vtolls.ppvtoll, 0) AS nonppvtoll
          FROM
            _SESSION.vtolls AS vtolls;

      DROP TABLE IF EXISTS SANDBOX.dbo_VtollCollectionPayments_PP_NonPP;
      CREATE TABLE SANDBOX.dbo_VtollCollectionPayments_PP_NonPP  AS
      SELECT
        x.*,
        COALESCE(x.ppvtollamount, 0) + COALESCE(x.nonppvtollamount, 0) AS vtollamount
      FROM (
        SELECT
          vtolls1.invoicenumber,
          vtolls1.posteddate,
          vtolls1.paymentplanid,
          vtolls1.statusdate,
          vtolls1.startdate,
          vtolls1.enddate,
          vtolls1.downpaymentdate,
          vtolls1.lastpaiddate,
          vtolls1.statuscode,
          vtolls1.statusdescription,
          vtolls1.quotesigneddate,
          vtolls1.quotefinalizeddate,
            --PDF.TollAmount,
          SUM(vtolls1.ppvtoll) AS ppvtollamount,
          SUM(vtolls1.nonppvtoll) AS nonppvtollamount
        FROM
          _SESSION.vtolls1 AS vtolls1
        GROUP BY
            invoicenumber, 
            posteddate,
            paymentplanid,
            statusdate,
            startdate,
            enddate,
            downpaymentdate,
            lastpaiddate,
            statuscode,
            statusdescription,
            quotesigneddate,
            quotefinalizeddate 
        ) AS x ; 

      DROP TABLE IF EXISTS EDW_TRIPS.CollectionsInvoiceVtollPayments;
      CREATE TABLE EDW_TRIPS.CollectionsInvoiceVtollPayments AS
      SELECT
        cid.violatorid,
        cid.invoicenumber,
        cid.zcinvoicedate,
        cid.currentinvoicestatus,
        cid.tolls,
        cid.fees,
        cid.invoiceamount,
        CASE
          WHEN cpafileid IS NOT NULL THEN 'Credit Protected Assoc. (CPA)'
          WHEN lesfileid IS NOT NULL THEN 'Duncan Solutions (LES/PAM)'
          ELSE NULL
      END
        AS Primary_Collection_Agency,
        COALESCE(cid.cpalatestfilegendate, cid.leslatestfilegendate) AS Created_at_Primary_Collection_agency,
        COALESCE(cid.cpanumberoftimessent, cid.lesnumberoftimessent, 0) AS No_of_Times_Sent_to_Primary,
        CASE
          WHEN swcfileid IS NOT NULL THEN 'Southwest Credit Systems (SWC)'
          WHEN cmifileid IS NOT NULL THEN 'Credit Management Group (CMI)'
          ELSE NULL
      END
        AS Seconday_Collection_Agency,
        COALESCE(cid.swclatestfilegendate, cid.cmilatestfilegendate) AS Created_at_Secondary_Collection_agency,
        COALESCE(cid.swcnumberoftimessent, cid.cminumberoftimessent, 0) AS No_of_Times_Sent_to_Secondary,
        ct.paymentplanid,
        CAST(NULL AS STRING) AS Locationname,
        CAST(NULL AS STRING) AS ChannelName,
        CAST(CAST( ct.posteddate AS STRING FORMAT 'YYYYMMDD') AS INT64) AS Paymentdate,
        CAST(NULL AS BIGNUMERIC) AS InvoicePaid,
        CAST(NULL AS BIGNUMERIC) AS TollPaid,
        CAST(NULL AS BIGNUMERIC) AS FeePaid,
        NULL AS AdjustmentAmount,
        ct.vtollamount,
        CAST( ct.posteddate AS DATE) AS VtollPostedDate
      FROM
        SANDBOX.dbo_CollectionInvoiceDetails AS cid
      INNER JOIN
        SANDBOX.dbo_VtollCollectionPayments_PP_NonPP AS ct
      ON
        ct.invoicenumber = cid.invoicenumber ;

      
      DROP TABLE IF EXISTS EDW_TRIPS.CollectionsInvoiceTotalPayments;
      CREATE TABLE EDW_TRIPS.CollectionsInvoiceTotalPayments AS
      SELECT
        collectionsinvoicevtollpayments.violatorid,
        collectionsinvoicevtollpayments.invoicenumber,
        collectionsinvoicevtollpayments.zcinvoicedate,
        collectionsinvoicevtollpayments.currentinvoicestatus,
        collectionsinvoicevtollpayments.tolls,
        collectionsinvoicevtollpayments.fees,
        collectionsinvoicevtollpayments.invoiceamount,
        collectionsinvoicevtollpayments.primary_collection_agency,
        collectionsinvoicevtollpayments.created_at_primary_collection_agency,
        collectionsinvoicevtollpayments.no_of_times_sent_to_primary,
        collectionsinvoicevtollpayments.seconday_collection_agency,
        collectionsinvoicevtollpayments.created_at_secondary_collection_agency,
        collectionsinvoicevtollpayments.no_of_times_sent_to_secondary,
        collectionsinvoicevtollpayments.paymentplanid,
        collectionsinvoicevtollpayments.locationname,
        collectionsinvoicevtollpayments.channelname,
        collectionsinvoicevtollpayments.paymentdate,
        round(collectionsinvoicevtollpayments.invoicepaid , 2 ) as invoicepaid,
        collectionsinvoicevtollpayments.tollpaid,
        collectionsinvoicevtollpayments.feepaid,
        collectionsinvoicevtollpayments.adjustmentamount,
        collectionsinvoicevtollpayments.vtollamount,
        collectionsinvoicevtollpayments.vtollposteddate
      FROM
        EDW_TRIPS.CollectionsInvoiceVtollPayments AS collectionsinvoicevtollpayments
      WHERE
        collectionsinvoicevtollpayments.vtollposteddate > COALESCE(collectionsinvoicevtollpayments.created_at_primary_collection_agency, collectionsinvoicevtollpayments.created_at_secondary_collection_agency)
      UNION DISTINCT
      SELECT
        collectioninvoicenonvtollpayments.violatorid,
        collectioninvoicenonvtollpayments.invoicenumber,
        collectioninvoicenonvtollpayments.zcinvoicedate,
        collectioninvoicenonvtollpayments.currentinvoicestatus,
        collectioninvoicenonvtollpayments.tolls,
        collectioninvoicenonvtollpayments.fees,
        collectioninvoicenonvtollpayments.invoiceamount,
        collectioninvoicenonvtollpayments.primary_collection_agency,
        collectioninvoicenonvtollpayments.created_at_primary_collection_agency,
        collectioninvoicenonvtollpayments.no_of_times_sent_to_primary,
        collectioninvoicenonvtollpayments.seconday_collection_agency,
        collectioninvoicenonvtollpayments.created_at_secondary_collection_agency,
        collectioninvoicenonvtollpayments.no_of_times_sent_to_secondary,
        collectioninvoicenonvtollpayments.paymentplanid,
        collectioninvoicenonvtollpayments.locationname,
        collectioninvoicenonvtollpayments.channelname,
        collectioninvoicenonvtollpayments.paymentdate,
        round(collectioninvoicenonvtollpayments.invoicepaid,2) as invoicepaid,
        collectioninvoicenonvtollpayments.tollpaid,
        collectioninvoicenonvtollpayments.feepaid,
        collectioninvoicenonvtollpayments.adjustmentamount,
        collectioninvoicenonvtollpayments.vtollamount,
        collectioninvoicenonvtollpayments.vtollposteddate
      FROM
        EDW_TRIPS.CollectionInvoiceNonVtollPayments AS collectioninvoicenonvtollpayments;

        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Collections Script Execution Completed Successfully', 'I', CAST(NULL as INT64), CAST(NULL as STRING));

      EXCEPTION WHEN ERROR THEN
          BEGIN
            DECLARE error_message STRING DEFAULT @@error.message;
            CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
            RAISE USING MESSAGE = error_message;
          END;
      END;
  END;