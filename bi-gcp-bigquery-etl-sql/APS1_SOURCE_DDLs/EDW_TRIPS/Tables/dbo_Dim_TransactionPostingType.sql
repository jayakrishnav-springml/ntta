CREATE TABLE [dbo].[Dim_TransactionPostingType]
(
	[TransactionPostingTypeID] int NOT NULL,
	[TransactionPostingType] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TransactionPostingTypeDesc] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[EDW_UpdatedDate] datetime2(7) NOT NULL
)
WITH(CLUSTERED INDEX ([TransactionPostingTypeID] ASC), DISTRIBUTION = REPLICATE)
