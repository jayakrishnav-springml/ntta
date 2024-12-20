CREATE TABLE [Utility].[TableDependencies]
(
	[TableName] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DependsOnTable] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ToControlLoad] smallint NULL
)
WITH(CLUSTERED INDEX ([TableName] ASC), DISTRIBUTION = REPLICATE)
