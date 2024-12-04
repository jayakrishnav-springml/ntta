CREATE OR REPLACE PROCEDURE EDW_TRIPS.Dim_ReasonCode_Incr_Load()
BEGIN
/*
IF OBJECT_ID ('dbo.Dim_ReasonCode_Incr_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Dim_ReasonCode_Incr_Load
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_ReasonCode_Incr_Load 1

SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_ReasonCode%' ORDER BY 1 DESC 
SELECT * FROM dbo.Dim_ReasonCode ORDER BY 2 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_ReasonCode table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0038319 	Andy		2021-03-08	New!
CHG0040134	Shankar		2021-12-15	Misc. Optimization.
CHG0041377	Shankar		2022-08-22	This proc should not run in full load mode after initial load to avoid SK values
									changing from one load to another, which causes data problems in fact tables.
									Renamed the proc to dbo.Dim_ReasonCode_Incr_Load and now it does only incr load.
###################################################################################################################
*/
    DECLARE last_updated_date DATETIME;
    DECLARE last_updated_date_new DATETIME default Null;
    DECLARE log_message STRING;
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_ReasonCode_Incr_Load';
    DECLARE log_start_date DATETIME;
    DECLARE max_id INT64 DEFAULT 0;
    DECLARE row_count INT64;
    DECLARE tablename STRING DEFAULT 'EDW_TRIPS.Dim_ReasonCode';
    DECLARE stagetablename STRING DEFAULT 'EDW_TRIPS.Dim_ReasonCode_NEW';
    DECLARE sql STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    SET log_start_date = current_datetime('America/Chicago');
    
/*
	--===========================================================================================================================================================================
	--:: DANGER! RISK OF DUMMY PRIMARY KEY VALUES CHANGING ON NEXT FULL LOAD! NEVER ENTERTAIN FULL LOAD OF DIM TABLES WHERE PRIMARY KEY VALUE DOES "NOT" COME FROM SOURCE SYSTEM.
	--===========================================================================================================================================================================
	IF @IsFullLoad = 1
	BEGIN

		SET @Log_Message = 'Started Full load'
		IF @trace_flag = 1 PRINT @Log_Message
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

		IF OBJECT_ID('dbo.Dim_ReasonCode_NEW','U') IS NOT NULL			DROP TABLE dbo.Dim_ReasonCode_NEW;
		CREATE TABLE dbo.Dim_ReasonCode_NEW WITH (CLUSTERED INDEX(ReasonCodeID), DISTRIBUTION = REPLICATE) AS
		SELECT ROW_NUMBER() OVER (ORDER BY ReasonCode) AS ReasonCodeID, ReasonCode, @Log_Start_Date AS EDW_UpdateDate
		FROM (
					SELECT
						RTRIM(LTRIM(ReasonCode)) AS ReasonCode 
					FROM LND_TBOS.TOLLPLUS.TP_TRIPS
					WHERE ReasonCode IS NOT NULL
					GROUP BY RTRIM(LTRIM(ReasonCode))
				) A
		UNION ALL
		SELECT -1 AS ReasonCodeID, 'Unknown' AS ReasonCode, @Log_Start_Date AS EDW_UpdateDate
		OPTION (LABEL = 'dbo.Dim_ReasonCode_NEW');

		SET  @Log_Message = 'Loaded ' + @StageTableName
		EXEC Utility.FastLog @Log_Source, @Log_Message, -1

		CREATE STATISTICS STAT_dbo_Dim_ReasonCode_001 ON dbo.Dim_ReasonCode_NEW (ReasonCode);

		## Table swap!
		EXEC Utility.TableSwap @StageTableName, @TableName

		SET @Log_Message = 'Completed full load'

	END

*/  
    SET max_id = (
                  SELECT
                    MAX(Dim_ReasonCode.reasoncodeid) AS max_id
                  FROM
                    EDW_TRIPS.Dim_ReasonCode );
    CALL EDW_TRIPS_SUPPORT.Get_UpdatedDate('Dim_ReasonCode/TOLLPLUS_TP_TRIPS', last_updated_date);
    SET log_message = concat('Started Incremental load from: ', substr(CAST(last_updated_date as STRING FORMAT 'yyyy-mm-dd hh:mi:ss.mmmm'), 1, 25));
    If trace_flag  = 1 THEN 
      SELECT log_message;
    END IF ;
    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
    
    CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.Dim_ReasonCode
      AS
        SELECT
            coalesce(max_id, 0) + row_number() OVER (ORDER BY a.reasoncode) AS reasoncodeid,
            a.reasoncode,
            log_start_date AS edw_updatedate
        FROM
          (
            SELECT 
                DISTINCT rtrim(ltrim(tt.reasoncode)) AS reasoncode
            FROM
              LND_TBOS.TOLLPLUS_TP_TRIPS AS tt
            WHERE 
              tt.reasoncode IS NOT NULL
              AND tt.lnd_updatedate > last_updated_date
              AND NOT EXISTS (
              SELECT
                  1
              FROM
                EDW_TRIPS.Dim_ReasonCode AS rc
              WHERE rc.reasoncode = tt.reasoncode
              )
          ) AS a;
    SET row_count = (SELECT
                      count(1) AS row_count
                    FROM
                      EDW_TRIPS_STAGE.Dim_ReasonCode);
    IF row_count > 0 THEN
      INSERT INTO EDW_TRIPS.Dim_ReasonCode (reasoncodeid, reasoncode, edw_updatedate)
        SELECT
            Dim_ReasonCode.*
        FROM
          EDW_TRIPS_STAGE.Dim_ReasonCode;
      SET log_message = concat('Inserted ', substr(CAST(row_count as STRING), 1, 30), ' rows into EDW_TRIPS.Dim_ReasonCode');
      -- Added ToLog here Insted of fastlog
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
    END IF;
    CALL EDW_TRIPS_SUPPORT.Set_UpdatedDate('Dim_ReasonCode/TOLLPLUS_TP_TRIPS', 'LND_TBOS.TOLLPLUS_TP_TRIPS', last_updated_date_new);
    SET log_message = concat('Completed Incremental load from: ', substr(CAST(last_updated_date as STRING), 1, 25));
    -- Added ToLog here Insted of fastlog
    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL , NULL);
    IF trace_flag = 1 THEN
      SELECT
          *
        FROM
          EDW_TRIPS_SUPPORT.ProcessLog
        WHERE ProcessLog.logsource LIKE '%Dim_ReasonCode%'
      ORDER BY
        1 DESC
      LIMIT 5
      ;
      SELECT
          *
        FROM
          EDW_TRIPS_SUPPORT.LoadProcessControl
        WHERE LoadProcessControl.tablename = 'Dim_ReasonCode/TOLLPLUS.TP_TRIPS'
      ;
      SELECT
          *
        FROM
          EDW_TRIPS.Dim_ReasonCode
      ORDER BY
        1 DESC
      ;
      SELECT DISTINCT
          rtrim(ltrim(tt.reasoncode)) AS reasoncode
        FROM
          LND_TBO.Tollplus_TP_Trips AS tt
        WHERE tt.reasoncode IS NOT NULL
        AND tt.lnd_updatedate > last_updated_date
      ;
    END IF;

    
/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================
SELECT * FROM Utility.LoadProcessControl WHERE TableName = 'Dim_ReasonCode/TOLLPLUS.TP_TRIPS'
EXEC dbo.Dim_ReasonCode_Incr_Load 
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_ReasonCode%' ORDER BY 1 desc
 
--:: Testing

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'Dim_ReasonCode/TOLLPLUS.TP_TRIPS', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  

EXEC Utility.Set_UpdatedDate 'Dim_ReasonCode/TOLLPLUS.TP_TRIPS', NULL, '2022-08-01'

EXEC dbo.Dim_ReasonCode_Incr_Load 

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'Dim_ReasonCode/TOLLPLUS.TP_TRIPS', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  

SELECT TOP 10 * FROM Utility.ProcessLog WHERE LogSource LIKE '%Dim_ReasonCode%' ORDER BY 1 desc
SELECT * FROM dbo.Dim_ReasonCode ORDER BY 1 DESC
SELECT * FROM Utility.LoadProcessControl WHERE TableName = 'Dim_ReasonCode/TOLLPLUS.TP_TRIPS'

*/
END;