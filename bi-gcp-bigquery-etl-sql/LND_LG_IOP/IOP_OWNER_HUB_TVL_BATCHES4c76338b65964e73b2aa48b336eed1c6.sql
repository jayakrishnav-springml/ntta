-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_HUB_TVL_BATCHES4c76338b65964e73b2aa48b336eed1c6.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Hub_Tvl_Batches4c76338b65964e73b2aa48b336eed1c6
(
  hub_tvl_batch_id BIGNUMERIC(38) NOT NULL,
  submission_type STRING,
  hub_id STRING,
  iop_home_agency_id STRING,
  iop_sent_to_agency_id STRING,
  tvl_batch_status STRING NOT NULL,
  batch_mode STRING NOT NULL,
  tvl_file_name STRING,
  submission_date DATETIME NOT NULL,
  transfer_date DATETIME,
  bulk_identifier BIGNUMERIC(38),
  tvl_batch_date DATETIME,
  tvl_activation_date DATETIME,
  bulk_indicator STRING NOT NULL,
  record_count BIGNUMERIC(38),
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
