CREATE TABLE [Stage].[CustomerFlagReferenceLookup]
(
	[CustomerFlagReferenceID] int NOT NULL,
	[FlagName] varchar(128) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FlagDescription] varchar(128) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CustomerFlagReferenceID] ASC), DISTRIBUTION = HASH([CustomerFlagReferenceID]))
