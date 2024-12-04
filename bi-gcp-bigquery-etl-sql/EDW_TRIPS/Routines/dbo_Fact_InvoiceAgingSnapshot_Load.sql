CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_InvoiceAgingSnapshot_Load`(load_start_date DATE)
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_InvoiceAgingSnapshot table by snapshotdate 
If table does not exist, creates table; otherwise load to stage table and switch partitions
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Gouthami, Andy	2020-11-02	New!
CHG0038039	Gouthami, Andy  2021-01-27  1. Created a new utility SP for Partition Switch as the citations were not 
										   updating when there are any changes in the source.
										2. Added Delete Flag
CHG0038304  Gouthami	    2021-02-26	1. Added WriteOffFlag, WriteOffAmount, WriteOffDate, FNFeesOutstandingAmount and 
										   SNFeesOutstandingAmount columns
										2. Removed group by for Fact_InvoiceDetail, and Fact_Violation
										3. Removed some columns which are not used by MSTR
CHG0040511  Gouthami		2022-02-25	Removed the columns(TotalTransactions,FNFeeDate,SNFeedate,TotalTxn) that are not used by MSTR.										

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------

Declare @Load_Start_Date [DATE] = CAST(GETDATE() AS DATE)
Exec dbo.Fact_InvoiceAgingSnapshot_Load  @Load_Start_Date 

EXEC Utility.FromLog 'dbo.Fact_InvoiceDetail', 1
SELECT COUNT_BIG(1) AS CNT FROM Fact_InvoiceAgingSnapshot  -- 117 100 991
SELECT 'dbo.Fact_InvoiceAgingSnapshot' TableName, * FROM dbo.Fact_InvoiceAgingSnapshot ORDER BY 2 DESC 
SELECT SnapshotDate,COUNT(*) FROM dbo.Fact_InvoiceAgingSnapshot GROUP BY SnapshotDate

###################################################################################################################
*/
    --Debug
	  --DECLARE @Load_Start_Date [DATE] = CAST(GETDATE() AS DATE)	
    DECLARE main_table_name STRING DEFAULT 'EDW_TRIPS.Fact_InvoiceAgingSnapshot';
    DECLARE stagetablename STRING DEFAULT 'EDW_TRIPS.Fact_InvoiceAgingSnapshot_NEW';
    DECLARE sql1 STRING;
    DECLARE sql2 STRING;
    DECLARE sqlresult STRING;
    DECLARE sql STRING;
    DECLARE sql3 STRING;
    DECLARE partitiondate DATE;
    DECLARE partitionmonthid INT64;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_InvoiceAgingSnapshot_Load';
    DECLARE log_start_date DATETIME;
    DECLARE lastpartitionid INT64;
    DECLARE partition_ranges STRING;
    SET log_start_date = current_datetime('America/Chicago');
    SET partitiondate = CASE WHEN extract(DAY from load_start_date) = 1 THEN date_sub(date_trunc(load_start_date,month),interval 1 day) ELSE date_sub(load_start_date, interval 1 DAY) END;
    SET partitionmonthid = CAST(substr(CAST(partitiondate AS STRING FORMAT 'yyyymmdd'),1,6) AS INT64);
    SET log_message = concat('Started load for partition ', substr(CAST(partitiondate as STRING), 1, 10));
    IF trace_flag = 1 THEN
      --SELECT log_message;
    END IF;

    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
    --=============================================================================================================
    -- Load dbo.Fact_InvoiceAging         
    --=============================================================================================================
    
    SET lastpartitionid = cast(substr(CAST(date_add(last_day(date_add(log_start_date,interval 1 month)),interval 1 day) AS STRING FORMAT 'yyyymmdd' ),1,6) as int64);
    IF trace_flag = 1 THEN 
        --SELECT 'Calling: Utility.Get_PartitionMonthIDRange_String from 202001 till ' + SUBSTR(CAST(lastpartitionid AS STRING),1,10);
    END IF;
    --CALL utility.get_partitionmonthidrange_string(substr(CAST(202001 as STRING), 1, 10), substr(CAST(lastpartitionid as STRING), 1, 10), partition_ranges);

    IF (SELECT count(1) FROM  EDW_TRIPS.INFORMATION_SCHEMA.TABLES WHERE table_name=SUBSTR(main_table_name,STRPOS(main_table_name,'.')+1)) =0 THEN
      SET stagetablename = main_table_name;
    END IF;

    
    set sql1 = CONCAT("SELECT  CAST(", "'",partitiondate,"' AS DATE) AS snapshotdate,coalesce(CAST('",partitionmonthid, "' as INT64), 0) AS snapshotmonthid, coalesce(invdet.citationid, 0) AS citationid, CAST(invdet.customerid as INT64) AS customerid, CAST(invdet.agestageid as INT64) AS agestageid, -1 AS citationstageid, coalesce(CAST(invdet.laneid as INT64), 0) AS laneid, coalesce(CAST(invdet.tptripid as INT64), 0) AS tptripid, CAST(invdet.invoicenumber as INT64) AS invoicenumber, coalesce(CAST(invdet.currentinvflag as INT64), 0) AS currentinvoiceflag, coalesce(CAST(invdet.writeoffflag as INT64), 0) AS writeoffflag, coalesce(invdet.deleteflag, 0) AS deleteflag, CAST(invdet.txndate as DATE) AS transactiondate, CAST(invdet.zcinvoicedate as DATE) AS invoicedate, CAST(invdet.posteddate as DATE) AS posteddate, CAST(invdet.fnfeesdate as DATE) AS firstnoticefeedate, CAST(invdet.snfeesdate as DATE) AS secondnoticefeedate, CAST(invdet.writeoffdate as DATE) AS writeoffdate, CAST(invdet.tolls as NUMERIC) AS tollsdue, CAST(invdet.fnfees as BIGNUMERIC) AS firstnoticefees, CAST(invdet.snfees as BIGNUMERIC) AS secondnoticefees, CAST(invdet.outstandingamount as NUMERIC) AS outstandingamount, CAST(invdet.fnfeesoutstandingamount as BIGNUMERIC) AS fnfeesoutstandingamount, CAST(invdet.snfeesoutstandingamount as BIGNUMERIC) AS snfeesoutstandingamount, CAST(invdet.writeoffamount as NUMERIC) AS writeoffamount, CAST(invdet.txndate as DATE) AS txndate, coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_updatedate FROM EDW_TRIPS.Fact_InvoiceDetail AS invdet WHERE (invdet.outstandingamount > 0 OR invdet.fnfeesoutstandingamount > 0 OR invdet.snfeesoutstandingamount > 0) AND CAST(invdet.txndate as DATE) < DATE '",load_start_date,"'AND invdet.deleteflag = 0");

    SET sql2 = CONCAT("SELECT CAST('",partitiondate,"' AS DATE) AS snapshotdate,coalesce(CAST('",partitionmonthid,"' as INT64), 0) AS snapshotmonthid, coalesce(v.citationid, 0) AS citationid, CAST(v.customerid as INT64) AS customerid, -1 AS agestageid, CAST(v.citationstageid as INT64) AS citationstageid, coalesce(CAST(v.laneid as INT64), 0) AS laneid, coalesce(CAST(v.tptripid as INT64), 0) AS tptripid, -1 AS invoicenumber, NULL AS currentinvoiceflag, coalesce(CAST(v.writeoffflag as INT64), 0) AS writeoffflag, coalesce(CAST(v.deleteflag as INT64), 0) AS deleteflag, CAST(v.transactiondate as DATE) AS transactiondate, '1900-01-01' AS invoicedate, CAST(v.posteddate as DATE) AS posteddate, '1900-01-01' AS firstnoticefeedate, '1900-01-01' AS secondnoticefeedate, CAST(v.writeoffdate as DATE) AS writeoffdate, CAST(v.tollamount as NUMERIC) AS tollsdue, 0 AS firstnoticefees, 0 AS secondnoticefees, CAST(v.outstandingamount as NUMERIC) AS outstandingamount, 0 AS fnfeesoutstandingamount, 0 AS snfeesoutstandingamount, CAST(v.writeoffamount as NUMERIC) AS writeoffamount, CAST(v.transactiondate as DATE) AS txndate, coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_updatedate FROM edw_trips.fact_violation AS v WHERE v.outstandingamount > 0 AND v.citationstageid = 0 AND CAST(v.transactiondate as DATE) < DATE '",load_start_date,"'AND v.deleteflag = 0");

    set sqlresult =  Concat(sql1," UNION ALL ", sql2);
    -- SET sql3 = CONCAT("DROP TABLE IF EXISTS ",stagetablename,";");
    SET sql = CONCAT("CREATE OR REPLACE TABLE ",stagetablename," cluster by CitationId AS(",sqlresult,");");
    --EXECUTE IMMEDIATE sql3;
    EXECUTE IMMEDIATE sql;

    -- Log 
    SET log_message='Loaded dbo.Fact_InvoiceAgingSnapshot_NEW';
    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, sql);

    IF stagetablename = main_table_name THEN
    ELSE
      IF trace_flag = 1 THEN
        --SELECT 'Calling: Utility.ManagePartitions_DateID';
      END IF;
      --CALL utility.managepartitions_dateid(main_table_name, 'MonthID:Month');
      IF trace_flag = 1 THEN
        --SELECT 'Calling: Utility.PartitionSwitch_Snapshot';
      END IF;
      --CALL utility.partitionswitch_snapshot('EDW_TRIPS.Fact_InvoiceAgingSnapshot_NEW', main_table_name);
      -- commented PartitionSwitch_Snapshot and implemented this logic using DELETE and INSERT STATEMENTS below
      -- Dropping Records From Main Table having common snapshotmonthid values with Stage Table.
      SET sql3 = concat("Delete From ", main_table_name , " where snapshotmonthid In ( Select snapshotmonthid from ",stagetablename , " )" );
      EXECUTE IMMEDIATE sql3;
      
      -- Inserting NEW Records from Stage to Main Table
      SET sql3 = concat("Insert Into  ", main_table_name , " Select * from ",stagetablename );
      EXECUTE IMMEDIATE sql3;
      SET sql3=concat("DROP TABLE IF EXISTS ", stagetablename);
      EXECUTE IMMEDIATE sql3;
    END IF;

    SET log_message = concat('Finished load for partition ', substr(CAST(partitiondate as STRING), 1, 10));
    IF trace_flag = 1 THEN
      --SELECT log_message;
    END IF;
    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
    IF trace_flag = 1 THEN
      SELECT
          'EDW_TRIPS.Fact_InvoiceAgingSnapshot' AS tablename,
          fact_invoiceagingsnapshot.*
        FROM
         EDW_TRIPS.Fact_InvoiceAgingSnapshot
      ORDER BY  2 DESC LIMIT 100
       
      ;
    END IF;

/*

--:: Testing Zone

EXEC dbo.Fact_InvoiceAgingSnapshot

--:: Quick check
SELECT count(*) FROM EDW_TBOS_DEV.dbo.Fact_InvoiceAgingSnapshot ORDER BY 1
SELECT count(*),SnapshotDate FROM EDW_TBOS_DEV.dbo.Fact_InvoiceAgingSnapshot group by SnapshotDate ORDER BY 1

select * from  dbo.Fact_InvoiceAgingSnapshot

delete  from  dbo.Fact_InvoiceAgingSnapshot where snapshotdate='2020-11-23'


*/
END;