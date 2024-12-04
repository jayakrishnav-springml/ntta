-- Translation time: 2024-06-04T07:59:17.388387Z
-- Translation job ID: 5118bff3-1545-4bd3-96b6-65be13aded87
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_ICRS/Tables/FPL_OWNER_FACILITIES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_ICRS.Fpl_Owner_Facilities
(
  plgp_id INT64,
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
CLUSTER BY facs_id
;
