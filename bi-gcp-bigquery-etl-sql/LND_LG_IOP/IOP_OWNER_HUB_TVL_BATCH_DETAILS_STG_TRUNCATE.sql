-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_HUB_TVL_BATCH_DETAILS_STG_TRUNCATE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Hub_Tvl_Batch_Details_Stg_Truncate
(
  hub_tvl_batch_id NUMERIC(29),
  hub_tvl_batch_detail_id BIGNUMERIC(38) NOT NULL,
  raw_dr_iop_home_agency_id STRING,
  raw_dr_tag_agency_id STRING,
  raw_dr_tag_serial_number STRING,
  raw_dr_tag_status STRING,
  raw_dr_discount_plans STRING,
  raw_dr_tag_type STRING,
  raw_dr_tag_class INT64,
  raw_dr_account_number STRING,
  raw_dr_fleet_indicator STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  date_created_month INT64,
  last_update_date DATETIME,
  last_update_type STRING
)
;
