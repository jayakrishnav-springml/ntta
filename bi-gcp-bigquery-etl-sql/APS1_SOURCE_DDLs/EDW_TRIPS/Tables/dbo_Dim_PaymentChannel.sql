CREATE TABLE [dbo].[Dim_PaymentChannel]
(
	[PaymentChannelID] int NOT NULL,
	[PaymentChannelCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PaymentChannelDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NULL
)
WITH(CLUSTERED INDEX ([PaymentChannelID] ASC), DISTRIBUTION = REPLICATE)
