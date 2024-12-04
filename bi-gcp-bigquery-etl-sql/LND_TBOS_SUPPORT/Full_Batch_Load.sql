CREATE TABLE IF NOT EXISTS LND_TBOS_SUPPORT.Full_Batch_Load
(
  Fullload_runid INT64,
  table_name STRING,
  start_date DATETIME,
  end_date DATETIME,
  rowcount_stage INT64,
  lnd_rowcount_before_loading INT64,
  lnd_rowcount_A_D_records INT64,
  lnd_rowcount_after_loading INT64,
  fullload_updatedate DATETIME,
  fullload_status STRING,
  comments STRING
);