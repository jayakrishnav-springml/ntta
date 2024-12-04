-- Translation time: 2024-06-04T07:59:17.388387Z
-- Translation job ID: 5118bff3-1545-4bd3-96b6-65be13aded87
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_ICRS/Tables/ICRS_OWNER_VIOL_REJECT_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_ICRS.Icrs_Owner_Viol_Reject_Types
(
  viol_reject_type STRING NOT NULL,
  viol_reject_type_descr STRING NOT NULL,
  viol_reject_type_order NUMERIC(29),
  viol_reject_type_role_level NUMERIC(29),
  supervisor_only STRING,
  is_active STRING NOT NULL,
  is_closed STRING,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME,
  modified_by STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
