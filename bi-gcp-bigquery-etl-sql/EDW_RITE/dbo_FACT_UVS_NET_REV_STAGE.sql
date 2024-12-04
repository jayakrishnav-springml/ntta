## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_UVS_NET_REV_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Uvs_Net_Rev_Stage
(
  lane_file_id STRING,
  tart_id INT64 NOT NULL,
  day_id INT64,
  pmty_id INT64 NOT NULL,
  ves_serial_no INT64,
  lane_id INT64,
  local_time DATETIME,
  vcly_id INT64 NOT NULL,
  avi_tag_status STRING,
  ear_rev NUMERIC(31, 2),
  pos_rev NUMERIC(31, 2),
  posted_revenue NUMERIC(31, 2),
  iop_rev NUMERIC(31, 2),
  toll_rev NUMERIC(31, 2),
  iop_flag INT64,
  txid_id INT64,
  deleted INT64,
  ttxn_id INT64,
  tag_id STRING,
  lvl_tvl STRING,
  source_code STRING,
  agency_id STRING,
  posted_date DATE,
  transaction_file_detail_id NUMERIC(29),
  license_plate_id INT64,
  lic_plate_nbr STRING,
  lic_plate_state STRING,
  acct_id INT64
)
;
