CREATE TABLE IF NOT EXISTS LND_TBOS_SUPPORT.Data_Loading_Statistics
(
  dataset_name STRING NOT NULL,
  table_name STRING NOT NULL,
  gcs_to_bq_loading_time_sec FLOAT64 NOT NULL,
  row_count INT64 NOT NULL,
  gcs_to_bq_load_status STRING NOT NULL,
  bq_job_id STRING NOT NULL,
  error STRING
);
ALTER TABLE LND_TBOS_SUPPORT.Data_Loading_Statistics ADD COLUMN IF NOT EXISTS load_datetime DATETIME;
ALTER TABLE LND_TBOS_SUPPORT.Data_Loading_Statistics ADD COLUMN IF NOT EXISTS execution_id INT64;