## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_AuditTransactions.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.EIP_AuditTransactions
(
  trxnauditid_pk INT64 NOT NULL,
  auditsetupid INT64,
  audittype STRING,
  batchid INT64,
  transactionid INT64,
  agencycode STRING NOT NULL,
  plazaid STRING NOT NULL,
  laneid STRING NOT NULL,
  tranid STRING NOT NULL,
  vehicleclass STRING,
  transactiondate DATE NOT NULL,
  transactiontime INT64,
  plateregistration STRING,
  platejurisdiction STRING,
  platetypeprefix STRING,
  platetypesuffix STRING,
  representativeimageid INT64,
  representativeimageid2 INT64,
  statusid INT64,
  statusdate DATETIME,
  eipreceiveddate DATETIME,
  isaipprocessed INT64,
  isagree INT64,
  unreadreasoncode INT64,
  dispositioncode INT64,
  firstreviewer STRING,
  doubleblindreviewer STRING,
  doubleblinddate DATETIME,
  auditcomments STRING,
  doubleblindreviewercomments STRING,
  spotcheckstatus STRING,
  iscsvgenerated INT64,
  spotcheckrevieweddate DATETIME,
  spotcheckreviewer STRING,
  previousstatusid INT64,
  previousreviewername STRING,
  eipcompletiondate DATETIME,
  platetype STRING,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
) cluster by trxnauditid_pk
;