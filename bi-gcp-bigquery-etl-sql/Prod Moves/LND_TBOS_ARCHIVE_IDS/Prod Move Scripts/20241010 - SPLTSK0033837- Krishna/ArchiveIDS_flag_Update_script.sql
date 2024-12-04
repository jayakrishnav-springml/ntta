-- Archive Flag Update by IDS

DECLARE
  sql_query STRING DEFAULT '';
DECLARE
  create_backup_table_sql STRING DEFAULT '';
DECLARE
  log_source STRING DEFAULT 'Archive IDS Flag Update ';
DECLARE
  logmessage STRING DEFAULT 'Archive IDS Flag Update';
BEGIN
     CALL   LND_TBOS_SUPPORT.ToLog(log_source,CURRENT_DATETIME('America/Chicago'),'Archive IDS flag Update Started','I',CAST(NULL AS INT64),CAST(NULL AS STRING)); 

/*Fetching Archive ID tables and Keycolumns*/   
      FOR i IN (
      SELECT
        a.table_id,
        b.id_column
      FROM
        `LND_TBOS_ARCHIVE_IDS.__TABLES__` a
      JOIN (
        SELECT
          table_name,
          column_name id_column
        FROM
          `LND_TBOS_ARCHIVE_IDS.INFORMATION_SCHEMA.COLUMNS`
        WHERE
          column_name NOT LIKE '%archivebatchdate%'
          AND column_name NOT LIKE '%lnd_updatedate%') b
      ON
        a.table_id =b.table_name
      WHERE
        table_id IN ( "Finance_ChaseTransactions_IDS",
                      "Finance_ChequePayments_IDS",
                      "Finance_CustomerPayments_IDS",
                      "TollPlus_OverPaymentsLog_IDS",
                      "TranProcessing_NTTAHostBOSFileTracker_IDS",
                      "TranProcessing_NTTARawTransactions_IDS",
                      "TSA_TSATripAttributes_IDS"
    ) ) DO
	/*Dynamic sql gneration for preserve records current status prior to flag update*/
      SET
        create_backup_table_sql = "CREATE TABLE ARCHIVE_IDS_VALIDATION."||i.table_id||"_Before "||CHR(10)|| 
                      "AS "||CHR(10)|| 
                      "SELECT lnd_updatetype,a."||i.id_column||CHR(10)|| 
                      " FROM LND_TBOS."||REPLACE(i.table_id,'_IDS','')||" a "||CHR(10)|| 
                      "JOIN LND_TBOS_ARCHIVE_IDS."|| i.table_id||" b "||CHR(10)||  
                      "ON a."||i.id_column||" =b. "||i.id_column;
					  
      EXECUTE IMMEDIATE
        create_backup_table_sql;

      CALL  LND_TBOS_SUPPORT.ToLog(log_source,CURRENT_DATETIME('America/Chicago'),"Backup completed for Table"||i.table_id,'I',-1,CAST(NULL AS STRING));
	/*Dynamic sql gneration for update  flag update to 'A'*/
      SET
        sql_query ="UPDATE LND_TBOS."||REPLACE(i.table_id,'_IDS','')|| " a "||CHR(10)||
                    "SET lnd_updatetype='A' "||CHR(10)|| 
                    "FROM LND_TBOS_ARCHIVE_IDS."|| i.table_id||" b "||CHR(10)||
                  "WHERE a."||i.id_column||"= b."||i.id_column;
      EXECUTE IMMEDIATE
          sql_query;

      CALL  LND_TBOS_SUPPORT.ToLog(log_source,CURRENT_DATETIME('America/Chicago'),"Flag Update completed for Table"||i.table_id,'I',-1,CAST(NULL AS STRING));

      END
        FOR;
      CALL  LND_TBOS_SUPPORT.ToLog(log_source,    CURRENT_DATETIME('America/Chicago'),    'Archive IDS flag  Update completed',    'I',    CAST(NULL AS INT64),    CAST(NULL AS STRING));
EXCEPTION
    WHEN ERROR THEN 
    BEGIN 
    DECLARE error_message STRING DEFAULT @@error.message;
     SET logmessage ='Archive flag Update Failed  for '||target_table||" "|| @@error.message; 
     CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date, logmessage, 'E', -1, NULL );
END
  ;
END
  ;

/*

select * from `LND_TBOS_SUPPORT.ProcessLog` order by 1 desc limit 100;

*/