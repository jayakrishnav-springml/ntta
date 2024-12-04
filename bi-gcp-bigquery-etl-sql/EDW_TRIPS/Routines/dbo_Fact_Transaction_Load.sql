CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_Transaction_Load`(isfullload INT64)
BEGIN


/*
IF OBJECT_ID ('dbo.Fact_Transaction_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Fact_Transaction_Load
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_Transaction_Load 1

EXEC Utility.FromLog 'dbo.Fact_Transaction', 1
SELECT top 100 * FROM LND_TBOS.TranProcessing.NttaRawTransactions
SELECT top 100 
	TPTripID, TripDayID, LaneID, VehicleID, TagAgencyID, VehicleClassID, TagVehicleClassID, PaymentStatusID, TripStageID, TripStatusID, TripIdentMethodID, 
	TransactionPostingTypeID, ReasonCodeID, SourceTripID, LinkID, IPSTransactionID, SourceOfEntry, RecordType, RecordNumber, VehicleSpeed, Disposition, TripWith, 
	TripDate, TripStatusDate, PostedDate, NonRevenueFlag, DeleteFlag, TollAmount, FeeAmount, ReceivedTollAmount, OutStandingAmount, PBMTollAmount, AVITollAmount, 
	UpdatedDate, LND_UpdateDate, EDW_UpdateDate
FROM dbo.Fact_Transaction
SELECT top 100 * FROM LND_TBOS.TOLLPLUS.TP_TRIPS

SELECT count_BIG(*) CNT, 'LND_TBOS.TOLLPLUS.TP_TRIPS' AS TableName FROM LND_TBOS.TOLLPLUS.TP_TRIPS -- 
																							 17,791,763
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_Transaction table. 

@IsFullLoad - 1 means forced Full load, 0 or NULL - incremental load. I the main table is not exists - it goes with full load.

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0038319 	Andy		2021-03-08	New!
CHG0038458	Andy		03/30/2021	Save Last Update date in LoadProcessControl after successful run. Added TRY/CATCH
CHG0038754	Shankar		04/27/2021	Fixed duplicates caused by join to Dim_Vehicle table
###################################################################################################################
*/


    /*====================================== TESTING =======================================================================*/
    --DECLARE @IsFullLoad BIT = 1 
    /*====================================== TESTING =======================================================================*/

    DECLARE tablename STRING DEFAULT 'EDW_TRIPS.Fact_Transaction';
		DECLARE trace_flag INT64 DEFAULT 1; ## Testing
    DECLARE firstpartitionid INT64 DEFAULT 201701;
    DECLARE lastpartitionid INT64;
    DECLARE partition_ranges STRING;
    DECLARE createtablewith STRING;
    DECLARE log_message STRING;
    DECLARE identifyingcolumns STRING DEFAULT 'TPTripID';
    DECLARE last_updated_date DATETIME;
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_Transaction_Load';
    DECLARE log_start_date DATETIME;
    DECLARE stagetablename STRING DEFAULT 'EDW_TRIPS.Fact_Transaction_NEW';
    DECLARE sql STRING;
    BEGIN
      DECLARE lastdatetoload STRING;
      SET log_start_date = current_datetime('America/Chicago');
      SET lastdatetoload = substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',date_add(last_day(current_datetime()), interval 1 DAY)) AS STRING),1,10);
      SET lastpartitionid = CAST(substr(CAST(FORMAT_DATETIME('%Y%m%d', date_add(last_day(date_add(current_datetime(),interval 1 MONTH)), interval 1 DAY)) AS STRING),1, 6)AS INT64);
      IF (SELECT count(1) FROM EDW_TRIPS.INFORMATION_SCHEMA.TABLES WHERE LOWER(table_name)=lower(SUBSTR(tablename,STRPOS(tablename,'.')+1))) =0 THEN  
        SET isfullload = 1;
      END IF;
      IF isfullload = 1 THEN
        IF trace_flag = 1 THEN
          --select  'Calling: Utility.Get_PartitionDayIDRange_String from ' || CAST(firstpartitionid AS STRING) ||' till ' || CAST(lastpartitionid AS STRING);
        END IF;
        
        --CALL EDW_TRIPS_SUPPORT.Get_PartitionDayIDRange_String(substr(CAST(firstpartitionid as STRING), 1, 10),substr(cast(lastpartitionid as STRING), 1, 10), partition_ranges);
        --SET createtablewith = concat('(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (', partition_ranges, ')))');
		
        SET log_message = 'Started Full load';
      ELSE
        --SET createtablewith = concat('(CLUSTERED INDEX (', identifyingcolumns, '), DISTRIBUTION = HASH(TPTripID))');
        IF trace_flag = 1 THEN
          select 'Calling: Utility.Get_UpdatedDate for ' || tablename;
        END IF;
        CALL EDW_TRIPS_SUPPORT.Get_UpdatedDate(tablename, last_updated_date);
        --SET last_updated_date= coalesce(last_updated_date, CURRENT_DATETIME());
        SET log_message = concat('Started Incremental load from: ', substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_updated_date) AS STRING),1,25));
      END IF;
      IF trace_flag = 1 THEN
        select log_message;
      END IF;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));

      --=============================================================================================================
      -- Load dbo.Fact_Transaction
      --============================================================================================================

      --set sql="DROP TABLE IF EXISTS "||stagetablename||""; 
      --EXECUTE IMMEDIATE sql;
      set sql="""
              CREATE OR REPLACE TABLE """||stagetablename||""" CLUSTER BY """||identifyingcolumns||"""
              AS     
                WITH main_cte AS 
                  (  
                    SELECT  coalesce(tp.tptripid, -1) AS tptripid,    
                            COALESCE(CAST(SUBSTR(CAST(tp.exittripdatetime AS STRING FORMAT 'yyyymmdd' ), 1, 8) AS INT64), -1) AS tripdayid,    
                            coalesce(CAST( tp.exitlaneid as INT64), -1) AS laneid,    
                            coalesce(CAST( tp.tripstageid as INT64), -1) AS tripstageid,    
                            coalesce(CAST( tp.tripstatusid as INT64), -1) AS tripstatusid,    
                            coalesce(CAST( tp.paymentstatusid as INT64), -1) AS paymentstatusid,    
                            coalesce(CAST( coalesce(att.sourcetripid, tp.sourcetripid) as INT64), -1) AS sourcetripid,    
                            coalesce(CAST( tp.linkid as INT64), -1) AS linkid,    
                            coalesce(CAST( coalesce(tp.vehicleid, v.vehicleid) as INT64), -1) AS vehicleid,    
                            coalesce(CAST( tp.tagagencyid as INT64), -1) AS tagagencyid ,    
                            coalesce(CAST( pt.transactionpostingtypeid as INT64), -1) AS transactionpostingtypeid,    
                            coalesce(CAST(nullif(tp.ipstransactionid, 0) AS INT64), -1) AS ipstransactionid,    
                            coalesce(CAST( rc.reasoncodeid as INT64), -1) AS reasoncodeid,    
                            coalesce(CAST(CASE WHEN tp.vehicleclass IN(   '2', '3', '4', '5', '6', '7', '8', '11', '12', '13', '14', '15', '16', '17', '18' ) THEN tp.vehicleclass ELSE NULL    END as INT64), -1) AS vehicleclassid,    
                            coalesce(CAST(CASE WHEN tp.tagvehicleclass IN(   '2', '3', '4', '5', '6', '7', '8', '11', '12', '13', '14', '15', '16', '17', '18' ) THEN tp.tagvehicleclass ELSE NULL    END as INT64), -1) AS tagvehicleclassid,    
                            coalesce(CAST( ti.tripidentmethodid as INT64), -1) AS tripidentmethodid,    
                            coalesce(CAST( tp.sourceofentry as INT64), 0) AS sourceofentry,    
                            coalesce(CAST( coalesce(rt.recordtype, traw.recordtype) as STRING), '') AS recordtype,    
                            coalesce(CAST( coalesce(rt.recordnumber, traw.subscriberuniquetransactionid) as INT64), 0) AS recordnumber,    
                            coalesce(CAST( coalesce(rt.vehiclespeed, traw.speed) as INT64), 0) AS vehiclespeed,    
                            coalesce(CAST( tp.disposition as STRING), '-1') AS disposition,    
                            coalesce(CAST( tp.tripwith as STRING), '-1') AS tripwith,    
                            coalesce(CAST( tp.exittripdatetime as DATETIME), DATETIME '1900-01-01 00:00:00') AS tripdate,    
                            coalesce(CAST( tp.tripstatusdate as DATE), DATE '1900-01-01') AS tripstatusdate,    
                            coalesce(CAST( tp.posteddate as DATE), DATE '1900-01-01') AS posteddate,    
                            coalesce(CAST( tp.isnonrevenue as INT64), 0) AS nonrevenueflag,    
                            coalesce(CASE WHEN tp.lnd_updatetype = 'D' THEN 1 ELSE 0    END, 0) AS deleteflag,    
                            coalesce(CAST( tp.tollamount as NUMERIC), CAST(0 as NUMERIC)) AS tollamount,    
                            coalesce(CAST( tp.feeamounts as NUMERIC), CAST(0 as NUMERIC)) AS feeamount,    
                            coalesce(CAST( tp.receivedtollamount as NUMERIC), CAST(0 as NUMERIC)) AS receivedtollamount,    
                            coalesce(CAST( tp.outstandingamount as NUMERIC), CAST(0 as NUMERIC)) AS outstandingamount,    
                            coalesce(CAST( tp.pbmtollamount as NUMERIC), CAST(0 as NUMERIC)) AS pbmtollamount,    
                            coalesce(CAST( tp.avitollamount as NUMERIC), CAST(0 as NUMERIC)) AS avitollamount,    
                            coalesce(CAST( tp.updateddate as DATETIME), DATETIME '1900-01-01 00:00:00') AS updateddate,    
                            coalesce(CAST( tp.lnd_updatedate as DATETIME), DATETIME '1900-01-01 00:00:00') AS lnd_updatedate,    
                            coalesce(cast(substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',\'"""||log_start_date||"""\') as STRING), 1, 25) as DATETIME),DATETIME '1900-01-01 00:00:00') AS edw_updatedate,    
                            row_number() OVER (PARTITION BY tp.tptripid ORDER BY v.vehiclestartdate DESC) AS rn  
                            FROM    LND_TBOS.TOLLPLUS_TP_TRIPS AS tp    
                                    LEFT OUTER JOIN LND_TBOS.TranProcessing_NttaRawTransactions AS rt 
                                      ON tp.sourcetripid = rt.txnid     AND tp.sourceofentry = 1    
                                    LEFT OUTER JOIN LND_TBOS.tsa_TSATripAttributes AS att 
                                      ON tp.sourcetripid = att.ttptripid     AND tp.sourceofentry = 3    
                                    LEFT OUTER JOIN LND_TBOS.TranProcessing_TSARawTransactions AS traw 
                                      ON att.sourcetripid = traw.txnid    
                                    LEFT OUTER JOIN EDW_TRIPS.Dim_TransactionPostingType AS pt 
                                      ON pt.transactionpostingtype = tp.transactionpostingtype    
                                    LEFT OUTER JOIN EDW_TRIPS.Dim_TripIdentMethod AS ti 
                                      ON ti.tripidentmethod = tp.tripidentmethod    
                                    LEFT OUTER JOIN EDW_TRIPS.Dim_ReasonCode AS rc 
                                      ON rc.reasoncode = rtrim(ltrim(tp.reasoncode))    
                                    LEFT OUTER JOIN EDW_TRIPS.Dim_Vehicle AS v 
                                      ON trim(v.licenseplatenumber) = trim(tp.vehiclenumber)  
                                        AND trim(v.licenseplatestate) = trim(tp.vehiclestate )    
                                          AND tp.exittripdatetime BETWEEN v.vehiclestartdate 
                                            AND v.vehicleenddate  WHERE 1 = 1   
                                              AND tp.exittripdatetime < \'"""||lastdatetoload||"""\'     )     
                                    
                                    SELECT  main_cte.tptripid,  
                                            main_cte.tripdayid,  
                                            main_cte.laneid,  
                                            main_cte.tripstageid,  
                                            main_cte.tripstatusid,  
                                            main_cte.paymentstatusid,  
                                            main_cte.sourcetripid,  
                                            main_cte.linkid,  
                                            main_cte.vehicleid,  
                                            main_cte.tagagencyid,  
                                            main_cte.transactionpostingtypeid,  
                                            main_cte.ipstransactionid,  
                                            main_cte.reasoncodeid,  
                                            main_cte.vehicleclassid,  
                                            main_cte.tagvehicleclassid,  
                                            main_cte.tripidentmethodid,  
                                            main_cte.sourceofentry,  
                                            main_cte.recordtype,  
                                            main_cte.recordnumber,  
                                            main_cte.vehiclespeed,  
                                            main_cte.disposition,  
                                            main_cte.tripwith,  
                                            main_cte.tripdate,  
                                            main_cte.tripstatusdate,  
                                            main_cte.posteddate,  
                                            main_cte.nonrevenueflag,  
                                            main_cte.deleteflag,  
                                            main_cte.tollamount,  
                                            main_cte.feeamount,  
                                            main_cte.receivedtollamount,  
                                            main_cte.outstandingamount,  
                                            main_cte.pbmtollamount,  
                                            main_cte.avitollamount, 
                                            main_cte.updateddate,  
                                            main_cte.lnd_updatedate,  
                                            main_cte.edw_updatedate  
                                              FROM  main_cte  WHERE main_cte.rn = 1 """;

      IF isfullload <> 1 THEN
        SET sql = replace(sql, 'WHERE 1 = 1', "WHERE tp.lnd_updatedate> \'"||substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_updated_date) AS STRING),1,25)||"\'");
      END IF;

      EXECUTE IMMEDIATE sql;
      --Log
      SET log_message = concat('Loaded ', tablename);
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, sql);
      IF isfullload = 1 THEN
        -- EXECUTE IMMEDIATE sql;
        -- Table swap!
        --TableSwap is Not Required, using  Create or Replace Table below
        --CALL EDW_TRIPS_SUPPORT.TableSwap(stagetablename, tablename);
        CREATE OR REPLACE TABLE EDW_TRIPS.Fact_Transaction AS  SELECT * FROM EDW_TRIPS.Fact_Transaction_NEW;   

        SET log_message = 'Completed full load';
      ELSE
        IF trace_flag = 1 THEN
          --select 'Calling: Utility.ManagePartitions_DateID';
        END IF;
        --CALL EDW_TRIPS_SUPPORT.ManagePartitions_DateID(tablename, 'DayID:Month');
        IF trace_flag = 1 THEN
          --select 'Calling: Utility.PartitionSwitch_Range';
        END IF;
        --Commented PartitionSwitch_Range, implimented logic below
        -- CALL EDW_TRIPS_SUPPORT.PartitionSwitch_Range(stagetablename, tablename, identifyingcolumns, CAST(NULL as STRING));
        -- Logic for PartitionSwitch_Range
        -- Dropping Records From Main Table To Avoid Duplicates
      SET sql = concat("Delete From ", tablename , " where ", identifyingcolumns ," In ( Select ", identifyingcolumns , " from ",stagetablename , " )" );
      EXECUTE IMMEDIATE sql;
    
      -- Inserting NEW Records from Stage to Main Table
      SET sql = concat("Insert Into  ", tablename , " Select * from ",stagetablename );
      EXECUTE IMMEDIATE sql;
      SET log_message = concat('Completed Incremental load from ', substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_updated_date) AS STRING),1,25));
      END IF;
      SET last_updated_date = CAST(NULL as DATETIME);
      CALL EDW_TRIPS_SUPPORT.Set_UpdatedDate(tablename, tablename, last_updated_date); -- So we going to manually set Updated date to be sure it didnt cach any error before that
      SET log_message = concat(log_message, '. Set Last Update date as ', substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',last_updated_date) AS STRING),1,25));
      IF trace_flag = 1 THEN
        select log_message;
      END IF;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
			EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = error_message;  -- Rethrow the error!
      END;
    END;
       
/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================
EXEC dbo.Fact_Transaction_Load

EXEC Utility.FromLog 'dbo.Fact_Transaction', 1
SELECT TOP 100 'dbo.Fact_Transaction' TableName, * FROM dbo.Fact_Transaction ORDER BY 2

--===============================================================================================================
-- !!! Dynamic SQL!!!
--===============================================================================================================

IF OBJECT_ID('dbo.Fact_Transaction_NEW','U') IS NOT NULL			DROP TABLE dbo.Fact_Transaction_NEW;

CREATE TABLE dbo.Fact_Transaction_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (20170101,20170201,20170301,20170401,20170501,20170601,20170701,20170801,20170901,20171001,20171101,20171201,20180101,20180201,20180301,20180401,20180501,20180601,20180701,20180801,20180901,20181001,20181101,20181201,20190101,20190201,20190301,20190401,20190501,20190601,20190701,20190801,20190901,20191001,20191101,20191201,20200101,20200201,20200301,20200401,20200501,20200601,20200701,20200801,20200901,20201001,20201101,20201201,20210101,20210201,20210301,20210401,20210501,20210601))) AS
WITH Main_CTE AS
(
SELECT
	ISNULL(TP.TPTripID, -1) AS TPTripID
	, ISNULL(CAST(CONVERT(VARCHAR(8), TP.ExitTripDateTime, 112) AS INT), -1) AS TripDayID
	, ISNULL(CAST(TP.ExitLaneID AS INT), -1) AS LaneID
	, ISNULL(CAST(TP.TripStageID AS INT), -1) AS TripStageID
	, ISNULL(CAST(TP.TripStatusID AS INT), -1) AS TripStatusID
	, ISNULL(CAST(TP.PaymentStatusID AS BIGINT), -1) AS PaymentStatusID
	, ISNULL(CAST(ISNULL(att.SourceTripId, TP.SourceTripID) AS BIGINT), -1) AS SourceTripID
	, ISNULL(CAST(TP.LinkID AS BIGINT), -1) AS LinkID
	, ISNULL(CAST(COALESCE(TP.VehicleID, V.VehicleID) AS BIGINT), -1) AS VehicleID 
	, ISNULL(CAST(TP.TagAgencyID AS INT), -1) AS TagAgencyID			-- Not always could be found in VehicleTagID - sometimes TagAgencyID > -1 and VehicleTagID = -1
	, ISNULL(CAST(PT.TransactionPostingTypeID AS INT), -1) AS TransactionPostingTypeID
	, ISNULL(CAST(NULLIF(TP.IPSTransactionID,0) AS BIGINT), -1) AS IPSTransactionID
	, ISNULL(CAST(RC.ReasonCodeID AS INT), -1) AS ReasonCodeID
	, ISNULL(CAST(CASE WHEN TP.VehicleClass IN ('2','3','4','5','6','7','8','11','12','13','14','15','16','17','18') THEN TP.VehicleClass ELSE NULL END AS SMALLINT),-1) AS VehicleClassID
	, ISNULL(CAST(CASE WHEN TP.TagVehicleClass IN ('2','3','4','5','6','7','8','11','12','13','14','15','16','17','18') THEN TP.TagVehicleClass ELSE NULL END AS SMALLINT),-1) AS TagVehicleClassID
	, ISNULL(CAST(TI.TripIdentMethodID AS SMALLINT),-1) AS TripIdentMethodID
	, ISNULL(CAST(TP.SourceOfEntry AS TINYINT), 0) AS SourceOfEntry
	, ISNULL(CAST(COALESCE(RT.RecordType,TRaw.RecordType) AS VARCHAR(4)),'') AS RecordType
	, ISNULL(CAST(COALESCE(RT.RecordNumber,TRaw.SubscriberUniqueTransactionID) AS BIGINT), 0) AS RecordNumber
	, ISNULL(CAST(COALESCE(RT.VehicleSpeed,TRaw.Speed) AS INT), 0) AS VehicleSpeed
	, ISNULL(CAST(TP.Disposition AS VARCHAR(2)),'-1') AS Disposition
	, ISNULL(CAST(TP.TripWith AS VARCHAR(2)),'-1') AS TripWith
	, ISNULL(CAST(TP.ExitTripDateTime AS DATETIME2(3)), '1900-01-01') AS TripDate
	, ISNULL(CAST(TP.TripStatusDate AS DATE), '1900-01-01') AS TripStatusDate
	, ISNULL(CAST(TP.PostedDate AS DATE), '1900-01-01') AS PostedDate
	, ISNULL(CAST(TP.IsNonRevenue AS BIT), 0) AS NonRevenueFlag
	, ISNULL(CAST(CASE WHEN TP.LND_UpdateType = 'D' THEN 1 ELSE 0 END AS BIT), 0) AS DeleteFlag
	, ISNULL(CAST(TP.TollAmount AS DECIMAL(9,2)), 0) AS TollAmount
	, ISNULL(CAST(TP.FeeAmounts AS DECIMAL(9,2)), 0) AS FeeAmount
	, ISNULL(CAST(TP.ReceivedTollAmount AS DECIMAL(9,2)), 0) AS ReceivedTollAmount
	, ISNULL(CAST(TP.OutStandingAmount AS DECIMAL(9,2)), 0) AS OutStandingAmount
	, ISNULL(CAST(TP.PBMTollAmount AS DECIMAL(9,2)), 0) AS PBMTollAmount
	, ISNULL(CAST(TP.AVITollAmount AS DECIMAL(9,2)), 0) AS AVITollAmount
	, ISNULL(CAST(TP.UpdatedDate AS DATETIME2(3)), '1900-01-01') AS UpdatedDate
	, ISNULL(CAST(TP.LND_UpdateDate AS datetime2(3)), '1900-01-01') AS LND_UpdateDate
	, ISNULL(CAST('2021-04-27 16:34:39.990' AS datetime2(3)), '1900-01-01') AS EDW_UpdateDate
	, ROW_NUMBER() OVER (PARTITION BY TP.TpTripID ORDER BY V.VehicleStartDate DESC) RN
FROM LND_TBOS.TOLLPLUS.TP_TRIPS TP
LEFT JOIN LND_TBOS.TranProcessing.NttaRawTransactions RT ON TP.SourceTripID = RT.TxnID AND tp.SourceOfEntry = 1
LEFT JOIN LND_TBOS.tsa.TSATripAttributes att ON tp.SourceTripID = att.TTpTripID AND tp.SourceOfEntry = 3
LEFT JOIN LND_TBOS.TranProcessing.TSARawTransactions TRaw ON att.SourceTripId = TRaw.TxnID
LEFT JOIN dbo.Dim_TransactionPostingType PT ON PT.TransactionPostingType = TP.TransactionPostingType
LEFT JOIN dbo.Dim_TripIdentMethod TI ON TI.TripIdentMethod = TP.TripIdentMethod
LEFT JOIN dbo.Dim_ReasonCode RC ON RC.ReasonCode = RTRIM(LTRIM(TP.ReasonCode))
LEFT JOIN dbo.Dim_Vehicle V ON V.LicensePlateNumber = TP.VehicleNumber AND V.LicensePlateState = TP.VehicleState AND TP.ExitTripDateTime BETWEEN V.VehicleStartDate AND V.VehicleEndDate
WHERE 1 = 1 AND TP.ExitTripDateTime < '2021-05-01'
)
SELECT
		TPTripID
	, TripDayID
	, LaneID
	, TripStageID
	, TripStatusID
	, PaymentStatusID
	, SourceTripID
	, LinkID
	, VehicleID
	, TagAgencyID
	, TransactionPostingTypeID
	, IPSTransactionID
	, ReasonCodeID
	, VehicleClassID
	, TagVehicleClassID
	, TripIdentMethodID
	, SourceOfEntry
	, RecordType
	, RecordNumber
	, VehicleSpeed
	, Disposition
	, TripWith
	, TripDate
	, TripStatusDate
	, PostedDate
	, NonRevenueFlag
	, DeleteFlag
	, TollAmount
	, FeeAmount
	, ReceivedTollAmount
	, OutStandingAmount
	, PBMTollAmount
	, AVITollAmount
	, UpdatedDate
	, LND_UpdateDate
	, EDW_UpdateDate
FROM Main_CTE
WHERE RN = 1
OPTION (LABEL = 'dbo.Fact_Transaction_NEW');


--===============================================================================================================
-- !!! USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel !!! 
--===============================================================================================================

SELECT TripDayID/100 AS MONTHID , COUNT_BIG(1) FROM dbo.Fact_Transaction				-- 1480156608
GROUP BY TripDayID/100
ORDER BY MONTHID

SELECT Disposition , COUNT_BIG(1) FROM dbo.Fact_Transaction				-- 1480156608
GROUP BY Disposition
ORDER BY Disposition


SELECT TOP 10 *
FROM LND_TBOS.TOLLPLUS.TP_TRIPS tp WITH (NOLOCK)
INNER JOIN LND_TBOS.tsa.TSATripAttributes att WITH (NOLOCK)
		ON tp.SOURCETRIPID = att.TTpTripID
INNER JOIN LND_TBOS.TranProcessing.TSARawTransactions TRaw WITH (NOLOCK)
		ON att.SourceTripId = TRaw.TxnID
WHERE tp.SourceOfEntry = 3

IF OBJECT_ID('dbo.Dim_TripIdentMethod') IS NOT NULL DROP TABLE dbo.Dim_TripIdentMethod;
CREATE TABLE dbo.Dim_TripIdentMethod WITH (HEAP, DISTRIBUTION = REPLICATE) AS
SELECT * FROM (
SELECT CAST(1 AS SMALLINT) AS TripIdentMethodID, 'AVI' AS TripIdentMethodCode, 'AviToll' AS TripIdentMethod UNION ALL
SELECT CAST(2 AS SMALLINT) AS TripIdentMethodID, 'VToll' AS TripIdentMethodCode, 'VideoToll' AS TripIdentMethod UNION ALL
SELECT CAST(-1 AS SMALLINT) AS TripIdentMethodID, 'Null' AS TripIdentMethodCode, 'Unknown' AS TripIdentMethod) A
 
Testing:

EXEC dbo.Fact_Transaction_Load 1

EXEC Utility.FromLog 'dbo.Fact_Transaction', 1

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_Transaction', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  -- 2021-02-25 16:52:43.985

SELECT  LND_UpdateDate, COUNT_BIG(1) Cnt
FROM dbo.Fact_Transaction
GROUP BY LND_UpdateDate
ORDER BY LND_UpdateDate DESC

EXEC Utility.Set_UpdatedDate 'dbo.Fact_Transaction', NULL, '2021-02-25 16:00:00'

-- 2021-02-25 16:00:00.000
EXEC dbo.Fact_Transaction_Load 0

EXEC Utility.FromLog 'dbo.Fact_Transaction', 1

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_Transaction', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  -- 2021-02-25 16:52:43.985

*/

  END;