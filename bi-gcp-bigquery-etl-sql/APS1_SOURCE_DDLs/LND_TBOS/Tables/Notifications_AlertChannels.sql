CREATE TABLE [Notifications].[AlertChannels]
(
	[AlertChannelID] int NOT NULL,
	[AlertChannelName] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[BitMapValue] int NULL,
	[ChannelDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Active] bit NOT NULL,
	[Remarks] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([AlertChannelID] DESC), DISTRIBUTION = HASH([AlertChannelID]))
