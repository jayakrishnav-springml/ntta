CREATE TABLE [Stage].[GlDailySummaryByCoaIDBuID]
(
	[DailySummaryID] bigint NOT NULL,
	[ChartOfAccountID] int NOT NULL,
	[BusinessUnitID] int NOT NULL,
	[BeginningBal] decimal(19,2) NOT NULL,
	[DebitTxnAmount] decimal(19,2) NOT NULL,
	[CreditTxnAmount] decimal(19,2) NOT NULL,
	[EndIngBal] decimal(19,2) NULL,
	[PostedDate] datetime2(3) NOT NULL,
	[FiscalYearName] varchar(128) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[JobRunDate] datetime2(3) NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ChartOfAccountID] ASC, [BusinessUnitID] ASC, [PostedDate] DESC), DISTRIBUTION = HASH([ChartOfAccountID]))
