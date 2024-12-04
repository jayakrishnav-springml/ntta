CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_AdjExpectedAmountDetail_Load`(isfullload INT64)
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_AdjExpectedAmountDetail and dbo.Fact_AdjExpectedAmount tables which are important for Board Reporting
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040744	Shankar		2022-03-21	New!
CHG0041141	Shankar		2022-06-30	Filter TPTripIDs selected to reduce incr run payload
CHG0042644	Shankar		2023-03-01	Incremental load cleanup of invalid data in existing table
===================================================================================================================
Example:   
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_AdjExpectedAmountDetail_Load 1
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE 'dbo.Fact_AdjExpectedAmount%' ORDER BY 1 DESC
SELECT * FROM Utility.LoadProcessControl WHERE TableName LIKE 'Fact_AdjExpectedAmountDetail%' ORDER BY 1

SELECT TOP 100 'dbo.Fact_AdjExpectedAmountDetail' Table_Name, TA.AdjustmentType,* 
FROM dbo.Fact_AdjExpectedAmountDetail AEA 
LEFT JOIN LND_TBOS.Finance.TollAdjustments TA ON AEA.TollAdjustmentID = TA.TollAdjustmentID 
WHERE TPTripID = 1938177625 
ORDER BY TxnSeqDesc Desc

SELECT TOP 100 'dbo.Fact_AdjExpectedAmount' Table_Name, * FROM dbo.Fact_AdjExpectedAmount WHERE TPTripID = 1938177625

SELECT COUNT(1) RC FROM Stage.Bubble_TPTripID
###################################################################################################################
*/


		/*=========================================== TESTING ========================================================*/
		--DECLARE @IsFullLoad BIT = 0
		/*=========================================== TESTING ========================================================*/

    DECLARE tablename STRING DEFAULT 'EDW_TRIPS.Fact_AdjExpectedAmountDetail';
    DECLARE trace_flag INT64 DEFAULT 0;-- Testing
    DECLARE firstpartitionid INT64 DEFAULT 201901;
    DECLARE lastpartitionid INT64;
    DECLARE partition_ranges STRING;
    DECLARE createtablewith STRING;
    DECLARE log_message STRING;
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_AdjExpectedAmountDetail_Load';
    DECLARE log_start_date DATETIME;
    DECLARE identifyingcolumns STRING DEFAULT 'TPTripID';
    DECLARE last_tp_trips_date DATETIME DEFAULT '2019-01-01';
    DECLARE last_tp_customertrips_date DATETIME DEFAULT '2019-01-01';
    DECLARE last_tp_violatedtrips_date DATETIME DEFAULT '2019-01-01';
    DECLARE last_bos_iop_outboundtransactions_date DATETIME DEFAULT '2019-01-01';
    DECLARE firstdatetoload STRING DEFAULT '2019-01-01';
    DECLARE nodataflag INT64 DEFAULT 0;
    DECLARE stagetablename STRING DEFAULT 'EDW_TRIPS.Fact_AdjExpectedAmountDetail_NEW';
    DECLARE lastdatetoload STRING;
    DECLARE sql STRING;
    DECLARE next_tp_trips_date DATETIME;
    DECLARE next_tp_customertrips_date DATETIME;
    DECLARE next_tp_violatedtrips_date DATETIME;
    DECLARE next_bos_iop_outboundtransactions_date DATETIME;
    BEGIN
		SET log_start_date = current_datetime('America/Chicago');
		SET lastdatetoload = cast(current_datetime('America/Chicago') as string);
		SET lastpartitionid = CAST(SUBSTR(CAST(DATE_ADD(LAST_DAY(DATE_ADD(CURRENT_DATE, INTERVAL 1 MONTH)),INTERVAL 1 DAY) AS STRING FORMAT 'YYYYMMDD'),1,6) AS INT64);
		IF (SELECT count(1) FROM  EDW_TRIPS.INFORMATION_SCHEMA.TABLES WHERE table_name=SUBSTR(tablename,STRPOS(tablename,'.')+1)) =0 then
			SET isfullload = 1;
		END IF;
		IF isfullload = 1 THEN
			-- Commenting partitionswitch_range , replaced with delete & Insert
			--CALL EDW_TRIPS_SUPPORT.Get_PartitionDayIDRange_String(firstpartitionid, lastpartitionid, partition_ranges);
			-- SET createtablewith = concat('(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (', partition_ranges, ')))');
			SET createtablewith = concat(' cluster by ',identifyingcolumns);
			SET log_message = 'Started full load';
			IF trace_flag = 1 THEN
		  		select log_message;
        	END IF;
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
			
		ELSE
			-- SET createtablewith = concat('(CLUSTERED INDEX (', identifyingcolumns, '), DISTRIBUTION = HASH(TPTripID))');
			SET createtablewith = concat(' cluster by ',identifyingcolumns);
			IF trace_flag = 1 THEN
		  		SELECT 'Calling: EDW_TRIPS_SUPPORT.Get_UpdatedDate for EDW_TRIPS_Fact_AdjExpectedAmountDetail~TP_Trips';
        	END IF;
			CALL EDW_TRIPS_SUPPORT.Get_UpdatedDate('Fact_AdjExpectedAmountDetail~TP_Trips', last_tp_trips_date);
			IF trace_flag = 1 THEN
          		SELECT 'Calling: EDW_TRIPS_SUPPORT.Get_UpdatedDate for EDW_TRIPS_Fact_AdjExpectedAmountDetail~TP_CustomerTrips';
        	END IF;
			CALL EDW_TRIPS_SUPPORT.Get_UpdatedDate('Fact_AdjExpectedAmountDetail~TP_CustomerTrips', last_tp_customertrips_date);
			IF trace_flag = 1 THEN
		  		SELECT 'Calling: EDW_TRIPS_SUPPORT.Get_UpdatedDate for EDW_TRIPS_Fact_AdjExpectedAmountDetail~TP_ViolatedTrips';
        	END IF;
			CALL EDW_TRIPS_SUPPORT.Get_UpdatedDate('Fact_AdjExpectedAmountDetail~TP_ViolatedTrips', last_tp_violatedtrips_date);
			IF trace_flag = 1 THEN
		  		SELECT 'Calling: EDW_TRIPS_SUPPORT.Get_UpdatedDate for EDW_TRIPS_Fact_AdjExpectedAmountDetail~BOS_IOP_OutboundTransactions';
        	END IF;
			CALL EDW_TRIPS_SUPPORT.Get_UpdatedDate('Fact_AdjExpectedAmountDetail~BOS_IOP_OutboundTransactions', last_bos_iop_outboundtransactions_date);
			SET log_message = concat('Started incremental load: TP_Trips from ', coalesce(substr(CAST(last_tp_trips_date as STRING), 1, 25), r'???'), ', TP_CustomerTrips from ', coalesce(substr(CAST(last_tp_customertrips_date as STRING), 1, 25), r'???'), ', TP_ViolatedTrips from ', coalesce(substr(CAST(last_tp_violatedtrips_date as STRING), 1, 25), r'???'), ', BOS_IOP_OutboundTransactions from ', coalesce(substr(CAST(last_bos_iop_outboundtransactions_date as STRING), 1, 25), r'???'));
			IF trace_flag = 1 THEN
		  		SELECT log_message;
		  	END IF;
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
        
			CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.Bubble_TPTripID
			cluster by TPTripID
			AS
				SELECT
					TP_Trips.tptripid
				FROM
					LND_TBOS.TollPlus_TP_Trips as TP_Trips
				WHERE TP_Trips.lnd_updatedate > last_tp_trips_date
				AND TP_Trips.sourceofentry IN(
					1, 3
				)
				AND TP_Trips.exittripdatetime >= cast(firstdatetoload as datetime)
				AND TP_Trips.exit_tolltxnid >= 0
				AND TP_Trips.lnd_updatetype <> 'D'
				UNION DISTINCT
				SELECT
					TP_CustomerTrips.tptripid
				FROM
					LND_TBOS.TollPlus_TP_CustomerTrips AS TP_CustomerTrips
				WHERE TP_CustomerTrips.lnd_updatedate > last_tp_customertrips_date
				AND TP_CustomerTrips.sourceofentry IN(
					1, 3
				)
				AND TP_CustomerTrips.exittripdatetime >= cast(firstdatetoload as datetime)
				AND TP_CustomerTrips.lnd_updatetype <> 'D'
				UNION DISTINCT
				SELECT
					TP_ViolatedTrips.tptripid
				FROM
					LND_TBOS.TollPlus_TP_ViolatedTrips AS TP_ViolatedTrips
				WHERE TP_ViolatedTrips.lnd_updatedate > last_tp_violatedtrips_date
				AND TP_ViolatedTrips.exittripdatetime >= cast(firstdatetoload as datetime)
				AND TP_ViolatedTrips.lnd_updatetype <> 'D'
				UNION DISTINCT
				SELECT
					IOP_BOS_IOP_OutboundTransactions.tptripid
				FROM
					LND_TBOS.IOP_BOS_IOP_OutboundTransactions AS IOP_BOS_IOP_OutboundTransactions
				WHERE LND_UpdateDate > last_bos_iop_outboundtransactions_date AND
								IOP_BOS_IOP_OutboundTransactions.transactionstatus = 'Posted'
				AND IOP_BOS_IOP_OutboundTransactions.lnd_updatetype <> 'D'
			;
			SET log_message = 'Loaded Stage.Bubble_TPTripID with TPTripIDs for incremental load';
       		CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
	   
			IF (
			SELECT
				count(1)
				FROM
				EDW_TRIPS_STAGE.Bubble_TPTripID
			) = 0 THEN
			SET nodataflag = 1
			;
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed incremental load: No data to load!', 'I', -1, NULL);
			END IF;
      	END IF;
		--=============================================================================================================
		-- Load dbo.Fact_AdjExpectedAmountDetail
		--============================================================================================================
		IF isfullload = 1
		OR (isfullload = 0
		AND nodataflag = 0) THEN
			
			SET sql="CREATE OR REPLACE TABLE "||stagetablename||" "||createtablewith||" AS  WITH  cte_adjexpectedamt AS (   SELECT       t.tptripid,       tc.custtripid AS custtripid,       CAST(NULL as INT64) AS citationid,       CAST(CAST(/* expression of unknown or erroneous type */ t.exittripdatetime as STRING FORMAT 'yyyymmdd') as INT64) AS tripdayid,       CASE         WHEN t.tripwith = \'C\'          AND t.linkid = tc.custtripid THEN 1         ELSE 0       END AS currenttxnflag,       \'TP_Customer_Trip_Charges_Tracker\' AS sourcename,       ct.tripchargeid AS sourceid,       CAST(NULL as INT64) AS tolladjustmentid,       CAST(NULL as STRING) AS adjustmentreason,       ct.amount,       ct.createddate AS txndate,       tc.lnd_updatedate     FROM       lnd_tbos.tollplus_tp_trips AS t       INNER JOIN lnd_tbos.tollplus_tp_customertrips AS tc ON tc.tptripid = t.tptripid       INNER JOIN lnd_tbos.tollplus_tp_customer_trip_charges_tracker AS ct ON ct.custtripid = tc.custtripid     WHERE 1 = 1      AND t.sourceofentry IN(       1, 3     )      AND t.exit_tolltxnid >= 0      AND t.exittripdatetime >= \'"||firstdatetoload||"\'      AND t.exittripdatetime < \'"||lastdatetoload||"\' AND t.lnd_updatetype <> \'D\'      AND tc.lnd_updatetype <> \'D\'   UNION ALL   SELECT       t.tptripid,       tc.custtripid,       CAST(NULL as INT64) AS citationid,       CAST(CAST( t.exittripdatetime as STRING FORMAT 'yyyymmdd') as INT64) AS tripdayid,       CASE         WHEN t.tripwith = \'C\'          AND t.linkid = tc.custtripid THEN 1         ELSE 0       END AS currenttxnflag,       \'Adjustment_LineItems\' AS sourcename,       ali.adjustmentid AS sourceid,       a.tolladjustmentid,       a.adjustmentreason,       CASE         WHEN a.drcrflag = \'C\' THEN ali.amount * -1         ELSE ali.amount       END AS amount,       a.approvedstatusdate AS txndate,       tc.lnd_updatedate     FROM       lnd_tbos.tollplus_tp_trips AS t       INNER JOIN lnd_tbos.tollplus_tp_customertrips AS tc ON tc.tptripid = t.tptripid       INNER JOIN lnd_tbos.finance_adjustment_lineitems AS ali ON tc.custtripid = ali.linkid        AND ali.linksourcename = \'TollPlus.TP_CustomerTrips\'       INNER JOIN lnd_tbos.finance_adjustments AS a ON a.adjustmentid = ali.adjustmentid        AND a.approvedstatusid = 466     WHERE 1 = 1      AND t.sourceofentry IN(       1, 3     )      AND t.exit_tolltxnid >= 0      AND t.exittripdatetime >= \'"||firstdatetoload||"\'      AND t.exittripdatetime < \'"||lastdatetoload||"\'     AND t.lnd_updatetype <> \'D\'      AND tc.lnd_updatetype <> \'D\'      AND ali.lnd_updatetype <> \'D\'      AND a.lnd_updatetype <> \'D\'   UNION ALL   SELECT       t.tptripid,       CAST(NULL as INT64) AS custtripid,       tv.citationid,       CAST(CAST(/* expression of unknown or erroneous type */ t.exittripdatetime as STRING FORMAT 'yyyymmdd') as INT64) AS tripdayid,       CASE         WHEN t.tripwith = \'V\'          AND t.linkid = tv.citationid THEN 1         ELSE 0       END AS currenttxnflag,       \'TP_Violated_Trip_Charges_Tracker\' AS sourcename,       vt.tripchargeid AS sourceid,       CAST(NULL as INT64) AS tolladjustmentid,       CAST(NULL as STRING) AS adjustmentreason,       vt.amount AS amount,       vt.createddate AS txndate,       tv.lnd_updatedate     FROM       lnd_tbos.tollplus_tp_trips AS t       INNER JOIN lnd_tbos.tollplus_tp_violatedtrips AS tv ON tv.tptripid = t.tptripid       INNER JOIN lnd_tbos.tollplus_tp_violated_trip_charges_tracker AS vt ON vt.citationid = tv.citationid     WHERE 1 = 1      AND t.sourceofentry IN(       1, 3     )      AND t.exit_tolltxnid >= 0      AND t.exittripdatetime >= \'"||firstdatetoload||"\'      AND t.exittripdatetime < \'"||lastdatetoload||"\'       AND t.lnd_updatetype <> \'D\'      AND tv.lnd_updatetype <> \'D\'   UNION ALL   SELECT       t.tptripid,       CAST(NULL as INT64) AS custtripid,       tv.citationid,       CAST(CAST(/* expression of unknown or erroneous type */ t.exittripdatetime as STRING FORMAT 'yyyymmdd') as INT64) AS tripdayid,       CASE         WHEN t.tripwith = \'V\'          AND t.linkid = tv.citationid THEN 1         ELSE 0       END AS currenttxnflag,       \'Adjustment_LineItems\' AS sourcename,       a.adjustmentid AS sourceid,       a.tolladjustmentid,       a.adjustmentreason,       CASE         WHEN a.drcrflag = \'C\' THEN ali.amount * -1         ELSE ali.amount       END AS amount,       a.approvedstatusdate AS txndate,       tv.lnd_updatedate     FROM       lnd_tbos.tollplus_tp_trips AS t       INNER JOIN lnd_tbos.tollplus_tp_violatedtrips AS tv ON tv.tptripid = t.tptripid       INNER JOIN lnd_tbos.finance_adjustment_lineitems AS ali ON tv.citationid = ali.linkid        AND ali.linksourcename = \'TollPlus.TP_ViolatedTrips\'       INNER JOIN lnd_tbos.finance_adjustments AS a ON a.adjustmentid = ali.adjustmentid        AND a.approvedstatusid = 466     WHERE 1 = 1      AND t.sourceofentry IN(       1, 3     )      AND t.exit_tolltxnid >= 0      AND t.exittripdatetime >= \'"||firstdatetoload||"\'      AND t.exittripdatetime < \'"||lastdatetoload||"\'     AND t.lnd_updatetype <> \'D\'      AND tv.lnd_updatetype <> \'D\'      AND ali.lnd_updatetype <> \'D\'      AND a.lnd_updatetype <> \'D\'   UNION ALL   SELECT       t.tptripid,       CAST(NULL as INT64) AS custtripid,       CAST(NULL as INT64) AS citationid,       CAST(CAST( t.exittripdatetime as STRING FORMAT 'yyyymmdd') as INT64) AS tripdayid,       CASE         WHEN t.tripwith = \'I\' THEN 1         ELSE 0       END AS currenttxnflag,       CASE         WHEN i.tollamount IS NOT NULL THEN \'BOS_IOP_OutboundTransactions-Paid\'         ELSE  \'BOS_IOP_OutboundTransactions-NotPaid\'       END AS sourcename,       t.linkid AS sourceid,       CAST(NULL as INT64) AS tolladjustmentid,       CAST(NULL as STRING) AS adjustmentreason,       coalesce(i.tollamount, t.tollamount) AS amount,       t.posteddate AS txndate,       coalesce(i.lnd_updatedate, t.lnd_updatedate) AS lnd_updatedate     FROM       lnd_tbos.tollplus_tp_trips AS t       LEFT OUTER JOIN (         SELECT             iop_bos_iop_outboundtransactions.tptripid,             sum(iop_bos_iop_outboundtransactions.tollamount) AS tollamount,             max(iop_bos_iop_outboundtransactions.lnd_updatedate) AS lnd_updatedate           FROM             lnd_tbos.iop_bos_iop_outboundtransactions           WHERE iop_bos_iop_outboundtransactions.transactionstatus = \'Posted\'            AND iop_bos_iop_outboundtransactions.exittripdatetime >= \'"||firstdatetoload||"\'            AND iop_bos_iop_outboundtransactions.exittripdatetime < \'"||lastdatetoload||"\'           AND iop_bos_iop_outboundtransactions.lnd_updatetype <> \'D\'           GROUP BY iop_bos_iop_outboundtransactions.tptripid       ) AS i ON i.tptripid = t.tptripid     WHERE 1 = 1      AND t.tripstageid = 31      AND  coalesce(t.tripwith, \'I\') = \'I\'      AND t.sourceofentry IN(       1, 3     )      AND t.exit_tolltxnid >= 0      AND t.exittripdatetime >= \'"||firstdatetoload||"\'      AND t.exittripdatetime < \'"||lastdatetoload||"\'      AND t.lnd_updatetype <> \'D\' ) SELECT     cte_adjexpectedamt.tptripid,     cte_adjexpectedamt.custtripid,     cte_adjexpectedamt.citationid,     cte_adjexpectedamt.currenttxnflag,     cte_adjexpectedamt.tripdayid,     cte_adjexpectedamt.sourceid,     cte_adjexpectedamt.sourcename,     cte_adjexpectedamt.tolladjustmentid,     cte_adjexpectedamt.adjustmentreason,     row_number() OVER (PARTITION BY cte_adjexpectedamt.tptripid ORDER BY cte_adjexpectedamt.currenttxnflag, cte_adjexpectedamt.txndate) AS txnseqasc,     cte_adjexpectedamt.txndate,     cte_adjexpectedamt.amount,     sum(cte_adjexpectedamt.amount) OVER (PARTITION BY cte_adjexpectedamt.tptripid ORDER BY cte_adjexpectedamt.currenttxnflag, cte_adjexpectedamt.txndate) AS runningtotalamount,     sum(CASE       WHEN cte_adjexpectedamt.sourcename = \'Adjustment_LineItems\' THEN cte_adjexpectedamt.amount       ELSE 0     END) OVER (PARTITION BY cte_adjexpectedamt.tptripid ORDER BY cte_adjexpectedamt.currenttxnflag, cte_adjexpectedamt.txndate) AS runningalladjamount,     sum(CASE       WHEN cte_adjexpectedamt.sourcename = \'Adjustment_LineItems\'        AND cte_adjexpectedamt.currenttxnflag = 1 THEN cte_adjexpectedamt.amount       ELSE 0     END) OVER (PARTITION BY cte_adjexpectedamt.tptripid ORDER BY cte_adjexpectedamt.currenttxnflag, cte_adjexpectedamt.txndate) AS runningtripwithadjamount,     row_number() OVER (PARTITION BY cte_adjexpectedamt.tptripid ORDER BY cte_adjexpectedamt.currenttxnflag DESC, cte_adjexpectedamt.txndate DESC) AS txnseqdesc,     cte_adjexpectedamt.lnd_updatedate,     current_datetime() AS edw_updatedate   FROM     cte_adjexpectedamt ";

			IF isfullload = 0 THEN
				SET sql = replace(sql, 'WHERE 1 = 1', 'WHERE   EXISTS (SELECT 1 FROM EDW_TRIPS_STAGE.Bubble_TPTripID TT WHERE TT.TPTripID = T.TPTripID)');
			END IF;
			IF trace_flag = 1 THEN
          		Select sql;
        	END IF;
			EXECUTE IMMEDIATE sql;
			SET log_message = concat('Loaded ', stagetablename);
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, sql);
		END IF;
    	--====================================================================================
		-- Finish full load
		--====================================================================================
		
		IF isfullload = 1 THEN
			--table swap
			--CALL EDW_TRIPS_SUPPORT.TableSwap(stagetablename, tablename);
			create or replace table EDW_TRIPS.Fact_AdjExpectedAmountDetail as(
			select * from EDW_TRIPS.Fact_AdjExpectedAmountDetail_NEW
			);
			SET log_message = 'Completed full load';
		END IF;
    	--====================================================================================
		-- Incremental load cleanup of invalid data in existing in Fact_AdjExpectedAmountDetail
		--====================================================================================
		
		IF isfullload = 0
		AND nodataflag = 0 THEN
		
			--Some TpTripIDs existing in Fact_AdjExpectedAmountDetail no longer qualify in full load run. Clean them up! Replicate full load output.

			DROP TABLE IF EXISTS EDW_TRIPS.Fact_AdjExpectedAmountDetail_DEL; 
			CREATE  TABLE EDW_TRIPS.Fact_AdjExpectedAmountDetail_DEL
			AS
				(
				SELECT
					Fact_AdjExpectedAmountDetail.tptripid
					FROM
					EDW_TRIPS.Fact_AdjExpectedAmountDetail
				INTERSECT DISTINCT SELECT
					bubble_tptripid.tptripid
					FROM
					EDW_TRIPS_STAGE.Bubble_TPTripID 
				) EXCEPT DISTINCT SELECT
					Fact_AdjExpectedAmountDetail_NEW.tptripid
				FROM
					EDW_TRIPS.Fact_AdjExpectedAmountDetail_NEW;
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Loaded TpTripIDs not qualified for dbo.Fact_AdjExpectedAmountDetail full load as of now into Temp.Fact_AdjExpectedAmountDetail_DEL', 'I', NULL, '-1');
			
			DELETE FROM EDW_TRIPS.Fact_AdjExpectedAmountDetail WHERE Fact_AdjExpectedAmountDetail.tptripid IN(
			SELECT
				Fact_AdjExpectedAmountDetail_DEL.tptripid
				FROM
				EDW_TRIPS.Fact_AdjExpectedAmountDetail_DEL
			);

			
		
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Deleted TpTripID rows not qualified for full load from dbo.Fact_AdjExpectedAmountDetail using Temp.Fact_AdjExpectedAmountDetail_DEL', 'I', NULL, '-1');
		END IF;

		--====================================================================================
		-- Call dbo.Fact_AdjExpectedAmount_Load
		--====================================================================================

		IF isfullload = 1
		OR isfullload = 0
		AND nodataflag = 0 THEN
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Calling: dbo.Fact_AdjExpectedAmount_Load', 'I', NULL, NULL);
			IF trace_flag = 1 THEN
		  		select 'Calling: EDW_TRIPS.Fact_AdjExpectedAmount_Load';
        	END IF;
			CALL EDW_TRIPS.Fact_AdjExpectedAmount_Load(isfullload);
		END IF;

    	--====================================================================================
		-- Finish incremental load
		--====================================================================================
		
		IF isfullload = 0
		AND nodataflag = 0 THEN
			-- Commenting partitionswitch_range , replaced with delete & Insert
			--CALL EDW_TRIPS_SUPPORT.ManagePartitions_DateID(tablename, 'DayID:Month');
			--CALL EDW_TRIPS_SUPPORT.PartitionSwitch_Range(stagetablename, tablename, identifyingcolumns, NULL);
			
			-- Dropping Records From Main Table To Avoid Duplicates
			SET sql = concat("Delete From ", tablename , " where ", identifyingcolumns ," In ( Select ", identifyingcolumns , " from ",stagetablename , " )" );
			EXECUTE IMMEDIATE sql;
			
			-- Inserting NEW Records from Stage to Main Table
			SET sql = concat("Insert Into  ", tablename , " Select * from ",stagetablename );
			EXECUTE IMMEDIATE sql;
			

			/*
			INSERT INTO EDW_TRIPS.Fact_AdjExpectedAmountDetail
		SELECT * FROM EDW_TRIPS.Fact_AdjExpectedAmountDetail_NEW 
		WHERE tptripid NOT IN (SELECT tptripid from EDW_TRIPS.Fact_AdjExpectedAmountDetail);
		*/
		
			SET log_message = 'Completed incremental load';
		END IF;
		
		--====================================================================================
		-- Set the load dates for next run for full or incremental load
		--====================================================================================
		
		IF isfullload = 1
		OR isfullload = 0
		AND nodataflag = 0 THEN
		--:: Set the load date for the next incremental run
			CALL EDW_TRIPS_SUPPORT.Set_UpdatedDate('Fact_AdjExpectedAmountDetail~TP_Trips', 'LND_TBOS.TollPlus_TP_Trips', next_tp_trips_date);
			CALL EDW_TRIPS_SUPPORT.Set_UpdatedDate('Fact_AdjExpectedAmountDetail~TP_CustomerTrips', 'LND_TBOS.TollPlus_TP_CustomerTrips', next_tp_customertrips_date);
			CALL EDW_TRIPS_SUPPORT.Set_UpdatedDate('Fact_AdjExpectedAmountDetail~TP_ViolatedTrips', 'LND_TBOS.TollPlus_TP_ViolatedTrips', next_tp_violatedtrips_date);
			CALL EDW_TRIPS_SUPPORT.Set_UpdatedDate('Fact_AdjExpectedAmountDetail~BOS_IOP_OutboundTransactions', 'LND_TBOS.IOP_BOS_IOP_OutboundTransactions', next_bos_iop_outboundtransactions_date);
			SET log_message = concat(log_message, '. SET next run start dates: TP_Trips after ', coalesce(substr(CAST(next_tp_trips_date as STRING), 1, 25), r'???'), ', TP_CustomerTrips after ', coalesce(substr(CAST(next_tp_customertrips_date as STRING), 1, 25), r'???'), ', TP_ViolatedTrips after ', coalesce(substr(CAST(next_tp_violatedtrips_date as STRING), 1, 25), r'???'), ', BOS_IOP_OutboundTransactions after ', coalesce(substr(CAST(next_bos_iop_outboundtransactions_date as STRING), 1, 25), r'???'));
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', NULL, NULL);
			IF trace_flag = 1 THEN
		  		select log_message;
        	END IF;
        	
			IF trace_flag = 1 THEN
          		SELECT 'EDW_TRIPS.Fact_AdjExpectedAmountDetail' AS tablename, Fact_AdjExpectedAmountDetail.*
            	FROM EDW_TRIPS.Fact_AdjExpectedAmountDetail
          		ORDER BY CAST(edw_updatedate as DATE) DESC, tptripid, txndate
            	LIMIT 100 ;
        	END IF;
		END IF;
		
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
        RAISE USING MESSAGE = error_message;-- Rethrow the error!
      END;
    END;
    

/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================
EXEC dbo.Fact_AdjExpectedAmountDetail_Load 1
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE 'dbo.Fact_AdjExpectedAmount%' ORDER BY 1 DESC  
SELECT TOP 100 'dbo.Fact_AdjExpectedAmountDetail' TableName, * FROM dbo.Fact_AdjExpectedAmountDetail WHERE TPTripID = 1937242377 ORDER BY 2, TxnSeqAsc
SELECT TOP 100 * FROM dbo.Fact_AdjExpectedAmountDetail_NEW 
 
SourceName                                                 RC
---------------------------------------- --------------------
TP_Customer_Trip_Charges_Tracker                   2308198869
TP_Violated_Trip_Charges_Tracker                    611543925
BOS_IOP_OutboundTransactions-Paid                   196969483
Adjustment_LineItems                                173986315
BOS_IOP_OutboundTransactions-NotPaid                  3512093


--:: Full
SELECT COUNT_BIG(1) RC, MIN(TripDayID) TripDayID_From, MAX(TripDayID) TripDayID_To, MIN(TxnDate) TxnDate_From, MAX(TxnDate) TxnDate_To, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To, MAX(EDW_UpdateDate) EDW_UpdateDate 
FROM dbo.Fact_AdjExpectedAmountDetail  

SELECT LND_UpdateDate, COUNT_BIG(1) RC, MIN(TripDayID) TripDayID_From, MAX(TripDayID) TripDayID_To, MIN(TxnDate) TxnDate_From, MAX(TxnDate) TxnDate_To, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To, MAX(EDW_UpdateDate) EDW_UpdateDate 
FROM dbo.Fact_AdjExpectedAmountDetail  
GROUP BY LND_UpdateDate
ORDER BY 1

SELECT SourceName, COUNT_BIG(1) RC, MIN(TripDayID) TripDayID_From, MAX(TripDayID) TripDayID_To, MIN(TxnDate) TxnDate_From, MAX(TxnDate) TxnDate_To, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To, MAX(EDW_UpdateDate) EDW_UpdateDate 
FROM dbo.Fact_AdjExpectedAmountDetail  
GROUP BY SourceName
ORDER BY 1

--:: Incremental
SELECT COUNT_BIG(1) RC, MIN(TripDayID) TripDayID_From, MAX(TripDayID) TripDayID_To, MIN(TxnDate) TxnDate_From, MAX(TxnDate) TxnDate_To, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To, MAX(EDW_UpdateDate) EDW_UpdateDate 
FROM dbo.Fact_AdjExpectedAmountDetail_NEW 

SELECT LND_UpdateDate, COUNT_BIG(1) RC, MIN(TripDayID) TripDayID_From, MAX(TripDayID) TripDayID_To, MIN(TxnDate) TxnDate_From, MAX(TxnDate) TxnDate_To, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To, MAX(EDW_UpdateDate) EDW_UpdateDate 
FROM dbo.Fact_AdjExpectedAmountDetail_NEW 
GROUP BY LND_UpdateDate
ORDER BY 1

SELECT SourceName, COUNT_BIG(1) RC, MIN(TripDayID) TripDayID_From, MAX(TripDayID) TripDayID_To, MIN(TxnDate) TxnDate_From, MAX(TxnDate) TxnDate_To, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To, MAX(EDW_UpdateDate) EDW_UpdateDate 
FROM dbo.Fact_AdjExpectedAmountDetail_NEW 
GROUP BY SourceName
ORDER BY 1

SELECT TOP 100 * FROM Stage.Bubble_TPTripID
SELECT COUNT(1) Incremental_Load_Trips_Count FROM Stage.Bubble_TPTripID

SELECT * FROM Utility.LoadProcessControl WHERE TableName LIKE 'Fact_AdjExpectedAmountDetail%' ORDER BY 1

--:: Testing

DECLARE @Last_TP_Trips_Date DATETIME2(3), @Last_TP_CustomerTrips_Date DATETIME2(3), @Last_TP_ViolatedTrips_Date DATETIME2(3), @Last_BOS_IOP_OutboundTransactions_Date DATETIME2(3)

EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_Trips', @Last_TP_Trips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_CustomerTrips', @Last_TP_CustomerTrips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_ViolatedTrips', @Last_TP_ViolatedTrips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~BOS_IOP_OutboundTransactions', @Last_BOS_IOP_OutboundTransactions_Date OUTPUT
SELECT 'Before Set_UpdatedDate' SRC, @Last_TP_Trips_Date [@Last_TP_Trips_Date], @Last_TP_CustomerTrips_Date [@Last_TP_CustomerTrips_Date], @Last_TP_ViolatedTrips_Date [@Last_TP_ViolatedTrips_Date], @Last_BOS_IOP_OutboundTransactions_Date [@Last_BOS_IOP_OutboundTransactions_Date], SYSDATETIME() [RunTime]

EXEC EDW_TRIPS_DEV.Utility.Set_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_Trips', NULL, '2022-06-06';
EXEC EDW_TRIPS_DEV.Utility.Set_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_CustomerTrips', NULL, '2022-06-06';
EXEC EDW_TRIPS_DEV.Utility.Set_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_ViolatedTrips', NULL, '2022-06-06';
EXEC EDW_TRIPS_DEV.Utility.Set_UpdatedDate 'Fact_AdjExpectedAmountDetail~BOS_IOP_OutboundTransactions', NULL, '2022-06-06';

--DECLARE @Last_TP_Trips_Date DATETIME2(3), @Last_TP_CustomerTrips_Date DATETIME2(3), @Last_TP_ViolatedTrips_Date DATETIME2(3), @Last_BOS_IOP_OutboundTransactions_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_Trips', @Last_TP_Trips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_CustomerTrips', @Last_TP_CustomerTrips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_ViolatedTrips', @Last_TP_ViolatedTrips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~BOS_IOP_OutboundTransactions', @Last_BOS_IOP_OutboundTransactions_Date OUTPUT
SELECT 'After Set_UpdatedDate' SRC,  @Last_TP_Trips_Date [@Last_TP_Trips_Date], @Last_TP_CustomerTrips_Date [@Last_TP_CustomerTrips_Date], @Last_TP_ViolatedTrips_Date [@Last_TP_ViolatedTrips_Date], @Last_BOS_IOP_OutboundTransactions_Date [@Last_BOS_IOP_OutboundTransactions_Date],  SYSDATETIME() [RunTime]

EXEC dbo.Fact_AdjExpectedAmountDetail_Load 0

EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_Trips', @Last_TP_Trips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_CustomerTrips', @Last_TP_CustomerTrips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~TP_ViolatedTrips', @Last_TP_ViolatedTrips_Date OUTPUT
EXEC Utility.Get_UpdatedDate 'Fact_AdjExpectedAmountDetail~BOS_IOP_OutboundTransactions', @Last_BOS_IOP_OutboundTransactions_Date OUTPUT
SELECT 'After run' SRC, @Last_TP_Trips_Date [@Last_TP_Trips_Date], @Last_TP_CustomerTrips_Date [@Last_TP_CustomerTrips_Date], @Last_TP_ViolatedTrips_Date [@Last_TP_ViolatedTrips_Date], @Last_BOS_IOP_OutboundTransactions_Date [@Last_BOS_IOP_OutboundTransactions_Date],  SYSDATETIME() [RunTime]

SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE 'dbo.Fact_AdjExpectedAmount%' AND LogDate > CONVERT(DATE,SYSDATETIME()) ORDER BY 1 DESC

--===============================================================================================================
-- Incremental load sliding window. Start date for next run.
--===============================================================================================================

SELECT LND_UpdateDate, COUNT(1) TP_Trips FROM LND_TBOS.TollPlus.TP_Trips WHERE LND_UpdateDate > '6/1/2022' GROUP BY LND_UpdateDate ORDER BY 1 DESC
SELECT LND_UpdateDate, COUNT(1) TP_CustomerTrips FROM LND_TBOS.TollPlus.TP_CustomerTrips WHERE LND_UpdateDate > '6/1/2022'  GROUP BY LND_UpdateDate ORDER BY 1 DESC
SELECT LND_UpdateDate, COUNT(1) [CustTrips Adjustment_LineItems] FROM LND_TBOS.Finance.Adjustment_LineItems WHERE LinkSourceName ='TollPlus.TP_CustomerTrips'AND LND_UpdateDate > '6/1/2022' GROUP BY LND_UpdateDate ORDER BY 1 DESC
SELECT LND_UpdateDate, COUNT(1) TP_ViolatedTrips FROM LND_TBOS.TollPlus.TP_ViolatedTrips WHERE LND_UpdateDate > '6/1/2022' GROUP BY LND_UpdateDate ORDER BY 1 DESC
SELECT LND_UpdateDate, COUNT(1) [ViolatedTrips Adjustment_LineItems] FROM LND_TBOS.Finance.Adjustment_LineItems WHERE LinkSourceName ='TollPlus.TP_ViolatedTrips' AND LND_UpdateDate > '6/1/2022' GROUP BY LND_UpdateDate ORDER BY 1 DESC
SELECT LND_UpdateDate, COUNT(1) BOS_IOP_OutboundTransactions FROM LND_TBOS.IOP.BOS_IOP_OutboundTransactions WHERE LND_UpdateDate > '6/1/2022' GROUP BY LND_UpdateDate ORDER BY 1 DESC

SELECT 'TP_Trips' SourceTableName, COUNT(1) Row_Count, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To FROM LND_TBOS.TollPlus.TP_Trips  WHERE LND_UpdateDate > '6/1/2022' AND SourceOfEntry IN (1,3) AND LND_UpdateType <> 'D'			
UNION 
SELECT 'TP_CustomerTrips' SourceTableName, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To FROM LND_TBOS.TollPlus.TP_CustomerTrips WHERE LND_UpdateDate >'6/1/2022' AND SourceOfEntry IN (1,3) AND LND_UpdateType <> 'D'	
UNION
SELECT 'TP_Customer_Trip_Charges_Tracker' SourceTableName, COUNT(1) Row_Count, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To FROM LND_TBOS.TollPlus.TP_Customer_Trip_Charges_Tracker  WHERE LND_UpdateDate > '6/1/2022' AND LND_UpdateType <> 'D'			
UNION 
SELECT'TP_ViolatedTrips' SourceTableName, COUNT(1) Row_Count, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To FROM LND_TBOS.TollPlus.TP_ViolatedTrips WHERE LND_UpdateDate >'6/1/2022' AND SourceOfEntry IN (1,3) AND LND_UpdateType <> 'D' 
UNION
SELECT'TP_Violated_Trip_Charges_Tracker' SourceTableName, COUNT(1) Row_Count, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To FROM LND_TBOS.TollPlus.TP_Violated_Trip_Charges_Tracker WHERE LND_UpdateDate >'6/1/2022' AND LND_UpdateType <> 'D' 
UNION
SELECT'BOS_IOP_OutboundTransactions' SourceTableName, COUNT(1) Row_Count, MIN(LND_UpdateDate) LND_UpdateDate_From, MAX(LND_UpdateDate) LND_UpdateDate_To FROM LND_TBOS.IOP.BOS_IOP_OutboundTransactions WHERE LND_UpdateDate >'6/1/2022' AND LND_UpdateType <> 'D'

--===============================================================================================================
-- !!! Full Load Dynamic SQL!!! 
--===============================================================================================================
IF OBJECT_ID('dbo.Fact_AdjExpectedAmountDetail_NEW','U') IS NOT NULL		DROP TABLE dbo.Fact_AdjExpectedAmountDetail_NEW;
CREATE TABLE dbo.Fact_AdjExpectedAmountDetail_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (20190101,20190201,20190301,20190401,20190501,20190601,20190701,20190801,20190901,20191001,20191101,20191201,20200101,20200201,20200301,20200401,20200501,20200601,20200701,20200801,20200901,20201001,20201101,20201201,20210101,20210201,20210301,20210401,20210501,20210601,20210701,20210801,20210901,20211001,20211101,20211201,20220101,20220201,20220301,20220401,20220501,20220601,20220701,20220801))) AS
WITH CTE_AdjExpectedAmt AS
(
	--:: CustomerTrips
	SELECT	T.TpTripID,
			TC.CustTripID AS CustTripID,
			CAST(NULL AS BIGINT) AS CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'C' AND T.LinkID = TC.CustTripID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST('TP_Customer_Trip_Charges_Tracker' AS VARCHAR(40)) AS SourceName,
			CT.TripChargeID AS SourceID,
			CAST(NULL AS INT) AS TollAdjustmentID,
			CAST(NULL AS VARCHAR(250)) AS AdjustmentReason,
			CT.Amount,
			CT.CreatedDate TxnDate,
			TC.LND_UpdateDate
	FROM	LND_TBOS.TollPlus.TP_Trips T
	JOIN	LND_TBOS.TollPlus.TP_CustomerTrips TC
			ON TC.TpTripID = T.TpTripID
	JOIN	LND_TBOS.TollPlus.TP_Customer_Trip_Charges_Tracker CT
			ON CT.CustTripID = TC.CustTripID
	WHERE 1 = 1
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:33:39.5224488'	
			AND T.LND_UpdateType <> 'D'
			AND TC.LND_UpdateType <> 'D'

	UNION ALL

	--:: CustomerTrip Adjustments
	SELECT	T.TpTripID,
			TC.CustTripID,
			CAST(NULL AS BIGINT) AS CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'C' AND T.LinkID = TC.CustTripID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST('Adjustment_LineItems' AS VARCHAR(40)) SourceName,
			ALI.AdjustmentID,
			A.TollAdjustmentID, -- Key to get Finance.TollAdjustments.AdjustmentType,
			A.AdjustmentReason,
			CASE WHEN A.DrcrFlag = 'C' THEN ALI.Amount*-1 ELSE ALI.Amount END AdjustmentLineItemAmount,
			A.ApprovedStatusDate,
			TC.LND_UpdateDate
	FROM	LND_TBOS.TollPlus.TP_Trips T
	JOIN	LND_TBOS.TollPlus.TP_CustomerTrips TC
			ON TC.TpTripID = T.TpTripID
	JOIN	LND_TBOS.Finance.Adjustment_LineItems ALI
			ON TC.CustTripID = ALI.LinkID
			AND ALI.LinkSourceName = 'TollPlus.TP_CustomerTrips'
	JOIN	LND_TBOS.Finance.Adjustments A
			ON A.AdjustmentID = ALI.AdjustmentID
			AND A.ApprovedStatusID = 466 -- Approved
	WHERE 1 = 1 
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:33:39.5224488'
			AND T.LND_UpdateType <> 'D'
			AND TC.LND_UpdateType <> 'D'
			AND ALI.LND_UpdateType <> 'D'
			AND A.LND_UpdateType <> 'D'

	UNION ALL

	--:: ViolatedTrips
	SELECT	T.TpTripID,
			CAST(NULL AS BIGINT) AS CustTripID,
			TV.CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'V' AND T.LinkID = TV.CitationID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST('TP_Violated_Trip_Charges_Tracker' AS VARCHAR(40)) SourceName,
			VT.TripChargeID,
			CAST(NULL AS INT) AS TollAdjustmentID,
			CAST(NULL AS VARCHAR(250)) AS AdjustmentReason,
			VT.Amount ViolatedTripCharge,
			VT.CreatedDate,
			TV.LND_UpdateDate
	FROM	LND_TBOS.TollPlus.TP_Trips T
	JOIN	LND_TBOS.TollPlus.TP_ViolatedTrips TV
			ON TV.TpTripID = T.TpTripID
	JOIN	LND_TBOS.TollPlus.TP_Violated_Trip_Charges_Tracker VT
			ON VT.CitationID = TV.CitationID
	WHERE 1 = 1
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:33:39.5224488'	
			AND T.LND_UpdateType <> 'D'
			AND TV.LND_UpdateType <> 'D'

	UNION ALL
	
	--:: ViolatedTrip Adjustments
	SELECT	T.TpTripID,
			CAST(NULL AS BIGINT)  AS CustTripID, 
			TV.CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'V' AND T.LinkID = TV.CitationID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST('Adjustment_LineItems' AS VARCHAR(40)) SourceName,
			A.AdjustmentID,
			A.TollAdjustmentID, -- Key to get Finance.TollAdjustments.AdjustmentType,
			A.AdjustmentReason,
			CASE WHEN A.DrcrFlag = 'C' THEN ALI.Amount*-1 ELSE ALI.Amount END AdjustmentLineItemAmount,
			A.ApprovedStatusDate,
			TV.LND_UpdateDate
	FROM	LND_TBOS.TollPlus.TP_Trips T
	JOIN	LND_TBOS.TollPlus.TP_ViolatedTrips TV
			ON TV.TpTripID = T.TpTripID
	JOIN	LND_TBOS.Finance.Adjustment_LineItems ALI
			ON TV.CitationID = ALI.LinkID
			AND ALI.LinkSourceName = 'TollPlus.TP_ViolatedTrips'
	JOIN	LND_TBOS.Finance.Adjustments A
			ON A.AdjustmentID = ALI.AdjustmentID
			AND A.ApprovedStatusID = 466 -- Approved. Add this check.
	WHERE 1 = 1
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:33:39.5224488'
			AND T.LND_UpdateType <> 'D'
			AND TV.LND_UpdateType <> 'D'
			AND ALI.LND_UpdateType <> 'D'
			AND A.LND_UpdateType <> 'D'

	UNION ALL
	
	--:: IOP Outbound Trips without or rarely with Adjustments
	SELECT	T.TpTripID,
			CAST(NULL AS BIGINT) AS CustTripID,
			CAST(NULL AS BIGINT) AS CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'I' THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST(CASE WHEN I.TollAmount IS NOT NULL /*Posted status in IOP table THEN 'BOS_IOP_OutboundTransactions-Paid' ELSE 'BOS_IOP_OutboundTransactions-NotPaid' END AS VARCHAR(40)) AS SourceName,
			T.LinkID AS SourceID,
			CAST(NULL AS INT) AS TollAdjustmentID,
			CAST(NULL AS VARCHAR(250)) AS AdjustmentReason,
			ISNULL(I.TollAmount,T.TollAmount) TollAmount, --> AEA always has value.
			T.PostedDate,
			ISNULL(I.LND_UpdateDate,T.LND_UpdateDate) LND_UpdateDate
						
	FROM	LND_TBOS.TollPlus.TP_Trips T
	LEFT JOIN
			(
					SELECT	TpTripID, SUM(TollAmount) TollAmount, MAX(LND_UpdateDate) LND_UpdateDate
					FROM	LND_TBOS.IOP.BOS_IOP_OutboundTransactions
					WHERE	TransactionStatus = 'Posted' 
						AND ExitTripDateTime >= '2019-01-01'
						AND ExitTripDateTime <  '2022-06-05 19:33:39.5224488'
							AND LND_UpdateType <> 'D'
					GROUP BY TpTripID 
			) I
			ON I.TpTripID = T.TpTripID

	WHERE 1 = 1
			AND T.TripStageID = 31 /*QUALIFY_FOR_IOP*
			AND ISNULL(T.TripWith,'I') = 'I'
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:33:39.5224488'
			AND T.LND_UpdateType <> 'D'
)
SELECT	TpTripID
		, CustTripID
		, CitationID
		, CurrentTxnFlag
		, TripDayID
		, SourceID
		, SourceName
		, TollAdjustmentID -- Key to get Finance.TollAdjustments.AdjustmentType,
		, AdjustmentReason
		, ROW_NUMBER() OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) TxnSeqAsc
		, TxnDate
		, Amount
		, SUM(Amount) OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) RunningTotalAmount

		, SUM(CASE WHEN SourceName = 'Adjustment_LineItems' THEN Amount ELSE 0 END) OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) RunningAllAdjAmount
		, SUM(CASE WHEN SourceName = 'Adjustment_LineItems' AND CurrentTxnFlag = 1 THEN Amount ELSE 0 END) OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) RunningTripWithAdjAmount
		, ROW_NUMBER() OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag DESC, TxnDate DESC) TxnSeqDesc
		, LND_UpdateDate
		, CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
FROM	CTE_AdjExpectedAmt
--ORDER BY TpTripID, TxnSeqAsc
OPTION (LABEL = 'dbo.Fact_AdjExpectedAmountDetail_NEW');
    
CREATE STATISTICS Stats_dbo_Fact_AdjExpectedAmountDetail_001 ON dbo.Fact_AdjExpectedAmountDetail_NEW(TpTripID)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_002 ON dbo.Fact_AdjExpectedAmountDetail_NEW(CustTripID)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_003 ON dbo.Fact_AdjExpectedAmountDetail_NEW(CitationID)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_004 ON dbo.Fact_AdjExpectedAmountDetail_NEW(CurrentTxnFlag)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_005 ON dbo.Fact_AdjExpectedAmountDetail_NEW(SourceName)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_006 ON dbo.Fact_AdjExpectedAmountDetail_NEW(SourceID)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_007 ON dbo.Fact_AdjExpectedAmountDetail_NEW(TxnSeqAsc)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_008 ON dbo.Fact_AdjExpectedAmountDetail_NEW(TxnSeqDesc)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_009 ON dbo.Fact_AdjExpectedAmountDetail_NEW(TpTripID,TxnSeqDesc)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_010 ON dbo.Fact_AdjExpectedAmountDetail_NEW(Amount)
CREATE STATISTICS STATS_dbo_Fact_AdjExpectedAmountDetail_501 ON dbo.Fact_AdjExpectedAmountDetail_NEW(LND_UpdateDate)
			
--===============================================================================================================
-- !!! Incremental Load Dynamic SQL!!! 
--===============================================================================================================
IF OBJECT_ID('dbo.Fact_AdjExpectedAmountDetail_NEW','U') IS NOT NULL		DROP TABLE dbo.Fact_AdjExpectedAmountDetail_NEW;
CREATE TABLE dbo.Fact_AdjExpectedAmountDetail_NEW WITH (CLUSTERED INDEX ([TPTripID]), DISTRIBUTION = HASH(TPTripID)) AS
WITH CTE_AdjExpectedAmt AS
(
	--:: CustomerTrips
	SELECT	T.TpTripID,
			TC.CustTripID AS CustTripID,
			CAST(NULL AS BIGINT) AS CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'C' AND T.LinkID = TC.CustTripID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST('TP_Customer_Trip_Charges_Tracker' AS VARCHAR(40)) AS SourceName,
			CT.TripChargeID AS SourceID,
			CAST(NULL AS INT) AS TollAdjustmentID,
			CAST(NULL AS VARCHAR(250)) AS AdjustmentReason,
			CT.Amount,
			CT.CreatedDate TxnDate,
			TC.LND_UpdateDate
	FROM	LND_TBOS.TollPlus.TP_Trips T
	JOIN	LND_TBOS.TollPlus.TP_CustomerTrips TC
			ON TC.TpTripID = T.TpTripID
	JOIN	LND_TBOS.TollPlus.TP_Customer_Trip_Charges_Tracker CT
			ON CT.CustTripID = TC.CustTripID
	WHERE   EXISTS (SELECT 1 FROM Stage.Bubble_TPTripID TT WHERE TT.TPTripID = T.TPTripID)
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:27:04.9869916'	
			AND T.LND_UpdateType <> 'D'
			AND TC.LND_UpdateType <> 'D'

	UNION ALL

	--:: CustomerTrip Adjustments
	SELECT	T.TpTripID,
			TC.CustTripID,
			CAST(NULL AS BIGINT) AS CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'C' AND T.LinkID = TC.CustTripID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST('Adjustment_LineItems' AS VARCHAR(40)) SourceName,
			ALI.AdjustmentID,
			A.TollAdjustmentID, -- Key to get Finance.TollAdjustments.AdjustmentType,
			A.AdjustmentReason,
			CASE WHEN A.DrcrFlag = 'C' THEN ALI.Amount*-1 ELSE ALI.Amount END AdjustmentLineItemAmount,
			A.ApprovedStatusDate,
			TC.LND_UpdateDate
	FROM	LND_TBOS.TollPlus.TP_Trips T
	JOIN	LND_TBOS.TollPlus.TP_CustomerTrips TC
			ON TC.TpTripID = T.TpTripID
	JOIN	LND_TBOS.Finance.Adjustment_LineItems ALI
			ON TC.CustTripID = ALI.LinkID
			AND ALI.LinkSourceName = 'TollPlus.TP_CustomerTrips'
	JOIN	LND_TBOS.Finance.Adjustments A
			ON A.AdjustmentID = ALI.AdjustmentID
			AND A.ApprovedStatusID = 466 -- Approved
	WHERE   EXISTS (SELECT 1 FROM Stage.Bubble_TPTripID TT WHERE TT.TPTripID = T.TPTripID) 
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:27:04.9869916'
			AND T.LND_UpdateType <> 'D'
			AND TC.LND_UpdateType <> 'D'
			AND ALI.LND_UpdateType <> 'D'
			AND A.LND_UpdateType <> 'D'

	UNION ALL

	--:: ViolatedTrips
	SELECT	T.TpTripID,
			CAST(NULL AS BIGINT) AS CustTripID,
			TV.CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'V' AND T.LinkID = TV.CitationID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST('TP_Violated_Trip_Charges_Tracker' AS VARCHAR(40)) SourceName,
			VT.TripChargeID,
			CAST(NULL AS INT) AS TollAdjustmentID,
			CAST(NULL AS VARCHAR(250)) AS AdjustmentReason,
			VT.Amount ViolatedTripCharge,
			VT.CreatedDate,
			TV.LND_UpdateDate
	FROM	LND_TBOS.TollPlus.TP_Trips T
	JOIN	LND_TBOS.TollPlus.TP_ViolatedTrips TV
			ON TV.TpTripID = T.TpTripID
	JOIN	LND_TBOS.TollPlus.TP_Violated_Trip_Charges_Tracker VT
			ON VT.CitationID = TV.CitationID
	WHERE   EXISTS (SELECT 1 FROM Stage.Bubble_TPTripID TT WHERE TT.TPTripID = T.TPTripID)
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:27:04.9869916'	
			AND T.LND_UpdateType <> 'D'
			AND TV.LND_UpdateType <> 'D'

	UNION ALL
	
	--:: ViolatedTrip Adjustments
	SELECT	T.TpTripID,
			CAST(NULL AS BIGINT)  AS CustTripID, 
			TV.CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'V' AND T.LinkID = TV.CitationID THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST('Adjustment_LineItems' AS VARCHAR(40)) SourceName,
			A.AdjustmentID,
			A.TollAdjustmentID, -- Key to get Finance.TollAdjustments.AdjustmentType,
			A.AdjustmentReason,
			CASE WHEN A.DrcrFlag = 'C' THEN ALI.Amount*-1 ELSE ALI.Amount END AdjustmentLineItemAmount,
			A.ApprovedStatusDate,
			TV.LND_UpdateDate
	FROM	LND_TBOS.TollPlus.TP_Trips T
	JOIN	LND_TBOS.TollPlus.TP_ViolatedTrips TV
			ON TV.TpTripID = T.TpTripID
	JOIN	LND_TBOS.Finance.Adjustment_LineItems ALI
			ON TV.CitationID = ALI.LinkID
			AND ALI.LinkSourceName = 'TollPlus.TP_ViolatedTrips'
	JOIN	LND_TBOS.Finance.Adjustments A
			ON A.AdjustmentID = ALI.AdjustmentID
			AND A.ApprovedStatusID = 466 -- Approved. Add this check.
	WHERE   EXISTS (SELECT 1 FROM Stage.Bubble_TPTripID TT WHERE TT.TPTripID = T.TPTripID)
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:27:04.9869916'
			AND T.LND_UpdateType <> 'D'
			AND TV.LND_UpdateType <> 'D'
			AND ALI.LND_UpdateType <> 'D'
			AND A.LND_UpdateType <> 'D'

	UNION ALL
	
	--:: IOP Outbound Trips without or rarely with Adjustments
	SELECT	T.TpTripID,
			CAST(NULL AS BIGINT) AS CustTripID,
			CAST(NULL AS BIGINT) AS CitationID,
			CAST(CONVERT(VARCHAR,T.ExitTripDateTime,112) AS INT) TripDayID,
			CAST(CASE WHEN T.TripWith = 'I' THEN 1 ELSE 0 END AS BIT) AS CurrentTxnFlag,
			CAST(CASE WHEN I.TollAmount IS NOT NULL /*Posted status in IOP table THEN 'BOS_IOP_OutboundTransactions-Paid' ELSE 'BOS_IOP_OutboundTransactions-NotPaid' END AS VARCHAR(40)) AS SourceName,
			T.LinkID AS SourceID,
			CAST(NULL AS INT) AS TollAdjustmentID,
			CAST(NULL AS VARCHAR(250)) AS AdjustmentReason,
			ISNULL(I.TollAmount,T.TollAmount) TollAmount, --> AEA always has value.
			T.PostedDate,
			ISNULL(I.LND_UpdateDate,T.LND_UpdateDate) LND_UpdateDate
						
	FROM	LND_TBOS.TollPlus.TP_Trips T
	LEFT JOIN
			(
					SELECT	TpTripID, SUM(TollAmount) TollAmount, MAX(LND_UpdateDate) LND_UpdateDate
					FROM	LND_TBOS.IOP.BOS_IOP_OutboundTransactions
					WHERE	TransactionStatus = 'Posted' 
						AND ExitTripDateTime >= '2019-01-01'
						AND ExitTripDateTime <  '2022-06-05 19:27:04.9869916'
							AND LND_UpdateType <> 'D'
					GROUP BY TpTripID 
			) I
			ON I.TpTripID = T.TpTripID

	WHERE   EXISTS (SELECT 1 FROM Stage.Bubble_TPTripID TT WHERE TT.TPTripID = T.TPTripID)
			AND T.TripStageID = 31 /*QUALIFY_FOR_IOP*--
			AND ISNULL(T.TripWith,'I') = 'I'
			AND T.SourceOfEntry IN (1,3) -- TSA & NTTA 
			AND T.Exit_TollTxnID >= 0
			AND T.ExitTripDateTime >= '2019-01-01'
			AND T.ExitTripDateTime <  '2022-06-05 19:27:04.9869916'
			AND T.LND_UpdateType <> 'D'
)
SELECT	TpTripID
		, CustTripID
		, CitationID
		, CurrentTxnFlag
		, TripDayID
		, SourceID
		, SourceName
		, TollAdjustmentID -- Key to get Finance.TollAdjustments.AdjustmentType,
		, AdjustmentReason
		, ROW_NUMBER() OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) TxnSeqAsc
		, TxnDate
		, Amount
		, SUM(Amount) OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) RunningTotalAmount

		, SUM(CASE WHEN SourceName = 'Adjustment_LineItems' THEN Amount ELSE 0 END) OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) RunningAllAdjAmount
		, SUM(CASE WHEN SourceName = 'Adjustment_LineItems' AND CurrentTxnFlag = 1 THEN Amount ELSE 0 END) OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag, TxnDate) RunningTripWithAdjAmount
		, ROW_NUMBER() OVER (PARTITION BY TpTripID ORDER BY CurrentTxnFlag DESC, TxnDate DESC) TxnSeqDesc
		, LND_UpdateDate
		, CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
FROM	CTE_AdjExpectedAmt
--ORDER BY TpTripID, TxnSeqAsc

OPTION (LABEL = 'dbo.Fact_AdjExpectedAmountDetail_NEW');



*/	

  END;