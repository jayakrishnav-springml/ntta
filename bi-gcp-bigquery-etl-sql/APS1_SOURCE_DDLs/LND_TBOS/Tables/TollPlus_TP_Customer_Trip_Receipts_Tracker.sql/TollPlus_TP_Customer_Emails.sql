CREATE TABLE [TollPlus].[TP_Customer_Emails]
(
	[CustMailID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[EmailType] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EmailAddress] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NOT NULL,
	[IsCommunication] bit NOT NULL,
	[IsValid] bit NOT NULL,
	[IsVerified] bit NULL,
	[IsBadEmail] bit NULL,
	[VerificationCount] tinyint NULL,
	[VerificationDate] datetime2(3) NULL,
	[ICNID] bigint NULL,
	[ChannelID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CustMailID] DESC), DISTRIBUTION = HASH([CustMailID]))
