CREATE TABLE [Utility].[TableAlias]
(
	[TableName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AliasShort] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AliasLong] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AliasFull] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CreatedDate] datetime2(0) NOT NULL
)
WITH(HEAP, DISTRIBUTION = REPLICATE)
