CREATE TABLE [Stage].[ItemInventoryLocations]
(
	[LocationID] int NOT NULL,
	[LocationName] varchar(40) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[DayPhone] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EveningPhone] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Fax] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[MobileNo] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PrimaryEmail] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SecondaryEmail] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AddressLine1] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AddressLine2] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[City] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[State] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Country] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Zip1] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Zip2] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([LocationID] DESC), DISTRIBUTION = HASH([LocationID]))
