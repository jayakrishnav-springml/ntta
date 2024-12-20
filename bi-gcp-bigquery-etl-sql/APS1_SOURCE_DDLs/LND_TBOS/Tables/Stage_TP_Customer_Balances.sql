CREATE TABLE [Stage].[TP_Customer_Balances]
(
	[CustbalID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[BalanceDate] datetime2(3) NOT NULL,
	[BalanceAmount] decimal(19,2) NOT NULL,
	[BalanceType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CustbalID] ASC), DISTRIBUTION = HASH([CustbalID]))
