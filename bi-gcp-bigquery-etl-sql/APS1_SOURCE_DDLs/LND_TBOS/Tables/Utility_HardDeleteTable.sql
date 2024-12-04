CREATE TABLE [Utility].[HardDeleteTable]
(
	[DataBaseName] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TableName] varchar(130) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(7) NOT NULL
)
WITH(HEAP, DISTRIBUTION = ROUND_ROBIN)
