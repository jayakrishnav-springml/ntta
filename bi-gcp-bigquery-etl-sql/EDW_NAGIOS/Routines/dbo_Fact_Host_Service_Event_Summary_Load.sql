CREATE OR REPLACE PROCEDURE `EDW_NAGIOS.Fact_Host_Service_Event_Summary_Load`(isfullload INT64)
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.dbo.Fact_Host_Service_Event_Summary_Load

The following 5 procs GO TOGETHER IN SEQUENCE, as if it's ALL IN ONE proc:
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
EXEC dbo.Fact_Host_Service_Event_Summary_Load 0
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE 'dbo.Fact_Host_Service_Event_Summary%' ORDER BY 1 DESC
SELECT 'LoadProcessControl After' SRC, * FROM Utility.LoadProcessControl

SELECT TOP 1000 * FROM dbo.Fact_Host_Service_Event_Summary ORDER BY 1 DESC
###################################################################################################################
*/
BEGIN
    -- DEBUG
		-- DECLARE @IsFullLoad BIT = 0
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 1;
    DECLARE log_source STRING DEFAULT 'EDW_NAGIOS.Fact_Host_Service_Event_Summary_Load';
    DECLARE log_start_date DATETIME;
    DECLARE last_updated_date DATETIME;
    DECLARE last_updated_dayid INT64;
    DECLARE sql STRING;
    BEGIN
      DECLARE createtablewith STRING;
      SET log_start_date = current_datetime('America/Chicago');
      IF (SELECT count(1) FROM `EDW_NAGIOS.INFORMATION_SCHEMA.TABLES` WHERE LOWER(table_name) = lower("Fact_Host_Service_Event_Summary")) = 0 THEN
        SET isfullload = 1;
      END IF;
		--======================================================================
		--:: dbo.Fact_Host_Service_Event_Summary
		--======================================================================
      IF isfullload = 1 THEN
        SET log_message = 'Started full load of EDW_NAGIOS.Fact_Host_Service_Event_Summary_Load';
        IF trace_flag = 1 THEN
          SELECT log_message;
        END IF;
        CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
        CREATE OR REPLACE TABLE EDW_NAGIOS.Fact_Host_Service_Event_Summary_New
        CLUSTER BY event_summary_id
          AS
            SELECT
                coalesce(row_number() OVER (ORDER BY fact_host_service_event.event_day_id, fact_host_service_event.nagios_object_id, fact_host_service_event.host_service_state_id), 0) AS event_summary_id,
                fact_host_service_event.event_day_id,
                fact_host_service_event.nagios_object_id,
                fact_host_service_event.host_service_state_id,
                coalesce(count(1), 0) AS event_count,
                max(fact_host_service_event.lnd_updatedate) AS lnd_updatedate,
                current_datetime() AS edw_updatedate
              FROM
                EDW_NAGIOS.fact_host_service_event
              GROUP BY 
                event_day_id,
                nagios_object_id,
                host_service_state_id
        ;
      ELSE
        BEGIN
          DECLARE max_id INT64;
          IF trace_flag = 1 THEN
            Select 'Calling: EDW_NAGIOS.Get_UpdatedDate for "Nagios Host_Service_Event Dim & Fact Tables"';
          END IF;
          CALL EDW_NAGIOS_SUPPORT.Get_UpdatedDate('Nagios Host_Service_Event Dim & Fact Tables', last_updated_date);
          SET last_updated_dayid= cast(cast(DATE_ADD(coalesce(last_updated_date ,'2021-01-11'), INTERVAL -1 DAY)  as string format 'yyyymmdd')as int64);
          SET max_id =(SELECT
              max(fact_host_service_event_summary.event_summary_id) AS max_id
            FROM
              EDW_NAGIOS.Fact_Host_Service_Event_Summary
            WHERE fact_host_service_event_summary.event_day_id < last_updated_dayid)
          ;
          SET log_message = concat('Started incremental load of EDW_NAGIOS.Fact_Host_Service_Event_Summary starting from ', substr(CAST(last_updated_dayid as STRING), 1, 30), '. Max_ID: ', substr(CAST(coalesce(max_id, 0) as STRING), 1, 30));
          IF trace_flag = 1 THEN
            select log_message;
          END IF;
          CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
          
          CREATE OR REPLACE TABLE EDW_NAGIOS.Fact_Host_Service_Event_Summary_New
          CLUSTER BY event_summary_id
            AS
              SELECT
                  fact_host_service_event_summary.event_summary_id,
                  fact_host_service_event_summary.event_day_id,
                  fact_host_service_event_summary.nagios_object_id,
                  fact_host_service_event_summary.host_service_state_id,
                  fact_host_service_event_summary.event_count,
                  fact_host_service_event_summary.lnd_updatedate,
                  fact_host_service_event_summary.edw_updatedate
                FROM
                  EDW_NAGIOS.fact_host_service_event_summary
                WHERE fact_host_service_event_summary.event_day_id < last_updated_dayid
              UNION ALL
              SELECT
                  coalesce(coalesce(max_id, 0) + row_number() OVER (ORDER BY fact_host_service_event.event_day_id, fact_host_service_event.nagios_object_id, fact_host_service_event.host_service_state_id), 0) AS event_summary_id,
                  fact_host_service_event.event_day_id,
                  fact_host_service_event.nagios_object_id,
                  fact_host_service_event.host_service_state_id,
                  coalesce(count(1), 0) AS event_count,
                  max(fact_host_service_event.lnd_updatedate) AS lnd_updatedate,
                  current_datetime() AS edw_updatedate
                FROM
                  EDW_NAGIOS.fact_host_service_event
                WHERE fact_host_service_event.event_day_id >= last_updated_dayid
                GROUP BY 
                  event_day_id,
                  nagios_object_id,
                  host_service_state_id;
        END;
      END IF;
      SET log_message = 'Loaded EDW_NAGIOS.Fact_Host_Service_Event_Summary_NEW';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, sql);
      --Table Swap
      --CALL utility.tableswap('dbo.Fact_Host_Service_Event_Summary_NEW', 'dbo.Fact_Host_Service_Event_Summary');
      CREATE OR REPLACE TABLE EDW_NAGIOS.Fact_Host_Service_Event_Summary CLUSTER BY event_summary_id AS SELECT * FROM EDW_NAGIOS.Fact_Host_Service_Event_Summary_NEW;
      IF trace_flag = 1 THEN
        SELECT log_message;
      END IF;
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, 'Created Statistics and completed Table Swap', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      SET log_message = CASE
        WHEN isfullload = 1 THEN 'Completed full load'
        ELSE 'Completed incremental load'
      END;
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        SET log_message = concat('*** Error in EDW_NAGIOS.Fact_Host_Service_Event_Summary_Load: ', error_message);
        CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = error_message;-- Rethrow the error!
      END;
    END;
  
/*
SELECT 'LoadProcessControl Before' SRC, * FROM Utility.LoadProcessControl
EXEC dbo.Fact_Host_Service_Event_Summary_Load 0
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE 'dbo.Fact_Host_Service_Event_Summary%' ORDER BY 1 DESC
SELECT 'LoadProcessControl After' SRC, * FROM Utility.LoadProcessControl

SELECT TOP 1000 * FROM dbo.Fact_Host_Service_Event_Summary ORDER BY 1 DESC

--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
SELECT Event_Day_ID, COUNT_BIG(1) RC 
	FROM dbo.Fact_Host_Service_Event_Summary
GROUP BY Event_Day_ID
ORDER BY Event_Day_ID DESC

SELECT COUNT_BIG(1) RC, MAX(Event_Summary_ID) -- 3302764
	FROM dbo.Fact_Host_Service_Event_Summary
WHERE Event_Day_ID < 20211101



*/
  END;