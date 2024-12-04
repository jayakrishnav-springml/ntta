-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_DMV_FILES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Dmv_Files
(
  id NUMERIC(29) NOT NULL,
  source_code STRING NOT NULL,
  dir_name STRING NOT NULL,
  file_name STRING NOT NULL,
  external_table_name STRING,
  file_line_count NUMERIC(29) NOT NULL,
  current_line NUMERIC(29) NOT NULL,
  file_year NUMERIC(29) NOT NULL,
  file_number NUMERIC(29) NOT NULL,
  status STRING NOT NULL,
  load_start_date DATETIME,
  load_end_date DATETIME,
  parse_start_date DATETIME,
  parse_end_date DATETIME,
  error_count NUMERIC(29) NOT NULL,
  loaded_count NUMERIC(29) NOT NULL,
  parsed_count NUMERIC(29) NOT NULL,
  duplicate_count NUMERIC(29) NOT NULL,
  excluded_count NUMERIC(29) NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
