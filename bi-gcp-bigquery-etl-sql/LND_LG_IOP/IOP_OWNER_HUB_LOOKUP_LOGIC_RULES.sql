-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_HUB_LOOKUP_LOGIC_RULES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Hub_Lookup_Logic_Rules
(
  hlkl_id NUMERIC(29),
  status STRING NOT NULL,
  source_type INT64 NOT NULL,
  is_active STRING,
  priority INT64,
  attribute_1 STRING,
  date_created DATETIME,
  date_modified DATETIME,
  created_by STRING,
  modified_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
