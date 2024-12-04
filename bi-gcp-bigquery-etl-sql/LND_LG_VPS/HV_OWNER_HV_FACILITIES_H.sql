-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/HV_OWNER_HV_FACILITIES_H.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Hv_Owner_Hv_Facilities_H
(
  dml_date DATETIME,
  dml_performed_by STRING,
  dml_command STRING,
  hv_facs_id BIGNUMERIC(48, 10),
  facs_id BIGNUMERIC(48, 10),
  facs_name STRING,
  facs_abbrev STRING,
  agcy_id BIGNUMERIC(48, 10),
  agcy_name STRING,
  agcy_abbrev STRING,
  note STRING,
  hv_enabled STRING,
  hv_start_date DATETIME,
  hv_end_date DATETIME,
  date_created DATETIME,
  created_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
