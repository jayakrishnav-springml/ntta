-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/HV_OWNER_HV_DESIGNATED_VIOLATIONS_CT_DEL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Hv_Owner_Hv_Designated_Violations_Ct_Del
(
  hv_desgn_viol_id FLOAT64 NOT NULL,
  violator_id NUMERIC(29) NOT NULL,
  vid_seq NUMERIC(29) NOT NULL,
  admin_hearing_county STRING,
  violation_id FLOAT64 NOT NULL,
  viol_date DATE,
  viol_status STRING NOT NULL,
  lane_id FLOAT64,
  post_date DATE,
  toll_due NUMERIC(33, 4),
  fine_amount NUMERIC(33, 4),
  is_1n_admin_fee STRING,
  is_2n_admin_fee STRING,
  transaction_county STRING,
  viol_invoice_id FLOAT64,
  statement_id FLOAT64,
  statement_date DATE,
  hv_job_run_date DATE NOT NULL,
  date_created DATE NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATE,
  modified_by STRING,
  insert_datetime DATETIME NOT NULL
)
;
