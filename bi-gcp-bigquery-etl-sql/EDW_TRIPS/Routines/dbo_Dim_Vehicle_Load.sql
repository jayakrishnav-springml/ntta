CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Dim_Vehicle_Load`(isfullload INT64)
BEGIN
/*
IF OBJECT_ID ('dbo.Dim_Vehicle_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Dim_Vehicle_Load
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_Vehicle_Load 1

EXEC Utility.FromLog 'dbo.Dim_Vehicle', 1
SELECT 'LND_TBOS.TollPlus.TP_Customer_Vehicles' Table_Name, COUNT_BIG(1) Row_Count FROM LND_TBOS.TollPlus.TP_Customer_Vehicles
SELECT 'dbo.Dim_Vehicle' Table_Name, COUNT_BIG(1) Row_Count FROM dbo.Dim_Vehicle  
SELECT TOP 100 * FROM dbo.Dim_Vehicle
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_Vehicle table. 

@IsFullLoad - 1 means forced Full load, 0 or NULL - incremental load. I the main table is not exists - it goes with full load.

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0038319 	Andy		2021-03-08	New!

###################################################################################################################
*/
  
    /*====================================== TESTING =======================================================================*/
    --DECLARE @IsFullLoad BIT = 1 
    /*====================================== TESTING =======================================================================*/

    DECLARE tablename STRING DEFAULT 'EDW_TRIPS.Dim_Vehicle';
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_Vehicle_Load';
    DECLARE log_start_date DATETIME;
    DECLARE stagetablename STRING DEFAULT 'EDW_TRIPS.Dim_Vehicle_NEW';
    DECLARE last_updateddate DATETIME;
    DECLARE identifyingcolumns STRING DEFAULT 'VehicleID';
    DECLARE sql STRING;
    DECLARE wheresql STRING DEFAULT '';
    SET log_start_date = current_datetime('America/Chicago');
    IF (
        (SELECT COUNT(1) 
        FROM `EDW_TRIPS.INFORMATION_SCHEMA.TABLES` 
        WHERE lower(table_name) = lower(SUBSTR(tablename,STRPOS(tablename,'.')+1))
        ) = 0
      ) THEN
      SET IsFullLoad = 1;
    END IF;
    IF isfullload = 1 THEN
      SET log_message = 'Started Full load';
      IF trace_flag = 1 THEN
        SELECT log_message;
      END IF;

      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL , NULL);
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_Vehicle_NEW;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_Vehicle cluster by VehicleID
        AS
          --EXPLAIN
          SELECT
              coalesce(CAST(tp_customer_vehicles.vehicleid as INT64), -1) AS vehicleid,
              coalesce(CAST(tp_customer_vehicles.customerid as INT64), -1) AS customerid,
              CAST(tp_customer_vehicles.vehiclenumber as STRING) AS licenseplatenumber,
              coalesce(CAST(tp_customer_vehicles.vehiclestate as STRING), '') AS licenseplatestate,
              coalesce(CAST(tp_customer_vehicles.vehiclecountry as STRING), '') AS licenseplatecountry,
              CAST(tp_customer_vehicles.year as INT64) AS vehicleyear,
              CAST(tp_customer_vehicles.make as STRING) AS vehiclemake,
              CAST(tp_customer_vehicles.model as STRING) AS vehiclemodel,
              CAST(tp_customer_vehicles.color as STRING) AS vehiclecolor,
              coalesce(CAST(tp_customer_vehicles.starteffectivedate as DATETIME), DATETIME '1900-01-01 00:00:00') AS vehiclestartdate,
              coalesce(CAST(tp_customer_vehicles.endeffectivedate as DATETIME), DATETIME '9999-12-31 00:00:00') AS vehicleenddate,
              coalesce(CAST(tp_customer_vehicles.vehiclestatusid as INT64), -1) AS vehiclestatusid,
              coalesce(CAST(vehiclestatus.vehiclestatuscode as STRING), 'Unknown') AS vehiclestatuscode,
              coalesce(CAST(vehiclestatus.vehiclestatusdesc as STRING), 'Unknown') AS vehiclestatusdesc,
              coalesce(case tp_customer_vehicles.vehicleclasscode when "" then 0 else SAFE_CAST(tp_customer_vehicles.vehicleclasscode  as int64) end,-1)  AS vehicleclassid,
              --, ISNULL(CAST(TP_Customer_Vehicles.VehicleClassCode AS varchar(2)), '-1') AS VehicleClass
              CAST(tp_customer_vehicles.docno as STRING) AS docno,
              coalesce(CAST(tp_customer_vehicles.tagid as STRING), '-1') AS tagid,
              CAST(tp_customer_vehicles.county as STRING) AS county,
              CAST(tp_customer_vehicles.vin as STRING) AS vin,
              coalesce(CAST(tp_customer_vehicles.contractualtypeid as INT64), -1) AS contractualtypeid,
              coalesce(CAST(contractualtype.contractualtypecode as STRING), 'Unknown') AS contractualtypecode,
              coalesce(CAST(contractualtype.contractualtypedesc as STRING), 'Unknown') AS contractualtypedesc,
              --, ISNULL(CAST(Dim_PlateType.PlateTypeID AS INT), -1) AS PlateTypeID
              --, CAST(TP_Customer_Vehicles.IsProtected AS bit) AS IsProtected
              coalesce(CAST(tp_customer_vehicles.isexempted as INT64), 0) AS exemptedflag,
       			  --, CAST(TP_Customer_Vehicles.IsTempNumber AS bit) AS IsTempNumber       
              coalesce(CAST(tp_customer_vehicles.isinhv as INT64), 0) AS hvflag,
        			--, ISNULL(CAST(TP_Customer_Vehicles.IsVRH AS bit), 0) AS IsVRH -- Vehicle Registration Block flag
              coalesce(CAST(tp_customer_vehicles.updateddate as DATETIME), DATETIME '1900-01-01 00:00:00') AS updateddate,
              coalesce(CAST(tp_customer_vehicles.lnd_updatedate as DATETIME), DATETIME '1900-01-01 00:00:00') AS lnd_updatedate,
              coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_updatedate
              --SELECT *
            FROM
              LND_TBOS.TollPlus_TP_Customer_Vehicles AS tp_customer_vehicles
              LEFT OUTER JOIN EDW_TRIPS.Dim_ContractualType AS contractualtype ON contractualtype.contractualtypeid = tp_customer_vehicles.contractualtypeid
              LEFT OUTER JOIN EDW_TRIPS.Dim_VehicleStatus AS vehiclestatus ON vehiclestatus.vehiclestatusid = tp_customer_vehicles.vehiclestatusid
    		      --LEFT JOIN  dbo.Dim_PlateType AS Dim_PlateType ON Dim_PlateType.PlateType = TP_Customer_Vehicles.PlateType
		          --LEFT JOIN LND_TBOS.TollPlus.Ref_LookupTypeCodes_Hierarchy AS VehicleStatus ON TP_Customer_Vehicles.VehicleStatusID = VehicleStatus.LookupTypeCodeID AND VehicleStatus.Parent_LookupTypeCodeID = 204

          UNION ALL
          SELECT
              -1 AS vehicleid,
              -1 AS customerid,
              '' AS licenseplatenumber,
              '' AS licenseplatestate,
              '' AS licenseplatecountry,
              0 AS vehicleyear,
              '' AS vehiclemake,
              '' AS vehiclemodel,
              '' AS vehiclecolor,
              '1900-01-01' AS vehiclestartdate,
              '9999-12-31' AS vehicleenddate,
              -1 AS vehiclestatusid,
              'Unknown' AS vehiclestatuscode,
              'Unknown' AS vehiclestatusdesc,
              -1 AS vehicleclassid,
              '' AS docno,
              '-1' AS tagid,
              '' AS county,
              '' AS vin,
              -1 AS contractualtypeid,
              'Unknown' AS contractualtypecode,
              'Unknown' AS contractualtypedesc,
              --, -1 AS PlateTypeID
			        --, 0 AS IsProtected
              0 AS exemptedflag,
              --, 0 AS IsTempNumber
              0 AS hvflag,
              --, 0 AS IsVRH
              '1900-01-01' AS updateddate,
              '1900-01-01' AS lnd_updatedate,
              current_datetime() AS edw_updatedate
      ;
      SET log_message = concat('Loaded ', tablename);
      -- Table swap!
      --CALL EDW_TRIPS_SUPPORT.TableSwap(stagetablename, tablename);
      --TableSwap is Not Required, using  Create or Replace Table
      SET log_message = 'Completed full load';
    ELSE
      CALL EDW_TRIPS_SUPPORT.Get_UpdatedDate(tablename, last_updateddate);
      SET log_message = concat('Started Incremental load from: ', substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_updateddate) as STRING), 1, 25));
      IF trace_flag = 1 THEN
        SELECT log_message;
      END IF;

      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL );
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_Vehicle_NEW;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_Vehicle_NEW cluster by VehicleID
        AS
          --EXPLAIN
          SELECT
              coalesce(CAST(tp_customer_vehicles.vehicleid as INT64), -1) AS vehicleid,
              coalesce(CAST(tp_customer_vehicles.customerid as INT64), -1) AS customerid,
              CAST(tp_customer_vehicles.vehiclenumber as STRING) AS licenseplatenumber,
              coalesce(CAST(tp_customer_vehicles.vehiclestate as STRING), '') AS licenseplatestate,
              coalesce(CAST(tp_customer_vehicles.vehiclecountry as STRING), '') AS licenseplatecountry,
              CAST(tp_customer_vehicles.year as INT64) AS vehicleyear,
              CAST(tp_customer_vehicles.make as STRING) AS vehiclemake,
              CAST(tp_customer_vehicles.model as STRING) AS vehiclemodel,
              CAST(tp_customer_vehicles.color as STRING) AS vehiclecolor,
              coalesce(CAST(tp_customer_vehicles.starteffectivedate as DATETIME), DATETIME '1900-01-01 00:00:00') AS vehiclestartdate,
              coalesce(CAST(tp_customer_vehicles.endeffectivedate as DATETIME), DATETIME '9999-12-31 00:00:00') AS vehicleenddate,
              coalesce(CAST(tp_customer_vehicles.vehiclestatusid as INT64), -1) AS vehiclestatusid,
              coalesce(CAST(vehiclestatus.vehiclestatuscode as STRING), 'Unknown') AS vehiclestatuscode,
              coalesce(CAST(vehiclestatus.vehiclestatusdesc as STRING), 'Unknown') AS vehiclestatusdesc,
              coalesce(case tp_customer_vehicles.vehicleclasscode when "" then 0 else SAFE_CAST(tp_customer_vehicles.vehicleclasscode  as int64) end,-1)  AS vehicleclassid,
    		    	--, ISNULL(CAST(TP_Customer_Vehicles.VehicleClassCode AS varchar(2)), '-1') AS VehicleClass          
              CAST(tp_customer_vehicles.docno as STRING) AS docno,
              coalesce(CAST(tp_customer_vehicles.tagid as STRING), '-1') AS tagid,
              CAST(tp_customer_vehicles.county as STRING) AS county,
              CAST(tp_customer_vehicles.vin as STRING) AS vin,
              coalesce(CAST(tp_customer_vehicles.contractualtypeid as INT64), -1) AS contractualtypeid,
              coalesce(CAST(contractualtype.contractualtypecode as STRING), 'Unknown') AS contractualtypecode,
              coalesce(CAST(contractualtype.contractualtypedesc as STRING), 'Unknown') AS contractualtypedesc,
      			  --, ISNULL(CAST(Dim_PlateType.PlateTypeID AS INT), -1) AS PlateTypeID
			        --, CAST(TP_Customer_Vehicles.IsProtected AS bit) AS IsProtected        
              coalesce(CAST(tp_customer_vehicles.isexempted as INT64), 0) AS exemptedflag,
          		--, CAST(TP_Customer_Vehicles.IsTempNumber AS bit) AS IsTempNumber   
              coalesce(CAST(tp_customer_vehicles.isinhv as INT64), 0) AS hvflag,
        			--, ISNULL(CAST(TP_Customer_Vehicles.IsVRH AS bit), 0) AS IsVRH -- Vehicle Registration Block flag      
              coalesce(CAST(tp_customer_vehicles.updateddate as DATETIME), DATETIME '1900-01-01 00:00:00') AS updateddate,
              coalesce(CAST(tp_customer_vehicles.lnd_updatedate as DATETIME), DATETIME '1900-01-01 00:00:00') AS lnd_updatedate,
              coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_updatedate
              --SELECT *
            FROM
              LND_TBOS.TollPlus_TP_Customer_Vehicles AS tp_customer_vehicles
              LEFT OUTER JOIN EDW_TRIPS.Dim_ContractualType AS contractualtype ON contractualtype.contractualtypeid = tp_customer_vehicles.contractualtypeid
              LEFT OUTER JOIN EDW_TRIPS.Dim_VehicleStatus AS vehiclestatus ON vehiclestatus.vehiclestatusid = tp_customer_vehicles.vehiclestatusid
            WHERE tp_customer_vehicles.lnd_updatedate > last_updateddate
      ;
      SET log_message = concat('Loaded ', stagetablename);
      IF trace_flag = 1 THEN
        --SELECT 'Calling: Utility.UpdateTableWithTable';
      END IF;
      --CALL EDW_TRIPS_SUPPORT.UpdateTableWithTable(stagetablename, tablename, identifyingcolumns, CAST(NULL as STRING));
      DROP TABLE IF EXISTS EDW_TRIPS.Dim_Vehicle_NEW;
      SET log_message = concat('Complited Incremental load from: ', substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_updateddate) as STRING), 1, 25));
    END IF;
    IF trace_flag = 1 THEN
      SELECT log_message;
    END IF;

    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL , NULL);
  END;