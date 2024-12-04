-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_FA_TXN_BATCHES_JN.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Fa_Txn_Batches_Jn
(
  jn_operation STRING NOT NULL,
  jn_oracle_user STRING NOT NULL,
  jn_datetime DATETIME NOT NULL,
  jn_notes STRING,
  jn_appln STRING,
  jn_session BIGNUMERIC(38),
  batch_id NUMERIC(29) NOT NULL,
  date_produced DATETIME,
  date_sent DATETIME,
  date_received DATETIME,
  txn_count NUMERIC(29),
  date_created DATETIME,
  date_modified DATETIME,
  modified_by STRING,
  created_by STRING,
  agency_id NUMERIC(29),
  sent_file_name STRING,
  received_file_name STRING,
  batch_status STRING,
  status_date DATETIME,
  batch_amount NUMERIC(31, 2),
  batch_charge_failures INT64,
  last_update_date DATETIME,
  last_update_type STRING
)
;
