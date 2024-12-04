## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_ItemInventoryLocations.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.Inventory_ItemInventoryLocations
(
  locationid INT64 NOT NULL,
  locationname STRING NOT NULL,
  dayphone STRING,
  eveningphone STRING,
  fax STRING,
  mobileno STRING,
  primaryemail STRING,
  secondaryemail STRING,
  addressline1 STRING,
  addressline2 STRING,
  city STRING,
  state STRING,
  country STRING,
  zip1 STRING,
  zip2 STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
locationid
;