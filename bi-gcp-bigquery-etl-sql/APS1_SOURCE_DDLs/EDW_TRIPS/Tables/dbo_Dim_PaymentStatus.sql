CREATE TABLE [dbo].[Dim_PaymentStatus]
(
	[PaymentStatusID] int NOT NULL,
	[PaymentStatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PaymentStatusDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NULL
)
WITH(CLUSTERED INDEX ([PaymentStatusID] ASC), DISTRIBUTION = REPLICATE)
