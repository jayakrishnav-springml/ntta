-- Translation time: 2024-06-04T07:59:17.388387Z
-- Translation job ID: 5118bff3-1545-4bd3-96b6-65be13aded87
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_ICRS/Tables/ICRS_OWNER_EXCUSAL_REASONS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_ICRS.Icrs_Owner_Excusal_Reasons
(
  excused_reason STRING NOT NULL,
  excused_reas_descr STRING NOT NULL,
  excused_reas_order INT64,
  is_active STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
