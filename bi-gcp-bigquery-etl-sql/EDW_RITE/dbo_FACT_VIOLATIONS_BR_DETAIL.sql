## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_VIOLATIONS_BR_DETAIL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Violations_Br_Detail
(
  day_id INT64,
  month_id INT64,
  violation_id INT64 NOT NULL,
  viol_date DATE,
  business_type STRING,
  txn_name STRING NOT NULL,
  lane_id INT64 NOT NULL,
  vcly_id INT64 NOT NULL,
  vehicle_class INT64 NOT NULL,
  toll_due NUMERIC(31, 2) NOT NULL,
  toll_paid NUMERIC(31, 2) NOT NULL
)
CLUSTER BY violation_id;
