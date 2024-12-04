-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_DMV_SUMMARIES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Dmv_Summaries
(
  id BIGNUMERIC(48, 10) NOT NULL,
  dmvcd_id NUMERIC(29) NOT NULL,
  week STRING,
  n_records NUMERIC(29),
  min_drec_id NUMERIC(29),
  max_drec_id NUMERIC(29),
  ph1_status STRING,
  ph1_start DATETIME,
  ph1_end DATETIME,
  ph2_status STRING,
  ph2_percent NUMERIC(31, 2),
  ph2_start DATETIME,
  ph2_end DATETIME,
  date_created DATETIME,
  date_modified DATETIME,
  modified_by STRING,
  created_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
