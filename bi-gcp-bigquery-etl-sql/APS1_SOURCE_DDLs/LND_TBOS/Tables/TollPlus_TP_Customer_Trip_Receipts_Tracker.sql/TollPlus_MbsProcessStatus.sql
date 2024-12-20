CREATE TABLE [TollPlus].[MbsProcessStatus]
(
	[MbsProcessStatusID] int NOT NULL,
	[MbsProcessCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[MbsProcessStatus] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NOT NULL,
	[ProcessDescription] varchar(400) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([MbsProcessStatusID] ASC), DISTRIBUTION = HASH([MbsProcessStatusID]))
