CREATE TABLE [dbo].[Dim_AutoReplenishment]
(
	[AutoReplenishmentID] int NOT NULL,
	[AutoReplenishmentCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AutoReplenishmentDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NULL
)
WITH(CLUSTERED INDEX ([AutoReplenishmentID] ASC), DISTRIBUTION = REPLICATE)
