CREATE OR REPLACE PROCEDURE EDW_NAGIOS.Fact_Host_Service_Event_Metric_Load(isfullload INT64)
BEGIN
    /*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.dbo.Fact_Host_Service_Event_Metric_Load

The following 3 procs go together in tight sequence, as if all in one proc:
1. dbo.Dim_Host_Service_Metric_Load
2. dbo.Fact_Host_Service_Event_Load
3. dbo.Fact_Host_Service_Event_Metric_Load
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0039845	Shankar		2021-03-26	New!
CHG0039980  Shankar	    2021-11-15  Moved the logic to set load control date for next run to Metric Summary table load.
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
SELECT 'LoadProcessControl Before' SRC, * FROM Utility.LoadProcessControl
EXEC dbo.Fact_Host_Service_Event_Metric_Load 1
SELECT * FROM Utility.ProcessLog ORDER BY 1 DESC
SELECT 'LoadProcessControl After' SRC, * FROM Utility.LoadProcessControl

SELECT TOP 1000 * FROM dbo.Fact_Host_Service_Event_Metric ORDER BY 1 DESC
###################################################################################################################
*/

		-- DEBUG
		-- DECLARE @IsFullLoad BIT = 0

    DECLARE tablename STRING DEFAULT 'EDW_NAGIOS.Fact_Host_Service_Event_Metric';
    DECLARE trace_flag INT64 DEFAULT 1; -- Testing
    DECLARE firstpartitionid INT64 DEFAULT 202103;
    DECLARE lastpartitionid INT64;
    DECLARE partition_ranges STRING;
    DECLARE createtablewith STRING;
    DECLARE log_message STRING;
    DECLARE identifyingcolumns STRING DEFAULT 'Host_Service_Event_ID';
    DECLARE last_updated_date DATETIME;
    DECLARE log_source STRING DEFAULT 'EDW_NAGIOS.Fact_Host_Service_Event_Metric_Load';
    DECLARE log_start_date DATETIME;
    DECLARE stagetablename STRING DEFAULT 'EDW_NAGIOS.Fact_Host_Service_Event_Metric_NEW';
    DECLARE sql STRING;
    DECLARE sql1 STRING;
    BEGIN
      SET log_start_date = current_datetime('America/Chicago');
      
      SET lastpartitionid = CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_add(last_day(date_add(current_datetime(),interval 1 MONTH)), interval 1 DAY)) as STRING), 1, 6) as INT64);
      IF (SELECT count(1) FROM EDW_NAGIOS.INFORMATION_SCHEMA.TABLES WHERE LOWER(table_name)=lower(SUBSTR(tablename,STRPOS(tablename,'.')+1))) =0 THEN 
        SET isfullload = 1;
      END IF;
      IF isfullload = 1 THEN
        -- IF trace_flag = 1 THEN
        --   SELECT 'Calling: Utility.Get_PartitionDayIDRange_String from ' + CAST(@FirstPartitionID AS VARCHAR(10))+ ' till ' + CAST(@LastPartitionID AS VARCHAR(10))
        -- END IF;
        --CALL utility.get_partitiondayidrange_string(substr(CAST(firstpartitionid as STRING), 1, 10), substr(CAST(lastpartitionid as STRING), 1, 10), partition_ranges);
        -- SET createtablewith = concat('(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(Host_Service_Event_ID), PARTITION (Event_Day_ID RANGE RIGHT FOR VALUES (', partition_ranges, ')))');
        SET createtablewith = concat(' cluster by ',identifyingcolumns);
        IF trace_flag = 1 THEN
          SELECT CreateTableWith;
        END IF;
        SET log_message = 'Started Full load from the data populated by EDW_NAGIOS.Dim_Host_Service_Metric_Load in EDW_NAGIOS_Stage.Host_Service_Event';
      ELSE
        --SET createtablewith = concat('(CLUSTERED INDEX (', identifyingcolumns, ' DESC), DISTRIBUTION = HASH(Host_Service_Event_ID))');
        SET createtablewith = concat(' cluster by ',identifyingcolumns);
        IF trace_flag = 1 THEN
          SELECT CreateTableWith;
        END IF;
        IF trace_flag = 1 THEN
          SELECT 'Calling: Utility.Get_UpdatedDate for "Nagios Host_Service_Event Dim & Fact Tables"';
        END IF;
        CALL EDW_NAGIOS_SUPPORT.Get_UpdatedDate('Nagios Host_Service_Event Dim & Fact Tables', last_updated_date);
        SET log_message = concat('Started Incremental load with parsed event metric data available in EDW_NAGIOS_Stage.Host_Service_Metric_Data starting from ', substr(CAST(last_updated_date as STRING), 1, 25));
      END IF;
      IF trace_flag = 1 THEN
        SELECT Log_Message;
      END IF;
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      
		  --======================================================================
		  --:: dbo.Fact_Host_Service_Event_Metric
		  --======================================================================
      SET sql = concat("""CREATE OR REPLACE TABLE """,stagetablename, CreateTableWith ,
                        """ AS 
                        SELECT coalesce(CAST(s.host_service_event_id as INT64), 0) AS host_service_event_id,
                        coalesce(CAST(m.host_service_metric_id as INT64), -1) AS host_service_metric_id, 
                        coalesce(CAST(concat('20', left(left(CAST(s.host_service_event_id as STRING), 12), 6)) as INT64), -1) AS event_day_id,
                        COALESCE(DATETIME_DIFF(PARSE_DATETIME('%y%m%d %H:%M:%S',CONCAT(SUBSTR(CAST(S.Host_Service_Event_ID AS STRING), 1, 6), ' ', SUBSTR(CAST(S.Host_Service_Event_ID AS STRING), 7, 2), ':', SUBSTR(CAST(S.Host_Service_Event_ID AS STRING), 9, 2), ':', SUBSTR(CAST(S.Host_Service_Event_ID AS STRING), 11, 2))),CAST(PARSE_DATETIME('%y%m%d %H:%M:%S',CONCAT(SUBSTR(CAST(S.Host_Service_Event_ID AS STRING), 1, 6), ' ', SUBSTR(CAST(S.Host_Service_Event_ID AS STRING), 7, 2), ':', SUBSTR(CAST(S.Host_Service_Event_ID AS STRING), 9, 2), ':', SUBSTR(CAST(S.Host_Service_Event_ID AS STRING), 11, 2))) AS DATE),SECOND),-1) AS event_time_id,
                        coalesce(CAST(st.state_id as INT64), -1) AS metric_state_id,
                        coalesce(PARSE_DATETIME('%y%m%d %H:%M:%S',CONCAT(SUBSTR(CAST(S.Host_Service_Event_ID AS STRING), 1, 6), ' ', SUBSTR(CAST(S.Host_Service_Event_ID AS STRING), 7, 2), ':', SUBSTR(CAST(S.Host_Service_Event_ID AS STRING), 9, 2), ':', SUBSTR(CAST(S.Host_Service_Event_ID AS STRING), 11, 2))),datetime '1900-01-01') AS event_date,
                        coalesce(CAST(s.metric_index as INT64), -1) AS metric_index,
                        CAST(s.metric_value as NUMERIC) AS metric_value,
                        CAST(s.metric_unit as STRING) AS metric_unit,
                        CAST(s.warning_value as NUMERIC) AS warning_value,
                        CAST(s.critical_value as NUMERIC) AS critical_value,
                        CAST(s.min_value as NUMERIC) AS min_value,
                        CAST(s.max_value as NUMERIC) AS max_value,
                        CAST(s.percent_warning as NUMERIC) AS percent_warning,
                        CAST(s.percent_critical as NUMERIC) AS percent_critical,
                        CAST(s.percent_max as NUMERIC) AS percent_max,
                        CAST(s.lnd_updatedate as DATETIME) AS lnd_updatedate,
                        current_datetime() AS edw_updatedate 
                        FROM EDW_NAGIOS_STAGE.Host_Service_Metric_Data AS s
                        INNER JOIN EDW_NAGIOS.Dim_State AS st ON s.metric_state = st.state_value AND st.object_type = CASE WHEN s.service IS NULL THEN 'Host' ELSE 'Service' END 
                        INNER JOIN EDW_NAGIOS.Dim_Host_Service_Metric AS m ON s.nagios_object_id = m.nagios_object_id AND s.metric_name = m.metric_name
                        """
                        );
      EXECUTE IMMEDIATE sql;
      SET log_message = concat('Loaded ', stagetablename);
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, sql);
      IF isfullload = 1 THEN
        -- CREATE STATISTICS Not Required in BQ 
        -- EXECUTE IMMEDIATE sql;
        -- TableSwap is Not Required using  Create or Replace Table
        -- CALL EDW_NAGIOS_SUPPORT.TableSwap(stagetablename, tablename);

        SET sql1="CREATE OR REPLACE TABLE "||tablename||" AS SELECT * FROM "||stagetablename||"";
        EXECUTE IMMEDIATE sql1;
        SET log_message = 'Completed Full load';
      ELSE
        IF trace_flag = 1 THEN
          -- SELECT 'Calling: Utility.ManagePartitions_DateID'
        END IF;
        -- CALL EDW_NAGIOS_SUPPORT.ManagePartitions_DateID(tablename, 'DayID:Month');
        IF trace_flag = 1 THEN
          -- SELECT 'Calling: Utility.PartitionSwitch_Range'
        END IF;
        -- Commented PartitionSwitch_Range, implemented logic below
        -- CALL EDW_NAGIOS_SUPPORT.PartitionSwitch_Range(stagetablename, tablename, identifyingcolumns, CAST(NULL as STRING));
        -- Logic for PartitionSwitch_Range
        -- Dropping Records From Main Table To Avoid Duplicates
        SET sql1 = concat("Delete From ", tablename , " where ",identifyingcolumns," In ( Select ",identifyingcolumns," from ",stagetablename , " )" );
        EXECUTE IMMEDIATE sql1;
        
        -- Inserting NEW Records from Stage to Main Table
        SET sql1 = concat("Insert Into  ", tablename , " Select * from ",stagetablename );
        EXECUTE IMMEDIATE sql1;

        -- UPDATE STATISTICS Not Required in BQ 
        -- SET sql = concat('UPDATE STATISTICS  ', tablename);
        -- EXECUTE IMMEDIATE sql;
        SET log_message = concat('Completed Incremental load from ', substr(CAST(last_updated_date as STRING), 1, 25));
      END IF;
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        SET log_message = concat('*** Error in dbo.Fact_Host_Service_Event_Metric_Load: ', error_message);
        CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = error_message;  -- Rethrow the error!
      END;
    END;
    
/*
SELECT 'LoadProcessControl Before' SRC, * FROM Utility.LoadProcessControl
EXEC dbo.Fact_Host_Service_Event_Metric_Load 1
SELECT * FROM Utility.ProcessLog ORDER BY 1 DESC
SELECT 'LoadProcessControl After' SRC, * FROM Utility.LoadProcessControl

SELECT TOP 1000 * FROM dbo.Fact_Host_Service_Event_Metric ORDER BY 1 DESC

--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================

SELECT 'LoadProcessControl Before' SRC, * FROM Utility.LoadProcessControl
EXEC dbo.Fact_Host_Service_Event_Metric_Load 0
SELECT * FROM Utility.ProcessLog ORDER BY 1 DESC
SELECT 'LoadProcessControl After' SRC, * FROM Utility.LoadProcessControl
--:: Event Metric fact table
SELECT	TOP 10000 f.Host_Service_Event_ID, f.Event_Date, M.*, F.* 
FROM	dbo.Fact_Host_Service_Event_Metric F
JOIN	dbo.Dim_Host_Service_Metric M 
		ON F.Host_Service_Metric_ID = M.Host_Service_Metric_ID		
WHERE	M.Host_Facility = 'DNT'
		AND M.Host_Type = 'UPS'
		AND M.Service = 'UPS Temperature'
		AND F.Event_Date > '9/1/2019'
ORDER BY F.Host_Service_Event_ID, Metric_Suffix

SELECT	TOP 10000 FM.Host_Service_Event_ID, FM.Event_Date, FE.Nagios_Object_ID, M.Host_type, M.Host, M.Service, ES.State_Desc Event_State, MS.State_Desc Metric_State, M.*, FM.* 
FROM	dbo.Fact_Host_Service_Event FE 
JOIN	dbo.Fact_Host_Service_Event_Metric FM
		ON FE.Host_Service_Event_ID = FM.Host_Service_Event_ID
JOIN	dbo.Dim_Host_Service_Metric M 
		ON FM.Host_Service_Metric_ID = M.Host_Service_Metric_ID
JOIN	dbo.Dim_State ES
		ON FE.Host_Service_State_ID = ES.State_ID
JOIN	dbo.Dim_State MS
		ON FM.Metric_State_ID = MS.State_ID
WHERE	M.Host_Type = 'UPS'  
--AND		FM.Event_Day_ID = 20190904
AND		M.Host = '360-DEBLN-1-UPS'
ORDER BY FM.Host_Service_Event_ID, Metric_Suffix

--===============================================================================================================
-- DYNAMIC SQL OUTPUT
--===============================================================================================================

IF OBJECT_ID('dbo.Fact_Host_Service_Event_Metric_NEW','U') IS NOT NULL DROP TABLE dbo.Fact_Host_Service_Event_Metric_NEW
CREATE TABLE dbo.Fact_Host_Service_Event_Metric_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(Host_Service_Event_ID), PARTITION (Event_Day_ID RANGE RIGHT FOR VALUES (20210301,20210401,20210501,20210601,20210701,20210801,20210901,20211001,20211101,20211201))) AS
SELECT	 
		ISNULL(CAST(S.Host_Service_Event_ID AS BIGINT), 0) AS Host_Service_Event_ID
		, ISNULL(CAST(M.Host_Service_Metric_ID AS INT), -1) AS Host_Service_Metric_ID	
		, ISNULL(CAST('20'+LEFT(LEFT(CONVERT(VARCHAR,S.Host_Service_Event_ID),12),6) AS INT),-1) AS Event_Day_ID
		, ISNULL(CAST(DATEDIFF(SECOND,CONVERT(DATE,STUFF(STUFF(STUFF(LEFT(CONVERT(VARCHAR,S.Host_Service_Event_ID),12),11,0,':'),9,0,':'),7,0,' ')),CONVERT(DATETIME,STUFF(STUFF(STUFF(LEFT(CONVERT(VARCHAR,S.Host_Service_Event_ID),12),11,0,':'),9,0,':'),7,0,' '))) AS INT),-1) AS Event_Time_ID
		, ISNULL(CAST(ST.State_ID AS SMALLINT), -1) AS Metric_State_ID	
		, ISNULL(CAST(STUFF(STUFF(STUFF(LEFT(CONVERT(VARCHAR,S.Host_Service_Event_ID),12),11,0,':'),9,0,':'),7,0,' ') AS DATETIME), '1900-01-01') AS Event_Date
		, ISNULL(CAST(S.Metric_Index AS SMALLINT), -1) AS Metric_Index	
		, CAST(S.Metric_Value AS DECIMAL(19,8)) AS Metric_Value
		, CAST(S.Metric_Unit AS VARCHAR(5)) AS Metric_Unit
		, CAST(S.Warning_Value AS DECIMAL(19,8)) AS Warning_Value
		, CAST(S.Critical_Value AS DECIMAL(19,8)) AS Critical_Value
		, CAST(S.Min_Value AS DECIMAL(19,8)) AS Min_Value
		, CAST(S.Max_Value AS DECIMAL(19,8)) AS Max_Value
		, CAST(S.Percent_Warning AS DECIMAL(19,2)) AS Percent_Warning
		, CAST(S.Percent_Critical AS DECIMAL(19,2)) AS Percent_Critical
		, CAST(S.Percent_Max AS DECIMAL(19,2)) AS Percent_Max
		, CAST(S.LND_UpdateDate AS DATETIME2(3)) AS LND_UpdateDate
		, CAST(SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate

FROM	Stage.Host_Service_Metric_Data S 
JOIN	dbo.Dim_State ST 
		ON S.Metric_State = ST.State_value 
		AND ST.Object_Type = CASE WHEN S.Service IS NULL THEN 'Host' ELSE 'Service' END 	
JOIN	dbo.Dim_Host_Service_Metric M
		ON S.Nagios_Object_ID = M.Nagios_Object_ID
		AND S.Metric_Name = M.Metric_Name
OPTION (LABEL = 'Load dbo.Fact_Host_Service_Event_Metric_NEW');

	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_001 ON dbo.Fact_Host_Service_Event_Metric_NEW(Host_Service_Metric_ID)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_002 ON dbo.Fact_Host_Service_Event_Metric_NEW(Event_Day_ID)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_003 ON dbo.Fact_Host_Service_Event_Metric_NEW(Event_Time_ID)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_004 ON dbo.Fact_Host_Service_Event_Metric_NEW(Event_Date)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_006 ON dbo.Fact_Host_Service_Event_Metric_NEW(Metric_State_ID)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_007 ON dbo.Fact_Host_Service_Event_Metric_NEW(Metric_Index)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_008 ON dbo.Fact_Host_Service_Event_Metric_NEW(Metric_Value)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_009 ON dbo.Fact_Host_Service_Event_Metric_NEW(Metric_Unit)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_010 ON dbo.Fact_Host_Service_Event_Metric_NEW(Host_Service_Metric_ID,Event_Day_ID)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_011 ON dbo.Fact_Host_Service_Event_Metric_NEW(LND_UpdateDate)
	CREATE STATISTICS STATS_dbo_Fact_Host_Service_Event_Metric_012 ON dbo.Fact_Host_Service_Event_Metric_NEW(EDW_UpdateDate)


--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================

*/


  END;