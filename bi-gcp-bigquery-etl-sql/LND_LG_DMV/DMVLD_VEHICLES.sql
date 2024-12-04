-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_VEHICLES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Vehicles
(
  id NUMERIC(29) NOT NULL,
  vin STRING NOT NULL,
  body_type STRING,
  class STRING,
  year STRING,
  modl_id STRING,
  source_id NUMERIC(29) NOT NULL,
  vety_id STRING NOT NULL,
  make_id STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  source_code STRING,
  vin_on_file STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
