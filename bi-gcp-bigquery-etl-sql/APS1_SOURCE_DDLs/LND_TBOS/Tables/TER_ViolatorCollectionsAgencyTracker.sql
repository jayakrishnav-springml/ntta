CREATE TABLE [TER].[ViolatorCollectionsAgencyTracker]
(
	[VioCollAgencyTrackerID] bigint NOT NULL,
	[ViolatorID] bigint NULL,
	[Agency] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Phase] tinyint NULL,
	[PreviousAgency] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VioCollAgencyTrackerID] ASC), DISTRIBUTION = HASH([VioCollAgencyTrackerID]))
