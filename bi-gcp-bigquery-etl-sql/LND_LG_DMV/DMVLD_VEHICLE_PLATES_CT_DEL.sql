-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_VEHICLE_PLATES_CT_DEL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Vehicle_Plates_Ct_Del
(
  plate_number STRING NOT NULL,
  start_date DATETIME,
  end_date DATETIME,
  ownr_id NUMERIC(29) NOT NULL,
  vehi_id NUMERIC(29) NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING,
  date_modified DATETIME,
  drec_id NUMERIC(29),
  vps_match STRING,
  violator_id NUMERIC(29),
  insert_datetime DATETIME NOT NULL
)
;