CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Dim_Day_Hierarchy_Full_Load`()
BEGIN
/*
###################################################################################################################
Purpose: Load all Date/Time dimension hierarchy tables. Run it once a year to load upto next year. 

Notes:
		- Rolling data Load of denormalized Date dimension tables at every Date hierarchy level
		- Consistent column naming and same shared data across all Date dim tables
		- Overlapping Star Schema Dimensional Model
		- Natural Hierarchies: 1) Day -> Month -> Quarter -> Year
							   2) Day -> Week
		- MicroStategy Design Theme: Join once from the fact table to any Level Date dim table and you are good! 
		- Level ID Column is the marker for the beginning of the group of columns for that Level
		- Robust set of Time Intelligence database transformations available at all levels towards the table end

Tables: !!! MATRYOSHKA RUSSIAN DOLLS ETL DESIGN PATTERN !!!
		- dbo.Dim_Year		-> Year level
		- dbo.Dim_Quarter	-> Quarter level + dbo.Dim_Year
		- dbo.Dim_Month		-> Month level + dbo.Dim_Quarter
		- dbo.Dim_Week		-> Week level + dbo.Dim_Month
		- dbo.Dim_Day		-> Day level + dbo.Dim_Week + dbo.Dim_Month
		- dbo.Dim_Time	    -> 24 Hours in HH MM SS level, in 5,10,15,30 min interval groups, in 12 and 24 HR format 
-------------------------------------------------------------------------------------------------------------------
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Andy and Shankar	2020-06-04	New!
-------------------------------------------------------------------------------------------------------------------
Run script:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_Day_Hierarchy_Full_Load

EXEC Utility.FromLog 'dbo.Dim_Day', 1
SELECT 'dbo.Dim_Year' TableName, * FROM  dbo.Dim_Year ORDER BY 2 DESC 
SELECT 'dbo.Dim_Quarter' TableName, * FROM dbo.Dim_Quarter ORDER BY 2 DESC
SELECT 'dbo.Dim_Month' TableName, * FROM dbo.Dim_Month ORDER BY 2 DESC
SELECT 'dbo.Dim_Week' TableName, * FROM dbo.Dim_Week ORDER BY 2 DESC
SELECT 'dbo.Dim_Day' TableName, * FROM dbo.Dim_Day ORDER BY 2 DESC
SELECT 'dbo.Dim_Time' TableName, * FROM dbo.Dim_Time ORDER BY 2 DESC

--:: Duplicate check
SELECT 'dbo.Dim_Year' TableName, YearID, COUNT(1) RC FROM  dbo.Dim_Year GROUP BY YearID HAVING COUNT(1) > 1
SELECT 'dbo.Dim_Quarter' TableName, QuarterID, COUNT(1) RC FROM dbo.Dim_Quarter GROUP BY QuarterID HAVING COUNT(1) > 1
SELECT 'dbo.Dim_Month' TableName, MonthID, COUNT(1) RC FROM dbo.Dim_Month GROUP BY MonthID HAVING COUNT(1) > 1
SELECT 'dbo.Dim_Week' TableName, WeekID, COUNT(1) RC FROM dbo.Dim_Week GROUP BY WeekID HAVING COUNT(1) > 1
SELECT 'dbo.Dim_Day' TableName, DayID, COUNT(1) RC FROM dbo.Dim_Day GROUP BY DayID HAVING COUNT(1) > 1
SELECT 'dbo.Dim_Time' TableName, TimeID, COUNT(1) RC FROM dbo.Dim_Time GROUP BY TimeID HAVING COUNT(1) > 1

###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_Day_Hierarchy_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0; -- Testing
    DECLARE q1_begin_date DATE DEFAULT cast('2000-1-1' as date);
    DECLARE q1_end_date DATE DEFAULT cast('2000-3-31' as date);
    DECLARE row_count INT64;
    BEGIN
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load of Hierarchy dim tables', '-1', CAST(NULL as INT64), 'I');

		--=============================================================================================================
		-- Load dbo.Dim_Year		->	Year Level
		--=============================================================================================================

      -- DROP TABLE IF EXISTS EDW_TRIPS.Dim_Year_NEW;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_Year cluster by YearID
        AS
          SELECT
              --:: Year Level
              coalesce(CAST(Dim_Year.cal_yearid as INT64), 0) AS yearid,
              CAST(Dim_Year.yeardate as DATE) AS yearbegindate,
              --:: All Time Intelligence attributes neatly packed at the end of the table. Primary level attribute columns come first for each level followed by these attributes. 
              CAST(Dim_Year.yearduration as INT64) AS yearduration,
              CASE
                WHEN Dim_Year.cal_prevyearid >= 2000 THEN Dim_Year.cal_prevyearid
                ELSE 0
              END AS p1yearid,
              CASE
                WHEN Dim_Year.cal_prev2yearid >= 2000 THEN Dim_Year.cal_prev2yearid
                ELSE 0
              END AS p2yearid,
              CASE
                WHEN Dim_Year.cal_prev3yearid >= 2000 THEN Dim_Year.cal_prev3yearid
                ELSE 0
              END AS p3yearid,
              CASE
                WHEN Dim_Year.cal_prev4yearid >= 2000 THEN Dim_Year.cal_prev4yearid
                ELSE 0
              END AS p4yearid,
              CASE
                WHEN Dim_Year.cal_prev5yearid >= 2000 THEN Dim_Year.cal_prev5yearid
                ELSE 0
              END AS p5yearid,
              CASE
                WHEN Dim_Year.cal_prev6yearid >= 2000 THEN Dim_Year.cal_prev6yearid
                ELSE 0
              END AS p6yearid,
              CASE
                WHEN Dim_Year.cal_prev7yearid >= 2000 THEN Dim_Year.cal_prev7yearid
                ELSE 0
              END AS p7yearid,
              current_datetime() AS lastmodified
              -- SELECT *
            FROM
              EDW_TRIPS_SUPPORT.Dim_Year
            WHERE Dim_Year.cal_yearid <= extract(YEAR from CAST(current_datetime() as DATE)) + 1
      ;
      -- Log
      SET log_message = 'Loaded EDW_TRIPS.Dim_Year with Year level';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));

      --Tableswap not required , using create or replace
      -- CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_Year_NEW', 'EDW_TRIPS.Dim_Year');
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Dim_Year' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_Year
        ORDER BY
          2 DESC
          LIMIT 100
        ;
      END IF;
      
		--=============================================================================================================
		-- Load dbo.Dim_Quarter		->	 Quarter + Year levels
		--=============================================================================================================

      -- DROP TABLE IF EXISTS EDW_TRIPS.Dim_Quarter_NEW;
      CREATE TEMPORARY TABLE _SESSION.cte_qtr AS (
            SELECT
                date_add(q1_begin_date, interval n.n - 1 QUARTER) AS quarterbegindate,
                date_add(q1_end_date, interval n.n - 1 QUARTER) AS quarterenddate,
                lag(date_add(q1_begin_date, interval n.n - 1 QUARTER), 1, NULL) OVER (ORDER BY date_add(q1_begin_date, interval n.n - 1 QUARTER)) AS p1quarterbegindate,
                lag(date_add(q1_begin_date, interval n.n - 1 QUARTER), 2, NULL) OVER (ORDER BY date_add(q1_begin_date, interval n.n - 1 QUARTER)) AS p2quarterbegindate,
                lag(date_add(q1_begin_date, interval n.n - 1 QUARTER), 3, NULL) OVER (ORDER BY date_add(q1_begin_date, interval n.n - 1 QUARTER)) AS p3quarterbegindate,
                lag(date_add(q1_begin_date, interval n.n - 1 QUARTER), 4, NULL) OVER (ORDER BY date_add(q1_begin_date, interval n.n - 1 QUARTER)) AS p4quarterbegindate
              FROM
                EDW_TRIPS_SUPPORT.Number AS n
              WHERE n.n <= 200
          );
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_Quarter cluster by QuarterID
        AS
          SELECT
              --:: Quarter Level
              CAST(concat(substr(CAST(extract(YEAR from cte_qtr.quarterbegindate) as STRING), 1, 4), substr(CAST(row_number() OVER (PARTITION BY extract(YEAR from cte_qtr.quarterbegindate) ORDER BY cte_qtr.quarterbegindate) as STRING), 1, 1)) as INT64) AS quarterid,
              cte_qtr.quarterbegindate,
              cte_qtr.quarterenddate,
              concat(substr(CAST(extract(YEAR from cte_qtr.quarterbegindate) as STRING), 1, 4), ' Q', substr(CAST(row_number() OVER (PARTITION BY extract(YEAR from cte_qtr.quarterbegindate) ORDER BY cte_qtr.quarterbegindate) as STRING), 1, 1)) AS yearquarterdesc,
              concat('Q', substr(CAST(row_number() OVER (PARTITION BY extract(YEAR from cte_qtr.quarterbegindate) ORDER BY cte_qtr.quarterbegindate) as STRING), 1, 1), ' ', substr(CAST(extract(YEAR from cte_qtr.quarterbegindate) as STRING), 1, 4)) AS quarteryeardesc,
              concat('Q', substr(CAST(row_number() OVER (PARTITION BY extract(YEAR from cte_qtr.quarterbegindate) ORDER BY cte_qtr.quarterbegindate) as STRING), 1, 1)) AS quarterdesc,
              date_diff(cte_qtr.quarterenddate, cte_qtr.quarterbegindate, DAY) + 1 AS quarterduration,
              --:: Year Level
              CAST(extract(YEAR from cte_qtr.quarterbegindate) as INT64) AS yearid,
              y.yearbegindate,
              y.yearduration,
              --:: All Time Intelligence attributes neatly packed at the end of the table. Primary level attribute columns come first for each level followed by these attributes. 
					    --:: Quarter
              CAST(coalesce(concat(substr(CAST(extract(YEAR from cte_qtr.p1quarterbegindate) as STRING), 1, 4), CAST(extract(quarter from cte_qtr.p1quarterbegindate) as STRING)), '0') as INT64) AS p1quarterid,
              CAST(coalesce(concat(substr(CAST(extract(YEAR from cte_qtr.p2quarterbegindate) as STRING), 1, 4), CAST(extract(quarter from cte_qtr.p2quarterbegindate) as STRING)), '0') as INT64) AS p2quarterid,
              CAST(coalesce(concat(substr(CAST(extract(YEAR from cte_qtr.p3quarterbegindate) as STRING), 1, 4), CAST(extract(quarter from cte_qtr.p3quarterbegindate) as STRING)), '0') as INT64) AS p3quarterid,
              CAST(coalesce(concat(substr(CAST(extract(YEAR from cte_qtr.p4quarterbegindate) as STRING), 1, 4), CAST(extract(quarter from cte_qtr.p4quarterbegindate) as STRING)), '0') as INT64) AS p4quarterid,
              CAST(coalesce(concat(substr(CAST(extract(YEAR from cte_qtr.p4quarterbegindate) as STRING), 1, 4), CAST(extract(quarter from cte_qtr.p4quarterbegindate) as STRING)), '0') as INT64) AS ly1quarterid,
              --:: Year
              y.p1yearid,
              y.p2yearid,
              y.p3yearid,
              y.p4yearid,
              y.p5yearid,
              y.p6yearid,
              y.p7yearid,
              current_datetime() AS lastmodified
            FROM
              cte_qtr
              INNER JOIN EDW_TRIPS.Dim_Year AS y ON y.yearid = CAST(extract(YEAR from cte_qtr.quarterbegindate) as INT64)
            WHERE extract(YEAR from cte_qtr.quarterbegindate) BETWEEN 2000 AND 2030
          UNION ALL
          SELECT
              19001,
              cast('1900-01-01' as date),
              cast('1900-03-31' as date),
              '1900 Q1',
              'Q1 1900',
              'Q1',
              91,
              Dim_Year.yearid,
              Dim_Year.yearbegindate,
              Dim_Year.yearduration,
              0 AS p1quarterid,
              0 AS p2quarterid,
              0 AS p3quarterid,
              0 AS p4quarterid,
              0 AS ly1quarterid,
              Dim_Year.p1yearid,
              Dim_Year.p2yearid,
              Dim_Year.p3yearid,
              Dim_Year.p4yearid,
              Dim_Year.p5yearid,
              Dim_Year.p6yearid,
              Dim_Year.p7yearid,
              Dim_Year.lastmodified
            FROM
              EDW_TRIPS.Dim_Year
            WHERE Dim_Year.yearid = 1900
      ;
      --Log
      SET log_message = 'Loaded EDW_TRIPS.Dim_Quarter with Quarter Level + EDW_TRIPS.Dim_Year';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));

      --Tableswap not required , using create or replace
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_Quarter_NEW', 'EDW_TRIPS.Dim_Quarter');
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Dim_Quarter' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_Quarter
        ORDER BY
          2 DESC
          LIMIT 100
        ;
        
      END IF;
      
		--=============================================================================================================
		-- Load dbo.Dim_Month		->	 Month + Quarter + Year levels
		--=============================================================================================================

      -- DROP TABLE IF EXISTS EDW_TRIPS.Dim_Month_NEW;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_Month CLUSTER BY MonthID
        AS
          SELECT
              --:: Month Level
              coalesce(CAST(main_table.cal_monthid as INT64), 0) AS monthid,
              CAST(main_table.monthdate as DATE) AS monthbegindate,
              last_day(DATE(monthdate)) AS monthenddate,
              concat(right(main_table.monthdesc, 4), ' ', left(main_table.monthdesc, 3)) AS yearmonthdesc,
              concat(left(main_table.monthdesc, 3), ' ', right(main_table.monthdesc, 4)) AS monthyeardesc,
              CAST(FORMAT_DATE("%B", monthdate) as STRING) AS monthdesc,
              CAST(main_table.cal_monthofyear as INT64) AS monthofyear,
              CAST(main_table.monthduration as INT64) AS monthduration,
              --:: Quarter, Year Levels
              q.quarterid,
              q.quarterbegindate,
              q.quarterenddate,
              q.yearquarterdesc,
              q.quarteryeardesc,
              q.quarterdesc,
              q.quarterduration,
              q.yearid,
              q.yearbegindate,
              q.yearduration,
              --:: All Time Intelligence attributes neatly packed at the end of the table. Primary level attribute columns come first for each level followed by these attributes.
              CASE
                WHEN date_sub(monthdate, interval 1 MONTH) >= CAST('2000-1-1' as DATE) THEN CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_sub(monthdate, interval 1 MONTH)) as STRING), 1, 6) as INT64)
                ELSE 0
              END AS p1monthid,
              CASE
                WHEN date_sub(monthdate, interval 2 MONTH) >= CAST('2000-1-1' as DATE) THEN CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_sub(monthdate, interval 2 MONTH)) as STRING), 1, 6) as INT64)
                ELSE 0
              END AS p2monthid,
              CASE
                WHEN date_sub(monthdate, interval 3 MONTH) >= CAST('2000-1-1' as DATE) THEN CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_sub(monthdate, interval 3 MONTH)) as STRING), 1, 6) as INT64)
                ELSE 0
              END AS p3monthid,
              CASE
                WHEN date_sub(monthdate, interval 4 MONTH) >= CAST('2000-1-1' as DATE) THEN CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_sub(monthdate, interval 4 MONTH)) as STRING), 1, 6) as INT64)
                ELSE 0
              END AS p4monthid,
              CASE
                WHEN date_sub(monthdate, interval 5 MONTH) >= CAST('2000-1-1' as DATE) THEN CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_sub(monthdate, interval 5 MONTH)) as STRING), 1, 6) as INT64)
                ELSE 0
              END AS p5monthid,
              CASE
                WHEN date_sub(monthdate, interval 6 MONTH) >= CAST('2000-1-1' as DATE) THEN CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_sub(monthdate, interval 6 MONTH)) as STRING), 1, 6) as INT64)
                ELSE 0
              END AS p6monthid,
              CASE
                WHEN date_sub(monthdate, interval 7 MONTH) >= CAST('2000-1-1' as DATE) THEN CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_sub(monthdate, interval 7 MONTH)) as STRING), 1, 6) as INT64)
                ELSE 0
              END AS p7monthid,
              CASE
                WHEN date_sub(monthdate, interval 8 MONTH) >= CAST('2000-1-1' as DATE) THEN CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_sub(monthdate, interval 8 MONTH)) as STRING), 1, 6) as INT64)
                ELSE 0
              END AS p8monthid,
              CASE
                WHEN date_sub(monthdate, interval 9 MONTH) >= CAST('2000-1-1' as DATE) THEN CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_sub(monthdate, interval 9 MONTH)) as STRING), 1, 6) as INT64)
                ELSE 0
              END AS p9monthid,
              CASE
                WHEN date_sub(monthdate, interval 10 MONTH) >= CAST('2000-1-1' as DATE) THEN CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_sub(monthdate, interval 10 MONTH)) as STRING), 1, 6) as INT64)
                ELSE 0
              END AS p10monthid,
              CASE
                WHEN date_sub(monthdate, interval 11 MONTH) >= CAST('2000-1-1' as DATE) THEN CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_sub(monthdate, interval 11 MONTH)) as STRING), 1, 6) as INT64)
                ELSE 0
              END AS p11monthid,
              CASE
                WHEN date_sub(monthdate, interval 12 MONTH) >= CAST('2000-1-1' as DATE) THEN CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_sub(monthdate, interval 12 MONTH)) as STRING), 1, 6) as INT64)
                ELSE 0
              END AS p12monthid,
              CASE
                WHEN date_sub(monthdate, interval 12 MONTH) >= CAST('2000-1-1' as DATE) THEN CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_sub(monthdate, interval 12 MONTH)) as STRING), 1, 6) as INT64)
                ELSE 0
              END AS ly1monthid,
              q.p1quarterid,
              q.p2quarterid,
              q.p3quarterid,
              q.p4quarterid,
              q.ly1quarterid,
              -- Quarter Time Intelligence
              q.p1yearid,
              q.p2yearid,
              q.p3yearid,
              q.p4yearid,
              q.p5yearid,
              q.p6yearid,
              q.p7yearid,
              -- Year Time Intelligence
              current_datetime() AS lastmodified
            --SELECT *
            FROM
              EDW_TRIPS_SUPPORT.Dim_Month AS main_table
              INNER JOIN EDW_TRIPS.Dim_Quarter AS q ON main_table.cal_quarterid = q.quarterid
      ;

      -- Log
      SET log_message = 'Loaded EDW_TRIPS.Dim_Month with Month level + EDW_TRIP_dbo.Dim_Quarter';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));

      --Tableswap not required , using create or replace
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_Month_NEW', 'EDW_TRIPS.Dim_Month');
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Dim_Month' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_Month
        ORDER BY
          2 DESC
          LIMIT 100
        ;
      END IF;

		--=============================================================================================================
		-- Load dbo.Dim_Week		->	 Week + Month + Quarter + Year levels
		--=============================================================================================================
      -- DROP TABLE IF EXISTS EDW_TRIPS.Dim_Week_NEW;
      CREATE TEMPORARY TABLE _SESSION.cte1 AS
       (
            SELECT DISTINCT
                CAST(concat(extract(Year from dim_day.daydate), right(concat('0', extract(week from dim_day.daydate)), 2)) as INT64) + CASE WHEN EXTRACT(DAYOFWEEK FROM DATE(CONCAT(EXTRACT(YEAR FROM dim_day.daydate), '-01-01'))) <> 1 THEN 1 ELSE 0 END AS weekid,
                date_add(dim_day.daydate, interval 1 - extract(DAYOFWEEK from dim_day.daydate) DAY) AS weekbegindate,
                date_add(dim_day.daydate, interval 7 - extract(DAYOFWEEK from dim_day.daydate) DAY) AS weekenddate,
                extract(week from dim_day.daydate) + CASE WHEN EXTRACT(DAYOFWEEK FROM DATE(CONCAT(EXTRACT(YEAR FROM dim_day.daydate), '-01-01'))) <> 1 THEN 1 ELSE 0 END AS weekofyear,
                dim_day.cal_monthid AS monthid,
                dim_day.cal_yearid AS yearid
              FROM
                EDW_TRIPS_SUPPORT.Dim_Day
              WHERE dim_day.dayid <> 19000101
          );
           CREATE TEMPORARY TABLE _SESSION.cte2 AS (
            SELECT
                cte1.weekid,
                cte1.weekofyear,
                CASE
                  WHEN extract(year from cte1.weekbegindate) < cte1.yearid -- Prev year
                    THEN CAST(concat(CAST(cte1.yearid as STRING), '-01-01') as DATE)
                    ELSE cte1.weekbegindate
                END AS weekbegindate,
                CASE
                  WHEN extract(year from cte1.weekenddate) > cte1.yearid -- Prev year 
                    THEN CAST(concat(CAST(cte1.yearid as STRING), '-12-31') as DATE)
                    ELSE cte1.weekenddate
                END AS weekenddate,
                cte1.monthid,
                row_number() OVER (PARTITION BY cte1.weekid ORDER BY cte1.monthid) AS rownum
              FROM
                cte1
          );
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_Week cluster by WeekID AS
          SELECT
              --:: Week Level
              cte2.weekid,
              cte2.weekbegindate,
              cte2.weekenddate,
              concat(substr(CAST(FORMAT_DATE('%m/%d/%Y',cte2.weekbegindate) as STRING), 1, 10), ' - ', substr(CAST(FORMAT_DATE('%m/%d/%Y',cte2.weekenddate) as STRING), 1, 10)) AS weekdesc,
              cte2.weekofyear,
              --:: Higher Levels. Important note: This is informational only. Week is not part of a natural hierarchy to higher levels
              m.monthid,
              m.monthbegindate,
              m.monthenddate,
              m.yearmonthdesc,
              m.monthyeardesc,
              m.monthdesc,
              m.monthofyear,
              m.monthduration,
              m.quarterid,
              m.quarterbegindate,
              m.quarterenddate,
              m.yearquarterdesc,
              m.quarteryeardesc,
              m.quarterdesc,
              m.quarterduration,
              m.yearid,
              m.yearbegindate,
              m.yearduration,
              --:: All Time Intelligence attributes neatly packed at the end of the table. Primary level attribute columns come first for each level followed by these attributes. 
              lag(CAST(concat(CAST(yearid as STRING), right(concat('0', CAST(cte2.weekofyear as STRING)), 2)) as INT64), 1, 0) OVER (ORDER BY cte2.weekid) AS p1weekid,
              lag(CAST(concat(CAST(yearid as STRING), right(concat('0', CAST(cte2.weekofyear as STRING)), 2)) as INT64), 2, 0) OVER (ORDER BY cte2.weekid) AS p2weekid,
              lag(CAST(concat(CAST(yearid as STRING), right(concat('0', CAST(cte2.weekofyear as STRING)), 2)) as INT64), 3, 0) OVER (ORDER BY cte2.weekid) AS p3weekid,
              lag(CAST(concat(CAST(yearid as STRING), right(concat('0', CAST(cte2.weekofyear as STRING)), 2)) as INT64), 4, 0) OVER (ORDER BY cte2.weekid) AS p4weekid,
              --!Note! Week is NOT part of a natural hierarchy to higher levels. Intentionally excluded other level Time Intelligence attributes and left them for future addition.
              current_datetime() AS lastmodified
            FROM
              cte2
              INNER JOIN EDW_TRIPS.Dim_Month AS m ON cte2.monthid = m.monthid
            WHERE cte2.rownum = 1
          UNION ALL
          SELECT
              190001 AS weekid,
              '1900-01-01' AS weekbegindate,
              '1900-01-06' AS weekenddate,
              '01/01/1900 - 01/06/1900' AS weekdesc,
              1 AS weekofyear,
              dim_month.monthid,
              dim_month.monthbegindate,
              dim_month.monthenddate,
              dim_month.yearmonthdesc,
              dim_month.monthyeardesc,
              dim_month.monthdesc,
              dim_month.monthofyear,
              dim_month.monthduration,
              dim_month.quarterid,
              dim_month.quarterbegindate,
              dim_month.quarterenddate,
              dim_month.yearquarterdesc,
              dim_month.quarteryeardesc,
              dim_month.quarterdesc,
              dim_month.quarterduration,
              dim_month.yearid,
              dim_month.yearbegindate,
              dim_month.yearduration,
              0 AS p1weekid,
              0 AS p2weekid,
              0 AS p3weekid,
              0 AS p4weekid,
              dim_month.lastmodified
            FROM
              EDW_TRIPS.Dim_Month
            WHERE dim_month.monthid = 190001
      ;

      -- Log
      SET log_message = 'Loaded EDW_TRIPS.Dim_Week with Week level + EDW_TRIPS.Dim_Month';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));

      --Tableswap not required , using create or replace
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_Week_NEW', 'EDW_TRIPS.Dim_Week');
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Dim_Week' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_Week
        ORDER BY
          2 DESC
          LIMIT 100
        ;
      END IF;
      
		--=============================================================================================================
		-- Load dbo.Dim_Day		->	 Day + Week + Month + Quarter + Year levels
		--=============================================================================================================

      -- DROP TABLE IF EXISTS EDW_TRIPS.Dim_Day_NEW;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_Day cluster by DayID
        AS
          SELECT
              --:: Day Level
              coalesce(main_table.dayid, -1) AS dayid,
              CAST(coalesce(main_table.daydate, '1900-01-01') as DATE) AS daydate,
              concat(CAST(FORMAT_DATE("%b %d, %Y",daydate) as STRING), ' (', left(FORMAT_DATE('%A', daydate), 3), ')') AS daydesc,
              CAST(FORMAT_DATE("%A", main_table.daydate) as STRING) AS dayname,
              extract(DAY from CAST(main_table.daydate as DATE)) AS dayofmonth,
              extract(dayofyear from main_table.daydate) AS dayofyear,
              CAST(main_table.isweekday as INT64) AS isweekday,
              CAST(main_table.isweekend as INT64) AS isweekend,
              CASE
                WHEN dim_date.business_day = 'Yes' THEN 1
                ELSE 0
              END AS isbusinessday,
              CASE
                WHEN dim_date.holiday = 'Yes'
                 AND main_table.dayid <> 19000101 THEN 1
                ELSE 0
              END AS isholiday,
              CAST(CASE
                WHEN main_table.dayid <> 19000101 THEN dim_date.holiday_name
              END as STRING) AS holidayname,
              --:: Week Level
              w.weekid,
              w.weekbegindate,
              w.weekenddate,
              w.weekdesc,
              w.weekofyear,
              --:: Month + Quarter + Year Levels
              m.monthid,
              m.monthbegindate,
              m.monthenddate,
              m.yearmonthdesc,
              m.monthyeardesc,
              m.monthdesc,
              m.monthofyear,
              m.monthduration,
              m.quarterid,
              m.quarterbegindate,
              m.quarterenddate,
              m.yearquarterdesc,
              m.quarteryeardesc,
              m.quarterdesc,
              m.quarterduration,
              m.yearid,
              m.yearbegindate,
              m.yearduration,

              --:: All Time Intelligence attributes neatly packed at the end of the table. Primary level attribute columns come first for each level followed by these attributes. 
					    --:: Day Intelligence
              CAST(main_table.prevdayid as INT64) AS p1dayid,
              CAST(substr(CAST(FORMAT_DATE("%Y%m%d", date_sub(daydate, interval 2 DAY)) as STRING), 1, 8) as INT64) AS p2dayid,
              CAST(substr(CAST(FORMAT_DATE("%Y%m%d", date_sub(daydate, interval 3 DAY)) as STRING), 1, 8) as INT64) AS p3dayid,
              CAST(substr(CAST(FORMAT_DATE("%Y%m%d", date_sub(daydate, interval 3 DAY)) as STRING), 1, 8) as INT64) AS p4dayid,
              CAST(substr(CAST(FORMAT_DATE("%Y%m%d", date_sub(daydate, interval 3 DAY)) as STRING), 1, 8) as INT64) AS p5dayid,
              CAST(substr(CAST(FORMAT_DATE("%Y%m%d", date_sub(daydate, interval 3 DAY)) as STRING), 1, 8) as INT64) AS p6dayid,
              CAST(substr(CAST(FORMAT_DATE("%Y%m%d", date_sub(daydate, interval 3 DAY)) as STRING), 1, 8) as INT64) AS p7dayid,
              --:: Week Intelligence
              w.p1weekid,
              w.p2weekid,
              w.p3weekid,
              w.p4weekid,
              --:: Month + Quarter + Year Intelligence
              m.p1monthid,
              m.p2monthid,
              m.p3monthid,
              m.p4monthid,
              m.p5monthid,
              m.p6monthid,
              m.p7monthid,
              m.p8monthid,
              m.p9monthid,
              m.p10monthid,
              m.p11monthid,
              m.p12monthid,
              m.p1quarterid,
              m.p2quarterid,
              m.p3quarterid,
              m.p4quarterid,
              m.ly1quarterid,
              m.p1yearid,
              m.p2yearid,
              m.p3yearid,
              m.p4yearid,
              m.p5yearid,
              m.p6yearid,
              m.p7yearid,
              current_datetime() AS lastmodified
            --SELECT *
            FROM
              EDW_TRIPS_SUPPORT.Dim_Day AS main_table
              LEFT OUTER JOIN EDW_TRIPS.Dim_Week AS w ON w.weekid = CAST(concat(left(CAST(main_table.cal_weekid as STRING), 4), right(CAST(main_table.cal_weekid as STRING), 2)) as INT64) -- Changed WeekID from YYYYWWW to YYYYWW since there are only 52 weeks in a year. Example: 2020045 to 202045
              INNER JOIN EDW_TRIPS.Dim_Month AS m ON main_table.cal_monthid = m.monthid
              LEFT OUTER JOIN EDW_TRIPS_SUPPORT.Dim_Date ON dim_date.date = main_table.daydate
      ;

      -- Log
      SET log_message = 'Loaded EDW_TRIPS.Dim_Day with Day level + EDW_TRPS_dbo.Dim_Week + EDW_TRIPS.Dim_Month';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));

      --Tableswap not required , using create or replace
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_Day_NEW', 'EDW_TRIPS.Dim_Day');
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Dim_Day' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_Day
       ORDER BY
          2 DESC
      LIMIT 100
        ;
      END IF;
      								 
		--=============================================================================================================
		-- Load dbo.Dim_Time
		--=============================================================================================================
		
      -- DROP TABLE IF EXISTS EDW_TRIPS.Dim_Time_NEW;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_Time cluster by TimeID
        AS
          SELECT
              coalesce(CAST(dim_time.time_id as INT64), 0) AS timeid,
              coalesce(CAST(dim_time.hour as STRING), '') AS hour,
              coalesce(CAST(dim_time.minute as STRING), '') AS minute,
              coalesce(CAST(dim_time.second as STRING), '') AS second,
              coalesce(CAST(dim_time.`12_hour` as STRING), '') AS `12_hour`,
              coalesce(CAST(dim_time.am_pm as STRING), '') AS am_pm,
              coalesce(CAST(dim_time.`5_minute` as STRING), '') AS `5_minute`,
              coalesce(CAST(dim_time.`10_minute` as STRING), '') AS `10_minute`,
              coalesce(CAST(dim_time.`15_minute` as STRING), '') AS `15_minute`,
              coalesce(CAST(dim_time.`30_minute` as STRING), '') AS `30_minute`,
              current_datetime() AS lastmodified
              -- SELECT *
            FROM
              EDW_TRIPS_SUPPORT.Dim_Time
      ;
      -- Log
      SET log_message = 'Loaded EDW_TRIPS.Dim_Time';
      CALL EDW_TRIPS_SUPPORT.Row_Count(row_count);
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, '-1', row_count, 'I');

      --Tableswap not required , using create or replace
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_Time_NEW', 'EDW_TRIPS.Dim_Time');
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Dim_Time' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_Time
        ORDER BY
          2 DESC
        LIMIT 100
        ;
      END IF;
      
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load of Date/Time Hierarchy dim tables', 'I', CAST(NULL as INT64), CAST(NULL as STRING));

    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = error_message;  -- Rethrow the error all the way to Data Manager
      END;
    END;
    /*

--:: Testing Zone

EXEC dbo.Dim_Day_Hierarchy_Full_Load

SELECT * FROM Utility.ProcessLog 
WHERE LogDate > '2020-07-30' AND LogSource IN ('dbo.Dim_Time','dbo.Dim_Day','dbo.Dim_Week','dbo.Dim_Month','dbo.Dim_Quarter','dbo.Dim_Year') 
ORDER BY LogDate DESC

--:: Quick check
SELECT * FROM Ref.Dim_Year ORDER BY 1
SELECT * FROM dbo.Dim_Year ORDER BY 1

--:: Quick check
SELECT * FROM Ref.Dim_Quarter ORDER BY 1
SELECT * FROM dbo.Dim_Quarter ORDER BY 1

--:: Quick check
SELECT * FROM Ref.Dim_Month ORDER BY 1
SELECT * FROM dbo.Dim_Month ORDER BY 1

--:: Quick check
SELECT * FROM Ref.Dim_Week ORDER BY 1
SELECT * FROM dbo.Dim_Week ORDER BY 1

--:: Quick check
SELECT * FROM Ref.Dim_Day ORDER BY 1
SELECT * FROM dbo.Dim_Day ORDER BY 1

--:: Quick check
SELECT * FROM Ref.Dim_Time ORDER BY 1
SELECT * FROM dbo.Dim_Time ORDER BY 1

--:: Data Profiling

SELECT MIN(DAYID) MIN_DAYID, MAX(DAYID) MAX_DAYID, COUNT(1) ROW_CNT FROM Ref.Dim_Day WHERE DAYID <>19000101  ORDER BY 1
SELECT MIN(Cal_MonthID) MIN_Cal_MonthID, MAX(Cal_MonthID) MAX_Cal_MonthID, COUNT(1) ROW_CNT FROM Ref.Dim_Month WHERE Cal_MonthID<> 190001  ORDER BY 1
SELECT MIN(Cal_QuarterID) MIN_Cal_QuarterID, MAX(Cal_QuarterID) MAX_Cal_QuarterID, COUNT(1) ROW_CNT FROM Ref.Dim_Quarter WHERE Cal_QuarterID <> 19001 ORDER BY 1
SELECT MIN(Cal_YearID) MIN_Cal_YearID, MAX(Cal_YearID) MAX_Cal_YearID, COUNT(1) ROW_CNT FROM Ref.Dim_Year WHERE Cal_YearID <> 1900 ORDER BY 1

SELECT IsWorkDay, *
FROM Ref.Dim_Day AS main_table
LEFT JOIN Ref.Dim_Date AS Dim_Date ON Dim_Date.DATE = DayDate 
WHERE Dim_Date.BUSINESS_DAY = Dim_Date.HOLIDAY AND  Dim_Date.HOLIDAY = 'No'
--WHERE IsWorkDay = CASE WHEN Dim_Date.BUSINESS_DAY = 'Yes' THEN 1 ELSE 0 END

*/


  END;