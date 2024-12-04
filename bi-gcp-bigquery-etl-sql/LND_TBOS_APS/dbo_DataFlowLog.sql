CREATE TABLE IF NOT EXISTS LND_TBOS_APS.dbo_DataFlowLog
(
  logdate DATETIME NOT NULL,
  tableload STRING NOT NULL,
  databasename STRING NOT NULL,
  schemaname STRING NOT NULL,
  tablename STRING NOT NULL,
  changedatafrom DATETIME,
  changedatato DATETIME,
  logduration STRING,
  row_count INT64 NOT NULL,
  reservedsize NUMERIC(31, 2) NOT NULL,
  datasize NUMERIC(31, 2) NOT NULL,
  indexsize NUMERIC(31, 2) NOT NULL,
  unusedsize NUMERIC(31, 2) NOT NULL
)
CLUSTER BY logdate
;
