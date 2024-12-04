-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TSA_OWNER_ACKNOWLEDGEMENT_FILE_HEADERS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Tsa_Owner_Acknowledgement_File_Headers
(
  ack_file_header_id NUMERIC(29) NOT NULL,
  record_type STRING NOT NULL,
  version STRING NOT NULL,
  file_date DATETIME NOT NULL,
  original_file_date DATETIME NOT NULL,
  ack_type_id INT64 NOT NULL,
  ack_file_status_id INT64 NOT NULL,
  is_internal_email_sent STRING NOT NULL,
  is_external_email_sent STRING NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  original_file_name STRING NOT NULL,
  file_type_id NUMERIC(29),
  last_update_date DATETIME,
  last_update_type STRING
)
;
