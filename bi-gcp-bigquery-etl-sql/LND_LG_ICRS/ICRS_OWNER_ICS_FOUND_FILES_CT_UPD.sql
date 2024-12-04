-- Translation time: 2024-06-04T07:59:17.388387Z
-- Translation job ID: 5118bff3-1545-4bd3-96b6-65be13aded87
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_ICRS/Tables/ICRS_OWNER_ICS_FOUND_FILES_CT_UPD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_ICRS.Icrs_Owner_Ics_Found_Files_Ct_Upd
(
  ff_id NUMERIC(29) NOT NULL,
  dir_id NUMERIC(29),
  fhl_id NUMERIC(29),
  file_full_name STRING,
  file_size_bytes NUMERIC(29),
  file_type STRING,
  file_created_date DATETIME,
  date_found DATETIME,
  last_seen_date DATETIME,
  date_created DATETIME,
  created_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  status STRING,
  tag_fhd_id NUMERIC(29),
  err_comment STRING,
  file_size_bytes_old NUMERIC(29),
  archive_location STRING,
  posted_date DATETIME,
  viol_date DATETIME,
  is_primary STRING,
  vendor STRING,
  dir_name STRING,
  insert_datetime DATETIME NOT NULL
)
;
