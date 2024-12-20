CREATE TABLE [Archive].[TP_Customer_Business]
(
	[ArchId] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[ArchiveBatchID] bigint NOT NULL,
	[ArchiveDate] datetime2(3) NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([CustomerID] DESC), DISTRIBUTION = HASH([CustomerID]))
