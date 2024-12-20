CREATE TABLE [TollPlus].[Channels]
(
	[ChannelID] int NOT NULL,
	[ChannelName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[IsDisplay] bit NOT NULL,
	[ChannelDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ChannelID] DESC), DISTRIBUTION = HASH([ChannelID]))
