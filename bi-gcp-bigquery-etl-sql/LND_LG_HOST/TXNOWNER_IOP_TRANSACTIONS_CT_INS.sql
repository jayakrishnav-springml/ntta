-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_IOP_TRANSACTIONS_CT_INS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Iop_Transactions_Ct_Ins
(
  transaction_id NUMERIC(29) NOT NULL,
  transaction_date DATETIME NOT NULL,
  agency_code STRING,
  tag_id STRING,
  facility_id INT64 NOT NULL,
  plaza_id INT64 NOT NULL,
  lane_id NUMERIC(29) NOT NULL,
  disposition STRING,
  reason_code STRING,
  earned_class INT64,
  earned_revenue NUMERIC(31, 2),
  posted_class INT64,
  posted_revenue NUMERIC(31, 2),
  posted_date_time DATETIME,
  source_code STRING NOT NULL,
  txid_id STRING,
  creation_date DATETIME NOT NULL,
  lic_plate_nbr STRING,
  lic_plate_state STRING,
  hia_agcy_id NUMERIC(29),
  txn_type STRING,
  entry_lane_id NUMERIC(29),
  entry_txn_date DATETIME,
  entry_tvl_tag_status STRING,
  exit_tvl_tag_status STRING,
  repost_attempts INT64,
  attribute_1 STRING,
  attribute_2 STRING,
  attribute_3 STRING,
  attribute_4 STRING,
  attribute_5 STRING,
  attribute_6 STRING,
  attribute_7 STRING,
  attribute_8 STRING,
  attribute_9 STRING,
  attribute_10 STRING,
  iop_earned_revenue NUMERIC(31, 2),
  det_link_id NUMERIC(29),
  det_link_vtoll NUMERIC(29),
  transaction_file_detail_id NUMERIC(29),
  proc_fee_flat NUMERIC(31, 2),
  proc_fee_pct NUMERIC(31, 2),
  lic_plate_country STRING,
  lic_plate_type STRING,
  resubmit_reason STRING,
  resubmit_count INT64,
  hub_iop_txn_id NUMERIC(29),
  home_txn_reference_id NUMERIC(29),
  recon_home_agency_id STRING,
  iop_disposition STRING,
  tag_agency_id STRING,
  insert_datetime DATETIME NOT NULL
)
;
