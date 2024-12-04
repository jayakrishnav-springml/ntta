CREATE TABLE [Temp].[Gl_Transactions_Archive_Reversal_Dup_20230920]
(
	[Gl_TxnID] bigint NOT NULL,
	[PostingDate] datetime2(3) NOT NULL,
	[PostingDate_yyyymm] int NOT NULL,
	[CustomerID] bigint NOT NULL,
	[TxnTypeID] int NOT NULL,
	[BusinessProcessID] int NOT NULL,
	[LinkID] bigint NOT NULL,
	[LinkSourceName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxnDate] datetime2(3) NOT NULL,
	[TxnAmount] decimal(19,2) NOT NULL,
	[IsContra] bit NULL,
	[Description] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RequestID] varchar(37) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[BusinessUnitId] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN)
