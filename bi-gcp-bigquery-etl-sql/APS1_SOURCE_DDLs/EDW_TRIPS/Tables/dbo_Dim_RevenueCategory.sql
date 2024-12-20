CREATE TABLE [dbo].[Dim_RevenueCategory]
(
	[RevenueCategoryID] int NOT NULL,
	[RevenueCategoryCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RevenueCategoryDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NULL
)
WITH(CLUSTERED INDEX ([RevenueCategoryID] ASC), DISTRIBUTION = REPLICATE)
