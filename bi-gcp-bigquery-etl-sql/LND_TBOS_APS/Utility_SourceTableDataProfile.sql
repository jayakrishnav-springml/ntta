
CREATE TABLE IF NOT EXISTS LND_TBOS_APS.SourceTableDataProfile
(
  databasename STRING,
  tablename STRING,
  tablename_arch STRING,
  tablename_ids STRING,
  row_count INT64,
  used_gb NUMERIC(31, 2),
  unused_gb NUMERIC(31, 2),
  total_gb NUMERIC(31, 2),
  lnd_updatedate DATETIME
)
;
