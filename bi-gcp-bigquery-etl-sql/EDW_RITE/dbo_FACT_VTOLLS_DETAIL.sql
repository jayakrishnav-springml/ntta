## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_VTOLLS_DETAIL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Vtolls_Detail
(
  day_id INT64,
  month_id INT64,
  transaction_id NUMERIC(29) NOT NULL,
  lane_viol_id NUMERIC(29),
  violation_id INT64,
  tt_id INT64 NOT NULL,
  agency_id STRING NOT NULL,
  lane_id INT64,
  lic_plate_state STRING NOT NULL,
  license_plate_id INT64 NOT NULL,
  vtoll_send_date DATETIME,
  vehicle_class INT64,
  vcly_id INT64 NOT NULL,
  source_code STRING NOT NULL,
  disposition STRING NOT NULL,
  posted_date DATE,
  pos_rev NUMERIC(31, 2) NOT NULL,
  act_rev NUMERIC(31, 2) NOT NULL,
  last_update_date DATETIME
)
;
