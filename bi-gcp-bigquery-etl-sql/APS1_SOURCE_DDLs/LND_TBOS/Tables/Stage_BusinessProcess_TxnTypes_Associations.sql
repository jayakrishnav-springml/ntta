CREATE TABLE [Stage].[BusinessProcess_TxnTypes_Associations]
(
	[TxnAssociationID] int NOT NULL,
	[BusinessProcessID] int NOT NULL,
	[TxnTypeID] int NOT NULL,
	[TxnCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ChartOfAccountID] int NULL,
	[LineItemCode] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Source] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TxnAssociationID] DESC), DISTRIBUTION = HASH([TxnAssociationID]))
