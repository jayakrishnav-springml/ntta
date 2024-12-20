CREATE TABLE [Stage].[TP_CustomerTripStatusTracker]
(
	[StatusTrackerID] bigint NOT NULL,
	[CustTripID] bigint NULL,
	[TpTripID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[VehicleNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleState] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleClass] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ReasonCode] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ReasonDesc] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TripStageID] int NOT NULL,
	[TripStatusID] int NOT NULL,
	[TripStatusDate] datetime2(3) NULL,
	[PlateType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([StatusTrackerID] DESC), DISTRIBUTION = HASH([StatusTrackerID]))
