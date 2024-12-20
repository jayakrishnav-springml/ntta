CREATE TABLE [Stage].[PaymentTxn_LineItems]
(
	[LineItemID] bigint NOT NULL,
	[PaymentID] bigint NOT NULL,
	[AppTxnTypeCode] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LineItemAmount] decimal(19,2) NOT NULL,
	[LinkID] bigint NULL,
	[LinkSourceName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CustomerID] bigint NULL,
	[PaymentDate] datetime2(3) NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([LineItemID] DESC), DISTRIBUTION = HASH([LineItemID]))
