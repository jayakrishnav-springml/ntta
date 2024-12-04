CREATE TABLE IF NOT EXISTS EDW_TER.Process_Log
(
  log_date DATETIME NOT NULL,
  log_source STRING NOT NULL,
  elapsed_time STRING,
  log_message STRING NOT NULL,
  rows_affected INT64
)
;
