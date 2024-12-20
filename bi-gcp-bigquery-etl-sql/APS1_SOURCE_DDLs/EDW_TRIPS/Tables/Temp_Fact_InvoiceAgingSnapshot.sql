CREATE TABLE [Temp].[Fact_InvoiceAgingSnapshot]
(
	[SnapshotDate] date NULL,
	[SnapshotMonthID] int NOT NULL,
	[CitationID] bigint NOT NULL,
	[CustomerID] bigint NULL,
	[AgeStageID] int NULL,
	[CitationStageID] int NULL,
	[LaneID] int NOT NULL,
	[VehicleID] bigint NULL,
	[TPTripID] bigint NOT NULL,
	[InvoiceStatusID] int NULL,
	[InvoiceNumber] bigint NULL,
	[TransactionDate] date NULL,
	[InvoiceDate] date NULL,
	[PostedDate] date NULL,
	[DueDate] date NULL,
	[FirstNoticeFeeDate] date NULL,
	[SecondNoticeFeeDate] date NULL,
	[TotalTransactions] int NULL,
	[TollsDue] decimal(19,2) NULL,
	[FirstNoticeFees] decimal(9,2) NULL,
	[SecondNoticeFees] decimal(9,2) NULL,
	[OutstandingAmount] decimal(19,2) NULL,
	[OutStandingFees] decimal(19,2) NULL,
	[CurrentInvoiceFlag] int NULL,
	[TxnDate] date NULL,
	[FNFeesDate] date NULL,
	[SNFeesDate] date NULL,
	[TotalTxns] int NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([CitationID]), 
	PARTITION ([SnapshotMonthID] RANGE RIGHT FOR VALUES (202001, 202002, 202003, 202004, 202005, 202006, 202007, 202008, 202009, 202010, 202011, 202012, 202101, 202102, 202103)))
