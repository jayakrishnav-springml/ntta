-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_OWNERS_CT_UPD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Owners_Ct_Upd
(
  id NUMERIC(29) NOT NULL,
  owner_type STRING NOT NULL,
  full_name STRING NOT NULL,
  first_name STRING NOT NULL,
  middle_name STRING,
  last_name STRING,
  first_name2 STRING,
  middle_name2 STRING,
  last_name2 STRING,
  source_id NUMERIC(29) NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  source_code STRING,
  insert_datetime DATETIME NOT NULL
)
;
