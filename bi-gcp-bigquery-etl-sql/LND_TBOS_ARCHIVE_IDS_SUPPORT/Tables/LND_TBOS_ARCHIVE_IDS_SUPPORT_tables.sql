CREATE TABLE IF NOT EXISTS LND_TBOS_ARCHIVE_IDS_SUPPORT.BI_ArchiveStage
(
  bi_archivestageid NUMERIC(30, 1) NOT NULL, --primary key 
  bi_archivestage STRING NOT NULL,
  bi_archivestagedesc STRING NOT NULL,
  bi_archivetype STRING NOT NULL,
  createddate DATETIME,
  PRIMARY KEY
    (bi_archivestageid) NOT ENFORCED
)
;

CREATE TABLE IF NOT EXISTS LND_TBOS_ARCHIVE_IDS_SUPPORT.BI_ArchiveTracker
(
  archivetrackerid INT64 NOT NULL,  --primary key 
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
  bi_archivestageid NUMERIC(30, 1), --Forign BI_ArchiveStage(bi_archivestageid)
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
   /* New! Archive Reversal summary recorded here for 360 degrees view */
    ------------------------------------------------
  reversalbatchcount INT64,
  first_archivereversaldate DATETIME, -- ArchiveReversalDate maps to SRC_ChangeDate (exactly when the reversed ID row is INSERTED BACK into TBOS DB) in BQ LND_TBOS_Qlik __ct table.	
  last_archivereversaldate DATETIME,
  lnd_firstid_reversed INT64,
  lnd_lastid_reversed INT64,
  ids_rowcount_reversed INT64,
  archiveflagrowcount INT64,
  final_rowcount_archived INT64, /* Final_RowCount_Archived = LND_RowCount_Archived- IDS_RowCount_Reversed*/
  lnd_reversal_rowcount_diff INT64, /* LND_Reversal_RowCount_Diff = ArchiveFlagRowCount - Final_RowCount_Archived*/,
  src_reversal_rowcount INT64,/* Archive Reversal data from TBOS DBA Team*/
  src_lnd_reversal_rowcount_diff INT64, /* SRC_LND_Reversal_RowCount_Diff = SRC_Reversal_RowCount - IDS_RowCount_Reversed*/
  bi_archivereversalstageid INT64, /*FK to dbo.BI_ArchiveReversalStage: 5.1 Reversal started. 5.2. BI internal reversal reconciled. 5.3. SRC vs LND reversal reconciled 5.4 Reconcile mismatch (internal or with SRC) 5.5 Reversal reconcile complete*/
  last_reversalloaddate DATETIME,
  lnd_updatedate DATETIME,
    PRIMARY KEY
    (archivetrackerid) NOT ENFORCED,
)CLUSTER BY
  archivetrackerid 
;

CREATE TABLE IF NOT EXISTS LND_TBOS_ARCHIVE_IDS_SUPPORT.BI_ArchiveTracker_BKUP
(
  archivetrackerid INT64 NOT NULL,  --primary key 
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
  bi_archivestageid NUMERIC(30, 1), --Forign BI_ArchiveStage(bi_archivestageid)
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
   /* New! Archive Reversal summary recorded here for 360 degrees view */
    ------------------------------------------------
  reversalbatchcount INT64,
  first_archivereversaldate DATETIME, -- ArchiveReversalDate maps to SRC_ChangeDate (exactly when the reversed ID row is INSERTED BACK into TBOS DB) in BQ LND_TBOS_Qlik __ct table.	
  last_archivereversaldate DATETIME,
  lnd_firstid_reversed INT64,
  lnd_lastid_reversed INT64,
  ids_rowcount_reversed INT64,
  archiveflagrowcount INT64,
  final_rowcount_archived INT64, /* Final_RowCount_Archived = LND_RowCount_Archived- IDS_RowCount_Reversed*/
  lnd_reversal_rowcount_diff INT64, /* LND_Reversal_RowCount_Diff = ArchiveFlagRowCount - Final_RowCount_Archived*/,
  src_reversal_rowcount INT64,/* Archive Reversal data from TBOS DBA Team*/
  src_lnd_reversal_rowcount_diff INT64, /* SRC_LND_Reversal_RowCount_Diff = SRC_Reversal_RowCount - IDS_RowCount_Reversed*/
  bi_archivereversalstageid INT64, /*FK to dbo.BI_ArchiveReversalStage: 5.1 Reversal started. 5.2. BI internal reversal reconciled. 5.3. SRC vs LND reversal reconciled 5.4 Reconcile mismatch (internal or with SRC) 5.5 Reversal reconcile complete*/
  last_reversalloaddate DATETIME,
  lnd_updatedate DATETIME,
  LND_BackupDate DATETIME ,
    PRIMARY KEY
    (archivetrackerid) NOT ENFORCED
)CLUSTER BY
  archivetrackerid 
;

CREATE TABLE IF NOT EXISTS LND_TBOS_ARCHIVE_IDS_SUPPORT.TRIPS_ArchiveStage
(
  trips_archivestageid NUMERIC(30, 1) NOT NULL,
  trips_archivestage STRING NOT NULL,
  trips_archivestagedesc STRING NOT NULL,
  trips_archivetype STRING NOT NULL,
  createddate DATETIME,
  PRIMARY KEY (trips_archivestageid) NOT ENFORCED
)CLUSTER BY 
trips_archivestageid
;

CREATE TABLE IF NOT EXISTS LND_TBOS_ARCHIVE_IDS_SUPPORT.TRIPS_ArchiveTracker
(
  archivetrackerid INT64 NOT NULL,
  archivebatchdate DATE NOT NULL,
  databasename STRING NOT NULL,
  tablename STRING NOT NULL,
  uniqueid_columnname STRING NOT NULL,
  archivetype STRING NOT NULL,
  trips_archivestageid NUMERIC(30, 1) NOT NULL,
  archivestartdate DATETIME NOT NULL,
  archivestagefinishdate DATETIME,
  archiveduration STRING,
  bi_archivesignaldate DATETIME,
  bi_archivestartdate DATETIME,
  bi_archivefinishdate DATETIME,
  bi_archiveduration STRING,
  trips_stopdate DATETIME,
  trips_startdate DATETIME,
  firstid_archived INT64 NOT NULL,
  lastid_archived INT64 NOT NULL,
  rowcount_archived INT64 NOT NULL,
  firstid_beforearchive INT64,
  lastid_beforearchive INT64,
  rowcount_beforearchive INT64,
  firstid_afterarchive INT64,
  lastid_afterarchive INT64,
  rowcount_afterarchive INT64,
  ids_loadstartdate DATETIME,
  ids_loadfinishdate DATETIME,
  ids_loadduration STRING,
  new_loadstartdate DATETIME,
  new_loadfinishdate DATETIME,
  new_loadduration STRING,
  tablerenamedate DATETIME,
  copydatastartdate DATETIME,
  copydatafinishdate DATETIME,
  copydataduration STRING,
  deletestartdate DATETIME,
  deletefinishdate DATETIME,
  deleteduration STRING,
  tablesize_beforearchive_gb NUMERIC(31, 2),
  tablesize_afterarchive_gb NUMERIC(31, 2),
  PRIMARY KEY (archivetrackerid) NOT ENFORCED
) CLUSTER BY archivetrackerid
;

CREATE TABLE IF NOT EXISTS LND_TBOS_ARCHIVE_IDS_SUPPORT.ArchiveDeleteRowCount
(
  lnd_updatedate DATE,
  databasename STRING NOT NULL,
  tablename STRING NOT NULL,
  cdcflag INT64,
  archiveflag INT64,
  harddeletetableflag INT64,
  archivemasterlistflag INT64,
  lnd_updatetype STRING,
  row_count INT64,
  rowcountdate DATETIME
)
;

CREATE TABLE IF NOT EXISTS LND_TBOS_ARCHIVE_IDS_SUPPORT.ArchiveMasterTableList
(
  tablename STRING,
  archivemasterlistdate DATETIME
)
;

CREATE TABLE IF NOT EXISTS LND_TBOS_ARCHIVE_IDS_SUPPORT.TRIPS_ArchivePlan
(
  databasename STRING NOT NULL,
  tablename STRING NOT NULL,
  archivecategory STRING NOT NULL,
  archivepolicy STRING NOT NULL,
  archiveplandate DATE,
  lnd_updatedate DATETIME
)
;