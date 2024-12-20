CREATE TABLE [TollPlus].[TP_Customer_Logins]
(
	[LoginID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[ICNID] bigint NULL,
	[ChannelID] int NULL,
	[UserName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Password] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Last_LoginDate] datetime2(3) NULL,
	[Last_Pwd_ModifiedDate] datetime2(3) NULL,
	[Current_Pwd_ExpiryDate] datetime2(3) NULL,
	[Pwd_Attempts_Count] tinyint NULL,
	[PinNumber] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsLocked] bit NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Sq_AttemptCount] int NULL,
	[Sq_LockOutTime] datetime2(3) NULL,
	[LockoutTime] datetime2(3) NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([LoginID] DESC), DISTRIBUTION = HASH([LoginID]))
