CREATE TABLE [Archive].[TP_CustTxns]
(
	[ArchId] bigint NOT NULL,
	[CustTxnID] bigint NOT NULL,
	[ArchiveBatchID] bigint NOT NULL,
	[ArchiveDate] datetime2(3) NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([CustTxnID] DESC), DISTRIBUTION = HASH([CustTxnID]))
