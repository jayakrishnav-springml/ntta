-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_PAYMENT_SUMMARIES_BASE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Payment_Summaries_Base
(
  pt_type_id INT64 NOT NULL,
  pos_id INT64 NOT NULL,
  card_code STRING NOT NULL,
  ps_date DATETIME NOT NULL,
  ps_total NUMERIC(31, 2) NOT NULL,
  ps_count NUMERIC(29) NOT NULL,
  date_created DATETIME NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  created_by STRING NOT NULL,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
