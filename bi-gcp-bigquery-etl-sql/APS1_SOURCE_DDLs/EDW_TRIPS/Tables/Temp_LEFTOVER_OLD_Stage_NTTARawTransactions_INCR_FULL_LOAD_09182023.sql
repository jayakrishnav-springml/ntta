CREATE TABLE [Temp].[LEFTOVER_OLD_Stage_NTTARawTransactions_INCR_FULL_LOAD_09182023]
(
	[TPTripID] bigint NOT NULL,
	[SourceTripID] bigint NULL,
	[TripDayID] int NOT NULL,
	[TripDate] datetime2(3) NULL,
	[SourceOfEntry] tinyint NULL,
	[RecordType] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ViolationSerialNumber] bigint NULL,
	[VesTimestamp] datetime2(3) NULL,
	[LocalVesTimestamp] datetime2(3) NULL,
	[LaneID] int NULL,
	[FacilityCode] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlazaCode] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LaneNumber] int NULL,
	[VehicleSpeed] int NULL,
	[RevenueVehicleClass] int NULL,
	[LaneTagStatus] int NULL,
	[FareAmount] decimal(19,2) NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN)
