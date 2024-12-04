
CREATE OR REPLACE PROCEDURE LND_TBOS_SUPPORT.Get_APS_RowCount()
BEGIN
/*
###################################################################################################################
Proc Description: 
##################################################################################################################-
Load Daily Row Counts of Landing TBOS tables in Stage.APS_DailyRowCount. 
===================================================================================================================
Change Log:
##################################################################################################################-
CHG0038211		Shankar		2021-01-18	New!
CHG0040170		Shankar		2021-12-22	Misc changes for better compare results and performance
CHG0042840		Sagarika    2023-04-19	Include LND_UpdateType = 'A' to Avoid wrong Source VS
                                        Landing Compariosn Numbers
===================================================================================================================
Example:
##################################################################################################################-
EXEC Utility.Get_APS_RowCount 
SELECT * FROM Utility.ProcessLog Where LogSource like 'Utility.Get_APS_RowCount%' ORDER BY 1 DESC

SELECT TOP 1000 'Stage.APS_DailyRowCount' TableName, * FROM Stage.APS_DailyRowCount ORDER BY 2,3,4 DESC
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'LND_TBOS_SUPPORT.Get_APS_RowCount';
    DECLARE log_start_date DATETIME;
    DECLARE tablescount INT64;
    DECLARE counter INT64 DEFAULT 1;
    DECLARE sql_line STRING;
    DECLARE sql STRING DEFAULT '';
    DECLARE sql1 STRING DEFAULT '';
    DECLARE sql2 STRING DEFAULT '';
    DECLARE trace_flag INT64 DEFAULT 0;## Testing
    DECLARE log_message STRING;
    BEGIN
      DECLARE row_count INT64;
      DECLARE aps_sql STRING;
      SET log_start_date = current_datetime();
     ## CALL utility.tolog(log_source, log_start_date, 'Started APS Row Counts', 'I', NULL, NULL);
      SELECT log_source, log_start_date, 'Started APS Row Counts', 'I', NULL, NULL;
      		
		##::==================================================================================================
		##:: Daily RowCount script: Compare Daily row counts by CreatedDate for each CDC table 
		##::==================================================================================================

      ##DROP TABLE IF EXISTS _SESSION._rowcounts_sql;
      CREATE OR REPLACE  TEMPORARY TABLE _SESSION.rowcounts_sql
        AS
          SELECT
              row_number() OVER (ORDER BY tableloadparameters.databasename, tableloadparameters.fullname) AS rn,
              concat('SELECT \'', tableloadparameters.databasename, '\' DataBaseName,\'', tableloadparameters.fullname, '\' TableName, ', CASE
                WHEN tableloadparameters.fullname <> 'EIP.Results_Log' THEN 'CAST(CreatedDate AS DATE)'
                ELSE 'CAST(ISNULL(EIPCompletedDate,EIPReceivedDate) AS DATE)'
              END, ' AS CreatedDate, ', 'COUNT(1) SourceRowCount, current_datetime() AS LND_UpdateDate', code_points_to_string(ARRAY[
                10
              ]),',NULL AS SRC_ChangeDate',code_points_to_string(ARRAY[
                10
              ]), 'FROM\t', tableloadparameters.fullname, code_points_to_string(ARRAY[
                10
              ]), 'WHERE\tLND_UpdateType NOT IN (\'D\',\'A\')', code_points_to_string(ARRAY[
                10
              ]), CASE
                WHEN tableloadparameters.fullname = 'TollPlus.TP_Image_Review_Results' THEN concat('AND CreatedDate\t>= \'2019-01-01 00:00\'', code_points_to_string(ARRAY[
                  10
                ]))
                ELSE ''
              END, 'GROUP BY ', CASE
                WHEN tableloadparameters.fullname <> 'EIP.Results_Log' THEN 'CAST(CreatedDate AS DATE)'
                ELSE 'CAST(ISNULL(EIPCompletedDate,EIPReceivedDate) AS DATE)'
              END, code_points_to_string(ARRAY[
                10
              ]), 'UNION ALL', code_points_to_string(ARRAY[
                10
              ])) AS sql_line
            FROM
              LND_TBOS_SUPPORT.tableloadparameters
            WHERE tableloadparameters.active = 1
             AND tableloadparameters.cdcflag = 1
      ;
      
      SET tablescount = (
        SELECT
            coalesce(any_value(subselect.__tablescount), tablescount) AS __tablescount
          FROM
            (
              SELECT
                  max(`#rowcounts_sql`.rn) AS __tablescount
                FROM
                  _SESSION.rowcounts_sql AS `#rowcounts_sql`
              LIMIT 1
            ) AS subselect
      );
      WHILE counter <= tablescount DO
        SET sql_line =
                (SELECT
                    m.sql_line AS sql_line
                  FROM
                    _SESSION.rowcounts_sql AS m
                  WHERE m.rn = counter
                );
        
        SET sql = concat(sql, CASE
          WHEN counter = tablescount THEN replace(sql_line, 'UNION ALL', '')
          ELSE sql_line
        END);
        SET counter=counter+1;
        ## No target-dialect support for source-dialect-specific SET
      END WHILE;
      SET sql1 = 'TRUNCATE TABLE LND_TBOS_Stage_CDC.APS_DailyRowCount;';
      SET sql2=concat( 'INSERT LND_TBOS_Stage_CDC.APS_DailyRowCount ',sql);
      IF trace_flag = 1 THEN
        ##CALL utility.longprint(sql);
      END IF;
      EXECUTE IMMEDIATE sql1;
      EXECUTE IMMEDIATE sql2;
      ##:: Get Row Counts SQL
      SET log_message = concat('Loaded Daily Row Counts for ', substr(CAST(tablescount as STRING), 1, 30), ' CDC Tables in APS LND_TBOS database');
      ##CALL utility.tolog(log_source, log_start_date, log_message, 'I', -1, sql);
      ##CALL utility.tolog(log_source, log_start_date, 'Completed APS Row Counts', 'I', NULL, NULL);
      select log_source, log_start_date, log_message, 'I', -1, sql;
      select log_source, log_start_date, 'Completed APS Row Counts', 'I', NULL, NULL;
      ## Show results
      IF trace_flag = 1 THEN
        ##CALL utility.fromlog(log_source, log_start_date);
        select log_source, log_start_date;
      END IF;
      IF trace_flag = 1 THEN
        SELECT
            'LND_TBOS_Stage_CDC.APS_DailyRowCount' AS tablename,
            *
          FROM
            LND_TBOS_Stage_CDC.aps_dailyrowcount
       ORDER BY
          2,
          3,
          4 DESC  LIMIT 1000
        ;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        SELECT log_source ,log_start_date,error_message,'E', NULL, NULL;
        ##CALL utility.tolog(`@log_source`, `@log_start_date`, error_message, 'E', NULL, NULL);
        ##CALL utility.fromlog(`@log_source`, `@log_start_date`);
        select log_source,log_start_date;
        RAISE USING MESSAGE = error_message;
      END;
    END;
/*
##===============================================================================================================
## DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
##===============================================================================================================
EXEC Utility.Get_APS_RowCount

EXEC Utility.FromLog 'Get_APS_RowCount', 1
SELECT TOP 1000 'Stage.APS_DailyRowCount' TableName, * FROM Stage.APS_DailyRowCount ORDER BY 2,3,4 DESC
*/

  END;



