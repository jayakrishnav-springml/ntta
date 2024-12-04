-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_FA_ACKN_BATCH.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Fa_Ackn_Batch
(
  batch_id NUMERIC(29) NOT NULL,
  agency_id NUMERIC(29),
  file_type STRING NOT NULL,
  orig_file_sequence NUMERIC(29),
  orig_file_name STRING NOT NULL,
  ackn_file_name STRING NOT NULL,
  ackn_txn_count NUMERIC(29),
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_sent DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;
