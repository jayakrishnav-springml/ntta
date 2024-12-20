CREATE TABLE [TollPlus].[TP_Customer_Phones]
(
	[CustPhoneID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[PhoneType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PhoneNumber] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Extention] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NOT NULL,
	[IsCommunication] bit NOT NULL,
	[IsVerified] bit NULL,
	[IsBadPhone] bit NULL,
	[IssoLicitPhone] bit NULL,
	[ICNID] bigint NULL,
	[ChannelID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CustPhoneID] DESC), DISTRIBUTION = HASH([CustPhoneID]))
