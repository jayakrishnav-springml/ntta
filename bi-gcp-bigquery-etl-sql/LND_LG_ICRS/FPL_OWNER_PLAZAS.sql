-- Translation time: 2024-06-04T07:59:17.388387Z
-- Translation job ID: 5118bff3-1545-4bd3-96b6-65be13aded87
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_ICRS/Tables/FPL_OWNER_PLAZAS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_ICRS.Fpl_Owner_Plazas
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
  lc_plaza_nbr INT64,
  plgp_id INT64,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
CLUSTER BY plaz_id
;
