## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_TRIP_ANALYSIS_NEW_SET.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Trip_Analysis_New_Set
(
  trip_id BIGNUMERIC(38),
  txn_type STRING NOT NULL,
  acct_id INT64,
  tag_id STRING NOT NULL,
  violator_id NUMERIC(29) NOT NULL,
  license_plate_id INT64,
  vehicle_class NUMERIC(29) NOT NULL,
  trip_duration_minutes INT64,
  trip_amount BIGNUMERIC(40, 2),
  start_facility_id NUMERIC(29) NOT NULL,
  start_plaza_id NUMERIC(29) NOT NULL,
  start_direction STRING,
  start_day_id INT64,
  start_time_id INT64,
  end_facility_id NUMERIC(29) NOT NULL,
  end_plaza_id NUMERIC(29) NOT NULL,
  end_direction STRING,
  end_day_id INT64,
  end_time_id INT64
)
;
