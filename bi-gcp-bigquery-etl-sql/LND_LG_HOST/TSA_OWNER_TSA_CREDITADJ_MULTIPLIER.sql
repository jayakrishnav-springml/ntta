-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TSA_OWNER_TSA_CREDITADJ_MULTIPLIER.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Tsa_Owner_Tsa_CreditAdj_Multiplier
(
  subscriber_id STRING,
  event_name STRING,
  dispostion_reason_code STRING,
  toll_multiplier INT64,
  base_multiplier INT64,
  variable_multiplier INT64,
  iop_multiplier INT64,
  last_update_date DATETIME,
  last_update_type STRING
)
;
