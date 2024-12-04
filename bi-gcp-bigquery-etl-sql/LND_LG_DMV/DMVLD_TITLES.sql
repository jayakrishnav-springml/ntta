-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_TITLES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Titles
(
  id BIGNUMERIC(48, 10) NOT NULL,
  docno STRING NOT NULL,
  vehi_id NUMERIC(29) NOT NULL,
  ownr_id NUMERIC(29) NOT NULL,
  title_issue_date DATETIME NOT NULL,
  is_current STRING NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  source_id NUMERIC(29) NOT NULL,
  end_source_id NUMERIC(29),
  source_code STRING,
  end_source_code STRING,
  docno_on_file STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
