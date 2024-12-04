## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_BALANCE_HISTORY_TGS_TRANS_VPS_TGS_DATES.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Balance_History_Tgs_Trans_Vps_Tgs_Dates
(
  date_below_0 DATE,
  date_above_0 DATE,
  acct_id NUMERIC(29) NOT NULL
)
;
