-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TSA_OWNER_ACKNOWLEDGEMENT_FILE_STATUSES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Tsa_Owner_Acknowledgement_File_Statuses
(
  ack_file_status_id INT64 NOT NULL,
  ack_file_status_code STRING NOT NULL,
  short_description STRING NOT NULL,
  long_description STRING NOT NULL,
  akn_file_status_order FLOAT64 NOT NULL,
  is_active STRING NOT NULL,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
