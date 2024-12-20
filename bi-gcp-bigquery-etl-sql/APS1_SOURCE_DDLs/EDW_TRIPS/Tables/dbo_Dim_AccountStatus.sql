CREATE TABLE [dbo].[Dim_AccountStatus]
(
	[AccountStatusID] int NOT NULL,
	[AccountStatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AccountStatusDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NULL
)
WITH(CLUSTERED INDEX ([AccountStatusID] ASC), DISTRIBUTION = REPLICATE)
