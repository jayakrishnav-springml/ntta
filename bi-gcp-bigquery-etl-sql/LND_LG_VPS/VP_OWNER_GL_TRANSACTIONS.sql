-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_GL_TRANSACTIONS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Gl_Transactions
(
  gl_transaction_id INT64 NOT NULL,
  account STRING NOT NULL,
  fund_code STRING NOT NULL,
  dept_id STRING NOT NULL,
  source_table STRING NOT NULL,
  source_column_primary STRING NOT NULL,
  source_column_secondary STRING,
  source_id_primary BIGNUMERIC(48, 10) NOT NULL,
  source_id_secondary BIGNUMERIC(48, 10),
  amount NUMERIC(31, 2) NOT NULL,
  transaction_date DATETIME NOT NULL,
  transaction_type STRING NOT NULL,
  payment_xref_id INT64,
  gl_status STRING NOT NULL,
  ps_gl_line_nbr INT64,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  date_modified DATETIME,
  modified_by STRING,
  class STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
