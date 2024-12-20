CREATE TABLE [TollPlus].[ZipCodes]
(
	[ZipCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[City] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[County] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[State] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxDotID] varchar(3) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsAdminHearing] bit NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ZipCode] ASC), DISTRIBUTION = HASH([ZipCode]))
