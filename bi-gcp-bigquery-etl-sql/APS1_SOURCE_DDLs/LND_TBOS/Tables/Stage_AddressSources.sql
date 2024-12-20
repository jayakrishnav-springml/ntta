CREATE TABLE [Stage].[AddressSources]
(
	[AddressSourceID] int NOT NULL,
	[AddressSourceName] varchar(40) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PriorityOrder] int NULL,
	[IsActive] bit NULL,
	[IsDisplay] bit NOT NULL,
	[Description] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([AddressSourceID] ASC), DISTRIBUTION = HASH([AddressSourceID]))
