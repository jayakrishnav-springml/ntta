CREATE TABLE [Archive].[PaymentTxn_LineItems]
(
	[ArchId] bigint NOT NULL,
	[LineItemID] bigint NOT NULL,
	[ArchiveBatchID] bigint NOT NULL,
	[ArchiveDate] datetime2(3) NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([LineItemID] DESC), DISTRIBUTION = HASH([LineItemID]))
