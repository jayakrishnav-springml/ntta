CREATE TABLE [Utility].[ProcDefinitions]
(
	[TableName] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ProcName] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ProcDefinition] varchar(max) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CleanDefinition] varchar(max) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ProcName] ASC), DISTRIBUTION = REPLICATE)
