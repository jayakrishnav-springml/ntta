CREATE TABLE [Stage].[FleetCustomersFileTracker]
(
	[TrackerID] bigint NOT NULL,
	[ParentFileID] bigint NULL,
	[CustomerID] bigint NULL,
	[FileDirection] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FileType] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FileName] varchar(128) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FileSequenceNumber] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FileProcessedDate] datetime2(3) NULL,
	[IsProcessed] bit NULL,
	[RecordCount] bigint NULL,
	[ProcessedCount] bigint NULL,
	[ErrorCount] bigint NULL,
	[ReplaceErrorCode] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OriginatingAuthority] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OriginatingAuthorityReference] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OriginalFileSequenceReference] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TrackerID] ASC), DISTRIBUTION = HASH([TrackerID]))
