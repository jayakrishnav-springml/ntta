CREATE TABLE [Ref].[Fact_UnifiedTransaction_StaticSummary]
(
	[TripMonthID] int NULL,
	[OperationsMappingID] int NOT NULL,
	[FacilityID] int NOT NULL,
	[TxnCount] bigint NULL,
	[ExpectedAmount] decimal(19,2) NULL,
	[AdjustedExpectedAmount] decimal(19,2) NULL,
	[CalcAdjustedAmount] decimal(19,2) NULL,
	[TripWithAdjustedAmount] decimal(19,2) NULL,
	[TollAmount] decimal(19,2) NULL,
	[ActualPaidAmount] decimal(19,2) NULL,
	[OutstandingAmount] decimal(19,2) NULL,
	[EDW_UpdateDate] datetime2(7) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([OperationsMappingID]))
