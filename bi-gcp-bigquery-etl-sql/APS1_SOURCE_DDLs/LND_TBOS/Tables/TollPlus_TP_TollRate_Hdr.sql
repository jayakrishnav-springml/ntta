CREATE TABLE [TollPlus].[TP_TollRate_Hdr]
(
	[TollRateHdrID] bigint NOT NULL,
	[TollRateName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NOT NULL,
	[TransactionMenthod] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleClassType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TollRateHdrID] DESC), DISTRIBUTION = REPLICATE)
