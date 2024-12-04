## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_BALANCE_HISTORY_TGS_TRANS_VPS_TGS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Balance_History_Tgs_Trans_Vps_Tgs
(
  acct_id NUMERIC(29) NOT NULL,
  date_id_below_0 INT64,
  balance_below_0 BIGNUMERIC(40, 2),
  total_toll_below_0 BIGNUMERIC(40, 2),
  total_charge_below_0 BIGNUMERIC(40, 2),
  date_id_above_0 INT64,
  balance_above_0 BIGNUMERIC(40, 2),
  total_toll_above_0 BIGNUMERIC(40, 2),
  total_charge_above_0 BIGNUMERIC(40, 2),
  zero_balance_days INT64
)
;
