-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_GL_TXN_DETAILS_CT_INS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Gl_Txn_Details_Ct_Ins
(
  gl_det_id NUMERIC(29) NOT NULL,
  source_table STRING NOT NULL,
  source_column_1 STRING NOT NULL,
  source_column_2 STRING,
  source_column_3 STRING,
  source_column_4 STRING,
  source_column_value_1 NUMERIC(29) NOT NULL,
  source_column_value_2 NUMERIC(29),
  source_column_value_3 NUMERIC(29),
  source_column_value_4 NUMERIC(29),
  amount NUMERIC(31, 2) NOT NULL,
  txn_date DATETIME NOT NULL,
  gtsm_id INT64 NOT NULL,
  summ_id INT64,
  pos_id INT64,
  merchant_id STRING,
  card_code STRING,
  gptm_id INT64,
  det_link_id NUMERIC(29) NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  insert_datetime DATETIME NOT NULL
)
;
