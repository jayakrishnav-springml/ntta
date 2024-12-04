## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_ACCT_BALANCE_TGS_DAILY_SUMMARY_STARTING_BALANCES.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Acct_Balance_Tgs_Daily_Summary_Starting_Balances
(
  acct_id NUMERIC(29) NOT NULL,
  date_id INT64,
  date_year STRING NOT NULL,
  total_toll BIGNUMERIC(40, 2),
  total_charge BIGNUMERIC(40, 2),
  balance BIGNUMERIC(40, 2)
)
;
