CREATE TABLE [Utility].[TableLoadFacts]
(
	[TableName] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[InfoMessage] varchar(4000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ActionDateTime] datetime2(0) NULL,
	[IsFullLoad] bit NULL,
	[Success] smallint NULL
)
WITH(CLUSTERED INDEX ([TableName] ASC), DISTRIBUTION = REPLICATE)
