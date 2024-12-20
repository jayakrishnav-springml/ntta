CREATE TABLE [dbo].[Dim_AccountType]
(
	[AccountTypeID] int NOT NULL,
	[AccountTypeCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AccountTypeDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NULL
)
WITH(CLUSTERED INDEX ([AccountTypeID] ASC), DISTRIBUTION = REPLICATE)
