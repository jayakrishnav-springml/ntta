-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_PARAMETERS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Parameters
(
  pr_id INT64 NOT NULL,
  pt_id INT64 NOT NULL,
  parameter_name STRING NOT NULL,
  multi_select_flg STRING NOT NULL,
  parameter_prompt STRING,
  parameter_descr STRING,
  note STRING,
  sql_stmt STRING,
  display_column_cnt INT64,
  created_by STRING NOT NULL,
  creation_date DATETIME NOT NULL,
  updated_by STRING NOT NULL,
  updated_date DATETIME NOT NULL,
  textsize INT64,
  maxlength INT64,
  colspan INT64,
  default_value STRING,
  validation_id FLOAT64,
  dependency_sql STRING,
  parent_pr_id FLOAT64,
  multi_parent_pr_id STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
