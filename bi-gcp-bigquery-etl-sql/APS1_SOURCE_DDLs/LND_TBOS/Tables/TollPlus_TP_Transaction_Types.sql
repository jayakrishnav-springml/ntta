CREATE TABLE [TollPlus].[TP_Transaction_Types]
(
	[TransactionTypeID] tinyint NOT NULL,
	[TransactiontCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactiontDesc] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TransactionTypeID] ASC), DISTRIBUTION = HASH([TransactionTypeID]))
