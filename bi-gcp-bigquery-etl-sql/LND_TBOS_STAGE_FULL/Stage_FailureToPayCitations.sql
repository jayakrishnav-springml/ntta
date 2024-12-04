## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_FailureToPayCitations.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TER_FailureToPayCitations
(
  failurecitationid INT64 NOT NULL,
  courtid INT64 NOT NULL,
  judgeid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  courtappearancedate DATETIME NOT NULL,
  dpstrooperid INT64 NOT NULL,
  maildate DATETIME,
  printdate DATETIME,
  citationnumber STRING,
  nttarepresentative STRING NOT NULL,
  referencetripid INT64 NOT NULL,
  hvstatuslookupid INT64 NOT NULL,
  cdltype INT64,
  isactive INT64,
  dpscitationnumber STRING,
  custresponselookupid INT64,
  dismissalreasondesc STRING,
  dpscitationissueddate DATETIME,
  casenumber STRING,
  sourcepkid INT64,
  isprimaryowner INT64,
  notaryofficerid INT64,
  citationinvoiceid INT64,
  agestageid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY 
failurecitationid
;