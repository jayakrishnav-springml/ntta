-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_HUB_TXN_EXCEPTIONS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Hub_Txn_Exceptions
(
  hub_txn_exception_id NUMERIC(29) NOT NULL,
  hub_txn_batch_id NUMERIC(29) NOT NULL,
  hub_txn_batch_detail_id NUMERIC(29) NOT NULL,
  txn_reference_id STRING,
  record_type STRING,
  error_message STRING,
  submission_detail_record STRING NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
