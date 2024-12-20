CREATE TABLE [TollPlus].[TP_Customer_Flags]
(
	[CustomerFlagID] bigint NOT NULL,
	[CustomerID] bigint NULL,
	[CustomerFlagReferenceID] int NULL,
	[FlagValue] bit NULL,
	[StartDate] datetime2(3) NULL,
	[EndDate] datetime2(3) NULL,
	[ICNID] bigint NULL,
	[ChannelID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CustomerFlagID] ASC), DISTRIBUTION = HASH([CustomerFlagID]))
