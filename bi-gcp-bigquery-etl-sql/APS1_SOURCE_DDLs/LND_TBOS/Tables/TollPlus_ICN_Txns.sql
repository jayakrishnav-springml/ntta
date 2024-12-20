CREATE TABLE [TollPlus].[ICN_Txns]
(
	[ICNTxnID] bigint NOT NULL,
	[ICNID] bigint NOT NULL,
	[TxnType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LinkID] bigint NOT NULL,
	[LinkSourceName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ICNTxnID] DESC), DISTRIBUTION = HASH([ICNTxnID]))
