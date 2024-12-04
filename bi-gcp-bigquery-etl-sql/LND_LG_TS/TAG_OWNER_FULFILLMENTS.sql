-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_FULFILLMENTS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Fulfillments
(
  acct_id NUMERIC(29),
  fulfillment_id NUMERIC(29),
  fulfillment_type_code STRING,
  fulfillment_status_code STRING,
  retail_trans_id INT64,
  rtd_id INT64,
  batch_id NUMERIC(29),
  units INT64,
  requested_by STRING,
  requested_date DATETIME,
  fulfilled_by STRING,
  fulfilled_date DATETIME,
  last_update_type STRING,
  last_update_date DATETIME
)
;
