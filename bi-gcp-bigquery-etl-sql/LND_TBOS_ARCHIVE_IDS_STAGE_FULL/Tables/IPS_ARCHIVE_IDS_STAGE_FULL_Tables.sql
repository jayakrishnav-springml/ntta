CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS_STAGE_FULL.VehicleImages_IDS (TxnImageID INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (TxnImageID) NOT ENFORCED
    )
CLUSTER BY
  TxnImageID;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS_STAGE_FULL.Transactions_IDS (TransactionID INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (TransactionID) NOT ENFORCED
    )
CLUSTER BY
  TransactionID ;

CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS_STAGE_FULL.Results_Log_IDS (TransactionID INT64 NOT NULL,
    archivebatchdate DATE NOT NULL,
    lnd_updatedate DATETIME NOT NULL,
  PRIMARY KEY
    (TransactionID) NOT ENFORCED
    )
CLUSTER BY
  TransactionID;