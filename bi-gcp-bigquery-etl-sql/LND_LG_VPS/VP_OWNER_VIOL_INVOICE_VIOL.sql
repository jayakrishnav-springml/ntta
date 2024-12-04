-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_VIOL_INVOICE_VIOL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Viol_Invoice_Viol
(
  violation_id NUMERIC(29),
  viol_invoice_id NUMERIC(29),
  fine_amount NUMERIC(31, 2),
  toll_due_amount NUMERIC(31, 2),
  viol_inv_status STRING,
  date_created DATETIME,
  date_modified DATETIME,
  modified_by STRING,
  created_by STRING,
  viol_status STRING,
  gl_status STRING,
  close_out_date DATETIME,
  last_update_type STRING,
  last_update_date DATETIME
)
cluster by violation_id, viol_invoice_id
;
