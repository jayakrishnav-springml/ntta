-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_HUB_TVL_BATCH_LIC_PLATES_ARC_TRUNCATE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Hub_Tvl_Batch_Lic_Plates_Arc_Truncate
(
  hub_tvl_batch_lic_plate_id BIGNUMERIC(38) NOT NULL,
  hub_tvl_batch_id NUMERIC(29),
  hub_tvl_batch_detail_id BIGNUMERIC(38),
  raw_dr_iop_home_agency_id STRING,
  raw_dr_lic_plate_country STRING,
  raw_dr_lic_plate_state STRING,
  raw_dr_lic_plate_number STRING,
  raw_dr_lic_plate_type STRING,
  raw_dr_lic_plate_eff_from DATETIME,
  raw_dr_lic_plate_eff_to DATETIME,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  date_created_month INT64,
  last_update_date DATETIME,
  last_update_type STRING
)
;
