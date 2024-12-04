CREATE TABLE [Utility].[LoadProcessControl]
(
	[TableName] varchar(300) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LastUpdatedDate] datetime2(3) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(HEAP, DISTRIBUTION = REPLICATE)
