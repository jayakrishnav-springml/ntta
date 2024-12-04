## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TER_ViolatorCollectionsOutbound.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TER_ViolatorCollectionsOutbound
(
  viocolloutboundid INT64 NOT NULL,
  fileid INT64,
  recordtype STRING,
  violatorid INT64,
  invoicenumber STRING,
  mbsid INT64,
  firstname STRING,
  lastname STRING,
  address1 STRING,
  address2 STRING,
  city STRING,
  state STRING,
  zipcode STRING,
  mobilephonenumber STRING,
  workphonenumber STRING,
  invoiceamount NUMERIC(31, 2),
  tollamount NUMERIC(31, 2),
  feeamount NUMERIC(31, 2),
  paymentorcreditadjustment NUMERIC(31, 2),
  reversalorcharge NUMERIC(31, 2),
  totalamountdue NUMERIC(31, 2),
  nsfindicator STRING,
  nsfdate DATETIME,
  zcinvoicedate DATETIME,
  firstnnpdate DATETIME,
  secondnnpdate DATETIME,
  thirdnnpdate DATETIME,
  vehiclenumber STRING,
  vehiclestate STRING,
  vehiclemake STRING,
  vehiclemodel STRING,
  vehiclecolor STRING,
  vehicleyear INT64,
  hastsatransactions STRING,
  rentalcarindicator STRING,
  recalldate DATETIME,
  lastactivityoninvoice DATETIME,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
viocolloutboundid
;