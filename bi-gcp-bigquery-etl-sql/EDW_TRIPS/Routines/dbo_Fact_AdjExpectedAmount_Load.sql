CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_AdjExpectedAmount_Load`(isfullload INT64)

BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_AdjExpectedAmount from dbo.Fact_AdjExpectedAmountDetail tables for Board Reporting. This proc is 
called from dbo.Fact_AdjExpectedAmountDetail_Load and it requires dbo.Fact_AdjExpectedAmountDetail_NEW for incr load.
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040744	Shankar		2022-03-21	New!
CHG0041406  Shekhar     2022-08-22  New Column ClassAdjustmentFlag
									This column will allow us to identify the type of adjustment for a transaction.
									As of today, the downstream programs are using this column to identify if a
									transcation has a Class adjustment or now. The value of 1 in this column means
									the transcation has a class related adjustment. 
CHG0042644	Shankar		2023-03-01	Incremental load cleanup of invalid data in existing table
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_AdjExpectedAmount_Load 1
SELECT * FROM Utility.ProcessLog WHERE LogSource = 'dbo.Fact_AdjExpectedAmount_Load' ORDER BY 1 DESC
SELECT TOP 100 'dbo.Fact_AdjExpectedAmount' Table_Name, * FROM dbo.Fact_AdjExpectedAmount ORDER BY LND_UpdateDate DESC
###################################################################################################################
*/
    DECLARE tablename STRING DEFAULT 'EDW_TRIPS.Fact_AdjExpectedAmount';
    DECLARE trace_flag INT64 DEFAULT 0; -- Testing
    DECLARE firstpartitionid INT64 DEFAULT 201901;
    DECLARE lastpartitionid INT64;
    DECLARE partition_ranges STRING;
    DECLARE createtablewith STRING;
    DECLARE log_message STRING;
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_AdjExpectedAmount_Load';
    DECLARE log_start_date DATETIME;
    DECLARE identifyingcolumns STRING DEFAULT 'TPTripID';
    DECLARE stagetablename STRING DEFAULT 'EDW_TRIPS.Fact_AdjExpectedAmount_NEW';
    DECLARE sql STRING;
    Declare SourceTable STRING;
    BEGIN
      DECLARE last_updated_date DATETIME;
      SET log_start_date = current_datetime('America/Chicago');
      BEGIN
        DECLARE firstdatetoload STRING DEFAULT '2019-01-01';
        DECLARE lastdatetoload STRING DEFAULT cast(current_datetime('America/Chicago') as STRING);
      END;
      SET lastpartitionid = CAST(SUBSTR(CAST(DATE_ADD(LAST_DAY(DATE_ADD(CURRENT_DATE, INTERVAL 1 MONTH)),INTERVAL 1 DAY) AS STRING FORMAT 'YYYYMMDD'),1,6) AS INT64);

      IF (SELECT count(1) FROM  EDW_TRIPS.INFORMATION_SCHEMA.TABLES WHERE table_name=SUBSTR(tablename,STRPOS(tablename,'.')+1)) =0 OR (SELECT count(1) FROM EDW_TRIPS.INFORMATION_SCHEMA.TABLES where table_name='Fact_AdjExpectedAmountDetail_NEW')=0 THEN
        SET isfullload = 1;
      END IF;
      IF isfullload = 1 THEN
        -- Commenting these Partition Utility Sp's , Not Required in BQ
        --CALL EDW_TRIPS_utility.Get_PartitionDayIDRange_String(substr(CAST(firstpartitionid as STRING), 1, 10), substr(CAST(lastpartitionid as STRING), 1, 10), partition_ranges);
        --SET createtablewith = concat('(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (', partition_ranges, ')))');
        SET createtablewith = concat(' cluster by ',identifyingcolumns);
        SET log_message = 'Started full load';
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
        IF trace_flag = 1 THEN
          select log_message;
        END IF;
      ELSE
        --SET createtablewith = concat('(CLUSTERED INDEX (', identifyingcolumns, '), DISTRIBUTION = HASH(TPTripID))');
        SET createtablewith = concat(' cluster by ',identifyingcolumns);
        SET log_message = 'Started incremental load';
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
        IF trace_flag = 1 THEN
          select log_message;
        END IF;
      END IF;
      --=============================================================================================================
      -- Load dbo.Fact_AdjExpectedAmount
      --============================================================================================================
      -- for isfulload = 0 we are incrementally loading into EDW_TRIPS.Fact_AdjExpectedAmountDetail_NEW table else into the EDW_TRIPS.Fact_AdjExpectedAmountDetail table
      if coalesce(isfullload,1)=0 then
        set SourceTable = "EDW_TRIPS.Fact_AdjExpectedAmountDetail_NEW";
      else  
        set SourceTable = "EDW_TRIPS.Fact_AdjExpectedAmountDetail";
      end IF;

      SET sql="CREATE OR REPLACE TABLE "||stagetablename||" "||createtablewith||"  AS     SELECT         fact_adjexpectedamountdetail.tptripid,         fact_adjexpectedamountdetail.tripdayid,         max(CASE           WHEN fact_adjexpectedamountdetail.tolladjustmentid = 1 THEN 1           ELSE 0         END) AS classadjustmentflag,         CAST(sum(fact_adjexpectedamountdetail.amount) as NUMERIC) AS adjustedexpectedamount,         CAST(sum(CASE           WHEN fact_adjexpectedamountdetail.currenttxnflag = 1            AND fact_adjexpectedamountdetail.sourcename = \'Adjustment_LineItems\' THEN fact_adjexpectedamountdetail.amount         END) as NUMERIC) AS tripwithadjustedamount,         CAST(sum(CASE           WHEN fact_adjexpectedamountdetail.sourcename = \'Adjustment_LineItems\' THEN fact_adjexpectedamountdetail.amount         END) as NUMERIC) AS alladjustedamount,         CAST(sum(CASE           WHEN fact_adjexpectedamountdetail.custtripid IS NOT NULL            AND fact_adjexpectedamountdetail.sourcename = \'Adjustment_LineItems\' THEN fact_adjexpectedamountdetail.amount         END) as NUMERIC) AS allcusttripadjustedamount,         CAST(sum(CASE           WHEN fact_adjexpectedamountdetail.citationid IS NOT NULL            AND fact_adjexpectedamountdetail.sourcename = \'Adjustment_LineItems\' THEN fact_adjexpectedamountdetail.amount         END) as NUMERIC) AS allviolatedtripadjustedamount,         CAST(sum(CASE           WHEN fact_adjexpectedamountdetail.sourcename = \'BOS_IOP_OutboundTransactions-Paid\' THEN fact_adjexpectedamountdetail.amount           ELSE 0         END) as NUMERIC) AS iop_outboundpaidamount,         current_datetime() AS edw_updatedate       FROM  "|| SourceTable ||" Fact_AdjExpectedAmountDetail GROUP BY fact_adjexpectedamountdetail.tptripid,fact_adjexpectedamountdetail.tripdayid";
      IF trace_flag = 1 THEN
        Select sql;
      END IF;
      EXECUTE IMMEDIATE sql; 
      -- Log 
      SET log_message = concat('Loaded ', tablename);
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, sql);
      IF isfullload = 1 THEN
        create or replace table EDW_TRIPS.Fact_AdjExpectedAmount as(
          select * from EDW_TRIPS.Fact_AdjExpectedAmount_NEW
        ) ;
        -- Table swap!
        -- The table swap stored procedure is not needed, as BigQuery handles this with the CREATE OR REPLACE statement.
        -- CALL EDW_TRIPS_utility.TableSwap(stagetablename, tablename);
        SET log_message = 'Completed full load';
      ELSE
        DELETE FROM EDW_TRIPS.Fact_AdjExpectedAmount WHERE Fact_AdjExpectedAmount.tptripid IN(
          SELECT
              tptripid
            FROM
              EDW_TRIPS.Fact_AdjExpectedAmountDetail_DEL
        );
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Deleted TpTripID rows not qualified for full load from dbo.Fact_AdjExpectedAmount using Temp.Fact_AdjExpectedAmountDetail_DEL', 'I', CAST(NULL as INT64), substr(CAST(-1 as STRING), 1, 2147483647));
        IF trace_flag = 1 THEN
          select log_source, log_start_date, 'Deleted TpTripID rows not qualified for full load from dbo.Fact_AdjExpectedAmount using EDW_TRIPS.Fact_AdjExpectedAmountDetail_DEL';
        END IF;
        -- Commenting these Partition Utility Sp's , Not Required in BQ
        -- CALL EDW_TRIPS_utility.ManagePartitions_DateID(tablename, 'DayID:Month');
        -- Commenting partitionswitch_range , replaced with delete & Insert
        -- CALL EDW_TRIPS_utility.PartitionSwitch_Range(stagetablename, tablename, identifyingcolumns, CAST(NULL as STRING));
        -- Dropping Records From Main Table To Avoid Duplicates
		    SET sql = concat("Delete From ", tablename , " where ", identifyingcolumns ," In ( Select ", identifyingcolumns , " from ",stagetablename , " )" );
		    EXECUTE IMMEDIATE sql;
		    -- Inserting NEW Records from Stage to Main Table
		    SET sql = concat("Insert Into  ", tablename , " Select * from ",stagetablename );
		    EXECUTE IMMEDIATE sql;
        SET log_message = 'Completed Incremental load';
      END IF;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      IF trace_flag = 1 THEN
        select log_message;
        SELECT 'EDW_TRIPS.Fact_AdjExpectedAmount' AS tablename, Fact_AdjExpectedAmount.*
          FROM EDW_TRIPS.Fact_AdjExpectedAmount
        ORDER BY Fact_AdjExpectedAmount.edw_updatedate DESC
        LIMIT 100;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = error_message;
      END;
    END;
    /*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================
EXEC dbo.Fact_AdjExpectedAmount_Load 1
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE 'dbo.Fact_AdjExpectedAmount%' ORDER BY 1 DESC  
SELECT TOP 100 'dbo.Fact_AdjExpectedAmount' TableName, * FROM dbo.Fact_AdjExpectedAmount ORDER BY 2
SELECT EDW_UpdateDate, COUNT_BIG(1) RC FROM dbo.Fact_AdjExpectedAmount GROUP BY EDW_UpdateDate ORDER BY 1 DESC

SELECT COUNT_BIG(1) RC FROM dbo.Fact_AdjExpectedAmount_NEW 
SELECT COUNT_BIG(1) RC FROM dbo.Fact_AdjExpectedAmount 

--:: Testing
EXEC dbo.Fact_AdjExpectedAmount_Load 1

EXEC Utility.FromLog 'dbo.Fact_AdjExpectedAmount', 1

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_AdjExpectedAmount', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  

EXEC Utility.Set_UpdatedDate 'dbo.Fact_AdjExpectedAmount', NULL, '2022-03-04'

EXEC dbo.Fact_AdjExpectedAmount_Load 0

EXEC Utility.FromLog 'dbo.Fact_AdjExpectedAmount', 3

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_AdjExpectedAmount', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  

--===============================================================================================================
-- !!! Dynamic SQL!!! 
--===============================================================================================================
IF OBJECT_ID('dbo.Fact_AdjExpectedAmount_NEW','U') IS NOT NULL		DROP TABLE dbo.Fact_AdjExpectedAmount_NEW;
CREATE TABLE dbo.Fact_AdjExpectedAmount_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (20190101,20190201,20190301,20190401,20190501,20190601,20190701,20190801,20190901,20191001,20191101,20191201,20200101,20200201,20200301,20200401,20200501,20200601,20200701,20200801,20200901,20201001,20201101,20201201,20210101,20210201,20210301,20210401,20210501,20210601,20210701,20210801,20210901,20211001,20211101,20211201,20220101,20220201,20220301,20220401,20220501,20220601,20220701,20220801,20220901,20221001))) AS
SELECT TPTripID
		, TripDayID
		, CAST(MAX(CASE when TollAdjustmentID = 1 then 1 else 0 END) AS smallint) ClassAdjustmentFlag --We are only interested ClassAdjustments, which has a TollAdjustmentID of 1 	
		, CAST(SUM(Amount) AS DECIMAL(19,2)) AdjustedExpectedAmount
		, CAST(SUM(CASE WHEN CurrentTxnFlag = 1 AND SourceName = 'Adjustment_LineItems' THEN Amount END) AS decimal(19,2)) TripWithAdjustedAmount
		, CAST(SUM(CASE WHEN SourceName = 'Adjustment_LineItems' THEN Amount END) AS decimal(19,2)) AllAdjustedAmount
		, CAST(SUM(CASE WHEN CustTripID IS NOT NULL AND SourceName = 'Adjustment_LineItems' THEN Amount END) AS decimal(19,2)) AllCustTripAdjustedAmount 
		, CAST(SUM(CASE WHEN CitationID IS NOT NULL AND SourceName = 'Adjustment_LineItems' THEN Amount END) AS decimal(19,2)) AllViolatedTripAdjustedAmount
		, CAST(SUM(CASE WHEN SourceName = 'BOS_IOP_OutboundTransactions-Paid' THEN Amount ELSE 0 END) AS decimal(19,2)) IOP_OutboundPaidAmount -- default must be 0, not null
		, CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
FROM dbo.Fact_AdjExpectedAmountDetail -- <== Following on the tail of Full or Incremental Load of dbo.Fact_AdjExpectedAmountDetail 
GROUP BY TPTripID, TripDayID
OPTION (LABEL = 'dbo.Fact_AdjExpectedAmount_NEW');


*/	

  END;