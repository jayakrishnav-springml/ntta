-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_VIOL_INVOICES_HISTORY_CT_INS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Viol_Invoices_History_Ct_Ins
(
  viol_invoice_id NUMERIC(29) NOT NULL,
  viol_inv_seq_id INT64 NOT NULL,
  old_viol_inv_sts STRING NOT NULL,
  new_viol_inv_sts STRING NOT NULL,
  status_date DATETIME,
  date_created DATETIME NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  created_by STRING NOT NULL,
  old_gl_status STRING NOT NULL,
  new_gl_status STRING NOT NULL,
  old_ca_inv_status STRING NOT NULL,
  new_ca_inv_status STRING NOT NULL,
  old_dps_inv_status STRING NOT NULL,
  new_dps_inv_status STRING NOT NULL,
  det_link_id NUMERIC(29),
  det_link_id2 NUMERIC(29),
  insert_datetime DATETIME NOT NULL
)
;
