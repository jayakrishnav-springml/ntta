-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_FA_FLEET_FILE_BATCH.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Fa_Fleet_File_Batch
(
  agency_id NUMERIC(29) NOT NULL,
  file_sequence NUMERIC(29) NOT NULL,
  file_create_date DATETIME NOT NULL,
  record_count NUMERIC(29) NOT NULL,
  file_type STRING NOT NULL,
  file_name STRING NOT NULL,
  records_processed NUMERIC(29) NOT NULL,
  error_records NUMERIC(29) NOT NULL,
  process_date DATETIME NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
