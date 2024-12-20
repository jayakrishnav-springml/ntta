CREATE TABLE [Utility].[TBOS_TableMetadata]
(
	[TableID] bigint NOT NULL,
	[DataBaseName] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[SchemaName] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TableName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[FullName] varchar(130) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[DistributionString] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IndexColumns] varchar(400) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ColumnName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ColumnID] int NULL,
	[ColumnNullable] bit NULL,
	[ColumnType] varchar(40) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(HEAP, DISTRIBUTION = REPLICATE)
