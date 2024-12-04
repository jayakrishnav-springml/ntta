-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/HV_OWNER_HV_FACILITIES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Hv_Owner_Hv_Facilities
(
  hv_facs_id FLOAT64 NOT NULL,
  facs_id FLOAT64 NOT NULL,
  facs_name STRING,
  facs_abbrev STRING,
  agcy_id FLOAT64,
  agcy_name STRING,
  agcy_abbrev STRING,
  note STRING,
  hv_enabled STRING NOT NULL,
  hv_start_date DATE NOT NULL,
  hv_end_date DATE NOT NULL,
  date_created DATE NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATE,
  modified_by STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
