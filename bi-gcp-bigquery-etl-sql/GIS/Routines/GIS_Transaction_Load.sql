CREATE OR REPLACE PROCEDURE `EDW_TRIPS.GIS_Transaction_Load`()
BEGIN
  DECLARE log_source STRING DEFAULT 'EDW_TRIPS.GIS_Transaction_Load';
  DECLARE log_start_date DATETIME;
  DECLARE log_message STRING;
  DECLARE sql STRING;
  BEGIN
    DECLARE month_year STRING;
    DECLARE startdayid INT64 DEFAULT 20210101;
    DECLARE enddayid INT64;

    SET month_year = FORMAT_DATE('%Y_%m', CURRENT_DATE());
    SET log_start_date = current_datetime('America/Chicago');
    SET log_message = concat('Started Loading FILES_EXPORT.AADT_Transactions_',month_year);
    SET enddayid = CAST(FORMAT_DATE('%Y%m%d', DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 1 DAY)) AS INT64);
    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date,log_message, 'I', NULL , NULL );


    SET SQL = """
      CREATE OR REPLACE TABLE FILES_EXPORT.AADT_Transactions_"""||month_year||""" AS
          SELECT
              sc.plazadirectionid,
              sc.tripdate,
              sc.`0` AS t0,
              sc.`1` AS t1,
              sc.`2` AS t2,
              sc.`3` AS t3,
              sc.`4` AS t4,
              sc.`5` AS t5,
              sc.`6` AS t6,
              sc.`7` AS t7,
              sc.`8` AS t8,
              sc.`9` AS t9,
              sc.`10` AS t10,
              sc.`11` AS t11,
              sc.`12` AS t12,
              sc.`13` AS t13,
              sc.`14` AS t14,
              sc.`15` AS t15,
              sc.`16` AS t16,
              sc.`17` AS t17,
              sc.`18` AS t18,
              sc.`19` AS t19,
              sc.`20` AS t20,
              sc.`21` AS t21,
              sc.`22` AS t22,
              sc.`23` AS t23,
              sum(coalesce(sc.`0`, 0) + coalesce(sc.`1`, 0) + coalesce(sc.`2`, 0) + coalesce(sc.`3`, 0) + coalesce(sc.`4`, 0) + coalesce(sc.`5`, 0) + coalesce(sc.`6`, 0) + coalesce(sc.`7`, 0) + coalesce(sc.`8`, 0) + coalesce(sc.`9`, 0) + coalesce(sc.`10`, 0) + coalesce(sc.`11`, 0) + coalesce(sc.`12`, 0) + coalesce(sc.`13`, 0) + coalesce(sc.`14`, 0) + coalesce(sc.`15`, 0) + coalesce(sc.`16`, 0) + coalesce(sc.`17`, 0) + coalesce(sc.`18`, 0) + coalesce(sc.`19`, 0) + coalesce(sc.`20`, 0) + coalesce(sc.`21`, 0) + coalesce(sc.`22`, 0) + coalesce(sc.`23`, 0)) AS totaltxns,
              current_datetime() AS gis_loaddate
            FROM
              (
                SELECT
                    l.plazadirectionid,
                    CAST(t.tripdate as DATE) AS tripdate,
                    EXTRACT(HOUR from t.tripdate) AS hr,
                    count(t.tripdate) AS nooftrips
                  FROM
                    EDW_TRIPS.Fact_Transaction AS t
                    INNER JOIN EDW_TRIPS.Dim_Lane AS l ON l.laneid = t.laneid
                  WHERE t.tripdayid BETWEEN """|| startdayid ||""" AND """|| enddayid ||"""
                  AND l.agencycode = 'NTTA'
                  GROUP BY  l.plazadirectionid,tripdate, hr 
              ) AS d PIVOT(sum(d.nooftrips) FOR d.hr IN (0 AS `0`, 1 AS `1`, 2 AS `2`, 3 AS `3`, 4 AS `4`, 5 AS `5`, 6 AS `6`, 7 AS `7`, 8 AS `8`, 9 AS `9`, 10 AS `10`, 11 AS `11`, 12 AS `12`, 13 AS `13`, 14 AS `14`, 15 AS `15`, 16 AS `16`, 17 AS `17`, 18 AS `18`, 19 AS `19`, 20 AS `20`, 21 AS `21`, 22 AS `22`, 23 AS `23`)) AS sc
            GROUP BY sc.plazadirectionid,sc.tripdate, sc.0, sc.1, sc.2, sc.3, sc.4, sc.5, sc.6, sc.7, sc.8, sc.9, sc.10, sc.11, sc.12, sc.13, sc.14, sc.15, sc.16, sc.17, sc.18, sc.19, sc.20, sc.21, sc.22, sc.23
          ORDER BY 
            1,
            2  """ ;
        
        EXECUTE IMMEDIATE sql;


    SET log_message = concat('Loaded FILES_EXPORT.AADT_Transactions',month_year);
    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date,log_message, 'I', -1 , NULL );
    
    EXCEPTION WHEN ERROR THEN
      BEGIN 
          DECLARE error_message STRING DEFAULT @@error.message;
          CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date,error_message, 'E', -1 , NULL ); 
          RAISE USING MESSAGE = error_message;  -- Rethrow the error!
      END;
  END;
END;