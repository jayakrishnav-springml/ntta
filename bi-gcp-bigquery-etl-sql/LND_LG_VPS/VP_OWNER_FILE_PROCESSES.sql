-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_FILE_PROCESSES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_File_Processes
(
  process_name STRING NOT NULL,
  source_directory_name STRING NOT NULL,
  destination_directory_path STRING,
  archive_directory_name STRING,
  unprocessed_directory_name STRING,
  error_directory_name STRING,
  extra_encryption_info STRING,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  encryption_extension STRING,
  is_active STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
