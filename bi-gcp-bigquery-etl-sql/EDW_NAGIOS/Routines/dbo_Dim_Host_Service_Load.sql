CREATE OR REPLACE PROCEDURE `EDW_NAGIOS.Dim_Host_Service_Load`()
BEGIN
  /*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_Host_Service. This is the central dimension in Nagios data model for Host devices and Services.
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0039845	Shankar		2021-03-26	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_Host_Service_Load 
SELECT * FROM dbo.Dim_Host_Service ORDER BY 2,1
SELECT * FROM Utility.ProcessLog ORDER BY 1 DESC
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_NAGIOS.Dim_Host_Service_Load';
    DECLARE log_start_date DATETIME;
    DECLARE trace_flag INT64 DEFAULT 1;
    DECLARE log_message STRING;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);
    --=============================================================================================================
    -- Load dbo.Dim_Host_Service
    --=============================================================================================================

    --:: Get #Dim_Host_Stage data 
      CREATE OR REPLACE TEMPORARY TABLE _SESSION.Dim_Host_Stage
        AS
          WITH Dim_Host_CTE AS (
            SELECT
                ho.object_id AS host_object_id,
                ho.name1 AS host,
                CASE
                  WHEN ho.name1 LIKE '%UPS%' THEN 'UPS'
                  WHEN ho.name1 LIKE 'CCTV%'
                   OR ho.name1 LIKE 'NATE%' THEN 'CCTV'
                  WHEN ho.name1 LIKE '%PDU%' THEN 'PDU'
                  WHEN ho.name1 LIKE '%AVI%' THEN 'AVI'
                  WHEN ho.name1 LIKE '%GTWY%' THEN 'GateWay'
                  WHEN ho.name1 LIKE '%IOC' THEN 'IOC'
                  WHEN hg.alias LIKE '%tolling_cameras%' THEN 'Tolling Camera'
                  WHEN hg.alias LIKE 'VES-%' THEN 'VES Controller'
                  WHEN hg.alias LIKE 'LC-%' THEN 'Lane Controller'
                  WHEN hg.alias LIKE 'cctv%' THEN 'CCTV'
                  --WHEN ho.name1 LIKE '%HVAC%'				THEN 'HVAC' -- not required, per Raymond on 10/15/2021
							--WHEN ho.name1 LIKE '%WVTRNX%'			THEN 'Wavetronix' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE 'Data Loggers%'		THEN 'Data Logger' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE 'data_logger_cameras%' THEN 'DLOG Camera' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE 'SPEED%'				THEN 'SpeedMap LC' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE '%SERVERS%'			THEN 'Server' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE '%gate%' AND hg.alias NOT LIKE '%CCTV%' THEN 'Gate' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE '%fireeye%'			THEN 'Fire Eye' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE '%lonestar%'			THEN 'Lonestar' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE 'infrastructure collectors'	THEN 'Infrastructure Collectors' -- not required, per Raymond on 10/15/2021
							--WHEN hg.alias LIKE '%testlane%'			THEN 'Unknown' -- not required, per Raymond on 10/15/2021 (used to be under Lane Controller)
							--ELSE hg.alias -- not required, per Raymond on 10/19. maps to all other host groups
                END AS Host_Type,
                CASE
                  WHEN ho.name1 LIKE '%SRT%'
                   OR ho.name1 LIKE 'CCTV ITS S%'
                   OR ho.name1 LIKE 'CCTV S%'
                   OR ho.name1 LIKE 'ITS S%' THEN 'SRT'
                  WHEN ho.name1 LIKE '%360%'
                   OR ho.name1 LIKE 'CCTV ITS T%'
                   OR ho.name1 LIKE 'CCTV T%' THEN '360'
                  WHEN ho.name1 LIKE '%PGBT%'
                   OR ho.name1 LIKE '%PGBW%'
                   OR ho.name1 LIKE 'CCTV%ITS P%'
                   OR ho.name1 LIKE 'CCTV P%' THEN 'PGBT'
                  WHEN ho.name1 LIKE '%AATT%' THEN 'AATT'
                  WHEN ho.name1 LIKE '%PMC%'
                   OR ho.name1 LIKE '%FOC%'
                   OR ho.name1 LIKE 'CCTV GE%'
                   OR ho.name1 LIKE 'GE %' THEN 'Facilities'
                  WHEN ho.name1 LIKE '%CTP%'
                   OR ho.name1 LIKE 'CCTV C%' THEN 'CTP'
                  WHEN ho.name1 LIKE '%DNT%'
                   OR ho.name1 LIKE 'CCTV D%'
                   OR ho.name1 LIKE 'CCTV%ITS D%' THEN 'DNT'
                  WHEN ho.name1 LIKE '%LLTB%' THEN 'LLTB'
                  WHEN ho.name1 LIKE '%MCLB%' THEN 'MCLB'
                  ELSE 'Unknown'
                END AS Host_Facility,
                reverse(substr(reverse(CASE
                  WHEN CASE
                    WHEN strpos(substr(ho.name1, strpos(ho.name1, '-')), '-') = 0 THEN 0
                    ELSE strpos(substr(ho.name1, strpos(ho.name1, '-')), '-') + (CASE
                      WHEN strpos(ho.name1, '-') < 1 THEN 1
                      ELSE strpos(ho.name1, '-')
                    END - 1)
                  END > 1
                   AND ho.name1 NOT LIKE '%speed%' THEN substr(ho.name1, 1, CASE
                    WHEN 1 < 1 THEN greatest(1 + (CASE
                      WHEN strpos(substr(ho.name1, strpos(ho.name1, '-') + 1), '-') = 0 THEN 0
                      ELSE strpos(substr(ho.name1, strpos(ho.name1, '-') + 1), '-') + (CASE
                        WHEN strpos(ho.name1, '-') + 1 < 1 THEN 1
                        ELSE strpos(ho.name1, '-') + 1
                      END - 1)
                    END - 1), 0)
                    ELSE CASE
                      WHEN strpos(substr(ho.name1, strpos(ho.name1, '-') + 1), '-') = 0 THEN 0
                      ELSE strpos(substr(ho.name1, strpos(ho.name1, '-') + 1), '-') + (CASE
                        WHEN strpos(ho.name1, '-') + 1 < 1 THEN 1
                        ELSE strpos(ho.name1, '-') + 1
                      END - 1)
                    END
                  END)
                END), 2, 50)) AS host_plaza,
                p.plazalatitude AS plaza_latitude,
                p.plazalongitude AS plaza_longitude,
                ho.is_active AS is_active,
                coalesce(h.lnd_updatedate, ho.lnd_updatedate) AS lnd_updatedate
              FROM
                LND_NAGIOS.nagios_objects AS ho
                LEFT OUTER JOIN LND_NAGIOS.nagios_hosts AS h ON ho.object_id = h.host_object_id
                LEFT OUTER JOIN LND_NAGIOS.nagios_hostgroup_members AS hgm ON h.host_object_id = hgm.host_object_id
                LEFT OUTER JOIN LND_NAGIOS.nagios_hostgroups AS hg ON hgm.hostgroup_id = hg.hostgroup_id
                LEFT OUTER JOIN EDW_TRIPS.Dim_Plaza AS p ON p.facilitycode = CASE
                  WHEN strpos(ho.name1, '-') > 1 THEN substr(ho.name1, 1, CASE
                    WHEN 1 < 1 THEN greatest(1 + (coalesce(nullif(strpos(ho.name1, '-') - 1, -1), 0) - 1), 0)
                    ELSE coalesce(nullif(strpos(ho.name1, '-') - 1, -1), 0)
                  END)
                END
                 AND p.plazacode = CASE
                  WHEN CASE
                    WHEN strpos(substr(ho.name1, strpos(ho.name1, '-')), '-') = 0 THEN 0
                    ELSE strpos(substr(ho.name1, strpos(ho.name1, '-')), '-') + (CASE
                      WHEN strpos(ho.name1, '-') < 1 THEN 1
                      ELSE strpos(ho.name1, '-')
                    END - 1)
                  END > 1 THEN substr(substr(ho.name1, greatest(strpos(ho.name1, '-') + 1, 0), CASE
                    WHEN strpos(ho.name1, '-') + 1 < 1 THEN greatest(strpos(ho.name1, '-') + 1 + (50 - 1), 0)
                    ELSE 50
                  END), 1, CASE
                    WHEN 1 < 1 THEN greatest(1 + (coalesce(nullif(strpos(substr(ho.name1, greatest(strpos(ho.name1, '-') + 1, 0), CASE
                      WHEN strpos(ho.name1, '-') + 1 < 1 THEN greatest(strpos(ho.name1, '-') + 1 + (50 - 1), 0)
                      ELSE 50
                    END), '-') - 1, -1), 0) - 1), 0)
                    ELSE coalesce(nullif(strpos(substr(ho.name1, greatest(strpos(ho.name1, '-') + 1, 0), CASE
                      WHEN strpos(ho.name1, '-') + 1 < 1 THEN greatest(strpos(ho.name1, '-') + 1 + (50 - 1), 0)
                      ELSE 50
                    END), '-') - 1, -1), 0)
                  END)
                END
              WHERE ho.objecttype_id = 1
              
          )
          SELECT
              h.host_object_id,
              h.host,
              coalesce(nullif(h.host_type, ''), 'Unknown') AS host_type,
              h.host_facility,
              coalesce(nullif(h.host_plaza, ''), 'Unknown') AS host_plaza,
              h.plaza_latitude,
              h.plaza_longitude,
              h.is_active,
              h.lnd_updatedate
            FROM
              (
                SELECT
                    Dim_Host_CTE.host_object_id,
                    Dim_Host_CTE.host,
                    Dim_Host_CTE.host_type,
                    Dim_Host_CTE.host_facility,
                    Dim_Host_CTE.host_plaza,
                    Dim_Host_CTE.plaza_latitude,
                    Dim_Host_CTE.plaza_longitude,
                    Dim_Host_CTE.is_active,
                    Dim_Host_CTE.lnd_updatedate,
                    row_number() OVER (PARTITION BY Dim_Host_CTE.host_object_id ORDER BY Dim_Host_CTE.host_type DESC) AS rn
                  FROM
                    Dim_Host_CTE
              ) AS h
            WHERE h.rn = 1
             AND h.host_type IS NOT NULL
      ;
      CREATE OR REPLACE TEMPORARY TABLE _SESSION.Dim_Host_Service_Stage
        AS
          SELECT
              h.host_object_id AS nagios_object_id,
              'Host' AS object_type,
              h.host_facility,
              h.host_type,
              h.host,
              NULL AS service,
              h.host_plaza,
              h.plaza_latitude,
              h.plaza_longitude,
              h.is_active,
              h.lnd_updatedate
            FROM
              Dim_Host_Stage AS h
          UNION ALL
          SELECT
              s.service_object_id AS nagios_object_id,
              'Service' AS object_type,
              h.host_facility,
              h.host_type,
              h.host,
              so.name2 AS service,
              h.host_plaza,
              h.plaza_latitude,
              h.plaza_longitude,
              so.is_active,
              s.lnd_updatedate
            FROM
              Dim_Host_Stage AS h
              INNER JOIN LND_NAGIOS.nagios_services AS s ON s.host_object_id = h.host_object_id
              INNER JOIN LND_NAGIOS.nagios_objects AS so ON s.service_object_id = so.object_id
      ;
      IF trace_flag = 1 THEN
        SELECT
            'Dim_Host_Service_Stage' AS datatable,
            `Dim_Host_Service_Stage`.*
          FROM
            Dim_Host_Service_Stage AS `Dim_Host_Service_Stage`
        ORDER BY
          2,
          1
        ;
      END IF;
      
      CREATE OR REPLACE TABLE EDW_NAGIOS.Dim_Host_Service_NEW
      CLUSTER BY nagios_object_id
        AS
        --:: New/existing rows
          SELECT
              hss.nagios_object_id,
              hss.object_type,
              hss.host_facility,
              hss.host_type,
              hss.host,
              hss.service,
              hss.host_plaza,
              hss.plaza_latitude,
              hss.plaza_longitude,
              hss.is_active,
              0 AS is_deleted,
              hss.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              Dim_Host_Service_Stage AS hss
          UNION ALL
          --:: Keep deleted rows as there may be events
          SELECT
              hs.nagios_object_id,
              hs.object_type,
              hs.host_facility,
              hs.host_type,
              hs.host,
              hs.service,
              hs.host_plaza,
              hs.plaza_latitude,
              hs.plaza_longitude,
              0 AS is_active,
              1 AS is_deleted,
              hs.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              EDW_NAGIOS.Dim_Host_Service AS hs
            WHERE NOT EXISTS (
              SELECT
                  1
                FROM
                  Dim_Host_Service_Stage AS hss
                WHERE hs.nagios_object_id = hss.nagios_object_id
            )
      ;
      SET log_message = 'Loaded EDW_NAGIOS.Dim_Host_Service_NEW';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      -- Table swap!
      --CALL EDW_NAGIOS_SUPPORT.TableSwap('EDW_NAGIOS.Dim_Host_Service_NEW', 'EDW_NAGIOS.Dim_Host_Service');
      CREATE OR REPLACE TABLE EDW_NAGIOS.Dim_Host_Service CLUSTER BY nagios_object_id AS SELECT * FROM EDW_NAGIOS.Dim_Host_Service_NEW;
      SET log_message = 'Completed EDW_NAGIOS.Dim_Host_Service load';
      CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
        RAISE USING MESSAGE = error_message;
      END;
    END;
/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_Host_Service_Load

EXEC Utility.FromLog 'dbo.Dim_Host_Service', 1
SELECT * FROM dbo.Dim_Host_Service ORDER BY Host, Object_Type

--:: Testing
SELECT * FROM dbo.Dim_Host_Service WHERE Is_Active = 0
SELECT * FROM dbo.Dim_Host_Service WHERE Is_Active = 1 AND Object_Type = 'Host'
SELECT * FROM dbo.Dim_Host_Service WHERE Is_Active = 1 AND Object_Type = 'Service'
SELECT * FROM dbo.Dim_Host_Service WHERE Is_Active = 0 AND Object_Type = 'Host'
SELECT * FROM dbo.Dim_Host_Service WHERE Is_Active = 0 AND Object_Type = 'Service'
SELECT * FROM dbo.Dim_Host_Service WHERE Is_Deleted = 1
SELECT * FROM dbo.Fact_Host_Service_Event F JOIN dbo.Dim_Host_Service D ON D.Nagios_Object_ID = F.Nagios_Object_ID WHERE D.Is_Active = 0

*/
  END;