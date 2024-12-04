CREATE OR REPLACE PROCEDURE `EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary_Load`(isfullload INT64)
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.dbo.Fact_Host_Service_Event_Metric_Summary_Load

The following 5 procs GO TOGETHER IN SEQUENCE, as if it's all in one proc:
1. dbo.Dim_Host_Service_Metric_Load
2. dbo.Fact_Host_Service_Event_Load
3. dbo.Fact_Host_Service_Event_Metric_Load
4. dbo.Fact_Host_Service_Event_Summary_Load
5. dbo.Fact_Host_Service_Event_Metric_Summary_Load
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0039980  Shankar	    2021-11-15	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
SELECT 'LoadProcessControl Before' SRC, * FROM Utility.LoadProcessControl
EXEC dbo.Fact_Host_Service_Event_Metric_Summary_Load 1
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE 'dbo.Fact_Host_Service_Event_Metric_Summary_Load%' ORDER BY 1 DESC
SELECT 'LoadProcessControl After' SRC, * FROM Utility.LoadProcessControl

SELECT TOP 1000 * FROM dbo.Fact_Host_Service_Event_Metric_Summary ORDER BY 1 DESC
###################################################################################################################
*/

    -- DEBUG
    -- DECLARE @IsFullLoad BIT = 0

    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 1; -- Testing
    DECLARE log_source STRING DEFAULT 'EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary_Load';
    DECLARE log_start_date DATETIME;
    DECLARE last_updated_date DATETIME;
    DECLARE last_updated_dayid INT64;
    DECLARE sql STRING;
    BEGIN		

      DECLARE createtablewith STRING;
      SET log_start_date = current_datetime('America/Chicago');
      IF (SELECT COUNT(1) FROM EDW_NAGIOS.INFORMATION_SCHEMA.TABLES WHERE LOWER(table_name)=LOWER('Fact_Host_Service_Event_Metric_Summary')) =0 THEN
        SET isfullload = 1;
      END IF;

      --======================================================================
      --:: dbo.Fact_Host_Service_Event_Metric_Summary
      --======================================================================
      IF isfullload = 1 THEN
        SET log_message = 'Started full load of EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary';
        IF trace_flag = 1 THEN
          select log_message;
        END IF;
        CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
        --DROP TABLE IF EXISTS EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary_NEW;
        CREATE OR REPLACE TABLE EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary_NEW
          CLUSTER BY Event_Metric_Summary_ID
          AS
            SELECT
                coalesce(row_number() OVER (ORDER BY Fact_Host_Service_Event_Metric.event_day_id, Fact_Host_Service_Event_Metric.host_service_metric_id, Fact_Host_Service_Event_Metric.metric_state_id), 0) AS event_metric_summary_id,
                Fact_Host_Service_Event_Metric.event_day_id,
                Fact_Host_Service_Event_Metric.host_service_metric_id,
                Fact_Host_Service_Event_Metric.metric_state_id,
                substr(CAST(max(Fact_Host_Service_Event_Metric.metric_unit) as STRING), 1, 5) AS metric_unit,
                CAST(sum(Fact_Host_Service_Event_Metric.metric_value) as NUMERIC) AS total_metric_value,
                count(1) AS metric_value_count,
                CAST(max(Fact_Host_Service_Event_Metric.lnd_updatedate) AS DATETIME) AS lnd_updatedate,
                current_datetime() AS edw_updatedate
              FROM
                EDW_NAGIOS.Fact_Host_Service_Event_Metric
              GROUP BY event_day_id,
                       host_service_metric_id,
                       metric_state_id
        ;
      ELSE
        BEGIN
          DECLARE max_id INT64;
          IF trace_flag = 1 THEN
            select 'Calling: Utility.Get_UpdatedDate for "Nagios Host_Service_Event Dim & Fact Tables"';
          END IF;
          CALL EDW_NAGIOS_SUPPORT.Get_UpdatedDate('Nagios Host_Service_Event Dim & Fact Tables', last_updated_date);
          SET  last_updated_dayid = (SELECT
              CAST(substr(CAST(datetime_sub(coalesce(last_updated_date, SAFE_CAST('11/01/2021' AS DATETIME)), interval 1 DAY) as STRING FORMAT 'YYYYMMDD'), 1, 30) as INT64))
          ;
          SET max_id = (SELECT
              max(Fact_Host_Service_Event_Metric_Summary.event_metric_summary_id)
            FROM
              EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary
            WHERE Fact_Host_Service_Event_Metric_Summary.event_day_id < last_updated_dayid)
          ;
          SET log_message = concat('Started incremental load of EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary starting from ', substr(CAST(last_updated_dayid as STRING), 1, 30), '. @Max_ID: ', substr(CAST(coalesce(max_id, 0) as STRING), 1, 30));
          IF trace_flag = 1 THEN
            select log_message;
          END IF;
          CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
          --DROP TABLE IF EXISTS EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary_NEW;
          CREATE OR REPLACE TABLE EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary_NEW
            CLUSTER BY Event_Metric_Summary_ID
            AS
              SELECT
                  Fact_Host_Service_Event_Metric_Summary.event_metric_summary_id,
                  Fact_Host_Service_Event_Metric_Summary.event_day_id,
                  Fact_Host_Service_Event_Metric_Summary.host_service_metric_id,
                  Fact_Host_Service_Event_Metric_Summary.metric_state_id,
                  Fact_Host_Service_Event_Metric_Summary.metric_unit,
                  Fact_Host_Service_Event_Metric_Summary.total_metric_value,
                  Fact_Host_Service_Event_Metric_Summary.metric_value_count,
                  Fact_Host_Service_Event_Metric_Summary.lnd_updatedate,
                  Fact_Host_Service_Event_Metric_Summary.edw_updatedate
                FROM
                  EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary
                WHERE Fact_Host_Service_Event_Metric_Summary.event_day_id < last_updated_dayid
              UNION ALL
              SELECT
                  coalesce(coalesce(max_id, 0) + row_number() OVER (ORDER BY Fact_Host_Service_Event_Metric.event_day_id, Fact_Host_Service_Event_Metric.host_service_metric_id, Fact_Host_Service_Event_Metric.metric_state_id), 0) AS event_metric_summary_id,
                  Fact_Host_Service_Event_Metric.event_day_id,
                  Fact_Host_Service_Event_Metric.host_service_metric_id,
                  Fact_Host_Service_Event_Metric.metric_state_id,
                  substr(CAST(max(Fact_Host_Service_Event_Metric.metric_unit) as STRING), 1, 5) AS metric_unit,
                  CAST(sum(Fact_Host_Service_Event_Metric.metric_value) as NUMERIC) AS total_metric_value,
                  count(1) AS metric_value_count,
                  CAST(max(Fact_Host_Service_Event_Metric.lnd_updatedate) AS DATETIME) AS lnd_updatedate,
                  current_datetime() AS edw_updatedate
                FROM
                  EDW_NAGIOS.Fact_Host_Service_Event_Metric
                WHERE Fact_Host_Service_Event_Metric.event_day_id >= last_updated_dayid
                GROUP BY event_day_id,
                         host_service_metric_id,
                         metric_state_id
          ;
        END;
      END IF;
      SET log_message = 'Loaded EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary_NEW';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, sql);
      --TableSwap is Not Required, using  Create or Replace Table below
      -- Table swap!
      --CALL EDW_NAGIOS_SUPPORT.TableSwap('EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary_NEW', 'EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary');
      CREATE OR REPLACE TABLE EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary CLUSTER BY event_metric_summary_id AS SELECT * FROM EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary_NEW;
      IF trace_flag = 1 THEN
        select log_message;
      END IF;
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, 'completed Table Swap', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      --:: Advance the Last_Updated_Date for next run.
      IF isfullload = 0 THEN
        SET last_updated_date = CAST(NULL as DATETIME);
        CALL EDW_NAGIOS_SUPPORT.Set_UpdatedDate('Nagios Host_Service_Event Dim & Fact Tables', 'EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary', last_updated_date);
        SET log_message = concat('Advanced Last Update date for the next run as ', coalesce(substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_updated_date) as STRING), 1, 25), r'?'));
        CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      END IF;
      SET log_message = CASE
        WHEN isfullload = 1 THEN 'Completed full load'
        ELSE 'Completed incremental load'
      END;
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        SET log_message= concat('*** Error in EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary_Load: ', error_message);
        CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message,'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = error_message;  -- Rethrow the error!
      END;
    END;
/*
SELECT 'LoadProcessControl Before' SRC, * FROM Utility.LoadProcessControl
EXEC dbo.Fact_Host_Service_Event_Metric_Summary_Load 0
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE 'dbo.Fact_Host_Service_Event_Metric_Summary_Load%' ORDER BY 1 DESC
SELECT 'LoadProcessControl After' SRC, * FROM Utility.LoadProcessControl

SELECT TOP 1000 * FROM dbo.Fact_Host_Service_Event_Metric_Summary ORDER BY 1 DESC

--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
SELECT Event_Day_ID, MIN(Event_Metric_Summary_ID) Event_Metric_Summary_ID_From, MAX(Event_Metric_Summary_ID) Event_Metric_Summary_ID_To, COUNT_BIG(1) RC 
	FROM dbo.Fact_Host_Service_Event_Metric_Summary 
GROUP BY Event_Day_ID
ORDER BY Event_Day_ID DESC

*/

  END;