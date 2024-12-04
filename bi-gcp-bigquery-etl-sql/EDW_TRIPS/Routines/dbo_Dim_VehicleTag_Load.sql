CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Dim_VehicleTag_Load`(isfullload INT64)
BEGIN
/*
IF OBJECT_ID ('dbo.Dim_VehicleTag_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Dim_VehicleTag_Load
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_VehicleTag_Load 1

EXEC Utility.FromLog 'dbo.Dim_VehicleTag', 1
SELECT 'LND_TBOS.TollPlus.TP_Customer_Vehicle_Tags' Table_Name, COUNT_BIG(1) Row_Count FROM LND_TBOS.TollPlus.TP_Customer_Vehicle_Tags
SELECT 'dbo.Dim_VehicleTag' Table_Name, COUNT_BIG(1) Row_Count FROM dbo.Dim_VehicleTag  
SELECT TOP 100 * FROM dbo.Dim_VehicleTag
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_VehicleTag table. 

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

    DECLARE tablename STRING DEFAULT 'EDW_TRIPS.Dim_VehicleTag';
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_VehicleTag_Load';
    DECLARE log_start_date DATETIME;
    DECLARE stagetablename STRING DEFAULT 'EDW_TRIPS.Dim_VehicleTag_NEW';
    DECLARE last_vehicle_tags_date DATETIME;
    DECLARE last_customertags_date DATETIME;
    DECLARE identifyingcolumns STRING DEFAULT 'VehicleTagID';
    SET log_start_date = current_datetime('America/Chicago');
    IF (
        (SELECT COUNT(*) 
        FROM `EDW_TRIPS.INFORMATION_SCHEMA.TABLES` 
        WHERE table_name = lower(SUBSTR(tablename,STRPOS(tablename,'.')+1))) = 0
      ) THEN
      SET IsFullLoad = 1;
    END IF;
    IF isfullload = 1 THEN
      SET log_message = 'Started Full load';
      IF trace_flag = 1 THEN
        SELECT log_message;
      END IF;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      SELECT log_source,log_start_date,log_message, 'I';
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_VehicleTag;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_VehicleTag cluster by VehicleTagID
        AS
          --EXPLAIN
          SELECT
              coalesce(CAST(tp_customer_vehicle_tags.vehicletagid as INT64), 0) AS vehicletagid,
              coalesce(CAST(tp_customer_vehicle_tags.custtagid as INT64), 0) AS custtagid,
              coalesce(CAST(tp_customer_tags.customerid as INT64), -1) AS customerid,
              coalesce(SUBSTR(CAST(tp_customer_tags.serialno as STRING),1,12), '-1') AS tagid,
              coalesce(CAST(tp_customer_vehicle_tags.vehicleid as INT64), 0) AS vehicleid,
              coalesce(CAST(tp_customer_tags.tagtype as STRING), '') AS tagtype,
              coalesce(CAST(tp_customer_tags.tagstatus as STRING), '') AS tagstatus,
              CAST(tp_customer_tags.tagagency as STRING) AS tagagency,
              CAST(tp_customer_tags.mounting as STRING) AS tagmounting,
              CAST(tp_customer_tags.specialitytag as STRING) AS tagspeciality,
              coalesce(CAST(tp_customer_tags.tagstartdate as DATE), DATE '1900-01-01') AS tagstatusdate,
              coalesce(CAST(tp_customer_vehicle_tags.starteffectivedate as DATE), DATE '1900-01-01') AS tagstartdate,
              coalesce(CAST(tp_customer_vehicle_tags.endeffectivedate as DATE), DATE '9999-12-31') AS tagenddate,
              CAST(tp_customer_tags.isnonrevenue as INT64) AS nonrevenueflag,
              coalesce(CAST(tp_customer_vehicle_tags.updateddate as DATETIME), DATETIME '1900-01-01 00:00:00') AS updateddate,
              coalesce(CAST(tp_customer_vehicle_tags.lnd_updatedate as DATETIME), DATETIME '1900-01-01 00:00:00') AS lnd_updatedate,
              coalesce(log_start_date, DATETIME '1900-01-01 00:00:00') AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_TP_Customer_Vehicle_Tags AS tp_customer_vehicle_tags
              LEFT OUTER JOIN LND_TBOS.TollPlus_TP_Customer_Tags AS tp_customer_tags ON tp_customer_tags.custtagid = tp_customer_vehicle_tags.custtagid
          UNION ALL
          SELECT
              -1 AS vehicletagid,
              -1 AS custtagid,
              -1 AS customerid,
              '-1' AS tagid,
              -1 AS vehicleid,
              '' AS tagtype,
              '' AS tagstatus,
              '' AS tagagency,
              '' AS tagmounting,
              '' AS tagspeciality,
              '1900-01-01' AS tagstatusdate,
              '1900-01-01' AS tagstartdate,
              '1900-01-01' AS tagenddate,
              0 AS nonrevenueflag,
              '1900-01-01' AS updateddate,
              '1900-01-01' AS lnd_updatedate,
              log_start_date AS edw_updatedate
      ;
      SET log_message = concat('Loaded ', tablename);
      --Table swap! 
      --CALL EDW_TRIPS_SUPPORT.TableSwap(stagetablename, tablename);
      SET log_message = 'Completed full load';
    ELSE
      CALL EDW_TRIPS_SUPPORT.Get_UpdatedDate(tablename, last_vehicle_tags_date);
      CALL EDW_TRIPS_SUPPORT.Get_UpdatedDate('Dim_VehicleTag/TP_Customer_Tags', last_customertags_date);
      SET log_message = concat('Started Incremental load from: ', substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_vehicle_tags_date) as STRING), 1, 25));
      IF trace_flag = 1 THEN
        SELECT log_message;
      END IF;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_VehicleTag_NEW;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_VehicleTag_NEW cluster by VehicleTagID
        AS
          SELECT
              coalesce(CAST(tp_customer_vehicle_tags.vehicletagid as INT64), 0) AS vehicletagid,
              coalesce(CAST(tp_customer_vehicle_tags.custtagid as INT64), 0) AS custtagid,
              coalesce(CAST(tp_customer_tags.customerid as INT64), -1) AS customerid,
              coalesce(SUBSTR(CAST(tp_customer_tags.serialno as STRING),1,12), '-1') AS tagid,
              coalesce(CAST(tp_customer_vehicle_tags.vehicleid as INT64), 0) AS vehicleid,
              coalesce(CAST(tp_customer_tags.tagtype as STRING), '') AS tagtype,
              coalesce(CAST(tp_customer_tags.tagstatus as STRING), '') AS tagstatus,
              CAST(tp_customer_tags.tagagency as STRING) AS tagagency,
              CAST(tp_customer_tags.mounting as STRING) AS tagmounting,
              CAST(tp_customer_tags.specialitytag as STRING) AS tagspeciality,
              coalesce(CAST(tp_customer_tags.tagstartdate as DATE), DATE '1900-01-01') AS tagstatusdate,
              coalesce(CAST(tp_customer_vehicle_tags.starteffectivedate as DATE), DATE '1900-01-01') AS tagstartdate,
              coalesce(CAST(tp_customer_vehicle_tags.endeffectivedate as DATE), DATE '9999-12-31') AS tagenddate,
              CAST(tp_customer_tags.isnonrevenue as INT64) AS nonrevenueflag,
              coalesce(CAST(tp_customer_vehicle_tags.updateddate as DATETIME), DATETIME '1900-01-01 00:00:00') AS updateddate,
              coalesce(CAST(tp_customer_vehicle_tags.lnd_updatedate as DATETIME), DATETIME '1900-01-01 00:00:00') AS lnd_updatedate,
              coalesce(log_start_date, DATETIME '1900-01-01 00:00:00') AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_TP_Customer_Vehicle_Tags AS tp_customer_vehicle_tags
              LEFT OUTER JOIN LND_TBOS.TollPlus_TP_Customer_Tags AS tp_customer_tags  ON tp_customer_tags.custtagid = tp_customer_vehicle_tags.custtagid
            WHERE tp_customer_vehicle_tags.custtagid IN(
              SELECT
                  custtagid
                FROM
                  LND_TBOS.TollPlus_TP_Customer_Tags AS tp_customer_tags_0
                WHERE lnd_updatedate > last_customertags_date
              UNION DISTINCT
              SELECT
                  custtagid
                FROM
                  LND_TBOS.TollPlus_TP_Customer_Vehicle_Tags AS tp_customer_vehicle_tags_0
                WHERE lnd_updatedate > last_vehicle_tags_date
            )
      ;
      SET log_message = concat('Loaded ', stagetablename);
      --CALL EDW_TRIPS_SUPPORT.UpdateTableWithTable(stagetablename, tablename, identifyingcolumns, CAST(NULL as STRING));
      --Dropping Records From Main Table To Avoid Duplicates
		    SET sql = concat("Delete From ", tablename , " where ", identifyingcolumns ," In ( Select ", identifyingcolumns , " from ",stagetablename , " )" );
		    EXECUTE IMMEDIATE sql;
		
		    --Inserting NEW Records from Stage to Main Table
		    SET sql = concat("Insert Into  ", tablename , " Select * from ",stagetablename );
		    EXECUTE IMMEDIATE sql;
      IF trace_flag = 1 THEN
        --SELECT 'Calling: Utility.UpdateTableWithTable';
      END IF;
      DROP TABLE IF EXISTS EDW_TRIPS.Dim_VehicleTag_NEW;
      SET log_message = concat('Completed Incremental load from: ', substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_vehicle_tags_date) as STRING), 1, 25));
    END IF;
    set last_customertags_date = Null ; -- Setting last_customertags_date to Null to Pass it to Set_UpdatedDate
    CALL EDW_TRIPS_SUPPORT.Set_UpdatedDate('Dim_VehicleTag/TP_Customer_Tags', 'LND_TBOS.TollPlus_TP_Customer_Tags', last_customertags_date);
    IF trace_flag = 1 THEN
      SELECT log_message;
    END IF;

    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
  /*
-- DEVELOPMENT ARIA --

List of columns were deleted. Save for situation we need to bring them again:

--, ISNULL(CAST(TP_Customer_Vehicle_Tags.ICNID AS int), 0) AS ICNID
--, CAST(TP_Customer_Tags.TagAlias AS varchar(20)) AS TagAlias
--, CAST(TP_Customer_Tags.HexTagID AS varchar(20)) AS HexTagID
--, CAST(TP_Customer_Tags.ItemCode AS varchar(20)) AS TagItemCode
--, ISNULL(CAST(TP_Customer_Vehicle_Tags.IsBlockListed AS bit), 0) AS IsBlockListed
--, ISNULL(CAST(TP_Customer_Tags.IsDFWBlocked AS bit), 0) AS IsDFWBlocked
--, ISNULL(CAST(TP_Customer_Tags.IsDALBlocked AS bit), 0) AS IsDALBlocked
--, CAST(TP_Customer_Tags.IsGroundTransportation AS bit) AS IsGroundTransportation




*/
END;