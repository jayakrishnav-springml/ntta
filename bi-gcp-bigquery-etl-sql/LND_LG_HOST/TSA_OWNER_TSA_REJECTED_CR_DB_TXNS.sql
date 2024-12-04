-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TSA_OWNER_TSA_REJECTED_CR_DB_TXNS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Tsa_Owner_Tsa_Rejected_Cr_Db_Txns
(
  transaction_file_detail_id NUMERIC(29) NOT NULL,
  txn_type STRING,
  orig_txn_file_detail_id NUMERIC(29),
  orig_txn_type STRING,
  reject_reason_code STRING,
  subscriber_unique_id NUMERIC(29),
  file_name STRING,
  license_plate STRING,
  license_state STRING,
  transponder_id STRING,
  date_received DATETIME,
  transaction_date DATETIME,
  home_authority STRING,
  lane_id NUMERIC(29),
  lane_name STRING,
  facility_name STRING,
  plaza_name STRING,
  amount NUMERIC(31, 2),
  org_txn_date_received DATETIME,
  org_txn_amount NUMERIC(31, 2),
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
