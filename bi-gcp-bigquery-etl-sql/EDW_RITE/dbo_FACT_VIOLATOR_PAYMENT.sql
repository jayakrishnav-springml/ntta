## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_VIOLATOR_PAYMENT.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Violator_Payment
(
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  payment_txn_id INT64 NOT NULL,
  licenseplateid INT64 NOT NULL,
  card_code STRING NOT NULL,
  payment_source_code STRING NOT NULL,
  viol_pay_type STRING NOT NULL,
  pmt_txn_type STRING,
  retail_trans_id INT64,
  trans_date DATE,
  trans_amt NUMERIC(33, 4),
  created_by STRING NOT NULL,
  pos_name STRING,
  inv_toll_amt NUMERIC(33, 4),
  inv_fees_amt NUMERIC(33, 4),
  invoice_type STRING,
  amount_due NUMERIC(33, 4),
  viol_invoice_id INT64,
  vbi_vbi_invoice_id INT64,
  insert_date DATETIME NOT NULL
)
;
