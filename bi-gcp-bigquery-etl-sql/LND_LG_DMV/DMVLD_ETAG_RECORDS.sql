-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_ETAG_RECORDS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Etag_Records
(
  erec_id NUMERIC(29) NOT NULL,
  recno NUMERIC(29) NOT NULL,
  control_item_id STRING,
  control_item_state STRING,
  effective_datestr STRING,
  expiration_datestr STRING,
  effective_date DATETIME,
  expiration_date DATETIME,
  usage_reason STRING,
  description STRING,
  vin STRING,
  docno STRING NOT NULL,
  make STRING,
  model STRING,
  bodystyle STRING,
  color STRING,
  year INT64,
  prev_docno STRING,
  full_name STRING,
  address1 STRING,
  address2 STRING,
  city STRING,
  state STRING,
  zipcode STRING,
  zipcode4 STRING,
  country STRING,
  lienhldrname STRING,
  lienhldrst1 STRING,
  lienhldrst2 STRING,
  lienhldrcity STRING,
  lienhldrstate STRING,
  lienhldrzpcd STRING,
  lienhldrzpcdp4 STRING,
  file_id NUMERIC(29) NOT NULL,
  vin_on_file STRING NOT NULL,
  docno_on_file STRING NOT NULL,
  status STRING NOT NULL,
  date_created DATETIME NOT NULL,
  date_processed DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;
