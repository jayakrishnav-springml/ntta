-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TIM_OWNER_INVENTORY_ENTRIES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tim_Owner_Inventory_Entries
(
  inv_entry_id INT64 NOT NULL,
  start_tag_id STRING NOT NULL,
  end_tag_id STRING NOT NULL,
  po_id INT64,
  container_id INT64,
  last_update_date DATETIME,
  last_update_type STRING
)
;
