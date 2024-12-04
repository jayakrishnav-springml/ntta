-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_DPS_CITATIONS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Dps_Citations
(
  violator_id NUMERIC(29) NOT NULL,
  driver_lic_nbr STRING,
  lic_plate_nbr STRING NOT NULL,
  violator_lname STRING,
  violator_fname STRING,
  violator_type STRING,
  violator_addr_seq INT64,
  outstanding_amount NUMERIC(31, 2),
  date_created DATETIME,
  created_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
