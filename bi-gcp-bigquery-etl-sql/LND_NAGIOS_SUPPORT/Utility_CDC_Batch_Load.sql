CREATE TABLE IF NOT EXISTS LND_NAGIOS_SUPPORT.CDC_Batch_Load
(
cdc_runid INT64,
cdc_batch_name STRING,	
table_name STRING,	
batch_start_date DATETIME,	
batch_end_date DATETIME,	
batch_window STRING,	
cdc_merge_status STRING,	
cdc_updatedate DATETIME,	
comments STRING,	
);

ALTER TABLE LND_NAGIOS_SUPPORT.CDC_Batch_Load
ADD COLUMN IF NOT EXISTS change_from_date DATETIME,
ADD COLUMN IF NOT EXISTS change_to_date DATETIME,
ADD COLUMN IF NOT EXISTS lnd_before_cdc_rowcount INT64,
ADD COLUMN IF NOT EXISTS lnd_after_cdc_rowcount INT64,
ADD COLUMN IF NOT EXISTS ct_rowcount INT64,
ADD COLUMN IF NOT EXISTS stage_cdc_rowcount INT64,
ADD COLUMN IF NOT EXISTS lnd_dup_rowcount INT64,
ADD COLUMN IF NOT EXISTS ct_i_count INT64,
ADD COLUMN IF NOT EXISTS ct_u_count INT64,
ADD COLUMN IF NOT EXISTS ct_d_count INT64,
ADD COLUMN IF NOT EXISTS stage_i_count INT64,
ADD COLUMN IF NOT EXISTS stage_u_count INT64,
ADD COLUMN IF NOT EXISTS stage_d_count INT64,
ADD COLUMN IF NOT EXISTS lnd_i_count INT64,
ADD COLUMN IF NOT EXISTS lnd_u_count INT64,
ADD COLUMN IF NOT EXISTS lnd_d_count INT64;

ALTER  TABLE LND_NAGIOS_SUPPORT.CDC_Batch_Load 
ADD COLUMN IF NOT EXISTS CDC_merge_end_date DATETIME;