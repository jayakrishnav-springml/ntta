-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_EVENT_PARAMETERS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Event_Parameters
(
  event_pr_id INT64 NOT NULL,
  event_id FLOAT64 NOT NULL,
  pr_id INT64 NOT NULL,
  parameter_prompt STRING,
  manditory_flg STRING NOT NULL,
  order_seq INT64 NOT NULL,
  event_parameter_name STRING NOT NULL,
  created_by STRING NOT NULL,
  creation_date DATETIME NOT NULL,
  updated_by STRING NOT NULL,
  updated_date DATETIME NOT NULL,
  static_value STRING,
  textsize INT64,
  maxlength INT64,
  colspan INT64,
  default_value STRING,
  new_row STRING,
  auto_increment STRING,
  display_on_summary STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
