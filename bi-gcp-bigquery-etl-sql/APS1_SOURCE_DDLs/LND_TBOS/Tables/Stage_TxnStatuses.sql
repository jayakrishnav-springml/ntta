CREATE TABLE [Stage].[TxnStatuses]
(
	[StatusID] int NOT NULL,
	[StatusName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StatusCode] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StatusDescription] varchar(256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(0) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(0) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([StatusID] ASC), DISTRIBUTION = HASH([StatusID]))
