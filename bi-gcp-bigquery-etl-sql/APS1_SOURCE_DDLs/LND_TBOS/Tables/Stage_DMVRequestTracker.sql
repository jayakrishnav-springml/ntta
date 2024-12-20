CREATE TABLE [Stage].[DMVRequestTracker]
(
	[RequestTrackerID] bigint NOT NULL,
	[FileID] bigint NULL,
	[LicenseNumber] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ReceivedDate] datetime2(3) NULL,
	[TransactionDate] datetime2(3) NULL,
	[RequestSource] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RequestedUser] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleState] varchar(16) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleCountry] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ExpirationYear] int NULL,
	[EndEffectiveDate] datetime2(3) NULL,
	[BusinessDate] datetime2(3) NULL,
	[DMVResponse] varchar(40) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DMVProvider] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([RequestTrackerID] DESC), DISTRIBUTION = HASH([RequestTrackerID]))
