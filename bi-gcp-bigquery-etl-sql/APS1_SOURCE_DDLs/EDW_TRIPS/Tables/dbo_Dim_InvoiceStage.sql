CREATE TABLE [dbo].[Dim_InvoiceStage]
(
	[InvoiceStageID] int NOT NULL,
	[InvoiceStageCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[InvoiceStageDesc] varchar(256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AgingPeriod] int NULL,
	[GracePeriod] int NULL,
	[WaiveAllFees] int NOT NULL,
	[ApplyAVIRate] int NOT NULL,
	[StageOrder] int NULL,
	[EDW_UpdatedDate] datetime2(7) NOT NULL
)
WITH(CLUSTERED INDEX ([InvoiceStageID] ASC), DISTRIBUTION = REPLICATE)
