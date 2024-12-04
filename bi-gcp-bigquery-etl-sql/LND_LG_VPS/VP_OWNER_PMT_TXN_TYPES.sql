-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_PMT_TXN_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Pmt_Txn_Types
(
  pmt_txn_type STRING NOT NULL,
  pmt_txn_type_descr STRING NOT NULL,
  tendered_multiplier INT64 NOT NULL,
  refund_multiplier INT64 NOT NULL,
  reversed_multiplier INT64 NOT NULL,
  is_active STRING NOT NULL,
  pmt_txn_type_descr2 STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
