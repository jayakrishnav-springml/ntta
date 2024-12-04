-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_FILE_SOURCE_STATE_XREF.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_File_Source_State_Xref
(
  id NUMERIC(29) NOT NULL,
  source_code STRING NOT NULL,
  state_code STRING NOT NULL,
  is_active STRING NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
