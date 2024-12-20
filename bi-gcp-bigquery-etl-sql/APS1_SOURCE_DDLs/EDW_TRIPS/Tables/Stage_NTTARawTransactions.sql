CREATE TABLE [Stage].[NTTARawTransactions]
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
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([TPTripID]), 
	PARTITION ([TripDayID] RANGE RIGHT FOR VALUES (20210101, 20210201, 20210301, 20210401, 20210501, 20210601, 20210701, 20210801, 20210901, 20211001, 20211101, 20211201, 20220101, 20220201, 20220301, 20220401, 20220501, 20220601, 20220701, 20220801, 20220901, 20221001, 20221101, 20221201, 20230101, 20230201, 20230301, 20230401, 20230501, 20230601, 20230701, 20230801, 20230901, 20231001, 20231101, 20231201, 20240101, 20240201, 20240301, 20240401)))
