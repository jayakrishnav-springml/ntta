CREATE TABLE [Stage].[TP_FileTracker]
(
	[FileID] bigint NOT NULL,
	[FileName] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FileType] int NULL,
	[ProcessStatus] int NULL,
	[RecordCount] int NULL,
	[ProcessedCount] int NULL,
	[ProcessedDate] datetime2(3) NULL,
	[Source] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Destination] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RequestSource] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[BusinessDate] datetime2(3) NULL,
	[FailedCount] int NULL,
	[ResponseCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RejectCode] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RejectReason] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([FileID] ASC), DISTRIBUTION = HASH([FileID]))
