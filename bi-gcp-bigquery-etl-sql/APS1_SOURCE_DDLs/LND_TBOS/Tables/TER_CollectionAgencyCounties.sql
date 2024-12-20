CREATE TABLE [TER].[CollectionAgencyCounties]
(
	[CollAgencyCountyID] bigint NOT NULL,
	[CollAgencyID] bigint NOT NULL,
	[State] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[County] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ZipCode] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NOT NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CollAgencyCountyID] ASC), DISTRIBUTION = HASH([CollAgencyCountyID]))
