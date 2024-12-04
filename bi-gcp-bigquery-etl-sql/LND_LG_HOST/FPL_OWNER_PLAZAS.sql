-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/FPL_OWNER_PLAZAS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Fpl_Owner_Plazas
(
  abbrev STRING NOT NULL,
  name STRING NOT NULL,
  note STRING,
  created_by STRING NOT NULL,
  creation_date DATETIME NOT NULL,
  updated_by STRING NOT NULL,
  updated_date DATETIME NOT NULL,
  plaz_id NUMERIC(29) NOT NULL,
  plzy_id NUMERIC(29) NOT NULL,
  facs_id NUMERIC(29) NOT NULL,
  locs_id NUMERIC(29),
  old_abbrev STRING,
  lc_plaza_nbr NUMERIC(29),
  plgp_id NUMERIC(29),
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by plaz_id
;
