## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_Plazas.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_Plazas
(
  plazaid INT64 NOT NULL,
  plazacode STRING,
  locationid INT64,
  plazaname STRING NOT NULL,
  description STRING,
  ipaddress STRING NOT NULL,
  portnumber STRING NOT NULL,
  agencyid INT64,
  pricemode STRING,
  transactionfeemode INT64,
  chartofaccountid INT64,
  ftpurl STRING,
  pgpkeyid STRING,
  ftplogin STRING,
  ftppwd STRING,
  encryptflag STRING,
  accountnumber STRING,
  accounttype STRING,
  accountname STRING,
  bankname STRING,
  ifsccode STRING,
  transactiontype STRING,
  isowned INT64,
  isnonrevenue INT64,
  plazatypeid INT64,
  exitplazacode STRING,
  channelid INT64,
  icnid INT64,
  parkingtaxrate NUMERIC(31, 2) NOT NULL,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by plazaid
;