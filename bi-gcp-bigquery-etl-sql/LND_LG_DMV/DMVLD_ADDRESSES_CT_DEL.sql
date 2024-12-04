-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_ADDRESSES_CT_DEL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Addresses_Ct_Del
(
  id NUMERIC(29) NOT NULL,
  street STRING,
  city STRING NOT NULL,
  state STRING NOT NULL,
  zip STRING NOT NULL,
  plus4 STRING,
  source_id NUMERIC(29) NOT NULL,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  source_code STRING,
  country_code STRING NOT NULL,
  insert_datetime DATETIME NOT NULL
)
;
