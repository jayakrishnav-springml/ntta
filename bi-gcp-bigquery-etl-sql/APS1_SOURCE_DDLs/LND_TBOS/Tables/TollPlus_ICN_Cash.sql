CREATE TABLE [TollPlus].[ICN_Cash]
(
	[ICN_CashID] bigint NOT NULL,
	[ICNID] bigint NOT NULL,
	[Nickle] int NULL,
	[OneCoin] int NULL,
	[Penny] int NULL,
	[Dimes] int NULL,
	[Quarter] int NULL,
	[Half] int NULL,
	[One] int NULL,
	[Two] int NULL,
	[Five] int NULL,
	[Ten] int NULL,
	[Twenty] int NULL,
	[Fifty] int NULL,
	[Hundred] int NULL,
	[Type] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ICN_CashID] DESC), DISTRIBUTION = HASH([ICN_CashID]))
