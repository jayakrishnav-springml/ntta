## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Unified_Violation_Base_N_Premium
(
  tart_id NUMERIC(29) NOT NULL,
  day_id INT64 NOT NULL,
  lane_viol_status STRING NOT NULL,
  disposition STRING NOT NULL,
  tag_id STRING NOT NULL,
  facility_id NUMERIC(29) NOT NULL,
  transaction_file_detail_id NUMERIC(29),
  iop INT64 NOT NULL,
  video INT64 NOT NULL,
  transaction_date DATETIME,
  toll_due NUMERIC(31, 2),
  ear_rev NUMERIC(35, 6),
  amount NUMERIC(31, 2),
  base_fee_type_id INT64,
  variable_fee_type_id INT64,
  iop_fee_type_id INT64,
  base_amount NUMERIC(33, 4),
  base_fee NUMERIC(33, 4),
  variable_fee NUMERIC(33, 4),
  base_transaction_fee NUMERIC(33, 4),
  variable_transaction_fee NUMERIC(33, 4),
  iop_transaction_fee NUMERIC(33, 4)
)
CLUSTER BY tart_id;
