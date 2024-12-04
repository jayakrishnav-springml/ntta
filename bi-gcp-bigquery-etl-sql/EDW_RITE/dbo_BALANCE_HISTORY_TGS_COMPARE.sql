## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_BALANCE_HISTORY_TGS_COMPARE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Balance_History_Tgs_Compare
(
  acct_id NUMERIC(29) NOT NULL,
  date_id INT64 NOT NULL,
  balance BIGNUMERIC(40, 2),
  end_balance BIGNUMERIC(40, 2),
  debit BIGNUMERIC(40, 2) NOT NULL,
  credit BIGNUMERIC(40, 2) NOT NULL,
  toll_cnt INT64 NOT NULL
)
;
