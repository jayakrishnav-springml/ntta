CREATE TABLE [Archive].[Overpayments]
(
	[ArchId] bigint NOT NULL,
	[OverpaymentID] bigint NOT NULL,
	[ArchiveBatchID] bigint NOT NULL,
	[ArchiveDate] datetime2(3) NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([OverpaymentID] DESC), DISTRIBUTION = HASH([OverpaymentID]))
