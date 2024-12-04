## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_VIOLATIONS_DETAIL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Violations_Detail
(
  day_id INT64,
  month_id INT64,
  lane_id INT64 NOT NULL,
  violation_id INT64 NOT NULL,
  viol_status STRING NOT NULL,
  status_descr STRING,
  status_date DATETIME NOT NULL,
  viol_date DATETIME NOT NULL,
  viol_type STRING NOT NULL,
  toll_due NUMERIC(31, 2) NOT NULL,
  toll_paid NUMERIC(31, 2) NOT NULL,
  license_plate_id INT64 NOT NULL,
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  vcly_id INT64 NOT NULL,
  vehicle_class INT64 NOT NULL,
  driver_lic_state STRING,
  acct_id INT64 NOT NULL,
  tag_id STRING NOT NULL,
  tt_id INT64 NOT NULL,
  agency_id STRING NOT NULL,
  excused_reason STRING,
  date_excused DATETIME,
  excused_by STRING,
  violator_id NUMERIC(29) NOT NULL,
  review_status STRING,
  rev_status_descr STRING,
  lane_viol_id NUMERIC(29) NOT NULL,
  transaction_id NUMERIC(29) NOT NULL,
  disposition STRING,
  origin_type STRING,
  current_type STRING,
  transaction_file_detail_id NUMERIC(29) NOT NULL,
  post_date DATETIME,
  dmv_sts STRING NOT NULL,
  txn_name STRING NOT NULL,
  fleet_flag INT64 NOT NULL,
  last_update_date DATETIME
)
CLUSTER BY violation_id;
