CREATE TABLE [Temp].[ArchiveMasterTableList_DUPS]
(
	[TableName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CNT] int NULL
)
WITH(HEAP, DISTRIBUTION = HASH([TableName]))
