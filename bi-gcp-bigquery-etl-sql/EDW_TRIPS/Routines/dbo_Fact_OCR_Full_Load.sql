CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_OCR_Full_Load`()
BEGIN
  /*
IF OBJECT_ID ('dbo.Fact_OCR', 'P') IS NOT NULL DROP PROCEDURE dbo.Fact_OCR
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_OCR. 

@IsFullLoad - 1 means forced Full load, 0 or NULL - incremental load. If the main table is not exists - it goes with full load.

This Proc has been created to help OCR daily Loads. Initially OCR Report is consumed by Bubble. As bubble Fact_Unified_SUmmary table load happens weekly,
The Requirement is to give something daily . In addition, DayNIghtFlag says wheather the trip has happened in a day or NIght.

"1" represents Day. "0" Represents Night.

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
		Sagarika		2024-03-21	New!
		Shekhar			2024-05-14  Added TripStatusID to the final table for MSTR reporting need. 
						2024-05-16  Removed TPTripID to change the granularity of the table.

==============.=====================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_OCR_Full_Load 

EXEC Utility.FromLog 'dbo.Fact_OCR', 1
SELECT 'dbo.Fact_OCR' Table_Name, COUNT_BIG(1) Row_Count FROM dbo.Fact_OCR
SELECT TOP 100 * FROM dbo.Fact_OCR
###################################################################################################################
*/

    DECLARE stagetablename STRING DEFAULT 'EDW_TRIPS.Fact_OCR_NEW';
    DECLARE log_message STRING;
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_OCR_Full_Load';
    DECLARE tablename STRING DEFAULT 'EDW_TRIPS.Fact_OCR';
    DECLARE log_start_date DATETIME;
    BEGIN
      DECLARE row_count INT64;
      DECLARE trace_flag INT64 DEFAULT 1; -- Testing
      DECLARE last_updateddate DATETIME;
      DECLARE identifyingcolumns STRING DEFAULT 'VehicleID';
      DECLARE sql STRING;
      DECLARE wheresql STRING DEFAULT '';
      SET log_start_date = current_datetime('America/Chicago');

      		
	   --=============================================================================================================
	   		-- Load Stage.IPS_Image_Review_Results_Daily	6:00	( (1171784068 row(s) affected)
	   --=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS_STAGE.IPS_Image_Review_Results_OCR;  -- (689882940 row(s) affected)
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.IPS_Image_Review_Results_OCR CLUSTER BY TPTripID
        AS
          SELECT
              t.imagereviewresultid,
              t.ipstransactionid,
              t.tptripid,
              t.manuallyreviewedflag,
              t.createduser,
              t.createddate,
              t.updateduser,
              t.updateddate,
              current_datetime() AS edw_updatedate
            FROM
              (
                SELECT
                    imagereviewresultid,
                    ipstransactionid,
                    sourcetransactionid AS tptripid,
                    ismanuallyreviewed AS manuallyreviewedflag,
                    irr.createduser,
                    irr.createddate,
                    irr.updateduser,
                    irr.updateddate,
                    row_number() OVER (PARTITION BY sourcetransactionid ORDER BY imagereviewresultid DESC) AS rn
                  FROM
                    LND_TBOS.TollPlus_TP_Image_Review_Results AS irr
                    LEFT OUTER JOIN EDW_TRIPS.Dim_Lane AS l ON l.ips_facilitycode = irr.facilitycode
                     AND l.ips_plazacode = irr.plazacode
                     AND l.lanenumber = CAST(irr.lanecode as STRING)
                  WHERE irr.timestamp >='2021-01-01'
                   AND irr.lnd_updatetype <> 'D'
              ) AS t
            WHERE t.rn = 1
      ;
 
		--=============================================================================================================
				-- Load Fact_OCR	
		--=============================================================================================================
		
      -- DROP TABLE IF EXISTS EDW_TRIPS.Fact_OCR_NEW;
      CREATE OR REPLACE TABLE EDW_TRIPS.Fact_OCR CLUSTER BY TripDayID
        AS
          SELECT
              --TT.TpTripID,
              coalesce(CAST(FORMAT_TIMESTAMP('%Y%m%d', tt.exittripdatetime) AS INT64), -1) AS tripdayid,
              CASE
                WHEN extract(hour from tt.exittripdatetime) > 7
                 AND extract(hour from tt.exittripdatetime) < 19 THEN '1'
                ELSE '0'
              END AS daynightflag,
              --TT.ExitTripDateTime,
              tt.exitlaneid AS laneid,
              tt.tripstatusid,              -- Added by Shekhar for MSTR on 5/14/2024
              dtim.tripidentmethodid,
              coalesce(irr.manuallyreviewedflag, 0) AS manuallyreviewedflag,
              sum(tt.tollamount) AS tollamount,
              count(*) AS txncount,
              coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_TP_Trips AS tt
              INNER JOIN EDW_TRIPS.Dim_TripIdentMethod AS dtim ON dtim.tripidentmethod = tt.tripidentmethod
              LEFT OUTER JOIN EDW_TRIPS_STAGE.IPS_Image_Review_Results_OCR AS irr ON irr.tptripid = tt.tptripid
            WHERE tt.sourceofentry IN(
              1, 3
            )   -- TSA & NTTA 
             AND tt.exit_tolltxnid >= 0
             AND tt.exittripdatetime > '2021-01-01' -- @Load_Cutoff_Date
             AND tt.exittripdatetime < current_datetime()
             --AND TT.TpTripID in (5585698810,5317497867,5320564131,5320351224)
            GROUP BY --TT.TpTripID,
                     coalesce(CAST(FORMAT_TIMESTAMP('%Y%m%d', tt.exittripdatetime) AS INT64), -1),
                      CASE
                          WHEN extract(hour from tt.exittripdatetime) > 7 AND extract(hour from tt.exittripdatetime) < 19 THEN '1'
                          ELSE '0'
                      END, 
                     --TT.ExitTripDateTime,
                     tt.exitlaneid, 
                     tt.tripstatusid, 
                     dtim.tripidentmethodid, 
                     irr.manuallyreviewedflag
      ;

      SET log_message = concat('Loaded ', tablename);

      --TableSwap is Not Required, using Create or Replace Table
      -- CALL EDW_TRIPS_SUPPORT.TableSwap(stagetablename, tablename);
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
        RAISE USING MESSAGE = error_message;  -- Rethrow the error!
      END;
    END;

    /*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Fact_OCR_Full_Load 1

SELECT  * FROM dbo.Fact_OCR
where laneID = 16 and TripDayID = 20240201
order by TripDayID, LaneID, DayNightFlag

SELECT  'dbo.Fact_OCR_Full_Load' Table_Name, * FROM dbo.Fact_OCR
where laneID = 16 and TripDayID = 20240201
order by TripDayID, LaneID, DayNightFlag


select * from Stage.IPS_Image_Review_Results_OCR where TPTripID = 5869664114 -- NULL
select * from Stage.IPS_Image_Review_Results_OCR where TPTripID = 5872735548 -- 0
select * from Stage.IPS_Image_Review_Results_OCR where TPTripID = 5873071003 -- 1


select * from LND_TBOS.Tollplus.TP_Trips where TPTripID = 5873071003 --5869664114	
--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================


*/

  END;