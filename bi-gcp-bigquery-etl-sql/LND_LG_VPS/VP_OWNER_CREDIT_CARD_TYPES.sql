-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_CREDIT_CARD_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Credit_Card_Types
(
  card_code STRING NOT NULL,
  card_name STRING NOT NULL,
  card_type_order INT64,
  card_nbr_prefix STRING,
  active_flag STRING NOT NULL,
  card_short_name STRING NOT NULL,
  validation_regex STRING,
  invalid_message STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
