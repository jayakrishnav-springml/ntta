CREATE TABLE [Archive].[Gl_Txn_LineItems]
(
	[ArchId] bigint NOT NULL,
	[PK_ID] bigint NOT NULL,
	[ArchiveBatchID] bigint NOT NULL,
	[ArchiveDate] datetime2(3) NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([PK_ID] DESC), DISTRIBUTION = HASH([PK_ID]))
