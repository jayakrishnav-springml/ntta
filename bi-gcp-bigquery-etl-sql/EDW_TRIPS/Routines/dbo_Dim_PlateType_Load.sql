CREATE OR REPLACE PROCEDURE EDW_TRIPS.Dim_PlateType_Load(isfullload INT64)
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_PlateType table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Andy		YYYY-MM-DD	New!
===================================================================================================================

Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_PlateType_Load @IsFullLoad = 1

EXEC Utility.FromLog 'dbo.Dim_PlateType', 1
SELECT 'dbo.Dim_PlateType' Table_Name, * FROM dbo.Dim_PlateType ORDER BY 2 
###################################################################################################################
*/
    DECLARE tablename STRING DEFAULT 'EDW_TRIPS.Dim_PlateType';
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_PlateType_Load';
    DECLARE log_start_date DATETIME;
    DECLARE stagetablename STRING DEFAULT 'EDW_TRIPS.Dim_PlateType_NEW';
    DECLARE sql STRING;
    DECLARE last_updated_date DATETIME;
    DECLARE max_id INT64 DEFAULT 0;
    DECLARE columnname STRING DEFAULT 'PlateType';
    SET log_start_date = current_datetime('America/Chicago');
  
      
    IF (select count(*)  FROM EDW_TRIPS.INFORMATION_SCHEMA.TABLES  
          where table_name = split(tablename,'.')[1]) = 0 
      THEN
        set isfullload = 1;
    END IF;

    IF isfullload = 1 THEN
      SET log_message = 'Started Full load';
      IF trace_flag = 1 THEN 
        select log_message;
      END IF;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      
      CREATE or REPLACE TABLE EDW_TRIPS.Dim_PlateType
        AS
          SELECT
              row_number() OVER (ORDER BY a.platetype) AS platetypeid,
              a.platetype
            FROM
              (
                SELECT
                    rtrim(ltrim(tollplus_tp_trips.platetype)) AS platetype
                  FROM
                    lnd_tbos.tollplus_tp_trips
                  WHERE tollplus_tp_trips.platetype IS NOT NULL
                  GROUP BY rtrim(ltrim(platetype))
              ) AS a
          UNION ALL
          SELECT
              -1 AS platetypeid,
              'Unknown' AS platetype
      ;
      -- Commenting Utility Procedures get_transferobject_sql , Replacing it with the required logic in BQ syntax From get_transferobject_sql 
      -- Do not need these As we are Direclty using Create or Replace on Main Table 
      -- CALL utility.get_transferobject_sql(stagetablename, tablename, sql);
      -- get_transferobject_sql Returns SQL Script to Move Stage table to Target Table By Either Schema Change or Table Rename 
      -- In This case we have Same Schema we just need table Rename , Rename main to Old Table and then New Stage table to main Table
      
      -- set sql = 'Alter Table EDW_TRIPS.Dim_PlateType rename to Dim_PlateType_old;';
      -- IF trace_flag = 1 THEN
      -- Commenting Utility Procedures longprint , Replacing it with Select to log details while execution 
      -- CALL utility.longprint(sql);
      -- select sql;
      -- END IF;
      -- EXECUTE IMMEDIATE sql;

      -- set sql = 'Alter Table EDW_TRIPS.Dim_PlateType_NEW rename to Dim_PlateType;';
      -- IF trace_flag = 1 THEN
      -- Commenting Utility Procedures longprint, Replacing it with Select to log details while execution 
      -- CALL utility.longprint(sql);
      -- select sql;
      -- END IF;
      -- EXECUTE IMMEDIATE sql;
      SET log_message = 'Finished full load';
    ELSE
		  set max_id = (SELECT max(Dim_PlateType.platetypeid) FROM EDW_TRIPS.Dim_PlateType);
      
      -- Updating Dataset Name for Utility Procedure
      CALL EDW_TRIPS_SUPPORT.Get_UpdatedDate('Dim_PlateType/TOLLPLUS_TP_TRIPS', last_updated_date);
      SET log_message = concat('Started Incremental load from: ', substr(CAST(last_updated_date as STRING), 1, 25));
      IF trace_flag = 1 THEN
		    Select Log_Message;
      END IF;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
	  
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_PlateType_NEW
        AS
          SELECT
              max_id + row_number() OVER (ORDER BY a.platetype) AS platetypeid,
              a.platetype
            FROM
              (
                SELECT
                    rtrim(ltrim(tollplus_tp_trips.platetype)) AS platetype
                  FROM
                    lnd_tbos.tollplus_tp_trips
                  WHERE tollplus_tp_trips.platetype IS NOT NULL
                   AND tollplus_tp_trips.updateddate >= last_updated_date
                  GROUP BY rtrim(ltrim(platetype))
              ) AS a
            WHERE a.platetype NOT IN(
              SELECT
                  a.platetype
                FROM
                  EDW_TRIPS.Dim_PlateType
            )
      ;
      SET log_message = concat('Loaded ', stagetablename);

      INSERT INTO EDW_TRIPS.Dim_PlateType SELECT Dim_PlateType_NEW.* FROM EDW_TRIPS.Dim_PlateType_NEW;

      SET log_message = concat('Finished Incremental load from: ', substr(CAST(last_updated_date as STRING), 1, 25));
    END IF;

    set last_updated_date = Null ; -- Setting last_updated_date to Null for Set_UpdatedDate
    -- Updating Dataset Name for Utility Procedure
    CALL EDW_TRIPS_SUPPORT.Set_UpdatedDate('Dim_PlateType/TOLLPLUS_TP_TRIPS', 'LND_TBOS.TOLLPLUS_TP_TRIPS', last_updated_date);
    IF trace_flag = 1 THEN
      select log_message;
    END IF;
    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
    
/*
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_PlateType_Load @IsFullLoad = 1

EXEC Utility.FromLog 'dbo.Dim_PlateType', 1
SELECT count(*) 'dbo.Dim_PlateType' Table_Name, * FROM dbo.Dim_PlateType ORDER BY 2 

*/
  END;