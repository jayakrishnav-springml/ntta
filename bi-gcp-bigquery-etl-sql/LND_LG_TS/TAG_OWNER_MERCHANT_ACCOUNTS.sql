-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_MERCHANT_ACCOUNTS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Merchant_Accounts
(
  merch_acct_id INT64 NOT NULL,
  merch_acct_descr STRING NOT NULL,
  card_code STRING NOT NULL,
  credit_source STRING NOT NULL,
  effective_date DATETIME NOT NULL,
  expiration_date DATETIME,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by merch_acct_id
;
