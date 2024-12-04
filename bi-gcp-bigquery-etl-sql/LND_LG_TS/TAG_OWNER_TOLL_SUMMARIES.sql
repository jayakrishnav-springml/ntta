-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_TOLL_SUMMARIES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Toll_Summaries
(
  toll_trxn_count INT64,
  toll_trxn_amt NUMERIC(31, 2),
  trxns_per_tag NUMERIC(32, 3),
  prev_7_day_avg NUMERIC(32, 3),
  toll_date DATETIME,
  toll_posted_count INT64,
  toll_posted_amt NUMERIC(31, 2),
  source_code STRING,
  credit_amt NUMERIC(31, 2),
  toll_credit NUMERIC(29),
  acct_type_code STRING,
  last_update_type STRING,
  last_update_date DATETIME
)
;
