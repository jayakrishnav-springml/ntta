CREATE TABLE IF NOT EXISTS EDW_TER.Dim_Invoice_Status
(
  invoice_type STRING NOT NULL,
  invoice_status STRING NOT NULL,
  invoice_status_descr STRING,
  invoice_status_descr_group STRING,
  insert_date DATETIME NOT NULL
)
;
