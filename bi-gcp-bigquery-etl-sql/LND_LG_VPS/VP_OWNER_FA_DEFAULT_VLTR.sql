-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_FA_DEFAULT_VLTR.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Fa_Default_Vltr
(
  dvltr_id NUMERIC(29) NOT NULL,
  agency_id NUMERIC(29) NOT NULL,
  fname STRING NOT NULL,
  lname STRING,
  address1 STRING NOT NULL,
  address2 STRING,
  city STRING NOT NULL,
  state STRING NOT NULL,
  zip_code STRING,
  plus4 STRING,
  phone STRING,
  email_addr STRING,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
