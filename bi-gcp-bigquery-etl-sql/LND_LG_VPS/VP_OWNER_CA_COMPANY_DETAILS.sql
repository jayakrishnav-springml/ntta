-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_CA_COMPANY_DETAILS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Ca_Company_Details
(
  ca_company_id INT64 NOT NULL,
  company_comments STRING,
  ca_company_seq_id INT64 NOT NULL,
  account STRING NOT NULL,
  dept_id STRING NOT NULL,
  fund_code STRING NOT NULL,
  is_active STRING NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  date_modified DATETIME,
  modified_by STRING,
  transfer_address STRING,
  transfer_user STRING,
  transfer_pwd STRING,
  transfer_directory STRING,
  class STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
