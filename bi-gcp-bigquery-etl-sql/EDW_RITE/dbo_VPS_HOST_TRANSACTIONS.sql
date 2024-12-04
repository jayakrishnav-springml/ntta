## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VPS_HOST_TRANSACTIONS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Vps_Host_Transactions
(
  day_id INT64,
  month_id INT64,
  transaction_id NUMERIC(29) NOT NULL,
  lane_viol_id NUMERIC(29),
  violation_id NUMERIC(29),
  violator_id NUMERIC(29),
  lane_id INT64 NOT NULL,
  vehicle_class INT64,
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  license_plate_id INT64 NOT NULL,
  vtoll_send_date DATETIME,
  posted_date DATE,
  transaction_date DATE,
  viol_date DATE,
  viol_time_id INT64 NOT NULL,
  viol_type STRING,
  source_code STRING,
  reason_code STRING,
  agency_code STRING NOT NULL,
  tag_id STRING,
  tt_id INT64,
  disposition STRING NOT NULL,
  violation_or_zipcash STRING,
  earned_revenue NUMERIC(31, 2) NOT NULL,
  posted_revenue NUMERIC(31, 2) NOT NULL,
  last_update_date DATETIME
)
cluster by TRANSACTION_ID
;
