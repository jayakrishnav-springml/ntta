-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_OLC_PMT_STATUS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Olc_Pmt_Status
(
  pmt_status STRING NOT NULL,
  pmt_status_desc STRING NOT NULL,
  show_order INT64,
  is_active STRING,
  date_modified DATETIME,
  date_created DATETIME,
  modified_by STRING,
  created_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
