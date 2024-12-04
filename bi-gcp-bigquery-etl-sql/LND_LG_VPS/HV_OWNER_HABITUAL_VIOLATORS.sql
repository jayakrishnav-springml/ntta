-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/HV_OWNER_HABITUAL_VIOLATORS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Hv_Owner_Habitual_Violators
(
  violator_id FLOAT64 NOT NULL,
  vid_seq FLOAT64 NOT NULL,
  hv_flag STRING,
  hv_designation_start_date DATE,
  hv_designation_end_date DATE,
  first_qualified_tran_date DATE,
  last_qualified_tran_date DATE,
  qualified_transactions_count FLOAT64,
  qualified_invoices_count FLOAT64,
  admin_hearing_county STRING,
  date_created DATE NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATE,
  modified_by STRING,
  last_update_type STRING,
  last_update_date DATETIME NOT NULL
)
;
