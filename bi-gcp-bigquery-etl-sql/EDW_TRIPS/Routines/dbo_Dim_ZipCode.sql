CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Dim_ZipCode_Full_Load`()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_ZipCode table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0044405	Shankar		2024-01-04	New!
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_ZipCode_Full_Load
SELECT 'TollPlus.ZipCodes' Table_name,* FROM LND_TBOS.TollPlus.ZipCodes ORDER BY 2
SELECT TOP 100 'dbo.Dim_ZipCode' Table_Name, * FROM dbo.Dim_ZipCode ORDER BY 2
###################################################################################################################
*/

    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_ZipCode_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0; -- Testing
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);

		--=============================================================================================================
		-- Load dbo.Dim_ZipCode
		--=============================================================================================================

	  --DROP TABLE IF EXISTS dbo.dim_zipcode;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_Zipcode
        AS
          SELECT
              zipcodes.zipcode,
              zipcodes.city,
              coalesce(nullif(zipcodes.county, 'UNKNOWN'), 'UNK') AS county,
              zipcodes.state,
              zipcodes.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_ZipCodes zipcodes
          UNION ALL
          SELECT
              'UNK',
              'UNKOWN',
              'UNK',
              'UNK',
              current_datetime(),
              current_datetime()
      ; --> Conventional -1 row in a Dim Table. Here UNK = -1.
      SET log_message = 'Loaded EDW_TRIPS.Dim_ZipCode';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
	  -- Table Swap Not Required as we are using Create or Replace in BQ
      --CALL EDW_TRIPS_utility.TableSwap('dbo.Dim_ZipCode_NEW', 'dbo.Dim_ZipCode');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);
      
	  -- Show results
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Dim_ZipCode' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_Zipcode
        ORDER BY
          2 DESC
        LIMIT 1000
        ;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
        RAISE USING MESSAGE = error_message;  -- Rethrow the error!
      END;
    END;
  END;