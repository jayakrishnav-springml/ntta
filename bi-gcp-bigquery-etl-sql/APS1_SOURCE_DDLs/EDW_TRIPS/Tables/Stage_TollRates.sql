CREATE TABLE [Stage].[TollRates]
(
	[EntryPlazaId] int NULL,
	[ExitPlazaId] int NULL,
	[ExitlaneId] int NOT NULL,
	[LaneType] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[StartEffectiveDate] datetime2(3) NOT NULL,
	[EndEffectiveDate] datetime2(3) NOT NULL,
	[VehicleClass] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ScheduleType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FromTime] decimal(9,2) NULL,
	[ToTime] decimal(9,2) NULL,
	[TagFare] decimal(19,2) NULL,
	[PlateFare] decimal(19,2) NULL
)
WITH(CLUSTERED INDEX ([ExitlaneId] ASC), DISTRIBUTION = REPLICATE)
