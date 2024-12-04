-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TIM_OWNER_SHIPMENTS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tim_Owner_Shipments
(
  shipment_id INT64 NOT NULL,
  shipped_date DATETIME,
  received_date DATETIME,
  created_date DATETIME,
  ship_status STRING NOT NULL,
  location_id INT64 NOT NULL,
  ordered_by STRING NOT NULL,
  received_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
