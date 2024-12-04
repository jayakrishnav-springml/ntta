-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/HV_OWNER_COUNTIES_H.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Hv_Owner_Counties_H
(
  dml_date DATETIME,
  dml_performed_by STRING,
  dml_command STRING,
  county_id BIGNUMERIC(48, 10),
  county_name STRING,
  state STRING,
  tx_dot_id STRING,
  date_created DATETIME,
  created_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
