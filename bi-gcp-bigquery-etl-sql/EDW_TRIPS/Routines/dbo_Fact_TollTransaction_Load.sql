CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_TollTransaction_Load`(isfullload INT64)
BEGIN


/*
IF OBJECT_ID ('dbo.Fact_TollTransaction_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Fact_TollTransaction_Load
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_TollTransaction_Load 0

EXEC Utility.FromLog 'dbo.Fact_TollTransaction', 3

SELECT TOP 100 * FROM dbo.Fact_TollTransaction 
SELECT COUNT_BIG(1) FROM dbo.Fact_TollTransaction				-- 1480156608
SELECT COUNT_BIG(1) FROM LND_TBOS.TollPlus.TP_CustomerTrips	-- 1479637789
SELECT COUNT_BIG(1) FROM LND_TBOS.Stage.TP_CustomerTrips	-- 1479637789
																						
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_TollTransaction table. 

@IsFullLoad - 1 means forced Full load, 0 or NULL - incremental load. I the main table is not exists - it goes with full load.

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Bhanu	2020-01-04	New!
			Arun Krishna 2021-01-22 
			1. Added APPROVEDSTATUSID = 466 as Per MSTR Team Request, which will give only Approved Adjustments.

CHG0038040  Arun Krishna 2021-01-27 -- Added Delete Flag and removed Current Txn Flag
CHG0038319 	Andy		2021-03-08	--	Chagned to Full&Incremental load, removed dups by Tags, refactoried columns
CHG0038458	Andy		03/30/2021	Save Last Update date in LoadProcessControl after successful run.  fixed CurrentTxnFlag. Added TRY/CATCH
###################################################################################################################
*/

	/*====================================== TESTING =======================================================================*/
	--DECLARE @IsFullLoad BIT = 1 
	/*====================================== TESTING =======================================================================*/

    DECLARE tablename STRING DEFAULT 'EDW_TRIPS.Fact_TollTransaction';
    DECLARE trace_flag INT64 DEFAULT 0;  -- Testing
    DECLARE firstpartitionid INT64 DEFAULT 201901;
    DECLARE lastpartitionid INT64;
    DECLARE partition_ranges STRING;
    DECLARE createtablewith STRING DEFAULT '';
    DECLARE log_message STRING;
    DECLARE identifyingcolumns STRING DEFAULT 'CustTripID';
    DECLARE last_updated_date DATETIME;
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_TollTransaction_Load';
    DECLARE log_start_date DATETIME;
    DECLARE stagetablename STRING DEFAULT 'EDW_TRIPS.Fact_TollTransaction_NEW';
    DECLARE sql STRING;
    declare sql1 string;
    BEGIN
      DECLARE lastdatetoload STRING;
      SET log_start_date = current_datetime('America/Chicago');
      
      SET lastdatetoload = substr(CAST(date_add(last_day(current_datetime()), interval 1 DAY) as STRING FORMAT 'yyyy-MM-dd'), 1, 10);
      SET lastpartitionid = CAST(substr(CAST(date_add(last_day(current_datetime()), interval 1 DAY) as STRING Format "yyyymmdd"), 1, 6) as INT64);
      IF (SELECT count(1) FROM  `EDW_TRIPS.INFORMATION_SCHEMA.TABLES` WHERE LOWER(table_name)=lower(SUBSTR(tablename,STRPOS(tablename,'.')+1))) =0 THEN        SET isfullload = 1;
      END IF;
      IF isfullload = 1 THEN
        --CALL utility.get_partitiondayidrange_string(substr(CAST(firstpartitionid as STRING), 1, 10), substr(CAST(lastpartitionid as STRING), 1, 10), partition_ranges);
        --SET createtablewith = concat('(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (', partition_ranges, ')))');
        SET log_message = 'Started Full load';
      ELSE
        --SET createtablewith = concat('(CLUSTERED INDEX (', identifyingcolumns, '), DISTRIBUTION = HASH(TPTripID))');
        --SET createtablewith = concat(' CLUSTER BY  ', identifyingcolumns);
        IF trace_flag = 1 THEN
          -- BigQuery does not support any equivalent for PRINT or LOG.
          SELECT concat('EDW_TRIPS_SUPPORT: Utility.Get_UpdatedDate for ',tablename);
        END IF;
        CALL EDW_TRIPS_SUPPORT.Get_UpdatedDate(tablename, last_updated_date);
        SET log_message = concat('Started Incremental load from: ', substr(CAST(last_updated_date as STRING FORMAT 'yyyy-mm-dd hh:mi:ss.mmmm'), 1, 25));
      END IF;
      -- Moving Out of IF Else Since it will be same for Both Full and Incremental Load
      SET createtablewith = concat(' CLUSTER BY  ', identifyingcolumns);
      IF trace_flag = 1 THEN
        -- BigQuery does not support any equivalent for PRINT or LOG.
        select log_message;
      END IF;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      --=============================================================================================================
      -- Load dbo.Fact_TollTransaction
      --============================================================================================================

      set sql = """CREATE OR REPLACE TABLE
                """||stagetablename||""" """||createtablewith||""" AS
              WITH
                main_cte AS (
                SELECT
                  COALESCE(CAST( tp.custtripid AS INT64), -1) AS custtripid,
                  COALESCE(tp.tptripid, -1) AS tptripid,
                  COALESCE(CAST(CAST( tp.exittripdatetime AS STRING FORMAT 'YYYYMMDD') AS INT64), -1) AS tripdayid,
                  COALESCE(CAST( tp.exitlaneid AS INT64), -1) AS laneid,
                  COALESCE(CAST( tp.paymentstatusid AS INT64), -1) AS paymentstatusid,
                  COALESCE(CAST( tp.tripstageid AS INT64), -1) AS tripstageid,
                  COALESCE(CAST( tp.tripstatusid AS INT64), -1) AS tripstatusid,
                  COALESCE(CAST( tp.customerid AS INT64), -1) AS customerid,
                  COALESCE(CAST( COALESCE(dct.custtagid, ct.custtagid) AS INT64), -1) AS custtagid,
                  COALESCE(CAST( dct.vehicletagid AS INT64), -1) AS vehicletagid,
                  COALESCE(CAST( COALESCE(tp.vehicleid, dct.vehicleid, v.vehicleid) AS INT64), -1) AS vehicleid,
                  COALESCE(CAST( tpt.transactionpostingtypeid AS INT64), -1) AS transactionpostingtypeid,
                  COALESCE(CAST(CASE
                        WHEN tp.vehicleclass IN( '2', '3', '4', '5', '6', '7', '8', '11', '12', '13', '14', '15', '16', '17', '18' ) THEN tp.vehicleclass
                      ELSE
                      NULL
                    END
                      AS INT64), -1) AS vehicleclassid,
                  COALESCE(CAST( ti.tripidentmethodid AS INT64), -1) AS tripidentmethodid,
                  COALESCE(CAST( tp.sourceofentry AS INT64), 0) AS sourceofentry,
                  COALESCE(CAST( tp.exittripdatetime AS DATETIME), DATETIME '1900-01-01 00:00:00') AS tripdate,
                  COALESCE(CAST( tp.posteddate AS DATETIME), DATETIME '1900-01-01 00:00:00') AS posteddate,
                  COALESCE(CAST( tp.tripstatusdate AS DATETIME), DATETIME '1900-01-01 00:00:00') AS tripstatusdate,
                  COALESCE(adj.adjustmentdate, DATETIME '1900-01-01 00:00:00') AS adjusteddate,
                  COALESCE(CASE
                      WHEN tp.lnd_updatetype = 'D' THEN 1
                    ELSE
                    0
                  END
                    , 0) AS deleteflag,
                  COALESCE(CAST( tp.tollamount AS NUMERIC), CAST(0 AS NUMERIC)) AS tollamount,
                  COALESCE(CAST( tp.feeamounts AS NUMERIC), CAST(0 AS NUMERIC)) AS feeamount,
                  COALESCE(CAST( tp.discountsamount AS NUMERIC), CAST(0 AS NUMERIC)) AS discountamount,
                  COALESCE(CAST( tp.netamount AS NUMERIC), CAST(0 AS NUMERIC)) AS netamount,
                  COALESCE(CAST( tp.rewards_discountamount AS NUMERIC), CAST(0 AS NUMERIC)) AS rewarddiscountamount,
                  COALESCE(CAST( tp.outstandingamount AS NUMERIC), CAST(0 AS NUMERIC)) AS outstandingamount,
                  COALESCE(CAST( tp.pbmtollamount AS NUMERIC), CAST(0 AS NUMERIC)) AS pbmtollamount,
                  COALESCE(CAST( tp.avitollamount AS NUMERIC), CAST(0 AS NUMERIC)) AS avitollamount,
                  COALESCE(CAST(adj.adjustedtolls AS NUMERIC), CAST(0 AS NUMERIC)) AS adjustedtollamount,
                  COALESCE(CAST( tp.updateddate AS DATETIME), DATETIME '1900-01-01 00:00:00') AS updateddate,
                  COALESCE(CAST( tp.lnd_updatedate AS DATETIME), DATETIME '1900-01-01 00:00:00') AS lnd_updatedate,
                  COALESCE('"""||SUBSTR(CAST(log_start_date AS STRING FORMAT "yyyy-mm-dd hh:mi:ss.mmmm"),1,25)||"""', DATETIME '1900-01-01 00:00:00') AS edw_updatedate,
                  COALESCE(CAST( tp.exittripdatetime AS DATETIME), DATETIME '1900-01-01 00:00:00') AS txndatetime,
                  COALESCE(CAST( tp.feeamounts AS NUMERIC), CAST(0 AS NUMERIC)) AS feeamounts,
                  COALESCE(CAST(adj.adjustedtolls AS NUMERIC), CAST(0 AS NUMERIC)) AS adjustedtolls,
                  CAST( tp.tripidentmethod AS STRING) AS tripidentmethod,
                  CAST( tp.rewards_discountamount AS NUMERIC) AS rewardsdiscountamount,
                  COALESCE(CAST( tp.discountsamount AS NUMERIC), CAST(0 AS NUMERIC)) AS discountsamount,
                  ROW_NUMBER() OVER (PARTITION BY tp.custtripid ORDER BY CASE WHEN dct.vehicleid = tp.vehicleid THEN 1 ELSE 2 END , dct.tagstatusorder, dct.tagstartdate DESC, ct.tagstatusstartdate DESC) AS rn FROM LND_TBOS.tollplus_tp_customertrips AS tp LEFT OUTER JOIN EDW_TRIPS.dim_transactionpostingtype AS tpt ON tpt.transactionpostingtype = tp.transactionpostingtype LEFT OUTER JOIN EDW_TRIPS.dim_tripidentmethod AS ti ON ti.tripidentmethod = tp.tripidentmethod LEFT OUTER JOIN EDW_TRIPS.dim_vehicle AS v ON v.licenseplatenumber = tp.vehiclenumber AND v.licenseplatestate = tp.vehiclestate AND tp.exittripdatetime BETWEEN v.vehiclestartdate AND v.vehicleenddate LEFT OUTER JOIN EDW_TRIPS.dim_customertag AS ct ON ct.tagid = tp.tagrefid AND ct.tagagency = tp.tagagency AND ct.customerid = tp.customerid LEFT OUTER JOIN ( SELECT dim_vehicletag.customerid, dim_vehicletag.custtagid, dim_vehicletag.vehicletagid, dim_vehicletag.tagid, dim_vehicletag.tagagency, dim_vehicletag.vehicleid, dim_vehicletag.tagstartdate, dim_vehicletag.tagenddate, CASE
                      WHEN dim_vehicletag.tagstatus IN( 'Assigned',
                      'Transferred' ) THEN 1
                    ELSE
                    2
                  END
                    AS tagstatusorder
                  FROM
                    EDW_TRIPS.dim_vehicletag ) AS dct
                ON
                  dct.tagid = tp.tagrefid
                  AND dct.tagagency = tp.tagagency
                  AND dct.customerid = tp.customerid
                  AND tp.exittripdatetime BETWEEN dct.tagstartdate
                  AND dct.tagenddate
                LEFT OUTER JOIN (
                  SELECT
                    ctrt.linkid AS custtripid,
                    MAX(adj_0.approvedstatusdate) AS adjustmentdate,
                    SUM(adj_0.amount *
                      CASE
                        WHEN drcrflag = 'D' THEN -1
                      ELSE
                      1
                    END
                      ) AS adjustedtolls
                  FROM
                    LND_TBOS.finance_adjustment_lineitems AS ctrt
                  INNER JOIN
                    LND_TBOS.finance_adjustments AS adj_0
                  ON
                    adj_0.adjustmentid = ctrt.adjustmentid
                    AND ctrt.linksourcename = 'TOLLPLUS.TP_CUSTOMERTRIPS'
                    AND adj_0.approvedstatusid = 466
                  GROUP BY
                    1 ) AS adj
                ON
                  adj.custtripid = tp.custtripid
                WHERE
                  1 = 1
                  AND tp.exittripdatetime < '"""||lastdatetoload||"""' )
              SELECT
                main_cte.custtripid,
                main_cte.tptripid,
                main_cte.tripdayid,
                main_cte.laneid,
                main_cte.customerid,
                main_cte.vehicleid,
                main_cte.custtagid,
                main_cte.vehicletagid,
                main_cte.vehicleclassid,
                main_cte.paymentstatusid,
                main_cte.tripstageid,
                main_cte.tripstatusid,
                main_cte.tripidentmethodid,
                main_cte.transactionpostingtypeid,
                main_cte.sourceofentry,
                main_cte.tripdate,
                main_cte.posteddate,
                main_cte.tripstatusdate,
                main_cte.adjusteddate,
                COALESCE(CASE
                    WHEN ROW_NUMBER() OVER (PARTITION BY main_cte.tptripid ORDER BY main_cte.deleteflag, main_cte.custtripid DESC) = 1 THEN 1
                  ELSE
                  0
                END
                  , 0) AS currenttxnflag,
                main_cte.deleteflag,
                main_cte.tollamount,
                main_cte.feeamount,
                main_cte.discountamount,
                main_cte.netamount,
                main_cte.rewarddiscountamount,
                main_cte.outstandingamount,
                main_cte.pbmtollamount,
                main_cte.avitollamount,
                main_cte.adjustedtollamount,
                main_cte.updateddate,
                main_cte.lnd_updatedate,
                main_cte.edw_updatedate,
                main_cte.txndatetime,
                main_cte.feeamounts,
                main_cte.adjustedtolls,
                main_cte.tripidentmethod,
                main_cte.rewardsdiscountamount,
                main_cte.discountsamount
              FROM
                main_cte
              WHERE
                main_cte.rn = 1;""";
      IF isfullload <> 1 THEN
        SET sql = replace(sql,"WITH main_cte AS","""WITH ChangedTPTripIDs_CTE AS 
        ( 
          SELECT """||identifyingcolumns||""" ,TPTripID 	
          FROM LND_TBOS.TollPlus_TP_CustomerTrips  
          WHERE LND_UpdateDate > '"""||SUBSTR(CAST(last_updated_date AS STRING FORMAT "yyyy-mm-dd hh:mi:ss.mmmm"),1,25 )||"""'
        ),
          ChangedCurrentTxnFlags_CTE AS 
        ( 	
          SELECT TP."""||identifyingcolumns||""" 	
          FROM """||tablename||""" TP 	
          JOIN ChangedTPTripIDs_CTE AS CTE ON  TP.TPTripID = CTE.TPTripID  
          WHERE CurrentTxnFlag = 1
        ), 
          ChangedCustTripIDs_CTE AS
        (	
          SELECT """||identifyingcolumns||"""	
          FROM ChangedTPTripIDs_CTE	
          UNION ALL	
          SELECT """||identifyingcolumns||"""	
          FROM ChangedCurrentTxnFlags_CTE
        ), 
          Main_CTE AS """);
       
        SET sql = replace(sql,"WHERE 1 = 1","JOIN  ChangedCustTripIDs_CTE AS CTE ON TP.CustTripID = CTE.CustTripID");
      END IF;
      IF trace_flag = 1 THEN
        --CALL utility.longprint(sql);
        Select sql;
      END IF;
      EXECUTE IMMEDIATE sql;
      SET log_message = concat('Loaded ', stagetablename);
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, sql);
      
      IF isfullload = 1 THEN
        -- Table swap!
        -- The table swap stored procedure is not needed, as BigQuery handles this with the CREATE OR REPLACE statement.
        --CALL utility.tableswap(stagetablename, tablename);
        SET sql = concat("Create Or Replace Table ", tablename , " as Select * from ",stagetablename );
		    EXECUTE IMMEDIATE sql;
        SET log_message = 'Completed full load';
      ELSE
        --CALL utility.managepartitions_dateid(tablename, 'DayID:Month');
        --CALL utility.partitionswitch_range(stagetablename, tablename, identifyingcolumns, CAST(NULL as STRING));
        -- Dropping Records From Main Table To Avoid Duplicates
		    SET sql = concat("Delete From ", tablename , " where ", identifyingcolumns ," In ( Select ", identifyingcolumns , " from ",stagetablename , " )" );
		    EXECUTE IMMEDIATE sql;
		    -- Inserting NEW Records from Stage to Main Table
		    SET sql = concat("Insert Into  ", tablename , " Select * from ",stagetablename );
		    EXECUTE IMMEDIATE sql;
        SET log_message = concat('Completed Incremental load from ', substr(CAST(last_updated_date as STRING), 1, 25));
      END IF;
      SET last_updated_date = CAST(NULL as DATETIME);
      CALL EDW_TRIPS_SUPPORT.Set_UpdatedDate(tablename, tablename, last_updated_date);
      SET log_message = concat(log_message , '. Set Last Update date as ', substr(CAST(last_updated_date as STRING FORMAT 'yyyy-mm-dd hh:mi:ss.mmmm'), 1, 25));
      IF trace_flag = 1 THEN
        select  log_message;
      END IF;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      IF trace_flag = 1 THEN
        --CALL utility.fromlog(tablename, substr(CAST(log_start_date as STRING), 1, 23));
        select tablename , log_start_date ;
      END IF;      
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = error_message;-- Rethrow the error!
      END;
    END;


/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================
EXEC dbo.Fact_TollTransaction_Load

EXEC Utility.FromLog 'dbo.Fact_TollTransaction', 1
SELECT TOP 100 'dbo.Fact_TollTransaction' TableName, * FROM dbo.Fact_TollTransaction ORDER BY 2

--===============================================================================================================
-- !!! USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel !!! 
--===============================================================================================================
SELECT TripDayID/100 AS MONTHID , COUNT_BIG(1) FROM dbo.Fact_TollTransaction				-- 1480156608
GROUP BY TripDayID/100
ORDER BY MONTHID

SELECT TripIdentMethod , COUNT_BIG(1) FROM dbo.Fact_TollTransaction				-- 1480156608
GROUP BY TripIdentMethod
ORDER BY TripIdentMethod

SELECT ISNULL(CAST(CASE WHEN ISNUMERIC(TP.VehicleClass) = 1 THEN TP.VehicleClass ELSE NULL END AS SMALLINT),-1) AS VehicleClass, COUNT_BIG(1) AS cnt
FROM LND_TBOS.TOLLPLUS.TP_CustomerTrips TP
GROUP BY ISNULL(CAST(CASE WHEN ISNUMERIC(TP.VehicleClass) = 1 THEN TP.VehicleClass ELSE NULL END AS SMALLINT),-1)
ORDER BY VehicleClass

--===============================================================================================================
-- !!! Recently removed columns !!! 
--===============================================================================================================
		--, ISNULL(CAST(TP.Exit_TollTxnID AS BIGINT), -1) AS TollTxnID							-- Do we need? 
		--, ISNULL(CAST(TP.Disposition AS INT), -1) AS Disposition
		--, ISNULL(CAST(TP.TransactionTypeID AS tinyint), -1) AS TransactionTypeID
		--, ISNULL(CAST(TP.TTxn_ID AS BIGINT), -1) AS TtxnID										-- Do we need?
		--, ISNULL(CAST(TP.AccountAgencyID AS BIGINT), -1) AS AccountAgencyID
		--, ISNULL(CAST(TP.IsExcessiveVToll AS BIT), -1) AS ExcessiveVTollFlag
		--, ISNULL(CAST(TP.IsROVWaiting AS BIT), -1) AS ROVWaitingFlag


TESTING:

EXEC dbo.Fact_TollTransaction_Load 1

EXEC Utility.FromLog 'dbo.Fact_TollTransaction', 1

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_TollTransaction', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  -- 2021-02-25 16:57:12.841

SELECT  LND_UpdateDate, COUNT_BIG(1) Cnt
FROM dbo.Fact_TollTransaction
GROUP BY LND_UpdateDate
ORDER BY LND_UpdateDate DESC

EXEC Utility.Set_UpdatedDate 'dbo.Fact_TollTransaction', NULL, '2021-02-25 16:00:00'
DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_TollTransaction', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  -- 2021-02-25 16:00:00.000

-- 2021-02-25 16:00:00.000
EXEC dbo.Fact_TollTransaction_Load 0

EXEC Utility.FromLog 'dbo.Fact_TollTransaction', 1

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_TollTransaction', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  -- 2021-02-25 16:57:12.841

*/



  END;