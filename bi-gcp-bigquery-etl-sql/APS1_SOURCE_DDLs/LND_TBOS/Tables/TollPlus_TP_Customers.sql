CREATE TABLE [TollPlus].[TP_Customers]
(
	[CustomerID] bigint NOT NULL,
	[UserTypeID] bigint NULL,
	[CustomerStatusID] bigint NULL,
	[AccountStatusID] bigint NOT NULL,
	[AccountStatusDate] datetime2(3) NOT NULL,
	[ParentCustomerID] bigint NOT NULL,
	[SourceOfEntry] int NULL,
	[RevenueCategoryID] int NOT NULL,
	[IsPrimary] bit NULL,
	[SourcePKID] bigint NOT NULL,
	[AgencyID] bigint NULL,
	[RegCustRefID] bigint NOT NULL,
	[LastActivityTimestamp] datetime2(3) NULL,
	[ICNID] bigint NULL,
	[ChannelID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CustomerID] DESC), DISTRIBUTION = HASH([CustomerID]))
