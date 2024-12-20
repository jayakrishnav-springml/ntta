CREATE TABLE [Archive].[TP_Violated_Trip_Receipts_Tracker]
(
	[ArchId] bigint NOT NULL,
	[TripReceiptID] bigint NOT NULL,
	[ArchiveBatchID] bigint NOT NULL,
	[ArchiveDate] datetime2(3) NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([TripReceiptID] DESC), DISTRIBUTION = HASH([TripReceiptID]))
