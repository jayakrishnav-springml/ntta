-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TIM_OWNER_SHIPMENT_DETAILS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tim_Owner_Shipment_Details
(
  shp_detail_id INT64 NOT NULL,
  shp_shipment_id INT64 NOT NULL,
  agency_id STRING,
  tag_id STRING,
  container_id INT64,
  last_update_date DATETIME,
  last_update_type STRING
)
;
