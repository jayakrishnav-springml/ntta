-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_FPL_MIGRATION_ERRORS_TRUNCATE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Fpl_Migration_Errors_Truncate
(
  environment STRING,
  target_database STRING,
  target_owner STRING,
  target_db_link STRING,
  facility_abbrev STRING,
  facility_name STRING,
  plaza_abbrev STRING,
  plaza_name STRING,
  lane_name STRING,
  error_code NUMERIC(29),
  error_message STRING,
  created_by STRING,
  date_created DATETIME,
  modified_by STRING,
  date_modified DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;
