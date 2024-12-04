CREATE TABLE IF NOT EXISTS LND_TBOS_SUPPORT.Source_DailyRowCount
(
  databasename STRING NOT NULL,
  tablename STRING NOT NULL,
  createddate DATE,
  sourcerowcount INT64,
  lnd_updatedate DATETIME,
);

ALTER TABLE LND_TBOS_SUPPORT.Source_DailyRowCount ADD COLUMN IF NOT EXISTS executionid INT64;
ALTER TABLE LND_TBOS_SUPPORT.Source_DailyRowCount ADD COLUMN IF NOT EXISTS sourceexectimeinsec FLOAT64;