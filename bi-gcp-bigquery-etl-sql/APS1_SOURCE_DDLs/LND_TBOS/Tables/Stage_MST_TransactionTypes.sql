CREATE TABLE [Stage].[MST_TransactionTypes]
(
	[TransactionTypeID] smallint NOT NULL,
	[TransactionType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TransactionTypeSource] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CreatedDate] datetime2(0) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TransactionTypeID] ASC), DISTRIBUTION = HASH([TransactionTypeID]))
