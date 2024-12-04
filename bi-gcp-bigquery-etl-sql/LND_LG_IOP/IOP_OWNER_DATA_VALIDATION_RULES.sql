-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_DATA_VALIDATION_RULES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Data_Validation_Rules
(
  validation_id FLOAT64 NOT NULL,
  validation_rule STRING NOT NULL,
  data_type STRING,
  format_string STRING,
  reg_exp STRING,
  included_chars STRING,
  excluded_chars STRING,
  sql_validation STRING,
  error_message STRING,
  nullable STRING,
  date_created DATETIME,
  date_modified DATETIME,
  modified_by STRING,
  created_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
