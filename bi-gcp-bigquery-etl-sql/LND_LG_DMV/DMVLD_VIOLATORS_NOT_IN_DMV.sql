-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_VIOLATORS_NOT_IN_DMV.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Violators_Not_In_Dmv
(
  id NUMERIC(29) NOT NULL,
  violator_id NUMERIC(29),
  lic_plate_nbr STRING NOT NULL,
  violator_fname STRING,
  violator_lname STRING,
  status STRING NOT NULL,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  notes STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
