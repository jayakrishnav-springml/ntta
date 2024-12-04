-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TIM_OWNER_TAG_SUMMARIES_TRUNCATE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tim_Owner_Tag_Summaries_Truncate
(
  tag_summary_date DATETIME NOT NULL,
  tag_count INT64 NOT NULL,
  location_id INT64 NOT NULL,
  tag_status STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
