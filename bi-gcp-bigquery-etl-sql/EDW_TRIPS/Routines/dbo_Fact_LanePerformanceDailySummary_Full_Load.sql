CREATE OR REPLACE PROCEDURE EDW_TRIPS.Fact_LanePerformanceDailySummary_Full_Load()
BEGIN
/*
IF OBJECT_ID ('dbo.Fact_LanePerformanceDailySummary_Full_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Fact_LanePerformanceDailySummary_Full_Load
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_LanePerformanceDailySummary_Full_Load table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG00XXXXX	Shekhar/Sagarika		2021-12-09	Created
			Shekhar					2022-03-28  Added a where clause to avoid future trips as they are causing a sudden 
											    drop the graph shown on dashboard (As of today, there are some future
												dated trips (ExitTripDateTime) in the TP_Trips table. )
			Shekhar					2022-03-28	Added extra comments for clarity


Description
	Fact_LanePerformanceDailySummary table is used to build 2 Microstrategy dashboards
		1. Lane Performance dashboard
		2. Misclass dashboard (Misclass dashboard uses one more fact table in addition to this one - Fact_Misclass)

	In the future, this table can source data from EDW_Trips.dbo.Fact_UnifiedTransaction instead of 
	LND_TBOS.Tollplus.TP_Trips. Currently (as of 3/28/2022) Fact_UnifiedTranscation table does not
	contain Airport and IOP Inbound trips.

	Note: as of 3/28/2022, this procedure takes around 22 min to run in DEV.

			Sagarika				2023-03-12  Added TollAmount to track the Dollar Amount Leaking Locations.


===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_LanePerformanceDailySummary_Full_Load

EXEC Utility.FromLog 'dbo.Fact_LanePerformanceDailySummary_Full_Load', 1
SELECT TOP 100 'dbo.Fact_LanePerformanceDailySummary_Full_Load' Table_Name, * FROM dbo.Fact_LanePerformanceDailySummary_Full_Load ORDER BY 2
###################################################################################################################
*/
		DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_LanePerformanceDailySummary_Full_Load';
		DECLARE log_start_date DATETIME;
		DECLARE log_message STRING;
		DECLARE trace_flag INT64 DEFAULT 0;
		BEGIN
			DECLARE row_count INT64;
			SET log_start_date = current_datetime('America/Chicago');
			
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
			Select log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING);

			--=============================================================================================================
				-- Load dbo.Fact_LanePerformanceDailySummary_Full_Load
			--=============================================================================================================

			CREATE OR REPLACE TABLE EDW_TRIPS.Fact_LanePerformanceDailySummary
				AS
					SELECT
						-- Manually added Compaltible Logic for SQL Server Convert 
						coalesce(CAST(SUBSTR(CAST(tt.exittripdatetime as STRING FORMAT 'yyyymmdd'),1,8) as INT64), -1) AS dayid,
						tt.exitlaneid AS laneid,
						dtim.tripidentmethodid,
						coalesce(drc.reasoncodeid, -1) AS reasoncodeid,
						CASE
							WHEN tt.isimagereviewed IS NULL 
							THEN 0
						ELSE tt.isimagereviewed
						END AS imagereviewedflag,
						sum(tollamount) as tollamount,
						count(*) AS txncount
						FROM
						LND_TBOS.TollPlus_TP_Trips AS tt
						INNER JOIN EDW_TRIPS.Dim_TripIdentMethod AS dtim 
							ON dtim.tripidentmethod = tt.tripidentmethod
						LEFT OUTER JOIN EDW_TRIPS.Dim_ReasonCode AS drc 
							ON drc.reasoncode = tt.reasoncode
						WHERE tt.lnd_updatetype <> 'D' 
							AND exittripdatetime <= current_datetime()  -- Eliminate future trips present in the TP_Trips table. This where clause is added by Shekhar on 3/28/2022
																		-- after Sreedevi pointed out a sudden drop on one of the dashboard graphs because of future trips.
																		-- We do not know why future dated trips are present in TP_Trips. It could be a data quality issue.
																		-- As of today the number of future trips is very small - around 50, but since the dashboard graph looks
																		-- ugly and raises a lot of questions, we are eliminating them.
						GROUP BY dayid, tt.exitlaneid, dtim.tripidentmethodid, drc.reasoncodeid, tt.isimagereviewed  
					;

			-- Log
			SET log_message = 'Loaded EDW_TRIPS.Fact_LanePerformanceDailySummary';
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
		  

		  	CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
		 
		  	IF trace_flag = 1 THEN
				select log_source, substr(CAST(log_start_date as STRING), 1, 23); -- Replacement for FromLog
			END IF;

			IF trace_flag = 1 THEN
				SELECT
					'EDW_TRIPS.Fact_LanePerformanceDailySummary' AS tablename,
					*
				FROM
					EDW_TRIPS.Fact_LanePerformanceDailySummary
				ORDER BY 2 DESC  
				LIMIT 1000 
				;
			END IF;
		
			EXCEPTION WHEN ERROR THEN
			BEGIN
				DECLARE error_message STRING DEFAULT @@error.message;

				CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));

				select log_source,log_start_date; -- replacement for fromlog
				RAISE USING MESSAGE = error_message;
			END;
		END;
/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Fact_LanePerformanceDailySummary


EXEC Utility.FromLog 'dbo.Fact_LanePerformanceDailySummary', 1
SELECT TOP 100 'dbo.Fact_LanePerformanceDailySummary' Table_Name, * FROM dbo.Fact_LanePerformanceDailySummary ORDER BY 2


-- Check if there are any future dated trips
SELECT TOP 100 'dbo.Fact_LanePerformanceDailySummary' Table_Name, * FROM dbo.Fact_LanePerformanceDailySummary 
where dayid > 20220328


select count_big(*) FROM lnd_tbos.tollplus.tp_trips where dayid is null ---- transactions reasoncode are rejected

SELECT CAST(exittripdatetime AS DATE) TripDate ,COUNT(tptripid)VideoTXNCnt		
FROM lnd_tbos.tollplus.tp_trips		
WHERE CAST(exittripdatetime AS DATE) BETWEEN '2021-05-01' AND '2021-05-31'		
AND TripIdentMethod='Videotoll'		
AND LND_UpdateType!='d'		
GROUP BY TripIdentMethod,CAST(exittripdatetime AS DATE)		
ORDER BY 1 		
		
SELECT DayID,SUM(TXnCount)VideoTXNCnt		
FROM dbo.Fact_LanePerformanceDailySummary		
WHERE dayid BETWEEN 20210501 AND 20210531		
AND TripIdentMethodID=2		
GROUP BY DayID 		
ORDER BY dayid 	



*/


END;