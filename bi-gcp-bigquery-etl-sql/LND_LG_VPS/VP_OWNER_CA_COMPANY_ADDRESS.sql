-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_CA_COMPANY_ADDRESS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Ca_Company_Address
(
  ca_company_id INT64 NOT NULL,
  ca_company_addr_seq INT64 NOT NULL,
  addr_status STRING NOT NULL,
  address1 STRING NOT NULL,
  address2 STRING,
  city STRING NOT NULL,
  state STRING NOT NULL,
  zip_code STRING,
  plus4 STRING,
  addr_source_date DATETIME NOT NULL,
  addr_comments STRING,
  comment_date DATETIME,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING,
  date_modified DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;
