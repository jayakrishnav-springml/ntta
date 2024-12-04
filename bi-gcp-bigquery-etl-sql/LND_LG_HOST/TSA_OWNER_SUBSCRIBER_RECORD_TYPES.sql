-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TSA_OWNER_SUBSCRIBER_RECORD_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Tsa_Owner_Subscriber_Record_Types
(
  subscriber_record_type_id STRING NOT NULL,
  record_type_code STRING NOT NULL,
  short_description STRING NOT NULL,
  long_description STRING NOT NULL,
  is_active STRING NOT NULL,
  created_by STRING NOT NULL,
  date_created DATE NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATE NOT NULL,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
