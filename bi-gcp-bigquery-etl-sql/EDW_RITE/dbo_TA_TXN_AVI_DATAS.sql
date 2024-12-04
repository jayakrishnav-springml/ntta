## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_TA_TXN_AVI_DATAS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Ta_Txn_Avi_Datas
(
  partition_values INT64,
  avi_reader_nbr STRING NOT NULL,
  avi_tag_class STRING NOT NULL,
  avi_tag_id STRING NOT NULL,
  avi_plaza_and_ln_id STRING NOT NULL,
  avi_tag_status STRING NOT NULL,
  avi_handshake STRING,
  avi_year STRING NOT NULL,
  avi_month STRING NOT NULL,
  avi_day STRING NOT NULL,
  avi_hour STRING NOT NULL,
  avi_minute STRING NOT NULL,
  avi_second STRING NOT NULL,
  tad_id NUMERIC(29) NOT NULL,
  tart_id NUMERIC(29),
  tag_agency STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
