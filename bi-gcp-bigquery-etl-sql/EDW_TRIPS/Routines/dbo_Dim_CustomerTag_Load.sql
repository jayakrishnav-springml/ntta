CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Dim_CustomerTag_Load`(isfullload INT64)
BEGIN
/*
IF OBJECT_ID ('dbo.Dim_CustomerTag_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Dim_CustomerTag_Load
GO
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_CustomerTag table. 

@IsFullLoad - 1 means forced Full load, 0 or NULL - incremental load. If the main table doesn't exists - It goes with full load.

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0038319 	Andy		2021-03-08	New!
CHG0039156  Sagarika    2021-06-24  Rename TagSpeciality as SpecialityTag, IsNonRevenue to NonRevenueFlag to avoid failure in Utility.UpdateTableWithTable for Incremental Loads and 
                                    Titlecase the TagStatus column values which are causing duplicate issue in Microstrategy Reports ( Eg: Assigned, ASSIGNED)		

###################################################################################################################
*/
    DECLARE sql STRING;
    DECLARE tablename STRING DEFAULT 'EDW_TRIPS.Dim_CustomerTag';
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_CustomerTag_Load';
    DECLARE log_start_date DATETIME;
    DECLARE stagetablename STRING DEFAULT 'EDW_TRIPS.Dim_CustomerTag_NEW';
    DECLARE last_customertags_date DATETIME;
    DECLARE identifyingcolumns STRING DEFAULT 'CustTagID';
    SET log_start_date = current_datetime('America/Chicago');
    IF (SELECT count(1) FROM  `EDW_TRIPS.INFORMATION_SCHEMA.TABLES` WHERE tablename='EDW_TRIPS.Dim_CustomerTag') =0 THEN
      SET isfullload = 1;
    END IF;
    IF isfullload = 1 THEN
      SET log_message = 'Started Full load';
      IF trace_flag = 1 THEN 
        SELECT log_message;
      END IF;
      
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));


      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_CustomerTag;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_CustomerTag CLUSTER BY CustTagID
        AS
          SELECT
              coalesce(CAST(TollPlus_TP_Customer_Tags.custtagid as INT64), 0) AS custtagid,
              coalesce(CAST(TollPlus_TP_Customer_Tags.customerid as INT64), -1) AS customerid,
              coalesce(SUBSTR(CAST(TollPlus_TP_Customer_Tags.serialno as STRING),1,12), '-1') AS tagid,
              coalesce(CAST(TollPlus_TP_Customer_Tags.channelid as INT64), -1) AS channelid,
              CAST(TollPlus_TP_Customer_Tags.tagagency as STRING) AS tagagency,
              coalesce(CAST(TollPlus_TP_Customer_Tags.tagtype as STRING), '') AS tagtype,
              coalesce(replace(replace(replace(replace(replace(concat(left(upper(TollPlus_TP_Customer_Tags.tagstatus), 1), substr(lower(TollPlus_TP_Customer_Tags.tagstatus), 2, CASE
                WHEN 2 < 1 THEN greatest(2 + (length(rtrim(TollPlus_TP_Customer_Tags.tagstatus)) - 1), 0)
                ELSE length(rtrim(TollPlus_TP_Customer_Tags.tagstatus))
              END)), 'Received', 'Received'), 'Replacement', 'Replacement'), 'Damaged', 'Damaged'), 'Defective', 'Defective'), 'Inactive', 'Inactive'), '') AS tagstatus,
              coalesce(CAST(TollPlus_TP_Customer_Tags.tagstartdate as DATE), DATE '1900-01-01') AS tagstatusstartdate,
              coalesce(CAST(TollPlus_TP_Customer_Tags.tagenddate as DATE), DATE '9999-12-31') AS tagstatusenddate,
              coalesce(CAST(TollPlus_TP_Customer_Tags.tagassigneddate as DATE), DATE '1900-01-01') AS tagassigneddate,
              coalesce(CAST(TollPlus_TP_Customer_Tags.tagassignedenddate as DATE), DATE '9999-12-31') AS tagassignedenddate,
              CAST(TollPlus_TP_Customer_Tags.itemcode as STRING) AS itemcode,
              CAST(TollPlus_TP_Customer_Tags.mounting as STRING) AS mounting,
              CAST(TollPlus_TP_Customer_Tags.specialitytag as STRING) AS specialitytag,
              coalesce(CAST(TollPlus_TP_Customer_Tags.isnonrevenue as INT64), 0) AS nonrevenueflag,
              coalesce(CAST(TollPlus_TP_Customer_Tags.updateddate as DATETIME), DATETIME '1900-01-01 00:00:00') AS updateddate,
              coalesce(CAST(TollPlus_TP_Customer_Tags.lnd_updatedate as DATETIME), DATETIME '1900-01-01 00:00:00') AS lnd_updatedate,
              coalesce(log_start_date, DATETIME '1900-01-01 00:00:00') AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_TP_Customer_Tags
          UNION ALL
          SELECT
              -1 AS custtagid,
              -1 AS customerid,
              '-1' AS tagid,
              -1 AS channelid,
              '' AS tagagency,
              '' AS tagtype,
              '' AS tagstatus,
              '1900-01-01' AS tagstatusstartdate,
              '9999-12-31' AS tagstatusenddate,
              '1900-01-01' AS tagassigneddate,
              '9999-12-31' AS tagassignedenddate,
              '' AS itemcode,
              '' AS mounting,
              '' AS specialitytag,
              0 AS nonrevenueflag,
              '1900-01-01' AS updateddate,
              '1900-01-01' AS lnd_updatedate,
              log_start_date AS edw_updatedate
      ;
      SET log_message = concat('Loaded ', tablename);
      
    
      
      -- Table swap!
      --TableSwap is Not Required,using  Create or Replace Table
      --CALL EDW_TRIPS_SUPPORT.TableSwap(stagetablename, tablename);
      SET log_message = 'Completed Full load';
    ELSE
      CALL EDW_TRIPS_SUPPORT.Get_UpdatedDate(tablename, last_customertags_date);
      SET log_message = concat('Started Incremental load from: ', CAST(last_customertags_date as STRING));     
      IF trace_flag = 1 THEN 
        SELECT log_message;
      END IF;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      
      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_CustomerTag_NEW;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_CustomerTag_NEW CLUSTER BY CustTagID
        AS
          SELECT
              coalesce(CAST(TollPlus_TP_Customer_Tags.custtagid as INT64), 0) AS custtagid,
              coalesce(CAST(TollPlus_TP_Customer_Tags.customerid as INT64), -1) AS customerid,
              coalesce(SUBSTR(CAST(TollPlus_TP_Customer_Tags.serialno as STRING),1,12), '-1') AS tagid,
              coalesce(CAST(TollPlus_TP_Customer_Tags.channelid as INT64), -1) AS channelid,
              CAST(TollPlus_TP_Customer_Tags.tagagency as STRING) AS tagagency,
              coalesce(CAST(TollPlus_TP_Customer_Tags.tagtype as STRING), '') AS tagtype,
              coalesce(replace(replace(replace(replace(replace(concat(left(upper(TollPlus_TP_Customer_Tags.tagstatus), 1), substr(lower(TollPlus_TP_Customer_Tags.tagstatus), 2, CASE
                WHEN 2 < 1 THEN greatest(2 + (length(rtrim(TollPlus_TP_Customer_Tags.tagstatus)) - 1), 0)
                ELSE length(rtrim(TollPlus_TP_Customer_Tags.tagstatus))
              END)), 'Received', 'Received'), 'Replacement', 'Replacement'), 'Damaged', 'Damaged'), 'Defective', 'Defective'), 'Inactive', 'Inactive'), '') AS tagstatus,
              coalesce(CAST(TollPlus_TP_Customer_Tags.tagstartdate as DATE), DATE '1900-01-01') AS tagstatusstartdate,
              coalesce(CAST(TollPlus_TP_Customer_Tags.tagenddate as DATE), DATE '9999-12-31') AS tagstatusenddate,
              coalesce(CAST(TollPlus_TP_Customer_Tags.tagassigneddate as DATE), DATE '1900-01-01') AS tagassigneddate,
              coalesce(CAST(TollPlus_TP_Customer_Tags.tagassignedenddate as DATE), DATE '9999-12-31') AS tagassignedenddate,
              CAST(TollPlus_TP_Customer_Tags.itemcode as STRING) AS itemcode,
              CAST(TollPlus_TP_Customer_Tags.mounting as STRING) AS mounting,
              CAST(TollPlus_TP_Customer_Tags.specialitytag as STRING) AS specialitytag,
              coalesce(CAST(TollPlus_TP_Customer_Tags.isnonrevenue as INT64), 0) AS nonrevenueflag,
              coalesce(CAST(TollPlus_TP_Customer_Tags.updateddate as DATETIME), DATETIME '1900-01-01 00:00:00') AS updateddate,
              coalesce(CAST(TollPlus_TP_Customer_Tags.lnd_updatedate as DATETIME), DATETIME '1900-01-01 00:00:00') AS lnd_updatedate,
              coalesce(log_start_date, DATETIME '1900-01-01 00:00:00') AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_TP_Customer_Tags
            WHERE TollPlus_TP_Customer_Tags.lnd_updatedate > last_customertags_date
      ;
      SET log_message = concat('Loaded ', stagetablename);
      IF trace_flag = 1 THEN 
        --SELECT 'Calling: Utility.UpdateTableWithTable';
      END IF;
      --CALL utility.updatetablewithtable(stagetablename, tablename, identifyingcolumns, CAST(NULL as STRING));
      --Dropping Records From Main Table To Avoid Duplicates
		    SET sql = concat("Delete From ", tablename , " where ", identifyingcolumns ," In ( Select ", identifyingcolumns , " from ",stagetablename , " )" );
		    EXECUTE IMMEDIATE sql;
		
		    --Inserting NEW Records from Stage to Main Table
		    SET sql = concat("Insert Into  ", tablename , " Select * from ",stagetablename );
		    EXECUTE IMMEDIATE sql;
      
      DROP TABLE IF EXISTS EDW_TRIPS.Dim_CustomerTag_NEW;
      SET log_message = concat('Completed Incremental load from: ', CAST(last_customertags_date as STRING));
    END IF;
    IF trace_flag = 1 THEN
      SELECT log_message;
    END IF;
    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
    /*###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_CustomerTag_Load 1

EXEC Utility.FromLog 'dbo.Dim_CustomerTag', 1
SELECT 'LND_TBOS.TollPlus.TP_Customer_Tags' Table_Name, COUNT_BIG(1) Row_Count FROM LND_TBOS.TollPlus.TP_Customer_Tags
SELECT 'dbo.Dim_CustomerTag' Table_Name, COUNT_BIG(1) Row_Count FROM dbo.Dim_CustomerTag  
SELECT TOP 100 'dbo.Dim_CustomerTag' Table_Name, * FROM dbo.Dim_CustomerTag
===================================================================================================================*/

  END;