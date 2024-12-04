-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_VIOL_INVOICE_VIOL_CT_UPD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Viol_Invoice_Viol_Ct_Upd
(
  violation_id NUMERIC(29) NOT NULL,
  viol_invoice_id NUMERIC(29) NOT NULL,
  fine_amount NUMERIC(33, 4) NOT NULL,
  toll_due_amount NUMERIC(33, 4) NOT NULL,
  viol_inv_status STRING NOT NULL,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME,
  modified_by STRING,
  viol_status STRING NOT NULL,
  gl_status STRING NOT NULL,
  close_out_date DATETIME,
  insert_datetime DATETIME NOT NULL
)
;
