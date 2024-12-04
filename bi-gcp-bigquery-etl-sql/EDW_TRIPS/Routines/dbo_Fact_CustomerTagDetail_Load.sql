CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_CustomerTagDetail_Load`(start_month_id INT64, end_month_id INT64, is_full_load INT64)
BEGIN
/*
#################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
1. Load daily Account Tag Activity for the current month or given month range.

 Notes: 
 1. Daily refresh loads from the current month begin to end of previous day (MTD). This is the normal mode. 
 2. The marker to denote change of month is: fact table does not have data for the last day of the previous month. 
    This is when it switches to load data for the entire previous month.
 3. From next day onwards, it reverts back to loading data for the current month as mentioned above in #1. 

-------------------------------------------------------------------------------------------------------------------
MISSION CLEAN DATA! 
-------------------------------------------------------------------------------------------------------------------
The real solution is: TBOS Source data should be cleaned and TRIPS app needs to be fixed to prevent such data ASAP.

Workaround data cleanup logic. Keep in mind that this is no silver bullet!

1. Data Issue: TagStartDate > TagEndDate. How is that possible?!
   Fix: Reverse these dates. Sometimes it helps, sometimes it does not when the issue spread to more than one row.
   Examples: See EDW_TRIPS_STAGE.CustomerTags_Source where DataIntegrityIssue contains 'TagStartDate > TagEndDate'

2. Data Issue: Current Tag Status ended in the past
   Fix: Extended Current Tag Status End for date range continuity
   Examples: See EDW_TRIPS_STAGE.CustomerTags where SRC = 'Current +'

3. Data Issue: Bad Actor rows in Hist that are in Active status with 9999-12-31 date will result in 
   PERPETUAL ACTIVE STATUS for those Customer Tags even when the Tag Status later became NOT ACTIVE. 
   Fix: Find the correct Close date after this Bad Actor row and use it end this row. 
   Examples: See EDW_TRIPS_STAGE.CustomerTags_BadActiveHist_Fix.

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0044405	Shankar 	2023-12-20	New!
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC EDW_TRIPS.Fact_CustomerTagDetail_Load @Start_Month_ID = 202101, @End_Month_ID = 202401, @Is_Full_Load = 1 -- Full Load
EXEC EDW_TRIPS.Fact_CustomerTagDetail_Load @Start_Month_ID = NULL, @End_Month_ID = NULL, @Is_Full_Load = 0 --Daily incremental run

SELECT TOP 100 * FROM Utility.ProcessLog WHERE LogSource = 'EDW_TRIPS.Fact_CustomerTagDetail_Load' ORDER BY 1 DESC
SELECT TOP 100 'EDW_TRIPS.Fact_CustomerTagDetail_Load' Table_Name, * FROM EDW_TRIPS.Fact_CustomerTagDetail ORDER BY 1,2
===================================================================================================================
*/
    --:: DEBUG
		--DECLARE @Start_Month_ID INT = 202101, @End_Month_ID INT = 202401, @Is_Full_Load BIT = 1
    DECLARE tablename STRING DEFAULT 'EDW_TRIPS.Fact_CustomerTagDetail';
    DECLARE current_date_ DATETIME;
    DECLARE eo_prev_date DATETIME;
    DECLARE eo_prev_month DATETIME;
    DECLARE current_month_id INT64;
    DECLARE prev_month_id INT64;
    DECLARE trace_flag INT64 DEFAULT 1; -- Testing
    DECLARE load_period STRING;
    DECLARE load_start_date DATETIME;
    DECLARE load_end_date DATETIME;
    DECLARE firstpartitionid INT64 DEFAULT 202012;
    DECLARE lastpartitionid INT64;
    DECLARE partition_ranges STRING;
    DECLARE createtablewith STRING;
    DECLARE log_message STRING;
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_CustomerTagDetail_Load';
    DECLARE log_start_date DATETIME;
    DECLARE sql STRING;
    BEGIN
      SET log_start_date = current_datetime('America/Chicago');
      SET lastpartitionid = CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_add(last_day(date_add(current_datetime(),interval 1 MONTH)), interval 1 DAY)) as STRING), 1, 6) as INT64);
      SET is_full_load = (SELECT COALESCE(is_full_load, 0) );-- Default INCR
      IF (
            (
              SELECT COUNT(1) FROM `EDW_TRIPS.INFORMATION_SCHEMA.TABLES` 
              WHERE lower(table_name) = lower(SUBSTR(tablename,STRPOS(tablename,'.')+1))
            ) = 0
          ) 
      THEN SET IsFullLoad = 1;
      END IF;


      SET current_date_ = 
            (
              SELECT
                  COALESCE(max(TollPlus_TP_Customer_Tags.updateddate), current_datetime()) 
                FROM
                  LND_TBOS.TollPlus_TP_Customer_Tags
                WHERE TollPlus_TP_Customer_Tags.lnd_updatetype <> 'D'
                  AND TollPlus_TP_Customer_Tags.updateddate < current_datetime() -- Data current date
              LIMIT 1
            ) ;
      SET eo_prev_date = 
            (
              SELECT
                  DATETIME_SUB(TIMESTAMP_TRUNC(current_date_, DAY),INTERVAL 3 MILLISECOND)  -- Prev Day 23:59:59
              LIMIT 1
            ) ;
      
      SET eo_prev_month = 
            (
              SELECT
                  DATETIME_SUB(TIMESTAMP_TRUNC(current_date_, MONTH),INTERVAL 3 MILLISECOND) 
              LIMIT 1
            ) ;

      SET (current_month_id, prev_month_id) = 
            (
              SELECT
                  STRUCT
                  (
                    CAST(substr(CAST(current_date_ as STRING FORMAT 'YYYYMMDD'), 1, 6) as INT64) AS current_month_id, 
                    CAST(substr(CAST(eo_prev_month as STRING FORMAT 'YYYYMMDD'), 1, 6) as INT64) AS prev_month_id
                  )
              LIMIT 1
            );



      IF 
        FORMAT_DATE('%Y-%m-%d', SAFE.PARSE_DATE('%Y%m%d', CONCAT(CAST(start_month_id AS STRING),'01'))) IS NOT NULL
        AND 
        FORMAT_DATE('%Y-%m-%d', SAFE.PARSE_DATE('%Y%m%d', CONCAT(CAST(end_month_id AS STRING),'01'))) IS NOT NULL 
      THEN
        BEGIN
            SET (load_period, load_start_date, load_end_date) = 
                  (
                    SELECT
                        STRUCT(
                            'Input Month Range' AS load_period, 
                            CAST(FORMAT_DATE('%Y-%m-%d', PARSE_DATE('%Y%m%d', CONCAT(CAST(start_month_id AS STRING),'01'))) AS DATETIME) AS load_start_date, 
                            CASE
                              WHEN end_month_id = current_month_id THEN eo_prev_date
                              ELSE DATETIME_SUB(datetime_add(CAST(PARSE_DATE('%Y%m%d', CONCAT(CAST(end_month_id AS STRING),'01')) AS DATETIME), interval 1 MONTH),INTERVAL 3 MILLISECOND)
                            END AS load_end_date)
                    LIMIT 1
                  );
        END ;
      ELSE
        BEGIN
          IF EXISTS 
            (
              SELECT
                  1
                FROM
                  EDW_TRIPS.Fact_CustomerTagDetail
                WHERE Fact_CustomerTagDetail.tagcounterdate = eo_prev_month
            ) 
          THEN
            SET (load_period, load_start_date, load_end_date, start_month_id, end_month_id) = 
                  (
                    SELECT
                        STRUCT
                          (
                            'Current Month' AS load_period, 
                            DATE_TRUNC(current_date_, MONTH) AS load_start_date, 
                            eo_prev_date AS load_end_date, 
                            current_month_id AS start_month_id, 
                            current_month_id AS end_month_id
                          )
                    LIMIT 1
                  );
          ELSE
            IF  current_date_ < DATETIME_ADD(EO_Prev_Month,interval 1 day) 
            THEN
              SET (load_period, load_start_date, load_end_date, start_month_id, end_month_id) = 
                    (
                      SELECT
                          STRUCT
                            (
                              'Previous Month' AS load_period, 
                              DATE_TRUNC(DATE_SUB(current_date_, INTERVAL 1 MONTH), MONTH) AS load_start_date, 
                              eo_prev_month AS load_end_date, 
                              prev_month_id AS start_month_id, 
                              prev_month_id AS end_month_id
                            )
                      LIMIT 1
                    );

            ELSE
              SET (load_period, load_start_date, load_end_date, start_month_id, end_month_id) = 
                    (
                      SELECT
                          STRUCT
                            (
                              'Current Month + Previous Month' AS load_period, 
                              DATE_TRUNC(DATE_SUB(current_date_, INTERVAL 1 MONTH), MONTH) AS load_start_date, 
                              eo_prev_date AS load_end_date, 
                              prev_month_id AS start_month_id, 
                              current_month_id AS end_month_id
                            )
                      LIMIT 1
                    );
            END IF;
          END IF;
        END;
      END IF;
      IF trace_flag = 1 THEN
        SELECT
            current_date_ AS current_date,
            eo_prev_date AS eo_prev_date,
            eo_prev_month AS eo_prev_month,
            load_period AS load_period,
            load_start_date AS load_start_date,
            load_end_date AS load_end_date,
            start_month_id AS start_month_id,
            end_month_id AS end_month_id,
            current_month_id AS current_month_id,
            firstpartitionid AS firstpartitionid,
            lastpartitionid AS lastpartitionid
        ;
      END IF;
      
      IF is_full_load = 1 THEN
        IF trace_flag = 1 THEN
            SELECT CONCAT('Calling: Utility.Get_PartitionMonthIDRange_String from ' , CAST(FirstPartitionID AS STRING), ' till ' , CAST(LastPartitionID AS STRING));
        END IF;

        SET log_message = (
            SELECT
                CONCAT('Started full load with parameters for ', COALESCE(load_period, ''), ' Current_Date: ', substr(CAST(current_date_ as STRING), 1, 19), ', Load_Start_Date: ', substr(CAST(load_start_date as STRING), 1, 19), ', Load_End_Date: ', substr(CAST(load_end_date as STRING), 1, 23), ', Start_Month_ID: ', COALESCE(substr(CAST(start_month_id as STRING), 1, 30), 'NULL'), ', End_Month_ID: ', COALESCE(substr(CAST(end_month_id as STRING), 1, 30), 'NULL')) AS _u0040_log_message
            LIMIT 1
        );

        IF trace_flag = 1 THEN
          SELECT log_message;
        END IF;

        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL , NULL );
      
      ELSE
        SET createtablewith = 'CLUSTER BY CustomerID';

        SET log_message = (
            SELECT
                CONCAT('Started incremental load with parameters for ', COALESCE(load_period, ''), ' - Current_Date: ', substr(CAST(current_date_ as STRING), 1, 19), ', Load_Start_Date: ', substr(CAST(load_start_date as STRING), 1, 19), ', Load_End_Date: ', substr(CAST(load_end_date as STRING), 1, 23), ', Start_Month_ID: ', COALESCE(substr(CAST(start_month_id as STRING), 1, 30), 'NULL'), ', End_Month_ID: ', COALESCE(substr(CAST(end_month_id as STRING), 1, 30), 'NULL')) AS _u0040_log_message
            LIMIT 1
        ); 

        IF trace_flag = 1 THEN
          SELECT log_message;
        END IF;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
      END IF;

      --:: Get load date ranges for this run
      CREATE OR REPLACE TEMPORARY TABLE _SESSION.__cw_local_tmp_load_months
        AS
          SELECT
              dim_month.yearid,
              dim_month.monthid,
              CASE
                WHEN dim_month.monthid = current_month_id THEN 1
                ELSE 0
              END AS currentmonthidflag,
              CAST(dim_month.monthbegindate as DATETIME) AS monthbegindate,
              CASE
                WHEN dim_month.monthid = CAST(substr(CAST(current_date_ as STRING FORMAT 'YYYYMMDD'), 1, 6) as INT64) THEN eo_prev_date
                ELSE datetime_sub(CAST(date_add(dim_month.monthbegindate, interval 1 MONTH) as DATETIME), interval 3 MILLISECOND)
              END AS monthenddate
            FROM
              EDW_TRIPS.dim_month
            WHERE dim_month.monthid BETWEEN start_month_id AND end_month_id
      ;
      IF trace_flag = 1 THEN
        SELECT
            '#Load_Months' AS src,
            `#load_months`.*
          FROM
            __cw_local_tmp_load_months AS `#load_months`
        ORDER BY monthid
        ;
      END IF;
      
      --::======================================================================================================================================
      --:: Get Customer Tag History for load
      --::======================================================================================================================================

      --:: Get Customer Tag data for TollTag accounts active as of TRIPS Go Live date 1/1/2021, that is, ignore TT Customer accounts closed before 1/1/2021.

      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.CustomerTags_Source 
      CLUSTER BY CustomerID
        AS
          --> Source: TRIPS Current Table
          SELECT
              'Current' AS src,
              99999999 AS histid/*current*/,
              custtagid,
              ct.customerid,
              c.accountstatusdesc,
              tagagency,
              serialno AS tagid,
              tagstatus,
              tagstartdate,
              tagenddate,
              CAST(NULL as STRING) AS dataintegrityissue,
              tagassigneddate,
              tagassignedenddate,
              tagstatusdate,
              ct.updateddate,
              ct.updateduser,
              ct.createddate,
              ct.createduser,
              ct.tagtype,
              ct.tagalias,
              ct.returnedorassignedtype,
              ct.itemcode,
              ct.isnonrevenue,
              ct.specialitytag,
              ct.mounting,
              ct.channelid,
              c.accountopendate,
              c.accountlastactivedate,
              c.accountlastclosedate,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_TP_Customer_Tags AS ct
              INNER JOIN EDW_TRIPS.Dim_Customer AS c 
                ON c.customerid = ct.customerid
            WHERE ct.customerid NOT IN(
              SELECT
                  customerid
                FROM
                  EDW_TRIPS.Dim_Customer
                WHERE accountcategorydesc = 'Tagstore'
                 AND accountlastclosedate < '2021-01-01'
            )
             AND ct.lnd_updatetype <> 'D'

          UNION DISTINCT

          --> Source: TRIPS History Table
          SELECT
              'Hist' AS src,
              CAST(histid as INT64) AS histid,
              custtagid,
              ct.customerid,
              c.accountstatusdesc,
              tagagency,
              serialno AS tagid,
              tagstatus,
              tagstartdate,
              tagenddate,
              CAST(NULL as STRING) AS dataintegrityissue,
              tagassigneddate,
              tagassignedenddate,
              tagstatusdate,
              ct.updateddate,
              ct.updateduser,
              ct.createddate,
              ct.createduser,
              ct.tagtype,
              ct.tagalias,
              ct.returnedorassignedtype,
              ct.itemcode,
              ct.isnonrevenue,
              ct.specialitytag,
              ct.mounting,
              ct.channelid,
              c.accountopendate,
              c.accountlastactivedate,
              c.accountlastclosedate,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_TP_Customer_Tags_History AS ct
              INNER JOIN EDW_TRIPS.Dim_Customer AS c ON c.customerid = ct.customerid
            WHERE ct.customerid NOT IN(
              SELECT
                  customerid
                FROM
                  EDW_TRIPS.Dim_Customer
                WHERE accountcategorydesc = 'Tagstore'
                 AND accountlastclosedate < '2021-01-01'
            )
             AND ct.lnd_updatetype <> 'D'
      ;

      SET log_message = 'Loaded EDW_TRIPS_STAGE.CustomerTags_Source as is before applying any data cleanup updates';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      

      CREATE or REPLACE TABLE EDW_TRIPS_STAGE.CustomerTags
      cluster by CustomerID
      --> Source: TRIPS. Data clean up #1. Fix TagStartDate > TagEndDate.
        AS
          SELECT
              CustomerTags_Source.src,
              CustomerTags_Source.histid,
              CustomerTags_Source.custtagid,
              CustomerTags_Source.customerid,
              CustomerTags_Source.accountstatusdesc,
              CustomerTags_Source.tagagency,
              CustomerTags_Source.tagid,
              CustomerTags_Source.tagstatus,
              CAST( 
                --CONVERT(DATETIME2(0),CASE WHEN TagStartDate > TagEndDate THEN TagEndDate ELSE TagStartDate END) TagStartDate
                -- A round about approach was used for rounding off to nearest second for tagendate and tagstartdate
                CASE
                  WHEN CustomerTags_Source.tagstartdate > CustomerTags_Source.tagenddate 
                  THEN 
                    -- select CustomerTags_Source.tagenddate as CustomerTags_Source.tagstartdate
                    CASE 
                      WHEN tagenddate>'9999-12-31'  -- workaround for rounding off tagenddate for value 9999-12-31 23:59:59:997 as it is not possible with below logic
                      THEN CAST(FORMAT_DATETIME("%Y-%m-%dT%H:%M:%S",CustomerTags_Source.tagenddate) as DATETIME)
                      ELSE CAST(TIMESTAMP_MILLIS( CAST(UNIX_MILLIS(CAST (CustomerTags_Source.tagenddate as timestamp)) / 1000 AS INT64) * 1000) AS DATETIME) -- convert datetime to unix milliseconds to round off to the nearest second
                    END 
                    -- select CustomerTags_Source.tagstartdate as CustomerTags_Source.tagstartdate
                  ELSE CAST(TIMESTAMP_MILLIS( CAST(UNIX_MILLIS(CAST (CustomerTags_Source.tagstartdate as timestamp)) / 1000 AS INT64) * 1000) AS DATETIME) -- convert datetime to unix milliseconds to round off to the nearest second
                END as DATETIME) AS tagstartdate, -- Fix TagStartDate, TagEndDate, if they are in reverse order. Or else, massive data disorder and confusion! ,
              CAST(
                -- CONVERT(DATETIME2(0),CASE WHEN TagStartDate > TagEndDate THEN TagStartDate ELSE TagEndDate END) TagEndDate,
                -- A round about approach was used for rounding off to nearest second for tagendate and tagstartdate
                CASE
                  WHEN CustomerTags_Source.tagstartdate > CustomerTags_Source.tagenddate 
                  -- select CustomerTags_Source.tagstartdate as CustomerTags_Source.tagenddate
                  THEN CAST(TIMESTAMP_MILLIS( CAST(UNIX_MILLIS(CAST (CustomerTags_Source.tagstartdate as timestamp)) / 1000 AS INT64) * 1000) AS DATETIME)  -- convert datetime to unix milliseconds to round off to the nearest second
                  ELSE  
                    -- select CustomerTags_Source.tagenddate as CustomerTags_Source.tagenddate
                    CASE 
                      WHEN tagenddate>'9999-12-31' -- workaround for rounding off tagenddate for value 9999-12-31 23:59:59:997 as it is not possible with below logic
                      THEN CAST(FORMAT_DATETIME("%Y-%m-%dT%H:%M:%S",CustomerTags_Source.tagenddate)as DATETIME) 
                      ELSE CAST(TIMESTAMP_MILLIS( CAST(UNIX_MILLIS(CAST (CustomerTags_Source.tagenddate as timestamp)) / 1000 AS INT64) * 1000) AS DATETIME)  -- convert datetime to unix milliseconds to round off to the nearest second
                    END
                END as DATETIME) AS tagenddate,
              NULLIF(
                CONCAT(
                    COALESCE(
                    CONCAT(
                          CASE 
                            WHEN CustomerTags_Source.tagstartdate > CustomerTags_Source.tagenddate 
                            THEN 'TagStartDate > TagEndDate' 
                          END, '; '
                          ), ''), 
                    COALESCE(
                            CASE 
                              WHEN CustomerTags_Source.src = 'Current' 
                            AND 
                            CASE 
                              WHEN CustomerTags_Source.tagstartdate > CustomerTags_Source.tagenddate 
                              THEN CustomerTags_Source.tagstartdate
                              ELSE CustomerTags_Source.tagenddate
                            END < current_datetime() THEN 'Current Tag Status ended in the past'
                            END, '')
              ), '') AS dataintegrityissue,
              CustomerTags_Source.tagassigneddate,
              CustomerTags_Source.tagassignedenddate,
              CustomerTags_Source.tagstatusdate,
              CustomerTags_Source.updateddate,
              CustomerTags_Source.updateduser,
              CustomerTags_Source.createddate,
              CustomerTags_Source.createduser,
              CustomerTags_Source.tagtype,
              CustomerTags_Source.tagalias,
              CustomerTags_Source.returnedorassignedtype,
              CustomerTags_Source.itemcode,
              CustomerTags_Source.isnonrevenue,
              CustomerTags_Source.specialitytag,
              CustomerTags_Source.mounting,
              CustomerTags_Source.channelid,
              CustomerTags_Source.accountopendate,
              CustomerTags_Source.accountlastactivedate,
              CustomerTags_Source.accountlastclosedate,
              CustomerTags_Source.edw_updatedate
            FROM
              EDW_TRIPS_STAGE.CustomerTags_Source
          UNION DISTINCT
            --> Source: BI. Data clean up #2. Add row to compensate for the missing Current Tag Status continuity

          SELECT
              'Current +' AS src,
              100000000 AS histid /*current Tag Status continuity correction row at the end*/,
              CustomerTags_Source.custtagid,
              CustomerTags_Source.customerid,
              CustomerTags_Source.accountstatusdesc,
              CustomerTags_Source.tagagency,
              CustomerTags_Source.tagid,
              CustomerTags_Source.tagstatus,
              CAST( 
                --CONVERT(DATETIME2(0),CASE WHEN TagStartDate > TagEndDate THEN TagStartDate ELSE TagEndDate END) TagStartDate, 
                -- A round about approach was used for rounding off to nearest second for tagendate and tagstartdate
                CASE
                WHEN CustomerTags_Source.tagstartdate > CustomerTags_Source.tagenddate 
                THEN CAST(TIMESTAMP_MILLIS( CAST(UNIX_MILLIS(CAST (CustomerTags_Source.tagstartdate as timestamp)) / 1000 AS INT64) * 1000) AS DATETIME)
                ELSE 
                CASE WHEN tagenddate>'9999-12-31'
                      THEN CAST(FORMAT_DATETIME("%Y-%m-%dT%H:%M:%S",CustomerTags_Source.tagenddate)as DATETIME) 
                      ELSE CAST(TIMESTAMP_MILLIS( CAST(UNIX_MILLIS(CAST (CustomerTags_Source.tagenddate as timestamp)) / 1000 AS INT64) * 1000) AS DATETIME)
                      END
              END as DATETIME) AS tagstartdate,
              '9999-12-31 23:59:59' AS tagenddate,
              CONCAT(CASE
                WHEN CustomerTags_Source.tagstartdate > CustomerTags_Source.tagenddate THEN 'TagStartDate > TagEndDate; '
                ELSE ''
              END, 'Extended Current Tag Status End for date range continuity') AS dataintegrityissue,
              CustomerTags_Source.tagassigneddate,
              CustomerTags_Source.tagassignedenddate,
              CustomerTags_Source.tagstatusdate,
              CustomerTags_Source.updateddate,
              CustomerTags_Source.updateduser,
              CustomerTags_Source.createddate,
              CustomerTags_Source.createduser,
              CustomerTags_Source.tagtype,
              CustomerTags_Source.tagalias,
              CustomerTags_Source.returnedorassignedtype,
              CustomerTags_Source.itemcode,
              CustomerTags_Source.isnonrevenue,
              CustomerTags_Source.specialitytag,
              CustomerTags_Source.mounting,
              CustomerTags_Source.channelid,
              CustomerTags_Source.accountopendate,
              CustomerTags_Source.accountlastactivedate,
              CustomerTags_Source.accountlastclosedate,
              current_datetime() AS edw_updatedate
            FROM
              EDW_TRIPS_STAGE.CustomerTags_Source
            WHERE CustomerTags_Source.src = 'Current'
             AND CASE
              WHEN CustomerTags_Source.tagstartdate > CustomerTags_Source.tagenddate THEN CustomerTags_Source.tagstartdate
              ELSE CustomerTags_Source.tagenddate
            END < current_datetime() -- Extend the last Tag Status till N/A date, if it already ended. This is important for tracking Open/Close/MonthEnd Tag Counts properly.
      ;
      
      SET log_message = 'Loaded EDW_TRIPS_STAGE.CustomerTags';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
      /*
      --:: Check
      SELECT TOP 10000 * FROM Stage.CustomerTags ORDER BY CustomerID, TagID, HistID
      SELECT TagAgency,TagID,COUNT(1) RC FROM Stage.CustomerTags WHERE AccountOpenDate > '1/1/2023'  GROUP BY TagAgency,TagID HAVING COUNT(1) > 3
      */

      --::======================================================================================================================================
      --:: Load Month Begin Tags, Opened/Closed Tags during the month and Month End Tags
      --::======================================================================================================================================

      --:: Open/Closed Tags decision data source. Must take complete view of Customer Tag History to track Tag Status changes correctly. Separate table helps with understanding Open/Closed Tags determination.

      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.OpenedClosedTags_Source -- All rows change tracking can be seen in _Source table
        AS
          SELECT
              t2.monthid,
              t2.src,
              t2.histid,
              t2.custtagid,
              t2.customerid,
              t2.tagagency,
              t2.tagid,
              t2.tagstatus,
              t2.tagstartdate,
              t2.tagenddate,
              t2.tagstatus_lag,
              t2.change_num,
              row_number() OVER (PARTITION BY t2.custtagid, t2.change_num ORDER BY t2.tagstartdate) AS change_num_seq,
              t2.dataintegrityissue,
              t2.edw_updatedate
            FROM
              (
                SELECT
                    t1.*,
                    sum(CASE
                      WHEN t1.tagstatus = t1.tagstatus_lag THEN 0
                      ELSE 1
                    END) OVER (PARTITION BY t1.custtagid ORDER BY t1.tagstartdate ROWS UNBOUNDED PRECEDING) AS change_num
                  FROM
                    (
                      SELECT
                          CustomerTags.src,
                          CustomerTags.histid,
                          CustomerTags.custtagid,
                          CustomerTags.customerid,
                          CustomerTags.tagagency,
                          CustomerTags.tagid,
                          CASE
                            WHEN CustomerTags.tagstatus = 'Assigned' THEN 'Active'
                            ELSE 'Other'
                          END AS tagstatus,
                          CustomerTags.tagstartdate,
                          CustomerTags.tagenddate,
                          lag(CASE
                            WHEN CustomerTags.tagstatus = 'Assigned' THEN 'Active'
                            ELSE 'Other'
                          END, 1, 'Other') OVER (PARTITION BY CustomerTags.custtagid ORDER BY CustomerTags.histid) AS tagstatus_lag,
                          CAST(substr(CAST(CustomerTags.tagstartdate as STRING FORMAT 'YYYYMMDD'), 1, 6) as INT64) AS monthid,
                          CustomerTags.dataintegrityissue,
                          CustomerTags.edw_updatedate
                        FROM
                          EDW_TRIPS_STAGE.CustomerTags
                          --WHERE TagID = '01234713' 
				                  --WHERE CustomerID = 4820583
                    ) AS t1 --ORDER BY CustomerID, TagID, TagAgency, CHANGE_NUM, TagStartDate
              ) AS t2 --ORDER BY CustomerID, TagID, TagAgency, CHANGE_NUM, CHANGE_NUM_SEQ 
      ;
      
      SET log_message = 'Loaded EDW_TRIPS_STAGE.OpenedClosedTags_Source';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
      ------------------------------------------------------------------------------------------------------------------------------------------
      --:: Bad Actor rows in Hist that are in Active status with 9999-12-31 date will result in PERPETUAL ACTIVE STATUS for those Customer Tags 
      --:: even when the Tag Status later became NOT ACTIVE.  Fixing them and doing it in the right way is not that simple!
      ------------------------------------------------------------------------------------------------------------------------------------------
      
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.CustomerTags_BadActiveHist
        AS
          SELECT
              t.src,
              t.histid,
              t.customerid,
              t.tagagency,
              t.tagid,
              t.tagstatus,
              t.tagstartdate,
              t.tagenddate,
              t.change_num
            FROM
              EDW_TRIPS_STAGE.OpenedClosedTags_Source AS t
            WHERE t.src = 'Hist'
             AND t.tagstatus = 'Active'
             AND t.tagenddate > current_datetime()
             AND EXISTS (
              SELECT
                  1
                FROM
                  EDW_TRIPS_STAGE.OpenedClosedTags_Source AS t1
                WHERE t1.customerid = t.customerid
                 AND t1.tagagency = t.tagagency
                 AND t1.tagid = t.tagid
                 AND t1.src = 'Current'
                 AND t1.tagstatus <> 'Active'
            )
      ;
      SET log_message = 'Loaded EDW_TRIPS_STAGE.CustomerTags_BadActiveHist with Hist rows in NEVER ENDING ACTIVE Tag Status!';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
            
      CREATE TEMPORARY TABLE _SESSION.cte_customertags_badactivehist_fix AS (
          SELECT
              bh.src,
              bh.histid,
              bh.customerid,
              bh.tagagency,
              bh.tagid,
              bh.tagstatus,
              bh.tagstartdate,
              bh.tagenddate,
              min(oc.tagstartdate) AS tagenddate_fixed,
              current_datetime() AS edw_updatedate
            FROM
              EDW_TRIPS_STAGE.CustomerTags_BadActiveHist AS bh
              INNER JOIN EDW_TRIPS_STAGE.OpenedClosedTags_Source AS oc ON bh.customerid = oc.customerid
                AND bh.tagid = oc.tagid
            WHERE oc.tagstatus = 'Other'
              AND (oc.tagenddate < current_datetime()
              OR oc.src = 'Current'/* Example: TagID 12401706. Current "Other" status end date is 9999-12-31. This is okay, if it is current row. */)
              AND (oc.change_num > bh.change_num /* Try finding the first next "Other" row, if possible, to pick it's TagStartDate as the new TagEndDate for the Bad Actor row */ 
              OR bh.tagstartdate < CAST('2021-01-01' /*Example: TagID 10926620. Bad Hist Active row TagStartDate is before 2021-01-01. No worries, end it with same date.*/as DATETIME)
              -- OR Example: TagID 13855047 Bad Hist Active row TagStartDate is AFTER any later rows, choosing them will put TagEndDate which is before TagStartDate on the Bad Hist Active row. End it with Same date?
              )
            GROUP BY bh.src, bh.histid, bh.customerid, bh.tagagency, bh.tagid, bh.tagstatus, bh.tagstartdate, bh.tagenddate
      );

      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.CustomerTags_BadActiveHist_Fix
        AS
        SELECT
            bh.src,
            bh.histid,
            bh.customerid,
            bh.tagagency,
            bh.tagid,
            bh.tagstatus,
            bh.tagstartdate,
            bh.tagenddate,
            COALESCE(bhf.tagenddate_fixed, bh.tagstartdate) AS tagenddate_fixed,
            CONCAT('Bad Active Row in History ', CASE
              WHEN bhf.tagenddate_fixed IS NULL THEN '- Not fixable, void it!'
              ELSE ''
            END) AS dataintegrityissue,
            COALESCE(bhf.edw_updatedate, current_datetime()) AS edw_updatedate
          FROM
            EDW_TRIPS_STAGE.CustomerTags_BadActiveHist AS bh
            LEFT OUTER JOIN cte_customertags_badactivehist_fix AS bhf ON bhf.customerid = bh.customerid
              AND bhf.tagagency = bh.tagagency
              AND bhf.tagid = bh.tagid
              AND bhf.histid = bh.histid
      ;

      SET log_message = 'Loaded EDW_TRIPS_STAGE.CustomerTags_BadActiveHist_Fix with a new TagEndDate for Hist rows in NEVER ENDING ACTIVE Tag Status!';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

      IF EXISTS (
        SELECT 1 FROM EDW_TRIPS_STAGE.CustomerTags_BadActiveHist_Fix
      ) THEN

        UPDATE EDW_TRIPS_STAGE.OpenedClosedTags_Source 
        SET tagenddate = CustomerTags_BadActiveHist_Fix.tagenddate_fixed, 
            dataintegrityissue = CustomerTags_BadActiveHist_Fix.dataintegrityissue, 
            edw_updatedate = CustomerTags_BadActiveHist_Fix.edw_updatedate 
        FROM EDW_TRIPS_STAGE.CustomerTags_BadActiveHist_Fix 
        WHERE CustomerTags_BadActiveHist_Fix.customerid = OpenedClosedTags_Source.customerid
          AND CustomerTags_BadActiveHist_Fix.tagagency = OpenedClosedTags_Source.tagagency
          AND CustomerTags_BadActiveHist_Fix.tagid = OpenedClosedTags_Source.tagid
          AND CustomerTags_BadActiveHist_Fix.histid = OpenedClosedTags_Source.histid;


        SET log_message = 'Fixed EDW_TRIPS_STAGE.OpenedClosedTags_Source with a new TagEndDate for Hist rows in NEVER ENDING ACTIVE Tag Status!';
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
        
        
        UPDATE EDW_TRIPS_STAGE.CustomerTags 
        SET tagenddate = CustomerTags_BadActiveHist_Fix.tagenddate_fixed, 
            dataintegrityissue = CustomerTags_BadActiveHist_Fix.dataintegrityissue, 
            edw_updatedate = CustomerTags_BadActiveHist_Fix.edw_updatedate 
        FROM EDW_TRIPS_STAGE.CustomerTags_BadActiveHist_Fix 
        WHERE CustomerTags_BadActiveHist_Fix.customerid = CustomerTags.customerid
          AND CustomerTags_BadActiveHist_Fix.tagagency = CustomerTags.tagagency
          AND CustomerTags_BadActiveHist_Fix.tagid = CustomerTags.tagid
          AND CustomerTags_BadActiveHist_Fix.histid = CustomerTags.histid;

        SET log_message = 'Fixed EDW_TRIPS_STAGE.CustomerTags with a new TagEndDate for Hist rows in NEVER ENDING ACTIVE Tag Status!';
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      END IF;
      
      
      -- UPDATE EDW_TRIPS_STAGE.CustomerTags_Source SET dataintegrityissue = CustomerTags.dataintegrityissue FROM EDW_TRIPS_STAGE.CustomerTags
      --  WHERE CustomerTags.customerid = CustomerTags_Source.customerid
      --  AND CustomerTags.tagagency = CustomerTags_Source.tagagency
      --  AND CustomerTags.tagid = CustomerTags_Source.tagid
      --  AND CustomerTags.histid = CustomerTags_Source.histid
      --  AND COALESCE(CustomerTags_Source.dataintegrityissue, '') <> COALESCE(CustomerTags.dataintegrityissue, '')
      --  AND CustomerTags.dataintegrityissue <> 'Current Tag Status ended in the past';

      -- Replaced the above logic as follows to prevent the following error
      -- !! UPDATE/MERGE must match at most one source row for each target row !!

      CREATE TEMPORARY TABLE _SESSION.cte_deduplicated_CustomerTags AS (
        SELECT
          customerid,
          tagagency,
          tagid,
          histid,
          dataintegrityissue,
          ROW_NUMBER() OVER (
            PARTITION BY customerid, tagagency, tagid, histid 
            ORDER BY updateddate DESC   -- or any other column to define the latest record
          ) as rn
        FROM
          EDW_TRIPS_STAGE.CustomerTags
        WHERE
          dataintegrityissue <> 'Current Tag Status ended in the past' -- too many. ignore clutter.
      );

      UPDATE 
        EDW_TRIPS_STAGE.CustomerTags_Source AS target
      SET 
        target.dataintegrityissue = source.dataintegrityissue
      FROM 
        cte_deduplicated_CustomerTags AS source
      WHERE 
        target.customerid = source.customerid
        AND target.tagagency = source.tagagency
        AND target.tagid = source.tagid
        AND target.histid = source.histid
        AND source.rn = 1
        AND COALESCE(target.dataintegrityissue, '') <> COALESCE(source.dataintegrityissue, '');


      SET log_message = 'Fixed EDW_TRIPS_STAGE.CustomerTags_Source with DataIntegrityIssue info';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
		  --:: Open/Closed Tags. 
      
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.OpenedClosedTags
        AS
          SELECT
              OpenedClosedTags_Source.*
            FROM
              EDW_TRIPS_STAGE.OpenedClosedTags_Source
            WHERE OpenedClosedTags_Source.change_num_seq = 1 --> Only TagStatus change activity rows
      ;

      SET log_message = 'Loaded EDW_TRIPS_STAGE.OpenedClosedTags';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
      /*
      --:: Check
      SELECT * FROM EDW_TRIPS_STAGE.OpenedClosedTags_Source WHERE CustomerID = 4820583 ORDER BY CustomerID, TagAgency, TagID, HistID
      SELECT * FROM EDW_TRIPS_STAGE.OpenedClosedTags  WHERE CustomerID = 4820583 ORDER BY CustomerID, TagAgency, TagID, HistID
      */

      ------------------------------------------------------------------------------------------------------------------------------------------
      --:: Count Customer Tags 
      ------------------------------------------------------------------------------------------------------------------------------------------

      --:: Month Begin Tags
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.MonthBeginTags
        AS
          SELECT
              t.src,
              t.monthid,
              t.histid,
              t.custtagid,
              t.customerid,
              t.tagagency,
              t.tagid,
              t.tagstatus,
              t.monthbegindate,
              t.tagstartdate,
              t.tagenddate,
              t.rn
            FROM
              (
                SELECT
                    CustomerTags.src,
                    `#load_months`.monthid,
                    CustomerTags.histid,
                    CustomerTags.custtagid,
                    CustomerTags.customerid,
                    CustomerTags.tagagency,
                    CustomerTags.tagid,
                    CustomerTags.tagstatus,
                    `#load_months`.monthbegindate,
                    CustomerTags.tagstartdate,
                    CustomerTags.tagenddate,
                    row_number() OVER (PARTITION BY `#load_months`.monthid, CustomerTags.customerid, CustomerTags.tagagency, CustomerTags.tagid ORDER BY CustomerTags.histid DESC) AS rn
                  FROM
                    EDW_TRIPS_STAGE.CustomerTags
                    INNER JOIN __cw_local_tmp_load_months AS `#load_months` ON `#load_months`.monthbegindate BETWEEN CustomerTags.tagstartdate AND CustomerTags.tagenddate
                  WHERE CustomerTags.tagstatus = 'Assigned'
                  --AND TagID = '13525663'
                  --ORDER BY MonthID, CustomerID, HistID 
              ) AS t
            WHERE t.rn = 1  --> Handle duplicates caused by same TagStartDate or TagEndDate or both in Current + History table. Example: TagID = '13525663'
		        --ORDER BY MonthID, CustTagID, T.HistID
      ;
      
      SET log_message = 'Loaded EDW_TRIPS_STAGE.MonthBeginTags';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      /*
      --:: Check
      SELECT * FROM Stage.CustomerTags WHERE TagID = '13525663' ORDER BY CustTagID, HistID 
      SELECT * FROM Stage.MonthBeginTags WHERE CustomerID = 1147255
      */      
      
		  --:: Month Opened Tags
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.MonthOpenedTags
        AS
          SELECT
              oct.src,
              oct.monthid,
              oct.histid,
              oct.custtagid,
              oct.customerid,
              oct.tagagency,
              oct.tagid,
              oct.tagstatus,
              oct.tagstartdate,
              oct.tagenddate,
              m.monthenddate
            FROM
              EDW_TRIPS_STAGE.OpenedClosedTags AS oct
              INNER JOIN __cw_local_tmp_load_months AS m ON oct.monthid = m.monthid
               AND oct.tagstartdate <= m.monthenddate
            WHERE oct.tagstatus = 'Active' --> OpenedTags
      ;
      
      SET log_message = 'Loaded EDW_TRIPS_STAGE.MonthOpenedTags';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
      /*
      --:: Check
      SELECT 'OPENED_TAGS' OPENED_TAGS, MonthID, CustomerID, COUNT(1) OPENED_TAGS FROM Stage.MonthOpenedTags GROUP BY MonthID, CustomerID ORDER BY MonthID, CustomerID
      SELECT * FROM Stage.OpenedClosedTags Where TagStartDate > '1/1/2023' ORDER BY CustomerID, TagID, MonthID

      --:: Same Tag opened multiple times within a month
      SELECT 'OPENED_TAGS' OPENED_TAGS, MonthID, CustTagID, CustomerID, TagAgency, TagID, COUNT(1) DUP_OPENED_TAGS FROM Stage.MonthOpenedTags GROUP BY MonthID, CustTagID, CustomerID, TagAgency, TagID HAVING COUNT(1) > 1 ORDER BY MonthID, CustomerID, TagID, CustTagID
      SELECT * FROM Stage.CustomerTags WHERE TagID = '02277666' ORDER BY TagStartDate
      SELECT * FROM Stage.OpenedClosedTags WHERE TagID = '02277666' ORDER BY 
      */      
      
      
		  --:: Month Closed Tags. Must have Active status before Closed status
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.MonthClosedTags
        AS
          SELECT
              oct.src,
              oct.monthid,
              oct.histid,
              oct.custtagid,
              oct.customerid,
              oct.tagagency,
              oct.tagid,
              oct.tagstatus,
              oct.tagstartdate,
              oct.tagenddate,
              m.monthenddate
            FROM
              EDW_TRIPS_STAGE.OpenedClosedTags AS oct
              INNER JOIN __cw_local_tmp_load_months AS m ON oct.monthid = m.monthid
                AND oct.tagstartdate <= m.monthenddate
            WHERE oct.tagstatus = 'Other' --> ClosedTags
              AND EXISTS (
              SELECT
                  1
                FROM
                  EDW_TRIPS_STAGE.CustomerTags AS ct
                WHERE ct.tagstatus = 'ASSIGNED'
                  AND oct.custtagid = ct.custtagid
                  AND oct.tagstartdate > ct.tagstartdate
            ) 		--AND OCT.CustomerID = 4820583 AND OCT.TagID = '11681327'
      ;
      
      SET log_message = 'Loaded EDW_TRIPS_STAGE.MonthClosedTags';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
      /*
      --:: Check
      SELECT 'CLOSED_TAGS' CLOSED_TAGS, MonthID, CustomerID, COUNT(1) CLOSED_TAGS FROM Stage.MonthClosedTags GROUP BY MonthID, CustomerID ORDER BY MonthID, CustomerID
      
      --:: Same Tag closed multiple times within a month
      SELECT 'CLOSED_TAGS' CLOSED_TAGS, MonthID, CustTagID, CustomerID, TagAgency, TagID, COUNT(1) DUP_CLOSED_TAGS FROM Stage.MonthClosedTags GROUP BY MonthID, CustTagID, CustomerID, TagAgency, TagID HAVING COUNT(1) > 1 ORDER BY MonthID, CustomerID, TagID, CustTagID
      SELECT * FROM Stage.CustomerTags WHERE TagID = '13644621' ORDER BY CustomerID, TagID, CustTagID, HistID
      SELECT * FROM Stage.OpenedClosedTags Where TagID = '13644621' ORDER BY MonthID, CustomerID, TagID, CustTagID, HistID
      SELECT * FROM Stage.MonthClosedTags WHERE TagID = '13644621'  ORDER BY MonthID, CustomerID

      --:: One Tag with 3 customers. Pick the Tag where it has active status prior to closed status.
      SELECT * FROM Stage.CustomerTags WHERE TagID = '03822931' ORDER BY CustomerID, TagID, CustTagID, HistID
      SELECT * FROM Stage.OpenedClosedTags Where TagID = '03822931' ORDER BY MonthID, CustomerID, TagID, CustTagID, HistID
      SELECT * FROM Stage.MonthClosedTags WHERE TagID = '03822931'  ORDER BY MonthID, CustomerID, TagID, CustTagID, HistID
      */

      --:: Month End Tags      
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.MonthEndTags
        AS
          SELECT
              t.src,
              t.monthid,
              t.histid,
              t.custtagid,
              t.customerid,
              t.tagagency,
              t.tagid,
              t.tagstatus,
              t.tagstartdate,
              t.tagenddate,
              CAST(FORMAT_DATETIME("%Y-%m-%dT%H:%M:%S",t.monthenddate) as DATETIME) AS monthenddate,
              t.rn
            FROM
              (
                SELECT
                    CustomerTags.src,
                    `#load_months`.monthid,
                    CustomerTags.histid,
                    CustomerTags.custtagid,
                    CustomerTags.customerid,
                    CustomerTags.tagagency,
                    CustomerTags.tagid,
                    CustomerTags.tagstatus,
                    CustomerTags.tagstartdate,
                    CustomerTags.tagenddate,
                    `#load_months`.monthenddate,
                    row_number() OVER (PARTITION BY `#load_months`.monthid, CustomerTags.customerid, CustomerTags.tagagency, CustomerTags.tagid ORDER BY CustomerTags.histid DESC) AS rn
                  FROM
                    EDW_TRIPS_STAGE.CustomerTags
                    INNER JOIN __cw_local_tmp_load_months AS `#load_months` ON `#load_months`.monthenddate BETWEEN CustomerTags.tagstartdate AND CustomerTags.tagenddate
                  WHERE CustomerTags.tagstatus = 'Assigned'
                  --AND TagID = '13525663'
			            --ORDER BY MonthID, CustomerID, HistID 
              ) AS t
            WHERE t.rn = 1  -- Handle duplicates caused by same TagStartDate or TagEndDate or both in Current + History table. Example: TagID = '13525663'
		        --ORDER BY CustomerID, CustTagID

      ;
      
      SET log_message = 'Loaded EDW_TRIPS_STAGE.MonthEndTags';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
      /*
      --:: Check
      SELECT * FROM Stage.CustomerTags WHERE CustomerID = 1147255 ORDER BY CustomerID, TagID, TagStartDate desc
      SELECT * FROM Stage.MonthEndTags WHERE CustomerID = 1147255 ORDER BY CustomerID, TagID, MonthID

      SELECT * FROM Stage.MonthEndTags Where CustomerID = 7800 ORDER BY CustomerID, TagID, MonthID
      SELECT * FROM Stage.OpenedClosedTags Where CustomerID = 7800 ORDER BY CustomerID, TagID, MonthID
      */

      --::======================================================================================================================================
      --:: Load TollTag Customer and Customer History 
      --::======================================================================================================================================
      
      --:: Current customer data from Dim_Customer table. 
            
      CREATE OR REPLACE TABLE EDW_TRIPS_Stage.TollTagCustomer
      CLUSTER BY CustomerID
        AS
          SELECT
              Dim_Customer.customerid,
              Dim_Customer.accounttypeid,
              Dim_Customer.accounttypedesc,
              Dim_Customer.accountstatusid,
              Dim_Customer.accountstatusdesc,
              Dim_Customer.accountstatusdate,
              Dim_Customer.autoreplenishmentid,
              Dim_Customer.autoreplenishmentcode,
              Dim_Customer.rebillamount,
              CASE
                  WHEN Dim_Customer.rebillamount IS NULL THEN -1
                  WHEN Dim_Customer.rebillamount < 20 THEN 1
                  WHEN Dim_Customer.rebillamount = 20 THEN 2
                  WHEN Dim_Customer.rebillamount > 20
                  AND Dim_Customer.rebillamount < 40 THEN 3
                  WHEN Dim_Customer.rebillamount >= 40 THEN 4
              END AS rebillamountgroupid,
              NULLIF(NULLIF(Dim_Customer.zipcode, '99999'), '') AS zipcode,
              Dim_Customer.accountcreatedate,
              Dim_Customer.accountlastclosedate
            FROM
              EDW_TRIPS.Dim_Customer
            WHERE Dim_Customer.accountcategorydesc = 'TagStore'
             AND Dim_Customer.customerid IN(
              SELECT
                  CustomerTags.customerid
                FROM
                  EDW_TRIPS_STAGE.CustomerTags
            )
      ;
      SET log_message = 'Loaded EDW_TRIPS_STAGE.TollTagCustomer';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
      ------------------------------------------------------------------------------------------------------------------------------------------
      --:: Customer History. Get customer data as of the last day of each month
      ------------------------------------------------------------------------------------------------------------------------------------------
      
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.TollTagCustomerHistory
      CLUSTER BY CustomerID
        AS
          SELECT
              'Current' AS src, /*current*/
              999999999 AS histid,
              TollPlus_tp_customers.customerid,
              TollPlus_tp_customers.usertypeid AS accounttypeid,
              TollPlus_tp_customers.accountstatusid,
              TollPlus_tp_customers.accountstatusdate,
              TollPlus_tp_customers.updateddate
            FROM
              LND_TBOS.TollPlus_tp_customers
            WHERE TollPlus_tp_customers.customerid IN(
              SELECT DISTINCT
                  TollTagCustomer.customerid
                FROM
                  EDW_TRIPS_STAGE.TollTagCustomer
            )
             AND TollPlus_tp_customers.lnd_updatetype <> 'D'

          UNION DISTINCT

          SELECT
              'History' AS src,
              History_tp_customers.histid,
              History_tp_customers.customerid,
              History_tp_customers.usertypeid AS accounttypeid,
              History_tp_customers.accountstatusid,
              History_tp_customers.accountstatusdate,
              History_tp_customers.updateddate
            FROM
              LND_TBOS.History_tp_customers
            WHERE History_tp_customers.customerid IN(
              SELECT DISTINCT
                  TollTagCustomer.customerid
                FROM
                  EDW_TRIPS_STAGE.TollTagCustomer
            )
             AND History_tp_customers.lnd_updatetype <> 'D'
      ;

      SET log_message = 'Loaded EDW_TRIPS_STAGE.TollTagCustomerHistory';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
    
      
      CREATE TEMPORARY TABLE _SESSION.cte_tolltagcustomerhistory_monthend AS (
          SELECT
              ch.*,
              m.*,
              row_number() OVER (PARTITION BY m.monthid, ch.customerid ORDER BY ch.updateddate DESC, ch.histid DESC) AS rn
            FROM
              EDW_TRIPS_STAGE.TollTagCustomerHistory AS ch
              INNER JOIN __cw_local_tmp_load_months AS m ON ch.updateddate < m.monthenddate
      );--SELECT * FROM CTE_TollTagCustomerHistory_MonthEnd WHERE CustomerID = 2754086 ORDER BY MonthID, CustomerID, RN

      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.TollTagCustomerHistory_MonthEnd
      CLUSTER BY CustomerID
      AS
        SELECT
            chm.monthid,
            chm.src,
            chm.histid,
            chm.customerid,
            chm.accounttypeid,
            t.accounttypedesc,
            chm.accountstatusid,
            s.accountstatusdesc,
            chm.accountstatusdate
          FROM
            cte_tolltagcustomerhistory_monthend AS chm
            LEFT OUTER JOIN EDW_TRIPS.dim_accounttype AS t 
              ON chm.accounttypeid = t.accounttypeid
            LEFT OUTER JOIN EDW_TRIPS.dim_accountstatus AS s 
              ON chm.accountstatusid = s.accountstatusid
          WHERE chm.rn = 1 
          --ORDER BY CHR.MonthID, CHR.CustomerID 
      ;
      


      SET log_message = 'Loaded EDW_TRIPS_STAGE.TollTagCustomerHistory_MonthEnd';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

      /*
      --:: Quick test 
      SELECT 'Current' SRC, * FROM LND_TBOS.TollPlus.TP_Customers WHERE LND_UpdateType <> 'D' AND CustomerID = 2754086 ORDER BY CustomerID, UpdatedDate
      SELECT 'History' SRC, * FROM LND_TBOS.History.TP_Customers WHERE LND_UpdateType <> 'D' AND CustomerID = 2754086 ORDER BY CustomerID, UpdatedDate

      SELECT 'Stage.TollTagCustomerHistory' SRC, * FROM Stage.TollTagCustomerHistory WHERE CustomerID = 2754086 ORDER BY CustomerID, UpdatedDate
      SELECT 'Stage.TollTagCustomerHistory_MonthEnd' SRC, * FROM Stage.TollTagCustomerHistory_MonthEnd WHERE CustomerID = 2754086 ORDER BY CustomerID, MonthID
      */

      ------------------------------------------------------------------------------------------------------------------------------------------
      --:: Customer Customer Zip code History. Get customer zip code as of the last day of each month
      ------------------------------------------------------------------------------------------------------------------------------------------

      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.CustomerZipcodeHistory
      CLUSTER BY CustomerID
        AS
          SELECT
              'Current' AS src,
              TollPlus_tp_customer_addresses.customerid,
              COALESCE(NULLIF(TollPlus_tp_customer_addresses.zip1, ''), 'UNKNOWN') AS zipcode,
              TollPlus_tp_customer_addresses.updateddate
            FROM
              LND_TBOS.TollPlus_tp_customer_addresses
            WHERE TollPlus_tp_customer_addresses.customerid IN(
              SELECT DISTINCT
                  TollTagCustomer.customerid
                FROM
                  EDW_TRIPS_STAGE.TollTagCustomer
            )
             AND TollPlus_tp_customer_addresses.isactive = 1
             AND TollPlus_tp_customer_addresses.iscommunication = 1
             AND TollPlus_tp_customer_addresses.lnd_updatetype <> 'D'
          UNION DISTINCT
          SELECT
              'History' AS src,
              History_tp_customer_addresses.customerid,
              COALESCE(NULLIF(History_tp_customer_addresses.zip1, ''), 'UNKNOWN') AS zipcode,
              History_tp_customer_addresses.updateddate
            FROM
              LND_TBOS.History_tp_customer_addresses
            WHERE History_tp_customer_addresses.customerid IN(
              SELECT DISTINCT
                  TollTagCustomer.customerid
                FROM
                  EDW_TRIPS_STAGE.TollTagCustomer
            )
             AND History_tp_customer_addresses.isactive = 1
             AND History_tp_customer_addresses.iscommunication = 1
             AND History_tp_customer_addresses.lnd_updatetype <> 'D'
      ;

      SET log_message = 'Loaded EDW_TRIPS_STAGE.CustomerZipcodeHistory';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
            
      CREATE TEMPORARY TABLE _SESSION.cte_customerzipcodehistory_monthend AS (
        SELECT
            m.monthid,
            zh.src,
            zh.customerid,
            zh.zipcode,
            zh.updateddate,
            row_number() OVER (PARTITION BY m.monthid, zh.customerid ORDER BY zh.updateddate DESC) AS rn
          FROM
            EDW_TRIPS_STAGE.CustomerZipcodeHistory AS zh
            INNER JOIN __cw_local_tmp_load_months AS m ON zh.updateddate < m.monthenddate
      );--SELECT * FROM CTE_CustomerZipcodeHistory_MonthEnd WHERE CustomerID = 4141325 ORDER BY MonthID, CustomerID, RN

      CREATE OR REPLACE  TABLE EDW_TRIPS_STAGE.CustomerZipcodeHistory_MonthEnd
      CLUSTER BY CustomerID
        AS
          SELECT
              cte_customerzipcodehistory_monthend.monthid,
              cte_customerzipcodehistory_monthend.src,
              cte_customerzipcodehistory_monthend.customerid,
              cte_customerzipcodehistory_monthend.zipcode,
              cte_customerzipcodehistory_monthend.updateddate,
              cte_customerzipcodehistory_monthend.rn
            FROM
              cte_customerzipcodehistory_monthend
            WHERE cte_customerzipcodehistory_monthend.rn = 1
            --AND	CustomerID = 4141325
		        --ORDER BY CustomerID, MonthID, UpdatedDate
      ;
      
      SET log_message = 'Loaded EDW_TRIPS_STAGE.CustomerZipcodeHistory_MonthEnd';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      /*
      --:: Quick test 
      SELECT 'Current' SRC, * FROM LND_TBOS.TollPlus.TP_Customer_Addresses WHERE	IsActive = 1 AND IsCommunication = 1 AND LND_UpdateType <> 'D' AND CustomerID = 4141325 ORDER BY CustomerID, UpdatedDate
      SELECT 'History' SRC, * FROM LND_TBOS.History.TP_Customer_Addresses WHERE	IsActive = 1 AND IsCommunication = 1 AND LND_UpdateType <> 'D' AND CustomerID = 4141325 ORDER BY CustomerID, UpdatedDate
      SELECT * FROM Stage.CustomerZipcodeHistory WHERE CustomerID = 4141325 ORDER BY CustomerID, UpdatedDate -- more than one zip code, all in one month example. 75149 and 75181 in 202101 based on UpdatedDate
      SELECT * FROM Stage.CustomerZipcodeHistory_MonthEnd WHERE CustomerID = 4141325 ORDER BY CustomerID, MonthID, UpdatedDate
      */

      ------------------------------------------------------------------------------------------------------------------------------------------
      --:: Customer Rebill Amount History. Get customer rebill amount as of the last day of each month
      ------------------------------------------------------------------------------------------------------------------------------------------
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.RebillHistory
      CLUSTER BY CustomerID
        AS
          SELECT
              'Current' AS src, /*current*/
              999999999 AS histid,
              TollPlus_tp_customer_attributes.customerid,
              TollPlus_tp_customer_attributes.autoreplenishmentid,
              TollPlus_tp_customer_attributes.calculatedrebillamount AS rebillamount,
              TollPlus_tp_customer_attributes.updateddate
            FROM
              LND_TBOS.TollPlus_tp_customer_attributes
            WHERE TollPlus_tp_customer_attributes.customerid IN(
              SELECT DISTINCT
                  TollTagCustomer.customerid
                FROM
                  EDW_TRIPS_STAGE.TollTagCustomer
            )
             AND TollPlus_tp_customer_attributes.lnd_updatetype <> 'D' -- WHERE CustomerID = 2015793598
          UNION DISTINCT
          SELECT
              'History' AS src,
              History_tp_customer_attributes.histid,
              History_tp_customer_attributes.customerid,
              History_tp_customer_attributes.autoreplenishmentid,
              History_tp_customer_attributes.calculatedrebillamount,
              History_tp_customer_attributes.updateddate
            FROM
              LND_TBOS.History_tp_customer_attributes
            WHERE History_tp_customer_attributes.customerid IN(
              SELECT DISTINCT
                  TollTagCustomer.customerid
                FROM
                  EDW_TRIPS_STAGE.TollTagCustomer
            )
             AND History_tp_customer_attributes.lnd_updatetype <> 'D' -- WHERE CustomerID = 2015793598
      ;
      

      SET log_message = 'Loaded EDW_TRIPS_STAGE.RebillHistory';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
            
      CREATE TEMPORARY TABLE _SESSION.cte_rebillhistory_monthend AS (
          SELECT
              m.monthid,
              rbh.src,
              rbh.histid,
              rbh.customerid,
              rbh.autoreplenishmentid,
              rbh.rebillamount,
              rbh.updateddate,
              row_number() OVER (PARTITION BY m.monthid, rbh.customerid ORDER BY rbh.updateddate DESC, rbh.histid DESC) AS rn
            FROM
              EDW_TRIPS_STAGE.RebillHistory AS rbh
              INNER JOIN __cw_local_tmp_load_months AS m ON rbh.updateddate < m.monthenddate
      ); --SELECT * FROM CTE_RebillHistory_MonthEnd WHERE CustomerID = 2015793598 ORDER BY MonthID, CustomerID, RN

      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.RebillHistory_MonthEnd
      CLUSTER BY CustomerID
        AS
          SELECT
              cte_rebillhistory_monthend.monthid,
              cte_rebillhistory_monthend.src,
              cte_rebillhistory_monthend.histid,
              cte_rebillhistory_monthend.customerid,
              cte_rebillhistory_monthend.autoreplenishmentid,
              cte_rebillhistory_monthend.rebillamount,
              CASE
                WHEN cte_rebillhistory_monthend.rebillamount IS NULL THEN -1
                WHEN cte_rebillhistory_monthend.rebillamount < 20 THEN 1
                WHEN cte_rebillhistory_monthend.rebillamount = 20 THEN 2
                WHEN cte_rebillhistory_monthend.rebillamount > 20
                  AND cte_rebillhistory_monthend.rebillamount < 40 THEN 3
                WHEN cte_rebillhistory_monthend.rebillamount >= 40 THEN 4
              END AS rebillamountgroupid,
              cte_rebillhistory_monthend.updateddate,
              cte_rebillhistory_monthend.rn
            FROM
              cte_rebillhistory_monthend
            WHERE cte_rebillhistory_monthend.rn = 1
            --AND CustomerID = 2022417992
		        --ORDER BY CustomerID, MonthID, UpdatedDate
      ;

      SET log_message = 'Loaded EDW_TRIPS_STAGE.RebillHistory_MonthEnd';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
      /*
      --:: Quick test 
      SELECT 	'Current' SRC, * FROM LND_TBOS.TollPlus.TP_CUSTOMER_ATTRIBUTES WHERE CustomerID = 2015793598 AND LND_UpdateType <> 'D' 
      SELECT 	'History' SRC, * FROM LND_TBOS.History.TP_CUSTOMER_ATTRIBUTES WHERE CustomerID = 2015793598 AND LND_UpdateType <> 'D' 
      SELECT 'Stage.RebillHistory' SRC, * FROM Stage.RebillHistory WHERE CustomerID = 2015793598 ORDER BY CustomerID, UpdatedDate
      SELECT 'Stage.RebillHistory_MonthEnd' SRC, * FROM Stage.RebillHistory_MonthEnd WHERE CustomerID = 2015793598 ORDER BY CustomerID, MonthID
      */

      --::======================================================================================================================================
      --:: Load dbo.Fact_CustomerTagDetail
      --::======================================================================================================================================
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.CustomerTagDetail
        AS
          SELECT
              MonthBeginTags.monthid,
              MonthBeginTags.custtagid,
              MonthBeginTags.customerid,
              MonthBeginTags.tagagency,
              MonthBeginTags.tagid,
              'MONTH BEGIN' AS tagcounter,
              CAST(FORMAT_DATETIME("%Y-%m-%dT%H:%M:%S",MonthBeginTags.monthbegindate) as DATETIME) tagcounterdate,
              1 AS monthbegintag,
              0 AS openedtag,
              0 AS closedtag,
              0 AS monthendtag
            FROM
              EDW_TRIPS_STAGE.MonthBeginTags

          UNION ALL

          SELECT
              MonthOpenedTags.monthid,
              MonthOpenedTags.custtagid,
              MonthOpenedTags.customerid,
              MonthOpenedTags.tagagency,
              MonthOpenedTags.tagid,
              'TAG OPENED' AS tagcounter,
              CAST(FORMAT_DATETIME("%Y-%m-%dT%H:%M:%S",MonthOpenedTags.tagstartdate) as DATETIME) tagcounterdate,
              0 AS monthbegintag,
              1 AS openedtag,
              0 AS closedtag,
              0 AS monthendtag
            FROM
              EDW_TRIPS_STAGE.MonthOpenedTags

          UNION ALL

          SELECT
              MonthClosedTags.monthid,
              MonthClosedTags.custtagid,
              MonthClosedTags.customerid,
              MonthClosedTags.tagagency,
              MonthClosedTags.tagid,
              'TAG CLOSED' AS tagcounter,
              CAST(FORMAT_DATETIME("%Y-%m-%dT%H:%M:%S",MonthClosedTags.tagstartdate) as DATETIME) tagcounterdate,
              0 AS monthbegintag,
              0 AS openedtag,
              1 AS closedtag,
              0 AS monthendtag
            FROM
              EDW_TRIPS_STAGE.MonthClosedTags

          UNION ALL

          SELECT
              MonthEndTags.monthid,
              MonthEndTags.custtagid,
              MonthEndTags.customerid,
              MonthEndTags.tagagency,
              MonthEndTags.tagid,
              'MONTH END' AS tagcounter,
              CAST(FORMAT_DATETIME("%Y-%m-%dT%H:%M:%S",MonthEndTags.monthenddate) as DATETIME) tagcounterdate,
              0 AS monthbegintag,
              0 AS openedtag,
              0 AS closedtag,
              1 AS monthendtag
            FROM
              EDW_TRIPS_STAGE.MonthEndTags
      ;
      

      SET log_message = 'Loaded EDW_TRIPS_STAGE.CustomerTagDetail';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
      SET sql="""
              CREATE OR REPLACE TABLE `EDW_TRIPS.Fact_CustomerTagDetail_NEW` 
              CLUSTER BY CustomerID 
                AS  
                SELECT      
                    td.monthid,     
                    td.customerid,     
                    COALESCE(CAST(rh.rebillamountgroupid AS INT64), -1) AS rebillamountgroupid,     
                    rh.rebillamount,     
                    COALESCE(CAST(rh.autoreplenishmentid AS INT64), -1) AS autoreplenishmentid,     
                    COALESCE(CAST(ch.accountstatusid AS INT64), -1) AS accountstatusid,     
                    COALESCE(CAST(ch.accounttypeid AS INT64), -1) AS accounttypeid,     
                    COALESCE(czh.zipcode, 'UNK') AS zipcode,     
                    a.accountcreatedate,     
                    a.accountlastclosedate,     
                    td.custtagid,     
                    td.tagagency,     
                    td.tagid,     
                    td.tagcounter,     
                    CAST(FORMAT_DATETIME(\"%Y-%m-%dT%H:%M:%S\",td.tagcounterdate) as DATETIME) as tagcounterdate,     
                    td.monthbegintag,     
                    td.openedtag,     
                    td.closedtag,     
                    td.monthendtag,     
                    CURRENT_DATETIME() AS edw_updatedate 
                    FROM      `EDW_TRIPS_STAGE.CustomerTagDetail` td 
                      JOIN      `EDW_TRIPS_STAGE.TollTagCustomer` A     
                        ON td.customerid = a.customerid 
                      LEFT JOIN  `EDW_TRIPS_STAGE.TollTagCustomerHistory_MonthEnd` ch     
                        ON ch.Customerid = a.Customerid 
                          AND ch.monthid = td.monthid
                      LEFT JOIN  `EDW_TRIPS_STAGE.RebillHistory_MonthEnd` rh     
                        ON rh.customerid = a.customerid 
                          AND rh.monthid = td.monthid 
                      LEFT JOIN  `EDW_TRIPS_STAGE.CustomerZipcodeHistory_MonthEnd` czh     
                        ON czh.customerid = a.customerid 
                          AND czh.monthid = td.monthid 
              """
              ;

      IF trace_flag = 1 THEN
        CALL EDW_TRIPS_SUPPORT.LongPrint(sql);
      END IF;

      EXECUTE IMMEDIATE sql;

      SET log_message = 'Loaded EDW_TRIPS.Fact_CustomerTagDetail_NEW';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, cast(-1 as string));
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Fact_CustomerTagDetail_NEW' AS src,
            *
          FROM
            EDW_TRIPS.Fact_CustomerTagDetail_NEW
            ORDER BY monthid,customerid LIMIT 100
        ;
      END IF;
      ------------------------------------------------------------------------------------------------------------------------------------------
      -- Finish full load
      ------------------------------------------------------------------------------------------------------------------------------------------
      IF is_full_load = 1 THEN
        --TableSwap is Not Required , using  Create or Replace Table
        CREATE OR REPLACE TABLE EDW_TRIPS.Fact_CustomerTagDetail AS SELECT * FROM  EDW_TRIPS.Fact_CustomerTagDetail_NEW;
        SET log_message = 'Completed full load';
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);

      ------------------------------------------------------------------------------------------------------------------------------------------
      -- Finish incremental load
      ------------------------------------------------------------------------------------------------------------------------------------------

      ELSE
        IF trace_flag = 1 THEN
        END IF;        
        --:: Delete old rows from the main table
        DELETE FROM EDW_TRIPS.Fact_CustomerTagDetail WHERE Fact_CustomerTagDetail.monthid BETWEEN start_month_id AND end_month_id;
        SET log_message = CONCAT('Delete old rows for ', load_period, ' (', substr(CAST(start_month_id as STRING), 1, 30), ' to ', substr(CAST(end_month_id as STRING), 1, 30), ') from EDW_TRIPS.Fact_CustomerTagDetail');
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
        
        
        --:: Add new rows from _NEW table which has new and modified rows
        INSERT INTO EDW_TRIPS.Fact_CustomerTagDetail (monthid, customerid, rebillamountgroupid, rebillamount, accountstatusid, accounttypeid, autoreplenishmentid, zipcode, accountcreatedate, accountlastclosedate, custtagid, tagagency, tagid, tagcounter, tagcounterdate, monthbegintag, openedtag, closedtag, monthendtag, edw_updatedate)
          SELECT
              Fact_CustomerTagDetail_NEW.monthid,
              Fact_CustomerTagDetail_NEW.customerid,
              Fact_CustomerTagDetail_NEW.rebillamountgroupid,
              Fact_CustomerTagDetail_NEW.rebillamount,
              Fact_CustomerTagDetail_NEW.accountstatusid,
              Fact_CustomerTagDetail_NEW.accounttypeid,
              Fact_CustomerTagDetail_NEW.autoreplenishmentid,
              Fact_CustomerTagDetail_NEW.zipcode,
              Fact_CustomerTagDetail_NEW.accountcreatedate,
              Fact_CustomerTagDetail_NEW.accountlastclosedate,
              Fact_CustomerTagDetail_NEW.custtagid,
              Fact_CustomerTagDetail_NEW.tagagency,
              Fact_CustomerTagDetail_NEW.tagid,
              Fact_CustomerTagDetail_NEW.tagcounter,
              CAST(FORMAT_DATETIME("%Y-%m-%dT%H:%M:%S",Fact_CustomerTagDetail_NEW.tagcounterdate) as DATETIME) as tagcounterdate,
              Fact_CustomerTagDetail_NEW.monthbegintag,
              Fact_CustomerTagDetail_NEW.openedtag,
              Fact_CustomerTagDetail_NEW.closedtag,
              Fact_CustomerTagDetail_NEW.monthendtag,
              Fact_CustomerTagDetail_NEW.edw_updatedate
            FROM
              EDW_TRIPS.Fact_CustomerTagDetail_NEW
        ;

        SET log_message = CONCAT('Inserted new rows for ', load_period, ' (', substr(CAST(start_month_id as STRING), 1, 30), ' to ', substr(CAST(end_month_id as STRING), 1, 30), ') into EDW_TRIPS.Fact_CustomerTagDetail');
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
        -- Log
        SET log_message = 'Completed Incremental Daily Load';
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
      END IF;

      /*
      --:: Quick test 
      SELECT 'Stage.CustomerTagDetail' SRC, * FROM Stage.CustomerTagDetail  WHERE CustomerID = 2015793598 ORDER BY MonthID, CustomerID, TagAgency, TagID, CustTagID, TagCounterDate
      SELECT 'dbo.Fact_CustomerTagDetail_NEW' SRC, * FROM dbo.Fact_CustomerTagDetail_NEW  WHERE CustomerID = 2015793598 ORDER BY MonthID, CustomerID, TagAgency, TagID, CustTagID, TagCounterDate
      SELECT 'dbo.vw_CustomerTagSummary' SRC,TOP 100 * FROM dbo.vw_CustomerTagSummary WHERE MonthID >= 202101 AND CustomerID = 2015793598  ORDER BY CustomerID DESC, MonthID
      */	
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Fact_CustomerTagDetail' AS src,
            Fact_CustomerTagDetail.*
          FROM
            EDW_TRIPS.Fact_CustomerTagDetail
        ORDER BY
          customerid DESC,
          monthid DESC LIMIT 1000
        ;
      END IF;
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS_SUPPORT.ProcessLog' AS src,
            *
          FROM
            EDW_TRIPS_SUPPORT.ProcessLog
          WHERE ProcessLog.logsource = 'EDW_TRIPS.Fact_CustomerTagDetail'
           AND ProcessLog.logdate >= log_start_date
        ORDER BY
          logdate DESC LIMIT 100
        ;
      END IF;
      EXCEPTION WHEN ERROR THEN
        BEGIN
          DECLARE error_message STRING DEFAULT @@error.message;
          CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
          SELECT log_source,log_start_date; -- Replacement for FromLog
          RAISE USING MESSAGE = error_message; -- Rethrow the error!
        END;
      END;
/*
--::======================================================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--::======================================================================================================================================

--:: Run SP
EXEC dbo.Fact_CustomerTagDetail_Load @Start_Month_ID = 202101, @End_Month_ID = 202311, @Is_Full_Load = 1 -- Month Range Full Load
EXEC dbo.Fact_CustomerTagDetail_Load @Start_Month_ID = 202302, @End_Month_ID = 202303, @Is_Full_Load = 0 -- Month Range Load
EXEC dbo.Fact_CustomerTagDetail_Load @Start_Month_ID = NULL, @End_Month_ID = NULL, @Is_Full_Load = 0 -- Daily Incremental Run

SELECT TOP 100 * FROM Utility.ProcessLog WHERE LogSource = 'dbo.Fact_CustomerTagDetail_Load' ORDER BY 1 DESC
SELECT TOP 100 'dbo.Fact_CustomerTagDetail_Load' Table_Name, * FROM dbo.Fact_CustomerTagDetail ORDER BY 1,2

--::======================================================================================================================================
-- dbo.Fact_CustomerTagDetail data validation and research scripts
--::======================================================================================================================================

-------------------------------------------------------------------------------------------------------------------------------------------
--:1: Account/Tag level attributes validation
-------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @MonthID INT = 202202, @CustomerID BIGINT = 112864,  @TagID VARCHAR(20) = NULL
--:: Fact table output
SELECT 'vw_CustomerTagSummary' ViewName, * FROM dbo.vw_CustomerTagSummary WHERE MonthID = ISNULL(@MonthID,MonthID) AND CustomerID = @CustomerID
SELECT 'dbo.Fact_CustomerTagDetail' TableName, * FROM dbo.Fact_CustomerTagDetail F WHERE	F.MonthID = ISNULL(@MonthID,F.MonthID) AND F.CustomerID = @CustomerID AND F.TagID = ISNULL(@TagID,TagID) ORDER BY CustomerID, F.MonthID, TagID, TagCounterDate
--:: Source and ETL stage tables used in the process of loading the fact table
SELECT 'Stage.CustomerTagDetail' TableName, * FROM Stage.CustomerTagDetail WHERE MonthID = ISNULL(@MonthID,MonthID) AND CustomerID = @CustomerID AND TagID = ISNULL(@TagID,TagID)  ORDER BY CustomerID, MonthID, TagID, TagCounterDate -- Open/Close in this month
SELECT 'Stage.CustomerTags' TableName, *  FROM Stage.CustomerTags WHERE CustomerID = @CustomerID AND TagID = ISNULL(@TagID,TagID)  ORDER BY CustomerID, TagID, HistID -- Source data AFTER some data clean up
SELECT 'Stage.CustomerTags_Source' TableName, *  FROM Stage.CustomerTags_Source WHERE CustomerID = @CustomerID AND TagID = ISNULL(@TagID,TagID)  ORDER BY CustomerID, TagID, HistID -- Source data AS IS
SELECT 'Stage.CustomerTags' TableName, *  FROM Stage.CustomerTags WHERE CustomerID = @CustomerID AND TagID = ISNULL(@TagID,TagID)  ORDER BY CustomerID, TagID, HistID -- Source data AFTER some data clean up
SELECT 'Stage.MonthBeginTags' TableName, * FROM Stage.MonthBeginTags WHERE MonthID = ISNULL(@MonthID,MonthID) AND CustomerID = @CustomerID AND TagID = ISNULL(@TagID,TagID)  ORDER BY CustomerID, MonthID, TagID, HistID
SELECT 'Stage.MonthEndTags' TableName, * FROM Stage.MonthEndTags WHERE MonthID = ISNULL(@MonthID,MonthID) AND CustomerID = @CustomerID AND TagID = ISNULL(@TagID,TagID)  ORDER BY CustomerID, MonthID, TagID, HistID
SELECT 'Stage.OpenedClosedTags_Source' TableName, * FROM Stage.OpenedClosedTags_Source WHERE CustomerID = @CustomerID AND TagID = ISNULL(@TagID,TagID)  ORDER BY CustomerID, TagID, HistID, CHANGE_NUM, CHANGE_NUM_SEQ -- Full picture
SELECT 'Stage.OpenedClosedTags' TableName, * FROM Stage.OpenedClosedTags WHERE MonthID = ISNULL(@MonthID,MonthID) AND CustomerID = @CustomerID AND TagID = ISNULL(@TagID,TagID)  ORDER BY CustomerID, MonthID, TagID, HistID -- Open/Close in this month
SELECT 'Stage.MonthOpenedTags' TableName, * FROM Stage.MonthOpenedTags WHERE MonthID = ISNULL(@MonthID,MonthID) AND CustomerID = @CustomerID AND TagID = ISNULL(@TagID,TagID)  ORDER BY CustomerID, MonthID, TagID, HistID
SELECT 'Stage.MonthClosedTags' TableName, * FROM Stage.MonthClosedTags WHERE MonthID = ISNULL(@MonthID,MonthID) AND CustomerID = @CustomerID AND TagID = ISNULL(@TagID,TagID)  ORDER BY CustomerID, MonthID, TagID, HistID 

-------------------------------------------------------------------------------------------------------------------------------------------
--:2: Account level attributes validation
-------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @MonthID INT = 202202, @CustomerID BIGINT = 112864,  @TagID VARCHAR(20) = NULL
SELECT 'Stage.TollTagCustomer' TableName, * FROM Stage.TollTagCustomer WHERE CustomerID = @CustomerID  
SELECT 'Stage.TollTagCustomerHistory' TableName, * FROM Stage.TollTagCustomerHistory WHERE CustomerID = @CustomerID ORDER BY CustomerID, HistID  
SELECT 'Stage.TollTagCustomerHistory_MonthEnd' TableName, * FROM Stage.TollTagCustomerHistory_MonthEnd WHERE MonthID = ISNULL(@MonthID,MonthID) AND CustomerID = @CustomerID ORDER BY CustomerID, MonthID, HistID
SELECT 'Stage.RebillHistory' TableName, * FROM Stage.RebillHistory WHERE CustomerID = @CustomerID ORDER BY CustomerID, HistID  
SELECT 'Stage.RebillHistory_MonthEnd' TableName, * FROM Stage.RebillHistory_MonthEnd WHERE MonthID = ISNULL(@MonthID,MonthID) AND CustomerID = @CustomerID ORDER BY CustomerID, MonthID, HistID
SELECT 'Stage.CustomerZipcodeHistory' TableName, * FROM Stage.CustomerZipcodeHistory WHERE CustomerID = @CustomerID ORDER BY CustomerID 
SELECT 'Stage.CustomerZipcodeHistory_MonthEnd' TableName, * FROM Stage.CustomerZipcodeHistory_MonthEnd WHERE MonthID = ISNULL(@MonthID,MonthID) AND CustomerID = @CustomerID ORDER BY CustomerID, MonthID 
 
--::======================================================================================================================================
-- Technical help
--::======================================================================================================================================

-- Fact Table Partition info
SELECT s.name + '.' + t.[name] table_name, p.[partition_number], rv.[value], *
FROM      sys.schemas s
JOIN      sys.Tables t                  ON t.[schema_id]      = s.[schema_id]
JOIN      sys.partitions p              ON p.[object_id]      = t.[object_id] AND p.[index_id] <= 1
JOIN      sys.indexes i                 ON i.[object_id]      = p.[object_id] AND i.[index_id] = p.[index_id]
JOIN      sys.data_spaces ds            ON ds.[data_space_id] = i.[data_space_id]
LEFT JOIN sys.partition_schemes ps      ON ps.[data_space_id] = ds.[data_space_id]
LEFT JOIN sys.partition_functions pf    ON pf.[function_id]   = ps.[function_id]
LEFT JOIN sys.partition_range_values rv ON rv.[function_id]   = pf.[function_id] AND rv.[boundary_id] = p.[partition_number]
WHERE s.name = 'dbo' AND t.[name] = 'Fact_CustomerTagDetail'
ORDER BY 1,2

--::======================================================================================================================================
-- !!! Dynamic SQL!!! 
--::======================================================================================================================================

IF OBJECT_ID('dbo.Fact_CustomerTagDetail_NEW') IS NOT NULL DROP TABLE dbo.Fact_CustomerTagDetail_NEW
CREATE TABLE dbo.Fact_CustomerTagDetail_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(CustomerID), 
		PARTITION (MonthID RANGE RIGHT FOR VALUES 
					(20201201,20210101,20210201,20210301,20210401,20210501,20210601,20210701,20210801,20210901,20211001,20211101,20211201,
					          20220101,20220201,20220301,20220401,20220501,20220601,20220701,20220801,20220901,20221001,20221101,20221201,
					          20230101,20230201,20230301,20230401,20230501,20230601,20230701,20230801,20230901,20231001,20231101,20231201,
					          20240101,20240201))) AS
SELECT	TD.MonthID,
		TD.CustomerID,
		ISNULL(CAST(RH.RebillAmountGroupID AS SMALLINT),-1) RebillAmountGroupID,
		RH.RebillAmount RebillAmount,
		ISNULL(CAST(RH.AutoReplenishmentID AS INT),-1) AutoReplenishmentID,
		ISNULL(CAST(CH.AccountStatusID AS INT),-1) AccountStatusID,
		ISNULL(CAST(CH.AccountTypeID AS INT),-1) AccountTypeID,
		ISNULL(CZH.ZipCode,'UNKNOWN') ZipCode,
		A.AccountCreateDate,
		A.AccountLastCloseDate,
		TD.CustTagID,
		TD.TagAgency,
		TD.TagID,
		TD.TagCounter,
		TD.TagCounterDate,
		TD.MonthBeginTag,
		TD.OpenedTag,
		TD.ClosedTag,
		TD.MonthEndTag,
		CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
FROM	Stage.CustomerTagDetail TD
JOIN	Stage.TollTagCustomer A
			ON TD.CustomerID = A.CustomerID
LEFT JOIN	Stage.TollTagCustomerHistory_MonthEnd CH
			ON CH.CustomerID = A.CustomerID
			AND CH.MonthID = TD.MonthID
LEFT JOIN	Stage.RebillHistory_MonthEnd RH
			ON RH.CustomerID = A.CustomerID
			AND RH.MonthID = TD.MonthID
LEFT JOIN	Stage.CustomerZipcodeHistory_MonthEnd CZH
			ON CZH.CustomerID = A.CustomerID
			AND CZH.MonthID = TD.MonthID 
OPTION  (LABEL = 'dbo.Fact_CustomerTagDetail_NEW');

*/

END;