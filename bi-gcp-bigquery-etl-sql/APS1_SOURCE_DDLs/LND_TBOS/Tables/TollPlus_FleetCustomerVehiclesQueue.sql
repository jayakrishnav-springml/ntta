CREATE TABLE [TollPlus].[FleetCustomerVehiclesQueue]
(
	[QueueID] bigint NOT NULL,
	[ParentFileID] bigint NULL,
	[RecordSequenceNumber] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleState] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StartDate] datetime2(3) NULL,
	[EndDate] datetime2(3) NULL,
	[VIN] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleStatus] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Make] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Model] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Color] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsProcessed] bit NULL,
	[ReplaceErrorCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RecordCode] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Status] char(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ZipCashDue] decimal(9,2) NULL,
	[ResponseFileID] bigint NULL,
	[CallType] int NULL,
	[OtherInfo] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([QueueID] ASC), DISTRIBUTION = HASH([QueueID]))
