CREATE TABLE [TollPlus].[TP_Customer_Contacts]
(
	[ContactID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[Title] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Suffix] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FirstName] varchar(60) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[MiddleName] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LastName] varchar(60) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Gender] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[NameType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[IsCommunication] bit NULL,
	[DateOfBirth] date NULL,
	[FirstName2] varchar(60) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LastName2] varchar(60) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ICNID] bigint NULL,
	[ChannelID] int NULL,
	[Race] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ContactID] DESC), DISTRIBUTION = HASH([ContactID]))
