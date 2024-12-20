CREATE TABLE [TollPlus].[TP_TollRate_Dtls]
(
	[TollRateDtlID] bigint NOT NULL,
	[TollRateID] bigint NOT NULL,
	[VehicleClass] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LaneType] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TollAmount] decimal(19,2) NOT NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TollRateDtlID] DESC), DISTRIBUTION = REPLICATE)
