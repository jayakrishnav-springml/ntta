CREATE TABLE [EIP].[InboundFileTracker]
(
	[InboundFileID] int NOT NULL,
	[AgencyCode] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[FileName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[FilePath] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ServiceName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ProcessCode] int NULL,
	[ProcessType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ProcessDate] datetime2(0) NULL,
	[FileType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[RecordCount] int NULL,
	[AcceptCount] int NULL,
	[RejectReason] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(0) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(0) NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([InboundFileID] ASC), DISTRIBUTION = HASH([InboundFileID]))
