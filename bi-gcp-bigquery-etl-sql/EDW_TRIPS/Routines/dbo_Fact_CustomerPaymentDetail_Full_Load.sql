CREATE OR REPLACE PROCEDURE EDW_TRIPS.Fact_CustomerPaymentDetail_Full_Load()
BEGIN
/*
###################################################################################################################

Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_CustomerPaymentDetail table for Recap Deferred Revenue Detail Report. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Shankar 	2020-11-24	New!
CHG0037922	Shankar		2021-01-20 	Change adjustment date to ApprovedStatusDate as per TollPlus updated logic
CHG0038039	Shankar		2021-01-27	Add DeleteFlag. Skip Deleted rows for now.
CHG0038104	Shankar		2021-02-03	Load missing adjustment transactions PRETOLLADJCR for “Account Level Fee Credit” 
CHG0038359	Shankar		2021-02-13	Added RefPaymentStatusID needed for Overpayment Txns
CHG0039407  Shankar		2021-08-05	1. Use OriginalPayTypeID column instead of PayTypeId in RefundRequests_Queue table
									2. Include. Adj Txn. PRESTMTREPRNTFEE, PRESTMTREPRNTFEENEGBAL
									3. Ignore. Payment Txn. CSCCCREFUND, CSCCHKREFUND
									4. Ignore. Adj Txn. ADJRFNDDR, PRECR, PREDR, PRETOLLADJDECEASEDCR
CHG0042378	Shankar		2023-01-30	"Account Level Fee Debit" logic change in Recap Detail report
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_CustomerPaymentDetail_Full_Load

EXEC Utility.FromLog 'dbo.Fact_CustomerPaymentDetail', 1
SELECT TOP 100 'dbo.Fact_CustomerPaymentDetail' Table_Name, * FROM dbo.Fact_CustomerPaymentDetail ORDER BY 2
###################################################################################################################

*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_CustomerPaymentDetail_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;

    BEGIN
      DECLARE load_cutoff_date DATE DEFAULT '2018-01-01';
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));

      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.CustomerPaymentDetail CLUSTER BY PaymentLineItemID
      AS
        SELECT
            li.lineitemid AS paymentlineitemid,
            li.paymentid,
            li.customerid,
            cp.planid,
            p.customerplandesc,
            'Payment' AS customerpaymenttype,
            att.apptxntypeid,
            li.apptxntypecode,
            att.apptxntypedesc,
            CASE
              --Current Deferred Revenue --> Cash --> Total Bank Deposit --> Cash
              WHEN li.apptxntypecode IN(
                'CSCCASHPMT', 'CSCREVCASHPMT', 'CSCVOIDCASHPMT', 'APPZCTOPRECASHPMT', 'APPPREDQCASHPMT'
              ) 
              THEN 1
              --Current Deferred Revenue --> Cash --> Total Bank Deposit --> Checks
              WHEN li.apptxntypecode IN(
                'CSCCHKPMT', 'CSCCRTFIDCHKPMT', 'CSCCASHIERCHKPMT', 'CSCREVCHKPMT', 'CSCREVCRTFIDCHKPMT', 'CSCREVCASHIERCHKPMT', 'CSCVOIDCHKPMT', 'CSCVOIDCRTFIDCHKPMT', 'CSCVOIDCASHIERCHKPMT', 'APPZCTOPRECHKPMT', 'APPZCTOPRECASHIERCHKPMT', 'APPZCTOPRECRTFIDCHKPMT', 'APPPREDQCHKPMT', 'APPPREDQCASHIERCHKPMT', 'APPPREDQCRTFIDCHKPMT'
              ) 
              THEN 2
              --Current Deferred Revenue --> Cash --> Total Bank Deposit --> Money Order
              WHEN li.apptxntypecode IN(
                'CSCMOPMT', 'APPZCTOPREMOPMT', 'APPPREDQMOPMT'
              ) 
              THEN 3
              --Current Deferred Revenue --> Cash --> Total Refunds/Bounced Checks --> Bounced Checks
              WHEN li.apptxntypecode IN(
                'APPBOUNCEDCHK'
              ) THEN 5
              --Current Deferred Revenue --> Credit --> Total Credit Card Charges --> Credit Card Charges
              WHEN li.apptxntypecode IN(
                'CSCCCPMT', 'CSCREVCCPMT', 'DALCCPMT', 'APPZCTOPRECCPMT', 'APPPREDQCCPMT', 'CSCVOIDCCPMT', 'DFWCCPMT'
              )
                AND pmt.paymentstatusid IN(
                109, 119, 3182
              ) 
              THEN 6
              --Current Deferred Revenue --> Credit --> Total Credit Card Charges --> Autocharges
              WHEN li.apptxntypecode IN(
                'AUTOPAYCC', 'AUTOPAYDC'
              )
                AND pmt.refpaymentid = 0 
              THEN 7
              --Current Deferred Revenue --> Credit --> Total Credit Refund/Chargebacks --> Credit Card Refund
              WHEN li.apptxntypecode IN(
                'DALCCPMTREF', 'DFWCCPMTREF'
              ) 
              THEN 8
              --Current Deferred Revenue --> Credit --> Total Credit Refund/Chargebacks --> Autocharge Refunds
              WHEN li.apptxntypecode = 'AUTOPAYCC'
                AND pmt.refpaymentid > 0 
              THEN 9
              --Current Deferred Revenue --> Credit --> Total Credit Refund/Chargebacks --> Chargebacks
              WHEN li.apptxntypecode IN(
                        'CSCCBREVCCPMT'
                      ) 
              THEN 10
              --Current Deferred Revenue --> Third Party --> Total Third Party Cash Receipt --> ACE Cash Express
              WHEN ch.channelname = 'ACECashExpress' 
              THEN 11
              --Current Deferred Revenue --> Third Party --> Total Third Party Cash Receipt --> Lockbox Payment
              WHEN li.apptxntypecode = 'APPLOCKBOXPMT' 
              THEN 12
              --Current Deferred Revenue --> Third Party --> Total Third Party Cash Receipt --> Lockbox Reversal
              WHEN li.apptxntypecode = 'APPLOCKBOXREV' 
              THEN 13
            ELSE -1
            END AS customerpaymentlevelid,
            CASE
              WHEN li.apptxntypecode IN(
                'CSCREVCASHPMT', 'CSCVOIDCASHPMT', 'CSCREVCASHIERCHKPMT', 'CSCREVCHKPMT',  'CSCREVCRTFIDCHKPMT', 'CSCVOIDCASHIERCHKPMT', 'CSCVOIDCHKPMT', 'CSCVOIDCRTFIDCHKPMT', 'APPBOUNCEDCHK', 'DALCCPMTREF', 'DFWCCPMTREF', 'CSCCBREVCCPMT', 'APPLOCKBOXREV'
              ) 
              THEN li.lineitemamount * -1
              WHEN li.apptxntypecode IN(
                'CSCREVCCPMT', 'CSCVOIDCCPMT'
              )
                AND pmt.paymentstatusid IN(
                109, 119, 3182
              ) 
              THEN li.lineitemamount * -1
              WHEN li.apptxntypecode IN(
                'AUTOPAYCC', 'AUTOPAYDC'
              )
                AND pmt.refpaymentid = 0 
              THEN li.lineitemamount
              WHEN li.apptxntypecode IN(
                'AUTOPAYCC'
              )
                AND pmt.refpaymentid > 0 
              THEN li.lineitemamount * -1
            ELSE li.lineitemamount
            END AS lineitemamount,
            li.paymentdate AS paymentdate,
            pmt.channelid AS channelid,
            ch.channelname AS paymentchannelname,
            pmt.paymentmodeid,
            pm.paymentmodecode,
            pmt.paymentstatusid,
            ps.paymentstatuscode,
            pmt.refpaymentid,
            ref.refpaymentstatusid,
            CASE
              WHEN pmt.lnd_updatetype = 'D'
                OR li.lnd_updatetype = 'D' 
              THEN 1
            ELSE 0
            END AS deleteflag,
            current_datetime() AS edw_update_date
            FROM
              LND_TBOS.Finance_PaymentTxns AS pmt
              INNER JOIN LND_TBOS.Finance_PaymentTxn_LineItems AS li 
                ON li.paymentid = pmt.paymentid
              INNER JOIN LND_TBOS.Tollplus_TP_Customer_Plans AS cp 
                ON li.customerid = cp.customerid
              LEFT OUTER JOIN EDW_TRIPS.Dim_CustomerPlan AS p 
                ON cp.planid = p.customerplanid
              LEFT OUTER JOIN EDW_TRIPS.Dim_Channel AS ch 
                ON pmt.channelid = ch.channelid
              LEFT OUTER JOIN EDW_TRIPS.Dim_PaymentStatus AS ps 
                ON pmt.paymentstatusid = ps.paymentstatusid
              LEFT OUTER JOIN EDW_TRIPS.Dim_AppTxnType AS att 
                ON li.apptxntypecode = att.apptxntypecode
              LEFT OUTER JOIN EDW_TRIPS.Dim_PaymentMode AS pm 
                ON pmt.paymentmodeid = pm.paymentmodeid
              LEFT OUTER JOIN 
              (
                  SELECT
                    orig_pmt.paymentid,
                    orig_pmt.paymentstatusid AS refpaymentstatusid
                  FROM
                    LND_TBOS.Finance_PaymentTxns AS orig_pmt
                    INNER JOIN 
                    (
                      SELECT
                          pt.refpaymentid
                        FROM
                          LND_TBOS.Finance_PaymentTxns AS pt
                        WHERE pt.refpaymentid > 0
                         AND pt.paymentstatusid = 109
                         AND pt.lnd_updatetype <> 'D'
                    ) AS ref_pmt 
                      ON ref_pmt.refpaymentid = orig_pmt.paymentid
                      AND orig_pmt.lnd_updatetype <> 'D'
              ) AS ref 
                ON ref.paymentid = pmt.refpaymentid
            WHERE pmt.paymentstatusid IN(
              109, 119, 3182
            ) --Success, Reveresed, Voided
             AND li.apptxntypecode NOT IN(
              'CSCCHKREFUND', 'CSCCCREFUND'
            ) --This code is used to affect refundbal of prepaid accounts. This can be ignored.
             AND pmt.lnd_updatetype <> 'D'
             AND li.lnd_updatetype <> 'D'
      ;
      SET log_message = 'Loaded EDW_TRIPS_STAGE.CustomerPaymentDetail';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      --=============================================================================================================
      -- Load Stage.CustomerAdjustmentDetail
      --=============================================================================================================

      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.CustomerAdjustmentDetail CLUSTER BY adjlineitemid
      AS
        SELECT
            li.adjlineitemid AS adjlineitemid,
            li.adjustmentid,
            adj.customerid,
            cp.planid,
            p.customerplandesc,
            'Adjustment' AS customerpaymenttype,
            att.apptxntypeid,
            li.apptxntypecode,
            att.apptxntypedesc,
            CASE
              --Current Deferred Revenue --> Cash --> Total Refunds/Bounced Checks --> Refund Checks
              WHEN li.apptxntypecode = 'ADJPRERFND'
                AND pm.paymentmodecode = 'Cheque' 
              THEN 4
              --Current Deferred Revenue --> Credit --> Total Credit Refund/Chargebacks --> Credit Card Refund
              WHEN li.apptxntypecode = 'ADJPRERFND'
                AND pm.paymentmodecode = 'CreditCard' 
              THEN 8
              --Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Lost/Stolen Tag Fees
              WHEN li.apptxntypecode IN(
                'TAGLOST', 'TAGSTOLEN'
              ) 
              THEN 14
              --Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Recovered Tag Credit
              WHEN li.apptxntypecode IN(
                'TAGLSTASGN', 'TAGSTLASGN'
              ) 
              THEN 15
              --Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Statement Fee
              WHEN li.apptxntypecode = 'STMNTCHRGFEE'
                AND adj.drcrflag = 'D' 
              THEN 16
              --Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Statement Fee Credit
              WHEN li.apptxntypecode = 'STMNTCHRGFEE'
                AND adj.drcrflag = 'C' 
              THEN 17
              --Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Account Level Fee Debit 
              WHEN (li.apptxntypecode IN(
                'CSCUSPSFEE', 'CSCSTMTREPRINTFEE', 'CSCSMSFEE', 'CSCEMAILFEE', 'CSCCHARGEBACKFEE', 'CSCNSFFEE', 'CSCCOLLFEE', 'CSCSTMTDELFEE', 'SHIPPING', 'ADJUSTMENT', 'TRANSRTBTOZIPCASH', 'ACCMERGECHILD', 'TRANSOVRPMTTOPRE', 'PRESTMTREPRNTFEE', 'PRESTMTREPRNTFEENEGBAL'
              )
                OR li.apptxntypecode = 'PRETOLLADJDR'
                AND li.linksourcename = 'TOLLPLUS.TP_CUSTOMERS')
                AND adj.drcrflag = 'D' 
              THEN 18
              --Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Account Level Fee Credit
              WHEN (li.apptxntypecode IN(
                'CSCUSPSFEE', 'REVCSCSTMTREPRINTFEE', 'REVCSCSMSFEE', 'REVCSCEMAILFEE', 'REVCSCCHARGEBACKFEE', 'REVCSCNSFFEE', 'REVCSCCOLLFEE', 'TAGRQCANSHIPPING', 'TRANSRFNDTOTB', 'TRANSRZIPCASHTOTB', 'TRANSOVRPMTTOPRE', 'ADJUSTMENT', 'ACCMERGE', 'REVCSCSTMTDELFEE'
              )
                OR li.apptxntypecode IN(
                'PRETOLLADJCR'
              )
                AND li.linksourcename = 'TOLLPLUS.TP_CUSTOMERS')
                AND adj.drcrflag = 'C' 
              THEN 19
              --Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Speciality Tag Fee
              WHEN li.apptxntypecode = 'SPECIALITYTAGFEE' 
              THEN 20
              --Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Speciality Tag Fee Credit
              WHEN li.apptxntypecode = 'TAGRQCANSPECFEE' 
              THEN 21
              --Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Escheatment  
              WHEN li.apptxntypecode = 'ADJTOLLAMTESCHEAT' 
              THEN 22
              --Current AVI Revenue Transactions --> Fee --> Fee Revenue --> Close Out Balance
              WHEN li.apptxntypecode = 'ADJBDEXPDR' 
              THEN 23
            ELSE -1
            END AS customerpaymentlevelid,
            CASE
              WHEN li.apptxntypecode IN(
                /*  4. Total Refunds/Bounced Checks       
							      8.Credit Card Refunds  */  'ADJPRERFND', 
                /* 14. Lost/Stolen Tag Fees */ 'TAGLOST', 'TAGSTOLEN', 
                /* 24. Speciality Tag Fee */   'SPECIALITYTAGFEE', 
                /* 26. Escheatment */          'ADJTOLLAMTESCHEAT', 
                /* 27. Close Out Balance */	   'ADJBDEXPDR'
              ) 
              THEN li.amount * -1
                /* 16. Statement Fee */   
              WHEN li.apptxntypecode = 'STMNTCHRGFEE'
                AND adj.drcrflag = 'D' 
              THEN li.amount * -1
              WHEN (  /* 18. Account Level Fee Debit */ 
                li.apptxntypecode IN
                (
                  'CSCUSPSFEE', 'CSCSTMTREPRINTFEE', 'CSCSMSFEE', 'CSCEMAILFEE', 'CSCCHARGEBACKFEE', 'CSCNSFFEE', 'CSCCOLLFEE', 'CSCSTMTDELFEE', 'SHIPPING', 'ADJUSTMENT', 'TRANSRTBTOZIPCASH', 'ACCMERGECHILD', 'TRANSOVRPMTTOPRE', 'PRESTMTREPRNTFEE', 'PRESTMTREPRNTFEENEGBAL'
                )
                OR li.apptxntypecode = 'PRETOLLADJDR'
                AND li.linksourcename = 'TOLLPLUS.TP_CUSTOMERS')
                AND adj.drcrflag = 'D' 
              THEN li.amount * -1
            ELSE li.amount
            END AS lineitemamount,
            adj.approvedstatusdate,
            rrq.originalpaytypeid AS paymentmodeid,
            pm.paymentmodecode,
            adj.approvedstatusid AS adjapprovalstatusid,
            adj.drcrflag,
            CASE
              WHEN adj.lnd_updatetype = 'D'
                OR li.lnd_updatetype = 'D' THEN 1
              ELSE 0
            END AS deleteflag
          FROM
            LND_TBOS.Finance_Adjustments AS adj
            INNER JOIN LND_TBOS.Finance_Adjustment_LineItems AS li 
              ON li.adjustmentid = adj.adjustmentid
            INNER JOIN LND_TBOS.Tollplus_TP_Customer_Plans AS cp 
              ON adj.customerid = cp.customerid
            LEFT OUTER JOIN EDW_TRIPS.Dim_CustomerPlan AS p 
              ON cp.planid = p.customerplanid
            LEFT OUTER JOIN EDW_TRIPS.Dim_AdjApprovalStatus AS aas 
              ON adj.approvedstatusid = aas.adjapprovalstatusid
            LEFT OUTER JOIN EDW_TRIPS.Dim_AppTxnType AS att 
              ON li.apptxntypecode = att.apptxntypecode
            LEFT OUTER JOIN LND_TBOS.Finance_RefundRequests_Queue AS rrq 
              ON adj.refundrequestid = rrq.refundrequestid
            LEFT OUTER JOIN EDW_TRIPS.Dim_PaymentMode AS pm 
              ON rrq.originalpaytypeid = pm.paymentmodeid
          WHERE adj.approvedstatusid = 466
            AND adj.approvedstatusdate >= load_cutoff_date
            AND (li.apptxntypecode NOT IN(
            'ASSIGNTAG', 'PRETOLLADJCR', 'PRETOLLADJDR', 'PRETOLLADJFIRSTRESPONDERCR', 'TRIPDISMISS', 'PRETOLLADJEXCUSALCR', -- Traffic. Separate data source Fact_TollTransaction.
            'ADJRFNDCR', -- We should ignore this one. Not right one for PrePaid; This is for Refund. One Txn activity involves two AppTxnTypeCodes. TollPlus uses ADJPRERFND (1st Txn), we caught ADJRFNDCR (2nd Txn).
            'ADJRFNDDR', -- This code is used to affect refundbal of prepaid accounts. This can be ignored.
            'PRECR', 'PREDR', -- This code is used for prepaid toll adjustments. We donot use codes to derive toll adjustments.This is already included in recap traffic section. This can be ignored
            'PRETOLLADJDECEASEDCR' -- Included in the Traffic part
          )
            OR li.apptxntypecode IN(
            'PRETOLLADJCR'
          )
            AND li.linksourcename = 'TOLLPLUS.TP_CUSTOMERS'
            AND adj.drcrflag = 'C' /* 19. Account Level Fee Credit */
            OR li.apptxntypecode IN(
            'PRETOLLADJDR'
          )
            AND li.linksourcename = 'TOLLPLUS.TP_CUSTOMERS'
            AND adj.drcrflag = 'D') /* 18. Account Level Fee Debit */
            AND adj.lnd_updatetype <> 'D'
            AND li.lnd_updatetype <> 'D'
        ;
      SET log_message = 'Loaded EDW_TRIPS_STAGE.CustomerAdjustmentDetail';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));


      CREATE OR REPLACE TABLE EDW_TRIPS.Fact_CustomerPaymentDetail CLUSTER BY CustomerPaymentDetailID
      AS
        SELECT
            coalesce(100000000000 + customerpaymentdetail.paymentlineitemid, 0) AS customerpaymentdetailid,
            coalesce(CAST( customerpaymentdetail.paymentlineitemid as INT64), 0) AS paymentlineitemid,
            coalesce(CAST( customerpaymentdetail.paymentid as INT64), 0) AS paymentid,
            coalesce(CAST(NULL as INT64), 0) AS adjlineitemid,
            coalesce(CAST(NULL as INT64), 0) AS adjustmentid,
            coalesce(CAST(customerpaymentdetail.customerid as INT64), -1) AS customerid,
            1 AS customerpaymenttypeid,
            coalesce(CAST(customerpaymentdetail.apptxntypeid as INT64), -1) AS apptxntypeid,
            coalesce(customerpaymentdetail.customerpaymentlevelid, -1) AS customerpaymentlevelid,
            coalesce(CAST(CAST(customerpaymentdetail.paymentdate as STRING FORMAT 'YYYYMMDD') as INT64), -1) AS paymentdayid,
            coalesce(CAST(customerpaymentdetail.channelid as INT64), -1) AS channelid,
            coalesce(CAST(customerpaymentdetail.paymentmodeid as INT64), 0) AS paymentmodeid,
            coalesce(CAST(customerpaymentdetail.paymentstatusid as INT64), 0) AS paymentstatusid,
            CAST(customerpaymentdetail.refpaymentid as INT64) AS refpaymentid,
            coalesce(CAST(customerpaymentdetail.refpaymentstatusid as INT64), 0) AS refpaymentstatusid,
            CAST(NULL as STRING) AS drcrflag,
            CAST(customerpaymentdetail.lineitemamount as NUMERIC) AS lineitemamount,
            coalesce(customerpaymentdetail.deleteflag, 0) AS deleteflag,
            CAST(customerpaymentdetail.paymentdate as DATETIME) AS paymentdate,
            coalesce(customerpaymentdetail.edw_update_date, DATETIME '1900-01-01') AS edw_update_date
        FROM
          EDW_TRIPS_STAGE.CustomerPaymentDetail
        UNION ALL
        SELECT
            coalesce(200000000000 + customeradjustmentdetail.adjlineitemid, 0) AS customerpaymentdetailid,
            coalesce(CAST(NULL as INT64), 0) AS paymentlineitemid,
            coalesce(CAST(NULL as INT64), 0) AS paymentid,
            coalesce(CAST(customeradjustmentdetail.adjlineitemid as INT64), 0) AS adjlineitemid,
            coalesce(CAST(customeradjustmentdetail.adjustmentid as INT64), 0) AS adjustmentid,
            coalesce(CAST(customeradjustmentdetail.customerid as INT64), -1) AS customerid,
            2 AS customerpaymenttypeid,
            coalesce(CAST(customeradjustmentdetail.apptxntypeid as INT64), -1) AS apptxntypeid,
            coalesce(customeradjustmentdetail.customerpaymentlevelid, -1) AS customerpaymentlevelid,
            coalesce(CAST(CAST(customeradjustmentdetail.approvedstatusdate as STRING FORMAT 'YYYYMMDD') as INT64), -1) AS paymentdayid,
            coalesce(CAST(NULL as INT64), -1) AS channelid,
            coalesce(CAST(customeradjustmentdetail.paymentmodeid as INT64), -1) AS paymentmodeid,
            coalesce(CAST(NULL as INT64), -1) AS paymentstatusid,
            CAST(NULL as INT64) AS refpaymentid,
            CAST(NULL as INT64) AS refpaymentstatusid,
            CAST(NULL as STRING) AS drcrflag,
            CAST(customeradjustmentdetail.lineitemamount as NUMERIC) AS lineitemamount,
            coalesce(customeradjustmentdetail.deleteflag, 0) AS deleteflag,
            CAST(customeradjustmentdetail.approvedstatusdate as DATETIME) AS approvedstatusdate,
            coalesce(current_datetime(), DATETIME '1900-01-01') AS edw_update_date
        FROM
          EDW_TRIPS_STAGE.CustomerAdjustmentDetail AS customeradjustmentdetail
      ;
      SET log_message = 'Loaded EDW_TRIPS.Fact_CustomerPaymentDetail';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      SELECT log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING);
      
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));

      IF trace_flag = 1 THEN
        select log_source, substr(CAST(log_start_date as STRING), 1, 23); -- Replacement or FromLog
      END IF;

      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS_STAGE.CustomerPaymentDetail' AS tablename,
            customerpaymentdetail.*
        FROM
          EDW_TRIPS_STAGE.CustomerPaymentDetail
        ORDER BY 2 DESC
        LIMIT 1000
        ;
      END IF;

      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS_STAGE.CustomerAdjustmentDetail' AS tablename,
            customeradjustmentdetail.*
        FROM
          EDW_TRIPS_STAGE.CustomerAdjustmentDetail
        ORDER BY 2 DESC
        LIMIT 1000
        ;
      END IF;

      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Fact_CustomerPaymentDetail' AS tablename,
            *
        FROM
          EDW_TRIPS.Fact_CustomerPaymentDetail
        ORDER BY 2 DESC
        LIMIT 1000
        ;
      END IF;
      
      EXCEPTION WHEN ERROR THEN
        BEGIN
          DECLARE error_message STRING DEFAULT @@error.message;
          CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
         
          select log_source, log_start_date; -- replacement for from log
          RAISE USING MESSAGE = error_message;  -- Rethrow the error!
        END;
    END;
/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Fact_CustomerPaymentDetail_Full_Load

EXEC Utility.FromLog 'dbo.Fact_CustomerPaymentDetail', 1
SELECT TOP 100 'dbo.Fact_CustomerPaymentDetail' Table_Name, * FROM dbo.Fact_CustomerPaymentDetail ORDER BY 2

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================

-- Sample data at a glance:

--:: Dim Tables
SELECT TOP 1000 'dbo.Dim_CustomerPaymentLevel' TableName, * FROM dbo.Dim_CustomerPaymentLevel --> New!
SELECT TOP 1000 'dbo.Dim_CustomerPaymentType' TableName, * FROM dbo.Dim_CustomerPaymentType --> New!
SELECT TOP 1000 'dbo.Dim_AdjApprovalStatus' TableName,* from dbo.Dim_AdjApprovalStatus -- FYI
SELECT TOP 1000 'dbo.Dim_PaymentMode' TableName, * FROM dbo.Dim_PaymentMode ORDER BY PaymentModeGroupCode, PaymentModeCode
SELECT TOP 1000 'dbo.Dim_PaymentStatus' TableName, * FROM dbo.Dim_PaymentStatus ORDER BY 2
SELECT TOP 1000 'dbo.Dim_Channel' TableName, * FROM dbo.Dim_Channel ORDER BY 2 -- for AceCashExpress
SELECT TOP 1000 'dbo.Dim_Customer' TableName, * FROM dbo.Dim_Customer ORDER BY 2  

--:: Fact Table 
SELECT TOP 10000 'Stage.CustomerPaymentDetail' TableName, * FROM Stage.CustomerPaymentDetail ORDER BY 2 DESC
SELECT TOP 10000 'Stage.CustomerAdjustmentDetail' TableName, * FROM Stage.CustomerAdjustmentDetail ORDER BY 2 DESC
SELECT TOP 10000 'Stage.CustomerPaymentDetail' TableName, * FROM Stage.CustomerPaymentDetail WHERE CustomerPaymentLevelID = -1 ORDER BY 2 DESC
SELECT TOP 10000 'Stage.CustomerAdjustmentDetail' TableName, * FROM Stage.CustomerAdjustmentDetail WHERE CustomerPaymentLevelID = -1 ORDER BY 2 DESC
SELECT TOP 10000 'dbo.Fact_CustomerPaymentDetail' TableName, * FROM dbo.Fact_CustomerPaymentDetail ORDER BY 2 DESC
SELECT COUNT(1) [Fact_CustomerPaymentDetail] FROM dbo.Fact_CustomerPaymentDetail  

SELECT 'Stage.CustomerPaymentDetail' TableName, PaymentStatusCode, COUNT(1) RC FROM Stage.CustomerPaymentDetail GROUP BY PaymentStatusCode ORDER BY 3 DESC
SELECT CONVERT(DATE,PaymentDate) PaymentDate, COUNT(1) RC, SUM(LineItemAmount) LineItemAmount FROM Stage.CustomerPaymentDetail WHERE CustomerPaymentLevelID = -1 GROUP BY  CONVERT(DATE,PaymentDate)  ORDER BY 1 DESC

--:: Showing Fact and Dim table relationships 

SELECT CP.CustomerPaymentType, 
          CPL.CustomerPaymentLevelID, CPL.CustomerPaymentLevel1, CPL.CustomerPaymentLevel2, CPL.CustomerPaymentLevel3, CPL.CustomerPaymentLevel4, 
          ATT.AppTxnTypeCode, ATT.AppTxnTypeDesc, 
          CH.ChannelName,
          PM.PaymentModeCode, PM.PaymentModeGroupCode,
          PS.PaymentStatusCode,
          CPD.LineItemAmount 
--SELECT COUNT(1) RC, SUM(CPD.LineItemAmount) LineItemAmount -- 7962926 rows, none lost in any JOIN
FROM dbo.Fact_CustomerPaymentDetail CPD  
JOIN dbo.Dim_CustomerPaymentType CP
       ON CPD.CustomerPaymentTypeID = CP.CustomerPaymentTypeID
JOIN dbo.Dim_CustomerPaymentLevel CPL -- 97252
       ON CPD.CustomerPaymentLevelID = CPL.CustomerPaymentLevelID
JOIN dbo.Dim_AppTxnType ATT --  -1
       ON CPD.AppTxnTypeID = ATT.AppTxnTypeID
JOIN dbo.Dim_Channel CH --  -1
       ON CPD.ChannelID = CH.ChannelID
JOIN dbo.Dim_PaymentMode PM
       ON CPD.PaymentModeID = PM.PaymentModeID
JOIN dbo.Dim_PaymentStatus PS
       ON CPD.PaymentStatusID = PS.PaymentStatusID
WHERE CPD.PaymentDayID BETWEEN 20201101 AND 20201130
AND CPL.CustomerPaymentLevelID = 19
ORDER BY CPD.PaymentDayID DESC, CPL.SortSequenceNumber  

--:: Here is the Customer Level Payments Detail fact table data 360 degrees view

SELECT	pt.CustomerPaymentType, 
		c.CustomerPlanID, c.CustomerPlanDesc,
		c.FleetFlag,
		AppTxnTypeCode, AppTxnTypeDesc,
		pd.CustomerPaymentLevelID, pl.CustomerPaymentLevel1, pl.CustomerPaymentLevel2, pl.CustomerPaymentLevel3, pl.CustomerPaymentLevel4,  
		pm.PaymentModeCode,
		ps.PaymentStatusCode,
		DRCRFlag, 
		MIN(d.DayDate) PaymentDateFrom, MAX(d.DayDate) PaymentDateTo,
		ISNULL(COUNT(DISTINCT pd.CustomerID),0) CustomerCount, ISNULL(COUNT(DISTINCT PaymentID),0) PaymentTxnCount, ISNULL(COUNT(1),0) Row_Count, ISNULL(SUM(pd.LineItemAmount),0.00) Amount
FROM	dbo.Fact_CustomerPaymentDetail pd 
LEFT JOIN	dbo.Dim_CustomerPaymentLevel pl
			ON pd.CustomerPaymentLevelID = pl.CustomerPaymentLevelID 
LEFT JOIN	dbo.Dim_AppTxnType att
			ON pd.AppTxnTypeID = att.AppTxnTypeID
LEFT JOIN	dbo.Dim_Customer c
			ON pd.CustomerID = c.CustomerID
LEFT JOIN	dbo.Dim_CustomerPaymentType pt
			ON pd.CustomerPaymentTypeID = pt.CustomerPaymentTypeID
LEFT JOIN	dbo.Dim_PaymentMode pm
			ON pd.PaymentModeID = pm.PaymentModeID
LEFT JOIN	dbo.Dim_PaymentStatus ps
			ON pd.PaymentStatusID = ps.PaymentStatusID
LEFT JOIN	dbo.Dim_Day d
			ON pd.PaymentDayID = d.DayID
WHERE	pd.CustomerPaymentLevelID = -1
GROUP BY 
		pt.CustomerPaymentType, 
		c.CustomerPlanID, c.CustomerPlanDesc,
		c.FleetFlag,
		AppTxnTypeCode, AppTxnTypeDesc,
		pd.CustomerPaymentLevelID, pl.CustomerPaymentLevel1, pl.CustomerPaymentLevel2, pl.CustomerPaymentLevel3, pl.CustomerPaymentLevel4,  
		pm.PaymentModeCode,
		ps.PaymentStatusCode,
		DRCRFlag
ORDER BY c.CustomerPlanID, pt.CustomerPaymentType, PaymentTxnCount DESC

--:: Simpler view. 
SELECT CustomerPaymentType, PlanID, CustomerPlanDesc, AppTxnTypeCode, AppTxnTypeDesc, pd.CustomerPaymentLevelID, pl.CustomerPaymentLevel1, pl.CustomerPaymentLevel2, pl.CustomerPaymentLevel3, pl.CustomerPaymentLevel4, NULL DRCRFlag, COUNT(DISTINCT CustomerID) CustomerCount, COUNT(DISTINCT PaymentID) PaymentTxnCount, COUNT(1) Row_Count, SUM(pd.LineItemAmount) Amount
FROM Stage.CustomerPaymentDetail pd JOIN dbo.Dim_CustomerPaymentLevel pl ON pd.CustomerPaymentLevelID = pl.CustomerPaymentLevelID 
GROUP BY CustomerPaymentType, PlanID, CustomerPlanDesc, AppTxnTypeCode, AppTxnTypeDesc, pd.CustomerPaymentLevelID, pl.CustomerPaymentLevel1, pl.CustomerPaymentLevel2, pl.CustomerPaymentLevel3, pl.CustomerPaymentLevel4 
 
SELECT CustomerPaymentType, PlanID, CustomerPlanDesc, AppTxnTypeCode, AppTxnTypeDesc, pd.CustomerPaymentLevelID, pl.CustomerPaymentLevel1, pl.CustomerPaymentLevel2, pl.CustomerPaymentLevel3, pl.CustomerPaymentLevel4, DRCRFlag, COUNT(DISTINCT CustomerID) CustomerCount, COUNT(DISTINCT AdjustmentID) AdjTxnCount, COUNT(1) Row_Count, SUM(pd.LineItemAmount) Amount 
FROM Stage.CustomerAdjustmentDetail pd JOIN dbo.Dim_CustomerPaymentLevel pl ON pd.CustomerPaymentLevelID = pl.CustomerPaymentLevelID  
GROUP BY CustomerPaymentType, PlanID, CustomerPlanDesc, AppTxnTypeCode, AppTxnTypeDesc, pd.CustomerPaymentLevelID, pl.CustomerPaymentLevel1, pl.CustomerPaymentLevel2, pl.CustomerPaymentLevel3, pl.CustomerPaymentLevel4, DRCRFlag 
ORDER BY PlanID, CustomerPaymentType, PaymentTxnCount DESC

select * from  Stage.CustomerAdjustmentDetail 
*/


END;