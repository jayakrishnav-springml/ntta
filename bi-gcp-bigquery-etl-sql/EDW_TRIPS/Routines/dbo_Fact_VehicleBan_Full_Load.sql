CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_VehicleBan_Full_Load`()
BEGIN
/*
###################################################################################################################
Proc  Description:
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_VehicleBan table.
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0043993      Gouthami  2023-11-02  New!
                    1. This load is created to find the out Bans that happened for an HV.
                    2. There are only two applied dates for BAN on '2019-01-01' and '2022-03-08'.
                       This how the data TRIPS data is. Need to pull data from RITE for these
                       dates.
CHG0044321     Gouthami   2024-01-08  1. Pulled RITE data and merged it into final fact table.
                    2. As TRIPS did not migrate correct dates for BANS, pulled those dates from
                      RITE system.
 
===================================================================================================================
Example:
----------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_VehicleBan_Full_Load
 
EXEC Utility.FromLog 'dbo.Fact_VehicleBan', 1
SELECT TOP 100 'dbo.Fact_VehicleBan' Table_Name, * FROM dbo.Fact_VehicleBan ORDER BY 2
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_VehicleBan_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
     
      --=============================================================================================================
      -- Load dbo.Fact_VehicleBan
      --=============================================================================================================
      CREATE OR REPLACE TABLE EDW_TRIPS.Fact_VehicleBan CLUSTER by hvid
        AS
          SELECT
              vb.vehiclebanid,
              coalesce(vb.hvid, -1) AS hvid,
              coalesce(hv.customerid, -1) AS customerid,
              coalesce(hv.vehicleid, -1) AS vehicleid,
              coalesce(vb.vblookupid, -1) AS vehiclebanstatusid,
              coalesce(vb.removallookupid, -1) AS vehiclebanremovalstatusid,
              vb.isactive AS activeflag,
              CASE        ------ If BAN createddate is prior to 2021, then pull requested date from Ref table (RITE data)
                WHEN CAST(ft.createddate as DATE) < DATE '2021-01-01' THEN CAST(left(CAST(ref.dayid2 as STRING), 8) as INT64)
                ELSE CAST(left(CAST(ft.createddate as STRING FORMAT 'YYYYMMDD'), 8) as INT64)
              END AS vbrequesteddayid,
              CASE        ------ If BAN createddate is prior to 2021, then pull applied date from Ref table (RITE data)
                WHEN CAST(ft.createddate as DATE) < DATE '2021-01-01' THEN CAST(left(CAST( ref.dayid2 as STRING), 8) as INT64)
                ELSE CAST(left(CAST( ft.createddate as STRING FORMAT 'YYYYMMDD'), 8) as INT64)
              END AS vbapplieddayid,
              CASE
                WHEN vb.vblookupid = 28 THEN vb.actiondate
                ELSE NULL
              END AS removeddate,
              ------ If the letter dates are not migrated to TRIPS, then pull the mailed date from Ref table (RITE data)
              coalesce(CAST( hv.earliestvehiclebanlettermaileddate as DATE), CAST(PARSE_DATE('%Y%m%d',CAST(ref.dayid1 as STRING)) as DATE)) AS earliestvehiclebanlettermaileddate,
              CAST(hv.earliestvehiclebanletterdelivereddate as DATE) AS earliestvehiclebanletterdelivereddate,
              CAST(hv.latestvehiclebanlettermaileddate as DATE) AS latestvehiclebanlettermaileddate,
              CAST(hv.latestvehiclebanletterdelivereddate as DATE) AS latestvehiclebanletterdelivereddate,
              coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_updatedate -- SELECT *
            FROM
              LND_TBOS.TER_vehicleban AS vb
              INNER JOIN EDW_TRIPS.dim_habitualviolator AS hv ON hv.hvid = vb.hvid
              LEFT OUTER JOIN LND_TBOS.TER_vehiclebanrequest AS vbr ON vbr.vehiclebanid = vb.vehiclebanid
              LEFT OUTER JOIN LND_TBOS.TollPlus_tpfiletracker AS ft ON ft.fileid = vbr.fileid
              LEFT OUTER JOIN EDW_TRIPS_SUPPORT.ban AS ref ON ref.violatorid = hv.customerid
               AND ref.hvflag = 1
      ;
      SET log_message = 'Loaded dbo.Fact_VehicleBan';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
     
      -- CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Fact_VehicleBan_NEW', 'EDW_TRIPS.Fact_VehicleBan');
      --TableSwap is Not Required, using  Create or Replace Table
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
 
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = error_message;  -- Rethrow the error!
      END;
    END;
/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Fact_VehicleBan_Load
 
EXEC Utility.FromLog 'dbo.Fact_VehicleBan', 1
SELECT TOP 100 'dbo.Fact_VehicleBan' Table_Name, * FROM dbo.Fact_VehicleBan ORDER BY 2
 
 
select * FROM dbo.Fact_VehicleBan ORDER BY 2
select count(*) FROM dbo.Fact_VehicleBan --110984
select * FROM edw_trips.dbo.Fact_VehicleBan  where customerid = 806539432
select * FROM edw_trips_dev.dbo.Fact_VehicleBan  where customerid = 806539432
 
 
---------------------------------------------------OLD CODE--------------------------------------------------------
  SELECT VB.VehicleBanID
               ,ISNULL(VB.HVID,-1) HVID
               ,ISNULL(HV.CustomerID,-1) CustomerID
               ,ISNULL(HV.VehicleID,-1) VehicleID
               ,ISNULL(VBLookupID,-1) VehicleBanStatusID
               ,ISNULL(RemovalLookupID,-1) VBRemovalReasonID
               ,VB.IsActive VBActiveFlag
               ,CAST(LEFT(CONVERT(VARCHAR,FT.CreatedDate,112),8) AS INT) VBRequestedDayID
               ,CAST(LEFT(CONVERT(VARCHAR,FT.CreatedDate,112),8) AS INT)  VBAppliedDayID
               ,CAST(LEFT(CONVERT(VARCHAR,CASE WHEN VB.VBLookupID=28 THEN VB.ActionDate ELSE NULL END,112),8) AS INT) AS VBRemovedDayID
               ,VB.CreatedDate
               ,ISNULL(CAST(SYSDATETIME() AS datetime2(3)), '1900-01-01') AS EDW_UpdateDate
               --SELECT  *
          FROM LND_TBOS.TER.VehicleBan VB
          JOIN dbo.Dim_HabitualViolator HV ON HV.HVID = VB.HVID
          LEFT JOIN LND_TBOS.TER.HVStatusLookup HVS ON VB.VBLookupID=HVS.HVStatusLookupID
          LEFT JOIN LND_TBOS.TER.HVStatusLookup HVS1 ON VB.RemovalLookupID=HVS1.HVStatusLookupID
          LEFT JOIN LND_TBOS.TER.VehicleBanRequest VBR ON VB.VehicleBanID=vbr.VehicleBanID
          LEFT JOIN LND_TBOS.TollPlus.TpFileTracker FT ON FT.FileID=VBR.FileID  
     
 
*/
 
 
  END;