CREATE TABLE IF NOT EXISTS LND_TBOS_SUPPORT.Landing_DailyRowCount
(
  datasetname STRING NOT NULL,
  tablename STRING NOT NULL,
  createddate DATE,
  landingrowcount INT64,
  lnd_updatedate DATETIME,
);

ALTER TABLE LND_TBOS_SUPPORT.Landing_DailyRowCount ADD COLUMN IF NOT EXISTS executionid INT64;