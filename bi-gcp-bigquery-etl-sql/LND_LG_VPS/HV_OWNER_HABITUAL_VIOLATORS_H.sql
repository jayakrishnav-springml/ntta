-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/HV_OWNER_HABITUAL_VIOLATORS_H.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Hv_Owner_Habitual_Violators_H
(
  dml_date DATETIME,
  dml_performed_by STRING,
  dml_command STRING,
  violator_id BIGNUMERIC(48, 10) NOT NULL,
  vid_seq BIGNUMERIC(48, 10) NOT NULL,
  hv_flag STRING,
  hv_designation_start_date DATETIME,
  hv_designation_end_date DATETIME,
  first_qualified_tran_date DATETIME,
  last_qualified_tran_date DATETIME,
  qualified_transactions_count BIGNUMERIC(48, 10),
  qualified_invoices_count BIGNUMERIC(48, 10),
  admin_hearing_county STRING,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME,
  modified_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
