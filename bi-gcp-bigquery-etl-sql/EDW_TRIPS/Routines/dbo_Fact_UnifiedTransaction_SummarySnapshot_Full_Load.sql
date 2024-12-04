CREATE OR REPLACE PROCEDURE EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot_Full_Load (boardreportingrunflag INT64, createsnapshotondemandflag INT64)
BEGIN

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_UnifiedTransaction_SummarySnapshot table. This monthly snapshot table feeds Board Reporting.
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040134	Shankar		2021-12-10	New!
CHG0040343	Shankar		2022-01-31	1. Get OOSPlateFlag for all transaction types, not just video.
									2. Add the First Payment Month and Last Payment Month columns. 
									3. Get Paid Amount for prepaid trips from TP_CustomerTrips along with Adj.
CHG0040744	Shankar		2022-04-13	Added AdjustedExpectedAmount and few new columns from dbo.Fact_UnifiedTransaction
CHG0041141	Shankar		2022-06-30	Added Rpt_PaidvsAEA, Rpt_LPState, Rpt_InvUnInv, Rpt_VToll
CHG0041406  Shekhar   	2022-08-23  Added VTollFlag & ClassAdjustmentFlag. No additional logic needed in the SP, as
                                  	they are directled fetched from the Fact_Unified_Summary table.
CHG0042057  Shankar   	2022-09-23  1. Embed three mapping output columns in Snapshot fact table to preserve this data in each snapshot
									2. Added AsOfDate to allow for multiple snapshots during one month. Data time period remains same.
									3. Multi-purpose proc interface.
									    @BoardReportingRunFlag		: Board Reporting OVERRIDE run to replace all the previous snapshot runs in the month. Start fresh.
									    @CreateSnapshotOnDemandFlag	: Create additional snapshots when needed ONLY AFTER the Board Reporting run is done including refreshing Unknown Mappings update.
									   
                                    Scenario 1. Regular prod run, including the first run after 4th for Board Reporting Snapshot 
                                        	@BoardReportingRunFlag = 0 -- auto-detect --, @CreateSnapshotOnDemandFlag = 0 
                                    Scenario 2. Refresh updated Unknown mappings in the latest Board Reporting Snapshot after confirming Pat updated all Unknown Operations mappings
                                        	@BoardReportingRunFlag = 0 -- auto-detect--, @CreateSnapshotOnDemandFlag = 0
                                    Scenario 3. Board Reporting Snapshot already created. Subsequent runs during the month with this input do nothing.
                                        	@BoardReportingRunFlag = 0, @CreateSnapshotOnDemandFlag = 0
                                    Scenario 4. Override Board Reporting Snapshot to replace existing Board Reporting Snapshot with a new Snapshot 
                                        	@BoardReportingRunFlag = 1 -- explicit instruction --, @CreateSnapshotOnDemandFlag = 0 
                                    Scenario 5. Create additional Snapshot(s) as and when needed after the first run which always reserved for Board Reporting Snapshot
											@BoardReportingRunFlag = 0, @CreateSnapshotOnDemandFlag = 1  -- explicit instruction --
CHG0042378  Shankar     2023-01-31  Avoid unnecessary backup of 3 large tables when Pat completes unknown mappings update to save time.
									   
CHG0042058 Shankar		2024-01-09  1. Deleted new Unknown mapping rows in dbo.Dim_OperationsMapping which do not map to any Txns in the entire Bubble Snapshot fact table
									2. Updated table partition values on backup tables to include current year.  

SPLTSK0036243 Shankar	2024-10-07  When reloading Bubble Snapshot after Pat completes unknown mapping update, stick to 4th 00:00 Bubble Summary fact table. Be consistent from month to month. 
*******************************************************************************************************************
    ATTENTION!  ==> Prod move peer review check. Keep @Trace_Flag BIT = 0, @Backup_Flag BIT = 0  <== ATTENTION!
*******************************************************************************************************************
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_UnifiedTransaction_SummarySnapshot_Full_Load @BoardReportingRunFlag = 0, @CreateSnapshotOnDemandFlag = 0
SELECT * FROM Utility.ProcessLog Where LogSource = 'dbo.Fact_UnifiedTransaction_SummarySnapshot_Full_Load' ORDER BY 1 DESC

SELECT TOP 1000 'dbo.Fact_UnifiedTransaction_Summary' TableName, * FROM dbo.Fact_UnifiedTransaction_Summary ORDER BY 2 DESC,3,4
SELECT TOP 1000 'dbo.Fact_UnifiedTransaction_SummarySnapshot' TableName, * FROM dbo.Fact_UnifiedTransaction_SummarySnapshot 
WHERE SnapshotMonthId = 202211 and TripIdentMethodID <> -1
ORDER BY 2 DESC, 3 DESC, 4,5,6,7
###################################################################################################################
*/

    
    --::>> DEBUG BLOCK BEGIN ===================================================================================
		
		--Uncomment for controlled test
		--DECLARE @BoardReportingRunFlag BIT = 0, @CreateSnapshotOnDemandFlag BIT = 1
		
    --Comment for controlled test
	DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0; /*Testing = 1. Prod = 0*/
    --:: Are there any Bubble Snapshots already present for @SnapshotMonthID?
    DECLARE snapshotmonthid_lastrun INT64;
    DECLARE asofdayid_lastrun INT64;
    DECLARE asofdayid_boardreportingrun INT64;
    DECLARE edw_updatedate_prevrunthismonth DATETIME;
    DECLARE edw_updatedate_thisrun DATETIME;
    DECLARE currentsnapshotscount INT64 DEFAULT 0;
    DECLARE now DATETIME;
    DECLARE boardreportingrunstartday INT64 DEFAULT 4; -- * I M P O R T A N T * --
    DECLARE updatedunknownmappingscount INT64;
    DECLARE unknownmappingscount INT64;
    DECLARE refreshunknownmappingsflag INT64 DEFAULT 0;
	DECLARE renamesummarytableflag INT64 DEFAULT 0;
    DECLARE backup_flag INT64 DEFAULT 0;  /*Testing = 1 or 0. Prod = 0*/ -- * I M P O R T A N T * --
    BEGIN
    	DECLARE var_snapshotmonthid INT64;
    	DECLARE monthbegindayid INT64;
		--Comment for controlled test		

		--Uncomment for controlled test run > Start
		--DECLARE var_snapshotmonthid INT = 202211, @MonthBeginDayID INT = 20221201, @Now DATETIME2(3) = '12/04/2022'
		--DECLARE @BoardReportingRunStartDay SMALLINT = 1
		--Uncomment for controlled test run > End

		--::>> DEBUG BLOCK END  ===================================================================================

    	DECLARE row_count INT64;
		SET now = current_datetime('America/Chicago');
		SET var_snapshotmonthid = CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_add(CAST(date_add(date_add(last_day(current_datetime('America/Chicago')), interval -1 MONTH), interval 1 DAY) AS DATETIME), interval -2 MILLISECOND)) AS STRING),1, 6) AS INT64);
		SET monthbegindayid = CAST(CAST(FORMAT_DATETIME('%Y%m%d', datetime_add(datetime_add(DATETIME '1900-01-01 00:00:00', interval 0 DAY), interval datetime_diff(current_datetime('America/Chicago'), datetime_add(DATETIME '1900-01-01 00:00:00', interval 0 DAY), MONTH) MONTH)) as STRING) AS INT64);
		SET log_start_date = current_datetime('America/Chicago');
		IF boardreportingrunflag is Null
		THEN 
			SET boardreportingrunflag = 0;
		END IF;
		IF createsnapshotondemandflag is Null
		THEN 
			SET createsnapshotondemandflag = 0;
		END IF;      
		SET log_message  = concat('Started Bubble Snapshot load for ', substr(CAST(var_snapshotmonthid as STRING), 1, 30), '. @BoardReportingRunFlag = ', coalesce(CAST(substr(CAST(boardreportingrunflag as STRING), 1, 30) as INT64), 0) , ', @CreateSnapshotOnDemandFlag = ' , coalesce(CAST(substr(CAST(createsnapshotondemandflag as STRING), 1, 30) as INT64), 0)) ;
		CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);

		--:: Are there any Bubble Snapshots already present for @SnapshotMonthID?
		SET (snapshotmonthid_lastrun, asofdayid_lastrun)=
			(SELECT
			(max(snapshotmonthid) ,
			max(Fact_UnifiedTransaction_SummarySnapshot.asofdayid))
		FROM
			EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot)  -- All Snapshots
		;
		SET ( currentsnapshotscount, asofdayid_boardreportingrun, edw_updatedate_prevrunthismonth)= 
		(SELECT 
		(count(DISTINCT Fact_UnifiedTransaction_SummarySnapshot.asofdayid),
		min(Fact_UnifiedTransaction_SummarySnapshot.asofdayid),
		CAST(max(Fact_UnifiedTransaction_SummarySnapshot.edw_updatedate) AS DATETIME))
		FROM
		EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot
		WHERE snapshotmonthid = var_snapshotmonthid ); -- This month ;
		SET edw_updatedate_thisrun= ( SELECT max(Fact_UnifiedTransaction_Summary.edw_updatedate) FROM EDW_TRIPS.Fact_UnifiedTransaction_Summary ) ;		

		IF trace_flag = 1 THEN 

		SELECT 
			snapshotmonthid as snapshotmonthid,
			monthbegindayid as monthbegindayid,
			snapshotmonthid_lastrun as snapshotmonthid_lastrun,
			asofdayid_lastrun as asofdayid_lastrun,
			asofdayid_boardreportingrun as asofdayid_boardreportingrun,
			edw_updatedate_prevrunthismonth as edw_updatedate_prevrunthismonth,
			edw_updatedate_thisrun as edw_updatedate_thisrun,
			currentsnapshotscount as currentsnapshotscount,
			boardreportingrunflag as boardreportingrunflag,
			createsnapshotondemandflag as createsnapshotondemandflag;
		END IF;

		--:: Parameter conflict screening
		IF boardreportingrunflag = 1 AND createsnapshotondemandflag = 1 
		THEN
			SET boardreportingrunflag = 0;
			SET createsnapshotondemandflag  = 0;
			-- Reset them to normal run
			SET log_message = 'If you need CreateSnapshotOnDemandFlag = 1, pass BoardReportingRunFlag as 0 as only one of them can be 1, not both. Ignore this invalid input and proceed with default run values @BoardReportingRunFlag = 0, @CreateSnapshotOnDemandFlag = 0' ;
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
		END IF;

    	--:: Wait until 4th of the month for the first Bubble Snapshot run of the month
		IF EXTRACT(DAY FROM now) < boardreportingrunstartday AND trace_flag = 0 
		THEN
			SET boardreportingrunflag = 0;
			SET createsnapshotondemandflag  = 0;
		
			-- Automatically turn it off!
			SET log_message = concat('Wait until 4th of the month for the first Bubble Snapshot run of the month for ', substr(CAST(var_snapshotmonthid as STRING), 1, 30), '. Take it easy!');
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
		END IF;

		--:: First Snapshot of the month is always used for Board Reporting. Subsequent snapshots can be created on demand based on special needs. 
		IF EXTRACT(DAY FROM now) >= boardreportingrunstartday AND currentsnapshotscount = 0 
		THEN
			SET boardreportingrunflag = 1; /* Automatically turn it on! */
			SET createsnapshotondemandflag  = 0; /*Automatically turn it off!*/
			SET log_message = concat('Detected the first run after 4th of the month for Board Reporting Snapshot ', substr(CAST(var_snapshotmonthid as STRING), 1, 30), '! Turned on @BoardReportingRunFlag = ', coalesce(CAST(substr(CAST(boardreportingrunflag as STRING), 1, 30) as INT64), 0) );
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
		END IF; 

    	--:: Refresh Unknown mapping data in fact table? Auto detect if Pat completed Unknown Mappings update after the last Bubble Snapshot run.  
      
		SET updatedunknownmappingscount=
		(SELECT
			count(DISTINCT ss.operationsmappingid)
		FROM
			EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot AS ss
			INNER JOIN EDW_TRIPS.Dim_OperationsMapping AS om ON om.operationsmappingid = ss.operationsmappingid
		WHERE ss.snapshotmonthid = var_snapshotmonthid
			AND ss.asofdayid = asofdayid_lastrun
			AND (ss.mappingdetailed = 'Unknown' OR ss.pursunpursstatus = 'Unknown') -- not in fact table
			AND om.mappingdetailed <> 'Unknown'
			AND om.pursunpursstatus <> 'Unknown');  -- in dim table

		SET unknownmappingscount=
		(SELECT
			count(DISTINCT ss.operationsmappingid)
		FROM EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot AS ss
		INNER JOIN EDW_TRIPS.Dim_OperationsMapping AS om ON om.operationsmappingid = ss.operationsmappingid
		WHERE ss.snapshotmonthid = var_snapshotmonthid
			AND ss.asofdayid = asofdayid_lastrun
			AND (om.mappingdetailed = 'Unknown' OR om.pursunpursstatus = 'Unknown'))
		;
		IF updatedunknownmappingscount > 0  -- some unknown mappings updated, yaay!
		THEN
			IF unknownmappingscount = 0   -- zero unknown mappings left in dim table, yaay! yaay!
				THEN
					-- green signal
					SET  refreshunknownmappingsflag = 1;
					SET  boardreportingrunflag  = ( SELECT CASE WHEN currentsnapshotscount = 1 THEN 1 ELSE 0 END  );
					SET log_message = ( SELECT CAST(concat('Pat completed ALL ', substr(CAST(updatedunknownmappingscount as STRING), 1, 30), ' Unknown Operations Mappings update! Reload Snapshot with the updated Operations Mappings data using prior run AsOfDayID. @RefreshUnknownMappingsFlag = 1, @BoardReportingRunFlag = ' , coalesce(CAST(substr(CAST(boardreportingrunflag as STRING), 1, 30) as INT64), 0) ,coalesce(concat('. @AsOfDayID_LastRun = ', substr(CAST(asofdayid_lastrun as STRING), 1, 30), '. '), 'N/A') , coalesce(concat(', @CurrentSnapshotsCount = ', substr(CAST(currentsnapshotscount as STRING), 1, 30), '. '), '')) AS STRING));
					CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
					
					-- when reloading monthly snapshot, ensure that Fact_UnifiedTransaction_Summary used is as of 4th of the month. Pat wants this "data as of date" to be consistent from month to month for apples to apples comparison.
					IF substring(cast(now as string),1,10)  <>  substring(cast(edw_updatedate_prevrunthismonth as string),1,10)
					THEN
						SET renamesummarytableflag = 1;
						ALTER TABLE EDW_TRIPS.Fact_UnifiedTransaction_Summary
						RENAME TO Fact_UnifiedTransaction_Summary_NEW;
						ALTER TABLE EDW_TRIPS.Fact_UnifiedTransaction_Summary_ThisRun
						RENAME TO Fact_UnifiedTransaction_Summary;
						SET log_message = concat('Renamed Fact_UnifiedTransaction_Summary_ThisRun table loaded on ', CAST(edw_updatedate_prevrunthismonth as STRING),  ' to replace Fact_UnifiedTransaction_Summary loaded on a later date ',CAST(edw_updatedate_thisrun as STRING),'!');
						CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
					END IF;
			ELSE
				-- wait!
				SET refreshunknownmappingsflag = 0 ;
				SET log_message = concat('Pat has still ', substr(CAST(unknownmappingscount as STRING), 1, 30), ' Unknown Operations Mappings update left! Wait for now. ', coalesce(concat('@AsOfDayID_LastRun = ', substr(CAST(asofdayid_lastrun as STRING), 1, 30), '. '), 'N/A'), coalesce(concat('@CurrentSnapshotsCount = ', substr(CAST(currentsnapshotscount as STRING), 1, 30), '. '), '')) ;
				CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
			END IF;
		END IF;
		--:: On Demand Snapshot. Board Reporting Snapshot must have been already created by this time. Is there new data in Summary fact table for this additional Snapshot? 
		IF EXTRACT(DAY FROM now) >= boardreportingrunstartday
			AND createsnapshotondemandflag = 1
			AND currentsnapshotscount > 0 
		THEN
        	IF edw_updatedate_thisrun > edw_updatedate_prevrunthismonth OR edw_updatedate_prevrunthismonth IS NULL OR trace_flag = 1 
			THEN
				SET boardreportingrunflag = 0;
				SET log_message = ( SELECT concat('New data! Creating one more Bubble Snapshot on demand with AsOfDayID ', CAST(FORMAT_DATETIME('%Y%m%d', current_datetime('America/Chicago')) AS STRING), ' for SnapshotMonthID ', substr(CAST(var_snapshotmonthid as STRING), 1, 30), '. It already has ', substr(CAST(currentsnapshotscount as STRING), 1, 30), ' Snapshot(s). The last Snapshot was created as of ', coalesce(substr(CAST(asofdayid_lastrun as STRING), 1, 30), ''), '. @EDW_UpdateDate_PrevRunThisMonth from SummarySnapshot table = ', coalesce(substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',edw_updatedate_prevrunthismonth) AS STRING),1,19), 'N/A'), ', @EDW_UpdateDate_ThisRun from Summary table = ', coalesce(substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',edw_updatedate_thisrun) AS STRING),1,19), 'N/A')));
				CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
				IF asofdayid_lastrun = CAST(CAST(FORMAT_DATETIME('%Y%m%d', current_datetime('America/Chicago')) AS STRING) as INT64)  -- Rule: Only one Bubble Snapshot per day. We always create Bubble Snapshots only for the last month and absolutely make no changes in the snapshots created for the prior months.
          		THEN
					--:: Backup Fact_UnifiedTransaction_SummarySnapshot
					--DROP TABLE IF EXISTS EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot_DELETED;
					CREATE OR REPLACE TABLE EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot_DELETED
					CLUSTER BY snapshotmonthid
						AS
						SELECT
							Fact_UnifiedTransaction_SummarySnapshot.*,
							current_datetime('America/Chicago') AS backupdate
							FROM
							EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot
							WHERE snapshotmonthid = var_snapshotmonthid
							AND Fact_UnifiedTransaction_SummarySnapshot.asofdayid = asofdayid_lastrun
					;
					--:: Clear the way for reloading Board Reporting Snapshot
					DELETE FROM EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot WHERE snapshotmonthid = var_snapshotmonthid
						AND Fact_UnifiedTransaction_SummarySnapshot.asofdayid = asofdayid_lastrun;
					SET log_message = concat('Snapshot on demand run once more on the same day! Deleted existing ', substr(CAST(var_snapshotmonthid as STRING), 1, 30), ' Snapshot created earlier today');
					CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
				END IF;
        	ELSE
				SET boardreportingrunflag = 0;
				SET createsnapshotondemandflag = 0;
				
				SET log_message = concat('No new data! Skip creating one more Bubble Snapshot on demand with AsOfDayID ',CAST(FORMAT_DATETIME('%Y%m%d', current_datetime('America/Chicago')) AS STRING), ' for SnapshotMonthID ', substr(CAST(var_snapshotmonthid as STRING), 1, 30), '. It already has ', substr(CAST(currentsnapshotscount as STRING), 1, 30), ' Snapshot(s). The last Snapshot was created as of ', coalesce(substr(CAST(asofdayid_lastrun as STRING), 1, 30), ''), '. @EDW_UpdateDate_PrevRunThisMonth from SummarySnapshot table = ', coalesce(substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',edw_updatedate_prevrunthismonth) AS STRING),1,19), 'N/A'), ', @EDW_UpdateDate_ThisRun from Summary table = ', coalesce(substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',edw_updatedate_thisrun) AS STRING),1,19), 'N/A'));
				CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
			END IF;
      	END IF;

		IF trace_flag = 1 THEN 
		SELECT 
			snapshotmonthid as snapshotmonthid,
			monthbegindayid as monthbegindayid,
			snapshotmonthid_lastrun as snapshotmonthid_lastrun,
			asofdayid_lastrun as asofdayid_lastrun,
			asofdayid_boardreportingrun as asofdayid_boardreportingrun,
			edw_updatedate_prevrunthismonth as edw_updatedate_prevrunthismonth,
			edw_updatedate_thisrun as edw_updatedate_thisrun,
			currentsnapshotscount as currentsnapshotscount,
			boardreportingrunflag as boardreportingrunflag,
			createsnapshotondemandflag as createsnapshotondemandflag,
			refreshunknownmappingsflag as refreshunknownmappingsflag,
			updatedunknownmappingscount as updatedunknownmappingscount;
		END IF ;

      
		--:: Board Reporting override run which needs clearing any existing Snapshot(s) for the last month. First Snapshot run of the current month is always meant for Board Reporting. @BoardReportingRunFlag = 1.
		IF boardreportingrunflag = 1
		AND EXISTS (
			SELECT
				1
			FROM
				EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot
			WHERE snapshotmonthid = var_snapshotmonthid
		) 
		THEN
			--:: Backup Fact_UnifiedTransaction_SummarySnapshot
			--DROP TABLE IF EXISTS EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot_DELETED;
			CREATE OR REPLACE TABLE EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot_DELETED
			CLUSTER BY snapshotmonthid
			AS
				SELECT
					Fact_UnifiedTransaction_SummarySnapshot.*,
					current_datetime('America/Chicago') AS backupdate
				FROM
					EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot
				WHERE snapshotmonthid = var_snapshotmonthid
				AND Fact_UnifiedTransaction_SummarySnapshot.asofdayid <= asofdayid_lastrun
			;

			--:: Clear the way for reloading Board Reporting Snapshot
			DELETE FROM EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot WHERE snapshotmonthid = var_snapshotmonthid
			AND Fact_UnifiedTransaction_SummarySnapshot.asofdayid <= asofdayid_lastrun;
			SET log_message = concat('Board Reporting Run override! Deleted existing ', substr(CAST(var_snapshotmonthid as STRING), 1, 30), ' Snapshot to clear the way for @BoardReportingRunFlag = 1 run. ', coalesce(concat('@AsOfDayID_LastRun = ', substr(CAST(asofdayid_lastrun as STRING), 1, 30), '. '), 'N/A'), coalesce(concat('@CurrentSnapshotsCount = ', substr(CAST(currentsnapshotscount as STRING), 1, 30), '. '), ''));
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
			
			--:: Discard _ThisRun backups and rename _PrevRun backups as _ThisRun. _PrevRun backups are important to stay as _PrevRun backups in this context for month over month Gold Standard diff research.
			DROP TABLE IF EXISTS EDW_TRIPS.Dim_OperationsMapping_ThisRun;
			IF (SELECT count(1) FROM EDW_TRIPS.INFORMATION_SCHEMA.TABLES WHERE LOWER(table_name)=LOWER('Dim_OperationsMapping_PrevRun')) !=0 THEN 
				ALTER TABLE EDW_TRIPS.Dim_OperationsMapping_PrevRun
				RENAME TO Dim_OperationsMapping_ThisRun;
			End IF;
			DROP TABLE IF EXISTS EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot_ThisRun;
			IF (SELECT count(1) FROM EDW_TRIPS.INFORMATION_SCHEMA.TABLES WHERE LOWER(table_name)=LOWER('Fact_UnifiedTransaction_SummarySnapshot_PrevRun')) !=0 THEN 
				ALTER TABLE EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot_PrevRun
				RENAME TO Fact_UnifiedTransaction_SummarySnapshot_ThisRun;
			End IF;       
			
			--:: No data change in these big tables when the run is only to refresh Unknown mappings updated by Pat (@RefreshUnknownMappingsFlag = 1). Why drop backup and take backup again?
			IF refreshunknownmappingsflag = 0 
			THEN
				DROP TABLE IF EXISTS EDW_TRIPS_STAGE.UnifiedTransaction_ThisRun;
				IF (SELECT count(1) FROM EDW_TRIPS_STAGE.INFORMATION_SCHEMA.TABLES WHERE LOWER(table_name)=LOWER('UnifiedTransaction_PrevRun')) !=0 THEN 
					ALTER TABLE EDW_TRIPS_STAGE.UnifiedTransaction_PrevRun
					RENAME TO UnifiedTransaction_ThisRun;
				End IF;
				
				DROP TABLE IF EXISTS EDW_TRIPS.Fact_UnifiedTransaction_ThisRun;
				IF (SELECT count(1) FROM EDW_TRIPS.INFORMATION_SCHEMA.TABLES WHERE LOWER(table_name)=LOWER('Fact_UnifiedTransaction_PrevRun')) !=0 THEN 
					ALTER TABLE EDW_TRIPS.Fact_UnifiedTransaction_PrevRun
					RENAME TO Fact_UnifiedTransaction_ThisRun;
				End IF;

				DROP TABLE IF EXISTS EDW_TRIPS.Fact_UnifiedTransaction_Summary_ThisRun;
				IF (SELECT count(1) FROM EDW_TRIPS.INFORMATION_SCHEMA.TABLES WHERE LOWER(table_name)=LOWER('Fact_UnifiedTransaction_Summary_PrevRun')) !=0 THEN 
					ALTER TABLE EDW_TRIPS.Fact_UnifiedTransaction_Summary_PrevRun
					RENAME TO Fact_UnifiedTransaction_Summary_ThisRun;
				End IF;

        	END IF;
      	END IF;
		  
		--:: Non-Board Reporting Run with @RefreshUnknownMappingsFlag = 1
		IF boardreportingrunflag = 0 AND refreshunknownmappingsflag = 1
		AND EXISTS ( SELECT 1 FROM EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot
			WHERE snapshotmonthid = var_snapshotmonthid
		) 
		THEN
			SET log_message = concat('Non-Board Reporting Run! @RefreshUnknownMappingsFlag = 1. Reload existing ', substr(CAST(var_snapshotmonthid as STRING), 1, 30), ' Snapshot with ', coalesce(concat('@AsOfDayID_LastRun = ', substr(CAST(asofdayid_lastrun as STRING), 1, 30), '. '), ''), coalesce(concat('@CurrentSnapshotsCount = ', substr(CAST(currentsnapshotscount as STRING), 1, 30), '. '), ''));
			
			--:: Backup Fact_UnifiedTransaction_SummarySnapshot
			--DROP TABLE IF EXISTS EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot_DELETED;
			CREATE OR REPLACE TABLE EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot_DELETED
			CLUSTER BY snapshotmonthid
			AS
				SELECT
					Fact_UnifiedTransaction_SummarySnapshot.*,
					current_datetime('America/Chicago') AS backupdate
				FROM
					EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot
				WHERE snapshotmonthid = var_snapshotmonthid
				AND Fact_UnifiedTransaction_SummarySnapshot.asofdayid = asofdayid_lastrun
			;
				
			--:: Clear the way for reloading Board Reporting Snapshot
			DELETE FROM EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot 
			WHERE Fact_UnifiedTransaction_SummarySnapshot.snapshotmonthid = var_snapshotmonthid
			AND Fact_UnifiedTransaction_SummarySnapshot.asofdayid = asofdayid_lastrun;
			SET log_message =  concat('Cleared the way for refreshing Unknown Mapping updates in the last Snapshot ', substr(CAST(var_snapshotmonthid as STRING), 1, 30), ', saved ', coalesce(concat('@AsOfDayID_LastRun = ', substr(CAST(asofdayid_lastrun as STRING), 1, 30), '. '), ''));
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
		END IF;
		
    	--=============================================================================================================
		-- Load dbo.Fact_UnifiedTransaction_SummarySnapshot for the last month on 4th of this month
		--=============================================================================================================

		--DECLARE @SnapshotMonthID INT = 202211, @MonthBeginDayID INT = 20221201, @RefreshUnknownMappingsFlag BIT = 0
		
		IF boardreportingrunflag = 1 OR createsnapshotondemandflag = 1 OR refreshunknownmappingsflag = 1 OR trace_flag = 1 
		THEN
			BEGIN
			DECLARE var_edw_updatedate DATETIME;
			SET log_message = concat('Ready to load Monthly Bubble Summary Snapshot ', substr(CAST(var_snapshotmonthid as STRING), 1, 30), ' with Txns before ', substr(CAST(monthbegindayid as STRING), 1, 30), '. ', coalesce(concat('@AsOfDayID = ', CASE
				WHEN refreshunknownmappingsflag = 1 THEN CAST(asofdayid_lastrun as STRING)
				ELSE CAST(FORMAT_DATETIME('%Y%m%d', now) AS STRING)
			END, ', '), 'N/A'), coalesce(concat('@CurrentSnapshotsCount = ', substr(CAST(currentsnapshotscount as STRING), 1, 30), '. '), ''), CASE
				WHEN trace_flag = 1
				AND NOT (boardreportingrunflag = 1
				OR createsnapshotondemandflag = 1
				OR refreshunknownmappingsflag = 1) THEN '** @Trace_Flag = 1 Run **'
				ELSE ''
			END);
			IF trace_flag = 1 THEN
				SELECT log_message;
			END IF ;
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
			SET var_edw_updatedate = current_datetime('America/Chicago');
			
			--DECLARE @SnapshotMonthID INT = 202211, @MonthBeginDayID INT = 20221201, @EDW_UpdateDate DATETIME2(3) = SYSDATETIME()
			--DROP TABLE IF EXISTS EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot_NEW;
			CREATE TEMPORARY TABLE _SESSION.cte_bubblesummarysnapshot AS (
				--=============================================================================================================
				--:: New Monthly Snapshot of the last month from current run
				--=============================================================================================================
					SELECT
						var_snapshotmonthid AS snapshotmonthid,
						coalesce(CAST(CASE
						WHEN refreshunknownmappingsflag = 1 THEN CAST(asofdayid_lastrun as STRING)
						ELSE CAST(FORMAT_DATETIME('%Y%m%d', now) AS STRING)
						END as INT64), -1) AS asofdayid, -- Retain @AsOfDayID_LastRun, if the purpose of this run is to refresh Unknown mapping updates in the current Snapshot
						coalesce(div(tripdayid, 100), -1) AS tripmonthid,
						l.facilityid,
						operationsmappingid,
						--:Begin: Key columns from dbo.Dim_OperationsMapping 
						tripwith,
						tripidentmethodid,
						transactionpostingtypeid,
						tripstageid,
						tripstatusid,
						reasoncodeid,
						citationstageid,
						trippaymentstatusid,
						badaddressflag,
						nonrevenueflag,
						businessrulematchedflag,
						--:End: Key columns from dbo.Dim_OperationsMapping         
						manuallyreviewedflag,
						oosplateflag,
						vtollflag,
						classadjustmentflag,
						uts.recordtypeid,
						coalesce(CAST(CAST(CAST(FORMAT_DATETIME('%Y%m%d',firstpaiddate) AS STRING) as BIGNUMERIC) / 100 as INT64), -1) AS firstpaidmonthid,
						coalesce(CAST(CAST(CAST(FORMAT_DATETIME('%Y%m%d',lastpaiddate) AS STRING) as BIGNUMERIC) / 100 as INT64), -1) AS lastpaidmonthid,
						rpt_paidvsaea,
						sum(txncount) AS txncount,
						CAST(sum(expectedamount) as NUMERIC) AS expectedamount,
						CAST(sum(adjustedexpectedamount) as NUMERIC) AS adjustedexpectedamount,
						CAST(sum(calcadjustedamount) as NUMERIC) AS calcadjustedamount,
						CAST(sum(tripwithadjustedamount) as NUMERIC) AS tripwithadjustedamount,
						CAST(sum(tollamount) as NUMERIC) AS tollamount,
						CAST(sum(actualpaidamount) as NUMERIC) AS actualpaidamount,
						CAST(sum(outstandingamount) as NUMERIC) AS outstandingamount,
						max(lnd_updatedate) AS lnd_updatedate,
						var_edw_updatedate AS edw_updatedate
					FROM
						EDW_TRIPS.Fact_UnifiedTransaction_Summary AS uts
						INNER JOIN EDW_TRIPS.Dim_Lane AS l ON l.laneid = uts.laneid
					WHERE tripdayid < monthbegindayid -- First day of current month
					GROUP BY tripmonthid,
							tripwith ,
							l.facilityid,
							operationsmappingid,
							--:Begin: Key columns from dbo.Dim_OperationsMapping
							tripwith,
							tripidentmethodid,
							transactionpostingtypeid,
							tripstageid,
							tripstatusid,
							reasoncodeid,
							citationstageid,
							trippaymentstatusid,
							badaddressflag,
							nonrevenueflag,
							businessrulematchedflag,
							--:End: Key columns from dbo.Dim_OperationsMapping
							manuallyreviewedflag,
							oosplateflag,
							vtollflag,
							classadjustmentflag,
							uts.recordtypeid,
							firstpaidmonthid,
							lastpaidmonthid,
							rpt_paidvsaea
					UNION ALL
					--============================================================================
						--:: Static Data to cover data migration gaps
					--==============================================================================================               
					SELECT
						var_snapshotmonthid AS snapshotmonthid,
						coalesce(CAST(CASE
						WHEN refreshunknownmappingsflag = 1 THEN CAST(asofdayid_lastrun as STRING)
						ELSE CAST(FORMAT_DATETIME('%Y%m%d', now) AS STRING)
						END as INT64), -1) AS asofdayid,  
						-- Retain @AsOfDayID_LastRun, if the purpose of this run is to refresh Unknown mapping updates in the current Snapshot
						tripmonthid,
						facilityid,
						ss.operationsmappingid,
						--:Begin: Key columns from dbo.Dim_OperationsMapping 
						om.tripwith,
						om.tripidentmethodid,
						om.transactionpostingtypeid,
						om.tripstageid,
						om.tripstatusid,
						om.reasoncodeid,
						om.citationstageid,
						om.trippaymentstatusid,
						om.badaddressflag,
						om.nonrevenueflag,
						om.businessrulematchedflag,
						--:End: Key columns from dbo.Dim_OperationsMapping                   
						-1 AS manuallyreviewedflag,
						-1 AS oosplateflag,
						-1 AS vtollflag,
						-1 AS classadjustmentflag,
						-1 AS recordtypeid,
						-1 AS firstpaidmonthid,
						-1 AS lastpaidmonthid,
						'UNK' AS rpt_paidvsaea,
						txncount,
						expectedamount,
						adjustedexpectedamount,
						calcadjustedamount,
						tripwithadjustedamount,
						tollamount,
						actualpaidamount,
						outstandingamount,
						CAST(NULL as DATETIME) AS lnd_updatedate,
						var_edw_updatedate  AS edw_updatedate
					FROM
						EDW_TRIPS_SUPPORT.Fact_UnifiedTransaction_StaticSummary AS ss
						INNER JOIN EDW_TRIPS.Dim_OperationsMapping AS om ON ss.operationsmappingid = om.operationsmappingid
			);

			--SELECT * FROM CTE_BubbleSummarySnapshot SS
			
			--// End of CTE //

			--=============================================================================================================
			--:1: Keep previous monthly snapshots intact
			--=============================================================================================================              
			CREATE OR REPLACE TABLE EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot CLUSTER BY snapshotmonthid AS
			SELECT
				Fact_UnifiedTransaction_SummarySnapshot.snapshotmonthid,
				Fact_UnifiedTransaction_SummarySnapshot.asofdayid,
				Fact_UnifiedTransaction_SummarySnapshot.rowseq,
				Fact_UnifiedTransaction_SummarySnapshot.tripmonthid,
				Fact_UnifiedTransaction_SummarySnapshot.facilityid,
				Fact_UnifiedTransaction_SummarySnapshot.facilitycode,
				Fact_UnifiedTransaction_SummarySnapshot.operationsagency,
				Fact_UnifiedTransaction_SummarySnapshot.operationsmappingid,
				Fact_UnifiedTransaction_SummarySnapshot.mapping,
				Fact_UnifiedTransaction_SummarySnapshot.mappingdetailed,
				Fact_UnifiedTransaction_SummarySnapshot.pursunpursstatus,
				Fact_UnifiedTransaction_SummarySnapshot.tripwith,
				Fact_UnifiedTransaction_SummarySnapshot.tripidentmethodid,
				Fact_UnifiedTransaction_SummarySnapshot.recordtypeid,
				Fact_UnifiedTransaction_SummarySnapshot.transactionpostingtypeid,
				Fact_UnifiedTransaction_SummarySnapshot.tripstageid,
				Fact_UnifiedTransaction_SummarySnapshot.tripstatusid,
				Fact_UnifiedTransaction_SummarySnapshot.reasoncodeid,
				Fact_UnifiedTransaction_SummarySnapshot.citationstageid,
				Fact_UnifiedTransaction_SummarySnapshot.trippaymentstatusid,
				Fact_UnifiedTransaction_SummarySnapshot.sourcename,
				Fact_UnifiedTransaction_SummarySnapshot.badaddressflag,
				Fact_UnifiedTransaction_SummarySnapshot.nonrevenueflag,
				Fact_UnifiedTransaction_SummarySnapshot.businessrulematchedflag,
				Fact_UnifiedTransaction_SummarySnapshot.manuallyreviewedflag,
				Fact_UnifiedTransaction_SummarySnapshot.oosplateflag,
				Fact_UnifiedTransaction_SummarySnapshot.vtollflag,
				Fact_UnifiedTransaction_SummarySnapshot.classadjustmentflag,
				Fact_UnifiedTransaction_SummarySnapshot.firstpaidmonthid,
				Fact_UnifiedTransaction_SummarySnapshot.lastpaidmonthid,
				Fact_UnifiedTransaction_SummarySnapshot.rpt_paidvsaea,
				Fact_UnifiedTransaction_SummarySnapshot.rpt_purunp,
				Fact_UnifiedTransaction_SummarySnapshot.rpt_lpstate,
				Fact_UnifiedTransaction_SummarySnapshot.rpt_invuninv,
				Fact_UnifiedTransaction_SummarySnapshot.rpt_vtoll,
				Fact_UnifiedTransaction_SummarySnapshot.rpt_irstatus,
				Fact_UnifiedTransaction_SummarySnapshot.rpt_processstatus,
				Fact_UnifiedTransaction_SummarySnapshot.rpt_paidstatus,
				Fact_UnifiedTransaction_SummarySnapshot.rpt_irrejectstatus,
				Fact_UnifiedTransaction_SummarySnapshot.txncount,
				Fact_UnifiedTransaction_SummarySnapshot.expectedamount,
				Fact_UnifiedTransaction_SummarySnapshot.adjustedexpectedamount,
				Fact_UnifiedTransaction_SummarySnapshot.calcadjustedamount,
				Fact_UnifiedTransaction_SummarySnapshot.tripwithadjustedamount,
				Fact_UnifiedTransaction_SummarySnapshot.tollamount,
				Fact_UnifiedTransaction_SummarySnapshot.actualpaidamount,
				Fact_UnifiedTransaction_SummarySnapshot.outstandingamount,
				Fact_UnifiedTransaction_SummarySnapshot.lnd_updatedate,
				CAST(Fact_UnifiedTransaction_SummarySnapshot.edw_updatedate AS DATETIME) AS edw_updatedate
				FROM
					EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot
				WHERE snapshotmonthid <= var_snapshotmonthid -- If BoardReporting "override" run or Unknown mapping refresh run, note that we already purged existing snapshots for the last month above. 
					AND Fact_UnifiedTransaction_SummarySnapshot.asofdayid <= asofdayid_lastrun -- If SnapshotOnDemand run, all existing snapshots are copied "as is"
				UNION ALL
				--=============================================================================================================
				--:2: New Monthly Snapshot of the last month from current run
				--=============================================================================================================
				SELECT
					ss.snapshotmonthid,
					ss.asofdayid,
					row_number() OVER (PARTITION BY ss.snapshotmonthid, ss.asofdayid ORDER BY CASE
						WHEN om.mapping LIKE '%migrated%' THEN 2
						ELSE 1
					END, ss.tripmonthid DESC, f.facilitycode, ss.operationsmappingid, ss.oosplateflag, ss.manuallyreviewedflag, ss.classadjustmentflag, ss.recordtypeid, ss.firstpaidmonthid, ss.lastpaidmonthid, ss.rpt_paidvsaea, ss.txncount DESC, ss.expectedamount DESC) AS rowseq,
					ss.tripmonthid,
					ss.facilityid,
					f.facilitycode,
					om.operationsagency,
					ss.operationsmappingid,
					--:Begin: Mapping output columns 
					om.mapping,
					om.mappingdetailed,
					om.pursunpursstatus,
					--:End: Mapping output columns 
					ss.tripwith,
					ss.tripidentmethodid,
					ss.recordtypeid,
					ss.transactionpostingtypeid,
					ss.tripstageid,
					ss.tripstatusid,
					ss.reasoncodeid,
					ss.citationstageid,
					ss.trippaymentstatusid,
					om.sourcename,
					ss.badaddressflag,
					ss.nonrevenueflag,
					ss.businessrulematchedflag,
					ss.manuallyreviewedflag,
					ss.oosplateflag,
					ss.vtollflag,
					ss.classadjustmentflag,
					ss.firstpaidmonthid,
					ss.lastpaidmonthid,
					--:: New columns
					ss.rpt_paidvsaea,
					CASE
						om.tripidentmethodid
						WHEN -1 THEN -- This is for the static data
						CASE
						WHEN om.mappingdetailed LIKE '%Duplicate%' THEN 'Dupl'
						WHEN om.mappingdetailed LIKE '%NonRev%' THEN 'NonRev'
						WHEN om.mappingdetailed = 'Video-Not Migrated Exc/Clsd Post Inv' THEN 'Purs'
						ELSE 'UnPurs'
						END
						ELSE -- Now lets deal with the current data
						CASE
						WHEN (om.tripstatuscode LIKE '%DUPL%'
						OR om.tripstatusdesc LIKE '%DUPL%'
						OR om.reasoncode LIKE '%DUPL%')
						OR (om.tripidentmethodid = 1
						AND om.sourcename = 'TSA_OWNER.TRANSACTION_FILE_DETAILS') THEN 'Dupl'  -- Check this part again
						WHEN om.nonrevenueflag = 1 THEN 'NonRev'
						WHEN om.operationsagency = 'IOP - NTTA Home' THEN 'NTTA-Home Agency IOP'
						WHEN om.trippaymentstatusdesc IN(
							'Paid', 'Partially Paid', 'Bankruptcy Discharged'
						)
						OR om.tripstatuscode IN(
							'POSTED', 'ADJUSTED', 'ADJUSTMENT_INITIATED', 'CREDITADJUSTMENT', 'CSR_ADJUSTED', 'CSR_DISMISSED', 'DISMISSED', 'DISPUTE_ADJUSTED', 'Dispute_Dismissed', 'DISPUTE_INITIATED', 'HOLD', 'Reset', 'TOBEPAIDBYDCB', 'TRANSFERRED', 'Transitioned', 'UnMatch_Initiated', 'UNMATCHED', 'UNMATCHED', 'VTOLL'
						)
						OR om.reasoncode IN(
							'POSTED', 'PostedWithCalculationError'
						) THEN 'Purs'
						WHEN om.tripstatuscode IN(
							'ERROR', 'FORMATERROR', 'FUTURETRIP', 'IMAGE_REVIEW_PENDING', 'INVALID_IMAGE', 'INVALIDPLATE', 'MANUAL_REVIEW_PENDING', 'NEGATIVEBALANCE', 'PREPROCESS_DONE', 'REJECTED', 'SYSTEM_ERROR', 'TOOOLDTRIP', 'WAITING_FOR_IOP'
						)
						OR om.trippaymentstatusdesc IN(
							'NOT APPLICABLE', 'Not Paid', 'Unknown'
						) THEN 'UnPurs'
						ELSE 'Unknown'
						END
					END AS rpt_purunp,
					CASE
						ss.oosplateflag
						WHEN 0 THEN 'IS'
						WHEN 1 THEN 'OOS'
						WHEN -1 THEN 'UNK'
					END AS rpt_lpstate,
					CASE
						WHEN om.mapping IN(
						'VIDEO', 'IOP - Video', 'NTTA-Home Agency IOP'
						)
						AND om.citationstagecode IN(
						'CTNISSD', 'FSTNTV', 'LAPNTV', 'SECNTV', 'THDNTV', 'ZCN' 
						) --1
						THEN 'Inv'
						WHEN om.mapping IN(
						'VIDEO', 'IOP - Video', 'NTTA-Home Agency IOP'
						)
						AND om.citationstagecode IN(
						'INVOICE', 'Unknown'
						) --2
						THEN 'UnInv' -- 2
						ELSE 'Unknown'
					END AS rpt_invuninv,
					CASE
						WHEN om.transactionpostingtype LIKE 'VToll%' THEN om.transactionpostingtype
						WHEN om.mapping = 'IOP - Video' THEN 'VToll'
						WHEN om.mapping = 'VIDEO'
						AND om.transactionpostingtype = 'NTTA Fleet'
						AND om.tripstatuscode = 'VTOLL' THEN 'VToll'
						WHEN om.mapping = 'VIDEO'
						AND om.transactionpostingtype = 'Prepaid AVI'
						AND om.tripstatuscode IN(
						'CSR_ADJUSTED', 'DISPUTE_ADJUSTED', 'POSTED', 'UNMATCHED'
						) THEN r'VToll?'
						ELSE 'Unknown'
					END AS rpt_vtoll,
					CASE
						WHEN om.tripstatuscode = 'REJECTED'
						AND reasoncode IN(
						'IMAGE_INFORMATION_MISSING', 'IMAGE_NOT_REQUESTED', 'IMAGES_NOT_RECEIVED_FROM_LANES', 'IMI Image Metadata Not Available', 'No Image Available At Record Level', 'No Image Available At Subscriber', 'VES_SERIAL_NUM_NOT_EXISTS'
						) THEN 'No Image'
						WHEN om.tripstatuscode IN(
						'IMAGE_REVIEW_PENDING', 'MANUAL_REVIEW_PENDING', 'PREPROCESS_DONE'
						) THEN 'Pending'
						WHEN ss.manuallyreviewedflag = 1 THEN 'MIR'
						WHEN ss.manuallyreviewedflag = 0 THEN 'OCR'
						ELSE 'Unknown'
					END AS rpt_irstatus,
					CASE
						WHEN om.citationstagecode = 'ZCN' THEN 'Zc'
						WHEN om.citationstagecode = 'FSTNTV' THEN 'Fn'
						WHEN om.citationstagecode = 'SECNTV' THEN 'Sn'
						WHEN om.citationstagecode = 'THDNTV' THEN 'Tn/Ca'
						WHEN om.citationstagecode = 'LAPNTV' THEN 'LAP'
						WHEN om.citationstagecode = 'CTNISSD' THEN 'Cit'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode = 'DMVPEND'
						AND om.reasoncode IN(
						'DMVPEND', 'IMAGE_REVIEW_PENDING', 'No Image Available At Subscriber'
						) THEN '<>DMV'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode = 'REJECTED'
						AND om.reasoncode IN(
						'DMVPEND', 'DMVDATANOTFOUND', 'DMV data not found'
						) THEN '<>DMV'
						WHEN om.citationstagecode = 'Unknown'
						AND tripstatusdesc = 'Customer Balance In Delinquent State' THEN 'Delq'
						WHEN om.citationstagecode = 'INVOICE'
						AND om.tripstatuscode IN(
						'CSR_DISMISSED', 'DISMISSED', 'Dispute_Dismissed'
						)
						AND trippaymentstatuscode = 'NA' THEN 'Dismissed'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode IN(
						'CSR_DISMISSED', 'DISMISSED', 'Dispute_Dismissed'
						)
						AND om.reasoncode IN(
						'Unknown', 'Posted'
						) THEN 'Dismissed'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode IN(
						'ERROR', 'FORMATERROR', 'FUTURETRIP', 'SYSTEM_ERROR', 'TOOOLDTRIP'
						) THEN 'Error'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode = 'REJECTED'
						AND om.reasoncode IN(
						'Error', 'INVALIDPLATE'
						) THEN 'Error'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode = 'WAITING_FOR_IOP'
						AND om.reasoncode IN(
						'FORMATERROR', 'INVALIDPLATE', 'SYSTEM_ERROR', 'TAG/PLATE_NOT_ON_FILE', 'TOOOLDTRIP'
						) THEN 'Error'
						WHEN om.citationstagecode = 'INVOICE'
						AND om.tripstatuscode IN(
						'CSR_ADJUSTED', 'DISPUTE_ADJUSTED', 'Excused', 'POSTED', 'TRANSFERRED', 'Transitioned', 'UNMATCHED', 'CSR_DISMISSED'
						)
						AND trippaymentstatuscode IN(
						'NA'
						) THEN 'Excused'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode = 'Excused'
						AND om.reasoncode = 'Posted' THEN 'Excused'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode IN(
						'INVALID_IMAGE', 'REJECTED', 'POSTED'
						)
						AND om.reasoncode IN(
						'Image Not Clear', 'Unclear Image'
						) THEN 'Image Not Clear'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode IN(
						'INVALID_IMAGE', 'REJECTED', 'POSTED', 'Excused'
						)
						AND om.reasoncode IN(
						'Incomplete Image', 'Incomplete'
						) THEN 'Incomplete Image'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode IN(
						'NEGATIVEBALANCE', 'WAITING_FOR_IOP'
						)
						AND om.reasoncode = 'NEGATIVEBALANCE' THEN 'Negative Balance'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode IN(
						'DISPUTE_ADJUSTED', 'INVALID_IMAGE', 'REJECTED', 'POSTED', 'CSR_ADJUSTED'
						)
						AND om.reasoncode IN(
						'Image Not Available at Record Level', 'No Image Available', 'IMAGE_INFORMATION_MISSING', 'IMAGES_NOT_RECEIVED_FROM_LANES', 'IMI Image Metadata Not Available', 'No Image Available At Record Level', 'No Image Available At Subscriber', 'VES_SERIAL_NUM_NOT_EXISTS'
						) THEN 'No Image'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode = 'REJECTED'
						AND om.reasoncode = 'No Plate' THEN 'No Plate'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode IN(
						'REJECTED', 'POSTED'
						)
						AND om.reasoncode IN(
						'Out of Country', 'Out of Country Plate'
						) THEN 'Out of  Country'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode IN(
						'IMAGE_REVIEW_PENDING', 'MANUAL_REVIEW_PENDING'
						) THEN 'Pend'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode IN(
						'DISPUTE_ADJUSTED', 'POSTED'
						)
						AND om.reasoncode = 'IMAGE_REVIEW_PENDING' THEN 'Pend'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode IN(
						'INVALID_IMAGE', 'REJECTED', 'POSTED', 'Excused', 'Transitioned'
						)
						AND om.reasoncode = 'Plate Obstruction' THEN 'Plate Obstruction'
						WHEN om.citationstagecode IN(
						'INVOICE', 'Unknown'
						)
						AND om.tripstatuscode IN(
						'POSTED', 'Excused'
						)
						AND om.reasoncode IN(
						'DMVDATANOTFOUND', 'DMVPEND'
						) THEN '<>DMV'
						WHEN om.citationstagecode IN(
						'INVOICE', 'Unknown'
						)
						AND om.tripstatuscode IN(
						'ADJUSTED', 'CSR_ADJUSTED', 'DISPUTE_ADJUSTED', 'DISPUTE_INITIATED', 'HOLD', 'UnMatch_Initiated', 'ADJUSTMENT_INITIATED', 'CREDITADJUSTMENT', 'DMVPEND', 'TRANSFERRED', 'Transitioned', 'UNMATCHED', 'POSTED', 'TSA_ADJUSTED'
						)
						AND om.reasoncode IN(
						'POSTED', 'UNMATCHED', 'Unknown', 'PostedWithCalculationError', 'Transaction Reversal - Adjustment'
						) THEN 'Posted'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode = 'REJECTED'
						AND om.reasoncode IN(
						'Adjustment Debit cannot be processed', 'EMERGENCY_MODE_PAYMENT', 'IMAGE_NOT_REQUESTED', 'Invalid Transaction Type', 'INVALID_CUSTOMER_STATUS', 'Re-submission Not Allowed', 'Transaction Older than the configured value', 'Txn Field Format Invalid_"Field Name"', 'Txn Field Format Invalid_"ResubmitCount"', 'Unknown', 'Vehicle Misclassification by Subscriber', 'First Responder', 'Resubmittal Count is Greater than the configured value'
						) THEN 'Rejected'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode IN(
						'INVALID_IMAGE', 'REJECTED'
						)
						AND om.reasoncode = 'Rejected Paper Plate' THEN 'Rejected Paperplate'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode = 'REJECTED'
						AND om.reasoncode IN(
						'Tribal Plate', 'Tribal State Plate'
						) THEN 'Tribal Plate'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode IN(
						'INVALIDPLATE', 'REJECTED'
						)
						AND om.reasoncode = 'Unknown State' THEN 'Unknown State'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode = 'UNMATCHED'
						AND om.reasoncode = 'Unknown' THEN 'Unmatch'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode = 'REJECTED'
						AND om.reasoncode IN(
						'Government', 'US Government Plate'
						) THEN 'US Govt Plate'
						WHEN om.citationstagecode IN(
						'INVOICE', 'Unknown'
						)
						AND om.tripstatuscode IN(
						'POSTED', 'REJECTED'
						)
						AND om.reasoncode IN(
						'Veterans Program', 'Veteran Program'
						) THEN 'Vet'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode = 'WAITING_FOR_IOP'
						AND om.reasoncode IN(
						'IOP_PLATE', 'IOP_TAG', 'TAG/PLATE_NOT_ON_FILE', 'Unknown'
						) THEN 'Waiting For IOP'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode LIKE 'Dupl%' -- Duplicate, Duplicate_At_Violator_Level
						THEN 'Duplicate'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode IN(
						'Posted', 'Excused', 'Rejected', 'Unmatched'
						)
						AND om.reasoncode LIKE 'Dupl%' THEN 'Duplicate'
						WHEN om.citationstagecode = 'Unknown'
						AND om.tripstatuscode = 'PREPROCESS_DONE' THEN 'Preprocess'
						ELSE 'Unknown'
					END AS rpt_processstatus,
					CASE
						WHEN om.trippaymentstatuscode = 'BkrtDismiss' THEN 'Bnkrpt Discharg'
						WHEN om.trippaymentstatuscode = 'NotPaid' THEN 'Not Paid'
						WHEN om.trippaymentstatuscode = 'Paid' THEN 'Paid'
						WHEN om.trippaymentstatuscode = 'PartialPaid' THEN 'Partial paid'
						WHEN om.trippaymentstatuscode = 'NA'
						AND om.tripstatuscode IN(
						'CSR_ADJUSTED', 'DISPUTE_ADJUSTED', 'DISPUTE_INITIATED', 'Excused', 'POSTED', 'Reset', 'TRANSFERRED', 'Transitioned', 'UNMATCHED'
						) THEN 'Execused'
						WHEN om.trippaymentstatuscode = 'NA'
						AND om.tripstatuscode IN(
						'CSR_DISMISSED', 'DISMISSED', 'Dispute_Dismissed', 'Transaction Dismissed'
						) THEN 'Dismissed'
						WHEN om.trippaymentstatuscode IN(
						'NA', 'Unknown'
						)
						AND ss.rpt_paidvsaea = '0' THEN 'UnPaid'
						WHEN om.trippaymentstatuscode IN(
						'NA', 'Unknown'
						)
						AND ss.rpt_paidvsaea IN(
						'<AEA', '=AEA', '>AEA'
						) THEN 'Paid'
						ELSE 'Unknown'
					END AS rpt_paidstatus,
					CASE
						WHEN om.pursunpursstatus LIKE 'Dupl%' THEN 'Unknown'
						WHEN om.tripidentmethod = 'AVITOLL' THEN 'Unknown'
						WHEN om.tripstatuscode IN(
						'IMAGE_REVIEW_PENDING', 'MANUAL_REVIEW_PENDING', 'PREPROCESS_DONE'
						) THEN 'Pending'
						WHEN om.mapping IN(
						'VIDEO', 'IOP - Video', 'NTTA-Home Agency IOP'
						)
						AND om.tripstatuscode IN(
						'ADJUSTED', 'ADJUSTMENT_INITIATED', 'CREDITADJUSTMENT', 'CSR_ADJUSTED', 'CSR_DISMISSED', 'DISMISSED', 'DISPUTE_ADJUSTED', 'Dispute_Dismissed', 'DISPUTE_INITIATED', 'DMVPEND', 'Excused', 'HOLD', 'NEGATIVEBALANCE', 'POSTED', 'Reset', 'TOBEPAIDBYDCB', 'TRANSFERRED', 'Transitioned', 'UnMatch_Initiated', 'UNMATCHED', 'VTOLL'
						) THEN 'IA'
						WHEN om.mapping IN(
						'VIDEO', 'IOP - Video', 'NTTA-Home Agency IOP'
						)
						AND om.tripstatuscode IN(
						'ERROR', 'FORMATERROR', 'FUTURETRIP', 'INVALID_IMAGE', 'INVALIDPLATE', 'SYSTEM_ERROR', 'TOOOLDTRIP'
						) THEN 'IR'
						WHEN om.mapping IN(
						'VIDEO', 'IOP - Video', 'NTTA-Home Agency IOP'
						)
						AND om.tripstatuscode = 'REJECTED'
						AND om.reasoncode IN(
						'DMV data not found', 'DMVDATANOTFOUND', 'DMVPEND'
						) THEN 'IA'
						WHEN om.mapping IN(
						'VIDEO', 'IOP - Video', 'NTTA-Home Agency IOP'
						)
						AND om.tripstatuscode = 'REJECTED'
						AND om.reasoncode NOT IN(
						'DMV data not found', 'DMVDATANOTFOUND', 'DMVPEND'
						) THEN 'IR'
						WHEN om.mapping IN(
						'VIDEO', 'IOP - Video', 'NTTA-Home Agency IOP'
						)
						AND om.tripstatuscode = 'WAITING_FOR_IOP'
						AND om.reasoncode NOT IN(
						'IOP_PLATE', 'NEGATIVEBALANCE', 'TAG/PLATE_NOT_ON_FILE'
						) THEN 'IA'
						WHEN om.mapping IN(
						'VIDEO', 'IOP - Video', 'NTTA-Home Agency IOP'
						)
						AND om.tripstatuscode = 'WAITING_FOR_IOP'
						AND reasoncode NOT IN(
						'SYSTEM_ERROR', 'TOOOLDTRIP', 'Unknown'
						) THEN 'IR'
						ELSE 'Unknown'
					END AS rpt_irrejectstatus,
					--:: Metrics
					ss.txncount,
					ss.expectedamount,
					ss.adjustedexpectedamount,
					ss.calcadjustedamount,
					ss.tripwithadjustedamount,
					ss.tollamount,
					ss.actualpaidamount,
					ss.outstandingamount,
					ss.lnd_updatedate,
					ss.edw_updatedate
					FROM
						_SESSION.cte_bubblesummarysnapshot AS ss
					INNER JOIN EDW_TRIPS.Dim_Facility AS f ON f.facilityid = ss.facilityid
					INNER JOIN EDW_TRIPS.Dim_OperationsMapping AS om ON om.operationsmappingid = ss.operationsmappingid
			;
			SET log_message = concat('Loaded EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot for @SnapshotMonthID ', substr(CAST(var_snapshotmonthid as STRING), 1, 30));
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
			
			-- Revert back to original state. 
			IF renamesummarytableflag = 1
			THEN
				ALTER TABLE EDW_TRIPS.Fact_UnifiedTransaction_Summary
				RENAME TO Fact_UnifiedTransaction_Summary_ThisRun;
				ALTER TABLE EDW_TRIPS.Fact_UnifiedTransaction_Summary_NEW
				RENAME TO Fact_UnifiedTransaction_Summary;
				SET log_message = 'Renamed Fact_UnifiedTransaction_Summary_NEW back to Fact_UnifiedTransaction_Summary. All set!';
				CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
			END IF; 

			--=============================================================================================================
			--:: Preserve the tables for Snapshot data validation afterwards
			--=============================================================================================================

			IF boardreportingrunflag = 1 /*means, prod run on 4th of the month or override Board Reporting Snapshot run*/
			OR (trace_flag = 1 AND backup_flag = 1) 
			THEN
				--:: Backup dbo.Fact_UnifiedTransaction_SummarySnapshot
				DROP TABLE IF EXISTS EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot_PrevRun;
				IF (SELECT count(1) FROM EDW_TRIPS.INFORMATION_SCHEMA.TABLES WHERE LOWER(table_name)=LOWER('Fact_UnifiedTransaction_SummarySnapshot_ThisRun')) !=0 THEN 
					ALTER TABLE EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot_ThisRun
					RENAME TO Fact_UnifiedTransaction_SummarySnapshot_PrevRun;
				End IF;
				CREATE TABLE EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot_ThisRun CLUSTER BY snapshotmonthid
				AS SELECT Fact_UnifiedTransaction_SummarySnapshot.*, 
					current_datetime('America/Chicago') AS backupdate
					FROM EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot;
				SET log_message = 'Backup EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot after the Monthly Snapshot';
				CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
				
				--:: Backup dbo.Dim_OperationsMapping          
				DROP TABLE IF EXISTS EDW_TRIPS.Dim_OperationsMapping_PrevRun;
				IF (SELECT count(1) FROM EDW_TRIPS.INFORMATION_SCHEMA.TABLES WHERE LOWER(table_name)=LOWER('Dim_OperationsMapping_ThisRun')) !=0 THEN 
					ALTER TABLE EDW_TRIPS.Dim_OperationsMapping_ThisRun
					RENAME TO Dim_OperationsMapping_PrevRun;
				End IF;
				CREATE TABLE EDW_TRIPS.Dim_OperationsMapping_ThisRun CLUSTER BY operationsmappingid
				AS SELECT Dim_OperationsMapping.*,
						current_datetime('America/Chicago') AS backupdate
					FROM EDW_TRIPS.Dim_OperationsMapping;
				
				SET log_message = 'Backup EDW_TRIPS.Dim_OperationsMapping after the Monthly Snapshot';
				CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
				
				--:: Saving Pats time. Purge Unknown mappings which carry no Txns in the entire Bubble Snapshot fact table and thus, no value.  
				DELETE FROM EDW_TRIPS.Dim_OperationsMapping WHERE edw_updatedate > date_add(last_day(date_add(current_datetime('America/Chicago'), interval -2 MONTH)), interval 1 DAY) -- First day of the last month
				AND NOT EXISTS ( SELECT 1
					FROM EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot AS ss
					WHERE Dim_OperationsMapping.operationsmappingid = ss.operationsmappingid
				)
				AND Dim_OperationsMapping.mappingdetailed = 'Unknown'; -- This is when Pat not yet updated Unknown mappings for those rows having no Txns in the entire Bubble Snapshot fact table
				SET log_message = 'Deleted new Unknown mapping rows in EDW_TRIPS.Dim_OperationsMapping which do not map to any Txns in the entire Bubble Snapshot fact table';
				CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

				IF refreshunknownmappingsflag = 0  -- First run, not the subsequent run after Pat updated Unknown mappings. Save time in DEV by not touching these backup tables after monthly APS2 DB refresh!
				THEN 
					--:: Backup Stage.UnifiedTransaction
					DROP TABLE IF EXISTS EDW_TRIPS_STAGE.UnifiedTransaction_PrevRun;
					IF (SELECT count(1) FROM EDW_TRIPS_STAGE.INFORMATION_SCHEMA.TABLES WHERE LOWER(table_name)=LOWER('UnifiedTransaction_ThisRun')) !=0 THEN 
						ALTER TABLE EDW_TRIPS_STAGE.UnifiedTransaction_ThisRun
						RENAME TO UnifiedTransaction_PrevRun;
					End IF;
					CREATE TABLE EDW_TRIPS_STAGE.UnifiedTransaction_ThisRun
						AS
						SELECT *, current_datetime('America/Chicago') AS backupdate
							FROM EDW_TRIPS_STAGE.UnifiedTransaction;
					SET log_message = 'Backup EDW_TRIPS_STAGE.UnifiedTransaction after the Monthly Snapshot';
					CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
					
					--:: Backup dbo.Fact_UnifiedTransaction
					DROP TABLE IF EXISTS EDW_TRIPS.Fact_UnifiedTransaction_PrevRun;
					IF (SELECT count(1) FROM EDW_TRIPS.INFORMATION_SCHEMA.TABLES WHERE LOWER(table_name)=LOWER('Fact_UnifiedTransaction_ThisRun')) !=0 THEN 
						ALTER TABLE EDW_TRIPS.Fact_UnifiedTransaction_ThisRun
						RENAME TO Fact_UnifiedTransaction_PrevRun;
					End IF;

					CREATE TABLE EDW_TRIPS.Fact_UnifiedTransaction_ThisRun
						AS 
						SELECT *,current_datetime('America/Chicago') AS backupdate
							FROM EDW_TRIPS.Fact_UnifiedTransaction;

					SET log_message = 'Backup EDW_TRIPS.Fact_UnifiedTransaction after the Monthly Snapshot';
					CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
					
					--:: Backup dbo.Fact_UnifiedTransaction_Summary
					DROP TABLE IF EXISTS EDW_TRIPS.Fact_UnifiedTransaction_Summary_PrevRun;
					IF (SELECT count(1) FROM EDW_TRIPS.INFORMATION_SCHEMA.TABLES WHERE LOWER(table_name)=LOWER('Fact_UnifiedTransaction_Summary_ThisRun')) !=0 THEN 
						ALTER TABLE EDW_TRIPS.Fact_UnifiedTransaction_Summary_ThisRun
						RENAME TO Fact_UnifiedTransaction_Summary_PrevRun;
					End IF;
					CREATE TABLE EDW_TRIPS.Fact_UnifiedTransaction_Summary_ThisRun
						AS
						SELECT Fact_UnifiedTransaction_Summary.*,
							current_datetime('America/Chicago') AS backupdate
							FROM EDW_TRIPS.Fact_UnifiedTransaction_Summary;

					SET log_message = 'Backup EDW_TRIPS.Fact_UnifiedTransaction_Summary after the Monthly Snapshot';
					CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
				END IF;
			END IF;
			END;
      ELSEIF EXISTS ( SELECT 1 FROM EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot
          WHERE snapshotmonthid = var_snapshotmonthid
      ) THEN
        SET log_message = concat('Monthly Bubble Summary Snapshot for ', substr(CAST(var_snapshotmonthid as STRING), 1, 30), ' already has ', substr(CAST(currentsnapshotscount as STRING), 1, 30), ' Snapshot(s) and the last one was created on ', coalesce(concat('@AsOfDayID_LastRun = ', substr(CAST(asofdayid_lastrun as STRING), 1, 30), '. '), 'N/A')) ;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
      END IF;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);
      IF trace_flag = 1 THEN
		SELECT
			'EDW_TRIPS.Fact_UnifiedTransaction_SummarySnapshot' AS tablename,
			*
			FROM
			EDW_TRIPS.fact_unifiedtransaction_summarysnapshot
			WHERE fact_unifiedtransaction_summarysnapshot.snapshotmonthid = fact_unifiedtransaction_summarysnapshot._u0040_snapshotmonthid
		ORDER BY
			2 DESC,
			3 DESC,
			4,
			5,
			6,
			7
		LIMIT 1000
		;
	  END IF;

      
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source,log_start_date, error_message, 'E', NULL, NULL);
        -- CALL EDW_TRIPS_SUPPORT.FromLog(log_source,log_start_date);
        select log_source, log_start_date;
        RAISE USING MESSAGE = error_message;  -- Rethrow the error!
      END;
    END;
    
/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================

EXEC dbo.Fact_UnifiedTransaction_SummarySnapshot_Full_Load @BoardReportingRunFlag = 0, @CreateSnapshotOnDemandFlag = 0
SELECT * FROM Utility.ProcessLog Where LogSource = 'dbo.Fact_UnifiedTransaction_SummarySnapshot_Full_Load' ORDER BY 1 DESC

SELECT SnapshotMonthID,AsOfDayID, SUM(TxnCount) TxnCount, SUM(ExpectedAmount) ExpectedAmount, SUM(AdjustedExpectedAmount) AdjustedExpectedAmount, SUM(ActualPaidAmount) ActualPaidAmount
FROM dbo.Fact_UnifiedTransaction_SummarySnapshot
GROUP BY SnapshotMonthID, AsOfDayID
ORDER BY 1 DESC,2 

SELECT DISTINCT OperationsMappingID FROM dbo.Fact_UnifiedTransaction_SummarySnapshot  WHERE SnapshotMonthID = 202211 AND MappingDetailed = 'unknown'

SELECT TOP 1000 'dbo.Fact_UnifiedTransaction_SummarySnapshot' TableName, * FROM dbo.Fact_UnifiedTransaction_SummarySnapshot WHERE SnapshotMonthID = 202211 ORDER BY SnapshotMonthID, AsOfDayID, RowSeq

--===============================================================================================================
--  Latest Bubble Snapshot Rows csv file output
--===============================================================================================================
--:: Unknown Bubble Snapshot Rows check
SELECT TOP 100 * FROM dbo.vw_BubbleSummarySnapshot WHERE SnapshotMonthID = @SnapshotMonthID AND AsOfDayID = @AsOfDayID AND (MappingDetailed = 'Unknown' OR PursUnPursStatus = 'Unknown') ORDER BY SnapshotMonthID, AsOfDayID, RowSeq
--:: Unknown mappings in Dim_OperationsMapping rows
SELECT TOP 100 * FROM dbo.Dim_OperationsMapping WHERE OperationsMappingID in (SELECT DISTINCT OperationsMappingID FROM dbo.vw_BubbleSummarySnapshot WHERE SnapshotMonthID = @SnapshotMonthID AND (MappingDetailed = 'Unknown' OR PursUnPursStatus = 'Unknown'))

-- Query for monthly Bubble csv file: \\nttafs1\Groups\NTTA\Operations-Analytics\00 Reporting\Bubble Spreadsheets Used for Board Reporting\csv\Bubble Summary Snapshot_*.csv
DECLARE @SnapshotMonthID INT, @AsofDayID INT
SELECT @SnapshotMonthID = MAX(SnapshotMonthID) FROM [dbo].[Fact_UnifiedTransaction_SummarySnapshot]
SELECT @AsofDayID = MAX(AsofDayID) FROM [dbo].[Fact_UnifiedTransaction_SummarySnapshot] WHERE SnapshotMonthID = @SnapshotMonthID
SELECT TOP 100 * FROM dbo.vw_BubbleSummarySnapshot WHERE SnapshotMonthID = @SnapshotMonthID AND AsOfDayID = @AsOfDayID ORDER BY SnapshotMonthID, AsOfDayID, RowSeq

-- See Data Manager Process 8532 in 9012 Package to refresh Unknown Mappings and export Bubble SummarySnapshot csv file

--===============================================================================================================
-- Quick check
--===============================================================================================================
DECLARE @SnapshotMonthID INT
SELECT @SnapshotMonthID = MAX(SnapshotMonthID) FROM dbo.Fact_UnifiedTransaction_SummarySnapshot

SELECT	 ut.TripMonthID/100,SUM(ut.TxnCount) TxnCount 
FROM	dbo.Fact_UnifiedTransaction_SummarySnapshot ut 
		JOIN dbo.Dim_Facility f ON f.FacilityID = ut.FacilityID 
		JOIN dbo.Dim_OperationsMapping OM ON OM.OperationsMappingID = ut.OperationsMappingID
WHERE	ut.SnapshotMonthID = 202205 AND F.FacilityCode LIKE 'NE%49'
GROUP BY ut.TripMonthID/100 o
ORDER BY 1

SELECT	ut.TripDayID/10000 TripYear, SUM(ut.TxnCount) TxnCount 
FROM	dbo.Fact_UnifiedTransaction_Summary ut 
		JOIN dbo.Dim_Lane l ON l.LaneID = ut.LaneID 
		JOIN dbo.Dim_OperationsMapping OM ON OM.OperationsMappingID = ut.OperationsMappingID
WHERE	  l.FacilityCode LIKE 'NE%49' AND ut.TripDayID < 20220601
GROUP BY ut.TripDayID/10000
ORDER BY 1

--=================================================================================================
-- Post Monthly Bubble Run data validation script. Preliminary checks.
--=================================================================================================

--:: TBOS vs LND Row Counts compare data monitor query. CreatedDate works great for majority of the tables for stable daily row count comparison between SRC and APS.
SELECT  * 
FROM    LND_TBOS.Utility.vw_CDCCompareSummary 
WHERE   NonMatching_RowCount <> 0 -->> 100 % row counts match on all days
        AND TableName NOT IN ('History.TP_Customer_Attributes','History.TP_Customers','IOP.BOS_IOP_OutboundTransactions','TollPlus.TP_Customer_Tags_History','TollPlus.TP_CustomerTrips','EIP.Results_Log','TollPlus.TP_Customer_Vehicle_Tags','TollPlus.TP_Customer_Vehicles','TollPlus.TP_Customer_Tags') 
UNION ALL
--:: CreatedDate is not suitable for some tables as new rows updated can have any old CreatedDate. Use NonMatching_RowPercent as a reasonable indicator to call for attention.
--:: Note: The pre-condition for this compare to work is that you capture SRC and APS row counts almost at the same time, never too far!
SELECT  * 
FROM    LND_TBOS.Utility.vw_CDCCompareSummary 
WHERE   NonMatching_RowPercent > 0.1 -->> 99.9% row counts match
        AND TableName IN ('History.TP_Customer_Attributes','History.TP_Customers','IOP.BOS_IOP_OutboundTransactions','TollPlus.TP_Customer_Tags_History','TollPlus.TP_CustomerTrips','EIP.Results_Log','TollPlus.TP_Customer_Vehicle_Tags','TollPlus.TP_Customer_Vehicles','TollPlus.TP_Customer_Tags') 
ORDER BY DataBaseName DESC, TableName

--Sample data check
SELECT 'Stage.UnifiedTransaction' TableName, COUNT_BIG(1) RC FROM Stage.UnifiedTransaction  
SELECT TOP 1000 'Stage.UnifiedTransaction' TableName, * FROM Stage.UnifiedTransaction --ORDER BY TripDate DESC,TPTripID
SELECT TOP 1000 'dbo.Fact_UnifiedTransaction' TableName, * FROM dbo.Fact_UnifiedTransaction --ORDER BY TripDate DESC,TPTripID
SELECT TOP 1000 'dbo.Fact_UnifiedTransaction_Summary' TableName, * FROM dbo.Fact_UnifiedTransaction_Summary --ORDER BY 2 DESC,3,4
SELECT TOP 1000 'Fact_UnifiedTransaction_SummarySnapshot' TableName, * FROM dbo.Fact_UnifiedTransaction_SummarySnapshot WHERE SnapshotMonthID = 202202
ORDER BY SnapshotMonthID DESC, TripMonthID DESC, OperationsMappingID, FacilityID
SELECT 'Fact_UnifiedTransaction_SummarySnapshot' TableName, SnapshotMonthID, AsOfDayID, * FROM dbo.Fact_UnifiedTransaction_SummarySnapshot WHERE SnapshotMonthID = 202202
ORDER BY SnapshotMonthID DESC, TripMonthID DESC, OperationsMappingID, FacilityID

--::Input check on APS1 
SELECT COUNT_BIG(1) LND_TxnCount , MIN(EXITTRIPDATETIME) [TripDateFrom], MAX(EXITTRIPDATETIME) TripDateTo
FROM LND_TBOS.TollPlus.TP_Trips TT (NOLOCK)
WHERE TT.ExitTripDateTime >= '01/01/2019'
AND TT.ExitTripDateTime < '11/01/2022'  
AND TT.SourceOfEntry IN (1,3) --TSA & NTTA 
AND TT.Exit_TollTxnID >= 0
AND TT.LND_UpdateType <> 'd'

--:: Input check on TBOS. Run it in Prod TBOS source also on NPRODTBOSLSTR02 (takes 20 to 30 min). Both should match.
SELECT COUNT_BIG(1) LND_TxnCount , MIN(EXITTRIPDATETIME) [TripDateFrom], MAX(EXITTRIPDATETIME) TripDateTo
FROM TollPlus.TP_Trips TT (NOLOCK)
WHERE TT.ExitTripDateTime >= '01/01/2019'
AND TT.ExitTripDateTime < '10/01/2022'  
AND TT.SourceOfEntry IN (1,3) --TSA & NTTA 
AND TT.Exit_TollTxnID >= 0

--=================================================================================================
-- Gold Standard Testing
--=================================================================================================

--:: Pat's Gold Standard Tests XL format

-- By TripMonth
SELECT SnapshotMonthID,AsOfDayID, TripMonthID, SUM(TxnCount) TxnCount, SUM(ExpectedAmount) ExpectedAmount, SUM(AdjustedExpectedAmount) AdjustedExpectedAmount, SUM(ActualPaidAmount) ActualPaidAmount
FROM dbo.Fact_UnifiedTransaction_SummarySnapshot
WHERE SnapshotMonthID in (202210, 202211)
AND TripMonthID <= 202210
GROUP BY SnapshotMonthID, AsOfDayID, TripMonthID
ORDER BY 1 DESC,2,3

-- By MappingDetailed
SELECT SnapshotMonthID,AsOfDayID, TripMonthID, Mapping, MappingDetailed, SUM(TxnCount) TxnCount, SUM(ExpectedAmount) ExpectedAmount, SUM(AdjustedExpectedAmount) AdjustedExpectedAmount, SUM(ActualPaidAmount) ActualPaidAmount
FROM dbo.Fact_UnifiedTransaction_SummarySnapshot
WHERE SnapshotMonthID in (202210, 202211)
AND TripMonthID <= 202210
GROUP BY SnapshotMonthID, AsOfDayID, TripMonthID, Mapping, MappingDetailed
ORDER BY 1 DESC,2,3,4,5


------ 1. Gold Standard-Total Counts ------

select	'APS1 202210 vs 202211 Snapshots' SRC, SnapshotMonthID,  
		TripMonthID/100 as TripYear, 
		sum(TxnCount)  TxnCount ,
		Sum(ExpectedAmount) ExpectedAmount
from edw_trips.dbo.Fact_UnifiedTransaction_SummarySnapshot 
where SnapshotMonthID in (202210, 202211)  -- Compare last 2 snapshots
and TripMonthID <= 202210 -- remove last month from the comparison
group by SnapshotMonthID ,  TripMonthID/100  
order by TripYear DESC, SnapshotMonthID desc							

--:: Gold standard side ways diff at TripYear level
SELECT *, a.TxnCount - b.TxnCount TxnCount_Diff, a.ExpectedAmount - b.ExpectedAmount ExpectedAmount_Diff
from
(
select	SnapshotMonthID,  
		TripMonthID/100 as TripYear, 
		sum(TxnCount)  TxnCount ,
		Sum(ExpectedAmount) ExpectedAmount
from edw_trips.dbo.Fact_UnifiedTransaction_SummarySnapshot 
where SnapshotMonthID = 202210 
and TripMonthID <= 202210 -- remove last month from the comparison
group by SnapshotMonthID ,  TripMonthID/100  
) b 
JOIN 
(
select	SnapshotMonthID,  
		TripMonthID/100 as TripYear, 
		sum(TxnCount)  TxnCount ,
		Sum(ExpectedAmount) ExpectedAmount
from edw_trips.dbo.Fact_UnifiedTransaction_SummarySnapshot 
where SnapshotMonthID = 202211 
and TripMonthID <= 202210 -- remove last month from the comparison
group by SnapshotMonthID ,  TripMonthID/100  
) a ON a.TripYear = b.TripYear
ORDER by TripYear DESC 

--:: Gold standard side ways diff at TripMonth level
SELECT *, a.TxnCount - b.TxnCount TxnCount_Diff, a.ExpectedAmount - b.ExpectedAmount ExpectedAmount_Diff
from
(
select	SnapshotMonthID,  
		TripMonthID, 
		sum(TxnCount)  TxnCount ,
		Sum(ExpectedAmount) ExpectedAmount
from edw_trips.dbo.Fact_UnifiedTransaction_SummarySnapshot 
where SnapshotMonthID = 202210 
and TripMonthID <= 202210 -- remove last month from the comparison
group by SnapshotMonthID ,  TripMonthID 
) b 
JOIN 
(
select	SnapshotMonthID,  
		TripMonthID, 
		sum(TxnCount)  TxnCount ,
		Sum(ExpectedAmount) ExpectedAmount
from edw_trips.dbo.Fact_UnifiedTransaction_SummarySnapshot 
where SnapshotMonthID = 202211 
and TripMonthID <= 202210 -- remove last month from the comparison
group by SnapshotMonthID ,  TripMonthID 
) a ON a.TripMonthID = b.TripMonthID							
ORDER by a.TripMonthID DESC 


SELECT COUNT(1) RC FROM stage.UnifiedTransaction_PrevRun WHERE TripDayID/100 = 202210  
SELECT COUNT(1) RC FROM stage.UnifiedTransaction_ThisRun WHERE TripDayID/100 = 202210  

--:: Diff examples
SELECT TM.TPTripID, TM.TripDate, TT.CreatedDate TP_Trips_CreatedDate, TT.UpdatedDate TP_Trips_UpdatedDate, TT.LND_UpdateDate LND_LoadDate -- select min(TT.CreatedDate)
--INTO SANDBOX.dbo.Bubble_GoldStandard_202210_Diff
FROM stage.UnifiedTransaction_ThisRun TM
LEFT JOIN stage.UnifiedTransaction_PrevRun PM ON pm.TPTripID = tm.TPTripID
JOIN LND_TBOS.TollPlus.TP_Trips TT ON TM.TPTripID = TT.TPTripID
WHERE tm.TripDayID/100 = 202210 
AND pm.TPTripID IS NULL 
ORDER BY TM.LND_UpdateDate, TM.TripDate

--:: TP_Trips load info
SELECT * FROM LND_TBOS.Utility.ProcessLog WHERE LogSource LIKE '%TP_Trips%' ORDER BY 1 desc
--:: Bubble load info
SELECT * FROM Utility.ProcessLog WHERE LogMessage LIKE '%UnifiedTransaction%' ORDER BY 1 desc

SELECT CONVERT(DATE,tm.LND_UpdateDate) LND_LoadDate, tm.TripDayID/100 TripMonthID, tm.SourceOfEntry, COUNT(1) TxnCount, SUM(tm.ExpectedAmount) ExpectedAmount
FROM stage.UnifiedTransaction_ThisRun TM
LEFT JOIN stage.UnifiedTransaction_PrevRun PM
ON pm.TPTripID = tm.TPTripID
WHERE tm.TripDayID/100 = 202210 
AND pm.TPTripID IS NULL 
GROUP BY CONVERT(DATE,tm.LND_UpdateDate), tm.TripDayID/100, tm.SourceOfEntry
ORDER BY 1

--:: Dup check
SELECT TPTripID, COUNT(1) RC FROM ref.TartTPTrip GROUP BY TPTripID HAVING COUNT(1) > 1
SELECT TPTripID, COUNT(1) RC FROM stage.UnifiedTransaction ut GROUP BY TPTripID HAVING COUNT(1) > 1
SELECT TPTripID, COUNT(1) RC FROM dbo.Fact_UnifiedTransaction ut GROUP BY TPTripID HAVING COUNT(1) > 1

-------Gold Standard-Counts by Mapping--------------
							
select	a.SnapshotMonthID,  
		b.Mapping,
		a.TripMonthID/100 as TransactionYear,
		sum(a.tXNcOUNT)  TxnCount ,
		sum(ExpectedAmount) ExpectedAmount
from	edw_trips.dbo.Fact_UnifiedTransaction_SummarySnapshot a
		join edw_trips.dbo.Dim_OperationsMapping b
			on a.OperationsMappingId = B.OperationsMappingID
where	a.SnapshotMonthID in (202210, 202211)  -- Compare last 2 snapshots
and TripMonthID != 202211 -- remove last month from the comparison
group by a.SnapshotMonthID ,  b.Mapping, a.TripMonthID/100 
order by 2,3 desc


*/

  END;