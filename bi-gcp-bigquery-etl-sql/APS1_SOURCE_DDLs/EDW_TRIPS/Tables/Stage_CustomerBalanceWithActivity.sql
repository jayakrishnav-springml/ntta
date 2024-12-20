CREATE TABLE [Stage].[CustomerBalanceWithActivity]
(
	[SnapshotMonthID] int NOT NULL,
	[CustomerID] int NOT NULL,
	[BalanceDate] date NULL,
	[TollTxnCount] int NOT NULL,
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
WITH(HEAP, DISTRIBUTION = HASH([CustomerID]))
