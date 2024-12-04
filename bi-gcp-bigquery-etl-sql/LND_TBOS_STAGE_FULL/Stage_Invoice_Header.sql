## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_Invoice_Header.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_Invoice_Header
(
  invoiceid INT64 NOT NULL,
  invoicenumber STRING,
  masterinvoiceid INT64,
  invoicedate DATETIME,
  duedate DATETIME,
  startperiod DATETIME,
  endperiod DATETIME,
  customerid INT64,
  vehicleid INT64,
  stagestepid INT64,
  previousdue NUMERIC(31, 2),
  totalamount NUMERIC(31, 2),
  amountpaid NUMERIC(31, 2),
  balancedue NUMERIC(31, 2),
  invoicestatus STRING,
  currentcharges NUMERIC(31, 2),
  adjustedamount NUMERIC(31, 2),
  isviolator INT64,
  invbatchid STRING,
  inv_file_path STRING,
  unbilledamt NUMERIC(31, 2),
  overpmtamt NUMERIC(31, 2),
  servicetax NUMERIC(31, 2) NOT NULL,
  is_hold INT64 NOT NULL,
  ispdfgenerated INT64 NOT NULL,
  agencyid INT64,
  graceperioddate DATETIME,
  mailingdate DATETIME,
  agestageid INT64,
  currentchargestoll NUMERIC(31, 2),
  currentchargesfee NUMERIC(31, 2),
  nonpaymentfee NUMERIC(31, 2),
  invoiceadjamt NUMERIC(31, 2),
  invoiceaccountstatus STRING,
  previousduestartperiod DATETIME,
  previousdueendperiod DATETIME,
  mailreturndate DATETIME,
  isdiscountprocessed INT64,
  unpaidtripcnt INT64,
  collectionstatus INT64,
  sourceid INT64,
  sourcename STRING,
  unpaidtripamount NUMERIC(31, 2),
  sourcewriteoff INT64 NOT NULL,
  channelid INT64,
  icnid INT64,
  citationstatus STRING,
  secntvdate DATETIME,
  sourceinvoicestatus STRING,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
invoiceid
;