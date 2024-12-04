-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_ADJUSTMENT_REASONS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Adjustment_Reasons
(
  adj_reason_code STRING NOT NULL,
  adj_reason_code_descr STRING NOT NULL,
  adj_reason_code_display_descr STRING,
  order_by INT64,
  is_active STRING NOT NULL,
  is_credit_flag STRING,
  display_from_ui STRING,
  is_adjustment STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;