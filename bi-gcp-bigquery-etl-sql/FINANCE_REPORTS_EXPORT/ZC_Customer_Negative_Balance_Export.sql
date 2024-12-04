CREATE OR REPLACE PROCEDURE `FINANCE_REPORTS_EXPORT.ZC_Customer_Negative_Balance_Export`(bucket_name STRING)
BEGIN 
  DECLARE 
    log_source STRING DEFAULT 'ZC_Customer_Negative_Balance_Export';
  DECLARE 
    log_start_date DATETIME DEFAULT CURRENT_DATETIME('America/Chicago');
  DECLARE 
    log_message  STRING DEFAULT 'Started ZC Customer Negative Balance Export';
  BEGIN
    DECLARE
      month_year STRING;
    DECLARE
      create_table string;
    DECLARE 
      export_sql STRING;
    DECLARE
      gcs_uri STRING;
    

    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date,log_message, 'I', NULL , NULL );   
    
    SET
      month_year = FORMAT_DATE('%Y_%m', CURRENT_DATE()); 
    SELECT
      month_year;
    SET
      create_table = '''
    CREATE OR REPLACE TABLE
      Finance_reports_export.ZC_Negative_Balance_'''||month_year||''' AS (
      SELECT
      coalesce(CAST(CTS.CustomerID AS INT64), -1) AS customerid,
      coalesce(CAST(eb.currentbalance AS NUMERIC), 0) AS endingbalanceamount,
      cts.lastcusttxnid AS endingcusttxnid,
      cts.lastposteddate
    FROM
      (
        SELECT
            ct.customerid,
            max(ct.posteddate) AS lastposteddate,
            max(ct.custtxnid) AS lastcusttxnid
          FROM
            lnd_tbos.tollplus_tp_custtxns AS ct
            INNER JOIN lnd_tbos.tollplus_tp_customer_plans AS cp ON cp.customerid = ct.customerid
            AND ct.lnd_updatetype <> 'D'
          WHERE cp.planid = 4
          AND ct.posteddate < datetime_add(datetime_add(DATETIME '1970-01-01 00:00:00', interval 0 DAY), interval datetime_diff(current_datetime(), datetime_add(DATETIME '1970-01-01 00:00:00', interval 0 DAY), MONTH) MONTH)
          AND ct.posteddate >= '2021-01-12 00:00:00'
          AND ct.balancetype = 'VioBal'
          AND apptxntypecode NOT LIKE '%FAIL%'
          GROUP BY ct.customerid
      ) AS cts
      INNER JOIN lnd_tbos.tollplus_tp_custtxns AS eb ON eb.custtxnid = cts.lastcusttxnid
    WHERE coalesce(CAST(eb.currentbalance AS NUMERIC), 0) < NUMERIC '0.00'
    ORDER BY
    cts.lastposteddate);''';
    EXECUTE IMMEDIATE
      create_table; 

    SET log_message = CONCAT('Loaded Finance_reports_export.ZC_Negative_Balance_',month_year);
    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date,log_message, 'I', -1 , NULL );

    -- Exporting to file logic is moved to workflows to achieve single file exporting.
    EXCEPTION WHEN ERROR THEN
      BEGIN 
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date,error_message, 'E', -1 , NULL ); 
        RAISE USING MESSAGE = error_message;  -- Rethrow the error!
      END;
    END;
END;