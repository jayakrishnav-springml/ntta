-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_FA_AGENCY_CARDS_JN.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Fa_Agency_Cards_Jn
(
  jn_operation STRING NOT NULL,
  jn_oracle_user STRING NOT NULL,
  jn_datetime DATETIME NOT NULL,
  jn_notes STRING,
  jn_appln STRING,
  jn_session BIGNUMERIC(38),
  fa_agency_card_id NUMERIC(29) NOT NULL,
  agency_id NUMERIC(29),
  card_code STRING,
  card_nbr STRING,
  card_expires DATETIME,
  is_active STRING,
  charge_order INT64,
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
  nbr_of_consec_failures INT64,
  date_created DATETIME,
  created_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  scrub_seq_nbr NUMERIC(29),
  last_update_date DATETIME,
  last_update_type STRING
)
;
