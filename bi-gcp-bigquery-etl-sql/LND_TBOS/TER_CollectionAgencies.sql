## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TER_CollectionAgencies.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TER_CollectionAgencies
(
  collagencyid INT64 NOT NULL,
  collagencyname STRING NOT NULL,
  collagencydesc STRING,
  collagencycode STRING NOT NULL,
  isprimaryagency INT64 NOT NULL,
  parentcollagencyid INT64,
  isactive INT64 NOT NULL,
  mindueamount NUMERIC(31, 2),
  maxdueamount NUMERIC(31, 2),
  maxnewaccounts INT64 NOT NULL,
  displayname STRING,
  customervolume INT64,
  isnewaccountprocessed INT64 NOT NULL,
  ispayenabled INT64 NOT NULL,
  isundoenabled INT64 NOT NULL,
  newaccountpreference INT64 NOT NULL,
  amountvolume INT64,
  collectionfee NUMERIC(31, 2),
  channelid INT64,
  icnid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
collagencyid
;