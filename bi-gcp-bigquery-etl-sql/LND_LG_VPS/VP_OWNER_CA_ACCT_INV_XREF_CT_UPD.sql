-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_CA_ACCT_INV_XREF_CT_UPD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Ca_Acct_Inv_Xref_Ct_Upd
(
  ca_acct_id NUMERIC(29) NOT NULL,
  viol_invoice_id NUMERIC(29) NOT NULL,
  ca_inv_status STRING NOT NULL,
  ca_acct_status STRING NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING,
  date_modified DATETIME,
  insert_datetime DATETIME NOT NULL
)
;
