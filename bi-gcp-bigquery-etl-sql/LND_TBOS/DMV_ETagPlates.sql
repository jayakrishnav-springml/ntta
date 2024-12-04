## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/DMV_ETagPlates.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.DMV_ETagPlates
(
  etagplaterecordid INT64 NOT NULL,
  uniqueid INT64,
  vin STRING,
  licenseplatenumber STRING NOT NULL,
  licenseplatestate STRING NOT NULL,
  etagusagereason STRING,
  etagdescription STRING,
  titleno STRING,
  ownername1 STRING,
  ownername2 STRING,
  owneraddress1 STRING,
  owneraddress2 STRING,
  ownercity STRING,
  ownerstate STRING,
  ownerzip1 STRING,
  ownerzip2 STRING,
  vehiclebodystyle STRING,
  vehiclemake STRING,
  vehiclemodel STRING,
  vehicleyear STRING,
  vehiclecolor STRING,
  ownershipstartdate DATETIME NOT NULL,
  ownershipenddate DATETIME,
  fileid INT64 NOT NULL,
  stage1recordid INT64,
  stage2recordid INT64,
  normalisedlicenseplatenumber STRING NOT NULL,
  normalisedpreviousplateno STRING,
  createduser STRING,
  createdtimestamp DATETIME,
  updateduser STRING,
  updatedtimestamp DATETIME,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
etagplaterecordid
;