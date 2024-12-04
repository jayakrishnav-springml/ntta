CREATE OR REPLACE PROCEDURE EDW_NAGIOS.Fact_Host_Service_Event_Load(isfullload INT64)
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.dbo.Fact_Host_Service_Event. Depends on dbo.Dim_Host_Service_Metric_Load for Stage.Host_Service_Event data

The following 3 procs go together in tight sequence, as if all in one proc:
1. dbo.Dim_Host_Service_Metric_Load
2. dbo.Fact_Host_Service_Event_Load
3. dbo.Fact_Host_Service_Event_Metric_Load
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0039845	Shankar		2021-03-26	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_Host_Service_Event_Load 0
SELECT TOP 1000 * FROM dbo.Fact_Host_Service_Event ORDER BY 1 DESC
SELECT * FROM EDW_NAGIOS_SUPPORT.ProcessLog ORDER BY 1 DESC
###################################################################################################################
*/
    -- DEBUG
    -- DECLARE @IsFullLoad BIT = 0

    DECLARE tablename STRING DEFAULT 'EDW_NAGIOS.Fact_Host_Service_Event';
    DECLARE trace_flag INT64 DEFAULT 1; -- Testing
    DECLARE firstpartitionid INT64 DEFAULT 202103;
    DECLARE lastpartitionid INT64;
    DECLARE partition_ranges STRING;
    DECLARE createtablewith STRING;
    DECLARE log_message STRING;
    DECLARE identifyingcolumns STRING DEFAULT 'Host_Service_Event_ID';
    DECLARE last_updated_date DATETIME;
    DECLARE log_source STRING DEFAULT 'EDW_NAGIOS.Fact_Host_Service_Event_Load';
    DECLARE log_start_date DATETIME;
    DECLARE stagetablename STRING DEFAULT 'EDW_NAGIOS.Fact_Host_Service_Event_NEW';
    DECLARE sql STRING;
    DECLARE sql1 STRING;
    BEGIN

      SET log_start_date = current_datetime('America/Chicago');
      SET lastpartitionid = CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_add(last_day(date_add(current_datetime(),interval 1 MONTH)), interval 1 DAY)) as STRING), 1, 6) as INT64);
      IF (SELECT COUNT(1) FROM EDW_NAGIOS.INFORMATION_SCHEMA.TABLES WHERE LOWER(table_name)=LOWER(SUBSTR(tablename,STRPOS(tablename,'.')+1))) =0 THEN
        SET isfullload = 1;
      END IF;
      IF isfullload = 1 THEN
        IF trace_flag = 1 THEN
          --select 'Calling: EDW_NAGIOS_SUPPORT.Get_PartitionDayIDRange_String from ' + substr(CAST(firstpartitionid as STRING), 1, 10)+ ' till ' + substr(CAST(lastpartitionid as STRING), 1, 10);
        END IF;
        --CALL EDW_NAGIOS_SUPPORT.Get_PartitionDayIDRange_String(substr(CAST(firstpartitionid as STRING), 1, 10), substr(CAST(lastpartitionid as STRING), 1, 10), partition_ranges);
        --SET createtablewith = concat('(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(Host_Service_Event_ID), PARTITION (Event_Day_ID RANGE RIGHT FOR VALUES (', partition_ranges, ')))');
        SET createtablewith = concat(' CLUSTER BY ', identifyingcolumns);

        IF trace_flag = 1 THEN
          select CreateTableWith;       
        END IF;
        SET log_message = 'Started Full load from the data populated by EDW_NAGIOS.Dim_Host_Service_Metric_Load in EDW_NAGIOS_STAGE.Host_Service_Event';
      ELSE
        SET createtablewith = concat(' CLUSTER BY ', identifyingcolumns);
        IF trace_flag = 1 THEN
          select CreateTableWith;
        END IF;
        IF trace_flag = 1 THEN
        	select 'Calling: EDW_NAGIOS_SUPPORT.Get_UpdatedDate for "Nagios Host_Service_Event Dim & Fact Tables"';
        END IF;
        CALL EDW_NAGIOS_SUPPORT.Get_UpdatedDate('Nagios Host_Service_Event Dim & Fact Tables', last_updated_date); -- Info Call only, not for use in this proc
        SET log_message = concat('Started Incremental load with event data populated by EDW_NAGIOS.Dim_Host_Service_Metric_Load in Stage.Host_Service_Event starting from ', substr(CAST(last_updated_date as STRING), 1, 25));
      END IF;
      IF trace_flag = 1 THEN
        select log_message;
      END IF;
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      
      --======================================================================
      --:: dbo.Fact_Host_Service_Event
      --======================================================================
      --SET sql= concat('CREATE OR REPLACE TABLE ', stagetablename, createtablewith, ' AS SELECT coalesce(CAST(s.host_service_event_id as INT64), 0) AS host_service_event_id, coalesce(CAST(s.nagios_object_id as INT64), 0) AS nagios_object_id, coalesce(CAST(s.event_date as DATETIME), DATETIME \'1900-01-01 00:00:00\') AS event_date, coalesce(CAST(CAST(s.event_date as STRING FORMAT \'YYYYMMDD\') as INT64), -1) AS event_day_id, coalesce(datetime_diff(s.event_date, CAST(CAST(s.event_date as DATE) as DATETIME), SECOND), -1) AS event_time_id, coalesce(CAST(st.state_id as INT64), 0) AS host_service_state_id, CAST(s.metric_count as INT64) AS metric_count, CAST(s.lnd_updatedate as DATETIME) AS lnd_updatedate, current_datetime() AS edw_updatedate FROM EDW_NAGIOS_STAGE.Host_Service_Event AS s INNER JOIN EDW_NAGIOS.Dim_State AS st ON s.host_service_state = st.state_value  AND st.object_type = CASE WHEN s.service IS NULL THEN \'Host\' ELSE \'Service\' END');
      set sql = '''CREATE OR REPLACE TABLE '''||stagetablename||''' ''' ||createtablewith|| ''' AS
                    SELECT
                      COALESCE(CAST(s.host_service_event_id AS INT64), 0) AS host_service_event_id,
                      COALESCE(CAST(s.nagios_object_id AS INT64), 0) AS nagios_object_id,
                      COALESCE(CAST(s.event_date AS DATETIME), DATETIME'1900-01-01 00:00:00') AS event_date,
                      COALESCE(CAST(CAST(s.event_date AS STRING FORMAT 'YYYYMMDD') AS INT64), -1) AS event_day_id,
                      COALESCE(DATETIME_DIFF(s.event_date, CAST(CAST(s.event_date AS DATE) AS DATETIME), SECOND), -1) AS event_time_id,
                      COALESCE(CAST(st.state_id AS INT64), 0) AS host_service_state_id,
                      CAST(s.metric_count AS INT64) AS metric_count,
                      CAST(s.lnd_updatedate AS DATETIME) AS lnd_updatedate,
                      CURRENT_DATETIME() AS edw_updatedate
                    FROM
                      EDW_NAGIOS_STAGE.Host_Service_Event AS s
                    INNER JOIN
                      EDW_NAGIOS.Dim_State AS st
                    ON
                      s.host_service_state = st.state_value
                      AND st.object_type =
                      CASE
                        WHEN s.service IS NULL THEN 'Host'
                        ELSE 'Service'
                    END'''
                      ;
      EXECUTE IMMEDIATE sql;
      SET log_message = concat('Loaded ', stagetablename);
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, sql);
      IF isfullload = 1 THEN
        --TableSwap is Not Required, using  Create or Replace Table below
        -- Table swap!
        --CALL EDW_NAGIOS_SUPPORT.TableSwap(stagetablename, tablename);
        SET sql1="CREATE OR REPLACE TABLE "||tablename||" AS SELECT * FROM "||stagetablename||"";
        EXECUTE IMMEDIATE sql1;
        SET log_message = 'Completed Full load';
      ELSE
        IF trace_flag = 1 THEN
			    --select 'Calling: EDW_NAGIOS_SUPPORT.ManagePartitions_DateID';
        END IF;
        --CALL EDW_NAGIOS_SUPPORT.ManagePartitions_DateID(tablename, 'DayID:Month');
        IF trace_flag = 1 THEN
          --select 'Calling: EDW_NAGIOS_SUPPORT.PartitionSwitch_Range';
        END IF;
        --Commented PartitionSwitch_Range, implemented logic below
        --CALL EDW_NAGIOS_SUPPORT.PartitionSwitch_Range(stagetablename, tablename, identifyingcolumns, CAST(NULL as STRING));
        -- Logic for PartitionSwitch_Range
        -- Dropping Records From Main Table To Avoid Duplicates
        SET sql1 = concat("Delete From ", tablename , " where ", identifyingcolumns ," In ( Select ", identifyingcolumns , " from ",stagetablename , " )" );
        EXECUTE IMMEDIATE sql1;
      
        -- Inserting NEW Records from Stage to Main Table
        SET sql1 = concat("Insert Into  ", tablename , " Select * from ",stagetablename );
        EXECUTE IMMEDIATE sql1;
      END IF;
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(-1 as STRING));
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        SET log_message = concat('*** Error in EDW_NAGIOS.Fact_Host_Service_Event_Load: ', error_message);
        CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message,'E', CAST(NULL as INT64), CAST(-1 as STRING));
        RAISE USING MESSAGE = error_message; -- Rethrow the error!
      END;
    END;
/*

--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Fact_Host_Service_Event_Load 0
SELECT TOP 100 * FROM Utility.ProcessLog ORDER BY 1 DESC

SELECT * FROM Utility.LoadProcessControl
SELECT TOP 10000 * FROM dbo.Fact_Host_Service_Event

--DROP TABLE dbo.Fact_Host_Service_Event
--TRUNCATE TABLE dbo.Fact_Host_Service_Event
--TRUNCATE TABLE Utility.ProcessLog

--===============================================================================================================
-- DYNAMIC SQL 
--===============================================================================================================

IF OBJECT_ID('dbo.Fact_Host_Service_Event_NEW','U') IS NOT NULL DROP TABLE dbo.Fact_Host_Service_Event_NEW
CREATE TABLE dbo.Fact_Host_Service_Event_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(Host_Service_Event_ID), PARTITION (Event_Day_ID RANGE RIGHT FOR VALUES (20210301,20210401,20210501,20210601,20210701,20210801,20210901,20211001,20211101,20211201))) AS
SELECT 
		ISNULL(CAST(S.Host_Service_Event_ID AS BIGINT), 0) AS Host_Service_Event_ID
		, ISNULL(CAST(S.Nagios_Object_ID AS INT), 0) AS Nagios_Object_ID
		, ISNULL(CAST(S.Event_Date AS DATETIME), '1900-01-01') AS Event_Date
		, ISNULL(CAST(CONVERT(VARCHAR(8), S.Event_Date,112) AS INT),-1) AS Event_Day_ID
		, ISNULL(CAST(DATEDIFF(SECOND,CAST(S.Event_Date AS DATE), S.Event_Date) AS INT),-1) AS Event_Time_ID
		, ISNULL(CAST(ST.State_ID AS SMALLINT), 0) AS Host_Service_State_ID	
		, CAST(S.Metric_Count AS TINYINT) AS Metric_Count
		, CAST(S.LND_UpdateDate AS DATETIME2(3)) AS LND_UpdateDate
		, CAST(SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate
FROM	Stage.Host_Service_Event S
JOIN	dbo.Dim_State ST 
		ON S.Host_Service_State = ST.State_value 
		AND ST.Object_Type = CASE WHEN S.Service IS NULL THEN 'Host' ELSE 'Service' END 	
OPTION (LABEL = 'Load dbo.Fact_Host_Service_Event_NEW');

CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_001 ON dbo.Fact_Host_Service_Event_NEW(Nagios_Object_ID)
CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_002 ON dbo.Fact_Host_Service_Event_NEW(Event_Day_ID)
CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_003 ON dbo.Fact_Host_Service_Event_NEW(Event_Time_ID)
CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_004 ON dbo.Fact_Host_Service_Event_NEW(Event_Date)
CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_005 ON dbo.Fact_Host_Service_Event_NEW(Host_Service_State_ID)
CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_006 ON dbo.Fact_Host_Service_Event_NEW(Metric_Count)
CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_101 ON dbo.Fact_Host_Service_Event_NEW(LND_UpdateDate)
CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_102 ON dbo.Fact_Host_Service_Event_NEW(EDW_UpdateDate)

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================
;WITH CTE AS
(
	SELECT  
		CAST(pf.boundary_value_on_right AS INT) AS boundary_value_on_right,
		CASE WHEN CAST(pf.boundary_value_on_right AS INT) = 1 
			THEN CASE WHEN rv.[value] IS NULL THEN 1 ELSE CAST(p.partition_number AS INT) + 1 END
			ELSE CAST(p.partition_number AS INT)
		END AS PartitionNum,
		CASE WHEN CAST(pf.boundary_value_on_right AS INT) = 1 
			THEN ISNULL(CAST(rv.[value] AS BIGINT),CAST(0 AS BIGINT))
			ELSE ISNULL(CAST(rv.[value] AS BIGINT),CAST(9223372036854775800 AS BIGINT))
		END AS NumberValueFrom 
	FROM      sys.schemas s
	JOIN      sys.Tables t                  ON t.[schema_id]      = s.[schema_id]
	JOIN      sys.partitions p              ON p.[object_id]      = t.[object_id] AND p.[index_id] <=1
	JOIN      sys.indexes i                 ON i.[object_id]      = p.[object_id] AND i.[index_id] = p.[index_id]
	JOIN      sys.data_spaces ds            ON ds.[data_space_id] = i.[data_space_id]
	LEFT JOIN sys.partition_schemes ps      ON ps.[data_space_id] = ds.[data_space_id]
	LEFT JOIN sys.partition_functions pf    ON pf.[function_id]   = ps.[function_id]
	LEFT JOIN sys.partition_range_values rv ON rv.[function_id]   = pf.[function_id] AND rv.[boundary_id] = p.[partition_number]
	WHERE s.[name] = 'dbo' AND t.[name] = 'Fact_Host_Service_Event'
)
SELECT
	PartitionNum,
	CASE WHEN CAST(boundary_value_on_right AS INT) = 1 
		THEN ISNULL(NumberValueFrom,0)
		ELSE ISNULL(LAG(NumberValueFrom) OVER (ORDER BY PartitionNum) + 1,CAST(0 AS BIGINT))
	END AS NumberValueFrom, 
	CASE WHEN CAST(boundary_value_on_right AS INT) = 1 
		THEN ISNULL(LEAD(NumberValueFrom) OVER (ORDER BY PartitionNum) - 1, CAST(9223372036854775800 AS BIGINT))
		ELSE ISNULL(NumberValueFrom,CAST(9223372036854775800 AS BIGINT))
	END AS NumberValueTo 
FROM CTE

*/

  END;