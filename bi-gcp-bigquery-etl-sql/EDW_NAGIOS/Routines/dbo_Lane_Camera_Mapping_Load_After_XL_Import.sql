CREATE OR REPLACE PROCEDURE `EDW_NAGIOS.Lane_Camera_Mapping_Load_After_Xl_Import`()
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Run after importing Lane_Camera_Mapping XL data into Ref.Lane_Camera_Mapping.
1. Auto fill Camera for a Lane Controller Host if mapping is found for the redundant Host.
•	VES Controller ends with AA or it’s redundant Host ends with BB with only one of them being active at a given time; 
•	Lane Controller ends with A  or it’s redundant Host ends with B with only one of them being active at a given time. 
•	The Camera mapping is identical for both main host and redundant host for the same metric suffix.
2. Update EDW_NAGIOS.Dim_Host_Service_Metric to reflect the latest data. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0039845	Shankar		2021-10-21	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC EDW_NAGIOS.Lane_Camera_Mapping_Load_After_XL_Import
SELECT 'Bkup.Lane_Camera_Mapping' TableName, * FROM Bkup.Lane_Camera_Mapping ORDER BY 2,3
SELECT 'Ref.Lane_Camera_Mapping' TableName, * FROM Ref.Lane_Camera_Mapping ORDER BY 2,3
SELECT 'EDW_NAGIOS.Dim_Host_Service_Metric' TableName, * FROM EDW_NAGIOS.Dim_Host_Service_Metric ORDER BY LND_UpdateDate DESC, Host, Service, Metric_Name
SELECT * FROM EDW_NAGIOS_SUPPORT.ProcessLog WHERE LogSource LIKE '%Lane_Camera_Mapping_Load_After_XL_Import%' ORDER BY 1 DESC
###################################################################################################################
*/
BEGIN
    --:: Debug
	-- DECLARE @IsFullLoad BIT = 1
    DECLARE log_source STRING DEFAULT 'EDW_NAGIOS.Lane_Camera_Mapping_Load_After_XL_Import';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 1;
    BEGIN
        DECLARE row_count INT64;
        SET log_start_date = current_datetime('America/Chicago');
        CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, 'Started EDW_NAGIOS.Lane_Camera_Mapping_Load_After_XL_Import', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
        --======================================================================
            -- Insert the missing Camera mapping for a Controller pairs
        --======================================================================
		
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
                EDW_NAGIOS_SUPPORT.Lane_Camera_Mapping AS n
            WHERE NOT EXISTS (
                SELECT
                    1
                FROM
                    EDW_NAGIOS_SUPPORT.Lane_Camera_Mapping AS s
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
                    EDW_NAGIOS.Dim_Host_Service
                WHERE object_type = 'Host'
            )
        ;
        SET log_message = 'Inserted the missing Camera mapping for a Controller pair into EDW_NAGIOS_SUPPORT.Lane_Camera_Mapping';
        CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
        
        --======================================================================
        -- Reload dbo.Dim_Host_Service_Metric
        --======================================================================
		
        CREATE OR REPLACE TABLE EDW_NAGIOS.Dim_Host_Service_Metric_NEW CLUSTER BY Host_Service_Metric_ID
            -- Existing rows with the latest data coming from EDW_NAGIOS.Dim_Host_Service, Ref.Lane_Camera_Mapping tables
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
                LEFT OUTER JOIN EDW_NAGIOS_SUPPORT.Lane_Camera_Mapping AS ht ON hs.host = ht.controller
                AND d.metric_suffix = ht.metric_suffix
        ;
        SET log_message = 'Loaded EDW_NAGIOS.Dim_Host_Service_Metric_NEW';
        CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
    
        --Table swap!
        --   CALL EDW_NAGIOS_SUPPORT.tableswap('EDW_NAGIOS.Dim_Host_Service_Metric_NEW', 'EDW_NAGIOS.Dim_Host_Service_Metric');
        CREATE OR REPLACE TABLE EDW_NAGIOS.Dim_Host_Service_Metric CLUSTER BY Host_Service_Metric_ID as SELECT * from  EDW_NAGIOS.Dim_Host_Service_Metric_NEW;

        SET log_message = 'Completed EDW_NAGIOS.Dim_Host_Service_Metric reload';
        CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
        SET log_message = 'Completed EDW_NAGIOS.Lane_Camera_Mapping_Load_After_XL_Import';
        CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
        IF trace_flag = 1 THEN
            -- SELECT
            --     'Bkup.Lane_Camera_Mapping' AS tablename,
            --     *
            -- FROM
            --     EDW_NAGIOS.bkup.lane_camera_mapping
            -- ORDER BY
            -- 2,
            -- 3
            -- ;
            SELECT
                ' EDW_NAGIOS_SUPPORT.Lane_Camera_Mapping' AS tablename,
                Lane_Camera_Mapping.*
            FROM
                EDW_NAGIOS_SUPPORT.Lane_Camera_Mapping
            ORDER BY
            2,
            3
            ;
            SELECT
                'EDW_NAGIOS.Dim_Host_Service_Metric' AS tablename,
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
      BEGIN
        DECLARE error_message STRING DEFAULT concat('*** Error in EDW_NAGIOS.Lane_Camera_Mapping_Load_After_XL_Import: ', @@error.message);
        CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = '';-- Rethrow the error!
      END;
    END;

/*

--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================

EXEC dbo.Lane_Camera_Mapping_Load_After_XL_Import
SELECT 'Bkup.Lane_Camera_Mapping' TableName, * FROM Bkup.Lane_Camera_Mapping ORDER BY 2,3
SELECT 'Ref.Lane_Camera_Mapping' TableName, * FROM Ref.Lane_Camera_Mapping ORDER BY 2,3
SELECT 'dbo.Dim_Host_Service_Metric' TableName, * FROM dbo.Dim_Host_Service_Metric ORDER BY LND_UpdateDate DESC, Host, Service, Metric_Name
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Lane_Camera_Mapping_Load_After_XL_Import%' ORDER BY 1 DESC

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