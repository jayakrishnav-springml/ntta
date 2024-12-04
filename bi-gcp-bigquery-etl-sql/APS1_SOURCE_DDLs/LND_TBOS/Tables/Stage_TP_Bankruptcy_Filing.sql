CREATE TABLE [Stage].[TP_Bankruptcy_Filing]
(
	[BankruptcyFID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[StartDate] datetime2(3) NOT NULL,
	[PetitionNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[BankruptcyStatusID] int NOT NULL,
	[BankruptcyTypeID] int NOT NULL,
	[DecisionDate] datetime2(3) NULL,
	[ICNID] bigint NULL,
	[ChannelID] int NULL,
	[IsMigrated] bit NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([BankruptcyFID] ASC), DISTRIBUTION = HASH([BankruptcyFID]))
