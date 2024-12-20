CREATE TABLE [TollPlus].[TripStages]
(
	[TripStageID] int NOT NULL,
	[TripStageCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TripStageDescription] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ParentStageID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TripStageID] DESC), DISTRIBUTION = HASH([TripStageID]))
