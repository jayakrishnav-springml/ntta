## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_BAN_Report_Data.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Ban_Report_Data
(
  violatorid INT64,
  vidseq INT64,
  firstname STRING,
  lastname STRING,
  sec_viol_first_name STRING,
  sec_viol_last_name STRING,
  address STRING NOT NULL,
  violatoraddresscity STRING,
  violatoraddressstate STRING,
  phonenbr STRING,
  violatoraddresszipcode STRING,
  violatoraddressstatus STRING,
  hvdate DATE,
  licplatenbr STRING,
  licplatestate STRING,
  banletter STRING,
  banletterdate DATE,
  hv STRING,
  vin STRING,
  totalamountdue NUMERIC(33, 4),
  totalfeesdue NUMERIC(33, 4),
  totaltollsdue NUMERIC(33, 4),
  violator_addr_seq INT64,
  transaction_date DATETIME,
  usage_end_date DATETIME,
  tsa INT64,
  lbj INT64,
  lbj_tolls_due BIGNUMERIC(40, 2),
  non_lbj_tolls_due BIGNUMERIC(40, 2)
)
;
