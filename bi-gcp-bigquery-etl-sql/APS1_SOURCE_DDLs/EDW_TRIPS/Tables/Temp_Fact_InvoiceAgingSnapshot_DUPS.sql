CREATE TABLE [Temp].[Fact_InvoiceAgingSnapshot_DUPS]
(
	[SnapshotMonthID] int NOT NULL,
	[CitationID] bigint NOT NULL,
	[CNT] int NULL
)
WITH(HEAP, DISTRIBUTION = HASH([CitationID]))
