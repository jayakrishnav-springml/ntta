CREATE TABLE [dbo].[Fact_GL_DailySummary]
(
	[DailySummaryID] bigint NOT NULL,
	[ChartOfAccountID] int NOT NULL,
	[BusinessUnitID] int NOT NULL,
	[BeginningBal] decimal(19,2) NOT NULL,
	[EndIngBal] decimal(19,2) NULL,
	[DebitTxnAmount] decimal(19,2) NOT NULL,
	[CreditTxnAmount] decimal(19,2) NOT NULL,
	[PostedDate] date NULL,
	[JobRunDate] date NULL,
	[FiscalYearName] varchar(128) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DeleteFlag] bit NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([DailySummaryID] DESC), DISTRIBUTION = HASH([DailySummaryID]))
