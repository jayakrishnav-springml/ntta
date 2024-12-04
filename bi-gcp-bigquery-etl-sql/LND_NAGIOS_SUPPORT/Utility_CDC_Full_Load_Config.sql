CREATE TABLE IF NOT EXISTS LND_NAGIOS_SUPPORT.CDC_Full_Load_Config
(
table_id INT64,
source_dataset_name STRING,	
source_table_name STRING,	
stage_cdc_dataset_name STRING,	
stage_full_dataset_name STRING,	
stage_table_name STRING,	
target_dataset_name STRING,	
target_table_name STRING,	
key_column STRING,	
target_table_columns_list STRING,	
cdc_run_flag STRING,	
fullload_run_flag STRING,	
cdc_batch_name STRING,	
batch_window INT64,
clustering_columns STRING,	
stage_insert_values_list STRING,	
level2_comparison_flag STRING,	
);

ALTER TABLE LND_NAGIOS_SUPPORT.CDC_Full_Load_Config ADD COLUMN IF NOT EXISTS overlap_window_in_secs INT64;
