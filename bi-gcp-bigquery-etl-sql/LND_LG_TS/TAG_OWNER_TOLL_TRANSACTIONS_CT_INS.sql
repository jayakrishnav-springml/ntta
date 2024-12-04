-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_TOLL_TRANSACTIONS_CT_INS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Toll_Transactions_Ct_Ins
(
  ttxn_id NUMERIC(29) NOT NULL,
  amount NUMERIC(31, 2) NOT NULL,
  transaction_date DATETIME NOT NULL,
  posted_date DATETIME,
  source_code STRING NOT NULL,
  source_trxn_id NUMERIC(29) NOT NULL,
  credited_flag STRING,
  acct_id NUMERIC(29) NOT NULL,
  agency_id STRING NOT NULL,
  tag_id STRING NOT NULL,
  lane_id INT64 NOT NULL,
  date_credited DATETIME,
  vehicle_class_code STRING,
  entry_date DATETIME,
  entry_lane_id INT64,
  trans_type_id NUMERIC(29),
  vpn_id INT64,
  transaction_file_detail_id NUMERIC(29),
  txn_match_identifier_code STRING,
  insert_datetime DATETIME NOT NULL
)
;
