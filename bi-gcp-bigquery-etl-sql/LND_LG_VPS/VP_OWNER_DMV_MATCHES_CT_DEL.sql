-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_DMV_MATCHES_CT_DEL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Dmv_Matches_Ct_Del
(
  id BIGNUMERIC(48, 10) NOT NULL,
  violation_id BIGNUMERIC(48, 10) NOT NULL,
  violator_id NUMERIC(29) NOT NULL,
  full_name STRING NOT NULL,
  first_name STRING,
  middle_name STRING,
  last_name STRING,
  street STRING,
  city STRING,
  zip STRING,
  plus4 STRING,
  type STRING,
  date_created DATETIME,
  date_modified DATETIME,
  modified_by STRING,
  created_by STRING,
  insert_datetime DATETIME NOT NULL
)
;
