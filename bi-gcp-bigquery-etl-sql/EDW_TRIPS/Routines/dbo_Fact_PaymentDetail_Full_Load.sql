CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_PaymentDetail_Full_Load`()
BEGIN
/*
GO
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_PaymentDetail_Full_Load table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838 	Bhanu	2020-10-21	New!
				1. PMTLI.CustomerID,--Removed By Bhanu to fix Duplicate Issue because if a Payment ID has multiple 
				   customers then Amount Received is Multiplied example Payment ID: 113812182
				2. Cannot Bring OverPayments because they are not reverted back to customer instead they are stores
				   in Customer Account. So, Customer Payment Table will/should have these records
CHG0037897 	Bhanu	2021-01-13
				1. Cannot Bring Postpaid Fleet OverPayments because they are not reverted back to customer instead 
				   they are stored in Customer Account. So, Customer Payment Table will/should have these records
				2. Added Left join for Reversals/VOID to all 3(TXN/FEE/Fleet Payments) tables and added RefPaymentStatusID 
				   to make sure MSTR query picks up the proper buckets.

CHG0038039	Gouthami  2021-01-27 Added DeleteFlag
CHG0038359	Bhanu	  2021-03-15 Added OverPaymentID, Receipttracker.txndate to Fact_PaymentDetail for MSTR to show
								 only the data with OverpaymentId=0
CHG0038749	Gouthami  2021-04-27 Added POSID
CHG0042740	Gouthami  2022-03-23 Removed A.LND_UpdateType from Stage.TransactionPayment as this is causing double 
								 payments


-------------------------------------------------------------------------------------------------------------------
Run script:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_PaymentDetail_Full_Load
EXEC Utility.FromLog 'dbo.Fact_PaymentDetail_Full_Load', 1

SELECT TOP 1000 'Stage.TransactionPayment' TableName, * FROM Stage.TransactionPayment ORDER BY 2 DESC 
SELECT TOP 1000 'Stage.InvoicedFeePayment' TableName, * FROM Stage.InvoicedFeePayment ORDER BY 2 DESC 
SELECT TOP 1000 'Stage.PostpaidFleetPayment' TableName, * FROM Stage.PostpaidFleetPayment ORDER BY 2 DESC 
SELECT TOP 1000 'dbo.Fact_PaymentDetail' TableName, * FROM Fact_PaymentDetail ORDER BY 2 DESC 

###################################################################################################################
*/

    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_PaymentDetail_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load of Fact tables', 'I', CAST('-1' as INT64), CAST(NULL as STRING));
      --=============================================================================================================
      -- Load Stage.TransactionPayment         --TXN Payments
      --=============================================================================================================
      -- DROP TABLE IF EXISTS EDW_TRIPS_STAGE.TransactionPayment;
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.TransactionPayment 
        AS
          SELECT
              coalesce(CAST(referenceinvoiceid as INT64), -1) AS invoicenumber,
              vtrt.invoiceid,
              vtrt.citationid,
              pmtidpmts.paymentid,
              vtrt.overpaymentid,
              c.customerid,
              c.customerstatusid,
              c.usertypeid,
              cpl.planid,
              CAST(CAST( pmtidpmts.paymentdate as STRING FORMAT 'YYYYMMDD') as INT64) AS paymentdayid,
              vtrt.txndate AS txnpaymentdate,
              pmtidpmts.paymentmodeid,
              -- pmtidpmts.activitytype,
              pmtidpmts.paymentstatusid,
              pmtidpmts.refpaymentid,
              pmtidpmts.refpaymentstatusid,
              pmtidpmts.voucherno,
              pmtidpmts.reftype,
              pmtidpmts.accountstatusid,
              pmtidpmts.channelid,
              pmtidpmts.locationid,
              pmtidpmts.icnid,
              pmtidpmts.isvirtualcheck,
              pmtidpmts.pmttxntype,
              pmtidpmts.subsystemid,
              pmtidpmts.apptxntypeid,
              pmtidpmts.approvedby,
              pmtidpmts.reasontext,
              pmtidpmts.txnamount,
           CAST(FORMAT('%44.6F', TRUNC( (pmtidpmts.lineitemamount / pmtidpmts.paidtxncnt)*1000000) /1000000) AS BIGNUMERIC) AS lineitemamount,    
              vtrt.amountreceived,
              CASE
                WHEN pmtidpmts.deleteflag = 1
                 OR vtrt.lnd_updatetype = 'D'
                 OR invoice_lineitems.lnd_updatetype = 'D' THEN 1
                ELSE 0
              END AS deleteflag
            FROM
              (
                SELECT
                    ptxn.paymentid,
                    --pmtli.customerid,-----Removed By Bhanu to fix Duplicate Issue because if a Payment ID has multiple customers then Amount Received is Multiplied example Payment ID: 113812182
                    ptxn.paymentdate,
                    ptxn.voucherno,
                    ptxn.paymentmodeid,
                    ptxn.activitytype,
                    ptxn.paymentstatusid,
                    ref.refpaymentstatusid,
                    ptxn.refpaymentid,
                    ptxn.reftype,
                    ptxn.accountstatusid,
                    ptxn.approvedby,
                    ptxn.channelid,
                    ptxn.locationid,
                    ptxn.reasontext,
                    ptxn.icnid AS icnid,
                    ptxn.isvirtualcheck,
                    ptxn.pmttxntype,
                    sub.subsystemid,
                    apptxn.apptxntypeid,
                    ptxn.txnamount AS txnamount,
                    CAST(FORMAT('%44.6F', TRUNC( ( sum(pmtli.lineitemamount) )*1000000) /1000000) AS BIGNUMERIC) AS lineitemamount,
                    a.txncnt AS paidtxncnt,
                    CASE
                      WHEN pmtli.lnd_updatetype = 'D'
                       OR ptxn.lnd_updatetype = 'D'
                       OR ref.lnd_updatetype = 'D' THEN 1
                      ELSE 0
                    END AS deleteflag
                  FROM
                    LND_TBOS.Finance_paymenttxn_lineitems AS pmtli
                    INNER JOIN (
                      SELECT
                          TollPlus_tp_violated_trip_receipts_tracker.linkid AS paymentid,
                          --LND_UpdateType, -- Remove to avoid double counting
                          count(DISTINCT TollPlus_tp_violated_trip_receipts_tracker.citationid) AS txncnt
                        FROM
                          LND_TBOS.TollPlus_tp_violated_trip_receipts_tracker
                        WHERE TollPlus_tp_violated_trip_receipts_tracker.linksourcename = 'Finance.PaymentTxns'
                         AND TollPlus_tp_violated_trip_receipts_tracker.lnd_updatetype <> 'D'
                        GROUP BY paymentid --, LND_UpdateType -- Remove to avoid double counting
                    ) AS a ON a.paymentid = pmtli.paymentid
                     AND pmtli.lnd_updatetype <> 'D'
                    INNER JOIN LND_TBOS.Finance_paymenttxns AS ptxn ON ptxn.paymentid = pmtli.paymentid
                     AND ptxn.lnd_updatetype <> 'D'
                    INNER JOIN LND_TBOS.TollPlus_subsystems AS sub ON sub.subsystemcode = ptxn.subsystem
                    INNER JOIN LND_TBOS.TollPlus_apptxntypes AS apptxn ON apptxn.apptxntypecode = pmtli.apptxntypecode
                     AND apptxn.apptxntypeid NOT IN(
                      2541, 2627, 2540, 2628, 2539, 2646, 2647, 2626
                    )
                    ----Cannot Bring Zipcash OverPayments because they are not reverted back to customer instead they are stores in Customer Account. So, Customer Payment Table will/should have these records
                    LEFT OUTER JOIN (
                      SELECT
                          orig_pmt.paymentid,
                          orig_pmt.paymentstatusid AS refpaymentstatusid,
                          orig_pmt.lnd_updatetype
                        FROM
                          LND_TBOS.Finance_paymenttxns AS orig_pmt
                          INNER JOIN (
                            SELECT
                                Finance_paymenttxns.refpaymentid
                              FROM
                                LND_TBOS.Finance_paymenttxns
                              WHERE Finance_paymenttxns.refpaymentid > 0
                               AND Finance_paymenttxns.paymentstatusid = 109
                               AND Finance_paymenttxns.lnd_updatetype <> 'D'
                          ) AS ref_pmt ON ref_pmt.refpaymentid = orig_pmt.paymentid
                           AND orig_pmt.lnd_updatetype <> 'D'
                    ) AS ref ON ptxn.refpaymentid = ref.paymentid
                  GROUP BY  ptxn.paymentid, ptxn.paymentdate, ptxn.voucherno, ptxn.paymentmodeid,ptxn.activitytype,ptxn.paymentstatusid,ref.refpaymentstatusid, ptxn.refpaymentid,ptxn.reftype,ptxn.accountstatusid,ptxn.approvedby,ptxn.channelid,ptxn.locationid,ptxn.reasontext,ptxn.icnid,ptxn.isvirtualcheck,ptxn.pmttxntype,sub.subsystemid,a.txncnt,ptxn.txnamount,apptxn.apptxntypeid,deleteflag
              ) AS pmtidpmts --PMTLI.CustomerID,-----Removed By Bhanu to fix Duplicate Issue because if a Payment ID has multiple customers then Amount Received is Multiplied example Payment ID: 113812182
              INNER JOIN LND_TBOS.TollPlus_tp_violated_trip_receipts_tracker AS vtrt ON vtrt.linkid = pmtidpmts.paymentid
               AND vtrt.linksourcename = 'FINANCE.PAYMENTTXNS'
               AND vtrt.lnd_updatetype <> 'D'
              INNER JOIN LND_TBOS.TollPlus_tp_customers AS c ON c.customerid = vtrt.violatorid -- PMTIDPMTS.CustomerID --Removed By Bhanu to fix Duplicate Issue because if a Payment ID has multiple customers then Amount Received is Multiplied example Payment ID :113812182
              INNER JOIN LND_TBOS.TollPlus_tp_customer_plans AS cpl ON c.customerid = cpl.customerid
              INNER JOIN LND_TBOS.TollPlus_plans ON TollPlus_plans.planid = cpl.planid
              LEFT OUTER JOIN (
                SELECT
                    row_number() OVER (PARTITION BY invoice_lineitems_0.linkid ORDER BY (CASE WHEN invoice_lineitems_0.referenceinvoiceid="" THEN -1 ELSE CAST(invoice_lineitems_0.referenceinvoiceid AS INT64) END) DESC) AS rn,
                    *
                  FROM
                    LND_TBOS.TollPlus_invoice_lineitems AS invoice_lineitems_0
                  WHERE invoice_lineitems_0.custtxncategory = 'TOLL'
                   AND invoice_lineitems_0.lnd_updatetype <> 'D'
              ) AS invoice_lineitems ON invoice_lineitems.linkid = vtrt.citationid
               AND invoice_lineitems.rn = 1
      ;
      -- Log
      SET log_message = 'Loaded EDW_TRIPS_STAGE.TransactionPayment';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, '-1', -1, 'I');
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS_STAGE.TransactionPayment' AS tablename,
            transactionpayment.*
          FROM
            EDW_TRIPS_STAGE.TransactionPayment
        ORDER BY 2 DESC
          LIMIT 100
        ;
      END IF;

      --SELECT * FROM stage.InvoicedFeePayment WHERE InvoiceNumber=1226895319 ORDER BY CitationID
      --=============================================================================================================
      -- Load Stage.InvoicedFeePayment	->	 Invoice Fee Payments
      --=============================================================================================================
      -- DROP TABLE IF EXISTS EDW_TRIPS_STAGE.InvoicedFeePayment;
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.InvoicedFeePayment
        AS
          SELECT
              coalesce(CAST(ih.invoicenumber as INT64), -1) AS invoicenumber,
              irct.invoiceid,
              ict.invoicechargeid,
              invoice_lineitems.linkid AS citationid,
              ptxn.paymentid,
              irct.overpaymentid,
              pmtli.customerid,
              c.customerstatusid,
              c.usertypeid,
              cpl.planid,
              CAST(CAST( ptxn.paymentdate as STRING FORMAT 'YYYYMMDD') as INT64) AS paymentdayid,
              irct.txndate AS txnpaymentdate,
              ptxn.paymentmodeid,
              ptxn.paymentstatusid,
              ref.refpaymentstatusid,
              ptxn.refpaymentid,
              ptxn.voucherno,
              ptxn.reftype,
              ptxn.accountstatusid,
              ptxn.channelid,
              ptxn.locationid,
              ptxn.icnid,
              ptxn.isvirtualcheck,
              ptxn.pmttxntype,
              sub.subsystemid,
              apptxn.apptxntypeid,
              ptxn.approvedby,
              ptxn.reasontext,
              ptxn.txnamount,
              CAST(FORMAT('%44.6F', TRUNC( (pmtli.lineitemamount )*1000000) /1000000) AS BIGNUMERIC) as lineitemamount ,
              NUMERIC '0' AS amountreceived,
             CAST(FORMAT('%49.13F', TRUNC((CASE
                WHEN ict.feecode = 'FSTNTVFEE' THEN cast(irct.amountreceived as BIGNUMERIC)
                ELSE 0
              END / cast( a.txncnt as BIGNUMERIC)) *10000000000000) /10000000000000) AS BIGNUMERIC)  AS fnfeespaid,
             CAST(FORMAT('%49.13F', TRUNC((CASE
                WHEN ict.feecode = 'SECNTVFEE' THEN cast(irct.amountreceived as BIGNUMERIC)
                ELSE 0
              END/ cast( a.txncnt as BIGNUMERIC)) *10000000000000) /10000000000000) AS BIGNUMERIC) AS snfeespaid,
              CASE
                WHEN ptxn.lnd_updatetype = 'D'
                 OR pmtli.lnd_updatetype = 'D'
                 OR irct.lnd_updatetype = 'D'
                 OR ict.lnd_updatetype = 'D'
                 OR ref.lnd_updatetype = 'D' THEN 1
                ELSE 0
              END AS deleteflag -- select *
            FROM
              LND_TBOS.Finance_paymenttxns AS ptxn
              INNER JOIN LND_TBOS.Finance_paymenttxn_lineitems AS pmtli ON pmtli.paymentid = ptxn.paymentid
               AND ptxn.lnd_updatetype <> 'D'
               AND pmtli.lnd_updatetype <> 'D'
              INNER JOIN LND_TBOS.TollPlus_tp_customers AS c ON pmtli.customerid = c.customerid
              INNER JOIN LND_TBOS.TollPlus_channels AS cn ON ptxn.channelid = cn.channelid
              INNER JOIN LND_TBOS.TollPlus_tp_invoice_receipts_tracker AS irct ON irct.linkid = ptxn.paymentid
               AND irct.invoiceid = pmtli.linkid
               AND irct.linksourcename = 'FINANCE.PAYMENTTXNS'
               AND pmtli.linksourcename = 'TOLLPLUS.INVOICE_HEADER'
               AND irct.lnd_updatetype <> 'D'
              INNER JOIN LND_TBOS.TollPlus_invoice_charges_tracker AS ict ON ict.invoicechargeid = irct.invoice_chargeid
               AND ict.lnd_updatetype <> 'D'
              INNER JOIN LND_TBOS.TollPlus_subsystems AS sub ON sub.subsystemcode = ptxn.subsystem
              INNER JOIN LND_TBOS.TollPlus_apptxntypes AS apptxn ON apptxn.apptxntypecode = pmtli.apptxntypecode
              INNER JOIN (
                SELECT DISTINCT
                    invoicenumber,
                    TollPlus_invoice_header.invoiceid
                    -- ,TP_Invoice_Receipts_Tracker.LND_UpdateType -- Removed this to avoid doubling	
                  FROM
                    LND_TBOS.TollPlus_invoice_header
                    INNER JOIN LND_TBOS.TollPlus_tp_invoice_receipts_tracker ON TollPlus_tp_invoice_receipts_tracker.invoiceid = TollPlus_invoice_header.invoiceid
                     AND TollPlus_tp_invoice_receipts_tracker.lnd_updatetype <> 'D'
                     --WHERE InvoiceNumber=1226895319
              ) AS ih ON irct.invoiceid = ih.invoiceid
              INNER JOIN LND_TBOS.TollPlus_tp_customer_plans AS cpl ON c.customerid = cpl.customerid
              INNER JOIN LND_TBOS.TollPlus_plans ON TollPlus_plans.planid = cpl.planid
              INNER JOIN (
                SELECT
                    invoice_lineitems_0.referenceinvoiceid AS invoicenumber,
                    count(DISTINCT invoice_lineitems_0.linkid) AS txncnt
                    --LND_UpdateType --Removed this to avoid doubling	
                  FROM
                    LND_TBOS.TollPlus_invoice_lineitems AS invoice_lineitems_0
                  WHERE invoice_lineitems_0.custtxncategory = 'TOLL'
                   AND invoice_lineitems_0.linkid > 0 -----This is to avoid duplicate count of Unassigned TXNs
                   AND invoice_lineitems_0.lnd_updatetype <> 'D'
                  GROUP BY  invoicenumber
              ) AS a ON a.invoicenumber = ih.invoicenumber
              INNER JOIN (
                SELECT
                    row_number() OVER (PARTITION BY invoice_lineitems_0.linkid ORDER BY CAST(invoice_lineitems_0.referenceinvoiceid as INT64) DESC) AS rn,
                    invoice_lineitems_0.*
                  FROM
                    LND_TBOS.TollPlus_invoice_lineitems AS invoice_lineitems_0
                  WHERE invoice_lineitems_0.custtxncategory = 'TOLL'
                   AND invoice_lineitems_0.linkid > 0
                   -----This is to avoid duplicate count of Unassigned TXNs
                   --AND ReferenceInvoiceID=1226895319
              ) AS invoice_lineitems ON invoice_lineitems.referenceinvoiceid = ih.invoicenumber
              LEFT OUTER JOIN (
                SELECT
                    orig_pmt.paymentid,
                    orig_pmt.paymentstatusid AS refpaymentstatusid,
                    orig_pmt.lnd_updatetype
                  FROM
                    LND_TBOS.Finance_paymenttxns AS orig_pmt
                    INNER JOIN (
                      SELECT
                          Finance_paymenttxns.refpaymentid
                        FROM
                          LND_TBOS.Finance_paymenttxns
                        WHERE Finance_paymenttxns.refpaymentid > 0
                         AND Finance_paymenttxns.paymentstatusid = 109
                         AND Finance_paymenttxns.lnd_updatetype <> 'D'
                         --AND RefPaymentID=181058859
                    ) AS ref_pmt ON ref_pmt.refpaymentid = orig_pmt.paymentid
                     AND orig_pmt.lnd_updatetype <> 'D'
              ) AS ref ON ptxn.refpaymentid = ref.paymentid
      ;
      --WHERE ISNULL(CAST(IH.InvoiceNumber AS BIGINT), -1)=1226895319 AND PTXN.PaymentID=181058859 AND Invoice_LineItems.LinkID=2044144627

      -- Log 
      SET log_message = 'Loaded EDW_TRIPS_STAGE.InvoicedFeePayment';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST('-1' as INT64), substr(CAST(-1 as STRING), 1, 2147483647));
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS_STAGE.InvoicedFeePayment' AS tablename,
            invoicedfeepayment.*
          FROM
            EDW_TRIPS_STAGE.InvoicedFeePayment
        ORDER BY 2 DESC
          LIMIT 100
        ;
      END IF;

      --=============================================================================================================
      -- Load Stage.PostpaidFleetPayment		->	 PostPaid Fleet Payments
      --=============================================================================================================

      -- DROP TABLE IF EXISTS EDW_TRIPS_STAGE.PostpaidFleetPayment;
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.PostpaidFleetPayment
        AS
          SELECT
              coalesce(CAST( invoice.invoicenumber as INT64), -1) AS invoicenumber,
              ct.custtripid,
              pmli.customerid,
              customerstatusid,
              usertypeid,
              cp.planid,
              CAST(CAST( pmtxn.paymentdate as STRING FORMAT 'YYYYMMDD') as INT64) AS paymentdayid,
              ct.txndate AS txnpaymentdate,
              coalesce(ct.invoiceid, 0) AS invoiceid,
              pmtxn.accountstatusid,
              coalesce(apptxn.apptxntypeid, -1) AS apptxntypeid,
              pmtxn.voucherno,
              sub.subsystemid,
              pmtxn.paymentmodeid,
              pmtxn.paymentstatusid,
              ref.refpaymentstatusid,
              pmtxn.paymentid,
              ct.overpaymentid,
              pmtxn.refpaymentid,
              coalesce(pmtxn.isvirtualcheck, 1) AS isvirtualcheck,
              coalesce(pmtxn.channelid, -1) AS channelid,
              coalesce(pmtxn.icnid, -1) AS icnid,
              coalesce(pmtxn.locationid, -1) AS locationid,
              coalesce(pmtxn.reftype, '-1') AS reftype,
              coalesce(pmtxn.reasontext, '-1') AS reasontext,
              -- pmtxn.activitytype,
              coalesce(pmtxn.approvedby, '-1') AS approvedby,
              coalesce(pmtxn.pmttxntype, '-1') AS pmttxntype,
              coalesce(ct.amountreceived, 0) AS amountreceived,
              pmtxn.txnamount,
              CAST(FORMAT('%44.6F', TRUNC( (pmli.lineitemamount)*1000000) /1000000) AS BIGNUMERIC) as lineitemamount,
              0 AS fnfeespaid,
              0 AS snfeespaid,
              CASE
                WHEN ct.lnd_updatetype = 'D'
                 OR pmtxn.lnd_updatetype = 'D'
                 OR pmli.lnd_updatetype = 'D'
                 OR invoice.lnd_updatetype = 'D'
                 OR ref.lnd_updatetype = 'D' THEN 1
                ELSE 0
              END AS deleteflag
              ---select COUNT(*)
            FROM
              LND_TBOS.TollPlus_tp_customer_trip_receipts_tracker AS ct
              INNER JOIN LND_TBOS.Finance_paymenttxns AS pmtxn ON ct.linkid = pmtxn.paymentid
               AND ct.linksourcename = 'FINANCE.PAYMENTTXNS'
               AND pmtxn.lnd_updatetype <> 'D'
              INNER JOIN LND_TBOS.Finance_paymenttxn_lineitems AS pmli ON ct.linkid = pmli.paymentid
               AND pmli.lnd_updatetype <> 'D'
              INNER JOIN LND_TBOS.TollPlus_apptxntypes AS apptxn ON pmli.apptxntypecode = apptxn.apptxntypecode
               AND apptxn.apptxntypeid NOT IN(
                2541, 2627, 2540, 2628, 2539, 2646, 2647, 2626
              )
               ----Cannot Bring Postpaid Fleet OverPayments because they are not reverted back to customer instead they are stores in Customer Account. So, Customer Payment Table will/should have these records
              INNER JOIN LND_TBOS.TollPlus_subsystems AS sub ON pmtxn.subsystem = sub.subsystemname
              INNER JOIN LND_TBOS.TollPlus_tp_customers AS c ON c.customerid = ct.customerid
               AND c.usertypeid IN(
                2, 3
              )
              INNER JOIN LND_TBOS.TollPlus_tp_customer_plans AS cp ON c.customerid = cp.customerid
              INNER JOIN LND_TBOS.TollPlus_plans ON TollPlus_plans.planid = cp.planid
               AND planname = 'Postpaid'
              LEFT OUTER JOIN (
                SELECT DISTINCT
                    TollPlus_invoice_header.invoicenumber,
                    TollPlus_invoice_header.invoiceid,
                    TollPlus_invoice_header.lnd_updatetype
                  FROM
                    LND_TBOS.TollPlus_invoice_header
              ) AS invoice ON invoice.invoiceid = ct.invoiceid
              LEFT OUTER JOIN (
                SELECT
                    orig_pmt.paymentid,
                    orig_pmt.paymentstatusid AS refpaymentstatusid,
                    orig_pmt.lnd_updatetype
                  FROM
                    LND_TBOS.Finance_paymenttxns AS orig_pmt
                    INNER JOIN (
                      SELECT
                          Finance_paymenttxns.refpaymentid
                        FROM
                          LND_TBOS.Finance_paymenttxns
                        WHERE Finance_paymenttxns.refpaymentid > 0
                         AND Finance_paymenttxns.paymentstatusid = 109
                    ) AS ref_pmt ON ref_pmt.refpaymentid = orig_pmt.paymentid
                     AND orig_pmt.lnd_updatetype <> 'D'
              ) AS ref ON pmtxn.refpaymentid = ref.paymentid
      ;

      --Log
      SET log_message = 'Loaded EDW_TRIPS_STAGE.PostpaidFleetPayment';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST('-1' as INT64), substr(CAST(-1 as STRING), 1, 2147483647));
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS_STAGE.PostpaidFleetPayment' AS tablename,
            postpaidfleetpayment.*
          FROM
            EDW_TRIPS_STAGE.PostpaidFleetPayment
        ORDER BY 2 DESC
          LIMIT 100
        ;
      END IF;

      --=============================================================================================================
      -- Load dbo.Fact_PaymentDetail						   
      --=============================================================================================================
      -- DROP TABLE IF EXISTS EDW_TRIPS.Fact_PaymentDetail_NEW;
      CREATE OR REPLACE TABLE EDW_TRIPS.Fact_PaymentDetail
        AS
          SELECT
              iuf.invoicenumber,
              iuf.invoiceid,
              iuf.tptripid,
              iuf.citationid,
              iuf.paymentid,
              iuf.overpaymentid,
              iuf.paymentdayid,
              iuf.paymentmodeid,
              iuf.paymentstatusid,
              iuf.refpaymentstatusid,
              iuf.apptxntypeid,
              iuf.laneid,
              iuf.customerid,
              iuf.customerstatusid,
              iuf.usertypeid AS accounttypeid,
              iuf.accountstatusid,
              iuf.planid,
              iuf.refpaymentid,
              iuf.voucherno,
              iuf.channelid,
              coalesce(iuf.locationid, -1) AS posid,
              iuf.icnid,
              iuf.isvirtualcheck,
              iuf.pmttxntype,
              iuf.subsystemid,
              iuf.txnpaymentdate,
              iuf.approvedby,
              iuf.reasontext,
              iuf.txnamount,
              CAST(FORMAT('%44.6F', TRUNC( (sum(iuf.lineitemamount))*1000000) /1000000) AS BIGNUMERIC) AS lineitemamount,
              sum(iuf.amountreceived) * -1 AS amountreceived,
              CAST(round(sum(iuf.fnfeespaid) * -1 , 11) AS BIGNUMERIC) AS fnfeespaid,
              CAST(round(sum(iuf.snfeespaid) * -1 , 11) AS BIGNUMERIC) AS snfeespaid,
              iuf.deleteflag,
              coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_update_date
            FROM
              (
                SELECT
                    transactionpayment.invoicenumber,
                    transactionpayment.invoiceid,
                    tptripid,
                    transactionpayment.citationid,
                    exitlaneid AS laneid,
                    transactionpayment.paymentid,
                    transactionpayment.overpaymentid,
                    transactionpayment.customerid,
                    transactionpayment.customerstatusid,
                    transactionpayment.usertypeid,
                    transactionpayment.planid,
                    transactionpayment.paymentdayid,
                    transactionpayment.paymentmodeid,
                    transactionpayment.paymentstatusid,
                    transactionpayment.refpaymentstatusid,
                    transactionpayment.refpaymentid,
                    transactionpayment.voucherno,
                    transactionpayment.reftype,
                    transactionpayment.accountstatusid,
                    transactionpayment.channelid,
                    transactionpayment.locationid,
                    transactionpayment.icnid,
                    transactionpayment.isvirtualcheck,
                    transactionpayment.pmttxntype,
                    transactionpayment.subsystemid,
                    transactionpayment.apptxntypeid,
                    transactionpayment.txnpaymentdate,
                    transactionpayment.approvedby,
                    transactionpayment.reasontext,
                    transactionpayment.txnamount,
                    CAST(FORMAT('%44.6F', TRUNC( (transactionpayment.lineitemamount )*1000000) /1000000) AS BIGNUMERIC) as lineitemamount,
                    transactionpayment.amountreceived,
                    0 AS fnfeespaid,
                    0 AS snfeespaid,
                    coalesce(transactionpayment.deleteflag, 0) AS deleteflag
                  FROM
                    EDW_TRIPS_STAGE.TransactionPayment
                    LEFT OUTER JOIN LND_TBOS.TollPlus_tp_violatedtrips ON TollPlus_tp_violatedtrips.citationid = transactionpayment.citationid
                UNION ALL
                SELECT
                    invoicedfeepayment.invoicenumber,
                    invoicedfeepayment.invoiceid,
                    tptripid,
                    invoicedfeepayment.citationid,
                    exitlaneid AS laneid,
                    invoicedfeepayment.paymentid,
                    invoicedfeepayment.overpaymentid,
                    invoicedfeepayment.customerid,
                    invoicedfeepayment.customerstatusid,
                    invoicedfeepayment.usertypeid,
                    invoicedfeepayment.planid,
                    invoicedfeepayment.paymentdayid,
                    invoicedfeepayment.paymentmodeid,
                    invoicedfeepayment.paymentstatusid,
                    invoicedfeepayment.refpaymentstatusid,
                    invoicedfeepayment.refpaymentid,
                    invoicedfeepayment.voucherno,
                    invoicedfeepayment.reftype,
                    invoicedfeepayment.accountstatusid,
                    invoicedfeepayment.channelid,
                    invoicedfeepayment.locationid,
                    invoicedfeepayment.icnid,
                    invoicedfeepayment.isvirtualcheck,
                    invoicedfeepayment.pmttxntype,
                    invoicedfeepayment.subsystemid,
                    invoicedfeepayment.apptxntypeid,
                    invoicedfeepayment.txnpaymentdate,
                    invoicedfeepayment.approvedby,
                    invoicedfeepayment.reasontext,
                    invoicedfeepayment.txnamount,
                    CAST(FORMAT('%44.6F', TRUNC( (invoicedfeepayment.lineitemamount )*1000000) /1000000) AS BIGNUMERIC) as lineitemamount,
                    invoicedfeepayment.amountreceived,
                    CAST(invoicedfeepayment.fnfeespaid  AS BIGNUMERIC) as fnfeespaid,
                    CAST(invoicedfeepayment.snfeespaid  AS BIGNUMERIC)  as snfeespaid,
                    coalesce(invoicedfeepayment.deleteflag, 0) AS deleteflag
                  FROM
                    EDW_TRIPS_STAGE.InvoicedFeePayment
                    LEFT OUTER JOIN LND_TBOS.TollPlus_tp_violatedtrips ON TollPlus_tp_violatedtrips.citationid = invoicedfeepayment.citationid
                UNION ALL
                SELECT
                    postpaidfleetpayment.invoicenumber,
                    postpaidfleetpayment.invoiceid,
                    tptripid,
                    postpaidfleetpayment.custtripid AS citationid,
                    exitlaneid AS laneid,
                    postpaidfleetpayment.paymentid,
                    postpaidfleetpayment.overpaymentid,
                    postpaidfleetpayment.customerid,
                    postpaidfleetpayment.customerstatusid,
                    postpaidfleetpayment.usertypeid,
                    postpaidfleetpayment.planid,
                    postpaidfleetpayment.paymentdayid,
                    postpaidfleetpayment.paymentmodeid,
                    postpaidfleetpayment.paymentstatusid,
                    postpaidfleetpayment.refpaymentstatusid,
                    postpaidfleetpayment.refpaymentid,
                    postpaidfleetpayment.voucherno,
                    postpaidfleetpayment.reftype,
                    postpaidfleetpayment.accountstatusid,
                    postpaidfleetpayment.channelid,
                    postpaidfleetpayment.locationid,
                    postpaidfleetpayment.icnid,
                    postpaidfleetpayment.isvirtualcheck,
                    postpaidfleetpayment.pmttxntype,
                    postpaidfleetpayment.subsystemid,
                    postpaidfleetpayment.apptxntypeid,
                    postpaidfleetpayment.txnpaymentdate,
                    postpaidfleetpayment.approvedby,
                    postpaidfleetpayment.reasontext,
                    postpaidfleetpayment.txnamount,
                    CAST(FORMAT('%44.6F', TRUNC( ( postpaidfleetpayment.lineitemamount)*1000000) /1000000) AS BIGNUMERIC) as lineitemamount,
                    postpaidfleetpayment.amountreceived,
                    CAST(postpaidfleetpayment.fnfeespaid  AS BIGNUMERIC)  as fnfeespaid,
                    CAST(postpaidfleetpayment.snfeespaid  AS BIGNUMERIC)  as snfeespaid,
                    coalesce(postpaidfleetpayment.deleteflag, 0) AS deleteflag
                  FROM
                    EDW_TRIPS_STAGE.PostpaidFleetPayment
                    LEFT OUTER JOIN LND_TBOS.TollPlus_tp_customertrips ON TollPlus_tp_customertrips.custtripid = postpaidfleetpayment.custtripid
              ) AS iuf
            WHERE iuf.deleteflag <> 1
            GROUP BY iuf.invoicenumber,iuf.invoiceid, iuf.citationid, tptripid, iuf.laneid, iuf.paymentid, iuf.overpaymentid, iuf.customerid, iuf.customerstatusid, iuf.usertypeid, iuf.planid, iuf.paymentdayid, iuf.paymentmodeid, iuf.paymentstatusid, iuf.refpaymentstatusid, iuf.refpaymentid, iuf.voucherno, iuf.reftype, iuf.accountstatusid, iuf.channelid, iuf.locationid, iuf.icnid, iuf.isvirtualcheck, iuf.pmttxntype, iuf.subsystemid, iuf.apptxntypeid, iuf.txnpaymentdate, iuf.approvedby, iuf.reasontext, iuf.txnamount, iuf.deleteflag
      ;

      -- Log
      SET log_message = 'Loaded EDW_TRIPS.Fact_PaymentDetail';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST('-1' as INT64), substr(CAST(-1 as STRING), 1, 2147483647));
      --TableSwap is Not Required, using  Create or Replace Table
      -- CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Fact_PaymentDetail_NEW', 'EDW_TRIPS.Fact_PaymentDetail');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Fact_PaymentDetail' AS tablename,
            *
          FROM
            EDW_TRIPS.Fact_PaymentDetail
        ORDER BY 2 DESC
          LIMIT 100
        ;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = '';  -- Rethrow the error all the way to Data Manager
      END;
    END;
       
/*

--:: Testing Zone

EXEC dbo.Fact_PaymentDetail_Full_Load
EXEC Utility.FromLog 'dbo.Fact_PaymentDetail_Full_Load', 1

SELECT 'Stage.TransactionPayment' TableName, * FROM Stage.TransactionPayment ORDER BY 2 DESC 
SELECT 'Stage.InvoicedFeePayment' TableName, * FROM Stage.InvoicedFeePayment ORDER BY 2 DESC 
SELECT 'Stage.PostpaidFleetPayment' TableName, * FROM Stage.PostpaidFleetPayment ORDER BY 2 DESC 
SELECT 'dbo.Fact_PaymentDetail' TableName, * FROM Fact_PaymentDetail ORDER BY 2 DESC 


*/
	
  END;