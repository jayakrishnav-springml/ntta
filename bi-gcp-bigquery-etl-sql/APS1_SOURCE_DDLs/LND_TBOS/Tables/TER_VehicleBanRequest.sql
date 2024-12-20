CREATE TABLE [TER].[VehicleBanRequest]
(
	[VehicleBanRequestID] bigint NOT NULL,
	[FileID] bigint NULL,
	[VehicleNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleState] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleYear] smallint NULL,
	[VehicleMake] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleModel] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[VehicleBanID] bigint NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VehicleBanRequestID] ASC), DISTRIBUTION = HASH([VehicleBanRequestID]))
