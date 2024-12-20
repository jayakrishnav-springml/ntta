CREATE TABLE [Stage].[Gl_Txn_LineItems]
(
	[PK_ID] bigint NOT NULL,
	[Gl_TxnID] bigint NOT NULL,
	[Description] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ChartOfAccountID] int NOT NULL,
	[DebitAmount] decimal(19,2) NOT NULL,
	[CreditAmount] decimal(19,2) NOT NULL,
	[SpecialJournalID] int NULL,
	[Drcr_Flag] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxnType_Li_ID] int NULL,
	[TxnTypeID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([PK_ID] DESC), DISTRIBUTION = HASH([PK_ID]))
