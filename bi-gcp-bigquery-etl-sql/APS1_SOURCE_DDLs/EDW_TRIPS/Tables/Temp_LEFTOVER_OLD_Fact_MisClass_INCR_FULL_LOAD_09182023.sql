CREATE TABLE [Temp].[LEFTOVER_OLD_Fact_MisClass_INCR_FULL_LOAD_09182023]
(
	[TpTripID] bigint NOT NULL,
	[TripWith] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ExitTripDateTime] datetime2(3) NULL,
	[DayID] int NULL,
	[TripIdentMethodID] smallint NULL,
	[LaneID] int NULL,
	[VehicleID] bigint NOT NULL,
	[LicensePlateNumber] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ReportedVehicleClassID] int NOT NULL,
	[MostFrequentVehicleClassID] int NULL,
	[TollsDue] decimal(19,2) NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[EDW_UpdateDate] datetime2(7) NOT NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN)
