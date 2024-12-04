CREATE TABLE [Temp].[ArchiveMasterTableList_TO_INSERT]
(
	[TableName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ArchiveMasterListDate] datetime2(3) NULL,
	[RN] bigint NULL
)
WITH(HEAP, DISTRIBUTION = HASH([TableName]))
