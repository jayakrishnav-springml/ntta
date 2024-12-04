-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TSA_OWNER_TRANSACTION_FILE_HEADERS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Tsa_Owner_Transaction_File_Headers
(
  transaction_file_header_id NUMERIC(29) NOT NULL,
  record_type STRING NOT NULL,
  version STRING NOT NULL,
  file_date DATETIME NOT NULL,
  trans_file_control_number STRING NOT NULL,
  subscriber_id STRING NOT NULL,
  record_count NUMERIC(29) NOT NULL,
  file_size NUMERIC(29) NOT NULL,
  checksum STRING NOT NULL,
  file_status_id NUMERIC(29) NOT NULL,
  file_name STRING NOT NULL,
  additional_comments STRING,
  created_by STRING,
  date_created DATETIME,
  modified_by STRING,
  date_modified DATETIME,
  subscriber_list_id INT64,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by transaction_file_header_id
;
