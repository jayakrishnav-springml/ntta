-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_PLATES_CT_UPD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Plates_Ct_Upd
(
  id BIGNUMERIC(38),
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  title_id NUMERIC(29) NOT NULL,
  is_current STRING NOT NULL,
  start_date DATETIME NOT NULL,
  end_date DATETIME,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  source_id NUMERIC(29) NOT NULL,
  end_source_id NUMERIC(29),
  source_code STRING,
  end_source_code STRING,
  insert_datetime DATETIME NOT NULL
)
;
