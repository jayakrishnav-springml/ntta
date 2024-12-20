CREATE TABLE [Temp].[ArchiveDeleteRowCount_TO_INSERT]
(
	[LND_UpdateDate] date NULL,
	[DataBaseName] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TableName] varchar(130) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CDCFlag] bit NULL,
	[ArchiveFlag] bit NULL,
	[HardDeleteTableFlag] bit NULL,
	[ArchiveMasterListFlag] bit NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Row_Count] bigint NULL,
	[RowCountDate] datetime2(3) NULL,
	[RN] bigint NULL
)
WITH(HEAP, DISTRIBUTION = HASH([TableName]))
