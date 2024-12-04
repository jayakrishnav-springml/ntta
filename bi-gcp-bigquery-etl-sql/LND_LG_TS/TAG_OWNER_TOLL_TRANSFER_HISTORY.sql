-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_TOLL_TRANSFER_HISTORY.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Toll_Transfer_History
(
  id NUMERIC(29) NOT NULL,
  ttxn_id NUMERIC(29),
  acct_id_from NUMERIC(29),
  acct_id_to NUMERIC(29),
  tag_id STRING,
  amount NUMERIC(31, 2),
  created_date DATETIME,
  created_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
