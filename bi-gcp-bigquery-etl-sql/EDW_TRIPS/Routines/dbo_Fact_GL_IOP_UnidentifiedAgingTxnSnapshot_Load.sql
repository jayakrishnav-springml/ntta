CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_Load`(load_start_date DATE)
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_Load table by snapshotmonthid 
If table does not exist, creates table; otherwise load to stage table and switch.

This proc is used to identify all the GL_IOP unidentifiedAging Customers. Customers who travel on our roads
having tolltag from different Agencies, We identify the list of customers and sent it to Agency.
At any time, A customer should have both debit and credit record for a txn. If any one of them is missing, then we assign it to a default customerid
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040294	Sagarika Chukka 	2022-12-06	New!
CHG0040527	Sagarika Chukka 	2022-03-02	Modify the DaycountID column based on PartionDate rather then getdate() to calculate the Day differences from PostingDate to PartionDate

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
Exec dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_Load '2022-01-21' 

EXEC Utility.FromLog 'dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_Load', 1
SELECT COUNT_BIG(1) AS CNT FROM dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_Load 
select sum(TxnAmount),snapshotmonthid  FROM dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot
group by snapshotmonthid

select * from Utility.ProcessLog order by 1 desc
###################################################################################################################
*/
    --Debug
	  --DECLARE load_start_date DATE DEFAULT DATE(current_datetime());	
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_Load';
    DECLARE log_start_date DATETIME;
    DECLARE lastpartitionid INT64;
    DECLARE partition_ranges STRING;
    BEGIN
      DECLARE main_table_name STRING DEFAULT 'EDW_TRIPS.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot';
      DECLARE stagetablename STRING DEFAULT 'EDW_TRIPS.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_NEW';
      DECLARE sql1 STRING;
      DECLARE sql2 STRING;
      DECLARE sql3 STRING;
      DECLARE sqlresult STRING;
      DECLARE sql STRING;
      DECLARE partitiondate DATE;
      DECLARE partitionmonthid INT64;
      SET log_start_date = current_datetime('America/Chicago');
      SET partitiondate = date_sub(load_start_date, interval 1 DAY);
      SET partitionmonthid = CAST(substr(CAST(partitiondate as STRING FORMAT "YYYYMMDD"), 1, 6) as INT64);
      SET log_message = concat('Started load for partition ', substr(CAST(partitiondate as STRING), 1, 10));
      IF trace_flag = 1 THEN
    		--SELECT log_message;
      END IF;
      
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
	  
      --=============================================================================================================
      -- Load dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot         
      --=============================================================================================================
   
	  
      SET lastpartitionid =  CAST(SUBSTR(CAST(DATE_ADD(LAST_DAY(DATE_ADD(log_start_date, INTERVAL 1 MONTH)),INTERVAL 1 DAY) AS STRING FORMAT 'YYYYMMDD'),1,6) AS INT64);
      IF trace_flag = 1 THEN
    		--SELECT concat('Calling: Utility.Get_PartitionMonthIDRange_String from 202201 till ',cast(lastpartitionid as string));
      END IF;
     
      --CALL EDW_TRIPS_SUPPORT.Get_PartitionMonthIDRange_String(substr(CAST(202201 as STRING), 1, 10), substr(CAST(lastpartitionid as STRING), 1, 10), partition_ranges);
      IF (SELECT count(1) FROM  EDW_TRIPS.INFORMATION_SCHEMA.TABLES WHERE table_name=SUBSTR(main_table_name,STRPOS(main_table_name,'.')+1)) =0 then
        SET stagetablename = main_table_name;
      END IF;

      --The following CTE give us the Tolltag Debit/Credit record for an unidentified IOP
      set sql1=""" WITH
                    CTE_TT_DR AS (
                    SELECT
                        Gl_TxnID,
                        LinkID AS TPTripID,
                        CustomerID,
                        a1.BusinessUnitId,
                        CAST(PostingDate AS DATE) AS PostingDate,
                        CAST(TxnDate AS DATE) AS TxnDate,
                        TxnAmount
                    FROM
                        EDW_TRIPS.Fact_GL_Transactions a1
                    JOIN
                        EDW_TRIPS.Dim_GL_TxnType a2
                    ON
                        a1.TxnTypeID = a2.TxnTypeID
                    WHERE
                        (TxnType LIKE 'IOP%UNIDTTDR'
                          OR TxnType LIKE 'IOP%UNIDTT')
                        AND Status = 'Active'
                        AND CustomerID = 100057393),
                    CTE_TT_CR AS (
                    SELECT
                        Gl_TxnID,
                        LinkID AS TPTripID,
                        CustomerID,
                        a1.BusinessUnitId,
                        CAST(PostingDate AS DATE) AS PostingDate,
                        CAST(TxnDate AS DATE) AS TxnDate,
                        TxnAmount
                    FROM
                        EDW_TRIPS.Fact_GL_Transactions a1
                    JOIN
                        EDW_TRIPS.Dim_GL_TxnType a2
                    ON
                        a1.TxnTypeID = a2.TxnTypeID
                    WHERE
                        (TxnType LIKE 'IOP%UNIDTTCR'
                          OR TxnType LIKE 'IOP%UNIDTTREJ')
                        AND Status = 'Active'
                        AND CustomerID = 100057393),
                    CTE_VT_DR AS (
                    SELECT
                        Gl_TxnID,
                        LinkID AS TPTripID,
                        CustomerID,
                        a1.BusinessUnitId,
                        CAST(PostingDate AS DATE) AS PostingDate,
                        CAST(TxnDate AS DATE) AS TxnDate,
                        TxnAmount
                    FROM
                        EDW_TRIPS.Fact_GL_Transactions a1
                    JOIN
                        EDW_TRIPS.Dim_GL_TxnType a2
                    ON
                        a1.TxnTypeID = a2.TxnTypeID
                    WHERE
                        (TxnType LIKE 'IOP%UNIDVTDR'
                          OR TxnType LIKE 'IOP%UNIDVT')
                        AND Status = 'Active'
                        AND CustomerID = 100057393),
                    CTE_VT_CR AS (
                    SELECT
                        Gl_TxnID,
                        LinkID AS TPTripID,
                        CustomerID,
                        a1.BusinessUnitId,
                        CAST(PostingDate AS DATE) AS PostingDate,
                        CAST(TxnDate AS DATE) AS TxnDate,
                        TxnAmount
                    FROM
                        EDW_TRIPS.Fact_GL_Transactions a1
                    JOIN
                        EDW_TRIPS.Dim_GL_TxnType a2
                    ON
                       a1.TxnTypeID = a2.TxnTypeID
                    WHERE
                        ((TxnType LIKE 'IOP%UNIDVTCR'
                          OR a2.TxnType LIKE 'IOP%UNIDVTREJ'
                          AND a1.CustomerID = 100057393)
                          OR ((a2.TxnType LIKE 'IOPNTELBJ%VT'
                            AND a2.TxnType NOT IN ('IOPNTELBJUNIDVT'))
                          OR (a2.TxnType LIKE 'IOPNTE12%VT'
                            AND a2.TxnType NOT IN ('IOPNTE12UNIDVT'))) )
                          AND Status = 'Active')
                  SELECT
                    CAST('"""||partitiondate||"""' AS DATE) AS SnapshotDate,
                    COALESCE("""||partitionmonthid||""",0) AS SnapshotMonthID,
                    T.Gl_TxnID,
                    T.TPTripID,
                    FT.LaneID,
                    T.CustomerID,
                    T.BusinessUnitId,
                    T.PostingDate,
                    T.TxnDate,
                    T.TxnAmount,
                    DATE_DIFF(CAST(CAST('"""||partitiondate||"""' AS STRING) AS DATE),T.PostingDate,DAY) AS DaycountID
                  FROM
                    CTE_TT_DR T
                  JOIN
                    EDW_TRIPS.Fact_Transaction FT
                  ON
                    T.TPTripID = FT.TPTripID
                  WHERE
                    T.TPTripID NOT IN (
                    SELECT
                      TPTripID
                    FROM
                      CTE_TT_CR)
                    AND CAST(T.TxnDate AS DATE) < '"""||load_start_date||"""' """;

        SET sql2=""" SELECT
                        CAST('"""||partitiondate||"""' AS DATE) AS SnapshotDate,
                        COALESCE("""||partitionmonthid||""", 0) AS SnapshotMonthID,
                        T.Gl_TxnID,
                        T.TPTripID,
                        FT.LaneID,
                        T.CustomerID,
                        T.BusinessUnitId,
                        T.PostingDate,
                        T.TxnDate,
                        T.TxnAmount,
                        DATE_DIFF(CAST(CAST('"""||partitiondate||"""' AS STRING)AS DATE),T.PostingDate,DAY) AS DaycountID
                      FROM
                        CTE_VT_DR T
                      JOIN
                        EDW_TRIPS.Fact_Transaction FT
                      ON
                        T.TPTripID = FT.TPTripID
                      WHERE
                        T.TPTripID NOT IN (
                        SELECT
                          TPTripID
                        FROM
                          CTE_VT_CR)
                        AND CAST(TxnDate AS DATE) < '"""||load_start_date||"""' """;

      SET sqlresult = concat(sql1, ' UNION DISTINCT ', sql2);
     
      --SET sql ="DROP TABLE IF EXISTS "||stagetablename||"";
      --EXECUTE IMMEDIATE sql;

      SET sql = "CREATE OR REPLACE TABLE "||stagetablename||" CLUSTER BY  Gl_TxnID AS "||sqlresult||"";
      
      EXECUTE IMMEDIATE sql;
      SET log_message = 'Loaded EDW_TRIPS.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_NEW';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));

      IF stagetablename = main_table_name THEN
       
      ELSE
        IF trace_flag = 1 THEN
          --select 'Calling: Utility.ManagePartitions_DateID';
        END IF;

        --CALL EDW_TRIPS_SUPPORT.ManagePartitions_DateID(main_table_name, 'MonthID:Month');
        IF trace_flag = 1 THEN
          --select 'Calling: Utility.PartitionSwitch_Snapshot';
        END IF;
        -- commented PartitionSwitch_Snapshot and implemented this logic below
        --CALL EDW_TRIPS_SUPPORT.PartitionSwitch_Snapshot('dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_NEW', main_table_name);
        --logic for PartitionSwitch_Snapshot
        -- Dropping Records From Main Table having common snapshotmonthid values with Stage Table.
        SET sql3 = concat("Delete From ", main_table_name , " where snapshotmonthid In ( Select snapshotmonthid from ",stagetablename , " )" );
        EXECUTE IMMEDIATE sql3;
      
      -- Inserting NEW Records from Stage to Main Table
        SET sql3 = concat("Insert Into  ", main_table_name , " Select * from ",stagetablename );
        EXECUTE IMMEDIATE sql3;

        --DROP TABLE IF EXISTS EDW_TRIPS.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_NEW;
        SET log_message = concat('Finished load for partition ', substr(CAST(partitiondate as STRING), 1, 10));
        IF trace_flag = 1 THEN
          --select log_message;
        END IF;
        
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
        IF trace_flag = 1 THEN
          SELECT
              'EDW_TRIPS.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot' AS tablename,
              fact_gl_iop_unidentifiedagingtxnsnapshot.*
            FROM
              EDW_TRIPS.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot
          ORDER BY
            2 DESC
            LIMIT 100
          ;
        END IF;

      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = error_message;  -- Rethrow the error!
      END;
    END;
/*

--:: Testing Zone

EXEC Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_Load '2022-01-25'

-- Example to see a full cycle  of the customer
SELECT a2.TxnType,a1.* FROM dbo.Fact_GL_Transactions a1
JOIN dbo.Dim_GL_TxnType a2
ON a1.TxnTypeID=a2.TxnTypeID
WHERE linkid=3268400701
ORDER BY 2

SELECT * FROM lnd_tbos.TollPlus.TP_Trips
WHERE TpTripID=3268400701

--:: Quick check
SELECT count(*) FROM dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot ORDER BY 1
SELECT count(*),SnapshotDate FROM dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot group by SnapshotDate ORDER BY 1

select top 1 * from  dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot
select top 1 * from  dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_new

delete  from  dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot 
where snapshotmonthid in ('202110','202111','202112','202201')

*/
  END;