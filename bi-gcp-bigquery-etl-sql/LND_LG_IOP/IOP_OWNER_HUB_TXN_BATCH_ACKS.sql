-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_HUB_TXN_BATCH_ACKS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Hub_Txn_Batch_Acks
(
  hub_txn_batch_ack_id NUMERIC(29) NOT NULL,
  submission_type STRING NOT NULL,
  hub_txn_batch_id NUMERIC(29) NOT NULL,
  batch_mode STRING NOT NULL,
  ack_file_name STRING NOT NULL,
  original_submission_type STRING NOT NULL,
  original_submission_date DATETIME NOT NULL,
  hub_id STRING NOT NULL,
  iop_from_agency_id STRING NOT NULL,
  iop_to_agency_id STRING NOT NULL,
  ack_datetime DATETIME NOT NULL,
  return_code STRING NOT NULL,
  processed_flag STRING,
  transfer_date DATETIME,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
