CREATE TABLE IF NOT EXISTS
  LND_TBOS_ARCHIVE_IDS_STAGE.BI_Archive_Reversal_IDS
(
  databasename      STRING NOT NULL,  -- TBOS, IPS etc.
  tablename       STRING NOT NULL,  -- Note: Populate full table name. SchemaName.TableName
  uniqueid_columnname STRING  NOT NULL, -- Table PK ColumnName
  uniqueid        INT64  NOT NULL,    -- Archive reversed row key value
  archivebatchdate    DATE NOT NULL,      -- Original Unique and easy to reference identifier for the Archive Date
  archivereversaldate DATETIME NOT NULL,  -- Exact timestamp of reversal of this ID. In BQ, SRC_ChangeDate of inserted (first) row from __ct afer ID's ArchiveBatchDate. Should be same date as ArchiveStartDate in dbo.TRIPS_ArchiveTracker reversal entry.
  lnd_updatedate    DATETIME NOT NULL
    )
  CLUSTER BY
       uniqueid ;
 
   
CREATE TABLE IF NOT EXISTS LND_TBOS_ARCHIVE_IDS_STAGE.BI_ArchiveReversalTracker
 
(
  archivebatchdate DATE NOT NULL,
  tablename STRING NOT NULL,
  reversalbatchcount INT64,
  first_archivereversaldate DATETIME,
  last_archivereversaldate DATETIME,
  lnd_firstid_reversed INT64,
  lnd_lastid_reversed INT64,
  lnd_rowcount_archived INT64,
  ids_rowcount_reversed INT64,
  final_rowcount_archived INT64,
  archiveflagrowcount INT64,
  lnd_reversal_rowcount_diff INT64,
  bi_archivereversalstageid NUMERIC(30, 1)
)
;
CREATE TABLE IF NOT EXISTS LND_TBOS_ARCHIVE_IDS_STAGE.Archive_ID_Reconcile_Table
(
  tablename STRING NOT NULL,
  uniqueid_columnname STRING NOT NULL,
  actual_rowcount_archived INT64 NOT NULL,
  tracker_rowcount_archived INT64 NOT NULL,
  rowcount_diff INT64
)
;
CREATE TABLE IF NOT EXISTS LND_TBOS_ARCHIVE_IDS_STAGE.BI_ArchiveTracker
(
  archivetrackerid INT64 NOT NULL,
  archivebatchdate DATE NOT NULL,
  databasename STRING NOT NULL,
  tablename STRING NOT NULL,
  uniqueid_columnname STRING NOT NULL,
  archivetype STRING NOT NULL,
  loadtype STRING NOT NULL,
  bi_archivesignaldate DATETIME,
  bi_archivestartdate DATETIME,
  bi_archivefinishdate DATETIME,
  bi_archiveduration STRING,
  bi_archivestageid NUMERIC(30, 1),
  src_firstid_archived INT64,
  src_lastid_archived INT64,
  src_rowcount_archived INT64,
  lnd_firstid_archived INT64,
  lnd_lastid_archived INT64,
  lnd_rowcount_archived INT64,
  src_lnd_rowcount_diff INT64,
  ids_loadstartdate DATETIME,
  ids_loadfinishdate DATETIME,
  ids_loadduration STRING,
  flagupdatestartdate DATETIME,
  flagupdatefinishdate DATETIME,
  flagupdateduration STRING,
  flagupdaterowcount INT64,
  src_upd_rowcount_diff INT64,
  ids_transferstartdate DATETIME,
  ids_transferfinishdate DATETIME,
  ids_transferduration STRING,
  ids_transferrowcount INT64,
  ids_transferrowcount_diff INT64,
  reversalbatchcount INT64,
  first_archivereversaldate DATETIME,
  last_archivereversaldate DATETIME,
  lnd_firstid_reversed INT64,
  lnd_lastid_reversed INT64,
  ids_rowcount_reversed INT64,
  archiveflagrowcount INT64,
  final_rowcount_archived INT64,
  lnd_reversal_rowcount_diff INT64,
  src_reversal_rowcount INT64,
  src_lnd_reversal_rowcount_diff INT64,
  bi_archivereversalstageid INT64,
  last_reversalloaddate DATETIME,
  lnd_updatedate DATETIME
)
;
       