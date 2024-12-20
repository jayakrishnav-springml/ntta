CREATE TABLE [Stage].[Locations]
(
	[LocationID] int NOT NULL,
	[LocationCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LocationName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Description] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsOwned] bit NULL,
	[IsNonRevenue] bit NULL,
	[CountyName] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CourtName] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AgencyID] bigint NULL,
	[IsHVEnabled] bit NULL,
	[IsTSA] bit NULL,
	[AgencyTSASubscriberMapID] int NULL,
	[TSAFacilityID] int NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([LocationID] DESC), DISTRIBUTION = HASH([LocationID]))
