-- Translation time: 2024-06-04T07:59:17.388387Z
-- Translation job ID: 5118bff3-1545-4bd3-96b6-65be13aded87
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_ICRS/Tables/ICRS_OWNER_QA_STATUS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_ICRS.Icrs_Owner_Qa_Status
(
  qa_status_code STRING NOT NULL,
  qa_status_descr STRING NOT NULL,
  is_active STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
