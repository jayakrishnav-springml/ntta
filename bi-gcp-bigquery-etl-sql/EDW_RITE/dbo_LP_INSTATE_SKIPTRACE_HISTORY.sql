## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_LP_INSTATE_SKIPTRACE_HISTORY.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Lp_Instate_Skiptrace_History
(
  gen_month INT64 NOT NULL,
  lp_seq_no INT64 NOT NULL,
  lic_plate STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  min_txn_date DATE NOT NULL,
  lp_flag INT64 NOT NULL,
  toll_due BIGNUMERIC(40, 2) NOT NULL,
  gen_date DATETIME NOT NULL
)
cluster by gen_month,lp_seq_no
;
