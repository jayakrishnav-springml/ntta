-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_TAG_VIOLATOR.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Tag_Violator
(
  tv_id NUMERIC(29) NOT NULL,
  acct_id NUMERIC(29) NOT NULL,
  acct_tag_seq INT64 NOT NULL,
  lic_plate STRING NOT NULL,
  lic_state STRING NOT NULL,
  violator_id NUMERIC(29) NOT NULL,
  tv_start_date DATETIME NOT NULL,
  tv_end_date DATETIME,
  is_active STRING NOT NULL,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME,
  modified_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
