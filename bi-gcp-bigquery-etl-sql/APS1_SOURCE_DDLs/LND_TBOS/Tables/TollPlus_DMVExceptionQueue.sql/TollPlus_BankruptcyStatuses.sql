CREATE TABLE [TollPlus].[BankruptcyStatuses]
(
	[BankruptcyStatusID] int NOT NULL,
	[BankruptcyStatus] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[BankruptcyStatusDesc] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StatusID] int NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([BankruptcyStatusID] ASC), DISTRIBUTION = HASH([BankruptcyStatusID]))
