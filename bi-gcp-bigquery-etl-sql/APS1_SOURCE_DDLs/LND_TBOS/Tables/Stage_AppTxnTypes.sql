CREATE TABLE [Stage].[AppTxnTypes]
(
	[AppTxnTypeID] int NOT NULL,
	[AppTxnTypeCode] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AppTxnTypeDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Effected_BalanceType_Positive] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Effected_BalanceType_Negative] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Main_Balance_Type] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxnType_CategoryID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([AppTxnTypeCode] ASC), DISTRIBUTION = HASH([AppTxnTypeCode]))
