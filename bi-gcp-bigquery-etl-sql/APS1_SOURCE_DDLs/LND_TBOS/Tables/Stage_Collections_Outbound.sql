CREATE TABLE [Stage].[Collections_Outbound]
(
	[CollOutbound_TxnID] bigint NOT NULL,
	[FileID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[FirstName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[MiddleName] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LastName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AddressLine1] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AddressLine2] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AddressLine3] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[City] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[State] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Country] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Zip1] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Zip2] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PhoneNumber] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Extention] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EmailAddress] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CollectionAmount] decimal(19,2) NOT NULL,
	[AccountStatusDate] datetime2(3) NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CollOutbound_TxnID] DESC), DISTRIBUTION = HASH([CollOutbound_TxnID]))
