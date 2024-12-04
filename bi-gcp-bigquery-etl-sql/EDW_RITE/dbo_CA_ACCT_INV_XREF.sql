## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_CA_ACCT_INV_XREF.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Ca_Acct_Inv_Xref
(
  ca_acct_id NUMERIC(29) NOT NULL,
  viol_invoice_id NUMERIC(29) NOT NULL,
  ca_inv_status STRING NOT NULL,
  ca_acct_status STRING NOT NULL,
  insert_date DATETIME,
  last_update_date DATETIME
)
;
