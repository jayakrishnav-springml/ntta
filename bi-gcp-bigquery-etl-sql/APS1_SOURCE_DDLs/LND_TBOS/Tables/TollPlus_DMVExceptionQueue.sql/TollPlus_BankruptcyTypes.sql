CREATE TABLE [TollPlus].[BankruptcyTypes]
(
	[BankruptcyTypeID] int NOT NULL,
	[BankruptcyType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[BankruptcyTypeDesc] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([BankruptcyTypeID] ASC), DISTRIBUTION = HASH([BankruptcyTypeID]))
