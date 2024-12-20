CREATE TABLE [History].[TP_Customers]
(
	[HistID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[UserTypeID] bigint NULL,
	[CustomerStatusID] bigint NULL,
	[AccountStatusID] bigint NOT NULL,
	[AccountStatusDate] datetime2(3) NULL,
	[ParentCustomerID] bigint NULL,
	[SourceOfEntry] int NULL,
	[RevenueCategoryID] int NOT NULL,
	[IsPrimary] bit NULL,
	[SourcePKID] bigint NULL,
	[Action] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AgencyID] bigint NULL,
	[RegCustRefID] bigint NULL,
	[ICNID] bigint NULL,
	[ChannelID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([HistID] DESC), DISTRIBUTION = HASH([HistID]))
