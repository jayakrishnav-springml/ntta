-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_FA_AGENCY_CARDS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Fa_Agency_Cards
(
  fa_agency_card_id NUMERIC(29) NOT NULL,
  agency_id NUMERIC(29) NOT NULL,
  card_code STRING NOT NULL,
  card_nbr STRING NOT NULL,
  card_expires DATETIME NOT NULL,
  is_active STRING NOT NULL,
  charge_order INT64 NOT NULL,
  name_on_card STRING,
  address1 STRING,
  address2 STRING,
  city STRING,
  state STRING,
  zip_code STRING,
  plus4 STRING,
  last_charge_attempt_date DATETIME,
  last_charge_successful STRING,
  last_charge_fail_date DATETIME,
  nbr_of_consec_failures INT64 NOT NULL,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
