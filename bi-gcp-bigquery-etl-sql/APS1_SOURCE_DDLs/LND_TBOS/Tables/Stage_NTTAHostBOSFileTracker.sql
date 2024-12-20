CREATE TABLE [Stage].[NTTAHostBOSFileTracker]
(
	[ID] bigint NOT NULL,
	[PublishTime] datetime2(3) NULL,
	[SourceSystem] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RecordType] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RecordFileName] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FilePath] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsMalformed] bit NULL,
	[Reason] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RecordMessage] varchar(8000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ID] ASC), DISTRIBUTION = HASH([ID]))
