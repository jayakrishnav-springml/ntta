## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_TEMP_TGS_PREV_MONTH_BAL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Temp_Tgs_Prev_Month_Bal
(
  acct_id NUMERIC(29),
  posted_date DATE,
  posted_balance NUMERIC(31, 2)
)
;