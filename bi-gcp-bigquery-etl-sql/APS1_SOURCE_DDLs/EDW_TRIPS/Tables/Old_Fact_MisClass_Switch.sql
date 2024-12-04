CREATE TABLE [Old].[Fact_MisClass_Switch]
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
WITH(CLUSTERED INDEX ([TpTripID] ASC), DISTRIBUTION = HASH([TpTripID]), 
	PARTITION ([DayID] RANGE RIGHT FOR VALUES (20200101, 20200201, 20200301, 20200401, 20200501, 20200601, 20200701, 20200801, 20200901, 20201001, 20201101, 20201201, 20210101, 20210201, 20210301, 20210401, 20210501, 20210601, 20210701, 20210801, 20210901, 20211001, 20211101, 20211201, 20220101, 20220201, 20220301, 20220401, 20220501, 20220601, 20220701, 20220801, 20220901, 20221001, 20221101, 20221201, 20230101, 20230201, 20230301, 20230401, 20230501, 20230601, 20230701, 20230801, 20230901, 20231001, 20231101, 20231201, 20240101, 20240201, 20240301, 20240401)))
