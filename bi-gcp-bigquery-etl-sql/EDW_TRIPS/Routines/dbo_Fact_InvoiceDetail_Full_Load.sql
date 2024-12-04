CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_InvoiceDetail_Full_Load`()
BEGIN

/*
IF OBJECT_ID ('dbo.Fact_InvoiceDetail_Full_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Fact_InvoiceDetail_Full_Load
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_InvoiceDetail table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838 	Bhanu/Gouthami	2020-01-04	New!
CHG0038039  Gouthami	    2021-01-27  Added Delete Flag
CHG0038304	Gouthami		2021-02-24	Changed the join condition on TransactionPostingType table to 
										ISNULL(TPV.TransactionPostingType,'Unknown') as it was eliminating the 
										TransactionPostingType = NULL records.
CHG0039112 	Gouthami 		2021-06-16  Modified the source column for Txndate from Invoice LineItems table
										to TP_Violatedtrips
CHG0039382 	Gouthami 		2021-07-26  Modified the ORDER BY clause from AgestageID column to Invoicedate for the 
										downgrading invoices.


===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_InvoiceDetail_Full_Load

EXEC Utility.FromLog 'dbo.Fact_InvoiceDetail', 1
SELECT TOP 100 'dbo.Fact_InvoiceDetail' Table_Name, * FROM dbo.Fact_InvoiceDetail ORDER BY 2
###################################################################################################################
*/

    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_InvoiceDetail_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      
		--=============================================================================================================
		-- Load dbo.Fact_InvoiceDetail
		--=============================================================================================================
		
      --DROP TABLE IF EXISTS EDW_TRIPS.Fact_InvoiceDetail_NEW;
      CREATE OR REPLACE TABLE EDW_TRIPS.Fact_InvoiceDetail
      PARTITION BY
      DATE_TRUNC(txndate, MONTH)
      OPTIONS ( require_partition_filter = FALSE)
        AS
          SELECT
              CAST(iltih.invoicenumber as INT64) AS invoicenumber,
              iltih.linkid AS citationid,
              coalesce(tpv.tptripid, -1) AS tptripid,
              iltih.customerid,
              tpv.exitlaneid AS laneid,
              iltih.agestageid,
              CASE
             WHEN iltih.rn= 1 THEN tpv.paymentstatusid
                ELSE -1
              END AS paymentstatusid,
              tpv.tripstageid,
              tpv.tripstatusid,
              tpv.transactiontypeid,
              pt.transactionpostingtypeid,
              CASE
             WHEN iltih.rn= 1
                 AND iltih.invoicedate = max(iltih.invoicedate) THEN invst.invoicestatusid
                ELSE -1
              END AS invoicestatusid,
              CASE
             WHEN iltih.rn= 1 THEN 1
                ELSE 0
              END AS currentinvflag,
              tpv.iswriteoff AS writeoffflag,
              -1 AS hvflag, --Null because on TBOS side TER was not ready . Need to work
              -1 AS ppflag, --Null because on TBOS side TER was not ready . Need to work
              -1 AS invoicedbadaddr,
              CAST(CAST(tpv.exittripdatetime as STRING FORMAT 'YYYY-MM-DD') as DATE) AS txndate,
              CAST(CAST(tpv.posteddate as STRING FORMAT 'YYYY-MM-DD') as DATE) AS posteddate,
              CASE
             WHEN iltih.rn= 1 THEN CAST(iltih.createddate as DATE) 
                ELSE CAST('1900-01-01' AS DATE)
              END AS zcinvoicedate,
              CASE
                WHEN CASE
               WHEN iltih.rn= 1 THEN 1
                  ELSE 0
                END = 1 THEN iltxn.fnfeesdate
                ELSE DATE '1900-01-01'
              END AS fnfeesdate,
              CASE
                WHEN CASE
               WHEN iltih.rn= 1 THEN 1
                  ELSE 0
                END = 1 THEN iltxn.snfeesdate
                ELSE DATE '1900-01-01'
              END AS snfeesdate,
              CASE
             WHEN iltih.rn= 1 THEN CAST(tpv.writeoffdate as DATE)
                ELSE CAST('1900-01-01' AS DATE)
              END AS writeoffdate,
              iltih.txntype,
              CASE
             WHEN iltih.rn= 1 THEN tpv.outstandingamount
                ELSE 0
              END AS outstandingamount,
              CASE
             WHEN iltih.rn= 1 THEN tpv.pbmtollamount
                ELSE 0
              END AS pbmtollamount,
              CASE
             WHEN iltih.rn= 1 THEN tpv.avitollamount
                ELSE 0
              END AS avitollamount,
              CASE
             WHEN iltih.rn= 1 THEN iltih.amount
                ELSE 0
              END AS tolls,
              CASE
                 CASE
               WHEN iltih.rn= 1 THEN tpv.paymentstatusid
                  ELSE -1
                END
                WHEN 456 THEN tpv.tollamount
                WHEN 457 THEN (tpv.tollamount - tpv.outstandingamount)
                ELSE 0
              END AS tollspaid,
              CASE
             WHEN iltih.rn= 1 THEN  CAST(FORMAT('%44.6F', TRUNC(max(coalesce(iltxn.adminfee1, 0))/ nullif(max(iltxn.txncnt), 0)*1000000) /1000000) AS BIGNUMERIC) 
                ELSE 0
              END AS fnfees,
              CASE
             WHEN iltih.rn= 1 THEN  CAST(FORMAT('%44.6F', TRUNC(max(coalesce(iltxn.adminfee2, 0))/ nullif(max(iltxn.txncnt), 0)*1000000) /1000000) AS BIGNUMERIC) 
                ELSE 0
              END AS snfees,
              CASE
             WHEN iltih.rn= 1 THEN  CAST(FORMAT('%44.6F', TRUNC(max(coalesce(iltxn.paidadminfee1, 0))/ nullif(max(iltxn.txncnt), 0)*1000000) /1000000) AS BIGNUMERIC) 
                ELSE 0
              END AS fnfeespaid,
              CASE
             WHEN iltih.rn= 1 THEN  CAST(FORMAT('%44.6F', TRUNC(max(coalesce(iltxn.paidadminfee2, 0))/ nullif(max(iltxn.txncnt), 0)*1000000) /1000000) AS BIGNUMERIC) 
                ELSE 0
              END AS snfeespaid,
              CASE
             WHEN iltih.rn= 1 THEN  CAST(FORMAT('%44.6F', TRUNC(max(coalesce(iltxn.fnfeesoutstandingamount, 0))/ nullif(max(iltxn.txncnt), 0)*1000000) /1000000) AS BIGNUMERIC) 
                ELSE 0
              END AS fnfeesoutstandingamount,
              CASE
             WHEN iltih.rn= 1 THEN  CAST(FORMAT('%44.6F', TRUNC(max(coalesce(iltxn.snfeesoutstandingamount, 0))/ nullif(max(iltxn.txncnt), 0)*1000000) /1000000) AS BIGNUMERIC) 
                ELSE 0
              END AS snfeesoutstandingamount,
              CASE
             WHEN iltih.rn= 1 THEN tpv.writeoffamount
                ELSE 0
              END AS writeoffamount,
              CASE
                WHEN iltih.lnd_updatetype = 'D'
                 OR iltih.lnd_updatetype = 'D'
                 OR tpv.lnd_updatetype = 'D'
                 OR tpct.lnd_updatetype = 'D' THEN 1
                ELSE 0
              END AS deleteflag,
              coalesce(current_datetime(), DATETIME '1900-01-01') AS edw_updatedate
            FROM
              (SELECT ih.agestageid,
                      ih.customerid,
                      ih.invoicedate,
                      ih.invoicenumber,
                      ih.lnd_updatetype,
                      ilt.amount,
                      ilt.createddate,
                      ilt.linkid,
                      ilt.lnd_updatetype as lnd_updatetype1,
                      ilt.txntype,invoicestatus,txndate,row_number() OVER (PARTITION BY ilt.linkid ORDER BY cast(ih.invoicenumber as INT64) DESC,ih.invoicedate DESC) rn FROM LND_TBOS.TollPlus_Invoice_Header AS ih
                    INNER JOIN LND_TBOS.TollPlus_Invoice_LineItems AS ilt ON ih.invoicenumber = ilt.referenceinvoiceid
                    AND linksourcename = 'TOLLPLUS.TP_VIOLATEDTRIPS'
                    AND ilt.linkid > 0
                    AND ilt.lnd_updatetype <> 'D'
              ) iltih
              INNER JOIN LND_TBOS.TollPlus_tp_violatedtrips AS tpv ON iltih.linkid = tpv.citationid
               AND tpv.lnd_updatetype <> 'D'
              INNER JOIN EDW_TRIPS.dim_transactionpostingtype AS pt ON pt.transactionpostingtype = coalesce(tpv.transactionpostingtype, 'Unknown')
              INNER JOIN (
                SELECT
                    invcurrtxn.invoicenumber,
                    sum(CASE
                      WHEN invcurrtxn.txnflag = 1 THEN 1
                      ELSE 0
                    END) AS txncnt,
                    ict.adminfee1 AS adminfee1,
                    ict.adminfee2 AS adminfee2,
                    ict.paidadminfee1 AS paidadminfee1,
                    ict.paidadminfee2 AS paidadminfee2,
                    ict.fnfeesdate,
                    ict.snfeesdate,
                    ict.fnfeesoutstandingamount,
                    ict.snfeesoutstandingamount
                  FROM
                    (
                      SELECT
                          TollPlus_Invoice_Header.invoicenumber,
                          row_number() OVER (PARTITION BY TollPlus_Invoice_LineItems.linkid ORDER BY CAST(TollPlus_Invoice_Header.invoicenumber as INT64) DESC, TollPlus_Invoice_Header.agestageid DESC) AS txnflag
                        FROM
                          LND_TBOS.TollPlus_Invoice_LineItems
                          INNER JOIN LND_TBOS.TollPlus_Invoice_Header ON invoicenumber = referenceinvoiceid
                           AND linksourcename IN(
                            'TOLLPLUS.TP_VIOLATEDTRIPS'
                          )
                           AND TollPlus_Invoice_Header.invoiceid = TollPlus_Invoice_LineItems.invoiceid
                           AND linkid > 0
                        WHERE TollPlus_Invoice_LineItems.lnd_updatetype <> 'D'
                         AND TollPlus_Invoice_Header.lnd_updatetype <> 'D'
                    ) AS invcurrtxn
                    LEFT OUTER JOIN (
                      SELECT
                          invoicenumber,
                          sum(CASE
                            WHEN feecode = 'FSTNTVFEE' THEN amount
                            ELSE 0
                          END) AS adminfee1,
                          sum(CASE
                            WHEN feecode = 'SECNTVFEE' THEN amount
                            ELSE 0
                          END) AS adminfee2,
                          sum(CASE
                            WHEN feecode = 'FSTNTVFEE'
                             AND paymentstatusid = 456 THEN amount
                            WHEN feecode = 'FSTNTVFEE'
                             AND paymentstatusid = 457 THEN (amount - outstandingamount)
                            ELSE 0
                          END) AS paidadminfee1,
                          sum(CASE
                            WHEN feecode = 'SECNTVFEE'
                             AND paymentstatusid = 456 THEN amount
                            WHEN feecode = 'SECNTVFEE'
                             AND paymentstatusid = 457 THEN (amount - outstandingamount)
                            ELSE 0
                          END) AS paidadminfee2,
                          max(CASE
                            WHEN feecode = 'FSTNTVFEE' THEN CAST(TollPlus_invoice_charges_tracker.createddate as DATE)
                            ELSE DATE '1900-01-01'
                          END) AS fnfeesdate,
                          max(CASE
                            WHEN feecode = 'SECNTVFEE' THEN CAST(TollPlus_invoice_charges_tracker.createddate as DATE)
                            ELSE DATE '1900-01-01'
                          END) AS snfeesdate,
                          sum(CASE
                            WHEN feecode = 'FSTNTVFEE' THEN outstandingamount
                            ELSE 0
                          END) AS fnfeesoutstandingamount,
                          sum(CASE
                            WHEN feecode = 'SECNTVFEE' THEN outstandingamount
                            ELSE 0
                          END) AS snfeesoutstandingamount
                        FROM
                          LND_TBOS.TollPlus_invoice_charges_tracker
                          INNER JOIN LND_TBOS.TollPlus_invoice_header ON TollPlus_Invoice_Header.invoiceid = TollPlus_invoice_charges_tracker.invoiceid
                        WHERE TollPlus_invoice_charges_tracker.lnd_updatetype <> 'D'
                         AND TollPlus_Invoice_Header.lnd_updatetype <> 'D'
                        GROUP BY invoicenumber
                    ) AS ict ON ict.invoicenumber = invcurrtxn.invoicenumber
                  GROUP BY ict.adminfee1, ict.adminfee2, ict.paidadminfee1, ict.paidadminfee2, invcurrtxn.invoicenumber, ict.fnfeesdate, ict.snfeesdate, ict.fnfeesoutstandingamount, ict.snfeesoutstandingamount
              ) AS iltxn ON iltxn.invoicenumber = iltih.invoicenumber
              LEFT OUTER JOIN lnd_tbos.tollplus_tp_violated_trip_charges_tracker AS tpct ON tpct.citationid = tpv.citationid
               AND tpct.lnd_updatetype <> 'D'
              LEFT OUTER JOIN EDW_TRIPS.dim_invoicestatus AS invst ON invst.invoicestatuscode = iltih.invoicestatus 
            GROUP BY invoicenumber, tptripid, CAST(CAST( iltih.txndate as STRING FORMAT 'YYYY-MM-DD') as DATE), iltih.agestageid, zcinvoicedate, iltih.linkid, tpv.exitlaneid, iltih.customerid, pt.transactionpostingtypeid, tpv.iswriteoff, iltih.txntype, tpv.exittripdatetime, iltxn.fnfeesdate, iltxn.snfeesdate, tpv.outstandingamount, tpv.pbmtollamount, tpv.avitollamount, tpv.tollamount, tpv.writeoffamount, iltih.amount, posteddate, tpv.writeoffdate, tpv.paymentstatusid, tpv.tripstageid, tpv.tripstatusid, tpv.transactiontypeid, deleteflag, invst.invoicestatusid, iltih.invoicedate, rn
            ;
      SET log_message = 'Loaded dbo.Fact_InvoiceDetail';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));

      -- TableSwap is Not Required, using  Create or Replace Table
      -- CALL EDW_TRIPS_SUPPORT.TableSwap('dbo.Fact_InvoiceDetail_NEW', 'dbo.Fact_InvoiceDetail');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      IF trace_flag = 1 THEN
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date);
      END IF;
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Fact_InvoiceDetail' AS tablename,
            *
          FROM
            EDW_TRIPS.Fact_InvoiceDetail
        ORDER BY
          2 DESC
        LIMIT 1000
        ;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = error_message; -- Rethrow the error!
      END;
    END;

    /*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================
EXEC dbo.Fact_InvoiceDetail_Full_Load

EXEC Utility.FromLog 'dbo.Fact_InvoiceDetail', 1
SELECT TOP 100 'dbo.Fact_InvoiceDetail' Table_Name, * FROM dbo.Fact_InvoiceDetail ORDER BY 2

--===============================================================================================================
-- !!! USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel !!! 
--===============================================================================================================


*/



  END;