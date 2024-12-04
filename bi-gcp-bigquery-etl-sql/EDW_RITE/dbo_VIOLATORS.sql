## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VIOLATORS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Violators
(
  violator_id INT64,
  violator_fname STRING,
  violator_lname STRING,
  violator_fname2 STRING NOT NULL,
  violator_lname2 STRING NOT NULL,
  violator_type STRING NOT NULL,
  hv_flag INT64 NOT NULL,
  phone_nbr STRING,
  email_addr STRING,
  license_plate_id INT64,
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  vehicle_make STRING NOT NULL,
  vehicle_model STRING NOT NULL,
  vehicle_body STRING NOT NULL,
  vehicle_year STRING NOT NULL,
  vehicle_color STRING NOT NULL,
  date_created DATE,
  docno STRING,
  vin STRING,
  last_update_date DATETIME
)
cluster by violator_id
;
