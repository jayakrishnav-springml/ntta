CREATE TABLE [TollPlus].[TollScheduleDtl]
(
	[TollScheduleDtlID] bigint NOT NULL,
	[TollScheduleHdrID] bigint NOT NULL,
	[TollRateID] bigint NOT NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[FromTime] decimal(9,2) NULL,
	[ToTime] decimal(9,2) NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TollScheduleDtlID] DESC), DISTRIBUTION = HASH([TollScheduleDtlID]))
