CREATE TABLE [Notifications].[AlertTypes]
(
	[AlertTypeID] int NOT NULL,
	[AlertType] varchar(40) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AlertTypeDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ConfigurableFlag] bit NULL,
	[Parent_AlertTypeID] int NULL,
	[IsPayByMail] bit NULL,
	[IsPostPaid] bit NULL,
	[IsPrePaid] bit NULL,
	[TransmissionType] int NULL,
	[IsActive] bit NULL,
	[SeedList] bit NULL,
	[IsMobileWebsite] bit NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[GroupName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsPortalDisplay] bit NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([AlertTypeID] DESC), DISTRIBUTION = HASH([AlertTypeID]))
