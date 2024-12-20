CREATE TABLE [Stage].[Lanes]
(
	[LaneID] int NOT NULL,
	[LaneCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[PlazaID] int NOT NULL,
	[LaneName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LaneType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Description] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LaneStatus] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Direction] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LaneCategoryID] smallint NULL,
	[ExitLaneCode] varchar(3) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([LaneID] DESC), DISTRIBUTION = HASH([LaneID]))
