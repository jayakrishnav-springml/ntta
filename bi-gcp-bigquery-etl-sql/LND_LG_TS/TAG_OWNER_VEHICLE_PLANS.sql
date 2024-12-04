-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_VEHICLE_PLANS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Vehicle_Plans
(
  vpn_id INT64 NOT NULL,
  vpn_plan STRING NOT NULL,
  vpn_abbrev STRING,
  vpn_desc STRING NOT NULL,
  vpn_order INT64 NOT NULL,
  is_active STRING NOT NULL,
  group_type STRING NOT NULL,
  date_created DATETIME NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  created_by STRING NOT NULL,
  vpn_class STRING NOT NULL,
  vpn_agcy_id BIGNUMERIC(38),
  last_update_date DATETIME,
  last_update_type STRING
)
;
