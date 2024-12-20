CREATE TABLE [Utility].[CompareDailyRowCount]
(
	[CompareRunID] int NOT NULL,
	[DataBaseName] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TableName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CreatedDate] date NULL,
	[SRC_RowCount] bigint NULL,
	[APS_RowCount] bigint NULL,
	[RowCountDiff] bigint NULL,
	[DiffPercent] decimal(19,6) NULL,
	[SRC_RowCountDate] datetime2(3) NULL,
	[APS_RowCountDate] datetime2(3) NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([CompareRunID] DESC), DISTRIBUTION = ROUND_ROBIN)
