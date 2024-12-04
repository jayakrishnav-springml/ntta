CREATE OR REPLACE PROCEDURE LND_TBOS.Cheque_Payments_File_Export_202402()
BEGIN
  DECLARE 
    log_source STRING DEFAULT 'Cheque_Payments_Export';
  DECLARE 
    log_start_date DATETIME DEFAULT CURRENT_DATETIME('America/Chicago');
  DECLARE 
    log_message  STRING DEFAULT 'Started Cheque_Payments Export';
  BEGIN
    DECLARE month_year STRING;
    DECLARE create_table string;

    DECLARE startdate DATETIME;

    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date,log_message, 'I', NULL , NULL );   

    -- SET startdate = CAST(date_add(last_day(date_add(current_datetime(), interval -2 MONTH)), interval 1 DAY) as DATETIME);
    SET startdate = CAST(date_add(last_day(date_add("2024-02-01", interval -2 MONTH)), interval 1 DAY) as DATETIME);
    SET month_year = FORMAT_DATE('%Y_%m', date_add(startdate,interval 1 MONTH));  
    SELECT month_year;
    SET create_table = """
    CREATE OR REPLACE TABLE
      FILES_EXPORT.ChequePayments_"""||month_year||""" AS (
    SELECT
        a.agency,
        a.store,
        a.payment_date,
        a.payment_date_time,
        a.employee_id,
        a.employeename,
        a.payment_id,
        CASE
          a.transaction_type
          WHEN 'R' THEN 'PAYMENT'
          WHEN 'XR' THEN 'REVERSAL'
          WHEN 'CR' THEN 'VOID'
          WHEN 'BR' THEN 'REFUND'
        END AS transaction_type,
        a.category,
        a.subcategory,
        a.activitytype,
        a.pay_type,
        sum(a.amount) AS amount,
        a.check_cc_number,
        a.accountnumber,
        a.paymentstatusid,
        a.subcategorydescription
      FROM
        (
          SELECT
              '2-NTTA' AS agency,
              loc.locationname AS store,
              CAST( pmt.paymentdate as DATE) AS payment_date,
              pmt.paymentdate AS payment_date_time,
              coalesce(icn.userid, pmt.channelid) AS employee_id,
              concat(CAST( coalesce(icn.userid, pmt.channelid) as STRING), ' - ', coalesce(icn.createduser, pmt.createduser)) AS employeename,
              pmt.paymentid AS payment_id,
              CASE
                category.categoryname
                WHEN 'PAYMENT' THEN 'R'
                WHEN 'TRANSFER' THEN 'T'
                WHEN 'DISCOUNT' THEN 'D'
                WHEN 'FEE' THEN 'F'
                WHEN 'WRITEOFF' THEN 'W'
                WHEN 'ADJUSTMENT' THEN 'A'
                WHEN 'REVERSAL' THEN 'XR'
                WHEN 'DISMISS' THEN 'D'
                WHEN 'REFUND' THEN 'BR'
                WHEN 'VOID' THEN 'CR'
                WHEN 'DISMISS' THEN 'D'
              END AS transaction_type,
              category.categoryname AS category,
              pmt_l.apptxntypecode AS subcategory,
              pmt.activitytype,
              CASE
                WHEN pmt.activitytype = 'OnlinePMT' THEN card_pmt.cardtype
                ELSE paymode.lookuptypecodedesc
              END AS pay_type,
              CASE
                WHEN ((pmt.refpaymentid > 0)
                OR (pmt_l.apptxntypecode IN(
                  'DFWCCPMTREF', 'DALCCPMTREF', 'TVCCCREFUND', 'CSCCCREFUND'
                ))
                OR (pmt.pmttxntype = 'CREDIT')) THEN coalesce(lineitemamount, txnamount) * -1
                ELSE coalesce(lineitemamount, txnamount)
              END AS amount,
              CASE
                WHEN pmt.activitytype = 'OfflinePMT'
                AND paymode.lookuptypecode IN(
                  'Cheque', 'CashierCheque', 'CertifiedCheque'
                ) THEN coalesce(chq_pmt.chequenumber, rev_chq_pmt.chequenumber)
                WHEN pmt.activitytype = 'OnlinePMT' THEN concat('****', card_pmt.cardkey)
                ELSE 'N/A'
              END AS check_cc_number,
              pmt_l.customerid AS accountnumber,
              paymentstatusid,
              apptxntypes.apptxntypedesc AS subcategorydescription
            FROM
              LND_TBOS.Finance_PaymentTxns AS pmt
              LEFT OUTER JOIN LND_TBOS.Finance_PaymentTxn_LineItems AS pmt_l ON pmt.paymentid = pmt_l.paymentid
              LEFT OUTER JOIN LND_TBOS.TollPlus_ICN icn ON pmt.icnid = icn.icnid
              LEFT OUTER JOIN LND_TBOS.Rbac_LocationRoles AS lr ON icn.locationroleid = lr.locationroleid
              LEFT OUTER JOIN LND_TBOS.TollPlus_OperationalLocations AS icnopl ON lr.locationid = icnopl.operationallocationid
              LEFT OUTER JOIN LND_TBOS.TollPlus_OperationalLocations AS loc ON pmt.locationid = loc.operationallocationid
              LEFT OUTER JOIN LND_TBOS.TollPlus_Channels AS pmtchannel ON pmt.channelid = pmtchannel.channelid
              LEFT OUTER JOIN LND_TBOS.TollPlus_AppTxnTypes AS apptxntypes ON pmt_l.apptxntypecode = apptxntypes.apptxntypecode
              LEFT OUTER JOIN LND_TBOS.TollPlus_TxnType_Categories AS category ON apptxntypes.txntype_categoryid = category.categoryid
              LEFT OUTER JOIN LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy AS paymode ON pmt.paymentmodeid = paymode.lookuptypecodeid
              LEFT OUTER JOIN LND_TBOS.Finance_ChequePayments AS chq_pmt ON pmt.paymentid = chq_pmt.paymentid
              LEFT OUTER JOIN LND_TBOS.Finance_ChaseTransactions AS card_pmt ON pmt.paymentid = card_pmt.paymentid
              LEFT OUTER JOIN LND_TBOS.Finance_ChequePayments AS rev_chq_pmt ON pmt.refpaymentid = rev_chq_pmt.paymentid
                -- WHERE loc.operationallocationid IN(
                --   store
                --   )
                --   OR loc.operationallocationid IS NULL
                --   AND -1 IN(
                --     store
                --   )
              ) AS a
            WHERE (a.transaction_type LIKE '%R%')
            -- OR a.subcategory IN(
            --   'DFWCCPMTREF', 'DALCCPMTREF', 'TVCCCREFUND', 'CSCCCREFUND'
            -- ))
            AND a.paymentstatusid IN(
              109, 119, 3182
            )
            AND a.payment_date_time >='"""||startdate||"""'
            AND a.payment_date_time < datetime_add('"""||startdate||"""', interval 1 MONTH)
            -- AND a.agency = agency
            -- AND (a.employee_id = employee_id
            -- OR employee_id IS NULL)
            AND a.transaction_type IN(
              'R'
            )
            AND a.pay_type = 'Check'

      GROUP BY agency,
        store,
        payment_date,
        payment_date_time,
        employee_id,
        employeename,
        payment_id,
        transaction_type,
        category,
        subcategory,
        activitytype,
        pay_type,
        check_cc_number,
        accountnumber,
        paymentstatusid,
        subcategorydescription); """
    ;
    select create_table;
    EXECUTE IMMEDIATE create_table; 

    SET log_message = CONCAT('Loaded Cheque_Payments_export');
    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date,log_message, 'I', -1 , NULL );

    EXCEPTION WHEN ERROR THEN
      BEGIN 
          DECLARE error_message STRING DEFAULT @@error.message;
          CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date,error_message, 'E', -1 , NULL ); 
          RAISE USING MESSAGE = error_message;  -- Rethrow the error!
      END;
  END;

END;