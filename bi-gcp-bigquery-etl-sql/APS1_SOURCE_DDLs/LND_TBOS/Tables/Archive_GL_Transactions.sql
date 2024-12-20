CREATE TABLE [Archive].[GL_Transactions]
(
	[ArchId] bigint NOT NULL,
	[GL_TxnID] bigint NOT NULL,
	[ArchiveBatchID] bigint NOT NULL,
	[ArchiveDate] datetime2(3) NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([GL_TxnID] DESC), DISTRIBUTION = HASH([GL_TxnID]))
