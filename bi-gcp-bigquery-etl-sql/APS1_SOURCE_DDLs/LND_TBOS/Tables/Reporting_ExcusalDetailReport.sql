CREATE TABLE [Reporting].[ExcusalDetailReport]
(
	[SnapshotMonthID] int NOT NULL,
	[TPTripID] bigint NOT NULL,
	[CustomerID] bigint NULL,
	[VehicleNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LaneName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TripDate] datetime2(3) NULL,
	[ExcusedDateTime] datetime2(3) NULL,
	[TripStatusDate] datetime2(3) NULL,
	[TollAmount] decimal(19,2) NULL,
	[TollExcused] decimal(19,2) NULL,
	[AdminFee1] decimal(19,2) NULL,
	[AdminFee1Waived] decimal(19,2) NULL,
	[AdminFee2] decimal(19,2) NULL,
	[AdminFee2Waived] decimal(19,2) NULL,
	[ReasonCode] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[GroupLevel] varchar(40) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ExcuseBy] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([TPTripID] ASC), DISTRIBUTION = HASH([TPTripID]))
