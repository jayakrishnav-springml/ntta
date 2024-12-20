CREATE TABLE [Stage].[TripStatuses]
(
	[TripStatusID] int NOT NULL,
	[TripStatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TripStatusDescription] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TripStatusID] DESC), DISTRIBUTION = HASH([TripStatusID]))
