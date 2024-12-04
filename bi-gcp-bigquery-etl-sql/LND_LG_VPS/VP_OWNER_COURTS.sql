-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_COURTS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Courts
(
  court_id INT64 NOT NULL,
  court_name STRING NOT NULL,
  address1 STRING NOT NULL,
  address2 STRING,
  city STRING NOT NULL,
  state STRING NOT NULL,
  zip_code STRING,
  plus4 STRING,
  judge STRING,
  court_cost NUMERIC(31, 2),
  county STRING NOT NULL,
  phone_nbr STRING,
  precinct STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
