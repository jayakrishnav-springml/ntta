-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_VO_PLATES_TRUNCATE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Vo_Plates_Truncate
(
  id NUMERIC(29) NOT NULL,
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  vehi_id NUMERIC(29) NOT NULL,
  ownr_id NUMERIC(29) NOT NULL,
  start_date DATETIME NOT NULL,
  end_date DATETIME,
  is_current STRING NOT NULL,
  source_id NUMERIC(29) NOT NULL,
  source_code STRING NOT NULL,
  end_source_id NUMERIC(29),
  end_source_code STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
