## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_ACCOUNT_VIOLATION_TGS_VPS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Account_Violation_Tgs_Vps
(
  acct_id NUMERIC(29) NOT NULL,
  violation_id BIGNUMERIC(48, 10) NOT NULL,
  violation_day_count INT64,
  fact_balance_history_tgs_trans_date_id DATE,
  viol_date_id INT64,
  vps_toll_paid NUMERIC(31, 2) NOT NULL,
  vps_toll_due NUMERIC(31, 2) NOT NULL,
  viol_status STRING NOT NULL
)
;
