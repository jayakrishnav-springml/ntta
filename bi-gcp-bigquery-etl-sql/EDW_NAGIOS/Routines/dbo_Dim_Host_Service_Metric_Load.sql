CREATE OR REPLACE PROCEDURE `EDW_NAGIOS.Dim_Host_Service_Metric_Load`(isfullload INT64)
BEGIN
  /*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_Host_Service_Metric. This proc parses the metric data from Host_Event and Service_Event tables
for events after the last update date and does the the incremental load of Stage.Host_Service_Metric_Data which is
used in loading dbo.Dim_Host_Service_Metric, dbo.Fact_Host_Service_Event, dbo.Fact_Host_Service_Event_Metric tables

The following 3 procs go together in tight sequence, as if all in one proc:
1. dbo.Dim_Host_Service_Metric_Load
2. dbo.Fact_Host_Service_Event_Load
3. dbo.Fact_Host_Service_Event_Metric_Load
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0039845	Shankar		2021-03-26	New!
CHG0039980  Shankar	    2021-11-15  Refresh dim table with updated Lane Camera Mapping data
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_Host_Service_Metric_Load 0
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_Host_Service_Metric%' ORDER BY 1 DESC
SELECT * FROM dbo.Dim_Host_Service_Metric
SELECT * FROM Utility.LoadProcessControl

--:: Log
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_Host_Service_Metric%' ORDER BY 1 DESC
SELECT * FROM Utility.LoadProcessControl

--:: Input
SELECT TOP 1000 * FROM Stage.Host_Service_Event ORDER BY Host_Service_Event_ID DESC

--:: Parsed Output Metrics
SELECT TOP 1000 'Stage.Host_Service_Metric_Data1' TableName, * FROM Stage.Host_Service_Metric_Data1 ORDER BY Host_Service_Event_ID DESC
SELECT TOP 1000 'Stage.Host_Service_Metric_Data2' TableName, * FROM Stage.Host_Service_Metric_Data2	ORDER BY Host_Service_Event_ID DESC
SELECT TOP 1000 'Stage.Host_Service_Metric_Data3' TableName, * FROM Stage.Host_Service_Metric_Data3	ORDER BY Host_Service_Event_ID DESC
SELECT TOP 1000 'Stage.Host_Service_Metric_Data4' TableName, * FROM Stage.Host_Service_Metric_Data4	ORDER BY Host_Service_Event_ID DESC
SELECT TOP 1000 'Stage.Host_Service_Metric_Data5' TableName, * FROM Stage.Host_Service_Metric_Data5	ORDER BY Host_Service_Event_ID DESC
SELECT TOP 1000 'Stage.Host_Service_Metric_Data6' TableName, * FROM Stage.Host_Service_Metric_Data6	ORDER BY Host_Service_Event_ID DESC
SELECT TOP 1000 'Stage.Host_Service_Metric_Data ' TableName, * FROM Stage.Host_Service_Metric_Data 	WHERE Nagios_Object_ID = 143 ORDER BY Host_Service_Event_ID DESC

--:: Output
SELECT * FROM dbo.Dim_Host_Service_Metric ORDER BY LND_UpdateDate DESC

--:: Data volume statistics
SELECT MIN(status_update_time), MAX(status_update_time), COUNT_BIG(1) RC FROM   LND_NAGIOS.dbo.nagios_hoststatus_HIST
SELECT MIN(status_update_time), MAX(status_update_time), COUNT_BIG(1) RC FROM   LND_NAGIOS.dbo.nagios_servicestatus_HIST  
SELECT MIN(Event_Date), MAX(Event_Date), COUNT_BIG(1) RC FROM   LND_NAGIOS.dbo.Host_Event  
SELECT MIN(Event_Date), MAX(Event_Date), COUNT_BIG(1) RC FROM   LND_NAGIOS.dbo.Service_Event  
SELECT MIN(Event_Day_ID), MAX(Event_Day_ID), COUNT_big(1) RC FROM   dbo.Fact_Host_Service_Event  
SELECT MIN(Event_Day_ID), MAX(Event_Day_ID), COUNT_big(1) RC FROM   dbo.Fact_Host_Service_Event_Metric 

SELECT CONVERT(DATE,status_update_time), COUNT_BIG(1) RC FROM   LND_NAGIOS.dbo.nagios_hoststatus_HIST GROUP BY CONVERT(DATE,status_update_time) ORDER BY 1 desc
SELECT CONVERT(DATE,status_update_time), COUNT_BIG(1) RC FROM   LND_NAGIOS.dbo.nagios_servicestatus_HIST GROUP BY CONVERT(DATE,status_update_time)  ORDER BY 1 desc
SELECT CONVERT(DATE,Event_Date) Event_Date, COUNT_BIG(1) Host_Event FROM   LND_NAGIOS.dbo.Host_Event GROUP BY CONVERT(DATE,Event_Date) ORDER BY 1 DESC
SELECT CONVERT(DATE,Event_Date) Event_Date, COUNT_BIG(1) Service_Event FROM   LND_NAGIOS.dbo.Service_Event GROUP BY CONVERT(DATE,Event_Date) ORDER BY 1 DESC 
SELECT CONVERT(DATE,CONVERT(VARCHAR,Event_Day_ID)) Event_Date, COUNT_BIG(1) Fact_Host_Service_Event FROM   dbo.Fact_Host_Service_Event GROUP BY CONVERT(DATE,CONVERT(VARCHAR,Event_Day_ID)) ORDER BY 1 DESC
SELECT CONVERT(DATE,CONVERT(VARCHAR,Event_Day_ID)) Event_Date, COUNT_BIG(1) Fact_Host_Service_Event_Metric FROM   dbo.Fact_Host_Service_Event_Metric GROUP BY CONVERT(DATE,CONVERT(VARCHAR,Event_Day_ID)) ORDER BY 1 DESC
###################################################################################################################
*/

    --:: Debug
		-- DECLARE @IsFullLoad BIT = 1
    
    DECLARE last_updated_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0; -- Testing
    DECLARE log_source STRING DEFAULT 'EDW_NAGIOS.Dim_Host_Service_Metric_Load';
    DECLARE log_start_date DATETIME;
    DECLARE sql STRING;
    DECLARE num INT64 DEFAULT 1;
    DECLARE eq STRING DEFAULT "INSTR(Metric_string,'=')";
    DECLARE new_sql STRING;
    DECLARE no_data_to_process INT64 DEFAULT 0;
    BEGIN
      DECLARE max_metric_count INT64;
      DECLARE last_host_service_metric_id INT64;
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
		--======================================================================
		-- Get Host/Service Status History data from landing
		--======================================================================
      IF isfullload = 0 THEN
        CALL EDW_NAGIOS_SUPPORT.Get_UpdatedDate('Nagios Host_Service_Event Dim & Fact Tables', last_updated_date);
        SET log_message = concat('Started incremental load from LND_UpdateDate since the last successful run: ', substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_updated_date) as STRING), 1, 25));
      ELSE
        SET last_updated_date=(SELECT
            coalesce(date_sub(min(t.lnd_updatedate), interval 1 SECOND), CAST('1/1/2021' as DATE)) AS last_updated_date
          FROM
            (
              SELECT
                  min(Host_Event.lnd_updatedate) AS lnd_updatedate
                FROM
                  LND_NAGIOS.Host_Event
              UNION DISTINCT
              SELECT
                  min(Service_Event.lnd_updatedate) AS lnd_updatedate
                FROM
                  LND_NAGIOS.Service_Event
            ) AS t)
        ;
        SET log_message = concat('Started full load from the 1st LND_UpdateDate in LND_NAGIOS.Host_Event and LND_NAGIOS.Service_Event: ', substr(CAST(last_updated_date as STRING), 1, 25));
      END IF;
      IF trace_flag = 1 THEN
        SELECT log_message;
      END IF;
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
    
      SET sql= """CREATE OR REPLACE TABLE
                    EDW_NAGIOS_STAGE.Host_Service_Event
                  CLUSTER BY
                    host_service_event_id AS
                  SELECT
                    src.service_event_id AS host_service_event_id,
                    src.service_object_id AS nagios_object_id,
                    src.event_date,
                    src.service_state AS host_service_state,
                    src.host,
                    src.service,
                    src.event_info,
                    src.perf_data,
                    src.metric_string,
                    src.metric_count,
                    src.lnd_updatedate
                  FROM
                    LND_NAGIOS.Service_Event AS src
                  INNER JOIN
                    EDW_NAGIOS.Dim_Host_Service AS hs
                  ON
                    src.service_object_id = hs.nagios_object_id
                  WHERE
                    src.lnd_updatedate > '"""||last_updated_date||"""'
                  UNION ALL
                  SELECT
                    src.host_event_id AS host_service_event_id,
                    src.host_object_id AS nagios_object_id,
                    src.event_date,
                    src.host_state AS host_service_state,
                    src.host,
                    NULL AS service,
                    src.event_info,
                    src.perf_data,
                    src.metric_string,
                    src.metric_count,
                    src.lnd_updatedate
                  FROM
                    LND_NAGIOS.Host_Event AS src
                  INNER JOIN
                    EDW_NAGIOS.Dim_Host_Service AS hs
                  ON
                    src.host_object_id = hs.nagios_object_id
                  WHERE
                    src.lnd_updatedate > '"""||last_updated_date||"""' """;
    
      EXECUTE IMMEDIATE sql;
      SET log_message = 'Loaded Stage.Host_Service_Event table';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, sql);


		--======================================================================
		--:: Load Stage.Host_Service_Metric_Data from STAGE data
		--======================================================================

      SET max_metric_count = coalesce((
        SELECT
            max(Host_Service_Event.metric_count)
          FROM
            EDW_NAGIOS_STAGE.Host_Service_Event
      ), 0);

      IF max_metric_count = 0 OR (SELECT count(1) FROM EDW_NAGIOS_STAGE.Host_Service_Event) = 0 
      THEN
        SET (log_message,no_data_to_process)=(SELECT STRUCT('Finished load proc, nothing process!' AS log_message,1 AS no_data_to_process));

        CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = 'log_message, 16, 1, ';
      END IF;
      SET max_metric_count = CASE
        WHEN max_metric_count > 20 THEN 20
        ELSE max_metric_count
      END;
      DROP TABLE IF EXISTS EDW_NAGIOS_STAGE.Host_Service_Metric_Data1;
      DROP TABLE IF EXISTS EDW_NAGIOS_STAGE.Host_Service_Metric_Data2;
      DROP TABLE IF EXISTS EDW_NAGIOS_STAGE.Host_Service_Metric_Data3;
      DROP TABLE IF EXISTS EDW_NAGIOS_STAGE.Host_Service_Metric_Data4;
      DROP TABLE IF EXISTS EDW_NAGIOS_STAGE.Host_Service_Metric_Data5;
      DROP TABLE IF EXISTS EDW_NAGIOS_STAGE.Host_Service_Metric_Data6;
      DROP TABLE IF EXISTS EDW_NAGIOS_STAGE.Host_Service_Metric_Data;

		--:: Load dbo.Host_Service_Metric_Data1 with "=" locations. One row per event.
      SET sql = """
      CREATE OR REPLACE TABLE EDW_NAGIOS_STAGE.Host_Service_Metric_Data1 AS 
      SELECT 
          Host_Service_Event_ID,
          Host_Service_State,
          Host,
          Service,
          Metric_String,
          Metric_Count,
          CASE WHEN Metric_Count >= 1 THEN """ || eq || """ END AS EQ_1
      """;

      WHILE num < max_metric_count DO
          SET num = num + 1;
          SET eq = "INSTR(Metric_String, '=', " || eq || " + 1)";
          SET sql = sql || """
          ,CASE WHEN Metric_Count >= """ || CAST(num AS STRING) || """ THEN """ || eq || """ END AS EQ_""" || CAST(num AS STRING);
      END WHILE;

      SET sql = sql || " FROM EDW_NAGIOS_STAGE.Host_Service_Event WHERE Metric_Count > 0";

      EXECUTE IMMEDIATE sql;
      SET log_message = 'Loaded .Host_Service_Metric_Data1 with "=" locations. One row per event.';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(-1 as STRING));
      
		--:: Load EDW_NAGIOS.Host_Service_Metric_Data2 with each metric start locations. One row per event
      SET num=1; --> Reset loop counter
      SET sql = """
      CREATE OR REPLACE TABLE EDW_NAGIOS_STAGE.Host_Service_Metric_Data2 AS 
      SELECT 
          *,
          1 AS M_1
      """;

      WHILE num < max_metric_count DO
          SET num = num + 1;
          SET sql = sql || """
          ,CASE 
              WHEN Metric_Count >= """ || CAST(num AS STRING) || """ AND (STRPOS(REVERSE(SUBSTR(Metric_String,EQ_""" || CAST(num - 1 AS STRING) || """,EQ_""" || CAST(num AS STRING) || """-EQ_""" || CAST(num - 1 AS STRING) || """)),';')-1)>0 THEN
                STRPOS(Metric_String,REVERSE(left(reverse(SUBSTR(Metric_String,EQ_""" || CAST(num - 1 AS STRING) || """,EQ_""" || CAST(num AS STRING) || """-EQ_""" || CAST(num - 1 AS STRING) || """)),(STRPOS(REVERSE(SUBSTR(Metric_String,EQ_""" || CAST(num - 1 AS STRING) || """,EQ_""" || CAST(num AS STRING) || """-EQ_""" || CAST(num - 1 AS STRING) || """)),';')-1)))) 
          END AS M_""" || CAST(num AS STRING) ;
      END WHILE;
      SET sql = sql || " FROM EDW_NAGIOS_STAGE.Host_Service_Metric_Data1";

      EXECUTE IMMEDIATE sql;
      SET log_message = 'Loaded EDW_NAGIOS_STAGE.Host_Service_Metric_Data2 with each metric start locations. One row per event.';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, substr(CAST(-1 as STRING), 1, 2147483647));


		--:: Expand! Load EDW_NAGIOS_STAGE.Host_Service_Metric_Data3 with precise Metric Name and Value String for each metric. One row per event,metric.
      SET num = 0;--> Reset loop counter
      SET sql="CREATE OR REPLACE TABLE EDW_NAGIOS_STAGE.Host_Service_Metric_Data3 AS ";
      
      WHILE num < max_metric_count DO
        SET num = num + 1;
        SET new_sql = """
        SELECT 
            host_service_event_id,
            host,
            service,
            host_service_state,
            metric_string,
            metric_count,
            """||substr(CAST(num as STRING), 1, 30)||""" AS metric_index,
            CAST(SUBSTR(metric_string, M_"""||CAST(num AS STRING)||""",EQ_"""|| CAST(num AS STRING)||""" - M_"""|| CAST(num AS STRING)||""") AS STRING) AS metric_name,
            SUBSTR(Metric_String,EQ_"""|| CAST(num AS STRING)||""" + 1,IF("""||num||""" = """||Max_Metric_Count||""", 50, COALESCE(M_"""|| case when num = Max_Metric_Count then  CAST(num AS STRING) else  CAST(num+1 AS STRING) end||""" - EQ_"""|| CAST(num AS STRING)||""" - 1, 50))) AS Value_String 
        FROM  EDW_NAGIOS_STAGE.Host_Service_Metric_Data2  
        WHERE metric_count >= """||substr(CAST(num as STRING), 1, 30)||""" """;

        SET sql = concat(sql, CASE WHEN num > 1 THEN "  UNION ALL " ELSE '' END, new_sql);
      END WHILE;

      EXECUTE IMMEDIATE sql;
      SET log_message = 'Loaded Stage.Host_Service_Metric_Data3 with precise Metric Name and Value String for each metric. One row per event,metric.';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(-1 as STRING));

		  --:: Parse Value_String delimiter positions
      --DROP TABLE IF EXISTS EDW_NAGIOS_STAGE.Host_Service_Metric_Data4;
      CREATE OR REPLACE TABLE EDW_NAGIOS_STAGE.Host_Service_Metric_Data4
        AS
          SELECT
              Host_Service_Metric_Data3.host_service_event_id,
              Host_Service_Metric_Data3.host_service_state,
              Host_Service_Metric_Data3.host,
              Host_Service_Metric_Data3.service,
              Host_Service_Metric_Data3.metric_count,
              Host_Service_Metric_Data3.metric_string,
              Host_Service_Metric_Data3.metric_index,
              Host_Service_Metric_Data3.metric_name,
              Host_Service_Metric_Data3.value_string,
              left(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') - 1) AS value_unit,
              nullif(strpos(Host_Service_Metric_Data3.value_string, ';'), 0) AS delim_1,
              nullif(CASE
                WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                  WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                  ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                END - 1)
              END, 0) AS delim_2,
              nullif(CASE
                WHEN strpos(substr(Host_Service_Metric_Data3.value_string, CASE
                  WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                  ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                    WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                    ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                  END - 1)
                END + 1), ';') = 0 THEN 0
                ELSE strpos(substr(Host_Service_Metric_Data3.value_string, CASE
                  WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                  ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                    WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                    ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                  END - 1)
                END + 1), ';') + (CASE
                  WHEN CASE
                    WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                    ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                      WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                      ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                    END - 1)
                  END + 1 < 1 THEN 1
                  ELSE CASE
                    WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                    ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                      WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                      ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                    END - 1)
                  END + 1
                END - 1)
              END, 0) AS delim_3,
              nullif(CASE
                WHEN strpos(substr(Host_Service_Metric_Data3.value_string, CASE
                  WHEN strpos(substr(Host_Service_Metric_Data3.value_string, CASE
                    WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                    ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                      WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                      ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                    END - 1)
                  END + 1), ';') = 0 THEN 0
                  ELSE strpos(substr(Host_Service_Metric_Data3.value_string, CASE
                    WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                    ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                      WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                      ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                    END - 1)
                  END + 1), ';') + (CASE
                    WHEN CASE
                      WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                      ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                        WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                        ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                      END - 1)
                    END + 1 < 1 THEN 1
                    ELSE CASE
                      WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                      ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                        WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                        ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                      END - 1)
                    END + 1
                  END - 1)
                END + 1), ';') = 0 THEN 0
                ELSE strpos(substr(Host_Service_Metric_Data3.value_string, CASE
                  WHEN strpos(substr(Host_Service_Metric_Data3.value_string, CASE
                    WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                    ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                      WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                      ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                    END - 1)
                  END + 1), ';') = 0 THEN 0
                  ELSE strpos(substr(Host_Service_Metric_Data3.value_string, CASE
                    WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                    ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                      WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                      ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                    END - 1)
                  END + 1), ';') + (CASE
                    WHEN CASE
                      WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                      ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                        WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                        ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                      END - 1)
                    END + 1 < 1 THEN 1
                    ELSE CASE
                      WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                      ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                        WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                        ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                      END - 1)
                    END + 1
                  END - 1)
                END + 1), ';') + (CASE
                  WHEN CASE
                    WHEN strpos(substr(Host_Service_Metric_Data3.value_string, CASE
                      WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                      ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                        WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                        ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                      END - 1)
                    END + 1), ';') = 0 THEN 0
                    ELSE strpos(substr(Host_Service_Metric_Data3.value_string, CASE
                      WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                      ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                        WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                        ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                      END - 1)
                    END + 1), ';') + (CASE
                      WHEN CASE
                        WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                        ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                          WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                          ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                        END - 1)
                      END + 1 < 1 THEN 1
                      ELSE CASE
                        WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                        ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                          WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                          ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                        END - 1)
                      END + 1
                    END - 1)
                  END + 1 < 1 THEN 1
                  ELSE CASE
                    WHEN strpos(substr(Host_Service_Metric_Data3.value_string, CASE
                      WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                      ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                        WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                        ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                      END - 1)
                    END + 1), ';') = 0 THEN 0
                    ELSE strpos(substr(Host_Service_Metric_Data3.value_string, CASE
                      WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                      ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                        WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                        ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                      END - 1)
                    END + 1), ';') + (CASE
                      WHEN CASE
                        WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                        ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                          WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                          ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                        END - 1)
                      END + 1 < 1 THEN 1
                      ELSE CASE
                        WHEN strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') = 0 THEN 0
                        ELSE strpos(substr(Host_Service_Metric_Data3.value_string, strpos(Host_Service_Metric_Data3.value_string, ';') + 1), ';') + (CASE
                          WHEN strpos(Host_Service_Metric_Data3.value_string, ';') + 1 < 1 THEN 1
                          ELSE strpos(Host_Service_Metric_Data3.value_string, ';') + 1
                        END - 1)
                      END + 1
                    END - 1)
                  END + 1
                END - 1)
              END, 0) AS delim_4
            FROM
              EDW_NAGIOS_STAGE.Host_Service_Metric_Data3
            WHERE Host_Service_Metric_Data3.metric_name IS NOT NULL
            --ORDER BY Host_Service_Event_ID, Metric_Index
            ;
      EXECUTE IMMEDIATE sql;

      SET log_message = 'Loaded Stage.Host_Service_Metric_Data4 table. Parse Value_String delimiter positions.';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      
		  --:: Parse Value_String
      --DROP TABLE IF EXISTS EDW_NAGIOS_STAGE.Host_Service_Metric_Data5;
      CREATE OR REPLACE TABLE
        EDW_NAGIOS_STAGE.Host_Service_Metric_Data5 AS
      SELECT
        Host_Service_Metric_Data4.host_service_event_id,
        Host_Service_Metric_Data4.host_service_state,
        Host_Service_Metric_Data4.host,
        Host_Service_Metric_Data4.service,
        Host_Service_Metric_Data4.metric_count,
        Host_Service_Metric_Data4.metric_string,
        Host_Service_Metric_Data4.metric_index,
        Host_Service_Metric_Data4.metric_name,
        Host_Service_Metric_Data4.value_string,
        Host_Service_Metric_Data4.value_unit,
        REGEXP_REPLACE(COLLATE(Value_Unit,
            ''),IFNULL( SUBSTR(COLLATE(Value_Unit,
                ''), NULLIF(STRPOS(COLLATE(Value_Unit,
                    ''), REGEXP_EXTRACT(COLLATE(Value_Unit,
                      ''), r'[^0-9.-]')), 0), 5 ), '' ), '') AS metric_value,
        SUBSTR(COLLATE(Value_Unit,
            ''), NULLIF(STRPOS(COLLATE(Value_Unit,
                ''), REGEXP_EXTRACT(COLLATE(Value_Unit,
                  ''), r'[^0-9.-]')), 0), 5) AS metric_unit,
        CASE
          WHEN DELIM_2 - DELIM_1 - 1 > 0 THEN REPLACE( REPLACE( SUBSTR(Value_String, DELIM_1 + 1, DELIM_2 - DELIM_1 - 1), IFNULL(SUBSTR(COLLATE(Value_Unit, ''), NULLIF(REGEXP_INSTR(COLLATE(Value_Unit, ''), r'[^0-9.-]'), 0), 5), ''), '' ), '_', '' )
      END
        AS warning_value,
        CASE
          WHEN DELIM_3 - DELIM_2 - 1 > 0 THEN REPLACE( REPLACE( SUBSTR(Value_String, DELIM_2 + 1, DELIM_3 - DELIM_2 - 1), IFNULL(SUBSTR(COLLATE(Value_Unit, ''), NULLIF(REGEXP_INSTR(COLLATE(Value_Unit, ''), r'[^0-9.-]'), 0), 5), ''), '' ), '_', '' )
      END
        AS critical_value,
        CASE
          WHEN DELIM_4 - DELIM_3 - 1 > 0 THEN REPLACE( REPLACE( SUBSTR(Value_String, DELIM_3 + 1, DELIM_4 - DELIM_3 - 1), IFNULL(SUBSTR(COLLATE(Value_Unit, ''), NULLIF(REGEXP_INSTR(COLLATE(Value_Unit, ''), r'[^0-9.-]'), 0), 5), ''), '' ), '_', '' )
      END
        AS min_value,
        CASE
          WHEN DELIM_4 + 1 > 0 THEN NULLIF( REPLACE( REPLACE( REPLACE( SUBSTR(Value_String, DELIM_4 + 1, 50), IFNULL(SUBSTR(Value_Unit, NULLIF(REGEXP_INSTR(COLLATE(Value_Unit, ''), r'[^0-9.-]'), 0), 5), ''), '' ), ';', '' ), '_', '' ), '' )
      END
        AS max_value
      FROM
        EDW_NAGIOS_STAGE.Host_Service_Metric_Data4
      WHERE
        NOT REGEXP_CONTAINS( REPLACE( COLLATE(Value_Unit,
              ''), IFNULL( SUBSTR(COLLATE(Value_Unit,
                  ''), NULLIF(STRPOS(COLLATE(Value_Unit,
                      ''), REGEXP_EXTRACT(COLLATE(Value_Unit,
                        ''), r'[^0-9.-]')), 0), 5 ), '' ), '' ), r'=' );
		--ORDER BY Host_Service_Event_ID, Metric_Index
      
      EXECUTE IMMEDIATE sql;
      SET log_message = 'Loaded Stage.Host_Service_Metric_Data5 table. Parse Value_String.';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      
      
      --DROP TABLE IF EXISTS EDW_NAGIOS_STAGE.Host_Service_Metric_Data6;
      CREATE OR REPLACE  TABLE EDW_NAGIOS_STAGE.Host_Service_Metric_Data6
        AS
          SELECT
              Host_Service_Metric_Data5.host_service_event_id,
              Host_Service_Metric_Data5.host_service_state,
              Host_Service_Metric_Data5.host,
              Host_Service_Metric_Data5.service,
              Host_Service_Metric_Data5.metric_string,
              Host_Service_Metric_Data5.metric_index,
              CAST(CASE 
                  WHEN (REGEXP_CONTAINS(COLLATE(Host_Service_Metric_Data5.Metric_Name,''), r'\.[0-9]$') OR REGEXP_CONTAINS(COLLATE(Host_Service_Metric_Data5.Metric_Name,''), r'0$')) AND Host_Service_Metric_Data5.Metric_Count = 1 THEN NULL 
                  WHEN REGEXP_CONTAINS(COLLATE(Host_Service_Metric_Data5.Metric_Name,''), r'[0-9]{2}$') THEN SUBSTR(COLLATE(Host_Service_Metric_Data5.Metric_Name,''), -2)
                  WHEN REGEXP_CONTAINS(COLLATE(Host_Service_Metric_Data5.Metric_Name,''), r'[0-9]$') THEN SUBSTR(COLLATE(Host_Service_Metric_Data5.Metric_Name,''), -1)
              END AS INT64) AS metric_suffix,
              Host_Service_Metric_Data5.metric_name,
              CASE
                WHEN REGEXP_CONTAINS(collate(Host_Service_Metric_Data5.metric_value,''), r'^-?\d+(\.\d+)?$')  IS NULL THEN CAST(NULL as BIGNUMERIC)
                ELSE SAFE_CAST(Host_Service_Metric_Data5.metric_value as NUMERIC)
              END AS metric_value,
              Host_Service_Metric_Data5.metric_unit,
              CASE
                WHEN REGEXP_CONTAINS(collate(Host_Service_Metric_Data5.warning_value,''), r'^-?\d+(\.\d+)?$') IS NULL THEN CAST(NULL as BIGNUMERIC)
                ELSE SAFE_CAST(Host_Service_Metric_Data5.warning_value as NUMERIC)
              END AS warning_value,
              CASE
                WHEN REGEXP_CONTAINS(collate(Host_Service_Metric_Data5.critical_value,''), r'^-?\d+(\.\d+)?$') IS NULL THEN CAST(NULL as BIGNUMERIC)
                ELSE SAFE_CAST(Host_Service_Metric_Data5.critical_value as NUMERIC)
              END AS critical_value,
              CASE
                WHEN REGEXP_CONTAINS(collate(Host_Service_Metric_Data5.min_value,''), r'^-?\d+(\.\d+)?$') IS NULL THEN CAST(NULL as BIGNUMERIC)
                ELSE SAFE_CAST(Host_Service_Metric_Data5.min_value as NUMERIC)
              END AS min_value,
              CASE
                WHEN REGEXP_CONTAINS(collate(Host_Service_Metric_Data5.max_value,''), r'^-?\d+(\.\d+)?$') IS NULL THEN CAST(NULL as BIGNUMERIC)
                ELSE SAFE_CAST(Host_Service_Metric_Data5.max_value as NUMERIC)
              END AS max_value
            FROM
              EDW_NAGIOS_STAGE.Host_Service_Metric_Data5
      ;
      SET log_message = 'Loaded Stage.Host_Service_Metric_Data6 table with key, values';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      
      --DROP TABLE IF EXISTS EDW_NAGIOS_STAGE.Host_Service_Metric_Data;
      CREATE OR REPLACE TABLE EDW_NAGIOS_STAGE.Host_Service_Metric_Data
        AS
          SELECT
              md.host_service_event_id,
              ss.event_date,
              ss.nagios_object_id,
              hs.host_type,
              ss.host,
              md.service,
              md.host_service_state,
              ss.event_info,
              md.metric_string,
              md.metric_index,
              md.metric_suffix,
              md.metric_name,
              md.metric_value,
              md.metric_unit,
              md.warning_value,
              md.critical_value,
              md.min_value,
              md.max_value,
              CASE
                WHEN md.metric_suffix IS NULL
                 AND md.metric_index = 1 THEN md.host_service_state
                WHEN md.max_value IS NOT NULL
                 AND md.metric_value >= md.max_value THEN 2 -- Critical
                WHEN md.min_value IS NOT NULL
                 AND md.metric_value < md.min_value THEN 3 -- Unknown
                WHEN md.critical_value IS NOT NULL
                 AND md.metric_value >= md.critical_value THEN 2 -- Critical
                WHEN md.warning_value IS NOT NULL
                 AND md.metric_value >= md.warning_value THEN 1
                ELSE 0
              END AS metric_state,
              CASE
                WHEN md.warning_value > 0 THEN ROUND(md.metric_value * 100 / md.warning_value,2)
                ELSE CAST(NULL as BIGNUMERIC)
              END AS percent_warning,
              CASE
                WHEN md.critical_value > 0 THEN ROUND(md.metric_value * 100 / md.critical_value,2)
                ELSE CAST(NULL as BIGNUMERIC)
              END AS percent_critical,
              CASE
                WHEN md.max_value > 0 THEN ROUND(md.metric_value * 100 / md.max_value,2)
                ELSE CAST(NULL as BIGNUMERIC)
              END AS percent_max,
              ss.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              EDW_NAGIOS_STAGE.Host_Service_Metric_Data6 AS md
              INNER JOIN EDW_NAGIOS_STAGE.host_service_event AS ss ON md.host_service_event_id = ss.host_service_event_id
              LEFT OUTER JOIN EDW_NAGIOS.dim_host_service AS hs ON ss.nagios_object_id = hs.nagios_object_id
      ;
      SET log_message = 'Loaded Stage.Host_Service_Metric_Data table with all metric details';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));

      		--======================================================================
		--:: Load dbo.Dim_Host_Service_Metric
		--======================================================================

		--:: Insert the unknown Camera mapping from the known mapping of one of the Controller Hosts pair ending in A/B or AA/BB. 
      INSERT INTO EDW_NAGIOS_SUPPORT.Lane_Camera_Mapping (controller, metric_suffix, camera, edw_updatedate)
        SELECT
            CASE
              WHEN n.controller LIKE '%A' THEN concat(reverse(substr(reverse(n.controller), greatest(strpos(reverse(n.controller), '-'), 0), CASE
                WHEN strpos(reverse(n.controller), '-') < 1 THEN greatest(strpos(reverse(n.controller), '-') + (50 - 1), 0)
                ELSE 50
              END)), replace(reverse(left(reverse(n.controller), strpos(reverse(n.controller), '-') - 1)), 'A', 'B'))
              WHEN n.controller LIKE '%B' THEN concat(reverse(substr(reverse(n.controller), greatest(strpos(reverse(n.controller), '-'), 0), CASE
                WHEN strpos(reverse(n.controller), '-') < 1 THEN greatest(strpos(reverse(n.controller), '-') + (50 - 1), 0)
                ELSE 50
              END)), replace(reverse(left(reverse(n.controller), strpos(reverse(n.controller), '-') - 1)), 'B', 'A'))
            END AS controller,
            n.metric_suffix,
            n.camera,
            n.edw_updatedate
          FROM
            EDW_NAGIOS_SUPPORT.Lane_Camera_Mapping  AS n
          WHERE NOT EXISTS (
            SELECT
                1
              FROM
                EDW_NAGIOS_SUPPORT.Lane_Camera_Mapping  AS s
              WHERE s.controller = CASE
                WHEN n.controller LIKE '%A' THEN concat(reverse(substr(reverse(n.controller), greatest(strpos(reverse(n.controller), '-'), 0), CASE
                  WHEN strpos(reverse(n.controller), '-') < 1 THEN greatest(strpos(reverse(n.controller), '-') + (50 - 1), 0)
                  ELSE 50
                END)), replace(reverse(left(reverse(n.controller), strpos(reverse(n.controller), '-') - 1)), 'A', 'B'))
                WHEN n.controller LIKE '%B' THEN concat(reverse(substr(reverse(n.controller), greatest(strpos(reverse(n.controller), '-'), 0), CASE
                  WHEN strpos(reverse(n.controller), '-') < 1 THEN greatest(strpos(reverse(n.controller), '-') + (50 - 1), 0)
                  ELSE 50
                END)), replace(reverse(left(reverse(n.controller), strpos(reverse(n.controller), '-') - 1)), 'B', 'A'))
              END
               AND s.metric_suffix = n.metric_suffix
          )
           AND CASE
            WHEN n.controller LIKE '%A' THEN concat(reverse(substr(reverse(n.controller), greatest(strpos(reverse(n.controller), '-'), 0), CASE
              WHEN strpos(reverse(n.controller), '-') < 1 THEN greatest(strpos(reverse(n.controller), '-') + (50 - 1), 0)
              ELSE 50
            END)), replace(reverse(left(reverse(n.controller), strpos(reverse(n.controller), '-') - 1)), 'A', 'B'))
            WHEN n.controller LIKE '%B' THEN concat(reverse(substr(reverse(n.controller), greatest(strpos(reverse(n.controller), '-'), 0), CASE
              WHEN strpos(reverse(n.controller), '-') < 1 THEN greatest(strpos(reverse(n.controller), '-') + (50 - 1), 0)
              ELSE 50
            END)), replace(reverse(left(reverse(n.controller), strpos(reverse(n.controller), '-') - 1)), 'B', 'A'))
          END IN(
            SELECT
                host AS host
              FROM
                EDW_NAGIOS.Dim_Host_Service_Metric
              WHERE object_type = 'Host'
          )
      ;
      SET log_message = 'Before dbo.Dim_Host_Service_Metric Load: Copied the missing Camera mapping for a Controller based on pair into Ref.Lane_Camera_Mapping';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      
      
      --DROP TABLE IF EXISTS EDW_NAGIOS_DELETE.Host_Service_Metric;
      CREATE OR REPLACE TABLE EDW_NAGIOS_DELETE.Host_Service_Metric
        AS
          SELECT
              hsm.nagios_object_id,
              hsm.service,
              hsm.metric_name,
              hsm.metric_suffix,
              CASE
                WHEN hsm.event_info LIKE '%Ln %:%'
                 AND hsm.metric_suffix IS NOT NULL THEN concat('Lane ', substr(CAST(hsm.metric_suffix as STRING), 1, 30))
                WHEN ht.camera IS NOT NULL
                 OR hsm.service IN(
                  'OCR Failure Rate', 'Missed Image Pct'
                ) THEN coalesce(ht.camera, 'Unknown')
              END AS metric_target,
              max(hsm.lnd_updatedate) AS lnd_updatedate
            FROM
              EDW_NAGIOS_STAGE.Host_Service_Metric_Data AS hsm
              LEFT OUTER JOIN EDW_NAGIOS_SUPPORT.Lane_Camera_Mapping  AS ht ON hsm.host = ht.controller
               AND hsm.metric_suffix = ht.metric_suffix
            GROUP BY hsm.nagios_object_id,hsm.service,hsm.metric_name,hsm.metric_suffix,metric_target
      ;

      SET last_host_service_metric_id=(SELECT
          max(Dim_Host_Service_Metric.host_service_metric_id) AS last_host_service_metric_id
        FROM
          EDW_NAGIOS.Dim_Host_Service_Metric)
      ;
      --DROP TABLE IF EXISTS EDW_NAGIOS.Dim_Host_Service_Metric_NEW;
      CREATE OR REPLACE TABLE EDW_NAGIOS.Dim_Host_Service_Metric_NEW cluster by Host_Service_Metric_ID
		-- Existing rows with the latest data coming from dbo.Dim_Host_Service, Ref.Lane_Camera_Mapping tables
        AS
          SELECT
              d.host_service_metric_id,
              d.nagios_object_id,
              coalesce(hs.object_type, d.object_type) AS object_type,
              coalesce(hs.host_facility, d.host_facility) AS host_facility,
              coalesce(hs.host_plaza, d.host_plaza) AS host_plaza,
              coalesce(hs.host_type, d.host_type) AS host_type,
              coalesce(hs.host, d.host) AS host,
              coalesce(hs.service, d.service) AS service,
              coalesce(hs.plaza_latitude, d.plaza_latitude) AS plaza_latitude,
              coalesce(hs.plaza_longitude, d.plaza_longitude) AS plaza_longitude,
              coalesce(hs.is_active, d.is_active) AS is_active,
              d.metric_name,
              d.metric_suffix,
              CASE
                WHEN d.metric_target_type = 'Lane' THEN d.metric_target_type
                WHEN ht.camera IS NOT NULL THEN 'Camera'
              END AS metric_target_type,
              CASE
                WHEN d.metric_target_type = 'Lane' THEN d.metric_target
                WHEN ht.camera IS NOT NULL THEN ht.camera
              END AS metric_target,
              d.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              EDW_NAGIOS.Dim_Host_Service_Metric AS d
              LEFT OUTER JOIN EDW_NAGIOS.Dim_Host_Service AS hs ON d.nagios_object_id = hs.nagios_object_id
              LEFT OUTER JOIN EDW_NAGIOS_SUPPORT.Lane_Camera_Mapping  AS ht ON hs.host = ht.controller
               AND d.metric_suffix = ht.metric_suffix
          UNION ALL
          SELECT
              IFNULL(Last_Host_Service_Metric_ID, 0) + ROW_NUMBER() OVER (
                  ORDER BY 
                    M.Nagios_Object_ID,
                    SUBSTR(M.Metric_Name, 1, 1 + LENGTH(M.Metric_Name) - REGEXP_INSTR(REVERSE(COLLATE(M.Metric_Name,'')), r'[^0-9 ]')),
                    M.Metric_Suffix
                ) AS host_service_metric_id,
              m.nagios_object_id,
              hs.object_type,
              hs.host_facility,
              hs.host_plaza,
              hs.host_type,
              hs.host,
              hs.service,
              hs.plaza_latitude,
              hs.plaza_longitude,
              hs.is_active,
              m.metric_name,
              m.metric_suffix,
              CASE
                WHEN m.metric_target LIKE 'Lane%' THEN 'Lane'
                WHEN m.metric_target IS NOT NULL THEN 'Camera'
              END AS metric_target_type,
              m.metric_target,
              m.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              EDW_NAGIOS_DELETE.Host_Service_Metric AS m
              INNER JOIN EDW_NAGIOS.Dim_Host_Service AS hs ON m.nagios_object_id = hs.nagios_object_id
            WHERE NOT EXISTS (
              SELECT
                  1
                FROM
                  EDW_NAGIOS.Dim_Host_Service_Metric AS d
                WHERE d.nagios_object_id = m.nagios_object_id
                 AND d.metric_name = m.metric_name
            )
      ;
      SET log_message = 'Loaded dbo.Dim_Host_Service_Metric_NEW';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      
      --CALL utility.tableswap('dbo.Dim_Host_Service_Metric_NEW', 'dbo.Dim_Host_Service_Metric');
      --Tableswap not required , using create or replace
      CREATE OR REPLACE TABLE EDW_NAGIOS.Dim_Host_Service_Metric CLUSTER BY host_service_metric_id AS SELECT * FROM EDW_NAGIOS.Dim_Host_Service_Metric_NEW;

      INSERT INTO EDW_NAGIOS_SUPPORT.Lane_Camera_Mapping  (controller, metric_suffix, camera, edw_updatedate)
        SELECT
            cmn.controller,
            cmn.metric_suffix,
            cmn.metric_target,
            current_datetime() AS edw_updatedate
          FROM
            (
              SELECT DISTINCT
                  Dim_Host_Service_Metric.host AS controller,
                  Dim_Host_Service_Metric.metric_suffix,
                  coalesce(Dim_Host_Service_Metric.metric_target, 'Unknown') AS metric_target
                FROM
                  EDW_NAGIOS.Dim_Host_Service_Metric
                WHERE Dim_Host_Service_Metric.service IN(
                  'OCR Failure Rate', 'Missed Image Pct'
                )
            ) AS cmn
          WHERE NOT EXISTS (
            SELECT
                1
              FROM
                EDW_NAGIOS_SUPPORT.Lane_Camera_Mapping  AS cm
              WHERE cmn.controller = cm.controller
               AND cmn.metric_suffix = cm.metric_suffix
          ) and cmn.Metric_Suffix is not null
      ;
      SET log_message = 'Inserted new Controller Hosts into Ref.Lane_Camera_Mapping table';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      SET log_message = 'Completed dbo.Dim_Host_Service_Metric load';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      
      IF trace_flag = 1 THEN
        SELECT
            'Stage.Host_Service_Metric_Data1' AS tablename,
            *
          FROM
            EDW_NAGIOS_STAGE.Host_Service_Metric_Data1
        ORDER BY
          host_service_event_id DESC  LIMIT 100
        ;
        SELECT
            'Stage.Host_Service_Metric_Data2' AS tablename,
            *
          FROM
            EDW_NAGIOS_STAGE.Host_Service_Metric_Data2
        ORDER BY
          host_service_event_id DESC  LIMIT 100
        ;
        SELECT
            'Stage.Host_Service_Metric_Data3' AS tablename,
            Host_Service_Metric_Data3.*
          FROM
            EDW_NAGIOS_STAGE.Host_Service_Metric_Data3
        ORDER BY
          host_service_event_id DESC  LIMIT 100
        ;
        SELECT
            'Stage.Host_Service_Metric_Data4' AS tablename,
            Host_Service_Metric_Data4.*
          FROM
            EDW_NAGIOS_STAGE.Host_Service_Metric_Data4
        ORDER BY
          host_service_event_id DESC  LIMIT 100
        ;
        SELECT
            'Stage.Host_Service_Metric_Data5' AS tablename,
            Host_Service_Metric_Data5.*
          FROM
            EDW_NAGIOS_STAGE.Host_Service_Metric_Data5
        ORDER BY
          host_service_event_id DESC  LIMIT 100
        ;
        SELECT
            'Stage.Host_Service_Metric_Data6' AS tablename,
            Host_Service_Metric_Data6.*
          FROM
            EDW_NAGIOS_STAGE.Host_Service_Metric_Data6
        ORDER BY
          host_service_event_id DESC  LIMIT 100
        ;
        SELECT
            'Stage.Host_Service_Metric_Data ' AS tablename,
            Host_Service_Metric_Data.*
          FROM
            EDW_NAGIOS_STAGE.Host_Service_Metric_Data
        ORDER BY
          host_service_event_id DESC  LIMIT 100
        ;
        SELECT
            Dim_Host_Service_Metric.*
          FROM
            EDW_NAGIOS.Dim_Host_Service_Metric
        ORDER BY
          lnd_updatedate DESC,
          host,
          service,
          metric_name
        ;
      END IF;

    EXCEPTION WHEN ERROR THEN
    IF no_data_to_process = 0 THEN
        BEGIN
          DECLARE error_message STRING DEFAULT concat('*** Error in dbo.Dim_Host_Service_Metric_Load: ', @@error.message);
          CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
          RAISE USING MESSAGE = error_message; -- Rethrow the error!
        END;
      END IF;
    END;
  /*

--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_Host_Service_Metric_Load 0
SELECT * FROM dbo.Dim_Host_Service_Metric ORDER BY Host_Type, Host, Service, Metric_Name, Metric_Suffix
SELECT * FROM Utility.ProcessLog ORDER BY 1 DESC
SELECT * FROM Utility.LoadProcessControl

--:: Data profile by Event Date
SELECT 'dbo.Host_Event' TableName, CONVERT(DATE, Event_Date) Event_Date, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Host_Object_ID) Dist_Count FROM LND_NAGIOS.dbo.Host_Event GROUP BY CONVERT(DATE, Event_Date) ORDER BY Event_Date desc
SELECT 'dbo.Service_Event' TableName, CONVERT(DATE, Event_Date) Event_Date, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Service_Object_ID) Dist_Count FROM LND_NAGIOS.dbo.Service_Event GROUP BY CONVERT(DATE, Event_Date) ORDER BY Event_Date DESC
SELECT 'Stage.Host_Service_Event' TableName, CONVERT(DATE, Event_Date) Event_Date, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Nagios_Object_ID) Dist_Count FROM Stage.Host_Service_Event GROUP BY CONVERT(DATE, Event_Date) ORDER BY Event_Date desc
											 
SELECT 'dbo.Fact_Host_Service_Event' TableName, CONVERT(DATE, Event_Date) Event_Date, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Nagios_Object_ID) Dist_Count FROM dbo.Fact_Host_Service_Event GROUP BY CONVERT(DATE, Event_Date) ORDER BY Event_Date desc
SELECT 'dbo.Fact_Host_Service_Event_Metric' TableName, CONVERT(DATE, Event_Date) Event_Date, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Nagios_Object_ID) Dist_Count FROM dbo.Fact_Host_Service_Event_Metric GROUP BY CONVERT(DATE, Event_Date) ORDER BY Event_Date desc
SELECT 'dbo.Fact_Host_Service_Event_Metric' TableName, COUNT_BIG(1) Row_Count, MIN(Event_Date) Event_DateFrom, MAX(Event_Date) Event_DateTo FROM dbo.Fact_Host_Service_Event_Metric   ORDER BY Event_Date desc

SELECT 'dbo.nagios_hoststatus_HIST' TableName, CONVERT(DATE, status_update_time) status_update_time, COUNT_BIG(1) Row_Count, COUNT(DISTINCT host_object_id) Dist_Count FROM LND_NAGIOS.dbo.nagios_hoststatus_HIST  GROUP BY CONVERT(DATE, status_update_time) ORDER BY status_update_time desc
SELECT 'dbo.nagios_servicestatus_HIST' TableName, CONVERT(DATE, status_update_time) status_update_time, COUNT_BIG(1) Row_Count, COUNT(DISTINCT service_object_id) Dist_Count FROM LND_NAGIOS.dbo.nagios_servicestatus_HIST GROUP BY CONVERT(DATE, status_update_time) ORDER BY status_update_time desc

SELECT 'dbo.nagios_hoststatus_STAGE' TableName, LND_UpdateDate , COUNT_BIG(1) Row_Count
FROM	LND_NAGIOS.dbo.nagios_hoststatus_STAGE hs  
JOIN	LND_NAGIOS.dbo.nagios_objects ho 
		ON hs.host_object_id = ho.object_id
WHERE	(hs.current_check_attempt = hs.max_check_attempts OR hs.current_state = 0)
GROUP BY LND_UpdateDate

--:: Data profile by LND_UpdateDate
SELECT 'dbo.Host_Event' TableName, LND_UpdateDate , COUNT_BIG(1) Row_Count, COUNT(DISTINCT Host_Object_ID) Dist_Count FROM LND_NAGIOS.dbo.Host_Event GROUP BY LND_UpdateDate ORDER BY LND_UpdateDate desc
SELECT 'dbo.Service_Event' TableName, LND_UpdateDate , COUNT_BIG(1) Row_Count, COUNT(DISTINCT Service_Object_ID) Dist_Count FROM LND_NAGIOS.dbo.Service_Event GROUP BY LND_UpdateDate ORDER BY LND_UpdateDate DESC
SELECT 'Stage.Host_Service_Event' TableName, LND_UpdateDate , COUNT_BIG(1) Row_Count, COUNT(DISTINCT Nagios_Object_ID) Dist_Count FROM Stage.Host_Service_Event GROUP BY LND_UpdateDate ORDER BY LND_UpdateDate DESC
SELECT 'dbo.Fact_Host_Service_Event' TableName, LND_UpdateDate, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Nagios_Object_ID) Dist_Count FROM dbo.Fact_Host_Service_Event GROUP BY LND_UpdateDate ORDER BY LND_UpdateDate desc
SELECT 'dbo.Fact_Host_Service_Event_Metric' TableName, LND_UpdateDate, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Nagios_Object_ID) Dist_Count FROM dbo.Fact_Host_Service_Event_Metric GROUP BY LND_UpdateDate ORDER BY LND_UpdateDate desc
SELECT * FROM Utility.LoadProcessControl

SELECT 'dbo.nagios_hoststatus_HIST' TableName, LND_UpdateDate, COUNT_BIG(1) Row_Count, COUNT(DISTINCT host_object_id) Dist_Count FROM LND_NAGIOS.dbo.nagios_hoststatus_HIST  GROUP BY LND_UpdateDate ORDER BY LND_UpdateDate desc
SELECT 'dbo.nagios_servicestatus_HIST' TableName, LND_UpdateDate, COUNT_BIG(1) Row_Count, COUNT(DISTINCT service_object_id) Dist_Count FROM LND_NAGIOS.dbo.nagios_servicestatus_HIST GROUP BY LND_UpdateDate ORDER BY LND_UpdateDate desc

--===============================================================================================================
-- Dynamic SQL outputs
--===============================================================================================================
IF OBJECT_ID('Stage.Host_Service_Metric_Data1') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data1 
CREATE TABLE Stage.Host_Service_Metric_Data1 WITH (HEAP, DISTRIBUTION = HASH(Host_Service_Event_ID)) AS
SELECT 
		Host_Service_Event_ID
		,State
		,Host
		,Service
		,Metric_String
		,Metric_Count
		,CASE WHEN Metric_Count >= 1 THEN CHARINDEX('=',Metric_String) END EQ_1
		,CASE WHEN Metric_Count >= 2 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1) END EQ_2
		,CASE WHEN Metric_Count >= 3 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1) END EQ_3
		,CASE WHEN Metric_Count >= 4 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1) END EQ_4
		,CASE WHEN Metric_Count >= 5 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1) END EQ_5
		,CASE WHEN Metric_Count >= 6 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1) END EQ_6
		,CASE WHEN Metric_Count >= 7 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1) END EQ_7
		,CASE WHEN Metric_Count >= 8 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1) END EQ_8
		,CASE WHEN Metric_Count >= 9 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_9
		,CASE WHEN Metric_Count >= 10 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_10
		,CASE WHEN Metric_Count >= 11 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_11
		,CASE WHEN Metric_Count >= 12 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_12
		,CASE WHEN Metric_Count >= 13 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_13
		,CASE WHEN Metric_Count >= 14 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_14
		,CASE WHEN Metric_Count >= 15 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_15
		,CASE WHEN Metric_Count >= 16 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_16
		,CASE WHEN Metric_Count >= 17 THEN CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String,CHARINDEX('=',Metric_String)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1) END EQ_17
FROM	Stage.Host_Service_Event

IF OBJECT_ID('Stage.Host_Service_Metric_Data2') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data2 
CREATE TABLE Stage.Host_Service_Metric_Data2 WITH (HEAP, DISTRIBUTION = HASH(Host_Service_Event_ID)) AS
SELECT 	*
		,1 M_1
	,CASE WHEN Metric_Count >= 2 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_1,EQ_2-EQ_1)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_1,EQ_2-EQ_1)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_1,EQ_2-EQ_1)))-1))+'%',Metric_String) END M_2
	,CASE WHEN Metric_Count >= 3 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_2,EQ_3-EQ_2)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_2,EQ_3-EQ_2)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_2,EQ_3-EQ_2)))-1))+'%',Metric_String) END M_3
	,CASE WHEN Metric_Count >= 4 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_3,EQ_4-EQ_3)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_3,EQ_4-EQ_3)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_3,EQ_4-EQ_3)))-1))+'%',Metric_String) END M_4
	,CASE WHEN Metric_Count >= 5 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_4,EQ_5-EQ_4)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_4,EQ_5-EQ_4)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_4,EQ_5-EQ_4)))-1))+'%',Metric_String) END M_5
	,CASE WHEN Metric_Count >= 6 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_5,EQ_6-EQ_5)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_5,EQ_6-EQ_5)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_5,EQ_6-EQ_5)))-1))+'%',Metric_String) END M_6
	,CASE WHEN Metric_Count >= 7 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_6,EQ_7-EQ_6)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_6,EQ_7-EQ_6)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_6,EQ_7-EQ_6)))-1))+'%',Metric_String) END M_7
	,CASE WHEN Metric_Count >= 8 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_7,EQ_8-EQ_7)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_7,EQ_8-EQ_7)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_7,EQ_8-EQ_7)))-1))+'%',Metric_String) END M_8
	,CASE WHEN Metric_Count >= 9 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_8,EQ_9-EQ_8)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_8,EQ_9-EQ_8)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_8,EQ_9-EQ_8)))-1))+'%',Metric_String) END M_9
	,CASE WHEN Metric_Count >= 10 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_9,EQ_10-EQ_9)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_9,EQ_10-EQ_9)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_9,EQ_10-EQ_9)))-1))+'%',Metric_String) END M_10
	,CASE WHEN Metric_Count >= 11 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_10,EQ_11-EQ_10)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_10,EQ_11-EQ_10)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_10,EQ_11-EQ_10)))-1))+'%',Metric_String) END M_11
	,CASE WHEN Metric_Count >= 12 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_11,EQ_12-EQ_11)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_11,EQ_12-EQ_11)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_11,EQ_12-EQ_11)))-1))+'%',Metric_String) END M_12
	,CASE WHEN Metric_Count >= 13 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_12,EQ_13-EQ_12)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_12,EQ_13-EQ_12)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_12,EQ_13-EQ_12)))-1))+'%',Metric_String) END M_13
	,CASE WHEN Metric_Count >= 14 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_13,EQ_14-EQ_13)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_13,EQ_14-EQ_13)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_13,EQ_14-EQ_13)))-1))+'%',Metric_String) END M_14
	,CASE WHEN Metric_Count >= 15 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_14,EQ_15-EQ_14)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_14,EQ_15-EQ_14)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_14,EQ_15-EQ_14)))-1))+'%',Metric_String) END M_15
	,CASE WHEN Metric_Count >= 16 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_15,EQ_16-EQ_15)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_15,EQ_16-EQ_15)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_15,EQ_16-EQ_15)))-1))+'%',Metric_String) END M_16
	,CASE WHEN Metric_Count >= 17 AND CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_16,EQ_17-EQ_16)))-1 > 0 THEN PATINDEX('%'+REVERSE(LEFT(REVERSE(SUBSTRING(Metric_String,EQ_16,EQ_17-EQ_16)),CHARINDEX(';',REVERSE(SUBSTRING(Metric_String,EQ_16,EQ_17-EQ_16)))-1))+'%',Metric_String) END M_17
FROM	Stage.Host_Service_Metric_Data1


IF OBJECT_ID('Stage.Host_Service_Metric_Data3') IS NOT NULL DROP TABLE Stage.Host_Service_Metric_Data3
CREATE TABLE Stage.Host_Service_Metric_Data3 WITH (HEAP, DISTRIBUTION = HASH(Host_Service_Event_ID)) AS
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		1 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_1,EQ_1-M_1)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_1+1,ISNULL(M_2-EQ_1-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 1
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		2 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_2,EQ_2-M_2)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_2+1,ISNULL(M_3-EQ_2-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 2
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		3 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_3,EQ_3-M_3)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_3+1,ISNULL(M_4-EQ_3-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 3
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		4 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_4,EQ_4-M_4)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_4+1,ISNULL(M_5-EQ_4-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 4
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		5 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_5,EQ_5-M_5)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_5+1,ISNULL(M_6-EQ_5-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 5
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		6 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_6,EQ_6-M_6)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_6+1,ISNULL(M_7-EQ_6-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 6
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		7 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_7,EQ_7-M_7)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_7+1,ISNULL(M_8-EQ_7-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 7
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		8 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_8,EQ_8-M_8)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_8+1,ISNULL(M_9-EQ_8-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 8
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		9 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_9,EQ_9-M_9)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_9+1,ISNULL(M_10-EQ_9-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 9
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		10 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_10,EQ_10-M_10)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_10+1,ISNULL(M_11-EQ_10-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 10
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		11 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_11,EQ_11-M_11)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_11+1,ISNULL(M_12-EQ_11-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 11
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		12 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_12,EQ_12-M_12)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_12+1,ISNULL(M_13-EQ_12-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 12
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		13 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_13,EQ_13-M_13)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_13+1,ISNULL(M_14-EQ_13-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 13
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		14 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_14,EQ_14-M_14)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_14+1,ISNULL(M_15-EQ_14-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 14
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		15 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_15,EQ_15-M_15)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_15+1,ISNULL(M_16-EQ_15-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 15
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		16 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_16,EQ_16-M_16)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_16+1,ISNULL(M_17-EQ_16-1,50)) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 16
	UNION ALL 
	SELECT 
		Host_Service_Event_ID,
		Host,
		Service,
		State,
		Metric_String,
		Metric_Count,
		17 AS Metric_Index,
		CONVERT(VARCHAR(100),SUBSTRING(Metric_String,M_17,EQ_17-M_17)) AS Metric_Name,
		SUBSTRING(Metric_String,EQ_17+1,50) AS Value_String
	FROM  Stage.Host_Service_Metric_Data2
	WHERE Metric_Count >= 17

--===============================================================================================================
-- Testing
--===============================================================================================================

SELECT TOP 1000 * FROM dbo.Dim_Host_Service WHERE Host = '360-WEBRD-1A' AND Service IN ('Missed Image Pct','OCR Failure Rate') 
SELECT TOP 1000 * FROM Stage.Host_Service_Metric_Data F WHERE Host = '360-WEBRD-1A' AND F.Nagios_Object_ID IN (72936, 72934)
SELECT TOP 1000 * FROM dbo.Dim_Host_Service_Metric ORDER BY Nagios_Object_ID, Host_Service_Metric_ID
SELECT TOP 1000 * FROM Stage.Host_Service_Metric_Data F WHERE metric_string LIKE '%iso.3.6.1.4.1.25597.11.1.1.4.0%'

--:: Distinct Services
SELECT DISTINCT Host_Type, Service FROM dbo.Dim_Host_Service WHERE Host_Type  = 'Lane Controller' AND Service IS NOT NULL ORDER BY   Service

SELECT TOP 1000 * FROM dbo.Dim_State 

SELECT * FROM Ref.Lane_Camera_Mapping

--:: Distinct Metric Names

SELECT	DISTINCT M.Metric_Name 
FROM	dbo.Dim_Host_Service_Metric M 
ORDER BY 1

SELECT	DISTINCT ISNULL(HS.Service,'Host') Host_Service,  M.Metric_Name 
FROM	dbo.Dim_Host_Service_Metric M 
JOIN	dbo.Dim_Host_Service HS 
		ON M.Nagios_Object_ID = HS.Nagios_Object_ID 
ORDER BY 1,2

SELECT	TOP 10000 HS.Nagios_Object_ID, HS.Host_type, HS.Host, HS.Service, M.* 
FROM	dbo.Dim_Host_Service_Metric M 
JOIN	dbo.Dim_Host_Service HS 
		ON M.Nagios_Object_ID = HS.Nagios_Object_ID 
WHERE	Host = 'SRT-NALDR-4A'  AND Service IN ('Missed Image Pct','OCR Failure Rate') 
ORDER BY M.Nagios_Object_ID, Metric_Suffix

SELECT	TOP 10000 HS.Nagios_Object_ID, HS.Host_type, HS.Host, HS.Service, M.* 
FROM	dbo.Dim_Host_Service_Metric M 
JOIN	dbo.Dim_Host_Service HS 
		ON M.Nagios_Object_ID = HS.Nagios_Object_ID 
WHERE	 Metric_Target_type = 'Camera'
		AND metric_target = 'CTP-MLG1-NR1'
ORDER BY M.Nagios_Object_ID, Metric_Suffix

SELECT	CONVERT(VARCHAR,status_update_time,112) StatusDayID, COUNT_BIG(1) RC
FROM	LND_NAGIOS.dbo.nagios_servicestatus_hist
GROUP BY CONVERT(VARCHAR,status_update_time,112)
ORDER BY 1

SELECT * FROM dbo.Dim_Host_Service_Metric WHERE Nagios_Object_ID = 13951

SELECT * FROM dbo.Host_Service_Metric_Data WHERE Host_Type IN ('Lane Controller','VES Controller','Tolling Camera') ORDER BY Host_Service_Event_ID, metric_index
SELECT * FROM dbo.Host_Service_Metric_Data WHERE Host_Type = 'UPS' ORDER BY Host_Service_Event_ID, metric_index

SELECT * FROM dbo.Host_Service_Metric_Data WHERE Service_State <> Metric_State AND Service_State = 1 ORDER BY Host_Service_Event_ID desc, metric_index
SELECT * FROM dbo.Host_Service_Metric_Data WHERE Host_Service_Event_ID  IN (190830165250073778) ORDER BY Host_Service_Event_ID, metric_index

SELECT COUNT_BIG(1) RC, COUNT(DISTINCT Host_Service_Event_ID) Event_Count FROM dbo.Host_Service_Metric_Data -- 72370706
SELECT COUNT_BIG(1) FROM service_state_STAGE

--:: Lane_Camera_Mapping data analysis									
SELECT DISTINCT Service FROM dbo.Dim_Host_Service_Metric m  WHERE m.Metric_Target IS NOT NULL AND m.Metric_Target_Type = 'Camera' 									
SELECT DISTINCT Host FROM dbo.Dim_Host_Service_Metric m WHERE service IN ('OCR Failure Rate','Missed Image Pct') AND m.Metric_Target IS NULL  ORDER BY  Host 									
SELECT DISTINCT Host, m.Metric_Suffix, Metric_Target FROM dbo.Dim_Host_Service_Metric m WHERE service IN ('OCR Failure Rate','Missed Image Pct') ORDER BY Host, m.Metric_Suffix									
SELECT DISTINCT Host_Plaza, Host, M.Object_Type, m.Metric_Target_Type, m.Metric_Target FROM dbo.Dim_Host_Service_Metric m WHERE m.Metric_Target IS NULL AND service IN ('OCR Failure Rate','Missed Image Pct') ORDER BY Host_Plaza, Host, M.Object_Type -- !!missing mapping rows!!									
SELECT DISTINCT Host_Plaza, Host, M.Object_Type, m.Metric_Target_Type, m.Metric_Target FROM dbo.Dim_Host_Service_Metric m WHERE m.Metric_Target IS NOT NULL AND service IN ('OCR Failure Rate','Missed Image Pct') ORDER BY Host_Plaza, Host, M.Object_Type  								
SELECT DISTINCT Host_Plaza, Host, M.Object_Type, Service, m.Metric_Target_Type, m.Metric_Target FROM dbo.Dim_Host_Service_Metric m WHERE m.Metric_Target IS NOT NULL AND m.Metric_Target_Type = 'Camera' ORDER BY Host_Plaza, Host, M.Object_Type, Service  									

--:: Before vs After
SELECT DISTINCT Host, m.Metric_Suffix, CASE WHEN Host = '360-MLG14-1BB' THEN NULL ELSE Metric_Target END Metric_Target FROM dbo.Dim_Host_Service_Metric m WHERE service IN ('OCR Failure Rate','Missed Image Pct') AND Host IN ( '360-MLG14-1AA','360-MLG14-1BB') ORDER BY Host, m.Metric_Suffix									
SELECT DISTINCT Host, m.Metric_Suffix, Metric_Target FROM dbo.Dim_Host_Service_Metric m WHERE service IN ('OCR Failure Rate','Missed Image Pct') AND Host IN ( '360-MLG14-1AA','360-MLG14-1BB') ORDER BY Host, m.Metric_Suffix									

--> Ref.Lane_Camera_Mapping XL File query <--
SELECT DISTINCT Host, Metric_Suffix, Metric_Target FROM dbo.Dim_Host_Service_Metric WHERE Service IN ('OCR Failure Rate','Missed Image Pct') ORDER BY 1, 2 

*/


  END;