-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_CA_ACCT_INV_PMTS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Ca_Acct_Inv_Pmts
(
  ca_account_id NUMERIC(29) NOT NULL,
  viol_invoice_id NUMERIC(29) NOT NULL,
  pmt_amount NUMERIC(31, 2) NOT NULL,
  pmt_file_date DATETIME NOT NULL,
  undo_file_date DATETIME,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
