CREATE OR REPLACE PROCEDURE `LND_TBOS_SUPPORT.Get_ArchiveDeleteRowCount`()


BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load Daily Row Counts of Landing TBOS Archive tables in Utility.ArchiveDeleteRowCount 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0042840		Sagarika, Shankar		2023-04-19	New!
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.Get_ArchiveDeleteRowCount 
SELECT * FROM Utility.ProcessLog Where LogSource LIKE '%Get_ArchiveDeleteRowCount%' ORDER BY 1 DESC
SELECT TOP 1000 'Stage.ArchiveDeleteRowCount' TableName, * FROM Stage.ArchiveDeleteRowCount ORDER BY 1,2,3 
###################################################################################################################
*/

    DECLARE log_source STRING DEFAULT 'LND_TBOS_SUPPORT.Get_ArchiveDeleteRowCount';
    DECLARE log_start_date DATETIME;
    DECLARE load_start_date STRING;
    DECLARE tablescount INT64;
    DECLARE counter INT64 DEFAULT 1;
    DECLARE sql_line STRING;
    DECLARE sql STRING DEFAULT '';
    DECLARE trace_flag INT64 DEFAULT 0; ## Testing
    DECLARE log_message STRING;
    DECLARE row_count INT64;
    DECLARE sql1 STRING DEFAULT '';
    BEGIN
      DECLARE aps_sql STRING;
      SET log_start_date = current_datetime();
     ## CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date, 'Started APS Archive Delete Row Counts', 'I', NULL, NULL);
     select log_source, log_start_date, 'Started APS Archive Delete Row Counts', 'I', NULL, NULL;
    ## Marker for the most recent LND_TBOS load date
      SET load_start_date = (
        SELECT
            coalesce(any_value(subselect.__load_start_date), load_start_date) AS __load_start_date
          FROM
            (
              SELECT
                  substr(CAST(DATE(datetime_sub(coalesce(max(TollPlus_TP_Trips.posteddate), current_datetime()), interval 1 DAY)) as STRING), 1, 30) AS __load_start_date
                FROM
                  LND_TBOS_STAGE_FULL.TollPlus_TP_Trips
              LIMIT 1
            ) AS subselect
      );
      	
        ##::==================================================================================================
		##:: Daily RowCount script: Compare Daily row counts by LND_UpdateDate for each CDC table 
		##::==================================================================================================

      ##DROP TABLE IF EXISTS _SESSION.archivedeleterowcount_sql;
      CREATE TEMPORARY TABLE _SESSION.archivedeleterowcount_sql
        AS
          SELECT
              row_number() OVER (ORDER BY tlp.databasename, tlp.fullname) AS rn,
              concat(code_points_to_string(ARRAY[
                10
              ]), 'SELECT CAST(LND_UpdateDate AS DATE) AS LND_UpdateDate,\'', tlp.databasename, '\' DataBaseName,\'', tlp.fullname, '\' TableName, CAST(', CAST(/* expression of unknown or erroneous type */ tlp.cdcflag as STRING), ' AS INT64) AS CDCFlag, CAST(', CAST(/* expression of unknown or erroneous type */ tlp.archiveflag as STRING), ' AS INT64) AS ArchiveFlag, CAST(', CASE
                WHEN hd.tablename IS NOT NULL THEN '1'
                ELSE '0'
              END, ' AS INT64) AS HardDeleteTableFlag, CAST(', CASE
                WHEN alt.tablename IS NOT NULL THEN '1'
                ELSE '0'
              END, ' AS INT64) AS ArchiveMasterListFlag, ', 'LND_UpdateType, ', 'COUNT(1) Row_Count, CAST(CURRENT_DATETIME() AS DATETIME) AS RowCountDate', code_points_to_string(ARRAY[
                10
              ]), 'FROM ', tlp.fullname, code_points_to_string(ARRAY[
                10
              ]), 'WHERE LND_UpdateType  IN (\'D\',\'A\')', code_points_to_string(ARRAY[
                10
              ]), 'AND LND_UpdateDate >= \'', load_start_date, '\'', code_points_to_string(ARRAY[
                10
              ]), 'GROUP BY ', 'CAST(LND_UpdateDate AS DATE)', ',LND_UpdateType', code_points_to_string(ARRAY[
                10
              ]), 'UNION ALL', code_points_to_string(ARRAY[
                10
              ])) AS sql_line
            FROM
              LND_TBOS_SUPPORT.TableLoadParameters AS tlp
              LEFT OUTER JOIN LND_TBOS_SUPPORT.HardDeleteTable AS hd ON tlp.fullname = hd.tablename
              LEFT OUTER JOIN LND_TBOS_SUPPORT.ArchiveMasterTableList AS alt ON tlp.fullname = alt.tablename
            WHERE tlp.active = 1
             AND tlp.fullname NOT IN(
              'Reporting.InvoiceDetail_Tunned', 'TranProcessing.NTTAHostBOSFileTracker', 'TollPlus.TpFileTracker'
            )
      ;
      		##AND TLP.FullName LIKE '%ACTIVITI%'
      SET tablescount = (
        SELECT
            coalesce(any_value(subselect.__tablescount), tablescount) AS __tablescount
          FROM
            (
              SELECT
                  max(`#archivedeleterowcount_sql`.rn) AS __tablescount
                FROM
                  _SESSION.archivedeleterowcount_sql AS `#archivedeleterowcount_sql`
              LIMIT 1
            ) AS subselect
      );
      select tablescount;
      WHILE counter <= tablescount DO
        SET sql_line = (
          SELECT
              coalesce(any_value(subselect.__sql_line), sql_line) AS __sql_line
            FROM
              (
                SELECT
                    m.sql_line AS __sql_line
                  FROM
                    _SESSION.archivedeleterowcount_sql AS m
                  WHERE m.rn = counter
                LIMIT 1
              ) AS subselect
        );
        SET sql = concat(sql, CASE
          WHEN counter = tablescount THEN replace(sql_line, 'UNION ALL', '')
          ELSE sql_line
        END);
        select sql;
        SET counter= counter+1;
        ## No target-dialect support for source-dialect-specific SET
      END WHILE;
      SET sql1 = 'TRUNCATE TABLE LND_TBOS_STAGE_FULL.ArchiveDeleteRowCount';
      EXECUTE IMMEDIATE sql1;
      SET sql = concat('INSERT INTO LND_TBOS_STAGE_FULL.ArchiveDeleteRowCount(lnd_updatedate, databasename,tablename,cdcflag,archiveflag,harddeletetableflag,archivemasterlistflag,lnd_updatetype,row_count,rowcountdate)', code_points_to_string(ARRAY[
        10
      ]), sql);
      IF trace_flag = 1 THEN
        CALL LND_TBOS_SUPPORT.LongPrint(sql);
        
        ##:: Get Row Counts SQL
      END IF;
      select sql;
      EXECUTE IMMEDIATE sql;
      SET log_message = concat('Loaded A or D Row Counts for ', substr(CAST(tablescount as STRING), 1, 30), ' tables from the latest load into LND_TBOS_STAGE_FULL.ArchiveDeleteRowCount ');
      
     ## CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, sql);
     select log_source, log_start_date, log_message, 'I', -1, sql;
      		##:: Load new A or D row counts
      INSERT INTO LND_TBOS_SUPPORT.ArchiveDeleteRowCount (lnd_updatedate, databasename, tablename, cdcflag, archiveflag, harddeletetableflag, archivemasterlistflag, lnd_updatetype, row_count, rowcountdate)
        SELECT
            s.lnd_updatedate,
            s.databasename,
            s.tablename,
            s.cdcflag,
            s.archiveflag,
            s.harddeletetableflag,
            s.archivemasterlistflag,
            s.lnd_updatetype,
            row_count,
            s.rowcountdate
          FROM
            LND_TBOS_STAGE_FULL.ArchiveDeleteRowCount AS s
          WHERE NOT EXISTS (
            SELECT
                1
              FROM
                LND_TBOS_SUPPORT.ArchiveDeleteRowCount AS m
              WHERE m.lnd_updatedate = s.lnd_updatedate
               AND m.tablename = s.tablename
               AND m.lnd_updatetype = s.lnd_updatetype
               AND m.row_count = s.row_count
          )
      ;
      SET log_message = concat('Loaded new A or D Row Counts for ', substr(CAST(tablescount as STRING), 1, 30), ' tables into LND_TBOS_SUPPORT.ArchiveDeleteRowCount ');
      ##CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, sql);
      select log_source, log_start_date, log_message, 'I', -1, sql;
      ##CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date, 'Completed APS Archive Delete Row Counts', 'I', NULL, NULL);
      select log_source, log_start_date, 'Completed APS Archive Delete Row Counts', 'I', NULL, NULL;
    
    ## Show results 
      IF trace_flag = 1 THEN
        ##CALL LND_TBOS_SUPPORT.FromLog(log_source, log_start_date);
        select log_source, log_start_date;
      END IF;
      IF trace_flag = 1 THEN
        SELECT
            'LND_TBOS_STAGE_FULL.ArchiveDeleteRowCount' AS tablename,
            ArchiveDeleteRowCount.*
          FROM
            LND_TBOS_STAGE_FULL.ArchiveDeleteRowCount
        ORDER BY
          2,
          3,
          4 DESC
        ;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        ##CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
        select log_source, log_start_date, error_message, 'E', NULL, NULL;
        ##CALL LND_TBOS_SUPPORT.FromLog(log_source, log_start_date);
        select log_source, log_start_date;
        RAISE USING MESSAGE = error_message;  ## Rethrow the error!
      END;
    END;
/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC Utility.Get_ArchiveDeleteRowCount 
SELECT * FROM Utility.ProcessLog Where LogSource LIKE '%Get_ArchiveDeleteRowCount%' ORDER BY 1 DESC
SELECT TOP 1000 'Stage.ArchiveDeleteRowCount' TableName, * FROM Stage.ArchiveDeleteRowCount ORDER BY 1,2,3 

--===============================================================================================================
-- Dynamic SQL
--===============================================================================================================
SELECT CAST(LND_UpdateDate AS DATE) AS LND_UpdateDate,'TBOS' DataBaseName,'TollPlus.TP_Customer_Activities' TableName, CAST(1 AS BIT) AS CDCFlag, CAST(0 AS BIT) AS ArchiveFlag, CAST(0AS BIT) AS HardDeleteTableFlag, CAST(1 AS BIT) AS ArchiveMasterListFlag, LND_UpdateType, COUNT_BIG(1) Row_Count, CAST(SYSDATETIME() AS DATETIME2(3)) AS RowCountDate
FROM LND_TBOS_DEV.TollPlus.TP_Customer_Activities
WHERE LND_UpdateType  IN ('D','A')
AND LND_UpdateDate >= '2023-04-18'
GROUP BY CAST(LND_UpdateDate AS DATE),LND_UpdateType

*/

 
  END;

