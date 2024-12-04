CREATE TABLE IF NOT EXISTS LND_TBOS_SUPPORT.CDC_Full_Load_Config
(
  table_id INT64 NOT NULL,
  source_dataset_name STRING NOT NULL,
  source_table_name STRING NOT NULL,
  stage_cdc_dataset_name STRING NOT NULL,
  stage_full_dataset_name STRING NOT NULL,
  stage_table_name STRING NOT NULL,
  target_dataset_name STRING NOT NULL,
  target_table_name STRING NOT NULL,  
  key_column STRING NOT NULL,
  target_table_columns_list STRING,
  cdc_run_flag STRING NOT NULL,
  fullload_run_flag STRING NOT NULL,
  cdc_batch_name STRING,
  batch_window INT64
)
;
/*alter for On demand Full load changes*/
ALTER TABLE
  LND_TBOS_SUPPORT.CDC_Full_Load_Config ADD COLUMN IF NOT EXISTS clustering_columns STRING;  
/*alter for CDC changes*/
ALTER TABLE 
  LND_TBOS_SUPPORT.CDC_Full_load_config ADD COLUMN IF NOT EXISTS stage_insert_values_list STRING;  
/*Lvele to row count comarision changes*/
ALTER TABLE
  LND_TBOS_SUPPORT.CDC_Full_load_config ADD COLUMN
IF NOT EXISTS level2_comparison_flag STRING;

ALTER TABLE
  LND_TBOS_SUPPORT.CDC_Full_load_config ALTER COLUMN level2_comparison_flag
SET
  DEFAULT 'Y';   
/*alter for CDC changes*/
ALTER TABLE LND_TBOS_SUPPORT.CDC_Full_Load_Config ADD COLUMN IF NOT EXISTS overlap_window_in_secs INT64;

/*alter for Purge Process*/
ALTER TABLE LND_TBOS_SUPPORT.CDC_Full_Load_Config ADD COLUMN IF NOT EXISTS purge_run_flag STRING, ADD COLUMN IF NOT EXISTS ct_data_retention_days INT64;