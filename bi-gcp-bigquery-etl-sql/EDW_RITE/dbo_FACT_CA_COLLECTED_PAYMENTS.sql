## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_CA_COLLECTED_PAYMENTS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Ca_Collected_Payments
(
  last_invoice_id INT64 NOT NULL,
  payment_id INT64 NOT NULL,
  vbi_invoice_id INT64 NOT NULL,
  viol_invoice_id INT64 NOT NULL,
  violator_id INT64 NOT NULL,
  invoice_date DATETIME NOT NULL,
  viol_inv_status STRING NOT NULL,
  vb_invoice_date DATETIME NOT NULL,
  vbi_status STRING NOT NULL,
  invoice_amount NUMERIC(31, 2) NOT NULL,
  invoice_amt_disc NUMERIC(31, 2) NOT NULL,
  toll_amount NUMERIC(31, 2) NOT NULL,
  toll_fee NUMERIC(31, 2) NOT NULL,
  date_excused DATETIME NOT NULL,
  excused_by STRING NOT NULL,
  dps_inv_status STRING NOT NULL,
  vidseq INT64 NOT NULL,
  paymentplanid INT64 NOT NULL,
  hv_start_date DATE NOT NULL,
  hv_end_date DATE NOT NULL,
  payment_date DATE,
  pos_id INT64 NOT NULL,
  delivery_code STRING NOT NULL,
  payment_source_code STRING NOT NULL,
  viol_amount NUMERIC(31, 2)
)
cluster by payment_id,viol_invoice_id,vbi_invoice_id
;
