-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/FPL_OWNER_HUBS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Fpl_Owner_Hubs
(
  hub_id STRING NOT NULL,
  abbrev STRING NOT NULL,
  hub_descr STRING NOT NULL,
  is_active STRING NOT NULL,
  hub_home_ind STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  bulk_days STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
