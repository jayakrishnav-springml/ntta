-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TSA_OWNER_TRANSACTION_FEES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Tsa_Owner_Transaction_Fees
(
  transaction_fee_id INT64 NOT NULL,
  fee_type_id INT64 NOT NULL,
  facility_id NUMERIC(29),
  fee_amount NUMERIC(33, 4) NOT NULL,
  is_percentage STRING NOT NULL,
  effective_date DATETIME,
  expiry_date DATETIME,
  created_by STRING,
  date_created DATETIME,
  modified_by STRING,
  date_modified DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;
