CREATE TABLE [dbo].[Dim_TransactionTypeCategory]
(
	[TransactionTypeCategoryID] int NOT NULL,
	[TransactionTypeCategoryCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionTypeCategoryDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NULL
)
WITH(CLUSTERED INDEX ([TransactionTypeCategoryID] ASC), DISTRIBUTION = REPLICATE)
