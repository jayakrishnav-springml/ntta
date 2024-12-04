CREATE OR REPLACE PROCEDURE `FINANCE_REPORTS_EXPORT.Item26_Export`(bucket_name STRING)
BEGIN 
  DECLARE 
    log_source STRING DEFAULT 'Item26_Export';
  DECLARE 
    log_start_date DATETIME DEFAULT CURRENT_DATETIME('America/Chicago');
  DECLARE 
    log_message  STRING DEFAULT 'Started Item26 Export';
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
      Finance_reports_export.Item26_'''||month_year||''' AS (
      SELECT
        fact_customerbalancesnapshot.customerid AS accountid,
        fact_customerbalancesnapshot.balancedate,
        fact_customerbalancesnapshot.beginningbalanceamount,
        fact_customerbalancesnapshot.endingbalanceamount,
        fact_customerbalancesnapshot.creditamount,
        fact_customerbalancesnapshot.debitamount
      FROM
        edw_trips.fact_customerbalancesnapshot
      WHERE
        NOT (fact_customerbalancesnapshot.beginningbalanceamount = 0
          AND fact_customerbalancesnapshot.endingbalanceamount = 0
          AND fact_customerbalancesnapshot.creditamount = 0
          AND fact_customerbalancesnapshot.debitamount = 0)
        AND fact_customerbalancesnapshot.snapshotmonthid = CAST(REPLACE(SUBSTR(CAST(DATETIME_SUB(CAST(DATE_TRUNC(CURRENT_DATE(), MONTH) AS DATETIME), INTERVAL 2 MILLISECOND) AS STRING), 1, 7),'-','') AS INT64)
      ORDER BY
        accountid );''';
    EXECUTE IMMEDIATE
      create_table; 

    SET log_message = CONCAT('Loaded Finance_reports_export.Item26_',month_year);
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