## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_Collections_Outbound.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.TollPlus_Collections_Outbound
(
  colloutbound_txnid INT64 NOT NULL,
  fileid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  firstname STRING,
  middlename STRING,
  lastname STRING,
  addressline1 STRING,
  addressline2 STRING,
  addressline3 STRING,
  city STRING,
  state STRING,
  country STRING,
  zip1 STRING,
  zip2 STRING,
  phonenumber STRING,
  extention STRING,
  emailaddress STRING,
  collectionamount NUMERIC(31, 2) NOT NULL,
  accountstatusdate DATETIME NOT NULL,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY colloutbound_txnid
;