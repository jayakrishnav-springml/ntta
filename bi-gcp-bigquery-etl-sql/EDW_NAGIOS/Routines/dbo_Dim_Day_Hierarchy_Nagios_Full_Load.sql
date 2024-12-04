CREATE OR REPLACE PROCEDURE `EDW_NAGIOS.Dim_Day_Hierarchy_Nagios_Full_Load`()
BEGIN
/*
###################################################################################################################
Purpose: Loads all Date/Time dimension hierarchy tables at the beginning of each year.

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
CHG0039845	Andy and Shankar	2020-06-04	New!
-------------------------------------------------------------------------------------------------------------------
Run script:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_Day_Hierarchy_Nagios_Full_Load

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

    DECLARE log_source STRING DEFAULT 'EDW_NAGIOS.Dim_Day_Hierarchy_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0; -- Testing
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load of Hierarchy dim tables', '-1', CAST(NULL as INT64), 'I');
      
      --=============================================================================================================
      -- Load dbo.Dim_Year		->	Year Level
      --=============================================================================================================

      -- DROP TABLE IF EXISTS EDW_NAGIOS.Dim_Year_NEW;
      CREATE OR REPLACE TABLE EDW_NAGIOS.Dim_Year CLUSTER BY YearID
        AS
          SELECT
              *
            FROM
              EDW_TRIPS.Dim_Year
      ;

      -- Log 
      SET log_message = 'Loaded EDW_NAGIOS.Dim_Year with Year level';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));

      -- TableSwap is Not Required using  Create or Replace Table
      -- CALL EDW_NAGIOS_SUPPORT.TableSwap('EDW_NAGIOS.Dim_Year_NEW', 'EDW_NAGIOS.Dim_Year');

      IF trace_flag = 1 THEN
        SELECT
            'EDW_NAGIOS.Dim_Year' AS tablename,
            *
          FROM
            EDW_NAGIOS.Dim_Year
        ORDER BY
          2 DESC
          LIMIT 100
        ;
      END IF;
      
      --=============================================================================================================
      -- Load dbo.Dim_Quarter		->	 Quarter + Year levels
      --=============================================================================================================

      -- DROP TABLE IF EXISTS EDW_NAGIOS.Dim_Quarter_NEW;
      CREATE OR REPLACE TABLE EDW_NAGIOS.Dim_Quarter CLUSTER BY QuarterID
        AS
          SELECT
              *
            FROM
              EDW_TRIPS.Dim_Quarter
      ;

      -- Log 
      SET log_message = 'Loaded EDW_NAGIOS.Dim_Quarter with Quarter level';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      
      -- TableSwap is Not Required using  Create or Replace Table
      -- CALL EDW_NAGIOS_SUPPORT.TableSwap('EDW_NAGIOS.Dim_Quarter_NEW', 'EDW_NAGIOS.Dim_Quarter');
      IF trace_flag = 1 THEN
        SELECT
            'EDW_NAGIOS.Dim_Quarter' AS tablename,
            *
          FROM
            EDW_NAGIOS.Dim_Quarter
        ORDER BY
          2 DESC LIMIT 100
        ;
      END IF;

      --=============================================================================================================
      -- Load dbo.Dim_Month		->	 Month + Quarter + Year levels
      --=============================================================================================================

      -- DROP TABLE IF EXISTS EDW_NAGIOS.Dim_Month_NEW;
      CREATE OR REPLACE TABLE EDW_NAGIOS.Dim_Month CLUSTER BY MonthID
        AS
          SELECT
              *
            FROM
              EDW_TRIPS.Dim_Month
      ;

      -- Log 
      SET log_message = 'Loaded EDW_NAGIOS.Dim_Month with Month level';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));

      -- TableSwap is Not Required using  Create or Replace Table
      -- CALL EDW_NAGIOS_SUPPORT.TableSwap('EDW_NAGIOS.Dim_Month_NEW', 'EDW_NAGIOS.Dim_Month');
      IF trace_flag = 1 THEN
        SELECT
            'EDW_NAGIOS.Dim_Month' AS tablename,
            *
          FROM
            EDW_NAGIOS.Dim_Month
        ORDER BY
          2 DESC LIMIT 100
        ;
      END IF;
      
      --=============================================================================================================
      -- Load dbo.Dim_Week		->	 Week + Month + Quarter + Year levels
      --=============================================================================================================

      -- DROP TABLE IF EXISTS EDW_NAGIOS.Dim_Week_NEW;
      CREATE OR REPLACE TABLE EDW_NAGIOS.Dim_Week CLUSTER BY WeekID
        AS
          SELECT
              *
            FROM
              EDW_TRIPS.Dim_Week
      ;

      -- Log 
      SET log_message = 'Loaded EDW_NAGIOS.Dim_Week with Week level';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));

      -- TableSwap is Not Required using  Create or Replace Table
      -- CALL EDW_NAGIOS_SUPPORT.TableSwap('EDW_NAGIOS.Dim_Week_NEW', 'EDW_NAGIOS.Dim_Week');
      IF trace_flag = 1 THEN
        SELECT
            'EDW_NAGIOS.Dim_Week' AS tablename,
            *
          FROM
            EDW_NAGIOS.Dim_Week
        ORDER BY
          2 DESC LIMIT 100
        ;
      END IF;
      
      --=============================================================================================================
      -- Load dbo.Dim_Day		->	 Day + Week + Month + Quarter + Year levels
      --=============================================================================================================

      -- DROP TABLE IF EXISTS EDW_NAGIOS.Dim_Day_NEW;
      CREATE OR REPLACE TABLE EDW_NAGIOS.Dim_Day CLUSTER BY DayID
        AS
          SELECT
              *
            FROM
              EDW_TRIPS.Dim_Day
      ;

      -- Log 
      SET log_message = 'Loaded EDW_NAGIOS.Dim_Day with Day level';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      -- TableSwap is Not Required using  Create or Replace Table
      -- CALL EDW_NAGIOS_SUPPORT.TableSwap('EDW_NAGIOS.Dim_Day_NEW', 'EDW_NAGIOS.Dim_Day');
      IF trace_flag = 1 THEN
        SELECT
            'EDW_NAGIOS.Dim_Day' AS tablename,
            *
          FROM
            EDW_NAGIOS.Dim_Day
        ORDER BY
          2 DESC LIMIT 100
        ;
      END IF;
      
		--=============================================================================================================
		-- Load dbo.Dim_Time
		--=============================================================================================================

      -- DROP TABLE IF EXISTS EDW_NAGIOS.Dim_Time_NEW;
      CREATE OR REPLACE TABLE EDW_NAGIOS.Dim_Time CLUSTER BY TimeID
        AS
          SELECT
              *
            FROM
              EDW_TRIPS.Dim_Time
      ;

      -- Log 
      SET log_message = 'Loaded EDW_NAGIOS.Dim_Time with Time level';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      -- TableSwap is Not Required using  Create or Replace Table
      -- CALL EDW_NAGIOS_SUPPORT.TableSwap('EDW_NAGIOS.Dim_Time_NEW', 'EDW_NAGIOS.Dim_Time');
      IF trace_flag = 1 THEN
        SELECT
            'EDW_NAGIOS.Dim_Time' AS tablename,
            *
          FROM
            EDW_NAGIOS.Dim_Time
        ORDER BY
          2 DESC
          LIMIT 100
        ;
      END IF;
      -- Show results
      IF trace_flag = 1 THEN
        SELECT
            'EDW_NAGIOS.Dim_Time' AS tablename,
            *
          FROM
            EDW_NAGIOS.Dim_Time
        ORDER BY
          2 DESC LIMIT 100
        ;
      END IF;
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load of Date/Time Hierarchy dim tables', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
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
SELECT * FROM EDW_TRIPS.dbo.Dim_Year ORDER BY 1
SELECT * FROM dbo.Dim_Year ORDER BY 1

--:: Quick check
SELECT * FROM EDW_TRIPS.dbo.Dim_Quarter ORDER BY 1
SELECT * FROM dbo.Dim_Quarter ORDER BY 1

--:: Quick check
SELECT * FROM EDW_TRIPS.dbo.Dim_Month ORDER BY 1
SELECT * FROM dbo.Dim_Month ORDER BY 1

--:: Quick check
SELECT * FROM EDW_TRIPS.dbo.Dim_Week ORDER BY 1
SELECT * FROM dbo.Dim_Week ORDER BY 1

--:: Quick check
SELECT * FROM EDW_TRIPS.dbo.Dim_Day ORDER BY 1
SELECT * FROM dbo.Dim_Day ORDER BY 1

--:: Quick check
SELECT * FROM EDW_TRIPS.dbo.Dim_Time ORDER BY 1
SELECT * FROM dbo.Dim_Time ORDER BY 1
*/

  END;