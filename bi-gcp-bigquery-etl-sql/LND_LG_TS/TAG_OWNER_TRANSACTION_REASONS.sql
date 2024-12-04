-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_TRANSACTION_REASONS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Transaction_Reasons
(
  reason_id NUMERIC(29),
  trans_type_id NUMERIC(29),
  code STRING,
  description STRING,
  is_default STRING,
  comment_reqd STRING,
  sort_order NUMERIC(29),
  date_active DATETIME,
  date_expires DATETIME,
  date_created DATETIME,
  created_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  last_update_type STRING,
  last_update_date DATETIME
)
;
