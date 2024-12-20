CREATE TABLE [dbo].[Dim_CitationStage]
(
	[CitationStageID] int NOT NULL,
	[CitationStageCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CitationStageDesc] varchar(256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AgingPeriod] int NULL,
	[GracePeriod] int NULL,
	[WaiveAllFees] int NOT NULL,
	[ApplyAVIRate] int NOT NULL,
	[StageOrder] int NULL,
	[EDW_UpdateDate] datetime2(7) NOT NULL
)
WITH(CLUSTERED INDEX ([CitationStageID] ASC), DISTRIBUTION = REPLICATE)
