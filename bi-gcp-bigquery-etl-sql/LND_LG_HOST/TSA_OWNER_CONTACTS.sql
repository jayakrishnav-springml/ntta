-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TSA_OWNER_CONTACTS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Tsa_Owner_Contacts
(
  contact_id NUMERIC(29) NOT NULL,
  first_name STRING NOT NULL,
  last_name STRING NOT NULL,
  company_id NUMERIC(29),
  email_address STRING,
  is_support STRING NOT NULL,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  company STRING,
  job_title STRING,
  badge_number STRING,
  middle_initial STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
