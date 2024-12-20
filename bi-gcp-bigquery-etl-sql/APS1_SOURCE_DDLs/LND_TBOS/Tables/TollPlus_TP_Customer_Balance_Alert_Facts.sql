CREATE TABLE [TollPlus].[TP_Customer_Balance_Alert_Facts]
(
	[CustomerID] bigint NOT NULL,
	[LowBalanceFlag] bit NULL,
	[LowBalanceDate] datetime2(3) NULL,
	[NegBalanceFlag] bit NULL,
	[NegBalanceDate] datetime2(3) NULL,
	[LowBalanceNotice] bit NULL,
	[NegativeBalanceNotice] bit NULL,
	[SentEmailCount] int NULL,
	[RegionalIOPLowBalanceFlag] bit NULL,
	[RegionalIOPLowBalanceDate] datetime2(3) NULL,
	[NationalIOPLowBalanceFlag] bit NULL,
	[NationalIOPLowBalanceDate] datetime2(3) NULL,
	[AccountFinancialStatus] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[BalanceFlag] bit NOT NULL,
	[BalanceNotice] bit NOT NULL,
	[BalanceDate] datetime2(3) NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CustomerID] DESC), DISTRIBUTION = HASH([CustomerID]))
