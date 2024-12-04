## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_GlDailySummaryByCoaIDBuID.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.Finance_GlDailySummaryByCoaIDBuID
(
  dailysummaryid INT64 NOT NULL,
  chartofaccountid INT64 NOT NULL,
  businessunitid INT64 NOT NULL,
  beginningbal NUMERIC(31, 2) NOT NULL,
  debittxnamount NUMERIC(31, 2) NOT NULL,
  credittxnamount NUMERIC(31, 2) NOT NULL,
  endingbal NUMERIC(31, 2),
  posteddate DATETIME NOT NULL,
  fiscalyearname STRING,
  jobrundate DATETIME NOT NULL,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
chartofaccountid,businessunitid,posteddate
;