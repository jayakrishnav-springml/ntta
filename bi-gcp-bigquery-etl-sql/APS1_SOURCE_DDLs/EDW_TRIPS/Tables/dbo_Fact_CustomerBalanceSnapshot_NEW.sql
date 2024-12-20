CREATE TABLE [dbo].[Fact_CustomerBalanceSnapshot_NEW]
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
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([CustomerID]), 
	PARTITION ([SnapshotMonthID] RANGE RIGHT FOR VALUES (202101, 202102, 202103, 202104, 202105, 202106, 202107, 202108, 202109, 202110, 202111, 202112, 202201, 202202, 202203, 202204, 202205, 202206, 202207, 202208, 202209, 202210, 202211, 202212, 202301, 202302, 202303, 202304, 202305, 202306, 202307, 202308, 202309, 202310, 202311, 202312, 202401, 202402, 202403, 202404)))
