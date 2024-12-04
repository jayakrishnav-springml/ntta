-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_EVENTS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Events
(
  event_id FLOAT64 NOT NULL,
  parent_event_id FLOAT64,
  event_type_id FLOAT64 NOT NULL,
  event_name STRING NOT NULL,
  description STRING,
  runtime_limit FLOAT64,
  eem_id FLOAT64,
  is_active STRING NOT NULL,
  execution_string STRING,
  scheduleable STRING NOT NULL,
  onload STRING,
  jscode STRING,
  ec_id NUMERIC(29),
  event_short_name STRING,
  footer_text STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
