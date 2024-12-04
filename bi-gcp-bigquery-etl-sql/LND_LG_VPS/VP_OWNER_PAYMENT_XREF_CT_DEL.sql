-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_PAYMENT_XREF_CT_DEL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Payment_Xref_Ct_Del
(
  payment_xref_id INT64 NOT NULL,
  payment_line_item_id INT64 NOT NULL,
  viol_invoice_id FLOAT64,
  violation_id FLOAT64,
  unpaid_toll_id INT64,
  split_amount NUMERIC(33, 4) NOT NULL,
  payment_status STRING NOT NULL,
  transaction_type STRING NOT NULL,
  gl_status STRING NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  det_link_id NUMERIC(29),
  ol_det_id NUMERIC(29),
  vbi_vbi_invoice_id NUMERIC(29),
  insert_datetime DATETIME NOT NULL
)
;
