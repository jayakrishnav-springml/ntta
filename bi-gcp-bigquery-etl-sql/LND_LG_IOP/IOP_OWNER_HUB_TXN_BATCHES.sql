-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_HUB_TXN_BATCHES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Hub_Txn_Batches
(
  hub_txn_batch_id NUMERIC(29) NOT NULL,
  submission_type STRING,
  submission_date DATETIME,
  hub_id STRING,
  iop_away_agency_id STRING,
  iop_home_agency_id STRING,
  data_sequence_number STRING,
  record_count STRING,
  file_name STRING,
  batch_mode STRING NOT NULL,
  txn_batch_status STRING NOT NULL,
  parent_batch_id NUMERIC(29),
  transfer_date DATETIME,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;