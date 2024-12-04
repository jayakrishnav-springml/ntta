## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Ref_RitemigratedTxnInvoices.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.RitemigratedTxnInvoices
(
  invoicenumber NUMERIC(29),
  invoicestatus STRING,
  vbi_invoice_id NUMERIC(29) NOT NULL,
  zipcashdate DATETIME NOT NULL,
  firstnoticedate DATETIME NOT NULL,
  secondnoticedate DATETIME,
  vbi_status STRING NOT NULL,
  viol_invoice_id NUMERIC(29),
  violinvoicedate DATETIME,
  viol_inv_status STRING,
  violation_id NUMERIC(29),
  finalviolstatus STRING,
  vb_viol_status STRING,
  viv_viol_status STRING,
  invoice_stage_id INT64 NOT NULL,
  finaltollamount BIGNUMERIC(42, 4),
  vb_tolldue NUMERIC(33, 4),
  viv_tolldue BIGNUMERIC(40, 2),
  vb_reunassigned_excused_amt NUMERIC(33, 4),
  viol_reunassigned_excused_amt BIGNUMERIC(40, 2),
  vb_reunassigned_excused_txncnt INT64,
  viol_reunassigned_excused_txncnt INT64,
  totaltxns INT64
)
;