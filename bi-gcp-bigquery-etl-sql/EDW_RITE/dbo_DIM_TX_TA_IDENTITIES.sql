## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DIM_TX_TA_IDENTITIES.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dim_Tx_Ta_Identities
(
  name STRING NOT NULL,
  txid_desc STRING NOT NULL,
  created_by STRING NOT NULL,
  creation_date DATE NOT NULL,
  updated_by STRING NOT NULL,
  updated_date DATE NOT NULL,
  txid_id NUMERIC(29),
  txbe_id NUMERIC(29),
  transaction_rpt_name STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
