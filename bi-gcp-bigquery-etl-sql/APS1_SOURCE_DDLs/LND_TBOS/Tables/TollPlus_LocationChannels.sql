CREATE TABLE [TollPlus].[LocationChannels]
(
	[LocationChannelID] int NOT NULL,
	[LocationID] bigint NOT NULL,
	[ChannelID] int NOT NULL,
	[ICNID] bigint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[StartEffectiveDate] datetime2(3) NULL,
	[EndEffectiveDate] datetime2(3) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([LocationChannelID] DESC), DISTRIBUTION = HASH([LocationChannelID]))
