-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_INCREMENT_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Increment_Types
(
  increment_type_id FLOAT64 NOT NULL,
  increment_type STRING,
  min_value FLOAT64,
  max_value FLOAT64,
  last_update_date DATETIME,
  last_update_type STRING
)
;