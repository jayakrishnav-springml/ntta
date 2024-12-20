CREATE TABLE [TollPlus].[TP_ViolatedTripStatusTracker]
(
	[StatusTrackerID] bigint NOT NULL,
	[CitationID] bigint NOT NULL,
	[TpTripID] bigint NOT NULL,
	[ViolatorID] bigint NOT NULL,
	[VehicleNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TripStatusID] int NOT NULL,
	[TripStatusDate] datetime2(3) NULL,
	[CitationStage] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CitationType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TripStageID] int NULL,
	[PlateType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([StatusTrackerID] DESC), DISTRIBUTION = HASH([StatusTrackerID]))
