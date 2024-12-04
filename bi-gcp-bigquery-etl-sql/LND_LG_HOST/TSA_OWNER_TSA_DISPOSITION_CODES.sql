-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TSA_OWNER_TSA_DISPOSITION_CODES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Tsa_Owner_Tsa_Disposition_Codes
(
  disposition_code_id INT64 NOT NULL,
  disposition_code STRING NOT NULL,
  disposition_code_desc STRING,
  is_active STRING NOT NULL,
  created_by STRING,
  date_created DATETIME,
  modified_by STRING,
  date_modified DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;