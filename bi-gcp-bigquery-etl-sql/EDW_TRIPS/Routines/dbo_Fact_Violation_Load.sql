CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_Violation_Load`(isfullload INT64)
BEGIN

/*
IF OBJECT_ID ('dbo.Fact_Violation_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Fact_Violation_Load
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_Violation_Load 1
EXEC Utility.FromLog 'dbo.Fact_Violation', 1
SELECT TOP 100 * FROM dbo.Fact_Violation 
SELECT count_BIG(*) CNT, 'dbo.Fact_Violation' AS TableName FROM dbo.Fact_Violation -- 786922727
SELECT count_BIG(*) CNT, 'LND_TBOS.TollPlus.TP_ViolatedTrips' AS TableName FROM LND_TBOS.TollPlus.TP_ViolatedTrips -- 787045884
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_Violation table. 

@IsFullLoad - 1 means forced Full load, 0 or NULL - incremental load. I the main table is not exists - it goes with full load.

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838  Bhanu/Gouthami  2020-12-31  New!
CHG0038039  Gouthami		2020-01-27	Added DeleteFlag
CHG0038304  Andy			2021-02-04  Changed to Full&Incremental load   -- Set correct Clog number
CHG0038458	Andy			03/30/2021	Save Last Update date in LoadProcessControl after successful run.  fixed CurrentTxnFlag. Added TRY/CATCH
###################################################################################################################
*/
    /*====================================== TESTING =======================================================================*/
    --DECLARE @IsFullLoad BIT = 1 
    /*====================================== TESTING =======================================================================*/

    DECLARE tablename STRING DEFAULT 'EDW_TRIPS.Fact_Violation';
    DECLARE trace_flag INT64 DEFAULT 0;-- Testing
    DECLARE firstpartitionid INT64 DEFAULT 200001;
    DECLARE lastpartitionid INT64;
    DECLARE partition_ranges STRING;
    DECLARE identifyingcolumns STRING DEFAULT 'CitationID';
    DECLARE createtablewith STRING DEFAULT '';
    DECLARE log_message STRING;
    DECLARE last_updated_date DATETIME;
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_Violation_Load';
    DECLARE log_start_date DATETIME;
    DECLARE stagetablename STRING DEFAULT 'EDW_TRIPS.Fact_Violation_NEW';
    DECLARE sql STRING;
    DECLARE sql1 STRING;
    DECLARE sql2 STRING;
    BEGIN
      SET log_start_date = current_datetime('America/Chicago');
      SET lastpartitionid = CAST(substr(CAST(date_add(last_day(current_datetime()), interval 1 DAY) as STRING FORMAT 'yyyymmdd'), 1, 6) as INT64);
      IF (SELECT count(1) FROM  `EDW_TRIPS_STAGE.INFORMATION_SCHEMA.TABLES` WHERE table_name= tablename) =0 THEN
        SET isfullload = 1;
      END IF;
      IF isfullload = 1 THEN
        IF trace_flag = 1 THEN
          --selecT concat('Calling: Utility.Get_PartitionDayIDRange_String from ' , SUBSTR(CAST(FirstPartitionID AS string),1,10), ' till ' , SUBSTR(CAST(LastPartitionID AS STRING),1,10));
        END IF;
        --CALL EDW_TRIPS_SUPPORT.get_partitiondayidrange_string(substr(CAST(firstpartitionid as STRING), 1, 10), substr(CAST(lastpartitionid as STRING), 1, 10), partition_ranges);
        -- Will use if go to columnstore - not delete this comment!!!!!  SET @CreateTableWith = '(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + ')))'
        -- SET createtablewith = concat('(CLUSTERED INDEX (', identifyingcolumns, '), DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (', partition_ranges, ')))');
        SET createtablewith = concat(' CLUSTER BY ', identifyingcolumns);
        SET log_message = 'Started Full load';
      ELSE
        SET createtablewith = concat(' CLUSTER BY ', identifyingcolumns);
        IF trace_flag = 1 THEN
          SELECT concat('Calling: Utility.Get_UpdatedDate for ',tablename);
        END IF;
        CALL EDW_TRIPS_SUPPORT.Get_UpdatedDate(tablename, last_updated_date);
         --SET last_updated_date= coalesce(last_updated_date, CURRENT_DATETIME());

        SET log_message = concat('Started Incremental load from: ', substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_updated_date) as STRING), 1, 25));
      END IF;
       IF trace_flag = 1 THEN
        SELECT log_message;
      END IF;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      --=============================================================================================================
      -- Load dbo.Fact_Violation
      --============================================================================================================   
      --SET sql = concat("DROP TABLE IF EXISTS ",stagetablename,";");
      SET sql1 = concat("CREATE OR REPLACE TABLE ",stagetablename , createtablewith, " AS (WITH main_cte AS (SELECT coalesce(CAST(tp.citationid as INT64), -1) AS citationid, coalesce(tp.tptripid, -1) AS tptripid, coalesce(CAST(SUBSTR(CAST(tp.exittripdatetime as STRING FORMAT 'yyyymmdd'),1,8 )as INT64), -1) AS tripdayid, coalesce(CAST(tp.exitlaneid as INT64), -1) AS laneid, coalesce(CAST(tp.violatorid as INT64), -1) AS customerid, coalesce(CAST(tp.custrefid as INT64), -1) AS custrefid, coalesce(CAST(tp.vehicleid as INT64), -1) AS vehicleid, coalesce(CAST(tp.accountagencyid as INT64), -1) AS accountagencyid, coalesce(CAST(tp.tripstatusid as INT64), -1) AS tripstatusid, coalesce(CAST(tp.tripstageid as INT64), -1) AS tripstageid, coalesce(CAST(tp.transactiontypeid as INT64), -1) AS transactiontypeid, coalesce(CAST(tpt.transactionpostingtypeid as INT64), -1) AS transactionpostingtypeid, coalesce(CAST(cs.citationstageid as INT64), -1) AS citationstageid, coalesce(CAST(tp.paymentstatusid as INT64), -1) AS paymentstatusid, coalesce(CAST(CASE   WHEN tp.vehicleclass IN  ('2', '3', '4', '5', '6', '7', '8', '11', '12', '13', '14', '15', '16', '17', '18'   ) THEN tp.vehicleclass   ELSE NULL END as INT64), -1) AS vehicleclassid, coalesce(CAST(tp.sourceofentry as INT64), 0) AS sourceofentry, coalesce(CAST(tp.exittripdatetime as DATETIME), DATETIME '1900-01-01 00:00:00') AS tripdate, coalesce(CAST(tp.tripstatusdate as DATETIME), DATETIME '1900-01-01 00:00:00') AS tripstatusdate, coalesce(CAST(tp.posteddate as DATETIME), DATETIME '1900-01-01 00:00:00') AS posteddate, coalesce(CAST(tp.writeoffdate as DATETIME), DATETIME '1900-01-01 00:00:00') AS writeoffdate, coalesce(CAST(tp.iswriteoff as INT64), 0) AS writeoffflag, coalesce(CASE   WHEN tp.lnd_updatetype = 'D' THEN 1   ELSE 0 END, 0) AS deleteflag, coalesce(CAST(tp.tollamount as NUMERIC), CAST(0 as NUMERIC)) AS tollamount, coalesce(CAST(tp.feeamounts as NUMERIC), CAST(0 as NUMERIC)) AS feeamount, coalesce(CAST(tp.outstandingamount as NUMERIC), CAST(0 as NUMERIC)) AS outstandingamount, coalesce(CAST(tp.netamount as NUMERIC), CAST(0 as NUMERIC)) AS netamount, coalesce(CAST(tp.pbmtollamount as NUMERIC), CAST(0 as NUMERIC)) AS pbmtollamount, coalesce(CAST(tp.avitollamount as NUMERIC), CAST(0 as NUMERIC)) AS avitollamount, coalesce(CAST(tp.writeoffamount as NUMERIC), CAST(0 as NUMERIC)) AS writeoffamount, coalesce(CAST(tp.updateddate as DATETIME), DATETIME '1900-01-01 00:00:00') AS updateddate, coalesce(CAST(tp.lnd_updatedate as DATETIME), DATETIME '1900-01-01 00:00:00') AS lnd_updatedate, current_datetime() AS edw_updatedate,CAST(tp.exittripdatetime as DATETIME) AS transactiondate FROM LND_TBOS.TollPlus_tp_violatedtrips AS tp LEFT OUTER JOIN EDW_TRIPS.dim_transactionpostingtype AS tpt ON tpt.transactionpostingtype = tp.transactionpostingtype LEFT OUTER JOIN EDW_TRIPS.dim_citationstage AS cs ON cs.citationstagecode = tp.citationstage WHERE 1 = 1) SELECT main_cte.citationid, main_cte.tptripid, main_cte.tripdayid, main_cte.laneid, main_cte.customerid, main_cte.custrefid, main_cte.vehicleid, main_cte.accountagencyid, main_cte.tripstatusid, main_cte.tripstageid, main_cte.transactiontypeid, main_cte.transactionpostingtypeid, main_cte.citationstageid, main_cte.paymentstatusid, main_cte.vehicleclassid, main_cte.sourceofentry, main_cte.tripdate, main_cte.tripstatusdate, main_cte.posteddate, main_cte.writeoffdate, main_cte.writeoffflag, coalesce(CASE WHEN row_number() OVER (PARTITION BY main_cte.tptripid ORDER BY main_cte.deleteflag, main_cte.citationid DESC) = 1 THEN 1 ELSE 0 END, 0) AS currenttxnflag, main_cte.deleteflag, main_cte.tollamount, main_cte.feeamount, main_cte.outstandingamount, main_cte.netamount, main_cte.pbmtollamount, main_cte.avitollamount, main_cte.writeoffamount, main_cte.updateddate, main_cte.lnd_updatedate, main_cte.edw_updatedate, main_cte.transactiondate FROM main_cte)");

      IF isfullload <> 1 THEN
            SET sql1  =  replace(sql1 ,"WITH main_cte AS", concat("WITH changedtptripids_cte AS (SELECT tp.citationid,tp.tptripid FROM lnd_tbos.tollplus_tp_violatedtrips AS tp WHERE tp.lnd_updatedate > '",substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_updated_date) as STRING), 1, 25),"'), changedcurrenttxnflags_cte AS ( SELECT tp.citationid FROM ",tablename," AS tp WHERE EXISTS ( SELECT 1 FROM ( SELECT tp.citationid,tp.tptripid FROM lnd_tbos.tollplus_tp_violatedtrips AS tp WHERE tp.lnd_updatedate > '",substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_updated_date) as STRING), 1, 25),"') AS cte WHERE tp.tptripid = cte.tptripid AND tp.citationid <> cte.citationid )AND tp.currenttxnflag = 1), changedcitationids_cte AS (SELECT changedtptripids_cte.citationid FROM changedtptripids_cte UNION ALL SELECT changedcurrenttxnflags_cte.citationid FROM changedcurrenttxnflags_cte ),main_cte AS" ));
            SET sql1 = replace(sql1, 'WHERE 1 = 1',concat("WHERE  EXISTS (SELECT 1 FROM( SELECT tp.citationid, tp.tptripid FROM lnd_tbos.tollplus_tp_violatedtrips AS tp WHERE tp.lnd_updatedate > '",substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_updated_date) as STRING), 1, 25),"') AS cte WHERE tp.citationid = cte.citationid)"));
      END IF;
      --EXECUTE IMMEDIATE sql;
      EXECUTE IMMEDIATE sql1;
      SET log_message = concat('Loaded ', tablename);
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, sql1);

      IF isfullload = 1 THEN
      	-- Table swap!
        -- commented tableswap, implemented logic below using CREATE OR REPLACE
        --CALL EDW_TRIPS_SUPPORT.tableswap(stagetablename, tablename);
        CREATE OR REPLACE TABLE EDW_TRIPS.Fact_Violation AS SELECT * FROM EDW_TRIPS.Fact_Violation_NEW;
        SET log_message = 'Completed full load';
      ELSE
        IF trace_flag = 1 THEN
          --SELECT 'Calling: Utility.ManagePartitions_DateID';
        END IF;
        --CALL EDW_TRIPS_SUPPORT.managepartitions_dateid(tablename, 'DayID:Month');
        IF trace_flag = 1 THEN
          --SELECT'Calling: Utility.PartitionSwitch_Range';
        END IF;
        -- commented PartitionSwitch_range and implemented this logic using DELETE and INSERT STATEMENTS below
        --CALL EDW_TRIPS_SUPPORT.partitionswitch_range(stagetablename, tablename, identifyingcolumns, CAST(NULL as STRING));
        -- Dropping Records From Main Table To Avoid Duplicates
        SET sql2 = concat("Delete From ", tablename , " where citationid In ( Select citationid from ",stagetablename , " )" );
        EXECUTE IMMEDIATE sql2;
        
        -- Inserting NEW Records from Stage to Main Table
        SET sql2 = concat("Insert Into  ", tablename , " Select * from ",stagetablename );
        EXECUTE IMMEDIATE sql2;

        SET log_message = concat('Completed Incremental load from ', substr(CAST(last_updated_date as STRING FORMAT "yyyy-mm-dd hh:mi:ss.mmmm"), 1, 25)); 
      END IF;
      SET last_updated_date = CAST(NULL as DATETIME);
      CALL EDW_TRIPS_SUPPORT.Set_UpdatedDate(tablename, tablename, last_updated_date);
      -- So we going to manually set Updated date to be sure it didnot cach any error before that
      SET log_message = concat(log_message, '. Set Last Update date as ', substr(CAST(last_updated_date as STRING FORMAT "yyyy-mm-dd hh:mi:ss.mmmm"), 1, 25));
      IF trace_flag = 1 THEN
        SELECT log_message;
      END IF;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      EXCEPTION WHEN ERROR THEN
        BEGIN
          DECLARE error_message STRING DEFAULT @@error.message;
          CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
          RAISE USING MESSAGE = error_message; -- Rethrow the error!
        END;
      END;

/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================
EXEC dbo.Fact_Violation_Load

EXEC Utility.FromLog 'dbo.Fact_Violation', 1
SELECT TOP 100 'dbo.Fact_Violation' TableName, * FROM dbo.Fact_Violation ORDER BY 2

--===============================================================================================================
-- !!! USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel !!! 
--===============================================================================================================
--===============================================================================================================
-- !!! Recently removed columns !!! 
--===============================================================================================================
			--, ISNULL(CAST(TP.IsExcessiveVToll AS BIT), 0) AS ExcessiveVTollFlag
			--, ISNULL(CAST(TP.IsImmediateFlag AS BIT), 0) AS ImmediateFlag


			TESTING:

EXEC dbo.Fact_Violation_Load 1

EXEC Utility.FromLog 'dbo.Fact_Violation', 1

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_Violation', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  -- 2021-02-25 16:48:58.935

EXEC Utility.Set_UpdatedDate 'dbo.Fact_Violation', NULL, '2021-02-25 16:30:00'

EXEC dbo.Fact_Violation_Load 0

EXEC Utility.FromLog 'dbo.Fact_Violation', 3

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_Violation', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  -- 2021-02-25 16:48:58.935



*/


END;