CREATE OR REPLACE PROCEDURE EDW_TRIPS_STAGE.NTTARawTransactions_Load(isfullload INT64)
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load Stage.NTTARawTransactions table to optmize dbo.Fact_UnifiedTransaction load as part of Bubble ETL Process 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040744	Shankar		2022-03-21	New!
CHG0041141	Shankar		2022-06-30	New columns added
            EGen		2024-April	Replaced PartitionSwitchRange with Delete & Insert 
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Stage.NTTARawTransactions_Load 1
SELECT * FROM Utility.ProcessLog WHERE LogSource = 'Stage.NTTARawTransactions_Load' ORDER BY 1 DESC
SELECT TOP 100 'Stage.NTTARawTransactions' Table_Name, * FROM Stage.NTTARawTransactions ORDER BY LND_UpdateDate DESC
###################################################################################################################
*/
    /*=========================================== TESTING ========================================================*/
		--DECLARE @IsFullLoad BIT = 1 
	/*=========================================== TESTING ========================================================*/

    DECLARE tablename STRING DEFAULT 'EDW_TRIPS_STAGE.NTTARawTransactions';
    DECLARE trace_flag INT64 DEFAULT 0; -- Testing
    DECLARE firstpartitionid INT64 DEFAULT 202101;
    DECLARE lastpartitionid INT64;
    DECLARE partition_ranges STRING;
    DECLARE createtablewith STRING DEFAULT '';
    DECLARE log_message STRING;
    DECLARE identifyingcolumns STRING DEFAULT 'TPTripID';
    DECLARE last_updated_date DATETIME DEFAULT CURRENT_DATETIME;
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS_STAGE.NTTARawTransactions_Load';
    DECLARE log_start_date DATETIME;
    DECLARE stagetablename STRING DEFAULT 'EDW_TRIPS_STAGE.NTTARawTransactions_NEW';
    DECLARE firstdatetoload STRING DEFAULT '2021-01-01';
    DECLARE lastdatetoload STRING;
    DECLARE sql STRING;
    DECLARE sql1 STRING;
    BEGIN
    	SET log_start_date = current_datetime('America/Chicago');
      	-- SET lastdatetoload =  '2024-02-04T00:00:00';
      	SET lastdatetoload =  SUBSTR(CAST (current_datetime() AS STRING),1,10);
		SET lastpartitionid = CAST(substr(CAST(date_add(last_day(current_datetime()), interval 1 DAY) as STRING FORMAT 'yyyymmdd'), 1, 6) as INT64);
		IF (SELECT count(1) FROM  `EDW_TRIPS_STAGE.INFORMATION_SCHEMA.TABLES` WHERE LOWER(table_name)=lower(SUBSTR(tablename,STRPOS(tablename,'.')+1))) =0 THEN
			SET isfullload = 1;
		END IF;
		IF isfullload = 1 THEN
			-- Commenting These  partition related Utilities, Not Required in BQ 
			--CALL EDW_TRIPS_SUPPORT.get_partitiondayidrange_string(substr(CAST(firstpartitionid as STRING), 1, 10), substr(CAST(lastpartitionid as STRING), 1, 10), partition_ranges);
			--SET createtablewith = concat('(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (', partition_ranges, ')))');
			--SET @CreateTableWith = '(CLUSTERED INDEX (' + @IdentifyingColumns + '), DISTRIBUTION = HASH(TPTripID), PARTITION (DayID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + ')))'
			
			-- Adding Same as Incremental Load Since BQ Does not Supports Range PARTITION 
			SET createtablewith = concat(' CLUSTER BY ', identifyingcolumns);
			SET log_message = 'Started full load';
		ELSE
			SET createtablewith = concat(' CLUSTER BY ', identifyingcolumns);
			IF trace_flag = 1 THEN
          		select concat("Calling: EDW_TRIPS_SUPPORT.Get_UpdatedDate for ",tablename);
        	END IF;
			CALL EDW_TRIPS_SUPPORT.Get_UpdatedDate(tablename, last_updated_date);
			SET log_message = concat('Started incremental load from: ', substr(CAST(last_updated_date as STRING FORMAT 'yyyy-mm-dd hh:mi:ss.mmmm'), 1, 25));
		END IF;

		IF trace_flag = 1 THEN
           select log_message; 
      	END IF;
		CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
		--============================================================================================================
		-- Load Stage.NTTARawTransactions
		--============================================================================================================
		--SET sql1 = concat('DROP TABLE IF EXISTS  ',stagetablename ,';');
		SET sql = Concat( """ CREATE OR REPLACE TABLE """ , stagetablename , createtablewith , 
				""" AS SELECT
					tt.tptripid,
					tt.sourcetripid,
					coalesce(CAST(CAST( tt.exittripdatetime as STRING FORMAT 'yyyymmdd') as INT64), -1) AS tripdayid,
					tt.exittripdatetime AS tripdate,
					tt.sourceofentry,
					nraw.recordtype,
					nraw.violationserialnumber,
					nraw.vestimestamp,
					CAST(date_add(nraw.vestimestamp, interval CASE
						WHEN nraw.vestimestamp BETWEEN tz.dst_start_date_utc AND tz.dst_end_date_utc THEN -5
						ELSE -6
					END HOUR) as DATETIME) AS localvestimestamp,
					tt.exitlaneid AS laneid,
					nraw.facilitycode,
					nraw.plazacode,
					nraw.lane AS lanenumber,
					nraw.vehiclespeed,
					nraw.revenuevehicleclass,
					nraw.tagstatus AS lanetagstatus,
					nraw.fareamount,
					nraw.lnd_updatedate,
					current_datetime() AS edw_updatedate
				FROM
					LND_TBOS.TollPlus_TP_Trips AS tt
					INNER JOIN LND_TBOS.TranProcessing_NTTARawTransactions AS nraw ON nraw.txnid = tt.sourcetripid
				AND tt.sourceofentry = 1
					LEFT OUTER JOIN LND_TBOS_SUPPORT.time_zone_offset AS tz ON extract(YEAR from CAST(nraw.vestimestamp as DATE)) = tz.yyyy
				WHERE 1 = 1
					AND tt.exit_tolltxnid >= 0
					AND tt.exittripdatetime >= @First_DateToLoad
					AND tt.exittripdatetime < @Last_DateToLoad 
					AND tt.lnd_updatetype <> 'D'
					AND nraw.lnd_updatetype <> 'D' """);

		IF isfullload <> 1 THEN
			SET sql = replace(sql, 'WHERE 1 = 1', concat('WHERE nraw.LND_UpdateDate > @Last_UpdatedDate '));
			EXECUTE IMMEDIATE sql using  firstdatetoload as First_DateToLoad , lastdatetoload as  Last_DateToLoad , last_updated_date as Last_UpdatedDate ;
		ELSE
			EXECUTE IMMEDIATE sql using  firstdatetoload as First_DateToLoad , lastdatetoload as  Last_DateToLoad ;
		END IF;
		IF trace_flag = 1 THEN
        	Select sql;
      	END IF;

		IF ( SELECT count(1) FROM EDW_TRIPS_STAGE.nttarawtransactions_new ) = 0 
		THEN
			SET log_message = concat('No data to load into ', stagetablename);
		ELSE
			SET log_message = concat('Loaded ', stagetablename);
		END IF;

		CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));

		IF isfullload = 1 THEN
			-- Table swap!
			--CALL EDW_TRIPS_SUPPORT.tableswap(stagetablename, tablename);
			SET sql = concat("Create OR REPLACE Table ", tablename , " as Select * from ",stagetablename );
			EXECUTE IMMEDIATE sql;
			SET log_message = 'Completed full load';
		ELSE
			--CALL EDW_TRIPS_SUPPORT.managepartitions_dateid(tablename, 'DayID:Month');
			-- Commenting partitionswitch_range , replaced with delete & Insert 
			--CALL EDW_TRIPS_SUPPORT.partitionswitch_range(stagetablename, tablename, identifyingcolumns, CAST(NULL as STRING));
			
			-- Dropping Records From Main Table To Avoid Duplicates
			SET sql = concat("Delete From ", tablename , " where ", identifyingcolumns ," In ( Select ", identifyingcolumns , " from ",stagetablename , " )" );
			EXECUTE IMMEDIATE sql;
			
			-- Inserting NEW Records from Stage to Main Table
			SET sql = concat("Insert Into  ", tablename , " Select * from ",stagetablename );
			EXECUTE IMMEDIATE sql;
			
			SET log_message = concat('Completed Incremental load from ', substr(CAST(last_updated_date as STRING FORMAT 'yyyy-mm-dd hh:mi:ss.mmmm'), 1, 25));
		END IF;
      
		SET last_updated_date = CAST(NULL as DATETIME);
		CALL EDW_TRIPS_SUPPORT.Set_UpdatedDate(tablename, tablename, last_updated_date);
		-- So we going to manually set Updated date to be sure it didnt cach any error before that
		
		SET log_message = concat(log_message, '. Set Last Update date as ', substr(CAST(last_updated_date as STRING FORMAT 'yyyy-mm-dd hh:mi:ss.mmmm'), 1, 25));
		IF trace_flag = 1 THEN
          select log_message;
      	END IF;
		CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));

		EXCEPTION WHEN ERROR THEN
		BEGIN
			DECLARE error_message STRING DEFAULT @@error.message;
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date,error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
			--CALL EDW_TRIPS_SUPPORT.fromlog(tablename, substr(CAST(log_start_date as STRING), 1, 23));
			SELECT tablename, log_start_date;
			RAISE USING MESSAGE = error_message;-- Rethrow the error!
		END;


	END;
/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================
EXEC Stage.NTTARawTransactions_Load 0
SELECT * FROM Utility.ProcessLog WHERE LogSource = 'Stage.NTTARawTransactions_Load' ORDER BY 1 DESC
SELECT * FROM Utility.LoadProcessControl WHERE TableName LIKE '%NTTARawTransactions%'
SELECT TOP 100 'Stage.NTTARawTransactions' TableName, * FROM Stage.NTTARawTransactions ORDER BY 2

SELECT TOP 10 * FROM LND_TBOS.TranProcessing.NTTARawTransactions WHERE LND_UpdateDate > '5/22/2022'  

SELECT LND_UpdateDate, COUNT(*) RC FROM LND_TBOS.TranProcessing.NTTARawTransactions WHERE LND_UpdateDate > '5/22/2022' GROUP BY LND_UpdateDate ORDER BY LND_UpdateDate DESC
SELECT COUNT(*) RC, MAX(EDW_UpdateDate) FROM Stage.NTTARawTransactions_NEW
SELECT COUNT(*) RC, MAX(EDW_UpdateDate) FROM Stage.NTTARawTransactions

--:: Testing
EXEC Stage.NTTARawTransactions_Load 1

EXEC Utility.FromLog 'Stage.NTTARawTransactions', 1

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'Stage.NTTARawTransactions', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  

EXEC Utility.Set_UpdatedDate 'Stage.NTTARawTransactions', NULL, '2022-05-22'

EXEC Stage.NTTARawTransactions_Load 0

EXEC Utility.FromLog 'Stage.NTTARawTransactions', 3

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'Stage.NTTARawTransactions', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  

--===============================================================================================================
-- !!! Dynamic SQL!!!
--===============================================================================================================

--:: Full Load
IF OBJECT_ID('Stage.NTTARawTransactions_NEW','U') IS NOT NULL			DROP TABLE Stage.NTTARawTransactions_NEW;

CREATE TABLE Stage.NTTARawTransactions_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (20190101,20190201,20190301,20190401,20190501,20190601,20190701,20190801,20190901,20191001,20191101,20191201,20200101,20200201,20200301,20200401,20200501,20200601,20200701,20200801,20200901,20201001,20201101,20201201,20210101,20210201,20210301,20210401,20210501,20210601,20210701,20210801,20210901,20211001,20211101,20211201,20220101,20220201,20220301,20220401,20220501,20220601,20220701,20220801))) AS
SELECT 
	TT.TPTripID
	, TT.SourceTripID
	, ISNULL(CAST(CONVERT(VARCHAR(8), TT.ExitTripDateTime, 112) AS INT), -1) AS TripDayID
	, TT.ExitTripDateTime TripDate -- NRaw.Timestamp is TripDateUTC
	, TT.SourceOfEntry
	, NRaw.RecordType
	, NRaw.ViolationSerialNumber
	, NRaw.VesTimestamp -- In UTC. May not be precisely equal to TripDate, but is important in the 5 key join with IPS to find TPTripID
	, CAST(DATEADD(HOUR, CASE WHEN NRaw.VesTimestamp BETWEEN tz.DST_Start_Date_UTC AND tz.DST_End_Date_UTC THEN -5 ELSE -6 END, NRaw.VesTimestamp) AS DATETIME2(3)) AS LocalVesTimestamp
	, TT.ExitLaneID LaneID
	, NRaw.FacilityCode
	, NRaw.PlazaCode
	, NRaw.Lane LaneNumber
	, NRaw.VehicleSpeed
	, NRaw.RevenueVehicleClass
	, NRaw.TagStatus LaneTagStatus
	, NRaw.FareAmount
	, NRaw.LND_UpdateDate
	, CAST(SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate
FROM LND_TBOS.TOLLPLUS.TP_TRIPS TT 
JOIN LND_TBOS.TranProcessing.NTTARawTransactions NRaw
		ON NRaw.TxnID = TT.SourceTripID AND TT.SourceOfEntry = 1 -- NTTA 
LEFT JOIN LND_TBOS.Utility.Time_Zone_Offset TZ
		ON YEAR(NRaw.VesTimestamp) = tz.YYYY
WHERE 1 = 1 
	AND TT.Exit_TollTxnID >= 0
	AND TT.ExitTripDateTime >= '2021-01-01'  
	AND TT.ExitTripDateTime <  '2022-06-15'
	AND TT.LND_UpdateType <> 'D'
	AND NRaw.LND_UpdateType <> 'D'

OPTION (LABEL = 'Stage.NTTARawTransactions_NEW');

CREATE STATISTICS Stats_Stage_NTTARawTransactions_001 ON Stage.NTTARawTransactions_NEW(TpTripID)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_002 ON Stage.NTTARawTransactions_NEW(TripDayID)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_003 ON Stage.NTTARawTransactions_NEW(SourceTripID)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_004 ON Stage.NTTARawTransactions_NEW(TripDate)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_005 ON Stage.NTTARawTransactions_NEW(ViolationSerialNumber)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_006 ON Stage.NTTARawTransactions_NEW(VesTimestamp)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_007 ON Stage.NTTARawTransactions_NEW(VehicleSpeed)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_008 ON Stage.NTTARawTransactions_NEW(RevenueVehicleClass)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_009 ON Stage.NTTARawTransactions_NEW(LaneTagStatus)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_010 ON Stage.NTTARawTransactions_NEW(FacilityCode)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_011 ON Stage.NTTARawTransactions_NEW(PlazaCode)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_012 ON Stage.NTTARawTransactions_NEW(LaneNumber)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_013 ON Stage.NTTARawTransactions_NEW(LaneID)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_014 ON Stage.NTTARawTransactions_NEW(FareAmount)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_501 ON Stage.NTTARawTransactions_NEW(LND_UpdateDate)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_502 ON Stage.NTTARawTransactions_NEW(EDW_UpdateDate)

--:: Incremental Load

IF OBJECT_ID('Stage.NTTARawTransactions_NEW','U') IS NOT NULL			DROP TABLE Stage.NTTARawTransactions_NEW;

CREATE TABLE Stage.NTTARawTransactions_NEW WITH (CLUSTERED INDEX ([TPTripID]), DISTRIBUTION = HASH(TPTripID)) AS
SELECT 
	TT.TPTripID
	, TT.SourceTripID
	, ISNULL(CAST(CONVERT(VARCHAR(8), TT.ExitTripDateTime, 112) AS INT), -1) AS TripDayID
	, TT.ExitTripDateTime TripDate -- NRaw.Timestamp is TripDateUTC
	, TT.SourceOfEntry
	, NRaw.RecordType
	, NRaw.ViolationSerialNumber
	, NRaw.VesTimestamp -- In UTC. May not be precisely equal to TripDate, but is important in the 5 key join with IPS to find TPTripID
	, CAST(DATEADD(HOUR, CASE WHEN NRaw.VesTimestamp BETWEEN tz.DST_Start_Date_UTC AND tz.DST_End_Date_UTC THEN -5 ELSE -6 END, NRaw.VesTimestamp) AS DATETIME2(3)) AS LocalVesTimestamp
	, TT.ExitLaneID LaneID
	, NRaw.FacilityCode
	, NRaw.PlazaCode
	, NRaw.Lane LaneNumber
	, NRaw.VehicleSpeed
	, NRaw.RevenueVehicleClass
	, NRaw.TagStatus LaneTagStatus
	, NRaw.FareAmount
	, NRaw.LND_UpdateDate
	, CAST(SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate
FROM LND_TBOS.TOLLPLUS.TP_TRIPS TT 
JOIN LND_TBOS.TranProcessing.NTTARawTransactions NRaw
		ON NRaw.TxnID = TT.SourceTripID AND TT.SourceOfEntry = 1 -- NTTA 
LEFT JOIN LND_TBOS.Utility.Time_Zone_Offset TZ
		ON YEAR(NRaw.VesTimestamp) = tz.YYYY
WHERE NRaw.LND_UpdateDate > '2022-03-03 00:00:00.000' 
	AND TT.Exit_TollTxnID >= 0
	AND TT.ExitTripDateTime >= '2022-01-01'  
	AND TT.ExitTripDateTime <  '2022-01-02'
	AND TT.LND_UpdateType <> 'D'
	AND NRaw.LND_UpdateType <> 'D'
OPTION (LABEL = 'Stage.NTTARawTransactions_NEW');

*/	

END;