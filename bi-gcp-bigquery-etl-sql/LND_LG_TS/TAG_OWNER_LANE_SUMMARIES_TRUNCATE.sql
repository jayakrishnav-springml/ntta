-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_LANE_SUMMARIES_TRUNCATE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Lane_Summaries_Truncate
(
  posted_date DATETIME NOT NULL,
  transaction_date DATETIME NOT NULL,
  source_code STRING NOT NULL,
  lane_id INT64 NOT NULL,
  vehicle_class_code STRING NOT NULL,
  revenue_flag STRING NOT NULL,
  trxn_cnt NUMERIC(29) NOT NULL,
  trxn_amt NUMERIC(31, 2) NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_type STRING,
  last_update_date DATETIME
)
;
