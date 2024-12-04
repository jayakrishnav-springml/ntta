CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Plaza_Lane_GIS_Data_Full_Load`()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Plaza_GIS_Data and dbo.Lane_GIS_Data tables. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Gouthami	2020-10-14	New!
CHG0039000	Gouthami	2021-06-04	Removed unnecessary joins from Lane_GIS_Data as there is PlazaID in GIS file
									                and changed the default value of plaza lattitude and longitude to 0
SPLTSK0033436 Dhanush 2024-08-28  lane_gis_data is static table which has stale or invalid lanestatus. 
                                  Get lanestatus from TollPlus_lanes table instead of lane_gis_data.
DFCT0014293 Dhanush   2024-09-18  Updated the EDW_TRIPS_SUPPORT.Lane_GIS_Data table with the latest data provided 
                                  by the GIS team.
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Plaza_Lane_GIS_Data_Full_Load

EXEC Utility.FromLog 'dbo.Plaza_Lane_GIS_Data_Full_Load', 1
SELECT TOP 100 'dbo.Lane_GIS_Data' Table_Name, * FROM dbo.Lane_GIS_Data ORDER BY 2
SELECT TOP 100 'dbo.Plaza_GIS_Data' Table_Name, * FROM dbo.Plaza_GIS_Data ORDER BY 2
###################################################################################################################
*/

    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Plaza_Lane_GIS_Data_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
		--=============================================================================================================
		-- Load dbo.Lane_GIS_Data
		--=============================================================================================================
      --DROP TABLE IF EXISTS EDW_TRIPS.lane_gis_data_new;
      CREATE or REPLACE TABLE EDW_TRIPS.lane_gis_data CLUSTER BY laneid
        AS
          SELECT DISTINCT
              e.laneid,
              c.plazaid,
              e.lanename,
              e.direction,
              CAST(coalesce(g.latitude, gp1.ycoord, lc.ycoord, 0) as BIGNUMERIC) AS latitude,
              CAST(coalesce(g.longitude, gp1.xcoord, lc.xcoord, 0) as BIGNUMERIC) AS longitude,
              coalesce(g.zipcode, gp1.postcode, 0) AS zipcode,
              coalesce(g.county, gp1.county, x.county, '') AS county,
              coalesce(m.mileage, 0) AS mileage,
              CASE
              WHEN e.lanestatus = 'INACTIVE' THEN 0 --BY Dhanush-Changed table from lane_gis_data to TollPlus_lanes, which caused the issue of displaying an INACTIVE table as an ACTIVE table.
              ELSE 1
              END AS active,
              --l.plazasortorder 
            FROM
              LND_TBOS.TollPlus_agencies AS a
              INNER JOIN LND_TBOS.TollPlus_locations AS b ON a.agencyid = b.agencyid
              INNER JOIN LND_TBOS.TollPlus_plazas AS c ON b.locationid = c.locationid
              INNER JOIN LND_TBOS.TollPlus_lanes AS e ON c.plazaid = e.plazaid
              LEFT OUTER JOIN EDW_TRIPS_SUPPORT.directions AS d ON e.direction = d.diredesc
              LEFT OUTER JOIN EDW_TRIPS_SUPPORT.facility_sub_agency AS sa ON b.locationcode = sa.facilityabbrev
              LEFT OUTER JOIN EDW_TRIPS_SUPPORT.lane_gis_data AS g ON e.laneid = g.laneid
              LEFT OUTER JOIN (
                SELECT
                    plaza_gis_data.plazaid,
                    plaza_gis_data.ritename,
                    plaza_gis_data.ycoord,
                    plaza_gis_data.xcoord,
                    plaza_gis_data.postcode,
                    plaza_gis_data.county,
                    row_number() OVER (PARTITION BY plaza_gis_data.ritename ORDER BY plaza_gis_data.type, plaza_gis_data.roadwayname) AS rn
                  FROM
                    EDW_TRIPS_SUPPORT.plaza_gis_data
              ) AS gp1 ON c.plazaid = gp1.plazaid
               AND gp1.rn = 1
              LEFT OUTER JOIN (
                SELECT
                    ntta_toll_locations.corridor,
                    ntta_toll_locations.ritename,
                    ntta_toll_locations.ycoord,
                    ntta_toll_locations.xcoord,
                    row_number() OVER (PARTITION BY ntta_toll_locations.corridor, ntta_toll_locations.ritename ORDER BY ntta_toll_locations.type DESC) AS rw
                  FROM
                    EDW_TRIPS_SUPPORT.ntta_toll_locations
              ) AS lc ON c.plazacode LIKE concat(lc.ritename, '%')
               AND lc.corridor = b.locationcode
               AND lc.rw = 1
              LEFT OUTER JOIN EDW_TRIPS_SUPPORT.plaza_county_xref AS x ON x.plazaid = c.plazaid
               AND x.lanedirection = coalesce(e.direction, d.diredesc) --BY Dhanush- updated the direction coloumn from the Lane_GIS_data table to the Tollplus_lanes table.
              LEFT OUTER JOIN EDW_TRIPS_SUPPORT.plaza_mileage AS m ON m.plazaid = c.plazaid
               AND m.lanedirection = coalesce(e.direction, d.diredesc)
		    --LEFT OUTER JOIN EDW_TRIPS_SUPPORT.dim_lane AS l ON l.laneid = e.laneid
              
      ;
      SET log_message = 'Loaded EDW_TRIPS.Lane_GIS_Data';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      
      -- Table Swap Not Required as we are using Create or Replace in BQ
      --CALL utility.tableswap('EDW_TRIPS.Lane_GIS_Data_NEW', 'EDW_TRIPS.Lane_GIS_Data');
      
		--=============================================================================================================
		-- Load dbo.Plaza_GIS_Data
		--=============================================================================================================
      --DROP TABLE IF EXISTS EDW_TRIPS.plaza_gis_data_new;
      CREATE OR REPLACE TABLE EDW_TRIPS.plaza_gis_data Cluster by plazaid
        AS
          SELECT DISTINCT
              e.plazaid,
              coalesce(g.latitude, 0) AS plazalatitude,
              coalesce(g.longitude, 0) AS plazalongitude,
              coalesce(g.zipcode, 0) AS zipcode,
              coalesce(g.county, '') AS county
            FROM
              LND_TBOS.TollPlus_agencies AS a
              INNER JOIN LND_TBOS.TollPlus_locations AS b ON a.agencyid = b.agencyid
              INNER JOIN LND_TBOS.TollPlus_plazas AS c ON b.locationid = c.locationid
              INNER JOIN LND_TBOS.TollPlus_lanes AS e ON c.plazaid = e.plazaid
              LEFT OUTER JOIN (
                SELECT
                    lane_gis_data.plazaid,
                    lane_gis_data.latitude,
                    lane_gis_data.longitude,
                    lane_gis_data.zipcode,
                    lane_gis_data.county,
                    row_number() OVER (PARTITION BY lane_gis_data.plazaid ORDER BY lane_gis_data.active, lane_gis_data.direction, lane_gis_data.laneid) AS rn
                  FROM
                    EDW_TRIPS.lane_gis_data  --WHERE LANE_ID=31
              ) AS g ON c.plazaid = g.plazaid
               AND g.rn = 1
      ;

      SET log_message = 'Loaded EDW_TRIPS.Plaza_GIS_Data';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      
      -- Table Swap Not Required as we are using Create or Replace in BQ
      --CALL utility.tableswap('EDW_TRIPS.Plaza_GIS_Data_NEW', 'EDW_TRIPS.Plaza_GIS_Data');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      -- Show results
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source,log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        SELECT log_source , log_start_date ;
        RAISE USING MESSAGE = error_message; -- Rethrow the error!
      END;


  END;
/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Rite_Plaza_Lane_GIS_Data_Full_Load

EXEC Utility.FromLog 'dbo.Dim_InvoiceStage', 1
SELECT 'LND_TBOS.MIR.ReasonCodes' Table_name,* FROM LND_TBOS.MIR.ReasonCodes ORDER BY 2
SELECT TOP 100 'dbo.Dim_InvoiceStage' Table_Name, * FROM dbo.Dim_InvoiceStage ORDER BY 2

*/
  END;