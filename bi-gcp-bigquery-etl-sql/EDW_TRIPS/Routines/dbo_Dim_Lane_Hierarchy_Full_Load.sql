CREATE OR REPLACE PROCEDURE EDW_TRIPS.Dim_Lane_Hierarchy_Full_Load()
BEGIN 
/*
###################################################################################################################
Purpose: Load all Lane dimension hierarchy tables. 

~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ 
Good Template for: MATRYOSHKA RUSSIAN DOLLS ETL DESIGN PATTERN for loading related Dim tables in a natural hierarchy 
~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ ~~~ 

Tables: !!! MATRYOSHKA RUSSIAN DOLLS ETL DESIGN PATTERN !!!
		- dbo.Dim_Agency	-> Agency level
		- dbo.Dim_Facility	-> Location level + dbo.Dim_Agency
		- dbo.Dim_Plaza		-> Plaza level + dbo.Dim_Facility
		- dbo.Dim_Lane		-> Lane level  + dbo.Dim_Plaza

-------------------------------------------------------------------------------------------------------------------
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838 		Gouthami		2020-01-04		New!
CHG0039000      Gouthami		2021-06-04		Added LaneCategoryID,LaneLatitude,LaneLongitude,LaneZipCode,LaneCountyName
												,PlazaLatitude, PlazaLongitude,PlazaZipCode  with new GIS data
CHG0040134		Gouthami		2021-12-15		Added Operations Agency for Bubble Report
CHG0041141		Shankar			2022-06-30		Added new columns for IPS. Modified OperationsAgency, SubAgency for NetRMA
CHG0044403		Shankar			2024-01-16		PlazaDirectionID replaces PlazaSortOrder column for GIS team
-------------------------------------------------------------------------------------------------------------------
Run script:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_Lane_Hierarchy_Full_Load
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_Lane_Hierarchy_Full_Load%' ORDER BY LogDate DESC

SELECT 'dbo.Dim_Agency' TableName, * FROM dbo.Dim_Agency ORDER BY 2 
SELECT 'dbo.Dim_Facility' TableName, * FROM dbo.Dim_Facility ORDER BY 2 
SELECT 'dbo.Dim_Plaza' TableName, * FROM dbo.Dim_Plaza ORDER BY 2 
SELECT 'dbo.Dim_Lane' TableName, * FROM dbo.Dim_Lane ORDER BY 2 
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_Lane_Hierarchy_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    BEGIN 
        DECLARE row_count INT64;
        DECLARE trace_flag INT64 DEFAULT 0;

        SET
            log_start_date = current_datetime('America/Chicago');
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date , 'Started full load of Hierarchy dim tables', '-1', NULL, 'I');

        --=============================================================================================================
                -- Load dbo.Dim_Agency		->	Agency Level
        --=============================================================================================================

        CREATE OR REPLACE TABLE EDW_TRIPS.Dim_Agency CLUSTER BY agencyid AS
        SELECT
            coalesce(CAST(agencies.agencyid as INT64),0) AS agencyid,
            coalesce(CAST(agencytype.lookuptypecode as STRING),'UNKNOWN') AS agencytype,
            CAST(agencies.agencyname as STRING) AS agencyname,
            coalesce(CAST(agencies.agencycode as STRING),'') AS agencycode,
            CAST(agencies.starteffectivedate as DATETIME) AS agencystartdate,
            CAST(agencies.endeffectivedate as DATETIME) AS agencyenddate,
            CAST(agencies.lnd_updatedate as DATETIME) AS lnd_updateddate,
            CAST(current_datetime() AS DATETIME) AS edw_updateddate
        FROM
            LND_TBOS.TollPlus_Agencies as agencies
            LEFT OUTER JOIN LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy AS agencytype ON agencies.agencytypeid = agencytype.lookuptypecodeid
            AND agencytype.parent_lookuptypecodeid = 587 -- AgencyType
            UNION DISTINCT
            SELECT
                -1 AS agencyid,
                'UNKNOWN' AS agencytype,
                'UNKNOWN' AS agencyname,
                'UNKNOWN' AS agencycode,
                NULL AS agencystartdate,
                NULL AS agencyenddate,
                current_datetime() AS lnd_updateddate,
                current_datetime() AS edw_updateddate;
        -- Log 
        SET
            log_message = 'Loaded EDW_TRIPS.Dim_Agency with Agency level';
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source , log_start_date , log_message, 'I', -1, NULL);

        -- Table Swap Not Required as we are using Create or Replace in BQ
        --CALL utility.tableswap('EDW_TRIPS.Dim_Agency_NEW', 'EDW_TRIPS.Dim_Agency');
        IF trace_flag = 1 THEN
            SELECT
                'EDW_TRIPS.Dim_Agency' AS tablename,
                *
                FROM
                EDW_TRIPS.dim_agency
            ORDER BY
                2 DESC
            LIMIT 100
            ;
        END IF;

        --=============================================================================================================
                -- Load dbo.Dim_Facility		->	 Location + Agency levels
        --=============================================================================================================

        CREATE OR REPLACE TABLE EDW_TRIPS.Dim_Facility CLUSTER BY facilityid AS
        SELECT
            coalesce(CAST(location.locationid as INT64),0) AS facilityid,
            CAST(location.locationcode as STRING) AS facilitycode,
            CAST(location.locationname as STRING) AS facilityname,
            CAST(location.tsafacilityid as INT64) AS tsafacilityid,
            CASE
                WHEN location.istsa = 1 THEN CAST(
                    
                    location.tsafacilityid as STRING
                )
                ELSE location.locationcode
            END AS ips_facilitycode,
            CAST(location.istsa as INT64) AS tsaflag,
            coalesce(
                CASE
                    WHEN agency.agencycode <> 'NTTA' THEN 1
                    WHEN location.locationid = 5 THEN 2
                    WHEN location.locationid = 9 THEN 4
                    WHEN location.locationid = 10 THEN 8
                    WHEN location.locationid = 11 THEN 16
                    WHEN location.locationid = 210 THEN 32
                    WHEN location.locationid = 220 THEN 64
                    WHEN location.locationid = 230 THEN 128
                    WHEN location.locationid = 240 THEN 256
                    WHEN location.locationid = 250 THEN 512
                    WHEN location.locationid = 260 THEN 1024
                    WHEN location.locationid = 270 THEN 2048
                    WHEN location.locationid = 271 THEN 4096
                    WHEN location.locationid = 280 THEN 8192
                    WHEN location.locationid = 290 THEN 16384
                    WHEN location.locationid = 281 THEN 32768
                END,
                0
            ) AS bitmaskid,
        ----------------------------------Agency Level--------------------------------------------------------
            SUBSTR(CAST(
                CASE
                    WHEN location.istsa = 1
                    AND sa.subagencyabbrev IS NOT NULL THEN sa.subagencyabbrev	-- TSA
                    WHEN location.istsa = 0
                    AND sa.subagencyabbrev IS NOT NULL
                    AND agency.agencytype = 'IOPAgency' THEN 'N/A'  -- IOP
                    WHEN location.istsa = 0
                    AND sa.subagencyabbrev <> 'TSA' THEN sa.subagencyabbrev -- Other than TSA
                END  as STRING),1,20) as subagencyabbrev, 
            SUBSTR(CAST(
                CASE
                    WHEN location.istsa = 1 THEN sa.operationsagency
                    WHEN location.istsa = 0
                    AND sa.operationsagency IS NOT NULL
                    AND agency.agencytype = 'IOPAgency' THEN 'IOP - NTTA Home'
                    ELSE sa.operationsagency
                END as STRING),1,20) AS operationsagency,
            agency.agencyid,
            agency.agencytype,
            agency.agencyname,
            agency.agencycode,
            agency.agencystartdate,
            agency.agencyenddate,
            CAST(location.lnd_updatedate as DATETIME) AS lnd_updateddate,
            current_datetime() AS edw_updateddate
        FROM
            LND_TBOS.TollPlus_Locations AS location
            LEFT OUTER JOIN EDW_TRIPS_SUPPORT.Facility_Sub_Agency AS sa ON sa.facilityabbrev = location.locationcode
            INNER JOIN EDW_TRIPS.Dim_Agency AS agency ON 
            CASE 
                WHEN location.locationid = -1 THEN -1 
                ELSE location.agencyid  
            END = agency.agencyid;
        -- Log
        SET
            log_message = 'Loaded EDW_TRIPS.Dim_Facility';
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source , log_start_date , log_message, 'I', -1, NULL);

        -- Table Swap Not Required as we are using Create or Replace in BQ
        --CALL utility.tableswap('EDW_TRIPS.Dim_Facility_NEW', 'EDW_TRIPS.Dim_Facility');
        IF trace_flag = 1 THEN
            SELECT
                'EDW_TRIPS.Dim_Facility' AS tablename,
                *
                FROM
                EDW_TRIPS.Dim_Facility
            ORDER BY
                2 DESC
            LIMIT 100
            ;
        END IF;

        /*
        --:: TxnCount by Facility

        DECLARE @SnapshotMonthID INT
        SELECT @SnapshotMonthID = MAX(SnapshotMonthID) FROM dbo.Fact_UnifiedTransaction_SummarySnapshot

        SELECT	ut.TripMonthID/100 TripYear, f.FacilityCode, f.OperationsAgency, COUNT(1) RC, SUM(ut.TxnCount) TxnCount 
        FROM	dbo.Fact_UnifiedTransaction_SummarySnapshot ut 
                JOIN dbo.Dim_Facility f ON f.FacilityID = ut.FacilityID 
                JOIN dbo.Dim_OperationsMapping OM ON OM.OperationsMappingID = ut.OperationsMappingID
        WHERE	ut.SnapshotMonthID = @SnapshotMonthID AND F.FacilityCode LIKE 'NE%49'
        GROUP BY ut.TripMonthID/100, f.FacilityCode, f.OperationsAgency  
        ORDER BY 3,2,1

        DECLARE @SnapshotMonthID INT
        SELECT @SnapshotMonthID = MAX(SnapshotMonthID) FROM dbo.Fact_UnifiedTransaction_SummarySnapshot

        SELECT	ut.TripMonthID, f.FacilityCode, f.OperationsAgency, COUNT(1) RC, SUM(ut.TxnCount) TxnCount 
        FROM	dbo.Fact_UnifiedTransaction_SummarySnapshot ut 
                JOIN dbo.Dim_Facility f ON f.FacilityID = ut.FacilityID 
                JOIN dbo.Dim_OperationsMapping OM ON OM.OperationsMappingID = ut.OperationsMappingID
        WHERE	ut.SnapshotMonthID = @SnapshotMonthID AND F.FacilityCode LIKE 'NE%49'
        GROUP BY ut.TripMonthID, f.FacilityCode, f.OperationsAgency  
        ORDER BY 3,2,1

        */
        --=============================================================================================================
        -- Load dbo.Dim_Plaza		->	 Plaza + Facility + Agency levels
        --=============================================================================================================

        CREATE OR REPLACE TABLE EDW_TRIPS.Dim_Plaza CLUSTER BY plazaid AS
        SELECT
            coalesce(CAST(TollPLus_Plazas.plazaid as INT64),0) AS plazaid,
            CAST(TollPLus_Plazas.plazacode as STRING) AS plazacode,
            CAST(
                CASE
                    WHEN facility.tsaflag = 1 THEN TollPLus_Plazas.exitplazacode
                    ELSE TollPLus_Plazas.plazacode
                END as STRING
            ) AS ips_plazacode,
            coalesce(CAST(TollPLus_Plazas.plazaname as STRING),'') AS plazaname,
            p.plazalatitude AS plazalatitude,
            p.plazalongitude AS plazalongitude,
            p.zipcode AS zipcode,
            p.county AS county,
            ---------------------------------Facility Level -----------------------------------------
            facility.facilityid,
            facility.facilitycode,
            facility.facilityname,
            facility.ips_facilitycode,
            facility.tsaflag,
            facility.tsafacilityid,
            facility.bitmaskid,
            facility.subagencyabbrev,
            facility.operationsagency,
            facility.agencyid,
            facility.agencytype,
            facility.agencyname,
            facility.agencycode,
            facility.agencystartdate,
            facility.agencyenddate,
            CAST(TollPLus_Plazas.lnd_updatedate as DATETIME) AS lnd_updateddate,
            current_datetime() AS edw_updateddate
        FROM
            LND_TBOS.TollPlus_Plazas
            INNER JOIN EDW_TRIPS.Plaza_GIS_data AS p ON TollPlus_Plazas.plazaid = p.plazaid
            INNER JOIN EDW_TRIPS.Dim_Facility AS facility ON TollPlus_Plazas.locationid = facility.facilityid;
        -- Log
        SET
            log_message = 'Loaded EDW_TRIPS.Dim_Plaza with Plaza level + EDW_TRIPS.Dim_Facility';
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source , log_start_date , log_message, 'I', -1, NULL);

        -- Table Swap Not Required as we are using Create or Replace in BQ
        --CALL utility.tableswap('EDW_TRIPS.Dim_Plaza_NEW', 'EDW_TRIPS.Dim_Plaza');
        IF trace_flag = 1 THEN
            SELECT
                'EDW_TRIPS.Dim_Plaza' AS tablename,
                *
                FROM
                EDW_TRIPS.Dim_Plaza
            ORDER BY
                2 DESC
            LIMIT 100
            ;
        END IF;
        --=============================================================================================================
        -- Load dbo.Dim_Lane		->	 Lane + Plaza + Facility + Agency levels
        --=============================================================================================================

        CREATE OR REPLACE TABLE EDW_TRIPS.Dim_Lane CLUSTER BY laneid AS
        SELECT
            coalesce(CAST(Lanes.laneid as INT64),0) AS laneid,
            coalesce(CAST(Lanes.lanecategoryid as INT64),0) AS lanecategoryid,
            coalesce(CAST(Lanes.lanecode as STRING),'') AS lanecode,
            CASE
                WHEN plaza.tsaflag = 1
                AND Lanes.exitlanecode IS NOT NULL THEN Lanes.exitlanecode
                WHEN strpos(reverse(Lanes.lanecode), '-') > 0 THEN replace(
                    ltrim(
                        replace(
                            reverse(
                                left(
                                    reverse(Lanes.lanecode),
                                    strpos(reverse(Lanes.lanecode), '-') - 1
                                )
                            ),
                            '0',
                            ' '
                        )
                    ),
                    ' ',
                    '0'
                )
            END AS lanenumber,
            coalesce(CAST(Lanes.lanename as STRING),'') AS lanename,
            CAST(Lanes.direction as STRING) AS lanedirection,
            CASE
                WHEN lanes.laneid = -1 THEN 'UNKNOWN'
                WHEN plaza.agencycode = 'NTTA' THEN upper(concat(plaza.facilitycode, '-', plaza.plazacode, '-', CASE
                  WHEN lanes.lanecode IN(
                    'DNT-PARBD-03', 'DNT-PARBD-04'
                  ) THEN '1'
                  WHEN lanes.lanecode IN(
                    'DNT-PARBD-05', 'DNT-PARBD-06'
                  ) THEN '2'
                  ELSE ''
                END, left(lanes.direction, 1)))
              END AS plazadirectionid,
            l.latitude AS lanelatitude,
            l.longitude AS lanelongitude,
            l.zipcode AS lanezipcode,
            l.county AS lanecountyname,
            l.mileage AS mileage,
            coalesce(CAST(Lanes.exitlanecode as STRING),'') AS exitlanecode,
            ---------------------------------------------Plaza Level--------------------------
            plaza.plazaid,
            plaza.plazacode,
            plaza.ips_plazacode,
            plaza.plazaname,
            plaza.plazalatitude AS plazalatitude,
            plaza.plazalongitude AS plazalongitude,
            plaza.zipcode AS plazazipcode,
            plaza.county AS plazacountyname,
            CAST(l.Plazasortorder as INT64) AS Plazasortorder, -- PlazaDirectionID replaces this column for GIS team. Drop this column when MSTR points to PlazaDirectionID.
            l.active,
            --------------------------------------------Facility Level-------------------------
            plaza.facilityid,
            plaza.facilitycode,
            plaza.facilityname,
            plaza.ips_facilitycode,
            plaza.tsaflag,
            plaza.tsafacilityid,
            plaza.bitmaskid,
            plaza.subagencyabbrev,
            plaza.operationsagency,
            ---------------------------------------------Agency Level--------------------------	
            plaza.agencyid,
            plaza.agencytype,
            plaza.agencyname,
            plaza.agencycode,
            plaza.agencystartdate,
            plaza.agencyenddate,
            coalesce(CAST(Lanes.updateddate as DATETIME),DATETIME '1900-01-01') AS updateddate,
            current_datetime() AS edw_updateddate
        FROM
            LND_TBOS.TollPlus_Lanes AS Lanes
            LEFT OUTER JOIN EDW_TRIPS.Dim_Plaza AS plaza ON Lanes.plazaid = plaza.plazaid
            INNER JOIN EDW_TRIPS.Lane_GIS_Data AS l ON l.laneid = Lanes.laneid
            AND plaza.plazaid = Lanes.plazaid;

        SET
            log_message = 'Loaded EDW_TRIPS.Dim_Lane with Lane level + EDW_TRIPS.Dim_Week + EDW_TRIPS.Dim_Plaza';
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source , log_start_date , log_message, '-1', -1, 'I');

        -- Table Swap Not Required as we are using Create or Replace in BQ
        --CALL utility.tableswap('EDW_TRIPS.Dim_Lane_NEW', 'EDW_TRIPS.Dim_Lane');
        IF trace_flag = 1 THEN
            SELECT
                'EDW_TRIPS.Dim_Lane' AS tablename,
                *
                FROM
                EDW_TRIPS.Dim_Lane
            ORDER BY
                2 DESC
            LIMIT 100
            ;
        END IF;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source , log_start_date, 'Completed full load of Lane Hierarchy dim tables', '-1', NULL, 'I');

        EXCEPTION WHEN ERROR THEN 
            BEGIN 
                DECLARE error_message STRING DEFAULT @@error.message;
                CALL EDW_TRIPS_SUPPORT.ToLog( log_source , log_start_date, error_message, '-1', NULL, 'E');
                select log_source, log_start_date;
                RAISE USING MESSAGE = error_message; -- Rethrow the error all the way to Data Manager
            END;

    END;
 
/*

--:: Testing Zone

EXEC Dev.Dim_Lane_Hierarchy_Full_Load

SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_Lane_Hierarchy_Full_Load%' ORDER BY LogDate DESC

--:: Quick check
SELECT * FROM EDW_RITE.dbo.Dim_Agency ORDER BY 1
SELECT * FROM EDW_TRIPS.dbo.Dim_Agency ORDER BY 1

--:: Quick check
SELECT * FROM EDW_RITE.dbo.Dim_Facility ORDER BY 1
SELECT * FROM EDW_TRIPS.dbo.Dim_Facility ORDER BY 1

--:: Quick check
SELECT * FROM EDW_RITE.dbo.Dim_Plaza-- ORDER BY 1
where plaza_Abbrev not in (
SELECT plazacode FROM EDW_TRIPS.dbo.Dim_Plaza ) ORDER BY 1

--:: Quick check
SELECT * FROM EDW_RITE.dbo.Dim_Lane --ORDER BY 1
where lane_Abbrev not in (
SELECT LaneCode FROM EDW_TRIPS.dbo.Dim_Lane_NEW where lanecode ='DFW-ENC-129') ORDER BY 1


*/

END;