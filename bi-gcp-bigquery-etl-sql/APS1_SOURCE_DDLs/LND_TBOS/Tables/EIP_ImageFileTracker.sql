CREATE TABLE [EIP].[ImageFileTracker]
(
	[ImageFileTrackerID] bigint NOT NULL,
	[PathID] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ImageFileName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Status] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ProcessDate] datetime2(0) NULL,
	[CreatedDate] datetime2(0) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(0) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ImageFileTrackerID] ASC), DISTRIBUTION = HASH([ImageFileTrackerID]))
