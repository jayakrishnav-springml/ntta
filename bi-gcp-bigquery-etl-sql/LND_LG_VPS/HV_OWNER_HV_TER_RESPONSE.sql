-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/HV_OWNER_HV_TER_RESPONSE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Hv_Owner_Hv_Ter_Response
(
  violator_id FLOAT64 NOT NULL,
  vid_seq FLOAT64 NOT NULL,
  hv_flag FLOAT64 NOT NULL,
  effectivedate DATE,
  is_processed_by_rite FLOAT64 NOT NULL,
  errormsg STRING,
  createdby STRING NOT NULL,
  createddate DATE NOT NULL,
  updatedby STRING,
  updateddate DATE,
  is_processed_by_rite2 STRING NOT NULL,
  process_status_by_rite STRING,
  date_created DATE NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATE,
  modified_by STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
