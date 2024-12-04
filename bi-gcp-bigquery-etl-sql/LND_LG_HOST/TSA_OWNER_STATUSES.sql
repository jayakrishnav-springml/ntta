-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TSA_OWNER_STATUSES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Tsa_Owner_Statuses
(
  status_id NUMERIC(29) NOT NULL,
  description STRING NOT NULL,
  date_created STRING NOT NULL,
  created_by STRING NOT NULL,
  date_modified STRING NOT NULL,
  modified_by STRING NOT NULL,
  version NUMERIC(29) NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
