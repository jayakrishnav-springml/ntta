## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_IOP_TGS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Iop_Tgs
(
  day_id INT64,
  month_id INT64,
  tag_id STRING,
  tt_id INT64,
  txn_date DATETIME NOT NULL,
  entry_txn_date DATETIME,
  posted_date DATETIME,
  disposition STRING NOT NULL,
  recon_home_agency_id STRING,
  tag_agency_id STRING,
  agency_code STRING,
  hia_agcy_id INT64,
  source_code STRING NOT NULL,
  source_txn_id INT64,
  lane_id INT64 NOT NULL,
  tvl_tag_status STRING,
  lic_plate_state STRING,
  lic_plate_nbr STRING,
  license_plate_id INT64,
  earned_class INT64,
  posted_class INT64,
  earned_revenue NUMERIC(31, 2),
  posted_revenue NUMERIC(31, 2),
  transaction_file_detail_id NUMERIC(29),
  last_update_type STRING,
  last_update_date DATETIME
)
CLUSTER BY source_txn_id;
