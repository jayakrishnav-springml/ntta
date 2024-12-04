CREATE TABLE IF NOT EXISTS
	LND_TBOS_ARCHIVE_IDS.BI_Archive_Reversal_IDS
(
 	databasename			STRING NOT NULL,	-- TBOS, IPS etc.
	tablename				STRING NOT NULL,	-- Note: Populate full table name. SchemaName.TableName
	uniqueid_columnname	STRING	NOT NULL,	-- Table PK ColumnName
	uniqueid				INT64  NOT NULL, 		-- Archive reversed row key value
	archivebatchdate		DATE NOT NULL,			-- Original Unique and easy to reference identifier for the Archive Date
	archivereversaldate	DATETIME NOT NULL,	-- Exact timestamp of reversal of this ID. In BQ, SRC_ChangeDate of inserted (first) row from __ct afer ID's ArchiveBatchDate. Should be same date as ArchiveStartDate in dbo.TRIPS_ArchiveTracker reversal entry.
	lnd_updatedate		DATETIME NOT NULL
    ) 
	CLUSTER BY
       uniqueid ; 