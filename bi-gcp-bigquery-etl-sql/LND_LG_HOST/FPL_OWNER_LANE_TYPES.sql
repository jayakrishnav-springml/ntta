-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/FPL_OWNER_LANE_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Fpl_Owner_Lane_Types
(
  lany_desc STRING NOT NULL,
  note STRING,
  created_by STRING NOT NULL,
  creation_date DATETIME NOT NULL,
  updated_by STRING NOT NULL,
  updated_date DATETIME NOT NULL,
  lany_id NUMERIC(29) NOT NULL,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;