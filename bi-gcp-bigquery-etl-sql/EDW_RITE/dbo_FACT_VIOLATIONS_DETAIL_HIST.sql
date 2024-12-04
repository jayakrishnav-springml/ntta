## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_VIOLATIONS_DETAIL_HIST.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Violations_Detail_Hist
(
  partition_date DATE,
  day_id STRING,
  lane_id NUMERIC(29) NOT NULL,
  violation_id BIGNUMERIC(48, 10) NOT NULL,
  viol_status STRING NOT NULL,
  status_descr STRING,
  status_date DATETIME NOT NULL,
  viol_date DATETIME NOT NULL,
  viol_type STRING NOT NULL,
  toll_due NUMERIC(31, 2) NOT NULL,
  toll_paid NUMERIC(31, 2) NOT NULL,
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  vcly_id NUMERIC(29) NOT NULL,
  vehicle_class NUMERIC(29) NOT NULL,
  driver_lic_state STRING,
  tolltag_acct_id INT64,
  tag_id STRING,
  agency_id STRING,
  excused_reason STRING,
  date_excused DATETIME,
  violator_id NUMERIC(29),
  review_status STRING,
  rev_status_descr STRING,
  lane_viol_id NUMERIC(29),
  transaction_id NUMERIC(29),
  disposition STRING,
  origin_type STRING,
  current_type STRING,
  transaction_file_detail_id NUMERIC(29),
  post_date DATETIME,
  address1 STRING,
  address2 STRING,
  city STRING,
  state STRING,
  zip_code STRING,
  addr_status STRING
)
;
