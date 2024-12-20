CREATE TABLE [Stage].[Ref_FeeTypes]
(
	[FeeTypeID] int NOT NULL,
	[FeeName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FeeCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FeeDescription] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FeeFactor] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Amount] decimal(19,2) NULL,
	[StartEffectiveDate] datetime2(3) NULL,
	[EndEffectiveDate] datetime2(3) NULL,
	[IsActive] bit NOT NULL,
	[AppliedOn_AccountCreation] bit NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([FeeTypeID] DESC), DISTRIBUTION = HASH([FeeTypeID]))
