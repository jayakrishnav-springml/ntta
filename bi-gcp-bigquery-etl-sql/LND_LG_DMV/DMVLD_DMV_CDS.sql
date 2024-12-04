-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_DMV_CDS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Dmv_Cds
(
  dmvcd_id NUMERIC(29) NOT NULL,
  file_name STRING,
  file_dir STRING,
  file_size_bytes NUMERIC(29),
  file_line_count NUMERIC(29),
  current_line NUMERIC(29),
  status STRING,
  date_created DATETIME,
  created_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  external_table_name STRING,
  err_mesage STRING,
  external_directory STRING,
  load_start_time DATETIME,
  load_end_time DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;
