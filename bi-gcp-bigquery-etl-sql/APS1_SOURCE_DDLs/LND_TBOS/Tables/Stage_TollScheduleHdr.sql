CREATE TABLE [Stage].[TollScheduleHdr]
(
	[TollScheduleHdrID] bigint NOT NULL,
	[EntryLaneID] int NOT NULL,
	[EntryPlazaID] int NULL,
	[ExitPlazaID] int NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[StartEffectiveDate] datetime2(3) NOT NULL,
	[EndEffectiveDate] datetime2(3) NOT NULL,
	[TollScheduleHdrDesc] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionMenthod] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ScheduleType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NOT NULL,
	[Interval] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TollScheduleHdrID] DESC), DISTRIBUTION = HASH([TollScheduleHdrID]))
