CREATE TABLE [TollPlus].[TP_Customer_Vehicle_Tags]
(
	[VehicleTagID] bigint NOT NULL,
	[VehicleID] bigint NOT NULL,
	[CustTagID] bigint NOT NULL,
	[IsBlockListed] bit NOT NULL,
	[StartEffectiveDate] datetime2(3) NULL,
	[EndEffectiveDate] datetime2(3) NULL,
	[ChannelID] int NULL,
	[ICNID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VehicleTagID] DESC), DISTRIBUTION = HASH([VehicleTagID]))
