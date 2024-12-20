CREATE TABLE [Stage].[Collections_Inbound]
(
	[CollInbound_TxnID] bigint NOT NULL,
	[FileID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[TransactionDate] datetime2(3) NOT NULL,
	[FirstName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[MiddleName] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LastName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PreviousBalance] decimal(19,2) NULL,
	[TransactionAmount] decimal(19,2) NOT NULL,
	[CurrentBalance] decimal(19,2) NULL,
	[Status] tinyint NOT NULL,
	[Notes] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PaymentType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Errors] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CollInbound_TxnID] DESC), DISTRIBUTION = HASH([CollInbound_TxnID]))
