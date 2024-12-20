CREATE TABLE [dbo].[Dim_CustomerStatus]
(
	[CustomerStatusID] int NOT NULL,
	[CustomerStatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CustomerStatusDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NULL
)
WITH(CLUSTERED INDEX ([CustomerStatusID] ASC), DISTRIBUTION = REPLICATE)
