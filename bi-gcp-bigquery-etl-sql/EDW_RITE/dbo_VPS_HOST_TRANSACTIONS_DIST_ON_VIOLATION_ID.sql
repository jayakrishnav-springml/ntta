## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VPS_HOST_TRANSACTIONS_DIST_ON_VIOLATION_ID.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Vps_Host_Transactions_Dist_On_Violation_Id
(
  transaction_id NUMERIC(29) NOT NULL,
  violator_id NUMERIC(29),
  lane_id INT64 NOT NULL,
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  transaction_date DATE,
  viol_date DATE,
  viol_time_id INT64 NOT NULL,
  viol_type STRING,
  violation_id NUMERIC(29),
  lane_viol_id NUMERIC(29),
  earned_revenue NUMERIC(31, 2) NOT NULL,
  posted_revenue NUMERIC(31, 2) NOT NULL,
  source_code STRING,
  agency_code STRING NOT NULL,
  tag_id STRING,
  disposition STRING NOT NULL,
  reason_code STRING,
  posted_date DATE,
  violation_or_zipcash STRING,
  last_update_date DATETIME
)
cluster by VIOLATION_ID
;
