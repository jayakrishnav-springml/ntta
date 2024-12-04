## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/MIR_MIR_Transactions.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.MIR_MIR_Transactions
(
  transactionid INT64 NOT NULL,
  node STRING NOT NULL,
  agencycode STRING NOT NULL,
  plazaid STRING NOT NULL,
  laneid STRING NOT NULL,
  tranid STRING NOT NULL,
  transactiontypeid INT64 NOT NULL,
  transactiondate DATE NOT NULL,
  transactiontime INT64 NOT NULL,
  eipreceiveddate DATETIME,
  vehicleclass STRING,
  platetypeprefix STRING,
  platetypesuffix STRING,
  plateregistration STRING,
  platejurisdiction STRING,
  initstageid INT64,
  statusid INT64,
  groupid INT64,
  reptransactionid INT64 NOT NULL,
  cameraid STRING,
  dispositioncode INT64,
  unreadreasoncode INT64,
  subreasontime INT64,
  totalmirtime INT64,
  totalreviews INT64 NOT NULL,
  totalimgenhtime INT64,
  plateregistrationmir STRING,
  platejurisdictionmir STRING,
  syntaxpattern STRING,
  imageofrecordid INT64 NOT NULL,
  imageofrecordid2 INT64 NOT NULL,
  isvalidgroup INT64 NOT NULL,
  isalprvalid INT64 NOT NULL,
  islpnresultsdeleted INT64,
  groupsize INT64 NOT NULL,
  isroichanged INT64 NOT NULL,
  mirreceiveddate DATETIME NOT NULL,
  mircompleteddate DATETIME,
  platetype STRING,
  createduser STRING NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)

CLUSTER BY
transactionid;