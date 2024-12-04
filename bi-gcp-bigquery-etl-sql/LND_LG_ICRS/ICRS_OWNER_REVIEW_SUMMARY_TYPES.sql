-- Translation time: 2024-06-04T07:59:17.388387Z
-- Translation job ID: 5118bff3-1545-4bd3-96b6-65be13aded87
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_ICRS/Tables/ICRS_OWNER_REVIEW_SUMMARY_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_ICRS.Icrs_Owner_Review_Summary_Types
(
  summary_type STRING NOT NULL,
  summary_type_descr STRING,
  interval_secs BIGNUMERIC(48, 10),
  last_update_date DATETIME,
  last_update_type STRING
)
;
