CREATE TABLE [Temp].[ArchiveDeleteRowCount_DUPS]
(
	[LND_UpdateDate] date NULL,
	[TableName] varchar(130) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Row_Count] bigint NULL,
	[CNT] int NULL
)
WITH(HEAP, DISTRIBUTION = HASH([TableName]))
