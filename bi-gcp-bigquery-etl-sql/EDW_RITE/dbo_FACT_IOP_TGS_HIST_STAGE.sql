## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_IOP_TGS_HIST_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Iop_Tgs_Hist_Stage
(
  partition_date DATE,
  iop_txn_id INT64,
  rownum INT64,
  day_id STRING,
  tag_id STRING NOT NULL,
  txn_date DATETIME,
  posted_date DATETIME,
  tag_identifier STRING,
  txn_type STRING,
  txn_status STRING,
  disposition STRING NOT NULL,
  source_agcy_id INT64,
  hia_agency_id INT64,
  source_code STRING NOT NULL,
  source_txn_id INT64,
  lane_id NUMERIC(29),
  loc STRING,
  tvl_tag_status STRING,
  lic_plate_state STRING,
  lic_plate_nbr STRING,
  earned_class INT64,
  posted_class INT64,
  earned_revenue NUMERIC(31, 2),
  posted_revenue NUMERIC(31, 2)
)
;
