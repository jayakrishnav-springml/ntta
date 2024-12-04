-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_VIOL_INVOICES_CT_DEL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Viol_Invoices_Ct_Del
(
  viol_invoice_id NUMERIC(29) NOT NULL,
  invoice_date DATETIME NOT NULL,
  invoice_amount NUMERIC(33, 4) NOT NULL,
  invoice_amt_paid NUMERIC(33, 4),
  viol_inv_batch_id NUMERIC(29) NOT NULL,
  viol_inv_status STRING NOT NULL,
  violator_addr_seq INT64 NOT NULL,
  violator_id NUMERIC(29) NOT NULL,
  curr_due_date DATETIME,
  mail_return_date DATETIME,
  inv_closed_date DATETIME,
  modified_by STRING,
  date_modified DATETIME,
  contested STRING,
  excused_by STRING,
  date_excused DATETIME,
  inv_excused_reason STRING,
  status_date DATETIME,
  comment_date DATETIME,
  dps_date DATETIME,
  dps_reject_date DATETIME,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  gl_status STRING NOT NULL,
  remailed STRING,
  cacctinvxr_viol_invoice_id NUMERIC(29),
  invoice_amt_disc NUMERIC(33, 4),
  ca_inv_status STRING NOT NULL,
  is_vtoll STRING NOT NULL,
  dps_inv_status STRING NOT NULL,
  is_vea STRING NOT NULL,
  det_link_id NUMERIC(29),
  vip_hold STRING NOT NULL,
  source_code STRING,
  inv_admin_fee NUMERIC(33, 4),
  close_out_eligibility_date DATETIME,
  close_out_status STRING,
  close_out_date DATETIME,
  close_out_type STRING,
  inv_admin_fee2 NUMERIC(33, 4),
  inv_admin_fee_post_date DATETIME,
  inv_admin_fee_2_post_date DATETIME,
  insert_datetime DATETIME NOT NULL
)
;
