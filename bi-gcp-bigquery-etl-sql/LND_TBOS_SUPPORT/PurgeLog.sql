CREATE TABLE IF NOT EXISTS LND_TBOS_SUPPORT.PurgeLog (
    runid INT64, 
    rundate DATETIME,
    table_name STRING, 
    fromdate DATETIME, 
    todate DATETIME, 
    keycolumn STRING, 
    min_key_value INT64 , 
    max_key_value INT64,
    purged_rowcount INT64,
    purge_status STRING
);