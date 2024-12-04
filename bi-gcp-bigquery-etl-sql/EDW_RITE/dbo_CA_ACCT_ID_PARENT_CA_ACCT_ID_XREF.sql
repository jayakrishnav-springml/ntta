## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_CA_ACCT_ID_PARENT_CA_ACCT_ID_XREF.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Ca_Acct_Id_Parent_Ca_Acct_Id_Xref
(
  viol_invoice_id NUMERIC(29) NOT NULL,
  old_acct_id NUMERIC(29) NOT NULL,
  old_company_id INT64,
  old_acct_date DATETIME NOT NULL,
  new_ca_acct NUMERIC(29) NOT NULL,
  new_ca_company_id INT64
)
;
