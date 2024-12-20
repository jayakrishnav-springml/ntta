CREATE TABLE [TollPlus].[TP_Customer_Business]
(
	[CustomerID] bigint NOT NULL,
	[OrganisationName] varchar(128) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsFleet] bit NOT NULL,
	[ICNID] bigint NULL,
	[ChannelID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] char(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CustomerID] DESC), DISTRIBUTION = HASH([CustomerID]))
