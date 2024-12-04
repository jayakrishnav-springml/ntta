-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_LB_FILE_HEADERS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Lb_File_Headers
(
  id BIGNUMERIC(48, 10) NOT NULL,
  file_number INT64 NOT NULL,
  file_type_id NUMERIC(29) NOT NULL,
  file_date DATETIME NOT NULL,
  deposit_date DATETIME,
  reversal_date DATETIME,
  record_count BIGNUMERIC(48, 10) NOT NULL,
  file_status_id BIGNUMERIC(48, 10) NOT NULL,
  failure_reason_id BIGNUMERIC(48, 10),
  additional_comments STRING,
  file_name STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
