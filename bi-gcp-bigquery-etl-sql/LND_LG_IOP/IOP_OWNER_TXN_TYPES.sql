-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_TXN_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Txn_Types
(
  txn_type STRING NOT NULL,
  txn_type_desc STRING NOT NULL,
  order_by INT64,
  is_active STRING NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  csc_source_code STRING,
  value_type INT64,
  record_type STRING,
  is_iop STRING,
  is_correction STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
