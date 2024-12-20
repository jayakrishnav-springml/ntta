CREATE TABLE [dbo].[Dim_PaymentModeGroup]
(
	[PaymentModeGroupID] int NOT NULL,
	[PaymentModeGroupCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PaymentModeGroupDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NULL
)
WITH(CLUSTERED INDEX ([PaymentModeGroupID] ASC), DISTRIBUTION = REPLICATE)
