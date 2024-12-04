-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_LB_FILE_DET_STATUS_HIST.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Lb_File_Det_Status_Hist
(
  id NUMERIC(29) NOT NULL,
  file_detail_id NUMERIC(29) NOT NULL,
  disposition_id NUMERIC(29) NOT NULL,
  additional_comments STRING NOT NULL,
  status_date DATETIME NOT NULL,
  amount_due NUMERIC(31, 2),
  disc_amt_due NUMERIC(31, 2),
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
