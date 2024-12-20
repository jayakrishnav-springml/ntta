CREATE TABLE [Stage].[BusinessProcesses]
(
	[BusinessProcessID] int NOT NULL,
	[BusinessProcessCode] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[BusinessProcessDescription] varchar(8000) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Status] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsAvailable] bit NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([BusinessProcessID] DESC), DISTRIBUTION = HASH([BusinessProcessID]))
