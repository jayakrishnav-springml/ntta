-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_GL_TXN_SUMMARIES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Gl_Txn_Summaries
(
  appl_name STRING NOT NULL,
  summ_id NUMERIC(29) NOT NULL,
  batch_id NUMERIC(29) NOT NULL,
  link_id NUMERIC(29) NOT NULL,
  gl_date DATETIME NOT NULL,
  gtsm_id INT64 NOT NULL,
  gl_pmt_type_id INT64,
  pos_id INT64,
  merchant_id STRING,
  card_code STRING,
  amount NUMERIC(31, 2) NOT NULL,
  gl_status STRING NOT NULL,
  descriptor STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  posted_date DATETIME,
  reject_date DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;
