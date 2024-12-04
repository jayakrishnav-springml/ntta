## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_MISCLASS_ICRS_OLD.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Misclass_Icrs_Old
(
  lane_viol_id NUMERIC(29) NOT NULL,
  violation_id BIGNUMERIC(48, 10),
  lic_plate_nbr STRING,
  lic_plate_state STRING,
  violator_fname STRING,
  violator_lname STRING,
  violator_id NUMERIC(29),
  viol_date DATETIME NOT NULL,
  day_id STRING,
  hh STRING,
  toll_due NUMERIC(31, 2),
  daily_mode_cash_toll FLOAT64,
  vehicle_class NUMERIC(29),
  daily_mode_vehicle_class INT64,
  issue STRING,
  agency_id NUMERIC(29),
  lane_id NUMERIC(29) NOT NULL,
  viol_status STRING,
  image_1 STRING,
  image_2 STRING,
  image_3 STRING,
  image_4 STRING,
  image_5 STRING,
  image_6 STRING
)
;
