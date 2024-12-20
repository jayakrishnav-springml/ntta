CREATE TABLE [Stage].[TxnType_Categories]
(
	[CategoryID] int NOT NULL,
	[CategoryName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CategoryDesc] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Status] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Parent_CategoryID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CategoryID] DESC), DISTRIBUTION = HASH([CategoryID]))
