-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/FPL_OWNER_FACILITIES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Fpl_Owner_Facilities
(
  plgp_id NUMERIC(29),
  abbrev STRING NOT NULL,
  name STRING NOT NULL,
  note STRING,
  created_by STRING NOT NULL,
  creation_date DATETIME NOT NULL,
  updated_by STRING NOT NULL,
  facs_id NUMERIC(29) NOT NULL,
  facy_id NUMERIC(29) NOT NULL,
  agcy_id NUMERIC(29) NOT NULL,
  locs_id NUMERIC(29),
  locs_id_located_at NUMERIC(29),
  updated_date DATETIME NOT NULL,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by facs_id
;
