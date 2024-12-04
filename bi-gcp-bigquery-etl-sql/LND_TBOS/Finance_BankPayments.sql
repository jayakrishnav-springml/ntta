## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Finance_BankPayments.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.Finance_BankPayments
(
  paymentid INT64 NOT NULL,
  bankname STRING,
  accountname STRING,
  accountnumber STRING,
  cctokenid STRING,
  pnrefid STRING,
  custrefid STRING,
  resultcode STRING,
  paymentstatusid INT64,
  refpaymentid INT64,
  replaceerrorcode STRING,
  responsemessage STRING,
  accounttype STRING,
  routingnumber STRING,
  banksuffix4 INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
paymentid
;