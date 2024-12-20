CREATE TABLE [TollPlus].[TP_CustTxns]
(
	[CustTxnID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[LinkID] bigint NOT NULL,
	[LinkSourceName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxnAmount] decimal(19,2) NOT NULL,
	[PostedDate] datetime2(3) NOT NULL,
	[VehicleID] bigint NOT NULL,
	[AppTxnTypeCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[BusinessProcessCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Stmt_Literal] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CustTxnCategory] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PreviousBalance] decimal(19,2) NULL,
	[CurrentBalance] decimal(19,2) NULL,
	[SubSystem] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LocationName] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[BalanceType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CustTxnID] DESC), DISTRIBUTION = HASH([CustTxnID]))
