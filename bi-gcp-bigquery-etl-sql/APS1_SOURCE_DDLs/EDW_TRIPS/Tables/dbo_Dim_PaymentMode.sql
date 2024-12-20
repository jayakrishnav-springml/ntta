CREATE TABLE [dbo].[Dim_PaymentMode]
(
	[PaymentModeID] int NULL,
	[PaymentModeCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PaymentModeDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PaymentModeGroupID] int NOT NULL,
	[PaymentModeGroupCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PaymentModeGroupDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NULL
)
WITH(CLUSTERED INDEX ([PaymentModeID] ASC), DISTRIBUTION = REPLICATE)
