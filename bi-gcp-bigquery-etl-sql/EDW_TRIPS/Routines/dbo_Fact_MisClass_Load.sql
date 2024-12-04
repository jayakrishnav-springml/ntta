CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_MisClass_Load`(isfullload INT64)
BEGIN
/*
IF OBJECT_ID ('dbo.Fact_MisClass_Load_New', 'P') IS NOT NULL DROP PROCEDURE dbo.Fact_MisClass_Load_New
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_MisClass_Load_New table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040590	Shekhar, Gouthami		2022-01-06	Created
CHG0040590	Shekhar					2022-03-01  The below Comments added for better explanation of the logic
CHG0044538  Gouthami				2024-02-07  1. Added vehicleclass <> 'null filter as Viaplus team updated vehicle 
												class value with 'null' for	131 trips which are in 2021. As this column 
												is INT, joining to dim_vehiclass is failing with conversion error.
												2. In order to avoid failure in our process , filtered out these trips.
												3. Reported this data issue to Anusha to raise this to Viaplus team.

Q: What is a misclass?
A: Equipment at the lane identifies the Axle count of the vehicle that passes through. If the lane equipment 
   incorrectly identifies the axle of a vehicle, we call that transaction as a misclass.

Q: How to identify a misclass?
A: There is no perfect way to identify a transaction as a misclass transaction. Our logic identifies a transaction 
   as a misclass with a fair amount of accuracy. It is as follows.
   Step 1:  Are there any other transactions during the same  day ? If yes, we identify them.
   Step 2:  What is the most frequent Axle Count for those transactions? We assume that this is the accurate Axle Count.
   Step 3:  If the current transaction's Axle count does not match the most frequent Axle Count for that day, we flag
            the current transaction as a misclass transaction.

   The above logic will not flag a transaction as a misclass "accurately" if:
	1. there is only one transaction in a day
	2. There are multiple "most frequent" Axle counts for a day.  Example: There are 10 txns in a day. 5 have an
	   axle count of 3 and the remaining 5 have an axle of count of 4. In this case we take the lowest(i.e. 3)
	   as the most frequent axle count. 


	Note: The above logic was tested by Cory & Raymond (ITS) by actually viewing the videos of vehicles. 
	      It was found to be satisfactorily accurate.

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_MisClass_Load 0

EXEC Utility.FromLog 'dbo.Fact_MisClass_Load_New', 1
SELECT TOP 100 'dbo.Fact_MisClass_Load_New' Table_Name, * FROM dbo.Fact_MisClass_Load_New ORDER BY 2

###################################################################################################################
*/
	/*====================================== TESTING =======================================================================*/
	--DECLARE @IsFullLoad BIT = 0
	/*====================================== TESTING =======================================================================*/

    DECLARE tablename STRING DEFAULT 'EDW_TRIPS.Fact_MisClass';
	DECLARE trace_flag INT64 DEFAULT 0; -- Testing
    DECLARE firstpartitionid INT64 DEFAULT 202001;
    DECLARE lastpartitionid INT64;
    DECLARE partition_ranges STRING;
    DECLARE identifyingcolumns STRING DEFAULT 'TPTripID';
    DECLARE createtablewith STRING;
    DECLARE log_message STRING;
    DECLARE last_updated_date DATETIME;
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_MisClass_Load';
    DECLARE log_start_date DATETIME;
    DECLARE stagetablename STRING DEFAULT 'EDW_TRIPS.Fact_MisClass_NEW';
    DECLARE sql STRING;
    BEGIN
      DECLARE startdate DATE;
      SET log_start_date = current_datetime('America/Chicago');
      SET startdate = CAST(datetime_add(datetime_add(DATETIME '1900-01-01 00:00:00', interval 0 DAY), interval datetime_diff(current_datetime(), datetime_add(DATETIME '1900-01-01 00:00:00', interval 0 DAY), YEAR) - 1 YEAR) AS DATE);
      SET lastpartitionid = CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d',date_add(last_day(date_add(current_datetime(),interval 1 MONTH)), interval 1 DAY)) as STRING), 1, 6) as INT64);
      IF (SELECT count(1) FROM EDW_TRIPS.INFORMATION_SCHEMA.TABLES WHERE LOWER(table_name)=lower(SUBSTR(tablename,STRPOS(tablename,'.')+1))) =0 THEN 
        SET isfullload = 1;
      END IF;
      IF isfullload = 1 THEN
        IF trace_flag = 1 THEN
        	--select 'Calling: EDW_TRIPS_SUPPORT.Get_PartitionDayIDRange_String from ' || CAST(firstpartitionid AS STRING)||' till ' || CAST(lastpartitionid as STRING);
        END IF;
        --CALL EDW_TRIPS_SUPPORT.Get_PartitionDayIDRange_String(substr(CAST(firstpartitionid as STRING), 1, 10), substr(CAST(lastpartitionid as STRING), 1, 10), partition_ranges);
        --Will use if go to columnstore - not delete this comment!!!!! ##  SET @CreateTableWith = '(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + ')))'
        --SET createtablewith = concat('(CLUSTERED INDEX (', identifyingcolumns, '), DISTRIBUTION = HASH(TPTripID), PARTITION (DayID RANGE RIGHT FOR VALUES (', partition_ranges, ')))');
    	SET createtablewith = concat(' CLUSTER BY ', identifyingcolumns);
		SET log_message = 'Started Full load';
      ELSE
        --SET createtablewith = concat('(CLUSTERED INDEX (', identifyingcolumns, '), DISTRIBUTION = HASH(TPTripID))');
        SET createtablewith = concat(' CLUSTER BY ', identifyingcolumns);
		IF trace_flag = 1 THEN
        	--select 'Calling: EDW_TRIPS_SUPPORT.Get_UpdatedDate for ' || tablename;
        END IF;
        CALL EDW_TRIPS_SUPPORT.Get_UpdatedDate(tablename, last_updated_date);
        --SET last_updated_date= coalesce(last_updated_date, CURRENT_DATETIME());
		SET log_message = concat('Started Incremental load from: ', substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_updated_date) as STRING), 1, 25));
      END IF;
      IF trace_flag = 1 THEN
       select log_message;
      END IF;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
       
      --=============================================================================================================
      -- Load dbo.Fact_MisClass
      --============================================================================================================
      
      --set sql="DROP TABLE IF EXISTS "||stagetablename||"";
      --EXECUTE IMMEDIATE sql;
      set sql="""CREATE OR REPLACE TABLE
			"""||stagetablename||""" """||createtablewith||""" AS
			WITH
			cw_ss AS (
			SELECT
				CAST( SUBSTR(CAST(FORMAT_DATETIME('%Y%m%d',tt.exittripdatetime) AS string),1,8) AS INT64) AS dayid,
				dvc.axles,
				tt.vehiclenumber AS vehiclenumber,
				tt.vehiclestate AS vehiclestate
			FROM
				LND_TBOS.TollPlus_TP_Trips AS tt
			INNER JOIN
				EDW_TRIPS.Dim_VehicleClass AS dvc
			ON
				(tt.vehicleclass) = CAST(dvc.vehicleclassid AS STRING)
				AND tt.vehicleclass IS NOT NULL
			WHERE
				CAST(exittripdatetime AS DATE) >= '"""||startdate||"""' ),
			vc AS (
			SELECT
				cw_ss.vehiclenumber|| cw_ss.vehiclestate AS vehiclenumber,
				cw_ss.dayid,
				cw_ss.axles,
				COUNT(1) AS frequency,
				MAX(COUNT(1)) OVER (PARTITION BY vehiclenumber, cw_ss.dayid) AS maxfrequency
			FROM
				cw_ss
			GROUP BY
				cw_ss.vehiclenumber,
				cw_ss.vehiclestate,
				cw_ss.axles,
				cw_ss.dayid ),
			vc1 AS (
			SELECT
				vc.vehiclenumber,
				vc.dayid,
				MIN(vc.axles) AS mostfrequentaxles
			FROM
				vc
			WHERE
				vc.frequency = vc.maxfrequency
			GROUP BY
				vc.vehiclenumber,
				vc.dayid )
			SELECT
			tt.tptripid,
			tt.tripwith,
			tt.exittripdatetime,
			CAST( SUBSTR(CAST(FORMAT_DATETIME('%Y%m%d',tt.exittripdatetime) AS string),1,8) AS INT64) AS dayid,
			dtim.tripidentmethodid,
			tt.exitlaneid AS laneid,
			COALESCE(tt.vehicleid, -1) AS vehicleid,
			tt.vehiclenumber|| tt.vehiclestate AS licenseplatenumber,
			dvc.axles AS reportedvehicleclassid,
			vc1.mostfrequentaxles AS mostfrequentvehicleclassid,
			tt.receivedtollamount AS tollsdue,
			tt.lnd_updatedate,
			COALESCE(CURRENT_DATETIME(), DATETIME '1900-01-01 00:00:00') AS edw_updatedate
			FROM
			LND_TBOS.TollPlus_TP_Trips AS tt
			INNER JOIN
			EDW_TRIPS.Dim_VehicleClass AS dvc
			ON
			(tt.vehicleclass) = CAST(dvc.vehicleclassid AS STRING)
			AND tt.vehicleclass IS NOT NULL
			INNER JOIN
			EDW_TRIPS.Dim_TripIdentMethod AS dtim
			ON
			tt.tripidentmethod = dtim.tripidentmethod
			INNER JOIN
			EDW_TRIPS.Dim_Lane AS dl
			ON
			dl.laneid = tt.exitlaneid
			INNER JOIN
			vc1
			ON
			vc1.vehiclenumber = tt.vehiclenumber|| tt.vehiclestate
			AND vc1.dayid = CAST( SUBSTR(CAST(FORMAT_DATETIME('%Y%m%d',tt.exittripdatetime) AS string),1,8) AS INT64)
			WHERE
			CAST(exittripdatetime AS DATE) >= '"""||startdate||"""'
			AND tt.vehiclenumber IS NOT NULL
			AND tt.vehiclenumber <> ''
			AND vc1.mostfrequentaxles <> dvc.axles""";
	  IF isfullload <> 1 THEN
		SET sql = replace(sql, "WITH cw_ss AS", """WITH changedtptripids_cte AS (
                         SELECT tp.tptripid 
						 FROM LND_TBOS.TollPlus_TP_Trips AS tp
						 WHERE tp.lnd_updatedate > \'"""||substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_updated_date) as STRING), 1, 25)||"""\' AND tp.vehicleclass IS NOT NULL), cw_ss AS""");       
	    SET sql= replace(sql,"CAST(exittripdatetime as DATE) >= \'"||startdate||"\'", "EXISTS ( SELECT 1 FROM changedtptripids_cte AS cte WHERE tt.tptripid = cte.tptripid)");
      END IF;
      
      EXECUTE IMMEDIATE sql;
      --Log
      SET log_message = concat('Loaded ', tablename);
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, sql);
      
      IF isfullload = 1 THEN
          
        --Table swap!
		-- Table Swap Not Required as we are using Create or Replace
        --CALL EDW_TRIPS_SUPPORT.TableSwap(stagetablename, tablename);
        CREATE OR REPLACE TABLE EDW_TRIPS.Fact_MisClass cluster by tptripid AS SELECT * FROM EDW_TRIPS.Fact_MisClass_NEW;
        SET log_message = 'Completed full load';
      ELSE
        IF trace_flag = 1 THEN
        	--select 'Calling: EDW_TRIPS_SUPPORT.ManagePartitions_DateID';
        END IF;
        --CALL EDW_TRIPS_SUPPORT.ManagePartitions_DateID(tablename, 'DayID:Month');
        IF trace_flag = 1 THEN
        	--select 'Calling: EDW_TRIPS_SUPPORT.PartitionSwitch_Range';
        END IF;
        --CALL EDW_TRIPS_SUPPORT.PartitionSwitch_Range(stagetablename, tablename, identifyingcolumns, CAST(NULL as STRING));
		-- Dropping Records From Main Table To Avoid Duplicates
        SET sql = concat("Delete From ", tablename , " where ", identifyingcolumns," In ( Select TPTripID from ",stagetablename , " )" );
        EXECUTE IMMEDIATE sql;
        
        -- Inserting NEW Records from Stage to Main Table
        SET sql = concat("Insert Into  ", tablename , " Select * from ",stagetablename );
        EXECUTE IMMEDIATE sql;

        --SET sql = concat('UPDATE STATISTICS  ', tablename);
        
        --EXECUTE IMMEDIATE sql;
        SET log_message = concat('Completed Incremental load from ', substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_updated_date) as STRING), 1, 25));
      END IF;
      SET last_updated_date = CAST(NULL as DATETIME);
      CALL EDW_TRIPS_SUPPORT.Set_UpdatedDate(tablename, tablename, last_updated_date);
      --So we going to manually set Updated date to be sure it didnt cach any error before that
      SET log_message = concat(log_message, '. Set Last Update date as ', substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_updated_date) as STRING), 1, 25));
      IF trace_flag = 1 THEN
        select log_message;
      END IF;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));

    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = error_message; ## Rethrow the error!
      END;
    END;
/*
----========Print of the query=======------

IF OBJECT_ID('dbo.Fact_MisClass_NEW','U') IS NOT NULL    DROP TABLE dbo.Fact_MisClass_NEW ;
	CREATE TABLE dbo.Fact_MisClass_NEW WITH (CLUSTERED INDEX ([TPTripID]), DISTRIBUTION = HASH(TPTripID), PARTITION (DayID RANGE RIGHT FOR VALUES (20200101,20200201,20200301,20200401,20200501,20200601,20200701,20200801,20200901,20201001,20201101,20201201,20210101,20210201,20210301,20210401,20210501,20210601,20210701,20210801,20210901,20211001,20211101,20211201,20220101,20220201,20220301,20220401,20220501))) AS 
	WITH VC AS
		(
		SELECT  (tt.VehicleNumber+tt.VehicleState) VehicleNumber,   
				CONVERT(INT,CONVERT(VARCHAR(8),tt.ExitTripDateTime,112)) AS DayID,
				dvc.Axles,
				COUNT(1)        AS Frequency,
				MAX(COUNT(1))   OVER (PARTITION BY VehicleNumber,  CONVERT(INT,CONVERT(VARCHAR(8),tt.ExitTripDateTime,112)) ) AS MaxFrequency
		FROM LND_TBOS.TollPlus.TP_Trips tt 
				JOIN EDW_TRIPS.dbo.Dim_VehicleClass dvc
				   ON tt.VehicleClass = dvc.VehicleClassID
		WHERE cast(ExitTripDateTime as Date) >='2021-01-01'
		GROUP  BY tt.VehicleNumber,tt.VehicleState, dvc.Axles,  CONVERT(INT,CONVERT(VARCHAR(8),tt.ExitTripDateTime,112))
		)
		, vc1 AS
		(
		SELECT  VehicleNumber , 
				DayID,
				MIN(Axles) AS MostFrequentAxles 
		FROM    VC
		WHERE    Frequency = MaxFrequency
		GROUP   BY VehicleNumber, DayID
		)
		SELECT  tt.TpTripID, 
				tt.TripWith, 
				tt.ExitTripDateTime, 
				CONVERT(INT,CONVERT(VARCHAR(8), tt.ExitTripDateTime,112)) AS DayID,
				dtim.TripIdentMethodID, 
				tt.ExitLaneID AS LaneID, 
				ISNULL(tt.VehicleID,-1) VehicleID,
				(tt.VehicleNumber+tt.VehicleState) LicensePlateNumber,
				dvc.Axles AS ReportedVehicleClassID,
				vc1.MostFrequentAxles MostFrequentVehicleClassID,
				tt.ReceivedTollAmount AS TollsDue,
				tt.LND_UpdateDate,
				ISNULL(CAST(SYSDATETIME() AS DATETIME2(7)), '1900-01-01') AS EDW_UpdateDate
		FROM    LND_TBOS.TollPlus.TP_Trips tt 
				JOIN EDW_TRIPS.dbo.Dim_VehicleClass dvc
					ON tt.VehicleClass = dvc.VehicleClassID
				JOIN   EDW_TRIPS.dbo.Dim_TripIdentMethod dtim
					ON tt.TripIdentMethod = dtim.TripIdentMethod
				JOIN    EDW_TRIPS.dbo.Dim_Lane dl
					ON dl.LaneID = tt.ExitLaneID
				JOIN    vc1 
					ON vc1.VehicleNumber = (tt.VehicleNumber+tt.VehicleState)
					AND vc1.DayID = CONVERT(INT,CONVERT(VARCHAR(8), tt.ExitTripDateTime,112)) 
				WHERE cast(ExitTripDateTime as Date) >='2021-01-01'
					AND   (tt.VehicleNumber is not null and tt.vehicleNumber != '') 					
					AND    vc1.MostFrequentAxles != dvc.Axles
					OPTION (LABEL = 'dbo.Fact_MisClass_NEW');

    (1 row(s) affected)
    

		CREATE STATISTICS Stats_dbo_Fact_MisClass_001 ON dbo.Fact_MisClass_NEW(DayID)
		CREATE STATISTICS STATS_dbo_Fact_MisClass_002 ON dbo.Fact_MisClass_NEW(LaneID)
		CREATE STATISTICS STATS_dbo_Fact_MisClass_003 ON dbo.Fact_MisClass_NEW(TripIdentMethodID)
		CREATE STATISTICS STATS_dbo_Fact_MisClass_004 ON dbo.Fact_MisClass_NEW(VehicleID)
		CREATE STATISTICS STATS_dbo_Fact_MisClass_005 ON dbo.Fact_MisClass_NEW(ReportedVehicleClassID)
		CREATE STATISTICS STATS_dbo_Fact_MisClass_006 ON dbo.Fact_MisClass_NEW(MostFrequentVehicleClassID)
		*/
/* -------Incremental query print
IF OBJECT_ID('dbo.Fact_MisClass_NEW','U') IS NOT NULL    DROP TABLE dbo.Fact_MisClass_NEW ;
	CREATE TABLE dbo.Fact_MisClass_NEW WITH (CLUSTERED INDEX ([TPTripID]), DISTRIBUTION = HASH(TPTripID)) AS 
	WITH ChangedTPTripIDs_CTE AS
		(	SELECT TP.TPTripID
			FROM LND_TBOS.TollPlus.TP_Trips TP
			WHERE TP.LND_UpdateDate > '1990-01-01 00:00:00.000'
		)
		,VC AS
		(
		SELECT  (tt.VehicleNumber+tt.VehicleState) VehicleNumber,   
				CONVERT(INT,CONVERT(VARCHAR(8),tt.ExitTripDateTime,112)) AS DayID,
				dvc.Axles,
				COUNT(1)        AS Frequency,
				MAX(COUNT(1))   OVER (PARTITION BY VehicleNumber,  CONVERT(INT,CONVERT(VARCHAR(8),tt.ExitTripDateTime,112)) ) AS MaxFrequency
		FROM LND_TBOS.TollPlus.TP_Trips tt 
				JOIN EDW_TRIPS.dbo.Dim_VehicleClass dvc
				   ON tt.VehicleClass = dvc.VehicleClassID
		WHERE EXISTS (SELECT 1 FROM ChangedTPTripIDs_CTE AS CTE WHERE TT.TPTripID = CTE.TPTripID)
		GROUP  BY tt.VehicleNumber,tt.VehicleState, dvc.Axles,  CONVERT(INT,CONVERT(VARCHAR(8),tt.ExitTripDateTime,112))
		)
		, vc1 AS
		(
		SELECT  VehicleNumber , 
				DayID,
				MIN(Axles) AS MostFrequentAxles 
		FROM    VC
		WHERE    Frequency = MaxFrequency
		GROUP   BY VehicleNumber, DayID
		)
		SELECT  tt.TpTripID, 
				tt.TripWith, 
				tt.ExitTripDateTime, 
				CONVERT(INT,CONVERT(VARCHAR(8), tt.ExitTripDateTime,112)) AS DayID,
				dtim.TripIdentMethodID, 
				tt.ExitLaneID AS LaneID, 
				ISNULL(tt.VehicleID,-1) VehicleID,
				(tt.VehicleNumber+tt.VehicleState) LicensePlateNumber,
				dvc.Axles AS ReportedVehicleClassID,
				vc1.MostFrequentAxles MostFrequentVehicleClassID,
				tt.ReceivedTollAmount AS TollsDue,
				tt.LND_UpdateDate,
				ISNULL(CAST(SYSDATETIME() AS DATETIME2(7)), '1900-01-01') AS EDW_UpdateDate
		FROM    LND_TBOS.TollPlus.TP_Trips tt 
				JOIN EDW_TRIPS.dbo.Dim_VehicleClass dvc
					ON tt.VehicleClass = dvc.VehicleClassID
				JOIN   EDW_TRIPS.dbo.Dim_TripIdentMethod dtim
					ON tt.TripIdentMethod = dtim.TripIdentMethod
				JOIN    EDW_TRIPS.dbo.Dim_Lane dl
					ON dl.LaneID = tt.ExitLaneID
				JOIN    vc1 
					ON vc1.VehicleNumber = (tt.VehicleNumber+tt.VehicleState)
					AND vc1.DayID = CONVERT(INT,CONVERT(VARCHAR(8), tt.ExitTripDateTime,112)) 
				WHERE EXISTS (SELECT 1 FROM ChangedTPTripIDs_CTE AS CTE WHERE TT.TPTripID = CTE.TPTripID)
					AND   (tt.VehicleNumber is not null and tt.vehicleNumber != '') 					
					AND    vc1.MostFrequentAxles != dvc.Axles
					OPTION (LABEL = 'dbo.Fact_MisClass_NEW');


*/
  END;