CREATE TABLE [Utility].[ArchiveMasterTableList]
(
	[TableName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ArchiveMasterListDate] datetime2(3) NULL
)
WITH(HEAP, DISTRIBUTION = ROUND_ROBIN)
