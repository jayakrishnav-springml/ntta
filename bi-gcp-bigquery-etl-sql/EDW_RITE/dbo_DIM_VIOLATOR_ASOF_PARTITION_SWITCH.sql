## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DIM_VIOLATOR_ASOF_PARTITION_SWITCH.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dim_Violator_Asof_Partition_Switch
(
  violator_id INT64 NOT NULL,
  partition_date DATE NOT NULL,
  violator_type STRING NOT NULL,
  violator_fname STRING,
  violator_lname STRING,
  violator_fname2 STRING,
  violator_lname2 STRING,
  phone_nbr STRING,
  email_addr STRING,
  violator_addr_seq INT64,
  address1 STRING,
  address2 STRING,
  city STRING,
  state STRING NOT NULL,
  zip_code STRING NOT NULL,
  plus4 STRING,
  addr_status STRING,
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  vehicle_make STRING NOT NULL,
  vehicle_model STRING NOT NULL,
  vehicle_body STRING NOT NULL,
  vehicle_year STRING NOT NULL,
  vehicle_color STRING NOT NULL,
  vin STRING,
  date_created DATE NOT NULL,
  hv_flag INT64 NOT NULL,
  payment_plan_flag INT64 NOT NULL,
  insert_date DATETIME NOT NULL
)
;
