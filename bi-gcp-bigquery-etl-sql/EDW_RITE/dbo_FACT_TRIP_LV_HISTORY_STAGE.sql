## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_TRIP_LV_HISTORY_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Trip_Lv_History_Stage
(
  trhl_id BIGNUMERIC(38),
  tart_id NUMERIC(29),
  license_plate_id INT64 NOT NULL,
  trip_id BIGNUMERIC(38),
  second_id INT64,
  day_id INT64,
  time_id INT64,
  vehicle_class NUMERIC(29) NOT NULL,
  lane_direction STRING,
  lane_id NUMERIC(29) NOT NULL,
  plaza_id NUMERIC(29) NOT NULL,
  facility_id NUMERIC(29) NOT NULL,
  mileage NUMERIC(31, 2),
  amount NUMERIC(31, 2) NOT NULL,
  duration_minutes INT64,
  violator_id NUMERIC(29) NOT NULL
)
;
