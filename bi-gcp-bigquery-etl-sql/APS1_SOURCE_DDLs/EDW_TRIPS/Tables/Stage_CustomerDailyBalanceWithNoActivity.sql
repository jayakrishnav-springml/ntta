CREATE TABLE [Stage].[CustomerDailyBalanceWithNoActivity]
(
	[CustomerID] int NOT NULL,
	[BalanceStartDate] date NULL,
	[TollTxnCount] int NOT NULL,
	[TollAmount] decimal(19,2) NOT NULL,
	[CreditAmount] decimal(19,2) NOT NULL,
	[DebitAmount] decimal(19,2) NOT NULL,
	[CreditTxnCount] int NOT NULL,
	[DebitTxnCount] int NOT NULL,
	[BeginningBalanceAmount] decimal(19,2) NOT NULL,
	[EndingBalanceAmount] decimal(19,2) NOT NULL,
	[CalcEndingBalanceAmount] decimal(19,2) NOT NULL,
	[BalanceDiffAmount] decimal(19,2) NOT NULL,
	[BeginningCustTxnID] bigint NULL,
	[EndingCustTxnID] bigint NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([CustomerID] ASC), DISTRIBUTION = HASH([CustomerID]))
